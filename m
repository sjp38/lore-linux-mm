Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id 107546B0031
	for <linux-mm@kvack.org>; Wed, 31 Jul 2013 22:56:10 -0400 (EDT)
Date: Thu, 1 Aug 2013 11:56:36 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [patch 3/3] mm: page_alloc: fair zone allocator policy
Message-ID: <20130801025636.GC19540@bbox>
References: <1374267325-22865-1-git-send-email-hannes@cmpxchg.org>
 <1374267325-22865-4-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1374267325-22865-4-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi Hannes,

On Fri, Jul 19, 2013 at 04:55:25PM -0400, Johannes Weiner wrote:
> Each zone that holds userspace pages of one workload must be aged at a
> speed proportional to the zone size.  Otherwise, the time an
> individual page gets to stay in memory depends on the zone it happened
> to be allocated in.  Asymmetry in the zone aging creates rather
> unpredictable aging behavior and results in the wrong pages being
> reclaimed, activated etc.
> 
> But exactly this happens right now because of the way the page
> allocator and kswapd interact.  The page allocator uses per-node lists
> of all zones in the system, ordered by preference, when allocating a
> new page.  When the first iteration does not yield any results, kswapd
> is woken up and the allocator retries.  Due to the way kswapd reclaims
> zones below the high watermark while a zone can be allocated from when
> it is above the low watermark, the allocator may keep kswapd running
> while kswapd reclaim ensures that the page allocator can keep
> allocating from the first zone in the zonelist for extended periods of
> time.  Meanwhile the other zones rarely see new allocations and thus
> get aged much slower in comparison.
> 
> The result is that the occasional page placed in lower zones gets
> relatively more time in memory, even get promoted to the active list
> after its peers have long been evicted.  Meanwhile, the bulk of the
> working set may be thrashing on the preferred zone even though there
> may be significant amounts of memory available in the lower zones.
> 
> Even the most basic test -- repeatedly reading a file slightly bigger
> than memory -- shows how broken the zone aging is.  In this scenario,
> no single page should be able stay in memory long enough to get
> referenced twice and activated, but activation happens in spades:
> 
>   $ grep active_file /proc/zoneinfo
>       nr_inactive_file 0
>       nr_active_file 0
>       nr_inactive_file 0
>       nr_active_file 8
>       nr_inactive_file 1582
>       nr_active_file 11994
>   $ cat data data data data >/dev/null
>   $ grep active_file /proc/zoneinfo
>       nr_inactive_file 0
>       nr_active_file 70
>       nr_inactive_file 258753
>       nr_active_file 443214
>       nr_inactive_file 149793
>       nr_active_file 12021
> 
> Fix this with a very simple round robin allocator.  Each zone is
> allowed a batch of allocations that is proportional to the zone's
> size, after which it is treated as full.  The batch counters are reset
> when all zones have been tried and the allocator enters the slowpath
> and kicks off kswapd reclaim:
> 
>   $ grep active_file /proc/zoneinfo
>       nr_inactive_file 0
>       nr_active_file 0
>       nr_inactive_file 174
>       nr_active_file 4865
>       nr_inactive_file 53
>       nr_active_file 860
>   $ cat data data data data >/dev/null
>   $ grep active_file /proc/zoneinfo
>       nr_inactive_file 0
>       nr_active_file 0
>       nr_inactive_file 666622
>       nr_active_file 4988
>       nr_inactive_file 190969
>       nr_active_file 937

First of all, I should appreciate your great work!
It's amazing and I saw Zlatko proved it enhances real works.
Thanks Zlatko, too!

So, I don't want to prevent merging but I think at least, we should
discuss some issues.

The concern I have is that it could accelerate low memory pinning
problems like mlock. Actually, I don't have such workload that makes
pin lots of pages but that's why we introduced lowmem_reserve_ratio,
as you know well so we should cover this issue, at least.

Other thing of my concerns is to add overhead in fast path.
Sometime, we are really reluctant to add simple even "if" condition
in fastpath but you are adding atomic op whenever page is allocated and
enter slowpath whenever all of given zones's batchcount is zero.
Yes, it's not really slow path because it could return to normal status
without calling significant slow functions by reset batchcount of
prepare_slowpath.

I think it's tradeoff and I am biased your approach although we would
lose a little performance because fair aging would recover the loss by
fastpath's overhead. But who knows? Someone has a concern.

So we should mention about such problems.

> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> ---
>  include/linux/mmzone.h |  1 +
>  mm/page_alloc.c        | 39 +++++++++++++++++++++++++++++----------
>  2 files changed, 30 insertions(+), 10 deletions(-)
> 
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index af4a3b7..0c41d59 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -352,6 +352,7 @@ struct zone {
>  	 * free areas of different sizes
>  	 */
>  	spinlock_t		lock;
> +	atomic_t		alloc_batch;
>  	int                     all_unreclaimable; /* All pages pinned */
>  #if defined CONFIG_COMPACTION || defined CONFIG_CMA
>  	/* Set to true when the PG_migrate_skip bits should be cleared */
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index af1d956b..d938b67 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -1879,6 +1879,14 @@ zonelist_scan:
>  		if (alloc_flags & ALLOC_NO_WATERMARKS)
>  			goto try_this_zone;
>  		/*
> +		 * Distribute pages in proportion to the individual
> +		 * zone size to ensure fair page aging.  The zone a
> +		 * page was allocated in should have no effect on the
> +		 * time the page has in memory before being reclaimed.
> +		 */
> +		if (atomic_read(&zone->alloc_batch) <= 0)
> +			continue;
> +		/*
>  		 * When allocating a page cache page for writing, we
>  		 * want to get it from a zone that is within its dirty
>  		 * limit, such that no single zone holds more than its
> @@ -1984,7 +1992,8 @@ this_zone_full:
>  		goto zonelist_scan;
>  	}
>  
> -	if (page)
> +	if (page) {
> +		atomic_sub(1U << order, &zone->alloc_batch);
>  		/*
>  		 * page->pfmemalloc is set when ALLOC_NO_WATERMARKS was
>  		 * necessary to allocate the page. The expectation is
> @@ -1993,6 +2002,7 @@ this_zone_full:
>  		 * for !PFMEMALLOC purposes.
>  		 */
>  		page->pfmemalloc = !!(alloc_flags & ALLOC_NO_WATERMARKS);
> +	}
>  
>  	return page;
>  }
> @@ -2342,16 +2352,20 @@ __alloc_pages_high_priority(gfp_t gfp_mask, unsigned int order,
>  	return page;
>  }
>  
> -static inline
> -void wake_all_kswapd(unsigned int order, struct zonelist *zonelist,
> -						enum zone_type high_zoneidx,
> -						enum zone_type classzone_idx)
> +static void prepare_slowpath(gfp_t gfp_mask, unsigned int order,
> +			     struct zonelist *zonelist,
> +			     enum zone_type high_zoneidx,
> +			     enum zone_type classzone_idx)
>  {
>  	struct zoneref *z;
>  	struct zone *zone;
>  
> -	for_each_zone_zonelist(zone, z, zonelist, high_zoneidx)
> -		wakeup_kswapd(zone, order, classzone_idx);
> +	for_each_zone_zonelist(zone, z, zonelist, high_zoneidx) {
> +		atomic_set(&zone->alloc_batch,
> +			   high_wmark_pages(zone) - low_wmark_pages(zone));
> +		if (!(gfp_mask & __GFP_NO_KSWAPD))
> +			wakeup_kswapd(zone, order, classzone_idx);
> +	}
>  }
>  
>  static inline int
> @@ -2447,9 +2461,8 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
>  		goto nopage;
>  
>  restart:
> -	if (!(gfp_mask & __GFP_NO_KSWAPD))
> -		wake_all_kswapd(order, zonelist, high_zoneidx,
> -						zone_idx(preferred_zone));
> +	prepare_slowpath(gfp_mask, order, zonelist,
> +			 high_zoneidx, zone_idx(preferred_zone));
>  
>  	/*
>  	 * OK, we're below the kswapd watermark and have kicked background
> @@ -4758,6 +4771,9 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat,
>  		zone_seqlock_init(zone);
>  		zone->zone_pgdat = pgdat;
>  
> +		/* For bootup, initialized properly in watermark setup */
> +		atomic_set(&zone->alloc_batch, zone->managed_pages);
> +
>  		zone_pcp_init(zone);
>  		lruvec_init(&zone->lruvec);
>  		if (!size)
> @@ -5533,6 +5549,9 @@ static void __setup_per_zone_wmarks(void)
>  		zone->watermark[WMARK_LOW]  = min_wmark_pages(zone) + (tmp >> 2);
>  		zone->watermark[WMARK_HIGH] = min_wmark_pages(zone) + (tmp >> 1);
>  
> +		atomic_set(&zone->alloc_batch,
> +			   high_wmark_pages(zone) - low_wmark_pages(zone));
> +
>  		setup_zone_migrate_reserve(zone);
>  		spin_unlock_irqrestore(&zone->lock, flags);
>  	}
> -- 
> 1.8.3.2
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
