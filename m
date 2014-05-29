Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f48.google.com (mail-pb0-f48.google.com [209.85.160.48])
	by kanga.kvack.org (Postfix) with ESMTP id 4536E6B004D
	for <linux-mm@kvack.org>; Thu, 29 May 2014 03:45:43 -0400 (EDT)
Received: by mail-pb0-f48.google.com with SMTP id rr13so12573492pbb.21
        for <linux-mm@kvack.org>; Thu, 29 May 2014 00:45:42 -0700 (PDT)
Received: from lgeamrelo02.lge.com (lgeamrelo02.lge.com. [156.147.1.126])
        by mx.google.com with ESMTP id rw8si27269402pab.167.2014.05.29.00.45.40
        for <linux-mm@kvack.org>;
        Thu, 29 May 2014 00:45:42 -0700 (PDT)
Date: Thu, 29 May 2014 16:48:47 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v2 2/3] CMA: aggressively allocate the pages on cma
 reserved memory when not used
Message-ID: <20140529074847.GA7554@js1304-P5Q-DELUXE>
References: <1401260672-28339-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1401260672-28339-3-git-send-email-iamjoonsoo.kim@lge.com>
 <5386E0CA.5040201@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <5386E0CA.5040201@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gioh Kim <gioh.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Laura Abbott <lauraa@codeaurora.org>, Minchan Kim <minchan@kernel.org>, Heesub Shin <heesub.shin@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, May 29, 2014 at 04:24:58PM +0900, Gioh Kim wrote:
