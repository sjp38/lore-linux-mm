Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 092ED6B0071
	for <linux-mm@kvack.org>; Tue, 19 Oct 2010 06:17:27 -0400 (EDT)
Subject: Re: PROBLEM: memory corrupting bug, bisected to 6dda9d55
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <20101018213348.10281.qmail@kosh.dhis.org>
References: <20101018213348.10281.qmail@kosh.dhis.org>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 19 Oct 2010 21:16:50 +1100
Message-ID: <1287483410.2341.66.camel@pasglop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: pacman@kosh.dhis.org
Cc: Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>


> > >From there, you might be able to close onto the culprit a bit more, for
> > example, try using the DABR register to set data access breakpoints
> > shortly before the corruption spot. AFAIK, On those old 32-bit CPUs, you
> > can set whether you want it to break on a real or a virtual address.
> 
> I thought of that, but as far as I can tell, this CPU doesn't have DABR.
> /proc/cpuinfo
> processor	: 0
> cpu		: 7447/7457
> clock		: 999.999990MHz
> revision	: 1.1 (pvr 8002 0101)
> bogomips	: 66.66
> timebase	: 33333333
> platform	: CHRP
> model		: Pegasos2
> machine		: CHRP Pegasos2
> Memory		: 512 MB

AFAIK, the 7447 is just a derivative of the 7450 design which -does-
have a DABR ... Unless it's broken :-)

> My next thought was: right after the correct value appears in memory, unmap
> the page from the kernel and let it Oops when it tries to write there. Then I
> found out that the kernel is using BATs instead of page tables for its own
> view of memory. Booting with "nobats" completely changes the memory usage
> pattern (probably because it's allocating a lot of pages to hold PTEs that it
> didn't need before)

Right. And that hides the problem I suppose ?

> > You can also sprinkle tests for the page content through the code if
> > that doesn't work to try to "close in" on the culprit (for example if
> > it's a case of stray DMA, like a network driver bug or such).
> 
> No network drivers are loaded when this happens.

Ok.

Cheers,
Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
