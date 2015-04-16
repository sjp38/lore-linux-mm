Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 0BC5D6B0038
	for <linux-mm@kvack.org>; Wed, 15 Apr 2015 23:56:14 -0400 (EDT)
Received: by pacyx8 with SMTP id yx8so74352629pac.1
        for <linux-mm@kvack.org>; Wed, 15 Apr 2015 20:56:13 -0700 (PDT)
Received: from lgeamrelo01.lge.com (lgeamrelo01.lge.com. [156.147.1.125])
        by mx.google.com with ESMTP id ki9si10109727pdb.160.2015.04.15.20.56.11
        for <linux-mm@kvack.org>;
        Wed, 15 Apr 2015 20:56:12 -0700 (PDT)
Date: Thu, 16 Apr 2015 12:57:36 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [patch] mm: vmscan: invoke slab shrinkers from shrink_zone()
Message-ID: <20150416035736.GA1203@js1304-P5Q-DELUXE>
References: <1416939830-20289-1-git-send-email-hannes@cmpxchg.org>
 <20141128160637.GH6948@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141128160637.GH6948@esperanza>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>

Hello, Johannes.

Ccing Vlastimil, because this patch causes some regression on
stress-highalloc test in mmtests and he is a expert on compaction
and would have interest on it. :)

On Fri, Nov 28, 2014 at 07:06:37PM +0300, Vladimir Davydov wrote:
> Hi Johannes,
> 
> The patch generally looks good to me, because it simplifies the code
> flow significantly and makes it easier for me to introduce per memcg
> slab reclaim (thanks!). However, it has one serious flaw. Please see the
> comment inline.
> 
> On Tue, Nov 25, 2014 at 01:23:50PM -0500, Johannes Weiner wrote:
> [...]
> > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > index a384339bf718..8c2b45bfe610 100644
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> [...]
> > @@ -2376,12 +2407,7 @@ static bool shrink_zones(struct zonelist *zonelist, struct scan_control *sc)
> >  	struct zone *zone;
> >  	unsigned long nr_soft_reclaimed;
> >  	unsigned long nr_soft_scanned;
> > -	unsigned long lru_pages = 0;
> > -	struct reclaim_state *reclaim_state = current->reclaim_state;
> >  	gfp_t orig_mask;
> > -	struct shrink_control shrink = {
> > -		.gfp_mask = sc->gfp_mask,
> > -	};
> >  	enum zone_type requested_highidx = gfp_zone(sc->gfp_mask);
> >  	bool reclaimable = false;
> >  
> > @@ -2394,10 +2420,8 @@ static bool shrink_zones(struct zonelist *zonelist, struct scan_control *sc)
> >  	if (buffer_heads_over_limit)
> >  		sc->gfp_mask |= __GFP_HIGHMEM;
> >  
> > -	nodes_clear(shrink.nodes_to_scan);
> > -
> >  	for_each_zone_zonelist_nodemask(zone, z, zonelist,
> > -					gfp_zone(sc->gfp_mask), sc->nodemask) {
> > +					requested_highidx, sc->nodemask) {
> >  		if (!populated_zone(zone))
> >  			continue;
> >  		/*
> > @@ -2409,9 +2433,6 @@ static bool shrink_zones(struct zonelist *zonelist, struct scan_control *sc)
> >  						 GFP_KERNEL | __GFP_HARDWALL))
> >  				continue;
> >  
> > -			lru_pages += zone_reclaimable_pages(zone);
> > -			node_set(zone_to_nid(zone), shrink.nodes_to_scan);
> > -
> >  			if (sc->priority != DEF_PRIORITY &&
> >  			    !zone_reclaimable(zone))
> >  				continue;	/* Let kswapd poll it */
> > @@ -2450,7 +2471,7 @@ static bool shrink_zones(struct zonelist *zonelist, struct scan_control *sc)
> >  			/* need some check for avoid more shrink_zone() */
> >  		}
> >  
> > -		if (shrink_zone(zone, sc))
> > +		if (shrink_zone(zone, sc, zone_idx(zone) == requested_highidx))
> >  			reclaimable = true;
> >  
> >  		if (global_reclaim(sc) &&
> 
> If the highest zone (zone_idx=requested_highidx) is not populated, we
> won't scan slab caches on direct reclaim, which may result in OOM kill
> even if there are plenty of freeable dentries available.
> 
> It's especially relevant for VMs, which often have less than 4G of RAM,
> in which case we will only have ZONE_DMA and ZONE_DMA32 populated and
> empty ZONE_NORMAL on x86_64.

I got similar problem mentioned above by Vladimir when I test stress-highest
benchmark. My test system has ZONE_DMA and ZONE_DMA32 and ZONE_NORMAL zones
like as following.

Node 0, zone      DMA
        spanned  4095
        present  3998
        managed  3977
Node 0, zone    DMA32
        spanned  1044480
        present  782333
        managed  762561
Node 0, zone   Normal
        spanned  262144
        present  262144
        managed  245318

Perhaps, requested_highidx would be ZONE_NORMAL for almost normal
allocation request.

When I test stress-highalloc benchmark, shrink_zone() on requested_highidx
zone in kswapd_shrink_zone() is frequently skipped because this zone is
already balanced. But, another zone, for example, DMA32, which has more memory,
isn't balanced so kswapd try to reclaim on that zone. But,
zone_idx(zone) == classzone_idx isn't true for that zone so
shrink_slab() is skipped and we can't age slab objects with same ratio
of lru pages. This could be also possible on direct reclaim path as Vladimir
mentioned.

This causes following success rate regression of phase 1,2 on stress-highalloc
benchmark. The situation of phase 1,2 is that many high order allocations are
requested while many threads do kernel build in parallel.

Base: Run 1
Ops 1       33.00 (  0.00%)
Ops 2       43.00 (  0.00%)
Ops 3       80.00 (  0.00%)
Base: Run 2
Ops 1       33.00 (  0.00%)
Ops 2       44.00 (  0.00%)
Ops 3       80.00 (  0.00%)
Base: Run 3
Ops 1       30.00 (  0.00%)
Ops 2       44.00 (  0.00%)
Ops 3       80.00 (  0.00%)

Revert offending commit: Run 1
Ops 1       46.00 (  0.00%)
Ops 2       53.00 (  0.00%)
Ops 3       80.00 (  0.00%)
Revert offending commit: Run 2
Ops 1       48.00 (  0.00%)
Ops 2       55.00 (  0.00%)
Ops 3       80.00 (  0.00%)
Revert offending commit: Run 3
Ops 1       48.00 (  0.00%)
Ops 2       55.00 (  0.00%)
Ops 3       81.00 (  0.00%)

I'm not sure whether we should consider this benchmark's regression very much,
because real life's compaction behavious would be different with this
benchmark. Anyway, I have some questions related to this patch. I don't know
this code very well so please correct me if I'm wrong.

I read the patch carefully and there is two main differences between before
and after. One is the way of aging ratio calculation. Before, we use number of
lru pages in node, but, this patch uses number of lru pages in zone. As I
understand correctly, shrink_slab() works for a node range rather than
zone one. And, I guess that calculated ratio with zone's number of lru pages
could be more fluctuate than node's one. Is it reasonable to use zone's one?

And, should we guarantee one time invocation of shrink_slab() in above cases?
When I tested it, benchmark result is restored a little.

Guarantee one time invocation: Run 1
Ops 1       30.00 (  0.00%)
Ops 2       47.00 (  0.00%)
Ops 3       80.00 (  0.00%)
Guarantee one time invocation: Run 2
Ops 1       43.00 (  0.00%)
Ops 2       45.00 (  0.00%)
Ops 3       78.00 (  0.00%)
Guarantee one time invocation: Run 3
Ops 1       39.00 (  0.00%)
Ops 2       45.00 (  0.00%)
Ops 3       80.00 (  0.00%)

Thanks.

> 
> What about distributing the pressure proportionally to the number of
> present pages on the zone? Something like this:
> 
> >From 5face0e29300950575bf9ccbd995828e2f183da1 Mon Sep 17 00:00:00 2001
> From: Vladimir Davydov <vdavydov@parallels.com>
> Date: Fri, 28 Nov 2014 17:58:43 +0300
> Subject: [PATCH] vmscan: fix slab vs page cache reclaim balance
> 
> Though page cache reclaim is done per-zone, the finest granularity for
> slab cache reclaim is per node. To achieve proportional pressure being
> put on them, we therefore shrink slab caches only when scanning the
> class zone, which is the highest zone suitable for allocations. However,
> the class zone may be empty, e.g. ZONE_NORMAL/ZONE_HIGH, which are class
> zones for most allocations, are empty on x86_64 with < 4G of RAM. This
> will result in slab cache being scanned only by kswapd, which in turn
> may lead to a premature OOM kill.
> 
> This patch attempts to fix this by calling shrink_node_slabs per each
> zone eligible while distributing the pressure between zones
> proportionally to the number of present pages.
> 
> Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 9130cf67bac1..dd80625a1be5 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2298,8 +2298,7 @@ static inline bool should_continue_reclaim(struct zone *zone,
>  	}
>  }
>  
> -static bool shrink_zone(struct zone *zone, struct scan_control *sc,
> -			bool is_classzone)
> +static bool shrink_zone(struct zone *zone, struct scan_control *sc)
>  {
>  	unsigned long nr_reclaimed, nr_scanned;
>  	bool reclaimable = false;
> @@ -2310,7 +2309,7 @@ static bool shrink_zone(struct zone *zone, struct scan_control *sc,
>  			.zone = zone,
>  			.priority = sc->priority,
>  		};
> -		unsigned long zone_lru_pages = 0;
> +		unsigned long nr_eligible = 0;
>  		struct mem_cgroup *memcg;
>  
>  		nr_reclaimed = sc->nr_reclaimed;
> @@ -2319,6 +2318,7 @@ static bool shrink_zone(struct zone *zone, struct scan_control *sc,
>  		memcg = mem_cgroup_iter(root, NULL, &reclaim);
>  		do {
>  			unsigned long lru_pages;
> +			unsigned long long tmp;
>  			struct lruvec *lruvec;
>  			int swappiness;
>  
> @@ -2326,7 +2326,17 @@ static bool shrink_zone(struct zone *zone, struct scan_control *sc,
>  			swappiness = mem_cgroup_swappiness(memcg);
>  
>  			shrink_lruvec(lruvec, swappiness, sc, &lru_pages);
> -			zone_lru_pages += lru_pages;
> +
> +			/*
> +			 * Scale lru_pages inversely proportionally to the zone
> +			 * size in order to not over-reclaim slab caches, which
> +			 * are zone unaware.
> +			 */
> +			tmp = lru_pages;
> +			tmp *= zone->zone_pgdat->node_present_pages;
> +			do_div(tmp, zone->present_pages);
> +
> +			nr_eligible += tmp;
>  
>  			/*
>  			 * Direct reclaim and kswapd have to scan all memory
> @@ -2350,12 +2360,12 @@ static bool shrink_zone(struct zone *zone, struct scan_control *sc,
>  		 * Shrink the slab caches in the same proportion that
>  		 * the eligible LRU pages were scanned.
>  		 */
> -		if (global_reclaim(sc) && is_classzone) {
> +		if (global_reclaim(sc)) {
>  			struct reclaim_state *reclaim_state;
>  
>  			shrink_node_slabs(sc->gfp_mask, zone_to_nid(zone),
>  					  sc->nr_scanned - nr_scanned,
> -					  zone_lru_pages);
> +					  nr_eligible);
>  
>  			reclaim_state = current->reclaim_state;
>  			if (reclaim_state) {
> @@ -2503,7 +2513,7 @@ static bool shrink_zones(struct zonelist *zonelist, struct scan_control *sc)
>  			/* need some check for avoid more shrink_zone() */
>  		}
>  
> -		if (shrink_zone(zone, sc, zone_idx(zone) == requested_highidx))
> +		if (shrink_zone(zone, sc))
>  			reclaimable = true;
>  
>  		if (global_reclaim(sc) &&
> @@ -3010,7 +3020,7 @@ static bool kswapd_shrink_zone(struct zone *zone,
>  						balance_gap, classzone_idx))
>  		return true;
>  
> -	shrink_zone(zone, sc, zone_idx(zone) == classzone_idx);
> +	shrink_zone(zone, sc);
>  
>  	/* Account for the number of pages attempted to reclaim */
>  	*nr_attempted += sc->nr_to_reclaim;
> @@ -3656,7 +3666,7 @@ static int __zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
>  		 * priorities until we have enough memory freed.
>  		 */
>  		do {
> -			shrink_zone(zone, &sc, true);
> +			shrink_zone(zone, &sc);
>  		} while (sc.nr_reclaimed < nr_pages && --sc.priority >= 0);
>  	}
>  
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
