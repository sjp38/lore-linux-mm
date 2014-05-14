Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id C5F8A6B0036
	for <linux-mm@kvack.org>; Wed, 14 May 2014 04:42:36 -0400 (EDT)
Received: by mail-pa0-f48.google.com with SMTP id rd3so1410437pab.21
        for <linux-mm@kvack.org>; Wed, 14 May 2014 01:42:36 -0700 (PDT)
Received: from e23smtp01.au.ibm.com (e23smtp01.au.ibm.com. [202.81.31.143])
        by mx.google.com with ESMTPS id iv2si613990pbd.254.2014.05.14.01.42.33
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 14 May 2014 01:42:35 -0700 (PDT)
Received: from /spool/local
	by e23smtp01.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Wed, 14 May 2014 18:42:31 +1000
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [9.190.235.21])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id 439A43578052
	for <linux-mm@kvack.org>; Wed, 14 May 2014 18:42:26 +1000 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s4E8gA3665994774
	for <linux-mm@kvack.org>; Wed, 14 May 2014 18:42:11 +1000
Received: from d23av03.au.ibm.com (localhost [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s4E8gOe9020125
	for <linux-mm@kvack.org>; Wed, 14 May 2014 18:42:24 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [RFC PATCH 2/3] CMA: aggressively allocate the pages on cma reserved memory when not used
In-Reply-To: <1399509144-8898-3-git-send-email-iamjoonsoo.kim@lge.com>
References: <1399509144-8898-1-git-send-email-iamjoonsoo.kim@lge.com> <1399509144-8898-3-git-send-email-iamjoonsoo.kim@lge.com>
Date: Wed, 14 May 2014 14:12:19 +0530
Message-ID: <8761l8ah04.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Laura Abbott <lauraa@codeaurora.org>, Minchan Kim <minchan@kernel.org>, Heesub Shin <heesub.shin@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Joonsoo Kim <iamjoonsoo.kim@lge.com> writes:

> CMA is introduced to provide physically contiguous pages at runtime.
> For this purpose, it reserves memory at boot time. Although it reserve
> memory, this reserved memory can be used for movable memory allocation
> request. This usecase is beneficial to the system that needs this CMA
> reserved memory infrequently and it is one of main purpose of
> introducing CMA.
>
> But, there is a problem in current implementation. The problem is that
> it works like as just reserved memory approach. The pages on cma reserved
> memory are hardly used for movable memory allocation. This is caused by
> combination of allocation and reclaim policy.
>
> The pages on cma reserved memory are allocated if there is no movable
> memory, that is, as fallback allocation. So the time this fallback
> allocation is started is under heavy memory pressure. Although it is under
> memory pressure, movable allocation easily succeed, since there would be
> many pages on cma reserved memory. But this is not the case for unmovable
> and reclaimable allocation, because they can't use the pages on cma
> reserved memory. These allocations regard system's free memory as
> (free pages - free cma pages) on watermark checking, that is, free
> unmovable pages + free reclaimable pages + free movable pages. Because
> we already exhausted movable pages, only free pages we have are unmovable
> and reclaimable types and this would be really small amount. So watermark
> checking would be failed. It will wake up kswapd to make enough free
> memory for unmovable and reclaimable allocation and kswapd will do.
> So before we fully utilize pages on cma reserved memory, kswapd start to
> reclaim memory and try to make free memory over the high watermark. This
> watermark checking by kswapd doesn't take care free cma pages so many
> movable pages would be reclaimed. After then, we have a lot of movable
> pages again, so fallback allocation doesn't happen again. To conclude,
> amount of free memory on meminfo which includes free CMA pages is moving
> around 512 MB if I reserve 512 MB memory for CMA.


Another issue i am facing with the current code is the atomic allocation
failing even with large number of CMA pages around. In my case we never
reclaimed because large part of the memory is consumed by the page cache and
for that, free memory check doesn't include at free_cma. I will test
with this patchset and update here once i have the results.

>
> I found this problem on following experiment.
>
> 4 CPUs, 1024 MB, VIRTUAL MACHINE
> make -j24
>
> CMA reserve:		0 MB		512 MB
> Elapsed-time:		234.8		361.8
> Average-MemFree:	283880 KB	530851 KB
>
> To solve this problem, I can think following 2 possible solutions.
> 1. allocate the pages on cma reserved memory first, and if they are
>    exhausted, allocate movable pages.
> 2. interleaved allocation: try to allocate specific amounts of memory
>    from cma reserved memory and then allocate from free movable memory.
>
> I tested #1 approach and found the problem. Although free memory on
> meminfo can move around low watermark, there is large fluctuation on free
> memory, because too many pages are reclaimed when kswapd is invoked.
> Reason for this behaviour is that successive allocated CMA pages are
> on the LRU list in that order and kswapd reclaim them in same order.
> These memory doesn't help watermark checking from kwapd, so too many
> pages are reclaimed, I guess.
>
> So, I implement #2 approach.
> One thing I should note is that we should not change allocation target
> (movable list or cma) on each allocation attempt, since this prevent
> allocated pages to be in physically succession, so some I/O devices can
> be hurt their performance. To solve this, I keep allocation target
> in at least pageblock_nr_pages attempts and make this number reflect
> ratio, free pages without free cma pages to free cma pages. With this
> approach, system works very smoothly and fully utilize the pages on
> cma reserved memory.
>
> Following is the experimental result of this patch.
>
> 4 CPUs, 1024 MB, VIRTUAL MACHINE
> make -j24
>
> <Before>
> CMA reserve:            0 MB            512 MB
> Elapsed-time:           234.8           361.8
> Average-MemFree:        283880 KB       530851 KB
> pswpin:                 7               110064
> pswpout:                452             767502
>
> <After>
> CMA reserve:            0 MB            512 MB
> Elapsed-time:           234.2           235.6
> Average-MemFree:        281651 KB       290227 KB
> pswpin:                 8               8
> pswpout:                430             510
>
> There is no difference if we don't have cma reserved memory (0 MB case).
> But, with cma reserved memory (512 MB case), we fully utilize these
> reserved memory through this patch and the system behaves like as
> it doesn't reserve any memory.
>
> With this patch, we aggressively allocate the pages on cma reserved memory
> so latency of CMA can arise. Below is the experimental result about
> latency.
>
> 4 CPUs, 1024 MB, VIRTUAL MACHINE
> CMA reserve: 512 MB
> Backgound Workload: make -jN
> Real Workload: 8 MB CMA allocation/free 20 times with 5 sec interval
>
> N:                    1        4       8        16
> Elapsed-time(Before): 4309.75  9511.09 12276.1  77103.5
> Elapsed-time(After):  5391.69 16114.1  19380.3  34879.2
>
> So generally we can see latency increase. Ratio of this increase
> is rather big - up to 70%. But, under the heavy workload, it shows
> latency decrease - up to 55%. This may be worst-case scenario, but
> reducing it would be important for some system, so, I can say that
> this patch have advantages and disadvantages in terms of latency.
>
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index fac5509..3ff24d4 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -389,6 +389,12 @@ struct zone {
>  	int			compact_order_failed;
>  #endif
>  
> +#ifdef CONFIG_CMA
> +	int has_cma;
> +	int nr_try_cma;
> +	int nr_try_movable;
> +#endif


Can you write documentation around this ?

> +
>  	ZONE_PADDING(_pad1_)
>  
>  	/* Fields commonly accessed by the page reclaim scanner */
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 674ade7..6f2b27b 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -788,6 +788,16 @@ void __init __free_pages_bootmem(struct page *page, unsigned int order)
>  }
>  
>  #ifdef CONFIG_CMA
> +void __init init_alloc_ratio_counter(struct zone *zone)
> +{
> +	if (zone->has_cma)
> +		return;
> +
> +	zone->has_cma = 1;
> +	zone->nr_try_movable = 0;
> +	zone->nr_try_cma = 0;
> +}
> +
>  /* Free whole pageblock and set its migration type to MIGRATE_CMA. */
>  void __init init_cma_reserved_pageblock(struct page *page)
>  {
> @@ -803,6 +813,7 @@ void __init init_cma_reserved_pageblock(struct page *page)
>  	set_pageblock_migratetype(page, MIGRATE_CMA);
>  	__free_pages(page, pageblock_order);
>  	adjust_managed_page_count(page, pageblock_nr_pages);
> +	init_alloc_ratio_counter(page_zone(page));
>  }
>  #endif
>  
> @@ -1136,6 +1147,69 @@ __rmqueue_fallback(struct zone *zone, int order, int start_migratetype)
>  	return NULL;
>  }
>  
> +#ifdef CONFIG_CMA
> +static struct page *__rmqueue_cma(struct zone *zone, unsigned int order,
> +						int migratetype)
> +{
> +	long free, free_cma, free_wmark;
> +	struct page *page;
> +
> +	if (migratetype != MIGRATE_MOVABLE || !zone->has_cma)
> +		return NULL;
> +
> +	if (zone->nr_try_movable)
> +		goto alloc_movable;
> +
> +alloc_cma:
> +	if (zone->nr_try_cma) {
> +		/* Okay. Now, we can try to allocate the page from cma region */
> +		zone->nr_try_cma--;
> +		page = __rmqueue_smallest(zone, order, MIGRATE_CMA);
> +
> +		/* CMA pages can vanish through CMA allocation */
> +		if (unlikely(!page && order == 0))
> +			zone->nr_try_cma = 0;
> +
> +		return page;
> +	}
> +
> +	/* Reset ratio counter */
> +	free_cma = zone_page_state(zone, NR_FREE_CMA_PAGES);
> +
> +	/* No cma free pages, so recharge only movable allocation */
> +	if (free_cma <= 0) {
> +		zone->nr_try_movable = pageblock_nr_pages;
> +		goto alloc_movable;
> +	}
> +
> +	free = zone_page_state(zone, NR_FREE_PAGES);
> +	free_wmark = free - free_cma - high_wmark_pages(zone);
> +
> +	/*
> +	 * free_wmark is below than 0, and it means that normal pages
> +	 * are under the pressure, so we recharge only cma allocation.
> +	 */
> +	if (free_wmark <= 0) {
> +		zone->nr_try_cma = pageblock_nr_pages;
> +		goto alloc_cma;
> +	}
> +
> +	if (free_wmark > free_cma) {
> +		zone->nr_try_movable =
> +			(free_wmark * pageblock_nr_pages) / free_cma;
> +		zone->nr_try_cma = pageblock_nr_pages;
> +	} else {
> +		zone->nr_try_movable = pageblock_nr_pages;
> +		zone->nr_try_cma = free_cma * pageblock_nr_pages / free_wmark;
> +	}

Can you add the commit message documentation here. 

> +
> +	/* Reset complete, start on movable first */
> +alloc_movable:
> +	zone->nr_try_movable--;
> +	return NULL;
> +}
> +#endif
> +
>  /*
>   * Do the hard work of removing an element from the buddy allocator.
>   * Call me with the zone->lock already held.
> @@ -1143,10 +1217,14 @@ __rmqueue_fallback(struct zone *zone, int order, int start_migratetype)
>  static struct page *__rmqueue(struct zone *zone, unsigned int order,
>  						int migratetype)
>  {
> -	struct page *page;
> +	struct page *page = NULL;
> +
> +	if (IS_ENABLED(CONFIG_CMA))
> +		page = __rmqueue_cma(zone, order, migratetype);

It would be better to move the migrate check here, So that it becomes 

         /* For migrate movable allocation try cma area first */
	if (IS_ENABLED(CONFIG_CMA) && (migratetype == MIGRATE_MOVABLE))



>  
>  retry_reserve:
> -	page = __rmqueue_smallest(zone, order, migratetype);
> +	if (!page)
> +		page = __rmqueue_smallest(zone, order, migratetype);
>  
>  	if (unlikely(!page) && migratetype != MIGRATE_RESERVE) {
>  		page = __rmqueue_fallback(zone, order, migratetype);
> @@ -4849,6 +4927,8 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat,
>  		zone_seqlock_init(zone);
>  		zone->zone_pgdat = pgdat;
>  		zone_pcp_init(zone);
> +		if (IS_ENABLED(CONFIG_CMA))
> +			zone->has_cma = 0;
>  
>  		/* For bootup, initialized properly in watermark setup */
>  		mod_zone_page_state(zone, NR_ALLOC_BATCH, zone->managed_pages);
> -- 
> 1.7.9.5
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
