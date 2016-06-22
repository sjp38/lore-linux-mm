Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f197.google.com (mail-lb0-f197.google.com [209.85.217.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7FDEA6B0253
	for <linux-mm@kvack.org>; Wed, 22 Jun 2016 10:04:37 -0400 (EDT)
Received: by mail-lb0-f197.google.com with SMTP id js8so41184910lbc.2
        for <linux-mm@kvack.org>; Wed, 22 Jun 2016 07:04:37 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id gl9si44369458wjb.144.2016.06.22.07.04.35
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 22 Jun 2016 07:04:36 -0700 (PDT)
Subject: Re: [PATCH 04/27] mm, vmscan: Begin reclaiming pages on a per-node
 basis
References: <1466518566-30034-1-git-send-email-mgorman@techsingularity.net>
 <1466518566-30034-5-git-send-email-mgorman@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <6eecdf50-7880-2bfe-5519-004a4beeece6@suse.cz>
Date: Wed, 22 Jun 2016 16:04:34 +0200
MIME-Version: 1.0
In-Reply-To: <1466518566-30034-5-git-send-email-mgorman@techsingularity.net>
Content-Type: text/plain; charset=iso-8859-2; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@surriel.com>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>

On 06/21/2016 04:15 PM, Mel Gorman wrote:
> This patch makes reclaim decisions on a per-node basis. A reclaimer knows
> what zone is required by the allocation request and skips pages from
> higher zones. In many cases this will be ok because it's a GFP_HIGHMEM
> request of some description. On 64-bit, ZONE_DMA32 requests will cause
> some problems but 32-bit devices on 64-bit platforms are increasingly
> rare. Historically it would have been a major problem on 32-bit with big
> Highmem:Lowmem ratios but such configurations are also now rare and even
> where they exist, they are not encouraged. If it really becomes a problem,
> it'll manifest as very low reclaim efficiencies.
>
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>

[...]

> @@ -2540,14 +2559,14 @@ static inline bool compaction_ready(struct zone *zone, int order, int classzone_
>   * If a zone is deemed to be full of pinned pages then just give it a light
>   * scan then give up on it.
>   */
> -static void shrink_zones(struct zonelist *zonelist, struct scan_control *sc)
> +static void shrink_zones(struct zonelist *zonelist, struct scan_control *sc,
> +		enum zone_type classzone_idx)
>  {
>  	struct zoneref *z;
>  	struct zone *zone;
>  	unsigned long nr_soft_reclaimed;
>  	unsigned long nr_soft_scanned;
>  	gfp_t orig_mask;
> -	enum zone_type requested_highidx = gfp_zone(sc->gfp_mask);
>
>  	/*
>  	 * If the number of buffer_heads in the machine exceeds the maximum
> @@ -2560,15 +2579,20 @@ static void shrink_zones(struct zonelist *zonelist, struct scan_control *sc)
>
>  	for_each_zone_zonelist_nodemask(zone, z, zonelist,
>  					gfp_zone(sc->gfp_mask), sc->nodemask) {

Using sc->reclaim_idx could be faster/nicer here than gfp_zone()?
Although after "mm, vmscan: Update classzone_idx if buffer_heads_over_limit" 
there would need to be a variable for the highmem adjusted value - maybe reuse 
"requested_highidx"? Not important though.

> -		enum zone_type classzone_idx;
> -
>  		if (!populated_zone(zone))
>  			continue;
>
> -		classzone_idx = requested_highidx;
> +		/*
> +		 * Note that reclaim_idx does not change as it is the highest
> +		 * zone reclaimed from which for empty zones is a no-op but
> +		 * classzone_idx is used by shrink_node to test if the slabs
> +		 * should be shrunk on a given node.
> +		 */
>  		while (!populated_zone(zone->zone_pgdat->node_zones +
> -							classzone_idx))
> +							classzone_idx)) {
>  			classzone_idx--;
> +			continue;
> +		}
>
>  		/*
>  		 * Take care memory controller reclaiming has small influence
> @@ -2594,8 +2618,8 @@ static void shrink_zones(struct zonelist *zonelist, struct scan_control *sc)
>  			 */
>  			if (IS_ENABLED(CONFIG_COMPACTION) &&
>  			    sc->order > PAGE_ALLOC_COSTLY_ORDER &&
> -			    zonelist_zone_idx(z) <= requested_highidx &&
> -			    compaction_ready(zone, sc->order, requested_highidx)) {
> +			    zonelist_zone_idx(z) <= classzone_idx &&
> +			    compaction_ready(zone, sc->order, classzone_idx)) {
>  				sc->compaction_ready = true;
>  				continue;
>  			}
> @@ -2615,7 +2639,7 @@ static void shrink_zones(struct zonelist *zonelist, struct scan_control *sc)
>  			/* need some check for avoid more shrink_zone() */
>  		}
>
> -		shrink_zone(zone, sc, zone_idx(zone) == classzone_idx);
> +		shrink_node(zone->zone_pgdat, sc, classzone_idx);
>  	}
>
>  	/*
> @@ -2647,6 +2671,7 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
>  	int initial_priority = sc->priority;
>  	unsigned long total_scanned = 0;
>  	unsigned long writeback_threshold;
> +	enum zone_type classzone_idx = sc->reclaim_idx;

Hmm, try_to_free_mem_cgroup_pages() seems to call this with sc->reclaim_idx not 
explicitly inirialized (e.g. 0). And shrink_all_memory() as well. I probably 
didn't check them in v6 and pointed out only try_to_free_pages() (which is now 
OK), sorry.

>  retry:
>  	delayacct_freepages_start();
>
> @@ -2657,7 +2682,7 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
>  		vmpressure_prio(sc->gfp_mask, sc->target_mem_cgroup,
>  				sc->priority);
>  		sc->nr_scanned = 0;
> -		shrink_zones(zonelist, sc);
> +		shrink_zones(zonelist, sc, classzone_idx);

Looks like classzone_idx here is only used here to pass to shrink_zones() 
unchanged, which means it can just use it directly without a new param?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
