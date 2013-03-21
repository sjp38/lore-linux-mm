Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id 13EC76B0002
	for <linux-mm@kvack.org>; Thu, 21 Mar 2013 10:55:00 -0400 (EDT)
Date: Thu, 21 Mar 2013 15:54:58 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 03/10] mm: vmscan: Flatten kswapd priority loop
Message-ID: <20130321145458.GM6094@dhcp22.suse.cz>
References: <1363525456-10448-1-git-send-email-mgorman@suse.de>
 <1363525456-10448-4-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1363525456-10448-4-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linux-MM <linux-mm@kvack.org>, Jiri Slaby <jslaby@suse.cz>, Valdis Kletnieks <Valdis.Kletnieks@vt.edu>, Rik van Riel <riel@redhat.com>, Zlatko Calusic <zcalusic@bitsync.net>, Johannes Weiner <hannes@cmpxchg.org>, dormando <dormando@rydia.net>, Satoru Moriya <satoru.moriya@hds.com>, LKML <linux-kernel@vger.kernel.org>

On Sun 17-03-13 13:04:09, Mel Gorman wrote:
> kswapd stops raising the scanning priority when at least SWAP_CLUSTER_MAX
> pages have been reclaimed or the pgdat is considered balanced. It then
> rechecks if it needs to restart at DEF_PRIORITY and whether high-order
> reclaim needs to be reset. This is not wrong per-se but it is confusing
> to follow and forcing kswapd to stay at DEF_PRIORITY may require several
> restarts before it has scanned enough pages to meet the high watermark even
> at 100% efficiency.

> This patch irons out the logic a bit by controlling when priority is
> raised and removing the "goto loop_again".

Applause Mr. Gorman ;) I really hat this goto loop_again. It makes my
head scratch all the time.

