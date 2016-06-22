Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id C32D66B0005
	for <linux-mm@kvack.org>; Wed, 22 Jun 2016 04:42:22 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id d132so14156215oig.0
        for <linux-mm@kvack.org>; Wed, 22 Jun 2016 01:42:22 -0700 (PDT)
Received: from out4435.biz.mail.alibaba.com (out4435.biz.mail.alibaba.com. [47.88.44.35])
        by mx.google.com with ESMTP id n5si47107903ioo.185.2016.06.22.01.42.20
        for <linux-mm@kvack.org>;
        Wed, 22 Jun 2016 01:42:21 -0700 (PDT)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <071801d1cc5c$245087d0$6cf19770$@alibaba-inc.com>
In-Reply-To: <071801d1cc5c$245087d0$6cf19770$@alibaba-inc.com>
Subject: Re: [PATCH 06/27] mm, vmscan: Make kswapd reclaim in terms of nodes
Date: Wed, 22 Jun 2016 16:42:06 +0800
Message-ID: <072501d1cc61$f51a2380$df4e6a80$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

>  /*
> - * kswapd shrinks the zone by the number of pages required to reach
> - * the high watermark.
> + * kswapd shrinks a node of pages that are at or below the highest usable
> + * zone that is currently unbalanced.
>   *
>   * Returns true if kswapd scanned at least the requested number of pages to
>   * reclaim or if the lack of progress was due to pages under writeback.
>   * This is used to determine if the scanning priority needs to be raised.
>   */
> -static bool kswapd_shrink_zone(struct zone *zone,
> +static bool kswapd_shrink_node(pg_data_t *pgdat,
>  			       int classzone_idx,
>  			       struct scan_control *sc)
>  {
> -	unsigned long balance_gap;
> -	bool lowmem_pressure;
> -	struct pglist_data *pgdat = zone->zone_pgdat;
> +	struct zone *zone;
> +	int z;
> 
> -	/* Reclaim above the high watermark. */
> -	sc->nr_to_reclaim = max(SWAP_CLUSTER_MAX, high_wmark_pages(zone));
> +	/* Reclaim a number of pages proportional to the number of zones */
> +	sc->nr_to_reclaim = 0;
> +	for (z = 0; z <= classzone_idx; z++) {
> +		zone = pgdat->node_zones + z;
> +		if (!populated_zone(zone))
> +			continue;
> 
> -	/*
> -	 * We put equal pressure on every zone, unless one zone has way too
> -	 * many pages free already. The "too many pages" is defined as the
> -	 * high wmark plus a "gap" where the gap is either the low
> -	 * watermark or 1% of the zone, whichever is smaller.
> -	 */
> -	balance_gap = min(low_wmark_pages(zone), DIV_ROUND_UP(
> -			zone->managed_pages, KSWAPD_ZONE_BALANCE_GAP_RATIO));
> +		sc->nr_to_reclaim += max(high_wmark_pages(zone), SWAP_CLUSTER_MAX);
> +	}
> 
>  	/*
> -	 * If there is no low memory pressure or the zone is balanced then no
> -	 * reclaim is necessary
> +	 * Historically care was taken to put equal pressure on all zones but
> +	 * now pressure is applied based on node LRU order.
>  	 */
> -	lowmem_pressure = (buffer_heads_over_limit && is_highmem(zone));
> -	if (!lowmem_pressure && zone_balanced(zone, sc->order, false,
> -						balance_gap, classzone_idx))
> -		return true;
> -
> -	shrink_node(zone->zone_pgdat, sc, classzone_idx);
> -
> -	/* TODO: ANOMALY */
> -	clear_bit(PGDAT_WRITEBACK, &pgdat->flags);
> +	shrink_node(pgdat, sc, classzone_idx);
> 
>  	/*
> -	 * If a zone reaches its high watermark, consider it to be no longer
> -	 * congested. It's possible there are dirty pages backed by congested
> -	 * BDIs but as pressure is relieved, speculatively avoid congestion
> -	 * waits.
> +	 * Fragmentation may mean that the system cannot be rebalanced for
> +	 * high-order allocations. If twice the allocation size has been
> +	 * reclaimed then recheck watermarks only at order-0 to prevent
> +	 * excessive reclaim. Assume that a process requested a high-order
> +	 * can direct reclaim/compact.
>  	 */
> -	if (pgdat_reclaimable(zone->zone_pgdat) &&
> -	    zone_balanced(zone, sc->order, false, 0, classzone_idx)) {
> -		clear_bit(PGDAT_CONGESTED, &pgdat->flags);
> -		clear_bit(PGDAT_DIRTY, &pgdat->flags);
> -	}
> +	if (sc->order && sc->nr_reclaimed >= 2UL << sc->order)
> +		sc->order = 0;
> 

Reclaim order is changed here.
Btw, I find no such change in current code.

>  	return sc->nr_scanned >= sc->nr_to_reclaim;
>  }
> 
>  /*
> - * For kswapd, balance_pgdat() will work across all this node's zones until
> - * they are all at high_wmark_pages(zone).
> - *
> - * Returns the highest zone idx kswapd was reclaiming at
> + * For kswapd, balance_pgdat() will reclaim pages across a node from zones
> + * that are eligible for use by the caller until at least one zone is
> + * balanced.
>   *
> - * There is special handling here for zones which are full of pinned pages.
> - * This can happen if the pages are all mlocked, or if they are all used by
> - * device drivers (say, ZONE_DMA).  Or if they are all in use by hugetlb.
> - * What we do is to detect the case where all pages in the zone have been
> - * scanned twice and there has been zero successful reclaim.  Mark the zone as
> - * dead and from now on, only perform a short scan.  Basically we're polling
> - * the zone for when the problem goes away.
> + * Returns the order kswapd finished reclaiming at.
>   *
>   * kswapd scans the zones in the highmem->normal->dma direction.  It skips
>   * zones which have free_pages > high_wmark_pages(zone), but once a zone is
> - * found to have free_pages <= high_wmark_pages(zone), we scan that zone and the
> - * lower zones regardless of the number of free pages in the lower zones. This
> - * interoperates with the page allocator fallback scheme to ensure that aging
> - * of pages is balanced across the zones.
> + * found to have free_pages <= high_wmark_pages(zone), any page is that zone
> + * or lower is eligible for reclaim until at least one usable zone is
> + * balanced.
>   */
>  static int balance_pgdat(pg_data_t *pgdat, int order, int classzone_idx)
>  {
>  	int i;
> -	int end_zone = 0;	/* Inclusive.  0 = ZONE_DMA */
>  	unsigned long nr_soft_reclaimed;
>  	unsigned long nr_soft_scanned;
> +	struct zone *zone;
>  	struct scan_control sc = {
>  		.gfp_mask = GFP_KERNEL,
> -		.reclaim_idx = MAX_NR_ZONES - 1,
>  		.order = order,
>  		.priority = DEF_PRIORITY,
>  		.may_writepage = !laptop_mode,
>  		.may_unmap = 1,
>  		.may_swap = 1,
> +		.reclaim_idx = classzone_idx,
>  	};
>  	count_vm_event(PAGEOUTRUN);
> 
> @@ -3203,21 +3125,10 @@ static int balance_pgdat(pg_data_t *pgdat, int order, int classzone_idx)
> 
>  		/* Scan from the highest requested zone to dma */
>  		for (i = classzone_idx; i >= 0; i--) {
> -			struct zone *zone = pgdat->node_zones + i;
> -
> +			zone = pgdat->node_zones + i;
>  			if (!populated_zone(zone))
>  				continue;
> 
> -			if (sc.priority != DEF_PRIORITY &&
> -			    !pgdat_reclaimable(zone->zone_pgdat))
> -				continue;
> -
> -			/*
> -			 * Do some background aging of the anon list, to give
> -			 * pages a chance to be referenced before reclaiming.
> -			 */
> -			age_active_anon(zone, &sc);
> -
>  			/*
>  			 * If the number of buffer_heads in the machine
>  			 * exceeds the maximum allowed level and this node
> @@ -3225,19 +3136,17 @@ static int balance_pgdat(pg_data_t *pgdat, int order, int classzone_idx)
>  			 * it to relieve lowmem pressure.
>  			 */
>  			if (buffer_heads_over_limit && is_highmem_idx(i)) {
> -				end_zone = i;
> +				classzone_idx = i;
>  				break;
>  			}
> 
> -			if (!zone_balanced(zone, order, false, 0, 0)) {
> -				end_zone = i;
> +			if (!zone_balanced(zone, order, 0, 0)) {

We need to sync order with the above change?

> +				classzone_idx = i;
>  				break;
>  			} else {
>  				/*
> -				 * If balanced, clear the dirty and congested
> -				 * flags
> -				 *
> -				 * TODO: ANOMALY
> +				 * If any eligible zone is balanced then the
> +				 * node is not considered congested or dirty.
>  				 */
>  				clear_bit(PGDAT_CONGESTED, &zone->zone_pgdat->flags);
>  				clear_bit(PGDAT_DIRTY, &zone->zone_pgdat->flags);
> @@ -3248,51 +3157,34 @@ static int balance_pgdat(pg_data_t *pgdat, int order, int classzone_idx)
>  			goto out;
> 
>  		/*
> +		 * Do some background aging of the anon list, to give
> +		 * pages a chance to be referenced before reclaiming. All
> +		 * pages are rotated regardless of classzone as this is
> +		 * about consistent aging.
> +		 */
> +		age_active_anon(pgdat, &pgdat->node_zones[MAX_NR_ZONES - 1], &sc);
> +
> +		/*
>  		 * If we're getting trouble reclaiming, start doing writepage
>  		 * even in laptop mode.
>  		 */
> -		if (sc.priority < DEF_PRIORITY - 2)
> +		if (sc.priority < DEF_PRIORITY - 2 || !pgdat_reclaimable(pgdat))
>  			sc.may_writepage = 1;
> 
> +		/* Call soft limit reclaim before calling shrink_node. */
> +		sc.nr_scanned = 0;
> +		nr_soft_scanned = 0;
> +		nr_soft_reclaimed = mem_cgroup_soft_limit_reclaim(zone, sc.order,
> +						sc.gfp_mask, &nr_soft_scanned);
> +		sc.nr_reclaimed += nr_soft_reclaimed;
> +
>  		/*
> -		 * Continue scanning in the highmem->dma direction stopping at
> -		 * the last zone which needs scanning. This may reclaim lowmem
> -		 * pages that are not necessary for zone balancing but it
> -		 * preserves LRU ordering. It is assumed that the bulk of
> -		 * allocation requests can use arbitrary zones with the
> -		 * possible exception of big highmem:lowmem configurations.
> +		 * There should be no need to raise the scanning priority if
> +		 * enough pages are already being scanned that that high
> +		 * watermark would be met at 100% efficiency.
>  		 */
> -		for (i = end_zone; i >= 0; i--) {
> -			struct zone *zone = pgdat->node_zones + i;
> -
> -			if (!populated_zone(zone))
> -				continue;
> -
> -			if (sc.priority != DEF_PRIORITY &&
> -			    !pgdat_reclaimable(zone->zone_pgdat))
> -				continue;
> -
> -			sc.nr_scanned = 0;
> -			sc.reclaim_idx = i;
> -
> -			nr_soft_scanned = 0;
> -			/*
> -			 * Call soft limit reclaim before calling shrink_zone.
> -			 */
> -			nr_soft_reclaimed = mem_cgroup_soft_limit_reclaim(zone,
> -							order, sc.gfp_mask,
> -							&nr_soft_scanned);
> -			sc.nr_reclaimed += nr_soft_reclaimed;
> -
> -			/*
> -			 * There should be no need to raise the scanning
> -			 * priority if enough pages are already being scanned
> -			 * that that high watermark would be met at 100%
> -			 * efficiency.
> -			 */
> -			if (kswapd_shrink_zone(zone, end_zone, &sc))
> -				raise_priority = false;
> -		}
> +		if (kswapd_shrink_node(pgdat, classzone_idx, &sc))
> +			raise_priority = false;
> 
>  		/*
>  		 * If the low watermark is met there is no need for processes
> @@ -3308,20 +3200,37 @@ static int balance_pgdat(pg_data_t *pgdat, int order, int classzone_idx)
>  			break;
> 
>  		/*
> +		 * Stop reclaiming if any eligible zone is balanced and clear
> +		 * node writeback or congested.
> +		 */
> +		for (i = 0; i <= classzone_idx; i++) {
> +			zone = pgdat->node_zones + i;
> +			if (!populated_zone(zone))
> +				continue;
> +
> +			if (zone_balanced(zone, sc.order, 0, classzone_idx)) {
> +				clear_bit(PGDAT_CONGESTED, &pgdat->flags);
> +				clear_bit(PGDAT_DIRTY, &pgdat->flags);
> +				goto out;
> +			}
> +		}
> +
> +		/*
>  		 * Raise priority if scanning rate is too low or there was no
>  		 * progress in reclaiming pages
>  		 */
>  		if (raise_priority || !sc.nr_reclaimed)
>  			sc.priority--;
> -	} while (sc.priority >= 1 &&
> -			!pgdat_balanced(pgdat, order, classzone_idx));
> +	} while (sc.priority >= 1);
> 
>  out:
>  	/*
> -	 * Return the highest zone idx we were reclaiming at so
> -	 * prepare_kswapd_sleep() makes the same decisions as here.
> +	 * Return the order kswapd stopped reclaiming at as
> +	 * prepare_kswapd_sleep() takes it into account. If another caller
> +	 * entered the allocator slow path while kswapd was awake, order will
> +	 * remain at the higher level.
>  	 */
> -	return end_zone;
> +	return sc.order;
>  }
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
