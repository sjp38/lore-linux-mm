Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id 24CD76B0005
	for <linux-mm@kvack.org>; Mon, 18 Mar 2013 19:58:59 -0400 (EDT)
Received: by mail-da0-f49.google.com with SMTP id t11so1629053daj.22
        for <linux-mm@kvack.org>; Mon, 18 Mar 2013 16:58:58 -0700 (PDT)
Message-ID: <5147AA3B.9080807@gmail.com>
Date: Tue, 19 Mar 2013 07:58:51 +0800
From: Simon Jeons <simon.jeons@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH 03/10] mm: vmscan: Flatten kswapd priority loop
References: <1363525456-10448-1-git-send-email-mgorman@suse.de> <1363525456-10448-4-git-send-email-mgorman@suse.de>
In-Reply-To: <1363525456-10448-4-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linux-MM <linux-mm@kvack.org>, Jiri Slaby <jslaby@suse.cz>, Valdis Kletnieks <Valdis.Kletnieks@vt.edu>, Rik van Riel <riel@redhat.com>, Zlatko Calusic <zcalusic@bitsync.net>, Johannes Weiner <hannes@cmpxchg.org>, dormando <dormando@rydia.net>, Satoru Moriya <satoru.moriya@hds.com>, Michal Hocko <mhocko@suse.cz>, LKML <linux-kernel@vger.kernel.org>

Hi Mel,
On 03/17/2013 09:04 PM, Mel Gorman wrote:
> kswapd stops raising the scanning priority when at least SWAP_CLUSTER_MAX
> pages have been reclaimed or the pgdat is considered balanced. It then
> rechecks if it needs to restart at DEF_PRIORITY and whether high-order
> reclaim needs to be reset. This is not wrong per-se but it is confusing
> to follow and forcing kswapd to stay at DEF_PRIORITY may require several
> restarts before it has scanned enough pages to meet the high watermark even
> at 100% efficiency. This patch irons out the logic a bit by controlling
> when priority is raised and removing the "goto loop_again".
>
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
>   mm/vmscan.c | 86 ++++++++++++++++++++++++++++++-------------------------------
>   1 file changed, 42 insertions(+), 44 deletions(-)
>
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 182ff15..279d0c2 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2625,8 +2625,11 @@ static bool prepare_kswapd_sleep(pg_data_t *pgdat, int order, long remaining,
>   /*
>    * kswapd shrinks the zone by the number of pages required to reach
>    * the high watermark.
> + *
> + * Returns true if kswapd scanned at least the requested number of
> + * pages to reclaim.
>    */
> -static void kswapd_shrink_zone(struct zone *zone,
> +static bool kswapd_shrink_zone(struct zone *zone,
>   			       struct scan_control *sc,
>   			       unsigned long lru_pages)
>   {
> @@ -2646,6 +2649,8 @@ static void kswapd_shrink_zone(struct zone *zone,
>   
>   	if (nr_slab == 0 && !zone_reclaimable(zone))
>   		zone->all_unreclaimable = 1;
> +
> +	return sc->nr_scanned >= sc->nr_to_reclaim;
>   }
>   
>   /*
> @@ -2672,26 +2677,25 @@ static void kswapd_shrink_zone(struct zone *zone,
>   static unsigned long balance_pgdat(pg_data_t *pgdat, int order,
>   							int *classzone_idx)
>   {
> -	bool pgdat_is_balanced = false;
>   	int i;
>   	int end_zone = 0;	/* Inclusive.  0 = ZONE_DMA */
>   	unsigned long nr_soft_reclaimed;
>   	unsigned long nr_soft_scanned;
>   	struct scan_control sc = {
>   		.gfp_mask = GFP_KERNEL,
> +		.priority = DEF_PRIORITY,
>   		.may_unmap = 1,
>   		.may_swap = 1,
> +		.may_writepage = !laptop_mode,

What's the influence of this change? If there are large numbers of 
anonymous pages and very little file pages, anonymous pages will not be 
swapped out when priorty >= DEF_PRIORITY-2. Just no sense scan.
>   		.order = order,
>   		.target_mem_cgroup = NULL,
>   	};
> -loop_again:
> -	sc.priority = DEF_PRIORITY;
> -	sc.nr_reclaimed = 0;
> -	sc.may_writepage = !laptop_mode;
>   	count_vm_event(PAGEOUTRUN);
>   
>   	do {
>   		unsigned long lru_pages = 0;
> +		unsigned long nr_reclaimed = sc.nr_reclaimed;
> +		bool raise_priority = true;
>   
>   		/*
>   		 * Scan in the highmem->dma direction for the highest
> @@ -2733,10 +2737,8 @@ loop_again:
>   			}
>   		}
>   
> -		if (i < 0) {
> -			pgdat_is_balanced = true;
> +		if (i < 0)
>   			goto out;
> -		}
>   
>   		for (i = 0; i <= end_zone; i++) {
>   			struct zone *zone = pgdat->node_zones + i;
> @@ -2803,8 +2805,16 @@ loop_again:
>   
>   			if ((buffer_heads_over_limit && is_highmem_idx(i)) ||
>   			    !zone_balanced(zone, testorder,
> -					   balance_gap, end_zone))
> -				kswapd_shrink_zone(zone, &sc, lru_pages);
> +					   balance_gap, end_zone)) {
> +				/*
> +				 * There should be no need to raise the
> +				 * scanning priority if enough pages are
> +				 * already being scanned that that high
> +				 * watermark would be met at 100% efficiency.
> +				 */
> +				if (kswapd_shrink_zone(zone, &sc, lru_pages))
> +					raise_priority = false;
> +			}
>   
>   			/*
>   			 * If we're getting trouble reclaiming, start doing
> @@ -2839,46 +2849,33 @@ loop_again:
>   				pfmemalloc_watermark_ok(pgdat))
>   			wake_up(&pgdat->pfmemalloc_wait);
>   
> -		if (pgdat_balanced(pgdat, order, *classzone_idx)) {
> -			pgdat_is_balanced = true;
> -			break;		/* kswapd: all done */
> -		}
> -
>   		/*
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
>   		 */
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
>   		/*
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
>   		 */
> -		if (sc.nr_reclaimed < SWAP_CLUSTER_MAX)
> -			order = sc.order = 0;
> -
> -		goto loop_again;
> -	}
> +		if (raise_priority || sc.nr_reclaimed - nr_reclaimed == 0)
> +			sc.priority--;
> +	} while (sc.priority >= 0 &&
> +		 !pgdat_balanced(pgdat, order, *classzone_idx));
>   
>   	/*
>   	 * If kswapd was reclaiming at a higher order, it has the option of
> @@ -2907,6 +2904,7 @@ out:
>   			compact_pgdat(pgdat, order);
>   	}
>   
> +out:
>   	/*
>   	 * Return the order we were reclaiming at so prepare_kswapd_sleep()
>   	 * makes a decision on the order we were last reclaiming at. However,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