> I've not understand your code fully. Please let me ask some silly questions.
> 
> 2014-05-28 i??i?? 4:04, Joonsoo Kim i?' e,?:
> > CMA is introduced to provide physically contiguous pages at runtime.
> > For this purpose, it reserves memory at boot time. Although it reserve
> > memory, this reserved memory can be used for movable memory allocation
> > request. This usecase is beneficial to the system that needs this CMA
> > reserved memory infrequently and it is one of main purpose of
> > introducing CMA.
> > 
> > But, there is a problem in current implementation. The problem is that
> > it works like as just reserved memory approach. The pages on cma reserved
> > memory are hardly used for movable memory allocation. This is caused by
> > combination of allocation and reclaim policy.
> > 
> > The pages on cma reserved memory are allocated if there is no movable
> > memory, that is, as fallback allocation. So the time this fallback
> > allocation is started is under heavy memory pressure. Although it is under
> > memory pressure, movable allocation easily succeed, since there would be
> > many pages on cma reserved memory. But this is not the case for unmovable
> > and reclaimable allocation, because they can't use the pages on cma
> > reserved memory. These allocations regard system's free memory as
> > (free pages - free cma pages) on watermark checking, that is, free
> > unmovable pages + free reclaimable pages + free movable pages. Because
> > we already exhausted movable pages, only free pages we have are unmovable
> > and reclaimable types and this would be really small amount. So watermark
> > checking would be failed. It will wake up kswapd to make enough free
> > memory for unmovable and reclaimable allocation and kswapd will do.
> > So before we fully utilize pages on cma reserved memory, kswapd start to
> > reclaim memory and try to make free memory over the high watermark. This
> > watermark checking by kswapd doesn't take care free cma pages so many
> > movable pages would be reclaimed. After then, we have a lot of movable
> > pages again, so fallback allocation doesn't happen again. To conclude,
> > amount of free memory on meminfo which includes free CMA pages is moving
> > around 512 MB if I reserve 512 MB memory for CMA.
> > 
> > I found this problem on following experiment.
> > 
> > 4 CPUs, 1024 MB, VIRTUAL MACHINE
> > make -j16
> > 
> > CMA reserve:            0 MB            512 MB
> > Elapsed-time:           225.2           472.5
> > Average-MemFree:        322490 KB       630839 KB
> > 
> > To solve this problem, I can think following 2 possible solutions.
> > 1. allocate the pages on cma reserved memory first, and if they are
> >     exhausted, allocate movable pages.
> > 2. interleaved allocation: try to allocate specific amounts of memory
> >     from cma reserved memory and then allocate from free movable memory.
> > 
> > I tested #1 approach and found the problem. Although free memory on
> > meminfo can move around low watermark, there is large fluctuation on free
> > memory, because too many pages are reclaimed when kswapd is invoked.
> > Reason for this behaviour is that successive allocated CMA pages are
> > on the LRU list in that order and kswapd reclaim them in same order.
> > These memory doesn't help watermark checking from kwapd, so too many
> > pages are reclaimed, I guess.
> > 
> > So, I implement #2 approach.
> > One thing I should note is that we should not change allocation target
> > (movable list or cma) on each allocation attempt, since this prevent
> > allocated pages to be in physically succession, so some I/O devices can
> > be hurt their performance. To solve this, I keep allocation target
> > in at least pageblock_nr_pages attempts and make this number reflect
> > ratio, free pages without free cma pages to free cma pages. With this
> > approach, system works very smoothly and fully utilize the pages on
> > cma reserved memory.
> > 
> > Following is the experimental result of this patch.
> > 
> > 4 CPUs, 1024 MB, VIRTUAL MACHINE
> > make -j16
> > 
> > <Before>
> > CMA reserve:            0 MB            512 MB
> > Elapsed-time:           225.2           472.5
> > Average-MemFree:        322490 KB       630839 KB
> > nr_free_cma:            0               131068
> > pswpin:                 0               261666
> > pswpout:                75              1241363
> > 
> > <After>
> > CMA reserve:            0 MB            512 MB
> > Elapsed-time:           222.7           224
> > Average-MemFree:        325595 KB       393033 KB
> > nr_free_cma:            0               61001
> > pswpin:                 0               6
> > pswpout:                44              502
> > 
> > There is no difference if we don't have cma reserved memory (0 MB case).
> > But, with cma reserved memory (512 MB case), we fully utilize these
> > reserved memory through this patch and the system behaves like as
> > it doesn't reserve any memory.
> > 
> > With this patch, we aggressively allocate the pages on cma reserved memory
> > so latency of CMA can arise. Below is the experimental result about
> > latency.
> > 
> > 4 CPUs, 1024 MB, VIRTUAL MACHINE
> > CMA reserve: 512 MB
> > Backgound Workload: make -jN
> > Real Workload: 8 MB CMA allocation/free 20 times with 5 sec interval
> > 
> > N:                    1        4       8        16
> > Elapsed-time(Before): 4309.75  9511.09 12276.1  77103.5
> > Elapsed-time(After):  5391.69 16114.1  19380.3  34879.2
> > 
> > So generally we can see latency increase. Ratio of this increase
> > is rather big - up to 70%. But, under the heavy workload, it shows
> > latency decrease - up to 55%. This may be worst-case scenario, but
> > reducing it would be important for some system, so, I can say that
> > this patch have advantages and disadvantages in terms of latency.
> > 
> > Although I think that this patch is right direction for CMA, there is
> > side-effect in following case. If there is small memory zone and CMA
> > occupys most of them, LRU for this zone would have many CMA pages. When
> > reclaim is started, these CMA pages would be reclaimed, but not counted
> > for watermark checking, so too many CMA pages could be reclaimed
> > unnecessarily. Until now, this can't happen because free CMA pages aren't
> > used easily. But, with this patch, free CMA pages are used easily so
> > this problem can be possible. I will handle it on another patchset
> > after some investigating.
> > 
> > v2: In fastpath, just replenish counters. Calculation is done whenver
> >      cma area is varied
> > 
> > Acked-by: Michal Nazarewicz <mina86@mina86.com>
> > Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> > 
> > diff --git a/arch/powerpc/kvm/book3s_hv_cma.c b/arch/powerpc/kvm/book3s_hv_cma.c
> > index d9d3d85..84a7582 100644
> > --- a/arch/powerpc/kvm/book3s_hv_cma.c
> > +++ b/arch/powerpc/kvm/book3s_hv_cma.c
> > @@ -132,6 +132,8 @@ struct page *kvm_alloc_cma(unsigned long nr_pages, unsigned long align_pages)
> >   		if (ret == 0) {
> >   			bitmap_set(cma->bitmap, pageno, nr_chunk);
> >   			page = pfn_to_page(pfn);
> > +			adjust_managed_cma_page_count(page_zone(page),
> > +								nr_pages);
> 
> I think it should be -nr_pages to decrease the managed_cma_pages variable.
> But it is not. I think there is a reason.
> Why the managed_cma_pages is increased by allocation?

Hello, Gioh.

It's my mistake. It should be -nr_pages.
Thanks for pointing out.

> 
> >   			memset(pfn_to_kaddr(pfn), 0, nr_pages << PAGE_SHIFT);
> >   			break;
> >   		} else if (ret != -EBUSY) {
> > @@ -180,6 +182,7 @@ bool kvm_release_cma(struct page *pages, unsigned long nr_pages)
> >   		     (pfn - cma->base_pfn) >> (KVM_CMA_CHUNK_ORDER - PAGE_SHIFT),
> >   		     nr_chunk);
> >   	free_contig_range(pfn, nr_pages);
> > +	adjust_managed_cma_page_count(page_zone(pages), nr_pages);
> >   	mutex_unlock(&kvm_cma_mutex);
> >   
> >   	return true;
> > @@ -210,6 +213,8 @@ static int __init kvm_cma_activate_area(unsigned long base_pfn,
> >   		}
> >   		init_cma_reserved_pageblock(pfn_to_page(base_pfn));
> >   	} while (--i);
> > +	adjust_managed_cma_page_count(zone, count);
> > +
> >   	return 0;
> >   }
> >   
> > diff --git a/drivers/base/dma-contiguous.c b/drivers/base/dma-contiguous.c
> > index 165c2c2..c578d5a 100644
> > --- a/drivers/base/dma-contiguous.c
> > +++ b/drivers/base/dma-contiguous.c
> > @@ -160,6 +160,7 @@ static int __init cma_activate_area(struct cma *cma)
> >   		}
> >   		init_cma_reserved_pageblock(pfn_to_page(base_pfn));
> >   	} while (--i);
> > +	adjust_managed_cma_page_count(zone, cma->count);
> >   
> >   	return 0;
> >   }
> > @@ -307,6 +308,7 @@ struct page *dma_alloc_from_contiguous(struct device *dev, int count,
> >   		if (ret == 0) {
> >   			bitmap_set(cma->bitmap, pageno, count);
> >   			page = pfn_to_page(pfn);
> > +			adjust_managed_cma_page_count(page_zone(page), count);
> 
> I think this also should be -count.

Ditto.

> 
> >   			break;
> >   		} else if (ret != -EBUSY) {
> >   			break;
> > @@ -353,6 +355,7 @@ bool dma_release_from_contiguous(struct device *dev, struct page *pages,
> >   	mutex_lock(&cma_mutex);
> >   	bitmap_clear(cma->bitmap, pfn - cma->base_pfn, count);
> >   	free_contig_range(pfn, count);
> > +	adjust_managed_cma_page_count(page_zone(pages), count);
> >   	mutex_unlock(&cma_mutex);
> >   
> >   	return true;
> > diff --git a/include/linux/gfp.h b/include/linux/gfp.h
> > index 39b81dc..51cffc1 100644
> > --- a/include/linux/gfp.h
> > +++ b/include/linux/gfp.h
> > @@ -415,6 +415,7 @@ extern int alloc_contig_range(unsigned long start, unsigned long end,
> >   extern void free_contig_range(unsigned long pfn, unsigned nr_pages);
> >   
> >   /* CMA stuff */
> > +extern void adjust_managed_cma_page_count(struct zone *zone, long count);
> >   extern void init_cma_reserved_pageblock(struct page *page);
> >   
> >   #endif
> > diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> > index fac5509..f52cb96 100644
> > --- a/include/linux/mmzone.h
> > +++ b/include/linux/mmzone.h
> > @@ -389,6 +389,20 @@ struct zone {
> >   	int			compact_order_failed;
> >   #endif
> >   
> > +#ifdef CONFIG_CMA
> > +	unsigned long managed_cma_pages;
> > +	/*
> > +	 * Number of allocation attempt on each movable/cma type
> > +	 * without switching type. max_try(movable/cma) maintain
> > +	 * predefined calculated counter and replenish nr_try_(movable/cma)
> > +	 * with each of them whenever both of them are 0.
> > +	 */
> > +	int nr_try_movable;
> > +	int nr_try_cma;
> > +	int max_try_movable;
> > +	int max_try_cma;
> > +#endif
> > +
> >   	ZONE_PADDING(_pad1_)
> >   
> >   	/* Fields commonly accessed by the page reclaim scanner */
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index 674ade7..ca678b6 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -788,6 +788,56 @@ void __init __free_pages_bootmem(struct page *page, unsigned int order)
> >   }
> >   
> >   #ifdef CONFIG_CMA
> > +void adjust_managed_cma_page_count(struct zone *zone, long count)
> > +{
> > +	unsigned long flags;
> > +	long total, cma, movable;
> > +
> > +	spin_lock_irqsave(&zone->lock, flags);
> > +	zone->managed_cma_pages += count;
> > +
> > +	total = zone->managed_pages;
> > +	cma = zone->managed_cma_pages;
> > +	movable = total - cma - high_wmark_pages(zone);
> 
> If cma can be negative value, above calcuation increase movable value becuase -cma becomes positive value.
> Does it need a sign check?

This is leftover from version 1. They (totla, cma, movable)
can not be negative on this v2. I will fix it on v3.

> 
> 
> 
> > +
> > +	/* No cma pages, so do only movable allocation */
> > +	if (cma <= 0) {
> > +		zone->max_try_movable = pageblock_nr_pages;
> > +		zone->max_try_cma = 0;
> > +		goto out;
> > +	}
> > +
> > +	/*
> > +	 * We want to consume cma pages with well balanced ratio so that
> > +	 * we have consumed enough cma pages before the reclaim. For this
> > +	 * purpose, we can use the ratio, movable : cma. And we doesn't
> > +	 * want to switch too frequently, because it prevent allocated pages
> > +	 * from beging successive and it is bad for some sorts of devices.
> > +	 * I choose pageblock_nr_pages for the minimum amount of successive
> > +	 * allocation because it is the size of a huge page and fragmentation
> > +	 * avoidance is implemented based on this size.
> > +	 *
> > +	 * To meet above criteria, I derive following equation.
> > +	 *
> > +	 * if (movable > cma) then; movable : cma = X : pageblock_nr_pages
> > +	 * else (movable <= cma) then; movable : cma = pageblock_nr_pages : X
> > +	 */
> > +	if (movable > cma) {
> > +		zone->max_try_movable =
> > +			(movable * pageblock_nr_pages) / cma;
> 
> I think you assume that cma value cannot be negative. If cma can be negative, the resule of dividing by cma becomes negative. Right?

It cannot be negative.

> 
> > +		zone->max_try_cma = pageblock_nr_pages;
> > +	} else {
> > +		zone->max_try_movable = pageblock_nr_pages;
> > +		zone->max_try_cma = cma * pageblock_nr_pages / movable;
> > +	}
> > +
> > +out:
> > +	zone->nr_try_movable = zone->max_try_movable;
> > +	zone->nr_try_cma = zone->max_try_cma;
> > +
> > +	spin_unlock_irqrestore(&zone->lock, flags);
> > +}
> > +
> >   /* Free whole pageblock and set its migration type to MIGRATE_CMA. */
> >   void __init init_cma_reserved_pageblock(struct page *page)
> >   {
> > @@ -1136,6 +1186,36 @@ __rmqueue_fallback(struct zone *zone, int order, int start_migratetype)
> >   	return NULL;
> >   }
> >   
> > +#ifdef CONFIG_CMA
> > +static struct page *__rmqueue_cma(struct zone *zone, unsigned int order)
> > +{
> > +	struct page *page;
> > +
> > +	if (zone->nr_try_movable > 0)
> > +		goto alloc_movable;
> > +
> > +	if (zone->nr_try_cma > 0) {
> > +		/* Okay. Now, we can try to allocate the page from cma region */
> > +		zone->nr_try_cma -= 1 << order;
> > +		page = __rmqueue_smallest(zone, order, MIGRATE_CMA);
> > +
> > +		/* CMA pages can vanish through CMA allocation */
> > +		if (unlikely(!page && order == 0))
> > +			zone->nr_try_cma = 0;
> > +
> > +		return page;
> > +	}
> > +
> > +	/* Reset counter */
> > +	zone->nr_try_movable = zone->max_try_movable;
> > +	zone->nr_try_cma = zone->max_try_cma;
> > +
> > +alloc_movable:
> > +	zone->nr_try_movable -= 1 << order;
> > +	return NULL;
> > +}
> > +#endif
> > +
> >   /*
> >    * Do the hard work of removing an element from the buddy allocator.
> >    * Call me with the zone->lock already held.
> > @@ -1143,10 +1223,15 @@ __rmqueue_fallback(struct zone *zone, int order, int start_migratetype)
> >   static struct page *__rmqueue(struct zone *zone, unsigned int order,
> >   						int migratetype)
> >   {
> > -	struct page *page;
> > +	struct page *page = NULL;
> > +
> > +	if (IS_ENABLED(CONFIG_CMA) &&
> 
> You might know that CONFIG_CMA is enabled and there is no CMA memory, because CONFIG_CMA_SIZE_MBYTES can be zero.
> Is IS_ENABLED(CONFIG_CMA) alright in that case?

next line checks whether zone->managed_cma_pages is positive or not.
If there is no CMA memory, zone->managed_cma_pages will be zero and
we will skip to call __rmqueue_cma().

Thanks for review!!!

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
