import XMonad
import System.Exit
import XMonad.Util.EZConfig
import XMonad.Util.SpawnOnce
import XMonad.Util.Loggers
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.StatusBar
import XMonad.Hooks.StatusBar.PP

main :: IO ()
main = xmonad
 . ewmhFullscreen
 . ewmh
 . withEasySB (statusBarProp "xmobar" (pure myXmobarPP)) defToggleStrutsKey
 $ myConf

myTerminal = "alacritty"

myNormalBorderColor = "#1d1f21"
myFocusedBorderColor = "#d5d5d5"

myWorkspaces = ["1", "2", "3", "4", "5", "6", "7", "8", "9"]

myManageHook :: ManageHook
myManageHook = composeAll
       [ className =? "alacritty" --> doShift "1"
       , className =? "firefox"   --> doShift "2"
       , className =? "librewolf" --> doShift "3"
       , className =? "vmware"    --> doShift "5"
       , isDialog                 --> doFloat
       ]

myKeys =
       -- Spawn Apps
       [ ("M-<Return>", spawn myTerminal)
       , ("M-d",        spawn "rofi -show drun -theme ~/.config/rofi/config.rasi")
       , ("M-S-x",      spawn "xsecurelock")
       -- Kill Windows
       , ("M-q",        kill)
       -- Volume Controls
       , ("<F8>", spawn "wpctl set-volume @DEFAULT_SINK@ 5%+")
       , ("<F7>", spawn "wpctl set-volume @DEFAULT_SINK@ 5%-")
       , ("<F6>", spawn "wpctl set-mute   @DEFAULT_SINK@ toggle")
       -- Quit/Recompile
       , ("M-S-r", spawn "xmonad --recompile && xmonad --restart")
       , ("M-S-q", io exitSuccess)
       ]
myConf =
    def
       { modMask = mod4Mask
       , terminal = myTerminal
       , normalBorderColor = myNormalBorderColor
       , focusedBorderColor = myFocusedBorderColor
       , startupHook = spawnOnce "xsetroot -cursor_name left_ptr"
       , manageHook = myManageHook
       , workspaces = myWorkspaces
       }
       `additionalKeysP` myKeys

myXmobarPP :: PP
myXmobarPP =
    def
       { ppSep             = " | "
       , ppTitleSanitize   = xmobarStrip
       , ppCurrent         = wrap "[" "]"
       , ppHidden          = white . wrap " " ""
       , ppUrgent          = red . wrap (yellow "!") (yellow "!")
       , ppOrder           = \[ws, l, _, wins] -> [ws, l, wins]
       , ppExtras          = [logTitles formatFocused formatUnfocused]
       }
    where
       formatFocused   = wrap (white    "[") (white    "]") . white    . ppWindow
       formatUnfocused = wrap (dimWhite "[") (dimWhite "]") . dimWhite . ppWindow

       ppWindow :: String -> String
       ppWindow = xmobarRaw . (\w -> if null w then "N/A" else w) . shorten 30

       red, yellow, white, dimWhite :: String -> String
       red      = xmobarColor "#e92929" ""
       yellow   = xmobarColor "#dfd73c" ""
       white    = xmobarColor "#ffffff" ""
       dimWhite = xmobarColor "#bbbbbb" ""
