Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 761686B0088
	for <linux-mm@kvack.org>; Wed,  4 Mar 2009 12:26:04 -0500 (EST)
MIME-version: 1.0
Content-transfer-encoding: 7BIT
Content-type: TEXT/PLAIN; charset=US-ASCII
Received: from xanadu.home ([66.131.194.97]) by VL-MO-MR005.ip.videotron.ca
 (Sun Java(tm) System Messaging Server 6.3-4.01 (built Aug  3 2007; 32bit))
 with ESMTP id <0KFZ00D1ESDS9O30@VL-MO-MR005.ip.videotron.ca> for
 linux-mm@kvack.org; Wed, 04 Mar 2009 12:25:06 -0500 (EST)
Date: Wed, 04 Mar 2009 12:26:00 -0500 (EST)
From: Nicolas Pitre <nico@cam.org>
Subject: Re: [RFC] atomic highmem kmap page pinning
In-reply-to: <20090304171429.c013013c.minchan.kim@barrios-desktop>
Message-id: <alpine.LFD.2.00.0903041101170.5511@xanadu.home>
References: <alpine.LFD.2.00.0903040014140.5511@xanadu.home>
 <20090304171429.c013013c.minchan.kim@barrios-desktop>
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Russell King - ARM Linux <linux@arm.linux.org.uk>
List-ID: <linux-mm.kvack.org>

On Wed, 4 Mar 2009, Minchan Kim wrote:

> On Wed, 04 Mar 2009 00:58:13 -0500 (EST)
> Nicolas Pitre <nico@cam.org> wrote:
> 
> > I've implemented highmem for ARM.  Yes, some ARM machines do have lots 
> > of memory...
> > 
> > The problem is that most ARM machines have a non IO coherent cache, 
> > meaning that the dma_map_* set of functions must clean and/or invalidate 
> > the affected memory manually.  And because the majority of those 
> > machines have a VIVT cache, the cache maintenance operations must be 
> > performed using virtual addresses.
> > 
> > In dma_map_page(), an highmem pages could still be mapped and cached 
> > even after kunmap() was called on it.  As long as highmem pages are 
> > mapped, page_address(page) is non null and we can use that to 
> > synchronize the cache.
> > It is unlikely but still possible for kmap() to race and recycle the 
> > obtained virtual address above, and use it for another page though.  In 
> > that case, the new mapping could end up with dirty cache lines for 
> > another page, and the unsuspecting cache invalidation loop in 
> > dma_map_page() won't notice resulting in data loss.  Hence the need for 
> > some kind of kmap page pinning which can be used in any context, 
> > including IRQ context.
> > 
> > This is a RFC patch implementing the necessary part in the core code, as 
> > suggested by RMK. Please comment.
> 
> I am not sure if i understand your concern totally.
> I can understand it can be recycled. but Why is it racing ?

Suppose this sequence of events:

	- dma_map_page(..., DMA_FROM_DEVICE) is called on a highmem page.

	-->	- vaddr = page_address(page) is non null. In this case
		  it is likely that the page has valid cache lines
		  associated with vaddr. Remember that the cache is VIVT.

		-->	- for (i = vaddr; i < vaddr + PAGE_SIZE; i += 32)
				invalidate_cache_line(i);

	*** preemption occurs in the middle of the loop above ***

	- kmap_high() is called for a different page.

	-->	- last_pkmap_nr wraps to zero and flush_all_zero_pkmaps()
		  is called.  The pkmap_count value for the page passed
		  to dma_map_page() above happens to be 1, so it is 
		  unmapped.  But prior to that, flush_cache_kmaps() 
		  cleared the cache for it.  So far so good.

		- A fresh pkmap entry is assigned for this kmap request.
		  The Murphy law says it will eventually happen to use 
		  the same vaddr as the one which used to belong to the
		  other page being processed by dma_map_page() in the
		  preempted thread above.

	- The caller of kmap_high() start dirtying the cache using the 
	  new virtual mapping for its page.

	*** the first thread is rescheduled ***

			- The for loop is resumed, but now cached data 
			  belonging to a different physical page is 
			  being discarded!

And this is not only a preemption issue.  ARM can be SMP as well where 
this scenario is just as likely, and disabling preemption in 
dma_map_page() won't prevent it.

> Now, kmap semantic is that it can't be called in interrupt context.

I know.  And in this case I don't need the full kmap_high() semantics.  
What I need is a guarantee that, if I start invalidating cache lines 
from an highmem page, its virtual mapping won't go away.  Meaning that I 
need to increase pkmap_count whenever it is not zero.  And if it is zero 
then there is simply no cache invalidation to worry about.  And that 
pkmap_count increment must be possible from any context as its primary 
user would be dma_map_page().

> As far as I understand, To make irq_disable to prevent this problem is 
> rather big cost.

How big?  Could you please elaborate on the significance of this cost?

> I think it would be better to make page_address can return null in that case
> where pkmap_count is less than one

This is already the case, and when it happens then there is no cache 
invalidation to perform like I say above.  The race is possible when 
pkmap_count is 1 or becomes 1.

> or it's not previous page mapping.

Even if the cache invalidation loop checks on every iteration if the 
page mapping changed which would be terribly inefficient, there is still 
a race window for the mapping to change between the mapping test 
and the actual cache line invalidation instruction.


Nicolas

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
