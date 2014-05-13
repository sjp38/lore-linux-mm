Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 227B56B0037
	for <linux-mm@kvack.org>; Mon, 12 May 2014 21:12:23 -0400 (EDT)
Received: by mail-pa0-f48.google.com with SMTP id rd3so9531378pab.7
        for <linux-mm@kvack.org>; Mon, 12 May 2014 18:12:22 -0700 (PDT)
Received: from lgeamrelo02.lge.com (lgeamrelo02.lge.com. [156.147.1.126])
        by mx.google.com with ESMTP id ud10si7133766pbc.116.2014.05.12.18.12.20
        for <linux-mm@kvack.org>;
        Mon, 12 May 2014 18:12:22 -0700 (PDT)
Date: Tue, 13 May 2014 10:14:27 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [RFC PATCH 2/3] CMA: aggressively allocate the pages on cma
 reserved memory when not used
Message-ID: <20140513011426.GB23803@js1304-P5Q-DELUXE>
References: <1399509144-8898-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1399509144-8898-3-git-send-email-iamjoonsoo.kim@lge.com>
 <5370FF1D.10707@codeaurora.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5370FF1D.10707@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <lauraa@codeaurora.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, Heesub Shin <heesub.shin@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, May 12, 2014 at 10:04:29AM -0700, Laura Abbott wrote:
> Hi,
> 
> On 5/7/2014 5:32 PM, Joonsoo Kim wrote:
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
> > make -j24
> > 
> > CMA reserve:		0 MB		512 MB
> > Elapsed-time:		234.8		361.8
> > Average-MemFree:	283880 KB	530851 KB
> > 
> > To solve this problem, I can think following 2 possible solutions.
> > 1. allocate the pages on cma reserved memory first, and if they are
> >    exhausted, allocate movable pages.
> > 2. interleaved allocation: try to allocate specific amounts of memory
> >    from cma reserved memory and then allocate from free movable memory.
> > 
> > I tested #1 approach and found the problem. Although free memory on
> > meminfo can move around low watermark, there is large fluctuation on free
> > memory, because too many pages are reclaimed when kswapd is invoked.
> > Reason for this behaviour is that successive allocated CMA pages are
> > on the LRU list in that order and kswapd reclaim them in same order.
> > These memory doesn't help watermark checking from kwapd, so too many
> > pages are reclaimed, I guess.
> > 
> 
> We have an out of tree implementation of #1 and so far it's worked for us
> although we weren't looking at the same metrics. I don't completely
> understand the issue you pointed out with #1. It sounds like the issue is
> that CMA pages are already in use by other processes and on LRU lists and
> because the pages are on LRU lists these aren't counted towards the
> watermark by kswapd. Is my understanding correct?

Hello,

Yes, your understanding is correct.
kswapd want to reclaim normal (not CMA) pages, but LRU lists could
have a lot of CMA pages continuously by #1 approach, so watermark
aren't restored easily.


> 
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
> > make -j24
> > 
> > <Before>
> > CMA reserve:            0 MB            512 MB
> > Elapsed-time:           234.8           361.8
> > Average-MemFree:        283880 KB       530851 KB
> > pswpin:                 7               110064
> > pswpout:                452             767502
> > 
> > <After>
> > CMA reserve:            0 MB            512 MB
> > Elapsed-time:           234.2           235.6
> > Average-MemFree:        281651 KB       290227 KB
> > pswpin:                 8               8
> > pswpout:                430             510
> > 
> > There is no difference if we don't have cma reserved memory (0 MB case).
> > But, with cma reserved memory (512 MB case), we fully utilize these
> > reserved memory through this patch and the system behaves like as
> > it doesn't reserve any memory.
> 
> What metric are you using to determine all CMA memory was fully used?
> We've been checking /proc/pagetypeinfo

In this result, we can check whether CMA memory was used more or not
by MemFree stat.
I used /proc/zoneinfo to get an insight.

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
> 
> Do you have any statistics related to failed migration from this? Latency
> and utilization are issues but so is migration success. In the past we've
> found that an increase in CMA utilization was related to increase in CMA
> migration failures because pages were unmigratable. The current
> workaround for this is limiting CMA pages to be used for user processes
> only and not the file cache. Both of these have their own problems.

I have the retrying number when doing 8 MB CMA allocation 20 times.
These number are average of 5 runs.

N:                    1        4       8        16
Retrying(Before):     0        0       0.6      12.2 
Retrying(After):      1.4      1.8     3        3.6

If you know any permanent failure case with file cache pages, please
let me know.

What I already know CMA migration failure about file cache pages is
the problems related to buffer_head lru, which you mentioned before.

> > Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> > 
> > diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> > index fac5509..3ff24d4 100644
> > --- a/include/linux/mmzone.h
> > +++ b/include/linux/mmzone.h
> > @@ -389,6 +389,12 @@ struct zone {
> >  	int			compact_order_failed;
> >  #endif
> >  
> > +#ifdef CONFIG_CMA
> > +	int has_cma;
> > +	int nr_try_cma;
> > +	int nr_try_movable;
> > +#endif
> > +
> >  	ZONE_PADDING(_pad1_)
> >  
> >  	/* Fields commonly accessed by the page reclaim scanner */
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index 674ade7..6f2b27b 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -788,6 +788,16 @@ void __init __free_pages_bootmem(struct page *page, unsigned int order)
> >  }
> >  
> >  #ifdef CONFIG_CMA
> > +void __init init_alloc_ratio_counter(struct zone *zone)
> > +{
> > +	if (zone->has_cma)
> > +		return;
> > +
> > +	zone->has_cma = 1;
> > +	zone->nr_try_movable = 0;
> > +	zone->nr_try_cma = 0;
> > +}
> > +
> >  /* Free whole pageblock and set its migration type to MIGRATE_CMA. */
> >  void __init init_cma_reserved_pageblock(struct page *page)
> >  {
> > @@ -803,6 +813,7 @@ void __init init_cma_reserved_pageblock(struct page *page)
> >  	set_pageblock_migratetype(page, MIGRATE_CMA);
> >  	__free_pages(page, pageblock_order);
> >  	adjust_managed_page_count(page, pageblock_nr_pages);
> > +	init_alloc_ratio_counter(page_zone(page));
> >  }
> >  #endif
> >  
> > @@ -1136,6 +1147,69 @@ __rmqueue_fallback(struct zone *zone, int order, int start_migratetype)
> >  	return NULL;
> >  }
> >  
> > +#ifdef CONFIG_CMA
> > +static struct page *__rmqueue_cma(struct zone *zone, unsigned int order,
> > +						int migratetype)
> > +{
> > +	long free, free_cma, free_wmark;
> > +	struct page *page;
> > +
> > +	if (migratetype != MIGRATE_MOVABLE || !zone->has_cma)
> > +		return NULL;
> > +
> > +	if (zone->nr_try_movable)
> > +		goto alloc_movable;
> > +
> > +alloc_cma:
> > +	if (zone->nr_try_cma) {
> > +		/* Okay. Now, we can try to allocate the page from cma region */
> > +		zone->nr_try_cma--;
> > +		page = __rmqueue_smallest(zone, order, MIGRATE_CMA);
> > +
> > +		/* CMA pages can vanish through CMA allocation */
> > +		if (unlikely(!page && order == 0))
> > +			zone->nr_try_cma = 0;
> > +
> > +		return page;
> > +	}
> > +
> > +	/* Reset ratio counter */
> > +	free_cma = zone_page_state(zone, NR_FREE_CMA_PAGES);
> > +
> > +	/* No cma free pages, so recharge only movable allocation */
> > +	if (free_cma <= 0) {
> > +		zone->nr_try_movable = pageblock_nr_pages;
> > +		goto alloc_movable;
> > +	}
> > +
> > +	free = zone_page_state(zone, NR_FREE_PAGES);
> > +	free_wmark = free - free_cma - high_wmark_pages(zone);
> > +
> > +	/*
> > +	 * free_wmark is below than 0, and it means that normal pages
> > +	 * are under the pressure, so we recharge only cma allocation.
> > +	 */
> > +	if (free_wmark <= 0) {
> > +		zone->nr_try_cma = pageblock_nr_pages;
> > +		goto alloc_cma;
> > +	}
> > +
> > +	if (free_wmark > free_cma) {
> > +		zone->nr_try_movable =
> > +			(free_wmark * pageblock_nr_pages) / free_cma;
> > +		zone->nr_try_cma = pageblock_nr_pages;
> > +	} else {
> > +		zone->nr_try_movable = pageblock_nr_pages;
> > +		zone->nr_try_cma = free_cma * pageblock_nr_pages / free_wmark;
> > +	}
> > +
> > +	/* Reset complete, start on movable first */
> > +alloc_movable:
> > +	zone->nr_try_movable--;
> > +	return NULL;
> > +}
> > +#endif
> > +
> >  /*
> >   * Do the hard work of removing an element from the buddy allocator.
> >   * Call me with the zone->lock already held.
> > @@ -1143,10 +1217,14 @@ __rmqueue_fallback(struct zone *zone, int order, int start_migratetype)
> >  static struct page *__rmqueue(struct zone *zone, unsigned int order,
> >  						int migratetype)
> >  {
> > -	struct page *page;
> > +	struct page *page = NULL;
> > +
> > +	if (IS_ENABLED(CONFIG_CMA))
> > +		page = __rmqueue_cma(zone, order, migratetype);
> >  
> >  retry_reserve:
> > -	page = __rmqueue_smallest(zone, order, migratetype);
> > +	if (!page)
> > +		page = __rmqueue_smallest(zone, order, migratetype);
> >  
> >  	if (unlikely(!page) && migratetype != MIGRATE_RESERVE) {
> >  		page = __rmqueue_fallback(zone, order, migratetype);
> > @@ -4849,6 +4927,8 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat,
> >  		zone_seqlock_init(zone);
> >  		zone->zone_pgdat = pgdat;
> >  		zone_pcp_init(zone);
> > +		if (IS_ENABLED(CONFIG_CMA))
> > +			zone->has_cma = 0;
> >  
> >  		/* For bootup, initialized properly in watermark setup */
> >  		mod_zone_page_state(zone, NR_ALLOC_BATCH, zone->managed_pages);
> > 
> 
> I'm going to see about running this through tests internally for comparison.
> Hopefully I'll get useful results in a day or so.

Okay.
I really hope to see your result. :)
Thanks for your interest.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
