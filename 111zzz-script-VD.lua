-- Сервисы
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

-- Настройки и состояния
local TargetFOV = 110
local DefaultFOV = 70
local MaxESPDistance = 250
local MaxActiveHighlights = 22 -- Оптимальный лимит для максимального FPS

local States = {
    Fov = false,
    ["Anti-Fog"] = false,
    ESP = false
}

local ESPConfig = {
    Killer = { Enabled = true, Color = Color3.fromRGB(255, 45, 45) },
    Survivors = { Enabled = true, Color = Color3.fromRGB(50, 220, 100) },
    Pallets = { Enabled = true, Color = Color3.fromRGB(255, 215, 0) },
    Windows = { Enabled = true, Color = Color3.fromRGB(0, 190, 255) },
    Generators = { Enabled = true, Color = Color3.fromRGB(180, 90, 255) },
    BrokenGen = { Enabled = true, Color = Color3.fromRGB(255, 115, 25) },
    Traps = { Enabled = true, Color = Color3.fromRGB(255, 50, 150) },
    Zombies = { Enabled = true, Color = Color3.fromRGB(130, 255, 60) }
}

local OrigLighting = {
    FogEnd = Lighting.FogEnd,
    FogStart = Lighting.FogStart,
    Brightness = Lighting.Brightness,
    ClockTime = Lighting.ClockTime,
    GlobalShadows = Lighting.GlobalShadows,
    OutdoorAmbient = Lighting.OutdoorAmbient
}

-- ==========================================
-- СОЗДАНИЕ МЕНЮ (UI)
-- ==========================================
if CoreGui:FindFirstChild("VD_MiniMenu") then
    CoreGui.VD_MiniMenu:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "VD_MiniMenu"
ScreenGui.Parent = CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 170, 0, 155)
MainFrame.Position = UDim2.new(0.05, 0, 0.3, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 24)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 8)
MainCorner.Parent = MainFrame

local HomePage = Instance.new("Frame")
HomePage.Size = UDim2.new(1, 0, 1, 0)
HomePage.BackgroundTransparency = 1
HomePage.Parent = MainFrame

local FovPage = Instance.new("Frame")
FovPage.Size = UDim2.new(1, 0, 1, 0)
FovPage.BackgroundTransparency = 1
FovPage.Visible = false
FovPage.Parent = MainFrame

local ESPPage = Instance.new("Frame")
ESPPage.Size = UDim2.new(1, 0, 1, 0)
ESPPage.BackgroundTransparency = 1
ESPPage.Visible = false
ESPPage.Parent = MainFrame

local ColorPage = Instance.new("Frame")
ColorPage.Size = UDim2.new(1, 0, 1, 0)
ColorPage.BackgroundTransparency = 1
ColorPage.Visible = false
ColorPage.Parent = MainFrame

local function SwitchPage(targetPage)
    HomePage.Visible = (targetPage == HomePage)
    FovPage.Visible = (targetPage == FovPage)
    ESPPage.Visible = (targetPage == ESPPage)
    ColorPage.Visible = (targetPage == ColorPage)

    if targetPage == ESPPage then
        MainFrame.Size = UDim2.new(0, 170, 0, 352)
    elseif targetPage == ColorPage then
        MainFrame.Size = UDim2.new(0, 170, 0, 225)
    else
        MainFrame.Size = UDim2.new(0, 170, 0, 155)
    end
end

-- ==========================================
-- ГЛАВНАЯ СТРАНИЦА
-- ==========================================
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundTransparency = 1
Title.Text = "Menu [X]"
Title.TextColor3 = Color3.fromRGB(200, 200, 200)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 13
Title.Parent = HomePage

local function CreateMainButton(name, posY, leftCallback, rightCallback)
    local Btn = Instance.new("TextButton")
    Btn.Name = name
    Btn.Size = UDim2.new(0, 146, 0, 30)
    Btn.Position = UDim2.new(0, 12, 0, posY)
    Btn.BackgroundColor3 = Color3.fromRGB(55, 55, 60)
    Btn.TextColor3 = Color3.fromRGB(230, 230, 230)
    Btn.Text = name
    Btn.Font = Enum.Font.GothamSemibold
    Btn.TextSize = 13
    Btn.AutoButtonColor = false
    Btn.Parent = HomePage

    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 6)
    BtnCorner.Parent = Btn

    Btn.MouseButton1Click:Connect(function()
        States[name] = not States[name]
        if States[name] then
            Btn.BackgroundColor3 = Color3.fromRGB(245, 245, 245)
            Btn.TextColor3 = Color3.fromRGB(20, 20, 20)
        else
            Btn.BackgroundColor3 = Color3.fromRGB(55, 55, 60)
            Btn.TextColor3 = Color3.fromRGB(230, 230, 230)
        end
        if leftCallback then leftCallback(States[name]) end
    end)

    Btn.MouseButton2Click:Connect(function()
        if rightCallback then rightCallback() end
    end)
