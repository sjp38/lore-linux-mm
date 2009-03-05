Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 27C2F6B00B2
	for <linux-mm@kvack.org>; Wed,  4 Mar 2009 19:27:29 -0500 (EST)
Received: by ti-out-0910.google.com with SMTP id u3so3430149tia.8
        for <linux-mm@kvack.org>; Wed, 04 Mar 2009 16:27:26 -0800 (PST)
Date: Thu, 5 Mar 2009 09:25:34 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [RFC] atomic highmem kmap page pinning
Message-Id: <20090305092534.740ee3c9.minchan.kim@barrios-desktop>
In-Reply-To: <20090304234633.GD14744@n2100.arm.linux.org.uk>
References: <alpine.LFD.2.00.0903040014140.5511@xanadu.home>
	<20090304171429.c013013c.minchan.kim@barrios-desktop>
	<alpine.LFD.2.00.0903041101170.5511@xanadu.home>
	<20090305080717.f7832c63.minchan.kim@barrios-desktop>
	<20090304234633.GD14744@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Cc: Minchan Kim <minchan.kim@gmail.com>, Nicolas Pitre <nico@cam.org>, lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Andrea Arcangeli <andrea@suse.de>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Wed, 4 Mar 2009 23:46:33 +0000
Russell King - ARM Linux <linux@arm.linux.org.uk> wrote:

> On Thu, Mar 05, 2009 at 08:07:17AM +0900, Minchan Kim wrote:
> > On Wed, 04 Mar 2009 12:26:00 -0500 (EST)
> > Nicolas Pitre <nico@cam.org> wrote:
> > 
> > > On Wed, 4 Mar 2009, Minchan Kim wrote:
> > > 
> > > > On Wed, 04 Mar 2009 00:58:13 -0500 (EST)
> > > > Nicolas Pitre <nico@cam.org> wrote:
> > > > 
> > > > > I've implemented highmem for ARM.  Yes, some ARM machines do have lots 
> > > > > of memory...
> > > > > 
> > > > > The problem is that most ARM machines have a non IO coherent cache, 
> > > > > meaning that the dma_map_* set of functions must clean and/or invalidate 
> > > > > the affected memory manually.  And because the majority of those 
> > > > > machines have a VIVT cache, the cache maintenance operations must be 
> > > > > performed using virtual addresses.
> > > > > 
> > > > > In dma_map_page(), an highmem pages could still be mapped and cached 
> > > > > even after kunmap() was called on it.  As long as highmem pages are 
> > > > > mapped, page_address(page) is non null and we can use that to 
> > > > > synchronize the cache.
> > > > > It is unlikely but still possible for kmap() to race and recycle the 
> > > > > obtained virtual address above, and use it for another page though.  In 
> > > > > that case, the new mapping could end up with dirty cache lines for 
> > > > > another page, and the unsuspecting cache invalidation loop in 
> > > > > dma_map_page() won't notice resulting in data loss.  Hence the need for 
> > > > > some kind of kmap page pinning which can be used in any context, 
> > > > > including IRQ context.
> ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
> 
> > > > > This is a RFC patch implementing the necessary part in the core code, as 
> > > > > suggested by RMK. Please comment.
> > > > 
> > > > I am not sure if i understand your concern totally.
> > > > I can understand it can be recycled. but Why is it racing ?
> > > 
> > > Suppose this sequence of events:
> > > 
> > > 	- dma_map_page(..., DMA_FROM_DEVICE) is called on a highmem page.
> > > 
> > > 	-->	- vaddr = page_address(page) is non null. In this case
> > > 		  it is likely that the page has valid cache lines
> > > 		  associated with vaddr. Remember that the cache is VIVT.
> > > 
> > > 		-->	- for (i = vaddr; i < vaddr + PAGE_SIZE; i += 32)
> > > 				invalidate_cache_line(i);
> > > 
> > > 	*** preemption occurs in the middle of the loop above ***
> > > 
> > > 	- kmap_high() is called for a different page.
> > > 
> > > 	-->	- last_pkmap_nr wraps to zero and flush_all_zero_pkmaps()
> > > 		  is called.  The pkmap_count value for the page passed
> > > 		  to dma_map_page() above happens to be 1, so it is 
> > > 		  unmapped.  But prior to that, flush_cache_kmaps() 
> > > 		  cleared the cache for it.  So far so good.
> > 
> > Thanks for kind explanation.:)
> > 
> > I thought kmap and dma_map_page usage was following.
> > 
> > kmap(page);
> > ...
> > dma_map_page(...)
> >   invalidate_cache_line
> > 
> > kunmap(page);
> 
> No, that's not the usage at all.  kmap() can't be called from the
> contexts which dma_map_page() is called from (iow, IRQ contexts as
> pointed out in the paragraph I underlined above.)
> 
> We're talking about dma_map_page() _internally_ calling kmap_get_page()
> to _atomically_ and _safely_ check whether the page was kmapped.  If
> it was kmapped, we need to pin the page and return its currently mapped
> address for cache handling and then release that reference.

Thanks, Russel. 
I see. That was thing I missed. :)

> None of the existing kmap support comes anywhere near to providing a
> mechanism for this because it can't be used in the contexts under which
> dma_map_page() is called.

Right. 

> If we could do it with existing interfaces, we wouldn't need a new
> interface would we?

OK. 
As previous said, I don't like kmap_high's irq disable.
It's already used in many place. so irq'disable effect might be rather big.

How about new interface which is like KM_IRQ's kmap_atomic slot 
 with serializing kmap_atomic_lock?

Let's Cced other experts. 

-- 
Kinds Regards
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
