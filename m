Message-ID: <41C71045.1020304@osdl.org>
Date: Mon, 20 Dec 2004 09:47:49 -0800
From: "Randy.Dunlap" <rddunlap@osdl.org>
MIME-Version: 1.0
Subject: Re: [PATCH 10/10] alternate 4-level page tables patches
References: <41C3D4AE.7010502@yahoo.com.au> <41C3D4C8.1000508@yahoo.com.au> <41C3D4F9.9040803@yahoo.com.au> <41C3D516.9060306@yahoo.com.au> <41C3D548.6080209@yahoo.com.au> <41C3D57C.5020005@yahoo.com.au> <41C3D594.4020108@yahoo.com.au> <41C3D5B1.3040200@yahoo.com.au> <20041218073100.GA338@wotan.suse.de> <Pine.LNX.4.58.0412181102070.22750@ppc970.osdl.org> <20041220174357.GB4316@wotan.suse.de>
In-Reply-To: <20041220174357.GB4316@wotan.suse.de>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Linus Torvalds <torvalds@osdl.org>, Nick Piggin <nickpiggin@yahoo.com.au>, Linux Memory Management <linux-mm@kvack.org>, Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

Andi Kleen wrote:
> On Sat, Dec 18, 2004 at 11:06:48AM -0800, Linus Torvalds wrote:
> 
>>
>>On Sat, 18 Dec 2004, Andi Kleen wrote:
>>
>>>Ok except on i386 where someone decided to explicitely turn it off 
>>>all the time :/
>>
>>Because it used to be broken as hell. The code it generated was absolute 
>>and utter crap.
> 
> 
> I disagree. It generated significantly smaller code and the SUSE 
> kernel has been shipping with it for several releases and I'm not
> aware of any bug report related to unit-at-a-time.
> 
> 
>>Maybe some versions of gcc get it right now, but what it _used_ to do was 
>>to make functions that had hundreds of bytes of stack-space, because gcc 
>>would never re-use stack slots, and if you have code like
> 
> 
> The right fix in that case would have been to add a few "noinline"s
> to these cases (should be easy to check for if it really happens 
> by grepping assembly code for large stack frames), not penalize code quality
> of the whole kernel.
> 
> I did a grep over a gcc 4.0-snapshot compiled i386 kernel.  There
> are a few really bad cases (e.g. GDTH, intelfb, some WAN stuff)
> that should be fixed, but from a quick review they all just put a single big
> object on the stack, and are not affected by unit-at-a-time.
> 
> [note names are after the occurrence, not before]
> 
> everything > 0x400
> 
>      808:       81 ec 58 09 00 00       sub    $0x958,%esp
> ./drivers/video/intelfb/intelfb.o
>      808:       81 ec 58 09 00 00       sub    $0x958,%esp
> ./drivers/video/intelfb/intelfbdrv.o
>      3b4:       81 ec 08 04 00 00       sub    $0x408,%esp
> ./drivers/net/wan/cyclomx.o
>       e8:       81 ec 08 04 00 00       sub    $0x408,%esp
> ./drivers/net/wan/cycx_x25.o
>     4d82:       81 ec 44 06 00 00       sub    $0x644,%esp
>     184b:       81 ec 48 02 00 00       sub    $0x248,%esp
> ./drivers/scsi/gdth.o
> 
> More smaller ones.

I posted a patch for intelfbdrv yesterday (on linux-fbdev-devel
m-l) and I'm working on gdth stack usage right now.
Basically I'm just tackling the top offenders (> 1000 bytes).

-- 
~Randy
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
