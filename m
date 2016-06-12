Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 813676B0005
	for <linux-mm@kvack.org>; Sun, 12 Jun 2016 05:33:29 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id z189so57147931itg.2
        for <linux-mm@kvack.org>; Sun, 12 Jun 2016 02:33:29 -0700 (PDT)
Received: from out4133-82.mail.aliyun.com (out4133-82.mail.aliyun.com. [42.120.133.82])
        by mx.google.com with ESMTP id c74si20346642ioe.176.2016.06.12.02.33.27
        for <linux-mm@kvack.org>;
        Sun, 12 Jun 2016 02:33:28 -0700 (PDT)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <02fe01d1c48b$c44e9e80$4cebdb80$@alibaba-inc.com>
In-Reply-To: <02fe01d1c48b$c44e9e80$4cebdb80$@alibaba-inc.com>
Subject: Re: [PATCH 06/27] mm, vmscan: Make kswapd reclaim in terms of nodes
Date: Sun, 12 Jun 2016 17:33:24 +0800
Message-ID: <02ff01d1c48d$78112f40$68338dc0$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

> 
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
> +	unsigned long nr_to_reclaim = 0;
> +	int z;
> 
> -	/* Reclaim above the high watermark. */
> -	sc->nr_to_reclaim = max(SWAP_CLUSTER_MAX, high_wmark_pages(zone));
> +	/* Reclaim a number of pages proportional to the number of zones */
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
> +		nr_to_reclaim += max(high_wmark_pages(zone), SWAP_CLUSTER_MAX);
> +	}

Missing sc->nr_to_reclaim = nr_to_reclaim; ?

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
>  	return sc->nr_scanned >= sc->nr_to_reclaim;
>  }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
