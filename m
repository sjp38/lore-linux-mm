Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f46.google.com (mail-wg0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id B5B446B0031
	for <linux-mm@kvack.org>; Fri, 27 Jun 2014 14:57:07 -0400 (EDT)
Received: by mail-wg0-f46.google.com with SMTP id y10so5612986wgg.17
        for <linux-mm@kvack.org>; Fri, 27 Jun 2014 11:57:07 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id be4si15101490wjc.162.2014.06.27.11.57.05
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 27 Jun 2014 11:57:06 -0700 (PDT)
Date: Fri, 27 Jun 2014 14:57:00 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 4/5] mm: page_alloc: Reduce cost of the fair zone
 allocation policy
Message-ID: <20140627185700.GV7331@cmpxchg.org>
References: <1403856880-12597-1-git-send-email-mgorman@suse.de>
 <1403856880-12597-5-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1403856880-12597-5-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>

On Fri, Jun 27, 2014 at 09:14:39AM +0100, Mel Gorman wrote:
> The fair zone allocation policy round-robins allocations between zones
> within a node to avoid age inversion problems during reclaim. If the
> first allocation fails, the batch counts is reset and a second attempt
> made before entering the slow path.
> 
> One assumption made with this scheme is that batches expire at roughly the
> same time and the resets each time are justified. This assumption does not
> hold when zones reach their low watermark as the batches will be consumed
> at uneven rates.  Allocation failure due to watermark depletion result in
> additional zonelist scans for the reset and another watermark check before
> hitting the slowpath.
> 
> This patch makes a number of changes that should reduce the overall cost
> 
> o Do not apply the fair zone policy to small zones such as DMA
> o Abort the fair zone allocation policy once remote or small zones are
>   encountered
> o Use a simplier scan when resetting NR_ALLOC_BATCH
> o Use a simple flag to identify depleted zones instead of accessing a
>   potentially write-intensive cache line for counters
> o Track zones who met the watermark but failed the NR_ALLOC_BATCH check
>   to avoid doing a rescan of the zonelist when the counters are reset
> 
> On UMA machines, the effect is marginal. Even judging from system CPU
> usage it's small for the tiobench test
> 
>           3.16.0-rc2  3.16.0-rc2
>             checklow    fairzone
> User          396.24      396.23
> System        395.23      391.50
> Elapsed      5182.65     5165.49

The next patch reports fairzone at 5182.86 again, so I'm guessing this
patch is not actually reliably reducing the runtime to 5165.49, that's
just runtime variation.

> And the number of pages allocated from each zone is comparable
> 
>                             3.16.0-rc2  3.16.0-rc2
>                               checklow    fairzone
> DMA allocs                           0           0
> DMA32 allocs                   7374217     7920241
> Normal allocs                999277551   996568115

Wow, the DMA32 zone gets less than 1% of the allocations.  What are
the zone sizes in this machine?

> @@ -1908,6 +1912,20 @@ static bool zone_allows_reclaim(struct zone *local_zone, struct zone *zone)
>  
>  #endif	/* CONFIG_NUMA */
>  
> +static void reset_alloc_batches(struct zone *preferred_zone)
> +{
> +	struct zone *zone = preferred_zone->zone_pgdat->node_zones;
> +
> +	do {
> +		if (!zone_is_fair_depleted(zone))
> +			continue;
> +		mod_zone_page_state(zone, NR_ALLOC_BATCH,
> +			high_wmark_pages(zone) - low_wmark_pages(zone) -
> +			atomic_long_read(&zone->vm_stat[NR_ALLOC_BATCH]));
> +		zone_clear_flag(zone, ZONE_FAIR_DEPLETED);
> +	} while (zone++ != preferred_zone);

get_page_from_freelist() looks at the batches in zonelist order, why
reset them in node_zones order?  Sure they are the same for all the
cases we care about now, but it's a non-obvious cross-depedency...

Does this even make a measurable difference?  It's a slow path after
you fixed the excessive resets below.

> @@ -2073,8 +2093,25 @@ this_zone_full:
>  		 * for !PFMEMALLOC purposes.
>  		 */
>  		page->pfmemalloc = !!(alloc_flags & ALLOC_NO_WATERMARKS);
> +		return page;
> +	}
>  
> -	return page;
> +	if ((alloc_flags & ALLOC_FAIR) && nr_fair_skipped) {
> +		alloc_flags &= ~ALLOC_FAIR;
> +		zonelist_rescan = true;
> +		reset_alloc_batches(preferred_zone);
> +	}

Yes, it happens quite often that get_page_from_freelist() fails due to
watermarks while all the batches are fine, so resetting the batches
and rescanning the zonelist is kind of a waste of time.  However, in
this situation, we are waiting for kswapd to make progress on the
watermarks, and it doesn't really matter where we are wasting time...

In this micro benchmark that doesn't really do much besides allocating
and reclaiming IO-less cache pages, the performance difference is less
than 1% with this patch applied:

old: 19.835353264 seconds time elapsed                                          ( +-  0.39% )
new: 19.587258161 seconds time elapsed                                          ( +-  0.34% )

But overall I agree with this particular change.

