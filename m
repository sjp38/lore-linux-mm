Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx107.postini.com [74.125.245.107])
	by kanga.kvack.org (Postfix) with SMTP id EB9AD6B004D
	for <linux-mm@kvack.org>; Wed, 25 Jan 2012 10:00:19 -0500 (EST)
Date: Wed, 25 Jan 2012 15:00:16 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH v2 -mm 1/3] mm: reclaim at order 0 when compaction is
 enabled
Message-ID: <20120125150016.GB3901@csn.ul.ie>
References: <20120124131822.4dc03524@annuminas.surriel.com>
 <20120124132136.3b765f0c@annuminas.surriel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20120124132136.3b765f0c@annuminas.surriel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-mm@kvack.org, lkml <linux-kernel@vger.kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>

On Tue, Jan 24, 2012 at 01:21:36PM -0500, Rik van Riel wrote:
> When built with CONFIG_COMPACTION, kswapd does not try to free
> contiguous pages. 

balance_pgdat() gets its order from wakeup_kswapd(). This does not apply
to THP because kswapd does not get woken for THP but it should be woken
up for allocations like jumbo frames or order-1.

This order is passed to shrink_zone(), shrink_list, shrink_inactive_list
and to isolate_lru_pages() which will isolate pages within a naturally
aligned boundary. This happens even with CONFIG_COMPACTION enabled.
There have been a number of changes in vmscan.c recently so maybe we are
looking at different versions but why do you say it doesn't free
contiguous pages?

That said, this is lumpy-reclaim-like behaviour and we want to move
away from it. There is no guarantee that there are pages that can be
isolated in the naturally aligned region which is particularly true if
swap is disabled. This has not happened yet as each cycle had changes
to compaction that took priority (the most recent being sync-light). I'm
glad you picked this up, so thanks.

As kswapd does no memory compaction itself, this patch still makes
sense but I found the changelog misleading.

> Because it is not trying, it should also not
> test whether it succeeded, because that can result in continuous
> page reclaim, until a large fraction of memory is free and large
> fractions of the working set have been evicted.
> 
> In shrink_inactive_list, we should not try to do higher order
> (out of LRU order) page isolation, unless we really are in 
> lumpy reclaim mode. This gives all pages a good amount of time
> on the inactive list, giving the actively used pages the chance
> to get referenced and avoid eviction.
> 
> Also remove a line of code that increments balanced right before
> exiting the function.
> 
> Signed-off-by: Rik van Riel <riel@redhat.com>
> ---
>  mm/vmscan.c |   29 ++++++++++++++++++++++-------
>  1 files changed, 22 insertions(+), 7 deletions(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 2880396..0398fab 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1512,6 +1512,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct mem_cgroup_zone *mz,
>  	unsigned long nr_writeback = 0;
>  	isolate_mode_t reclaim_mode = ISOLATE_INACTIVE;
>  	struct zone *zone = mz->zone;
> +	int order = 0;
>  
>  	while (unlikely(too_many_isolated(zone, file, sc))) {
>  		congestion_wait(BLK_RW_ASYNC, HZ/10);
> @@ -1522,8 +1523,10 @@ shrink_inactive_list(unsigned long nr_to_scan, struct mem_cgroup_zone *mz,
>  	}
>  
>  	set_reclaim_mode(priority, sc, false);
> -	if (sc->reclaim_mode & RECLAIM_MODE_LUMPYRECLAIM)
> +	if (sc->reclaim_mode & RECLAIM_MODE_LUMPYRECLAIM) {
>  		reclaim_mode |= ISOLATE_ACTIVE;
> +		order = sc->order;
> +	}
>  
>  	lru_add_drain();
>  

This is a nit-pick but I would far prefer if you did not bypass
sc->order like this and instead changes isolate_lru_pages to do a

if (!order || !(sc->reclaim_mode & RECLAIM_MODE_LUMPYRECLAIM))
	continue;

That would very clearly mark where LUMPYRECLAIM takes effect in
isolate_lru_pages() and makes deleting LUMPYRECLAIM easier in the
future.

The second effect of this change is a non-obvious side-effect. kswapd
will now isolate fewer pages per cycle because it will isolate
SWAP_CLUSTER_MAX pages instead of SWAP_CLUSTER_MAX<<order which it
potentially does currently. This is not wrong as such and may be
desirable to limit how much reclaim kswapd does but potentially it
impacts success rates for compaction. As this does not apply to THP,
it will be difficult to detect but bear in mind if we see an increase
in high-order allocation failures after this patch is merged. I am
not suggesting a change here but it would be nice to note in the
changelog if there is a new version of this patch.

> @@ -1535,7 +1538,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct mem_cgroup_zone *mz,
>  	spin_lock_irq(&zone->lru_lock);
>  
>  	nr_taken = isolate_lru_pages(nr_to_scan, mz, &page_list,
> -				     &nr_scanned, sc->order,
> +				     &nr_scanned, order,
>  				     reclaim_mode, 0, file);
>  	if (global_reclaim(sc)) {
>  		zone->pages_scanned += nr_scanned;
> @@ -2754,7 +2757,7 @@ loop_again:
>  		 */
>  		for (i = 0; i <= end_zone; i++) {
>  			struct zone *zone = pgdat->node_zones + i;
> -			int nr_slab;
> +			int nr_slab, testorder;
>  			unsigned long balance_gap;
>  
>  			if (!populated_zone(zone))
> @@ -2783,11 +2786,25 @@ loop_again:
>  			 * gap is either the low watermark or 1%
>  			 * of the zone, whichever is smaller.
>  			 */
> +			testorder = order;
>  			balance_gap = min(low_wmark_pages(zone),
>  				(zone->present_pages +
>  					KSWAPD_ZONE_BALANCE_GAP_RATIO-1) /
>  				KSWAPD_ZONE_BALANCE_GAP_RATIO);
> -			if (!zone_watermark_ok_safe(zone, order,
> +			/*
> +			 * Kswapd reclaims only single pages when
> +			 * COMPACTION_BUILD. Trying too hard to get
> +			 * contiguous free pages can result in excessive
> +			 * amounts of free memory, and useful things
> +			 * getting kicked out of memory.
> +			 * Limit the amount of reclaim to something sane,
> +			 * plus space for compaction to do its thing.
> +			 */
> +			if (COMPACTION_BUILD) {
> +				testorder = 0;
> +				balance_gap += 2<<order;
> +			}

This 2<<order logic now appears in a few places. I am not expecting
it to be handled in this patch but at some point the various different
balance_gap logics need to be put in once place.

> +			if (!zone_watermark_ok_safe(zone, testorder,
>  					high_wmark_pages(zone) + balance_gap,
>  					end_zone, 0)) {
>  				shrink_zone(priority, zone, &sc);
> @@ -2816,7 +2833,7 @@ loop_again:
>  				continue;
>  			}
>  
> -			if (!zone_watermark_ok_safe(zone, order,
> +			if (!zone_watermark_ok_safe(zone, testorder,
>  					high_wmark_pages(zone), end_zone, 0)) {
>  				all_zones_ok = 0;
>  				/*
> @@ -2922,8 +2939,6 @@ out:
>  
>  			/* If balanced, clear the congested flag */
>  			zone_clear_flag(zone, ZONE_CONGESTED);
> -			if (i <= *classzone_idx)
> -				balanced += zone->present_pages;
>  		}

Why is this being deleted? It is still used by pgdat_balanced().

>  	}
>  

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
