Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id 605236B0035
	for <linux-mm@kvack.org>; Mon, 23 Jun 2014 04:35:49 -0400 (EDT)
Received: by mail-wi0-f170.google.com with SMTP id cc10so3748253wib.5
        for <linux-mm@kvack.org>; Mon, 23 Jun 2014 01:35:48 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id kq9si22172021wjc.136.2014.06.23.01.35.47
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 23 Jun 2014 01:35:47 -0700 (PDT)
Date: Mon, 23 Jun 2014 10:35:44 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 3/4] mm: vmscan: remove all_unreclaimable()
Message-ID: <20140623083544.GC9743@dhcp22.suse.cz>
References: <1403282030-29915-1-git-send-email-hannes@cmpxchg.org>
 <1403282030-29915-3-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1403282030-29915-3-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri 20-06-14 12:33:49, Johannes Weiner wrote:
> Direct reclaim currently calls shrink_zones() to reclaim all members
> of a zonelist, and if that wasn't successful it does another pass
> through the same zonelist to check overall reclaimability.
> 
> Just check reclaimability in shrink_zones() directly and propagate the
> result through the return value.  Then remove all_unreclaimable().

Heh, I was really looking for the return value and abuse it for the
memcg low/min reclaim purposes. I will find a way...

> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: Michal Hocko <mhocko@suse.cz>

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
>  
>  /* Returns true if compaction should go ahead for a high-order request */
> @@ -2340,8 +2345,10 @@ static inline bool compaction_ready(struct zone *zone, int order)
>   *
>   * If a zone is deemed to be full of pinned pages then just give it a light
>   * scan then give up on it.
> + *
> + * Returns whether the zones overall are reclaimable or not.
>   */
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
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
