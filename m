Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id C07336B007E
	for <linux-mm@kvack.org>; Tue, 12 Jul 2011 09:39:55 -0400 (EDT)
From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 6/8] drivers: add Contiguous Memory Allocator
Date: Tue, 12 Jul 2011 15:39:31 +0200
References: <1309851710-3828-1-git-send-email-m.szyprowski@samsung.com> <201107051558.39344.arnd@arndb.de> <20110708172541.GM4812@n2100.arm.linux.org.uk>
In-Reply-To: <20110708172541.GM4812@n2100.arm.linux.org.uk>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <201107121539.31548.arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Cc: linux-arm-kernel@lists.infradead.org, Daniel Walker <dwalker@codeaurora.org>, Jonathan Corbet <corbet@lwn.net>, Mel Gorman <mel@csn.ul.ie>, Chunsang Jeong <chunsang.jeong@linaro.org>, Jesse Barker <jesse.barker@linaro.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, Michal Nazarewicz <mina86@mina86.com>, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, Kyungmin Park <kyungmin.park@samsung.com>, Ankita Garg <ankita@in.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, linux-media@vger.kernel.org

On Friday 08 July 2011, Russell King - ARM Linux wrote:
> On Tue, Jul 05, 2011 at 03:58:39PM +0200, Arnd Bergmann wrote:
> 
> > If I'm reading your "ARM: DMA: steal memory for DMA coherent mappings"
> > correctly, the idea is to have a per-platform compile-time amount
> > of memory that is reserved purely for coherent allocations and
> > taking out of the buddy allocator, right?
> 
> Yes, because every time I've looked at taking out memory mappings in
> the first level page tables, it's always been a major issue.
> 
> We have a method where we can remove first level mappings on
> uniprocessor systems in the ioremap code just fine - we use that so
> that systems can setup section and supersection mappings.  They can
> tear them down as well - and we update other tasks L1 page tables
> when they get switched in.
> 
> This, however, doesn't work on SMP, because if you have a DMA allocation
> (which is permitted from IRQ context) you must have some way of removing
> the L1 page table entries from all CPUs TLBs and the page tables currently
> in use and any future page tables which those CPUs may switch to.

Ah, interesting. So there is no tlb flush broadcast operation and it
always goes through IPI?

> So, in a SMP system, there is no safe way to remove L1 page table entries
> from IRQ context.  That means if memory is mapped for the buddy allocators
> using L1 page table entries, then it is fixed for that application on a
> SMP system.

Ok. Can we limit GFP_ATOMIC to memory that doesn't need to be remapped then?
I guess we can assume that there is no regression if we just skip
the dma_alloc_contiguous step in dma_alloc_coherent for any atomic
callers and immediately fall back to the regular allocator.

Unfortunately, this still means we have to keep both methods. I was
hoping that with CMA doing dynamic remapping there would be no need for
keeping a significant number of pages reserved for this.

	Arnd

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
