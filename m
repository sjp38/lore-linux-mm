Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 8542E6B00AD
	for <linux-mm@kvack.org>; Wed,  4 Mar 2009 23:22:54 -0500 (EST)
Received: by ti-out-0910.google.com with SMTP id u3so3483161tia.8
        for <linux-mm@kvack.org>; Wed, 04 Mar 2009 20:22:51 -0800 (PST)
Date: Thu, 5 Mar 2009 13:20:54 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [RFC] atomic highmem kmap page pinning
Message-Id: <20090305132054.888396da.minchan.kim@barrios-desktop>
In-Reply-To: <alpine.LFD.2.00.0903042129140.5511@xanadu.home>
References: <alpine.LFD.2.00.0903040014140.5511@xanadu.home>
	<20090304171429.c013013c.minchan.kim@barrios-desktop>
	<alpine.LFD.2.00.0903041101170.5511@xanadu.home>
	<20090305080717.f7832c63.minchan.kim@barrios-desktop>
	<alpine.LFD.2.00.0903042129140.5511@xanadu.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nicolas Pitre <nico@cam.org>
Cc: Minchan Kim <minchan.kim@gmail.com>, lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Russell King - ARM Linux <linux@arm.linux.org.uk>
List-ID: <linux-mm.kvack.org>

On Wed, 04 Mar 2009 21:37:43 -0500 (EST)
Nicolas Pitre <nico@cam.org> wrote:

> On Thu, 5 Mar 2009, Minchan Kim wrote:
> 
> > I thought kmap and dma_map_page usage was following.
> > 
> > kmap(page);
> > ...
> > dma_map_page(...)
> >   invalidate_cache_line
> > 
> > kunmap(page);
> > 
> > In this case, how do pkmap_count value for the page passed to dma_map_page become 1 ?
> > The caller have to make sure to complete dma_map_page before kunmap.
> 
> 
> The caller doesn't have to call kmap() on pages it intends to use for 
> DMA.

Thanks for pointing me. 
Russel also explained that. 
Sorry for my misunderstanding. 

I want to add your changelog in git log. 
--- 
       - dma_map_page(..., DMA_FROM_DEVICE) is called on a highmem page.

       -->     - vaddr = page_address(page) is non null. In this case
                 it is likely that the page has valid cache lines
                 associated with vaddr. Remember that the cache is VIVT.

               -->     - for (i = vaddr; i < vaddr + PAGE_SIZE; i += 32)
                               invalidate_cache_line(i);

       *** preemption occurs in the middle of the loop above ***

       - kmap_high() is called for a different page.

       -->     - last_pkmap_nr wraps to zero and flush_all_zero_pkmaps()
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
---

> > Do I miss something ?
> 
> See above.
> 
> > > > As far as I understand, To make irq_disable to prevent this problem is 
> > > > rather big cost.
> > > 
> > > How big?  Could you please elaborate on the significance of this cost?
> > 
> > I don't have a number. It depends on you for submitting this patch. 
> 
> My assertion is that the cost is negligible.  This is why I'm asking you 
> why you think this is a big cost.

Of course, I am not sure whether it's big cost or not. 
But I thought it already is used in many fs, driver.
so, whether it's big cost depends on workload type .

However, This patch is needed for VIVT and no coherent cache.
Is right ?

If it is right, it will add unnessary overhead in other architecture 
which don't have this problem.

I think it's not desirable although it is small cost.
If we have a other method which avoids unnessary overhead, It would be better.
Unfortunately, I don't have any way to solve this, now. 

Let us wait for other server guys's opinion.  :)

> Nicolas


-- 
Kinds Regards
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