> @@ -2748,33 +2763,18 @@ retry_cpuset:
>  		goto out;
>  	classzone_idx = zonelist_zone_idx(preferred_zoneref);
>  
> +	if (zonelist->fair_enabled)
> +		alloc_flags |= ALLOC_FAIR;
>  #ifdef CONFIG_CMA
>  	if (allocflags_to_migratetype(gfp_mask) == MIGRATE_MOVABLE)
>  		alloc_flags |= ALLOC_CMA;
>  #endif
> -retry:
>  	/* First allocation attempt */
>  	page = get_page_from_freelist(gfp_mask|__GFP_HARDWALL, nodemask, order,
>  			zonelist, high_zoneidx, alloc_flags,
>  			preferred_zone, classzone_idx, migratetype);
>  	if (unlikely(!page)) {
>  		/*
> -		 * The first pass makes sure allocations are spread
> -		 * fairly within the local node.  However, the local
> -		 * node might have free pages left after the fairness
> -		 * batches are exhausted, and remote zones haven't
> -		 * even been considered yet.  Try once more without
> -		 * fairness, and include remote zones now, before
> -		 * entering the slowpath and waking kswapd: prefer
> -		 * spilling to a remote zone over swapping locally.
> -		 */

I wrote this comment, so I don't know how helpful it is to others, but
the retry logic in get_page_from_freelist() seems a little naked
without any explanation.

> -		if (alloc_flags & ALLOC_FAIR) {
> -			reset_alloc_batches(zonelist, high_zoneidx,
> -					    preferred_zone);
> -			alloc_flags &= ~ALLOC_FAIR;
> -			goto retry;
> -		}
> -		/*
>  		 * Runtime PM, block IO and its error handling path
>  		 * can deadlock because I/O on the device might not
>  		 * complete.
> @@ -3287,10 +3287,18 @@ void show_free_areas(unsigned int filter)
>  	show_swap_cache_info();
>  }
>  
> -static void zoneref_set_zone(struct zone *zone, struct zoneref *zoneref)
> +static int zoneref_set_zone(pg_data_t *pgdat, struct zone *zone,
> +			struct zoneref *zoneref, struct zone *preferred_zone)
>  {
> +	int zone_type = zone_idx(zone);
> +	bool fair_enabled = zone_local(zone, preferred_zone);
> +	if (zone_type == 0 &&
> +			zone->managed_pages < (pgdat->node_present_pages >> 4))
> +		fair_enabled = false;

This needs a comment.

>  	zoneref->zone = zone;
> -	zoneref->zone_idx = zone_idx(zone);
> +	zoneref->zone_idx = zone_type;
> +	return fair_enabled;
>  }
>  
>  /*
> @@ -3303,17 +3311,26 @@ static int build_zonelists_node(pg_data_t *pgdat, struct zonelist *zonelist,
>  {
>  	struct zone *zone;
>  	enum zone_type zone_type = MAX_NR_ZONES;
> +	struct zone *preferred_zone = NULL;
> +	int nr_fair = 0;
>  
>  	do {
>  		zone_type--;
>  		zone = pgdat->node_zones + zone_type;
>  		if (populated_zone(zone)) {
> -			zoneref_set_zone(zone,
> -				&zonelist->_zonerefs[nr_zones++]);
> +			if (!preferred_zone)
> +				preferred_zone = zone;
> +
> +			nr_fair += zoneref_set_zone(pgdat, zone,
> +				&zonelist->_zonerefs[nr_zones++],
> +				preferred_zone);

Passing preferred_zone to determine locality seems pointless when you
walk the zones of a single node.

And the return value of zoneref_set_zone() is fairly unexpected.

It's probably better to determine fair_enabled in the callsite, that
would fix both problems, and write a separate helper that tests if a
zone is eligible for fair treatment (type && managed_pages test).

>  			check_highest_zone(zone_type);
>  		}
>  	} while (zone_type);
>  
> +	if (nr_fair <= 1)
> +		zonelist->fair_enabled = false;
> +
>  	return nr_zones;
>  }
>  
> @@ -3538,8 +3555,9 @@ static void build_zonelists_in_zone_order(pg_data_t *pgdat, int nr_nodes)
>  {
>  	int pos, j, node;
>  	int zone_type;		/* needs to be signed */
> -	struct zone *z;
> +	struct zone *z, *preferred_zone = NULL;
>  	struct zonelist *zonelist;
> +	int nr_fair = 0;
>  
>  	zonelist = &pgdat->node_zonelists[0];
>  	pos = 0;
> @@ -3547,15 +3565,25 @@ static void build_zonelists_in_zone_order(pg_data_t *pgdat, int nr_nodes)
>  		for (j = 0; j < nr_nodes; j++) {
>  			node = node_order[j];
>  			z = &NODE_DATA(node)->node_zones[zone_type];
> +			if (!preferred_zone)
> +				preferred_zone = z;
>  			if (populated_zone(z)) {
> -				zoneref_set_zone(z,
> -					&zonelist->_zonerefs[pos++]);
> +				nr_fair += zoneref_set_zone(pgdat, z,
> +					&zonelist->_zonerefs[pos++],
> +					preferred_zone);
>  				check_highest_zone(zone_type);
>  			}
>  		}
>  	}
>  	zonelist->_zonerefs[pos].zone = NULL;
>  	zonelist->_zonerefs[pos].zone_idx = 0;
> +
> +	/*
> +	 * For this policy, the fair zone allocation policy is disabled as the
> +	 * stated priority is to preserve lower zones, not balance them fairly.
> +	 */
> +	if (nr_fair == 1 || nr_online_nodes > 1)
> +		zonelist->fair_enabled = false;
>  }
>  
>  static int default_zonelist_order(void)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