end

-- ==========================================
-- СТРАНИЦА НАСТРОЕК FOV
-- ==========================================
local FovTitle = Instance.new("TextLabel")
FovTitle.Size = UDim2.new(1, 0, 0, 30)
FovTitle.BackgroundTransparency = 1
FovTitle.Text = "FOV Settings"
FovTitle.TextColor3 = Color3.fromRGB(200, 200, 200)
FovTitle.Font = Enum.Font.GothamBold
FovTitle.TextSize = 13
FovTitle.Parent = FovPage

local FovValueLabel = Instance.new("TextLabel")
FovValueLabel.Size = UDim2.new(1, 0, 0, 20)
FovValueLabel.Position = UDim2.new(0, 0, 0, 38)
FovValueLabel.BackgroundTransparency = 1
FovValueLabel.Text = "Value: " .. tostring(TargetFOV)
FovValueLabel.TextColor3 = Color3.fromRGB(245, 245, 245)
FovValueLabel.Font = Enum.Font.GothamSemibold
FovValueLabel.TextSize = 12
FovValueLabel.Parent = FovPage

local SliderBg = Instance.new("TextButton")
SliderBg.Size = UDim2.new(0, 140, 0, 10)
SliderBg.Position = UDim2.new(0, 15, 0, 68)
SliderBg.BackgroundColor3 = Color3.fromRGB(55, 55, 60)
SliderBg.Text = ""
SliderBg.AutoButtonColor = false
SliderBg.Parent = FovPage

local SliderCorner = Instance.new("UICorner")
SliderCorner.CornerRadius = UDim.new(1, 0)
SliderCorner.Parent = SliderBg

local SliderFill = Instance.new("Frame")
SliderFill.Size = UDim2.new((TargetFOV - 70) / (120 - 70), 0, 1, 0)
SliderFill.BackgroundColor3 = Color3.fromRGB(245, 245, 245)
SliderFill.BorderSizePixel = 0
SliderFill.Parent = SliderBg

local FillCorner = Instance.new("UICorner")
FillCorner.CornerRadius = UDim.new(1, 0)
FillCorner.Parent = SliderFill

local draggingFovSlider = false
local minFOV, maxFOV = 70, 120

local function UpdateFovSlider(input)
    local relX = math.clamp((input.Position.X - SliderBg.AbsolutePosition.X) / SliderBg.AbsoluteSize.X, 0, 1)
    SliderFill.Size = UDim2.new(relX, 0, 1, 0)
    TargetFOV = math.floor(minFOV + (maxFOV - minFOV) * relX)
    FovValueLabel.Text = "Value: " .. tostring(TargetFOV)
end

SliderBg.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingFovSlider = true
        MainFrame.Draggable = false
        UpdateFovSlider(input)
    end
end)

local FovBackBtn = Instance.new("TextButton")
FovBackBtn.Size = UDim2.new(0, 146, 0, 28)
FovBackBtn.Position = UDim2.new(0, 12, 0, 113)
FovBackBtn.BackgroundColor3 = Color3.fromRGB(55, 55, 60)
FovBackBtn.TextColor3 = Color3.fromRGB(230, 230, 230)
FovBackBtn.Text = "< Back"
FovBackBtn.Font = Enum.Font.GothamSemibold
FovBackBtn.TextSize = 12
FovBackBtn.AutoButtonColor = false
FovBackBtn.Parent = FovPage

local FovBackCorner = Instance.new("UICorner")
FovBackCorner.CornerRadius = UDim.new(0, 6)
FovBackCorner.Parent = FovBackBtn

FovBackBtn.MouseButton1Click:Connect(function()
    SwitchPage(HomePage)
end)

-- ==========================================
-- СТРАНИЦА ВЫБОРА ЦВЕТА (COLOR WHEEL)
-- ==========================================
local RefreshESP
local ActiveColorKey = nil
local ActiveColorSquare = nil
local CurrentHue, CurrentSat, CurrentVal = 0, 1, 1

