Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f177.google.com (mail-we0-f177.google.com [74.125.82.177])
	by kanga.kvack.org (Postfix) with ESMTP id 8E7AC6B0062
	for <linux-mm@kvack.org>; Mon, 23 Jun 2014 09:32:27 -0400 (EDT)
Received: by mail-we0-f177.google.com with SMTP id u56so7076052wes.36
        for <linux-mm@kvack.org>; Mon, 23 Jun 2014 06:32:26 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id bu13si16714921wib.101.2014.06.23.06.32.24
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 23 Jun 2014 06:32:25 -0700 (PDT)
Date: Mon, 23 Jun 2014 14:32:21 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [patch 3/4] mm: vmscan: remove all_unreclaimable()
Message-ID: <20140623133221.GN10819@suse.de>
References: <1403282030-29915-1-git-send-email-hannes@cmpxchg.org>
 <1403282030-29915-3-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1403282030-29915-3-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Jun 20, 2014 at 12:33:49PM -0400, Johannes Weiner wrote:
> Direct reclaim currently calls shrink_zones() to reclaim all members
> of a zonelist, and if that wasn't successful it does another pass
> through the same zonelist to check overall reclaimability.
> 
> Just check reclaimability in shrink_zones() directly and propagate the
> result through the return value.  Then remove all_unreclaimable().
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> ---
>  mm/vmscan.c | 48 +++++++++++++++++++++++-------------------------
>  1 file changed, 23 insertions(+), 25 deletions(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index ed1efb84c542..d0bc1a209746 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2244,9 +2244,10 @@ static inline bool should_continue_reclaim(struct zone *zone,
>  	}
>  }
>  
> -static void shrink_zone(struct zone *zone, struct scan_control *sc)
> +static unsigned long shrink_zone(struct zone *zone, struct scan_control *sc)
>  {
>  	unsigned long nr_reclaimed, nr_scanned;
> +	unsigned long zone_reclaimed = 0;
>  
>  	do {
>  		struct mem_cgroup *root = sc->target_mem_cgroup;
> @@ -2290,8 +2291,12 @@ static void shrink_zone(struct zone *zone, struct scan_control *sc)
>  			   sc->nr_scanned - nr_scanned,
>  			   sc->nr_reclaimed - nr_reclaimed);
>  
> +		zone_reclaimed += sc->nr_reclaimed - nr_reclaimed;
> +
>  	} while (should_continue_reclaim(zone, sc->nr_reclaimed - nr_reclaimed,
>  					 sc->nr_scanned - nr_scanned, sc));
> +
> +	return zone_reclaimed;
>  }

You do not actually need a counter here because all that matters is that
a page got reclaimed. It could just as easily have been

bool zone_reclaimable = false;

...

if (sc->nr_reclaimed - nr_reclaimed)
	zone_reclaimable = true;

...

return zone_reclaimable

so that zone[s]_reclaimable is always a boolean and not sometimes a boolean
and sometimes a counter.


>  
>  /* Returns true if compaction should go ahead for a high-order request */
> @@ -2340,8 +2345,10 @@ static inline bool compaction_ready(struct zone *zone, int order)
>   *
>   * If a zone is deemed to be full of pinned pages then just give it a light
>   * scan then give up on it.
> + *
> + * Returns whether the zones overall are reclaimable or not.
>   */

Returns true if a zone was reclaimable

