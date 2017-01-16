Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 283BC6B0033
	for <linux-mm@kvack.org>; Mon, 16 Jan 2017 11:01:31 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id p192so28779342wme.1
        for <linux-mm@kvack.org>; Mon, 16 Jan 2017 08:01:31 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id o79si12915181wme.32.2017.01.16.08.01.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Jan 2017 08:01:29 -0800 (PST)
Date: Mon, 16 Jan 2017 11:01:23 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [RFC PATCH 1/2] mm, vmscan: consider eligible zones in
 get_scan_count
Message-ID: <20170116160123.GB30300@cmpxchg.org>
References: <20170110125552.4170-1-mhocko@kernel.org>
 <20170110125552.4170-2-mhocko@kernel.org>
 <20170114161236.GB26139@cmpxchg.org>
 <20170116092956.GC13641@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170116092956.GC13641@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>

On Mon, Jan 16, 2017 at 10:29:56AM +0100, Michal Hocko wrote:
> From 39824aac7504b38f943a80b7d98ec4e87a5607a7 Mon Sep 17 00:00:00 2001
> From: Michal Hocko <mhocko@suse.com>
> Date: Tue, 27 Dec 2016 16:28:44 +0100
> Subject: [PATCH] mm, vmscan: consider eligible zones in get_scan_count
> 
> get_scan_count considers the whole node LRU size when
> - doing SCAN_FILE due to many page cache inactive pages
> - calculating the number of pages to scan
> 
> in both cases this might lead to unexpected behavior especially on 32b
> systems where we can expect lowmem memory pressure very often.
> 
> A large highmem zone can easily distort SCAN_FILE heuristic because
> there might be only few file pages from the eligible zones on the node
> lru and we would still enforce file lru scanning which can lead to
> trashing while we could still scan anonymous pages.
> 
> The later use of lruvec_lru_size can be problematic as well. Especially
> when there are not many pages from the eligible zones. We would have to
> skip over many pages to find anything to reclaim but shrink_node_memcg
> would only reduce the remaining number to scan by SWAP_CLUSTER_MAX
> at maximum. Therefore we can end up going over a large LRU many times
> without actually having chance to reclaim much if anything at all. The
> closer we are out of memory on lowmem zone the worse the problem will
> be.
> 
> Fix this by making lruvec_lru_size zone aware. zone_idx will tell the
> the maximum eligible zone.
> 
> Changes since v2
> - move the zone filtering logic to lruvec_lru_size so that we do not
>   have too many lruvec_lru_size* functions - Johannes
> 
> Changes since v1
> - s@lruvec_lru_size_zone_idx@lruvec_lru_size_eligibe_zones@
> 
> Acked-by: Minchan Kim <minchan@kernel.org>
> Signed-off-by: Michal Hocko <mhocko@suse.com>

Thanks, that looks better IMO. Two tiny things:

> @@ -234,22 +234,44 @@ bool pgdat_reclaimable(struct pglist_data *pgdat)
>  		pgdat_reclaimable_pages(pgdat) * 6;
>  }
>  
> -unsigned long lruvec_lru_size(struct lruvec *lruvec, enum lru_list lru)
> +static unsigned long lruvec_zone_lru_size(struct lruvec *lruvec,
> +		enum lru_list lru, int zone_idx)
>  {
>  	if (!mem_cgroup_disabled())
> -		return mem_cgroup_get_lru_size(lruvec, lru);
> +		return mem_cgroup_get_zone_lru_size(lruvec, lru, zone_idx);
>  
> -	return node_page_state(lruvec_pgdat(lruvec), NR_LRU_BASE + lru);
> +	return zone_page_state(&lruvec_pgdat(lruvec)->node_zones[zone_idx],
> +			       NR_ZONE_LRU_BASE + lru);
>  }
>  
> -unsigned long lruvec_zone_lru_size(struct lruvec *lruvec, enum lru_list lru,
> -				   int zone_idx)
> +/** lruvec_lru_size -  Returns the number of pages on the given LRU list.
> + * @lruvec: lru vector
> + * @lru: lru to use
> + * @zone_idx: zones to consider (use MAX_NR_ZONES for the whole LRU list)
> + */
> +unsigned long lruvec_lru_size(struct lruvec *lruvec, enum lru_list lru, int zone_idx)
>  {
> +	unsigned long lru_size;
> +	int zid;
> +
>  	if (!mem_cgroup_disabled())
> -		return mem_cgroup_get_zone_lru_size(lruvec, lru, zone_idx);
> +		lru_size = mem_cgroup_get_lru_size(lruvec, lru);
> +	else
> +		lru_size = node_page_state(lruvec_pgdat(lruvec), NR_LRU_BASE + lru);
> +
> +	for (zid = zone_idx + 1; zid < MAX_NR_ZONES; zid++) {
> +		struct zone *zone = &lruvec_pgdat(lruvec)->node_zones[zid];
> +		unsigned long size;
> +
> +		if (!managed_zone(zone))
> +			continue;
> +
> +		size = lruvec_zone_lru_size(lruvec, lru, zid);
> +		lru_size -= min(size, lru_size);

Fold lruvec_zone_lru_size() in here? Its body goes well with how we
get lru_size at the start of the function, no need to maintain that
abstraction.

> @@ -2064,8 +2086,8 @@ static bool inactive_list_is_low(struct lruvec *lruvec, bool file,
>  	if (!file && !total_swap_pages)
>  		return false;
>  
> -	total_inactive = inactive = lruvec_lru_size(lruvec, file * LRU_FILE);
> -	total_active = active = lruvec_lru_size(lruvec, file * LRU_FILE + LRU_ACTIVE);
> +	total_inactive = inactive = lruvec_lru_size(lruvec, file * LRU_FILE, MAX_NR_ZONES);
> +	total_active = active = lruvec_lru_size(lruvec, file * LRU_FILE + LRU_ACTIVE, MAX_NR_ZONES);
>  
>  	/*
>  	 * For zone-constrained allocations, it is necessary to check if

It might be a better patch order to do the refactoring of the zone
filtering from inactive_list_is_low() to lruvec_lru_size() in 1/2,
without change of behavior; then update the other callers in 2/2.

Hm?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
