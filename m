Date: Sat, 18 Dec 2004 08:31:00 +0100
From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH 10/10] alternate 4-level page tables patches
Message-ID: <20041218073100.GA338@wotan.suse.de>
References: <41C3D479.40708@yahoo.com.au> <41C3D48F.8080006@yahoo.com.au> <41C3D4AE.7010502@yahoo.com.au> <41C3D4C8.1000508@yahoo.com.au> <41C3D4F9.9040803@yahoo.com.au> <41C3D516.9060306@yahoo.com.au> <41C3D548.6080209@yahoo.com.au> <41C3D57C.5020005@yahoo.com.au> <41C3D594.4020108@yahoo.com.au> <41C3D5B1.3040200@yahoo.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <41C3D5B1.3040200@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Linux Memory Management <linux-mm@kvack.org>, Andi Kleen <ak@suse.de>, Hugh Dickins <hugh@veritas.com>, Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

On Sat, Dec 18, 2004 at 06:01:05PM +1100, Nick Piggin wrote:
> 10/10

> 
> 
> Convert some pagetable walking functions over to be inline where
> they are only used once. This is worth a percent or so on lmbench
> fork.

Any modern gcc (3.4+ or 3.3-hammer) should use unit-at-a-time anyways,
which automatically inlines all static functions that are only used once.

I like it because during debugging you can turn it off and it makes
it much easier to read oopses when not everything is inlined.  And 
when turned on it generates much smaller and faster as you've shown
code.

Ok except on i386 where someone decided to explicitely turn it off 
all the time :/

I've been reenabling it on the suse kernel for a long time because
it doesn't seem to have any bad side effects and makes the code
considerably smaller.  It would be better to just turn it on in mainline 
again, then you'll see much more gain everywhere.

BTW we can do much better with all the page table walking by
adding some bitmaps about used ptes to struct page and skipping
holes quickly. DaveM has a patch for that in the queue, I hope a patch 
similar to his can be added once 4level page tables are in.

-Andi

Here's the patch: 

Enable unit-at-a-time by default. At least with 3.3-hammer and 3.4 
it seems to work just fine. Has been tested with 3.3-hammer over
several suse releases.

Signed-off-by: Andi Kleen <ak@suse.de>

diff -u linux-2.6.10rc2-time/arch/i386/Makefile-o linux-2.6.10rc2-time/arch/i386/Makefile
--- linux-2.6.10rc2-time/arch/i386/Makefile-o	2004-11-15 12:34:25.000000000 +0100
+++ linux-2.6.10rc2-time/arch/i386/Makefile	2004-12-18 08:27:14.000000000 +0100
@@ -57,9 +57,8 @@
 GCC_VERSION			:= $(call cc-version)
 cflags-$(CONFIG_REGPARM) 	+= $(shell if [ $(GCC_VERSION) -ge 0300 ] ; then echo "-mregparm=3"; fi ;)
 
-# Disable unit-at-a-time mode, it makes gcc use a lot more stack
-# due to the lack of sharing of stacklots.
-CFLAGS += $(call cc-option,-fno-unit-at-a-time)
+# Enable unit-at-a-time mode. It generates considerably smaller code.
+CFLAGS += $(call cc-option,-funit-at-a-time)
 
 CFLAGS += $(cflags-y)
 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