> -static void shrink_zones(struct zonelist *zonelist, struct scan_control *sc)
> +static bool shrink_zones(struct zonelist *zonelist, struct scan_control *sc)
>  {
>  	struct zoneref *z;
>  	struct zone *zone;
> @@ -2354,6 +2361,7 @@ static void shrink_zones(struct zonelist *zonelist, struct scan_control *sc)
>  		.gfp_mask = sc->gfp_mask,
>  	};
>  	enum zone_type requested_highidx = gfp_zone(sc->gfp_mask);
> +	bool all_unreclaimable = true;
>  
>  	/*
>  	 * If the number of buffer_heads in the machine exceeds the maximum
> @@ -2368,6 +2376,8 @@ static void shrink_zones(struct zonelist *zonelist, struct scan_control *sc)
>  
>  	for_each_zone_zonelist_nodemask(zone, z, zonelist,
>  					gfp_zone(sc->gfp_mask), sc->nodemask) {
> +		unsigned long zone_reclaimed = 0;
> +
>  		if (!populated_zone(zone))
>  			continue;
>  		/*
> @@ -2414,10 +2424,15 @@ static void shrink_zones(struct zonelist *zonelist, struct scan_control *sc)
>  						&nr_soft_scanned);
>  			sc->nr_reclaimed += nr_soft_reclaimed;
>  			sc->nr_scanned += nr_soft_scanned;
> +			zone_reclaimed += nr_soft_reclaimed;
>  			/* need some check for avoid more shrink_zone() */
>  		}
>  
> -		shrink_zone(zone, sc);
> +		zone_reclaimed += shrink_zone(zone, sc);
> +
> +		if (zone_reclaimed ||
> +		    (global_reclaim(sc) && zone_reclaimable(zone)))
> +			all_unreclaimable = false;
>  	}
>  

This is where you don't need the counter as such. It could just as
easily have been

bool reclaimable = false;
....
if (shrink_zone(zone, sc))
	reclaimable = true;

if (!reclaimable && global_reclaim(sc) && zone_reclaimable(zone))
	reclaimable = true;

return reclaimable;

It doesn't matter as such, it's just zone_reclaimed is implemented as a
counter but not used as one.

>  	/*
> @@ -2439,26 +2454,8 @@ static void shrink_zones(struct zonelist *zonelist, struct scan_control *sc)
>  	 * promoted it to __GFP_HIGHMEM.
>  	 */
>  	sc->gfp_mask = orig_mask;
> -}
>  
> -/* All zones in zonelist are unreclaimable? */
> -static bool all_unreclaimable(struct zonelist *zonelist,
> -		struct scan_control *sc)
> -{
> -	struct zoneref *z;
> -	struct zone *zone;
> -
> -	for_each_zone_zonelist_nodemask(zone, z, zonelist,
> -			gfp_zone(sc->gfp_mask), sc->nodemask) {
> -		if (!populated_zone(zone))
> -			continue;
> -		if (!cpuset_zone_allowed_hardwall(zone, GFP_KERNEL))
> -			continue;
> -		if (zone_reclaimable(zone))
> -			return false;
> -	}
> -
> -	return true;
> +	return !all_unreclaimable;
>  }
>  
>  /*
> @@ -2482,6 +2479,7 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
>  {
>  	unsigned long total_scanned = 0;
>  	unsigned long writeback_threshold;
> +	bool zones_reclaimable;
>  
>  	delayacct_freepages_start();
>  
> @@ -2492,7 +2490,7 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
>  		vmpressure_prio(sc->gfp_mask, sc->target_mem_cgroup,
>  				sc->priority);
>  		sc->nr_scanned = 0;
> -		shrink_zones(zonelist, sc);
> +		zones_reclaimable = shrink_zones(zonelist, sc);
>  
>  		total_scanned += sc->nr_scanned;
>  		if (sc->nr_reclaimed >= sc->nr_to_reclaim)
> @@ -2533,8 +2531,8 @@ out:
>  	if (sc->compaction_ready)
>  		return 1;
>  
> -	/* top priority shrink_zones still had more to do? don't OOM, then */
> -	if (global_reclaim(sc) && !all_unreclaimable(zonelist, sc))
> +	/* Any of the zones still reclaimable?  Don't OOM. */
> +	if (zones_reclaimable)
>  		return 1;
>  
>  	return 0;
> -- 
> 2.0.0
> 

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