> This patch has kswapd raise the scanning priority until it is scanning
> enough pages that it could meet the high watermark in one shrink of the
> LRU lists if it is able to reclaim at 100% efficiency. It will not raise
> the scanning prioirty higher unless it is failing to reclaim any pages.
> 
> To avoid infinite looping for high-order allocation requests kswapd will
> not reclaim for high-order allocations when it has reclaimed at least
> twice the number of pages as the allocation request.
> 
> Signed-off-by: Mel Gorman <mgorman@suse.de>
> ---
>  mm/vmscan.c | 86 ++++++++++++++++++++++++++++++-------------------------------
>  1 file changed, 42 insertions(+), 44 deletions(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 182ff15..279d0c2 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2625,8 +2625,11 @@ static bool prepare_kswapd_sleep(pg_data_t *pgdat, int order, long remaining,
>  /*
>   * kswapd shrinks the zone by the number of pages required to reach
>   * the high watermark.
> + *
> + * Returns true if kswapd scanned at least the requested number of
> + * pages to reclaim.

Maybe move the comment about not rising priority in such case here to be
clear what the return value means. Without that the return value could
be misinterpreted that kswapd_shrink_zone succeeded in shrinking might
be not true.
Or maybe even better, leave the void there and add bool *raise_priority
argument here so the decision and raise_priority are at the same place.

>   */
> -static void kswapd_shrink_zone(struct zone *zone,
> +static bool kswapd_shrink_zone(struct zone *zone,
>  			       struct scan_control *sc,
>  			       unsigned long lru_pages)
>  {
> @@ -2646,6 +2649,8 @@ static void kswapd_shrink_zone(struct zone *zone,
>  
>  	if (nr_slab == 0 && !zone_reclaimable(zone))
>  		zone->all_unreclaimable = 1;
> +
> +	return sc->nr_scanned >= sc->nr_to_reclaim;
>  }
>  
>  /*
[...]
> @@ -2803,8 +2805,16 @@ loop_again:
>  
>  			if ((buffer_heads_over_limit && is_highmem_idx(i)) ||
>  			    !zone_balanced(zone, testorder,
> -					   balance_gap, end_zone))
> -				kswapd_shrink_zone(zone, &sc, lru_pages);
> +					   balance_gap, end_zone)) {
> +				/*
> +				 * There should be no need to raise the
> +				 * scanning priority if enough pages are
> +				 * already being scanned that that high

s/that that/that/

> +				 * watermark would be met at 100% efficiency.
> +				 */
> +				if (kswapd_shrink_zone(zone, &sc, lru_pages))
> +					raise_priority = false;
> +			}
>  
>  			/*
>  			 * If we're getting trouble reclaiming, start doing
> @@ -2839,46 +2849,33 @@ loop_again:
>  				pfmemalloc_watermark_ok(pgdat))
>  			wake_up(&pgdat->pfmemalloc_wait);
>  
> -		if (pgdat_balanced(pgdat, order, *classzone_idx)) {
> -			pgdat_is_balanced = true;
> -			break;		/* kswapd: all done */
> -		}
> -
>  		/*
> -		 * We do this so kswapd doesn't build up large priorities for
> -		 * example when it is freeing in parallel with allocators. It
> -		 * matches the direct reclaim path behaviour in terms of impact
> -		 * on zone->*_priority.
> +		 * Fragmentation may mean that the system cannot be rebalanced
> +		 * for high-order allocations in all zones. If twice the
> +		 * allocation size has been reclaimed and the zones are still
> +		 * not balanced then recheck the watermarks at order-0 to
> +		 * prevent kswapd reclaiming excessively. Assume that a
> +		 * process requested a high-order can direct reclaim/compact.
>  		 */
> -		if (sc.nr_reclaimed >= SWAP_CLUSTER_MAX)
> -			break;
> -	} while (--sc.priority >= 0);
> +		if (order && sc.nr_reclaimed >= 2UL << order)
> +			order = sc.order = 0;
>  
> -out:
> -	if (!pgdat_is_balanced) {
> -		cond_resched();
> +		/* Check if kswapd should be suspending */
> +		if (try_to_freeze() || kthread_should_stop())
> +			break;
>  
> -		try_to_freeze();
> +		/* If no reclaim progress then increase scanning priority */
> +		if (sc.nr_reclaimed - nr_reclaimed == 0)
> +			raise_priority = true;
>  
>  		/*
> -		 * Fragmentation may mean that the system cannot be
> -		 * rebalanced for high-order allocations in all zones.
> -		 * At this point, if nr_reclaimed < SWAP_CLUSTER_MAX,
> -		 * it means the zones have been fully scanned and are still
> -		 * not balanced. For high-order allocations, there is
> -		 * little point trying all over again as kswapd may
> -		 * infinite loop.
> -		 *
> -		 * Instead, recheck all watermarks at order-0 as they
> -		 * are the most important. If watermarks are ok, kswapd will go
> -		 * back to sleep. High-order users can still perform direct
> -		 * reclaim if they wish.
> +		 * Raise priority if scanning rate is too low or there was no
> +		 * progress in reclaiming pages
>  		 */
> -		if (sc.nr_reclaimed < SWAP_CLUSTER_MAX)
> -			order = sc.order = 0;
> -
> -		goto loop_again;
> -	}
> +		if (raise_priority || sc.nr_reclaimed - nr_reclaimed == 0)

(sc.nr_reclaimed - nr_reclaimed == 0) is redundant because you already
set raise_priority above in that case.

> +			sc.priority--;
> +	} while (sc.priority >= 0 &&
> +		 !pgdat_balanced(pgdat, order, *classzone_idx));
>  
>  	/*
>  	 * If kswapd was reclaiming at a higher order, it has the option of
> @@ -2907,6 +2904,7 @@ out:
>  			compact_pgdat(pgdat, order);
>  	}
>  
> +out:
>  	/*
>  	 * Return the order we were reclaiming at so prepare_kswapd_sleep()
>  	 * makes a decision on the order we were last reclaiming at. However,

It looks OK otherwise but I have to think some more as balance_pgdat is
still tricky, albeit less then it was before so this is definitely
progress.

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