local ColorTitle = Instance.new("TextLabel")
ColorTitle.Size = UDim2.new(1, 0, 0, 28)
ColorTitle.BackgroundTransparency = 1
ColorTitle.Text = "Color Picker"
ColorTitle.TextColor3 = Color3.fromRGB(200, 200, 200)
ColorTitle.Font = Enum.Font.GothamBold
ColorTitle.TextSize = 13
ColorTitle.Parent = ColorPage

local WheelImage = Instance.new("ImageButton")
WheelImage.Size = UDim2.new(0, 114, 0, 114)
WheelImage.Position = UDim2.new(0.5, -57, 0, 28)
WheelImage.BackgroundTransparency = 1
WheelImage.Image = "rbxassetid://6020299385"
WheelImage.AutoButtonColor = false
WheelImage.Parent = ColorPage

local WheelCursor = Instance.new("Frame")
WheelCursor.Size = UDim2.new(0, 10, 0, 10)
WheelCursor.Position = UDim2.new(0.5, -5, 0.5, -5)
WheelCursor.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
WheelCursor.BorderSizePixel = 0
WheelCursor.ZIndex = 5
WheelCursor.Parent = WheelImage

local CursorCorner = Instance.new("UICorner")
CursorCorner.CornerRadius = UDim.new(1, 0)
CursorCorner.Parent = WheelCursor

local CursorStroke = Instance.new("UIStroke")
CursorStroke.Color = Color3.fromRGB(15, 15, 15)
CursorStroke.Thickness = 2
CursorStroke.Parent = WheelCursor

local ValSliderBg = Instance.new("TextButton")
ValSliderBg.Size = UDim2.new(0, 146, 0, 12)
ValSliderBg.Position = UDim2.new(0, 12, 0, 154)
ValSliderBg.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
ValSliderBg.Text = ""
ValSliderBg.AutoButtonColor = false
ValSliderBg.Parent = ColorPage

local ValCorner = Instance.new("UICorner")
ValCorner.CornerRadius = UDim.new(1, 0)
ValCorner.Parent = ValSliderBg

local ValGradient = Instance.new("UIGradient")
ValGradient.Color = ColorSequence.new(Color3.fromRGB(0, 0, 0), Color3.fromRGB(255, 255, 255))
ValGradient.Parent = ValSliderBg

local ValKnob = Instance.new("Frame")
ValKnob.Size = UDim2.new(0, 8, 0, 16)
ValKnob.Position = UDim2.new(1, -4, 0.5, -8)
ValKnob.BackgroundColor3 = Color3.fromRGB(245, 245, 245)
ValKnob.BorderSizePixel = 0
ValKnob.Parent = ValSliderBg

local KnobCorner = Instance.new("UICorner")
KnobCorner.CornerRadius = UDim.new(0, 3)
KnobCorner.Parent = ValKnob

