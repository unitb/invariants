{-# LANGUAGE CPP #-}
module GHC.Stack.Utils
    ( module GHC.Stack.Utils
    , module GHC.Stack )
where

import Data.Maybe

import GHC.Stack

#if !(MIN_VERSION_base(4,9,0))
import GHC.SrcLoc
#endif


import Text.Printf

stackTrace' :: [FilePath] -> CallStack -> String -> String
stackTrace' fs stack str = fromMaybe str $ stackTrace fs stack

getSrcLocs :: [FilePath] -> CallStack -> [(String,SrcLoc)]
getSrcLocs fs cs = filter notHere $ getCallStack cs
    where
        notHere :: (a,SrcLoc) -> Bool
        notHere (_,x) = srcLocFile x `notElem` __FILE__:fs

stackTrace :: [FilePath] -> CallStack -> Maybe String
stackTrace fs cs | null loc  = Nothing
                 | otherwise = Just $ '\n':concatMap f (reverse loc)
    where
        loc = getSrcLocs fs cs
        f (fn,loc) = printf "%s - %s\n" (locToString loc) fn

locToString :: SrcLoc -> String
locToString loc = printf "%s:%d:%d" 
            (srcLocFile loc) 
            (srcLocStartLine loc)
            (srcLocStartCol loc)
