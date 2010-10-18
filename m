Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 88BB76B00DA
	for <linux-mm@kvack.org>; Mon, 18 Oct 2010 17:33:53 -0400 (EDT)
Message-ID: <20101018213348.10281.qmail@kosh.dhis.org>
From: pacman@kosh.dhis.org
Subject: Re: PROBLEM: memory corrupting bug, bisected to 6dda9d55
Date: Mon, 18 Oct 2010 16:33:48 -0500 (GMT+5)
In-Reply-To: <1287436205.2341.14.camel@pasglop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Benjamin Herrenschmidt writes:
> 
> You can do something fun... like a timer interrupt that peeks at those
> physical addresses from the linear mapping for example, and try to find
> out "when" they get set to the wrong value (you should observe the load
> from disk, then the corruption, unless they end up being loaded
> incorrectly (ie. dma coherency problem ?) ...

I'm headed toward something like that. Maybe not a timer, maybe a "check it
every time the kernel is entered". But first I have to work out exactly when
the disk load completes so I know when to start checking.

> 
> >From there, you might be able to close onto the culprit a bit more, for
> example, try using the DABR register to set data access breakpoints
> shortly before the corruption spot. AFAIK, On those old 32-bit CPUs, you
> can set whether you want it to break on a real or a virtual address.

I thought of that, but as far as I can tell, this CPU doesn't have DABR.
/proc/cpuinfo
processor	: 0
cpu		: 7447/7457
clock		: 999.999990MHz
revision	: 1.1 (pvr 8002 0101)
bogomips	: 66.66
timebase	: 33333333
platform	: CHRP
model		: Pegasos2
machine		: CHRP Pegasos2
Memory		: 512 MB

My next thought was: right after the correct value appears in memory, unmap
the page from the kernel and let it Oops when it tries to write there. Then I
found out that the kernel is using BATs instead of page tables for its own
view of memory. Booting with "nobats" completely changes the memory usage
pattern (probably because it's allocating a lot of pages to hold PTEs that it
didn't need before)

> 
> You can also sprinkle tests for the page content through the code if
> that doesn't work to try to "close in" on the culprit (for example if
> it's a case of stray DMA, like a network driver bug or such).

No network drivers are loaded when this happens.

-- 
Alan Curry

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