local KnobStroke = Instance.new("UIStroke")
KnobStroke.Color = Color3.fromRGB(20, 20, 20)
KnobStroke.Thickness = 1.5
KnobStroke.Parent = ValKnob
local function ApplySelectedHSV()
local finalColor = Color3.fromHSV(CurrentHue, CurrentSat, CurrentVal)
ValGradient.Color = ColorSequence.new(Color3.fromRGB(0, 0, 0), Color3.fromHSV(CurrentHue, CurrentSat, 1))
WheelImage.ImageColor3 = Color3.fromHSV(0, 0, CurrentVal)
if ActiveColorKey and ESPConfig[ActiveColorKey] then
ESPConfig[ActiveColorKey].Color = finalColor
end
if ActiveColorSquare then
ActiveColorSquare.BackgroundColor3 = finalColor
end
if RefreshESP then
RefreshESP()
end
end
local draggingWheel = false
local draggingVal = false
local function UpdateWheelFromInput(input)
local center = WheelImage.AbsolutePosition + (WheelImage.AbsoluteSize / 2)
local radius = WheelImage.AbsoluteSize.X / 2
local delta = Vector2.new(input.Position.X - center.X, input.Position.Y - center.Y)
local dist = math.min(delta.Magnitude, radius)
local angle = math.atan2(delta.Y, delta.X)
local hue = (math.deg(angle) % 360) / 360
CurrentHue = hue
CurrentSat = math.clamp(dist / radius, 0, 1)
local clampedX = math.cos(angle) * dist
local clampedY = math.sin(angle) * dist
WheelCursor.Position = UDim2.new(0.5, clampedX - 5, 0.5, clampedY - 5)
ApplySelectedHSV()
end
local function UpdateValFromInput(input)
local relX = math.clamp((input.Position.X - ValSliderBg.AbsolutePosition.X) / ValSliderBg.AbsoluteSize.X, 0, 1)
CurrentVal = relX
ValKnob.Position = UDim2.new(relX, -4, 0.5, -8)
ApplySelectedHSV()
end
WheelImage.InputBegan:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseButton1 then
draggingWheel = true
MainFrame.Draggable = false
UpdateWheelFromInput(input)
end
end)
ValSliderBg.InputBegan:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseButton1 then
draggingVal = true
MainFrame.Draggable = false
UpdateValFromInput(input)
end
end)
local ColorBackBtn = Instance.new("TextButton")
ColorBackBtn.Size = UDim2.new(0, 146, 0, 26)
ColorBackBtn.Position = UDim2.new(0, 12, 0, 186)
ColorBackBtn.BackgroundColor3 = Color3.fromRGB(55, 55, 60)
ColorBackBtn.TextColor3 = Color3.fromRGB(230, 230, 230)
ColorBackBtn.Text = "< Back"
ColorBackBtn.Font = Enum.Font.GothamSemibold
ColorBackBtn.TextSize = 12
ColorBackBtn.AutoButtonColor = false
ColorBackBtn.Parent = ColorPage
local ColorBackCorner = Instance.new("UICorner")
ColorBackCorner.CornerRadius = UDim.new(0, 6)
ColorBackCorner.Parent = ColorBackBtn
ColorBackBtn.MouseButton1Click:Connect(function()
SwitchPage(ESPPage)
end)
local function OpenColorPicker(key, labelName, squareBtn)
ActiveColorKey = key
ActiveColorSquare = squareBtn
ColorTitle.Text = labelName .. " Color"
local h, s, v = ESPConfig[key].Color:ToHSV()
CurrentHue, CurrentSat, CurrentVal = h, s, v
local radius = 57
local angle = math.rad(h * 360)
local dist = s * radius
WheelCursor.Position = UDim2.new(0.5, math.cos(angle) * dist - 5, 0.5, math.sin(angle) * dist - 5)
ValKnob.Position = UDim2.new(v, -4, 0.5, -8)
ValGradient.Color = ColorSequence.new(Color3.fromRGB(0, 0, 0), Color3.fromHSV(h, s, 1))
WheelImage.ImageColor3 = Color3.fromHSV(0, 0, v)
SwitchPage(ColorPage)
end
-- ==========================================
-- СТРАНИЦА НАСТРОЕК ESP + СЛАЙДЕР ДИСТАНЦИИ
-- ==========================================
local ESPTitle = Instance.new("TextLabel")
ESPTitle.Size = UDim2.new(1, 0, 0, 30)
ESPTitle.BackgroundTransparency = 1
ESPTitle.Text = "ESP Settings"
ESPTitle.TextColor3 = Color3.fromRGB(200, 200, 200)
ESPTitle.Font = Enum.Font.GothamBold
ESPTitle.TextSize = 13
ESPTitle.Parent = ESPPage
local function CreateESPOption(key, labelText, posY)
local cfg = ESPConfig[key]
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, 114, 0, 24)
ToggleBtn.Position = UDim2.new(0, 12, 0, posY)
ToggleBtn.BackgroundColor3 = cfg.Enabled and Color3.fromRGB(245, 245, 245) or Color3.fromRGB(55, 55, 60)
ToggleBtn.TextColor3 = cfg.Enabled and Color3.fromRGB(20, 20, 20) or Color3.fromRGB(230, 230, 230)
ToggleBtn.Text = labelText
ToggleBtn.Font = Enum.Font.GothamSemibold
ToggleBtn.TextSize = 12
ToggleBtn.AutoButtonColor = false
ToggleBtn.Parent = ESPPage
local TCorner = Instance.new("UICorner")
TCorner.CornerRadius = UDim.new(0, 5)
TCorner.Parent = ToggleBtn
ToggleBtn.MouseButton1Click:Connect(function()
cfg.Enabled = not cfg.Enabled
if cfg.Enabled then
ToggleBtn.BackgroundColor3 = Color3.fromRGB(245, 245, 245)
ToggleBtn.TextColor3 = Color3.fromRGB(20, 20, 20)
else
ToggleBtn.BackgroundColor3 = Color3.fromRGB(55, 55, 60)
ToggleBtn.TextColor3 = Color3.fromRGB(230, 230, 230)
end
if RefreshESP then RefreshESP() end
end)
local ColorBtn = Instance.new("TextButton")
ColorBtn.Size = UDim2.new(0, 26, 0, 24)
ColorBtn.Position = UDim2.new(0, 132, 0, posY)
ColorBtn.BackgroundColor3 = cfg.Color
ColorBtn.Text = ""
ColorBtn.AutoButtonColor = false
ColorBtn.Parent = ESPPage
local CCorner = Instance.new("UICorner")
CCorner.CornerRadius = UDim.new(0, 5)
CCorner.Parent = ColorBtn
ColorBtn.MouseButton1Click:Connect(function()
OpenColorPicker(key, labelText, ColorBtn)
end)
end
CreateESPOption("Killer", "Killer", 34)
CreateESPOption("Survivors", "Survivors", 63)
CreateESPOption("Pallets", "Pallets", 92)
CreateESPOption("Windows", "Windows", 121)
CreateESPOption("Generators", "Generators", 150)
CreateESPOption("BrokenGen", "Broken Gen", 179)
CreateESPOption("Traps", "Traps", 208)
CreateESPOption("Zombies", "Zombies", 237)
local DistLabel = Instance.new("TextLabel")
DistLabel.Size = UDim2.new(1, 0, 0, 16)
DistLabel.Position = UDim2.new(0, 0, 0, 267)
DistLabel.BackgroundTransparency = 1
DistLabel.Text = "Object Dist: " .. tostring(MaxESPDistance)
DistLabel.TextColor3 = Color3.fromRGB(215, 215, 215)
DistLabel.Font = Enum.Font.GothamSemibold
DistLabel.TextSize = 11
DistLabel.Parent = ESPPage
local DistSliderBg = Instance.new("TextButton")
DistSliderBg.Size = UDim2.new(0, 146, 0, 8)
DistSliderBg.Position = UDim2.new(0, 12, 0, 287)
DistSliderBg.BackgroundColor3 = Color3.fromRGB(55, 55, 60)
DistSliderBg.Text = ""
DistSliderBg.AutoButtonColor = false
DistSliderBg.Parent = ESPPage
local DistSliderCorner = Instance.new("UICorner")
DistSliderCorner.CornerRadius = UDim.new(1, 0)
DistSliderCorner.Parent = DistSliderBg
local minDist, maxDist = 50, 1000
local DistSliderFill = Instance.new("Frame")
DistSliderFill.Size = UDim2.new((MaxESPDistance - minDist) / (maxDist - minDist), 0, 1, 0)
DistSliderFill.BackgroundColor3 = Color3.fromRGB(245, 245, 245)
DistSliderFill.BorderSizePixel = 0
DistSliderFill.Parent = DistSliderBg
local DistFillCorner = Instance.new("UICorner")
DistFillCorner.CornerRadius = UDim.new(1, 0)
DistFillCorner.Parent = DistSliderFill
local draggingDistSlider = false
local function UpdateDistSlider(input)
local relX = math.clamp((input.Position.X - DistSliderBg.AbsolutePosition.X) / DistSliderBg.AbsoluteSize.X, 0, 1)
DistSliderFill.Size = UDim2.new(relX, 0, 1, 0)
MaxESPDistance = math.floor(minDist + (maxDist - minDist) * relX)
DistLabel.Text = "Object Dist: " .. tostring(MaxESPDistance)
if RefreshESP then RefreshESP() end
end
DistSliderBg.InputBegan:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseButton1 then
draggingDistSlider = true
MainFrame.Draggable = false
UpdateDistSlider(input)
end
end)
UserInputService.InputEnded:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseButton1 then
if draggingFovSlider or draggingWheel or draggingVal or draggingDistSlider then
draggingFovSlider = false
draggingWheel = false
draggingVal = false
draggingDistSlider = false
MainFrame.Draggable = true
end
end
end)
UserInputService.InputChanged:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseMovement then
if draggingFovSlider then
UpdateFovSlider(input)
elseif draggingWheel then
UpdateWheelFromInput(input)
elseif draggingVal then
UpdateValFromInput(input)
elseif draggingDistSlider then
UpdateDistSlider(input)
end
end
end)
local ESPBackBtn = Instance.new("TextButton")
ESPBackBtn.Size = UDim2.new(0, 146, 0, 26)
ESPBackBtn.Position = UDim2.new(0, 12, 0, 311)
ESPBackBtn.BackgroundColor3 = Color3.fromRGB(55, 55, 60)
ESPBackBtn.TextColor3 = Color3.fromRGB(230, 230, 230)
ESPBackBtn.Text = "< Back"
ESPBackBtn.Font = Enum.Font.GothamSemibold
ESPBackBtn.TextSize = 12
ESPBackBtn.AutoButtonColor = false
ESPBackBtn.Parent = ESPPage
local ESPBackCorner = Instance.new("UICorner")
ESPBackCorner.CornerRadius = UDim.new(0, 6)
ESPBackCorner.Parent = ESPBackBtn
ESPBackBtn.MouseButton1Click:Connect(function()
SwitchPage(HomePage)
end)
-- ==========================================
-- УЛЬТРА-ОПТИМИЗИРОВАННАЯ ЛОГИКА ESP (СОБЫТИЙНАЯ)
-- ==========================================
local CachedMapObjects = {}
local function IsInLobby(obj)
local current = obj
while current and current ~= workspace do
local n = string.lower(current.Name)
if string.find(n, "lobby") or string.find(n, "spawn") or string.find(n, "menu") then
return true
end
current = current.Parent
end
return false
end
local function IsInteractableVault(obj)
local checkTarget = (obj:IsA("BasePart") and obj.Parent and obj.Parent ~= workspace) and obj.Parent or obj
for _, desc in ipairs(checkTarget:GetDescendants()) do
if desc:IsA("ProximityPrompt") or desc:IsA("ClickDetector") then
return true
end
local dName = string.lower(desc.Name)
if string.find(dName, "vault") or string.find(dName, "prompt") or string.find(dName, "interact") then
return true
end
end
return false
end
-- Мгновенное получение позиции без тяжелых вычислений
local function FastGetPosition(target, cachedRoot)
if cachedRoot and cachedRoot.Parent then
return cachedRoot.Position
end
if target:IsA("BasePart") then
return target.Position
elseif target:IsA("Model") then
if target.PrimaryPart then
return target.PrimaryPart.Position
end
local part = target:FindFirstChildWhichIsA("BasePart", true)
if part then
return part.Position
end
end
return nil
end
local function ClassifyObject(obj)
if Players:GetPlayerFromCharacter(obj) or Players:GetPlayerFromCharacter(obj.Parent) then
return nil
end
if IsInLobby(obj) then
return nil
end
local name = string.lower(obj.Name)
if obj:IsA("Model") and obj:FindFirstChildOfClass("Humanoid") then
return "Zombies"
elseif string.find(name, "zombie") or string.find(name, "plague") or string.find(name, "minion") or string.find(name, "infected") then
return "Zombies"
elseif string.find(name, "trap") or string.find(name, "snare") or string.find(name, "kapkan") then
return "Traps"
elseif string.find(name, "pallet") then
return "Pallets"
elseif string.find(name, "vault") or (string.find(name, "window") and IsInteractableVault(obj)) then
return "Windows"
elseif string.find(name, "generator") or name == "gen" or string.find(name, "gen_") or string.find(name, "gen1") or string.find(name, "gen2") then
return "Generators"
end
return nil
end
-- Вычисление статуса генератора только при изменении его свойств (0 нагрузки в цикле!)
local function EvaluateGeneratorState(target)
local attrs = target:GetAttributes()
for k, v in pairs(attrs) do
local key = string.lower(tostring(k))
if (string.find(key, "complet") or string.find(key, "finish") or string.find(key, "repaired") or string.find(key, "done")) and v == true then
return "Completed"
end
if (string.find(key, "progress") or string.find(key, "percent")) and type(v) == "number" and v >= 100 then
return "Completed"
end
if (string.find(key, "broken") or string.find(key, "damag") or string.find(key, "regress")) and v == true then
return "BrokenGen"
end
end
local hasPrompt = false
local anyPromptEnabled = false
for _, desc in ipairs(target:GetDescendants()) do
if desc:IsA("ProximityPrompt") then
hasPrompt = true
if desc.Enabled then anyPromptEnabled = true end
elseif desc:IsA("BoolValue") then
local n = string.lower(desc.Name)
if (string.find(n, "complet") or string.find(n, "finish") or string.find(n, "repaired") or string.find(n, "done")) and desc.Value == true then
return "Completed"
end
if (string.find(n, "broken") or string.find(n, "damag") or string.find(n, "regress")) and desc.Value == true then
return "BrokenGen"
end
elseif desc:IsA("NumberValue") or desc:IsA("IntValue") then
local n = string.lower(desc.Name)
if (string.find(n, "progress") or string.find(n, "percent")) and desc.Value >= 100 then
return "Completed"
end
elseif desc:IsA("StringValue") then
local val = string.lower(desc.Value)
if string.find(val, "complet") or string.find(val, "repaired") or string.find(val, "done") then
return "Completed"
end
if string.find(val, "broken") or string.find(val, "damag") or string.find(val, "regress") then
return "BrokenGen"
end
elseif desc:IsA("ParticleEmitter") or desc:IsA("Sparkles") or desc:IsA("Fire") then
local n = string.lower(desc.Name)
if desc.Enabled and (string.find(n, "spark") or string.find(n, "break") or string.find(n, "damag") or string.find(n, "regress")) then
return "BrokenGen"
end
end
end
if hasPrompt and not anyPromptEnabled then
return "Completed"
end
return "Generators"
end
-- Привязываем легкие слушатели изменений к генератору
local function BindGeneratorListeners(target, data)
local function updateState()
if target and target.Parent then
data.GenState = EvaluateGeneratorState(target)
end
end
target.AttributeChanged:Connect(updateState)
for _, desc in ipairs(target:GetDescendants()) do
if desc:IsA("ValueBase") then
desc.Changed:Connect(updateState)
elseif desc:IsA("ProximityPrompt") or desc:IsA("ParticleEmitter") or desc:IsA("Sparkles") or desc:IsA("Fire") then
desc:GetPropertyChangedSignal("Enabled"):Connect(updateState)
end
end
updateState()
end
local function RegisterMapObject(obj)
if not (obj:IsA("Model") or obj:IsA("BasePart")) then return end
local category = ClassifyObject(obj)
if not category then return end
local target = (obj:IsA("BasePart") and obj.Parent:IsA("Model") and obj.Parent ~= workspace) and obj.Parent or obj
if CachedMapObjects[target] then return end
if Players:GetPlayerFromCharacter(target) then return end
local rootPart = target:IsA("BasePart") and target or (target.PrimaryPart or target:FindFirstChild("HumanoidRootPart") or target:FindFirstChildWhichIsA("BasePart", true))
if not rootPart then return end
if target:IsA("Model") then
local ok, _, size = pcall(function() return target:GetBoundingBox() end)
if not (ok and size and size.X < 40 and size.Y < 40 and size.Z < 40) then
return
end
end
local isDynamic = (category == "Zombies" or category == "Traps")
local entry = {
Category = category,
Position = rootPart.Position,
RootPart = rootPart,
Dynamic = isDynamic,
GenState = "Generators",
Humanoid = isDynamic and target:FindFirstChildOfClass("Humanoid") or nil
}
CachedMapObjects[target] = entry
if category == "Generators" then
BindGeneratorListeners(target, entry)
end
end
local function ScanMap()
for target, _ in pairs(CachedMapObjects) do
if not target or not target.Parent then
CachedMapObjects[target] = nil
end
end
local descendants = workspace:GetDescendants()
for i = 1, #descendants do
local item = descendants[i]
if item:IsA("Model") or item:IsA("BasePart") then
RegisterMapObject(item)
end
if i % 1000 == 0 then
task.wait()
end
end
end
-- Мгновенный отсев мусора (частиц, звуков и т.д.) при добавлении объектов на карту
workspace.DescendantAdded:Connect(function(obj)
if not States.ESP then return end
if not (obj:IsA("Model") or obj:IsA("BasePart")) then return end
task.defer(function()
if obj and obj.Parent then
RegisterMapObject(obj)
end
end)
end)
local function SetHighlightState(target, enabled, color)
if not target or not target.Parent then return end
local hl = target:FindFirstChild("VD_Highlight")
if enabled then
if not hl then
hl = Instance.new("Highlight")
hl.Name = "VD_Highlight"
hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
hl.FillTransparency = 0.65
hl.OutlineTransparency = 0
hl.FillColor = color
hl.OutlineColor = color
hl.Enabled = true
hl.Parent = target
else
if not hl.Enabled then hl.Enabled = true end
if hl.FillColor ~= color then
hl.FillColor = color
hl.OutlineColor = color
end
end
else
if hl and hl.Enabled then
hl.Enabled = false
end
end
end
local function DisableAllHighlights()
for _, player in ipairs(Players:GetPlayers()) do
if player.Character then
local hl = player.Character:FindFirstChild("VD_Highlight")
if hl then hl.Enabled = false end
end
end
for target, _ in pairs(CachedMapObjects) do
if target and target.Parent then
local hl = target:FindFirstChild("VD_Highlight")
if hl then hl.Enabled = false end
end
end
end
local candidates = {} -- Переиспользуем таблицу, чтобы не нагружать сборщик мусора
RefreshESP = function()
if not States.ESP then
DisableAllHighlights()
return
end
local activeCount = 0
-- 1. Игроки
for _, player in ipairs(Players:GetPlayers()) do
if player ~= LocalPlayer and player.Character then
local teamName = player.Team and string.lower(player.Team.Name) or ""
local isKiller = string.find(teamName, "killer") ~= nil
local cfg = isKiller and ESPConfig.Killer or ESPConfig.Survivors
if cfg.Enabled and activeCount < MaxActiveHighlights then
SetHighlightState(player.Character, true, cfg.Color)
activeCount = activeCount + 1
else
SetHighlightState(player.Character, false, cfg.Color)
end
end
end
-- 2. Объекты карты (без вызова GetDescendants в цикле)
local originPos = nil
local char = LocalPlayer.Character
if char and char:FindFirstChild("HumanoidRootPart") then
originPos = char.HumanoidRootPart.Position
elseif Camera then
originPos = Camera.CFrame.Position
end
table.clear(candidates)
for target, data in pairs(CachedMapObjects) do
if target and target.Parent then
local activeCategory = (data.Category == "Generators") and data.GenState or data.Category
local isDeadZombie = (activeCategory == "Zombies" and data.Humanoid and data.Humanoid.Health <= 0)
if activeCategory == "Completed" or isDeadZombie then
SetHighlightState(target, false, Color3.new(1, 1, 1))
else
local cfg = ESPConfig[activeCategory]
if cfg and cfg.Enabled then
local currentPos = data.Position
if data.Dynamic then
local newPos = FastGetPosition(target, data.RootPart)
if newPos then
currentPos = newPos
data.Position = newPos
end
end
local dist = (originPos and currentPos) and (originPos - currentPos).Magnitude or 0
if dist <= MaxESPDistance then
candidates[#candidates + 1] = {
Target = target,
Distance = dist,
Color = cfg.Color
}
else
SetHighlightState(target, false, cfg.Color)
end
else
SetHighlightState(target, false, Color3.new(1, 1, 1))
end
end
else
CachedMapObjects[target] = nil
end
end
table.sort(candidates, function(a, b)
return a.Distance < b.Distance
end)
for i = 1, #candidates do
local item = candidates[i]
if activeCount < MaxActiveHighlights then
SetHighlightState(item.Target, true, item.Color)
activeCount = activeCount + 1
else
SetHighlightState(item.Target, false, item.Color)
end
end
end
-- Оптимальный цикл обновления (раз в 0.5 сек)
task.spawn(function()
while task.wait(0.5) do
if States.ESP then
RefreshESP()
end
end
end)
-- ==========================================
-- ПРИВЯЗКА ГЛАВНЫХ КНОПОК И УПРАВЛЕНИЯ
-- ==========================================
CreateMainButton("Fov", 35, function(enabled)
if not enabled and Camera then
Camera.FieldOfView = DefaultFOV
end
end, function()
SwitchPage(FovPage)
end)
RunService.RenderStepped:Connect(function()
if States.Fov and Camera then
Camera.FieldOfView = TargetFOV
end
end)
local function ApplyAntiFog()
if States["Anti-Fog"] then
Lighting.FogEnd = 999999
Lighting.FogStart = 999999
Lighting.Brightness = 2
Lighting.ClockTime = 14
Lighting.GlobalShadows = false
Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
for _, obj in pairs(Lighting:GetChildren()) do
if obj:IsA("Atmosphere") then
obj:Destroy()
end
end
end
end
CreateMainButton("Anti-Fog", 73, function(enabled)
if enabled then
ApplyAntiFog()
else
Lighting.FogEnd = OrigLighting.FogEnd
Lighting.FogStart = OrigLighting.FogStart
Lighting.Brightness = OrigLighting.Brightness
Lighting.ClockTime = OrigLighting.ClockTime
Lighting.GlobalShadows = OrigLighting.GlobalShadows
Lighting.OutdoorAmbient = OrigLighting.OutdoorAmbient
end
end)
Lighting.Changed:Connect(function()
if States["Anti-Fog"] then
ApplyAntiFog()
end
end)
CreateMainButton("ESP", 111, function(enabled)
if enabled then
task.spawn(function()
ScanMap()
RefreshESP()
end)
else
DisableAllHighlights()
end
end, function()
SwitchPage(ESPPage)
end)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
if not gameProcessed and input.KeyCode == Enum.KeyCode.X then
MainFrame.Visible = not MainFrame.Visible
end
end)
