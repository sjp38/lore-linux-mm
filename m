Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id A15106B0069
	for <linux-mm@kvack.org>; Tue, 10 Jan 2017 18:56:54 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id f144so234150267pfa.3
        for <linux-mm@kvack.org>; Tue, 10 Jan 2017 15:56:54 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id r7si3698692pgf.303.2017.01.10.15.56.53
        for <linux-mm@kvack.org>;
        Tue, 10 Jan 2017 15:56:53 -0800 (PST)
Date: Wed, 11 Jan 2017 08:56:51 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [RFC PATCH 2/2] mm, vmscan: cleanup inactive_list_is_low
Message-ID: <20170110235651.GB7130@bbox>
References: <20170110125552.4170-1-mhocko@kernel.org>
 <20170110125552.4170-3-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170110125552.4170-3-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>

Hi Michal,

On Tue, Jan 10, 2017 at 01:55:52PM +0100, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> inactive_list_is_low is duplicating logic implemented by
> lruvec_lru_size_eligibe_zones. Let's use the dedicated function to get
> the number of eligible pages on the lru list and ask use lruvec_lru_size
> to get the total LRU lize only when the tracing is really requested. We
> are still iterating over all LRUs two times in that case but a)
> inactive_list_is_low is not a hot path and b) this can be addressed at
> the tracing layer and only evaluate arguments only when the tracing is
> enabled in future if that ever matters.

Make sense so I was about to add my acked-by but surprised when I found
"bool trace variable" and lruvec_lru_size in the trace so I ask some
questions to the "+ mm-vmscan-add-mm_vmscan_inactive_list_is_low-tracepoint"
thread.

Except that part, looks good to me.

> 
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---
>  mm/vmscan.c | 38 ++++++++++----------------------------
>  1 file changed, 10 insertions(+), 28 deletions(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 137bc85067d3..a9c881f06c0e 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2054,11 +2054,10 @@ static bool inactive_list_is_low(struct lruvec *lruvec, bool file,
>  						struct scan_control *sc, bool trace)
>  {
>  	unsigned long inactive_ratio;
> -	unsigned long total_inactive, inactive;
> -	unsigned long total_active, active;
> +	unsigned long inactive, active;
> +	enum lru_list inactive_lru = file * LRU_FILE;
> +	enum lru_list active_lru = file * LRU_FILE + LRU_ACTIVE;
>  	unsigned long gb;
> -	struct pglist_data *pgdat = lruvec_pgdat(lruvec);
> -	int zid;
>  
>  	/*
>  	 * If we don't have swap space, anonymous page deactivation
> @@ -2067,27 +2066,8 @@ static bool inactive_list_is_low(struct lruvec *lruvec, bool file,
>  	if (!file && !total_swap_pages)
>  		return false;
>  
> -	total_inactive = inactive = lruvec_lru_size(lruvec, file * LRU_FILE);
> -	total_active = active = lruvec_lru_size(lruvec, file * LRU_FILE + LRU_ACTIVE);
> -
> -	/*
> -	 * For zone-constrained allocations, it is necessary to check if
> -	 * deactivations are required for lowmem to be reclaimed. This
> -	 * calculates the inactive/active pages available in eligible zones.
> -	 */
> -	for (zid = sc->reclaim_idx + 1; zid < MAX_NR_ZONES; zid++) {
> -		struct zone *zone = &pgdat->node_zones[zid];
> -		unsigned long inactive_zone, active_zone;
> -
> -		if (!managed_zone(zone))
> -			continue;
> -
> -		inactive_zone = lruvec_zone_lru_size(lruvec, file * LRU_FILE, zid);
> -		active_zone = lruvec_zone_lru_size(lruvec, (file * LRU_FILE) + LRU_ACTIVE, zid);
> -
> -		inactive -= min(inactive, inactive_zone);
> -		active -= min(active, active_zone);
> -	}
> +	inactive = lruvec_lru_size_eligibe_zones(lruvec, inactive_lru, sc->reclaim_idx);
> +	active = lruvec_lru_size_eligibe_zones(lruvec, active_lru, sc->reclaim_idx);
>  
>  	gb = (inactive + active) >> (30 - PAGE_SHIFT);
>  	if (gb)
> @@ -2096,10 +2076,12 @@ static bool inactive_list_is_low(struct lruvec *lruvec, bool file,
>  		inactive_ratio = 1;
>  
>  	if (trace)
> -		trace_mm_vmscan_inactive_list_is_low(pgdat->node_id,
> +		trace_mm_vmscan_inactive_list_is_low(lruvec_pgdat(lruvec)->node_id,
>  				sc->reclaim_idx,
> -				total_inactive, inactive,
> -				total_active, active, inactive_ratio, file);
> +				lruvec_lru_size(lruvec, inactive_lru), inactive,
> +				lruvec_lru_size(lruvec, active_lru), active,
> +				inactive_ratio, file);
> +
>  	return inactive * inactive_ratio < active;
>  }
>  
> -- 
> 2.11.0
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
