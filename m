Date: Sat, 18 Dec 2004 11:06:48 -0800 (PST)
From: Linus Torvalds <torvalds@osdl.org>
Subject: Re: [PATCH 10/10] alternate 4-level page tables patches
In-Reply-To: <20041218073100.GA338@wotan.suse.de>
Message-ID: <Pine.LNX.4.58.0412181102070.22750@ppc970.osdl.org>
References: <41C3D479.40708@yahoo.com.au> <41C3D48F.8080006@yahoo.com.au>
 <41C3D4AE.7010502@yahoo.com.au> <41C3D4C8.1000508@yahoo.com.au>
 <41C3D4F9.9040803@yahoo.com.au> <41C3D516.9060306@yahoo.com.au>
 <41C3D548.6080209@yahoo.com.au> <41C3D57C.5020005@yahoo.com.au>
 <41C3D594.4020108@yahoo.com.au> <41C3D5B1.3040200@yahoo.com.au>
 <20041218073100.GA338@wotan.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Linux Memory Management <linux-mm@kvack.org>, Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>


On Sat, 18 Dec 2004, Andi Kleen wrote:
> 
> Ok except on i386 where someone decided to explicitely turn it off 
> all the time :/

Because it used to be broken as hell. The code it generated was absolute 
and utter crap.

Maybe some versions of gcc get it right now, but what it _used_ to do was 
to make functions that had hundreds of bytes of stack-space, because gcc 
would never re-use stack slots, and if you have code like

	static int fn_case1(..)
	..

	static int fn_case2(..)
	..

	switch (ioctl) {
	case abc:
		err = fn_case1(..);
		break;
	case def:
		err = fn_case2(..)
		break;
	..
	case xyz:
		err = fn_case25(..);
		break;
	}

which actually is not that unusual, gcc would make a TOTAL mess of it, 
because it would add up _all_ the stack space for _all_ the functions, and 
instead of having 16 bytes of stack used, it would use a kilobyte.

It may be less of an issue on x86-64, because
 - you probably haven't even looked
 - with more registers, you need less spilling, and inlining works better.

> Enable unit-at-a-time by default. At least with 3.3-hammer and 3.4 
> it seems to work just fine. Has been tested with 3.3-hammer over
> several suse releases.

How about looking at those ioctl functions, and verifying that gcc has 
been fixed? With more than just _one_ boutique compiler version?

		Linus
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
