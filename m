Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f51.google.com (mail-wg0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id E72256B0095
	for <linux-mm@kvack.org>; Wed,  6 Aug 2014 09:56:16 -0400 (EDT)
Received: by mail-wg0-f51.google.com with SMTP id b13so2697904wgh.22
        for <linux-mm@kvack.org>; Wed, 06 Aug 2014 06:56:16 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id hl8si3394411wib.60.2014.08.06.06.56.13
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 06 Aug 2014 06:56:14 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [RFC 2/4] mm, page_alloc: reduce number of alloc_pages* functions' parameters
Date: Wed,  6 Aug 2014 15:55:54 +0200
Message-Id: <1407333356-30928-3-git-send-email-vbabka@suse.cz>
In-Reply-To: <1407333356-30928-1-git-send-email-vbabka@suse.cz>
References: <1407333356-30928-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Vlastimil Babka <vbabka@suse.cz>

Introduce struct alloc_info to accumulate all the numerous parameters passed
between the alloc_pages* family of functions and get_page_from_freelist().
---
 mm/page_alloc.c | 241 +++++++++++++++++++++++++++-----------------------------
 1 file changed, 118 insertions(+), 123 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index b2cd463..399d40d 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -231,6 +231,19 @@ EXPORT_SYMBOL(nr_node_ids);
 EXPORT_SYMBOL(nr_online_nodes);
 #endif
 
+struct alloc_info {
+	struct zonelist *zonelist;
+	nodemask_t *nodemask;
+	struct zone *preferred_zone;
+
+	unsigned int order;
+	gfp_t gfp_mask;
+	int alloc_flags;
+	int classzone_idx;
+	int migratetype;
+	enum zone_type high_zoneidx;
+};
+
 int page_group_by_mobility_disabled __read_mostly;
 
 void set_pageblock_migratetype(struct page *page, int migratetype)
@@ -1943,10 +1956,11 @@ static void reset_alloc_batches(struct zone *preferred_zone)
  * a page.
  */
 static struct page *
-get_page_from_freelist(gfp_t gfp_mask, nodemask_t *nodemask, unsigned int order,
-		struct zonelist *zonelist, int high_zoneidx, int alloc_flags,
-		struct zone *preferred_zone, int classzone_idx, int migratetype)
+get_page_from_freelist(const struct alloc_info *ai)
 {
+	const unsigned int order = ai->order;
+	int alloc_flags = ai->alloc_flags;
+	struct zonelist *zonelist = ai->zonelist;
 	struct zoneref *z;
 	struct page *page = NULL;
 	struct zone *zone;
@@ -1954,7 +1968,7 @@ get_page_from_freelist(gfp_t gfp_mask, nodemask_t *nodemask, unsigned int order,
 	int zlc_active = 0;		/* set if using zonelist_cache */
 	int did_zlc_setup = 0;		/* just call zlc_setup() one time */
 	bool consider_zone_dirty = (alloc_flags & ALLOC_WMARK_LOW) &&
-				(gfp_mask & __GFP_WRITE);
+				(ai->gfp_mask & __GFP_WRITE);
 	int nr_fair_skipped = 0;
 	bool zonelist_rescan;
 
@@ -1966,7 +1980,7 @@ zonelist_scan:
 	 * See also __cpuset_node_allowed_softwall() comment in kernel/cpuset.c.
 	 */
 	for_each_zone_zonelist_nodemask(zone, z, zonelist,
-						high_zoneidx, nodemask) {
+						ai->high_zoneidx, ai->nodemask) {
 		unsigned long mark;
 
 		if (IS_ENABLED(CONFIG_NUMA) && zlc_active &&
@@ -1974,7 +1988,7 @@ zonelist_scan:
 				continue;
 		if (cpusets_enabled() &&
 			(alloc_flags & ALLOC_CPUSET) &&
-			!cpuset_zone_allowed_softwall(zone, gfp_mask))
+			!cpuset_zone_allowed_softwall(zone, ai->gfp_mask))
 				continue;
 		/*
 		 * Distribute pages in proportion to the individual
@@ -1983,7 +1997,7 @@ zonelist_scan:
 		 * time the page has in memory before being reclaimed.
 		 */
 		if (alloc_flags & ALLOC_FAIR) {
-			if (!zone_local(preferred_zone, zone))
+			if (!zone_local(ai->preferred_zone, zone))
 				break;
 			if (zone_is_fair_depleted(zone)) {
 				nr_fair_skipped++;
@@ -2021,7 +2035,7 @@ zonelist_scan:
 
 		mark = zone->watermark[alloc_flags & ALLOC_WMARK_MASK];
 		if (!zone_watermark_ok(zone, order, mark,
-				       classzone_idx, alloc_flags)) {
+				       ai->classzone_idx, alloc_flags)) {
 			int ret;
 
 			/* Checked here to keep the fast path fast */
@@ -2042,7 +2056,7 @@ zonelist_scan:
 			}
 
 			if (zone_reclaim_mode == 0 ||
-			    !zone_allows_reclaim(preferred_zone, zone))
+			    !zone_allows_reclaim(ai->preferred_zone, zone))
 				goto this_zone_full;
 
 			/*
@@ -2053,7 +2067,7 @@ zonelist_scan:
 				!zlc_zone_worth_trying(zonelist, z, allowednodes))
 				continue;
 
-			ret = zone_reclaim(zone, gfp_mask, order);
+			ret = zone_reclaim(zone, ai->gfp_mask, order);
 			switch (ret) {
 			case ZONE_RECLAIM_NOSCAN:
 				/* did not scan */
@@ -2064,7 +2078,7 @@ zonelist_scan:
 			default:
 				/* did we reclaim enough */
 				if (zone_watermark_ok(zone, order, mark,
-						classzone_idx, alloc_flags))
+						ai->classzone_idx, alloc_flags))
 					goto try_this_zone;
 
 				/*
@@ -2085,8 +2099,8 @@ zonelist_scan:
 		}
 
 try_this_zone:
-		page = buffered_rmqueue(preferred_zone, zone, order,
-						gfp_mask, migratetype);
+		page = buffered_rmqueue(ai->preferred_zone, zone, order,
+						ai->gfp_mask, ai->migratetype);
 		if (page)
 			break;
 this_zone_full:
@@ -2118,7 +2132,7 @@ this_zone_full:
 		alloc_flags &= ~ALLOC_FAIR;
 		if (nr_fair_skipped) {
 			zonelist_rescan = true;
-			reset_alloc_batches(preferred_zone);
+			reset_alloc_batches(ai->preferred_zone);
 		}
 		if (nr_online_nodes > 1)
 			zonelist_rescan = true;
@@ -2239,15 +2253,14 @@ should_alloc_retry(gfp_t gfp_mask, unsigned int order,
 }
 
 static inline struct page *
-__alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
-	struct zonelist *zonelist, enum zone_type high_zoneidx,
-	nodemask_t *nodemask, struct zone *preferred_zone,
-	int classzone_idx, int migratetype)
+__alloc_pages_may_oom(struct alloc_info *ai)
 {
 	struct page *page;
+	const gfp_t gfp_mask = ai->gfp_mask;
+	const int alloc_flags_saved = ai->alloc_flags;
 
 	/* Acquire the per-zone oom lock for each zone */
-	if (!oom_zonelist_trylock(zonelist, gfp_mask)) {
+	if (!oom_zonelist_trylock(ai->zonelist, ai->gfp_mask)) {
 		schedule_timeout_uninterruptible(1);
 		return NULL;
 	}
@@ -2257,19 +2270,21 @@ __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
 	 * here, this is only to catch a parallel oom killing, we must fail if
 	 * we're still under heavy pressure.
 	 */
-	page = get_page_from_freelist(gfp_mask|__GFP_HARDWALL, nodemask,
-		order, zonelist, high_zoneidx,
-		ALLOC_WMARK_HIGH|ALLOC_CPUSET,
-		preferred_zone, classzone_idx, migratetype);
+	ai->gfp_mask |= __GFP_HARDWALL;
+	ai->alloc_flags = ALLOC_WMARK_HIGH|ALLOC_CPUSET;
+	page = get_page_from_freelist(ai);
+	ai->gfp_mask = gfp_mask;
+	ai->alloc_flags = alloc_flags_saved;
+
 	if (page)
 		goto out;
 
 	if (!(gfp_mask & __GFP_NOFAIL)) {
 		/* The OOM killer will not help higher order allocs */
-		if (order > PAGE_ALLOC_COSTLY_ORDER)
+		if (ai->order > PAGE_ALLOC_COSTLY_ORDER)
 			goto out;
 		/* The OOM killer does not needlessly kill tasks for lowmem */
-		if (high_zoneidx < ZONE_NORMAL)
+		if (ai->high_zoneidx < ZONE_NORMAL)
 			goto out;
 		/*
 		 * GFP_THISNODE contains __GFP_NORETRY and we never hit this.
@@ -2282,23 +2297,24 @@ __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
 			goto out;
 	}
 	/* Exhausted what can be done so it's blamo time */
-	out_of_memory(zonelist, gfp_mask, order, nodemask, false);
+	out_of_memory(ai->zonelist, gfp_mask, ai->order, ai->nodemask, false);
 
 out:
-	oom_zonelist_unlock(zonelist, gfp_mask);
+	oom_zonelist_unlock(ai->zonelist, gfp_mask);
 	return page;
 }
 
 #ifdef CONFIG_COMPACTION
 /* Try memory compaction for high-order allocations before reclaim */
 static struct page *
-__alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
-	struct zonelist *zonelist, enum zone_type high_zoneidx,
-	nodemask_t *nodemask, int alloc_flags, struct zone *preferred_zone,
-	int classzone_idx, int migratetype, enum migrate_mode mode,
+__alloc_pages_direct_compact(struct alloc_info *ai, enum migrate_mode mode,
 	bool *contended_compaction, bool *deferred_compaction,
 	unsigned long *did_some_progress)
 {
+	const unsigned int order = ai->order;
+	struct zone *preferred_zone = ai->preferred_zone;
+	const int alloc_flags_saved = ai->alloc_flags;
+
 	if (!order)
 		return NULL;
 
@@ -2308,8 +2324,8 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
 	}
 
 	current->flags |= PF_MEMALLOC;
-	*did_some_progress = try_to_compact_pages(zonelist, order, gfp_mask,
-						nodemask, mode,
+	*did_some_progress = try_to_compact_pages(ai->zonelist, order, ai->gfp_mask,
+						ai->nodemask, mode,
 						contended_compaction);
 	current->flags &= ~PF_MEMALLOC;
 
@@ -2320,10 +2336,10 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
 		drain_pages(get_cpu());
 		put_cpu();
 
-		page = get_page_from_freelist(gfp_mask, nodemask,
-				order, zonelist, high_zoneidx,
-				alloc_flags & ~ALLOC_NO_WATERMARKS,
-				preferred_zone, classzone_idx, migratetype);
+		ai->alloc_flags &= ~ALLOC_NO_WATERMARKS;
+		page = get_page_from_freelist(ai);
+		ai->alloc_flags = alloc_flags_saved;
+
 		if (page) {
 			preferred_zone->compact_blockskip_flush = false;
 			compaction_defer_reset(preferred_zone, order, true);
@@ -2352,12 +2368,9 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
 }
 #else
 static inline struct page *
-__alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
-	struct zonelist *zonelist, enum zone_type high_zoneidx,
-	nodemask_t *nodemask, int alloc_flags, struct zone *preferred_zone,
-	int classzone_idx, int migratetype,
-	enum migrate_mode mode, bool *contended_compaction,
-	bool *deferred_compaction, unsigned long *did_some_progress)
+__alloc_pages_direct_compact(struct alloc_info *ai, enum migrate_mode mode,
+	bool *contended_compaction, bool *deferred_compaction,
+	unsigned long *did_some_progress)
 {
 	return NULL;
 }
@@ -2393,29 +2406,25 @@ __perform_reclaim(gfp_t gfp_mask, unsigned int order, struct zonelist *zonelist,
 
 /* The really slow allocator path where we enter direct reclaim */
 static inline struct page *
-__alloc_pages_direct_reclaim(gfp_t gfp_mask, unsigned int order,
-	struct zonelist *zonelist, enum zone_type high_zoneidx,
-	nodemask_t *nodemask, int alloc_flags, struct zone *preferred_zone,
-	int classzone_idx, int migratetype, unsigned long *did_some_progress)
+__alloc_pages_direct_reclaim(struct alloc_info *ai,
+				unsigned long *did_some_progress)
 {
 	struct page *page = NULL;
 	bool drained = false;
+	const int alloc_flags_saved = ai->alloc_flags;
 
-	*did_some_progress = __perform_reclaim(gfp_mask, order, zonelist,
-					       nodemask);
+	*did_some_progress = __perform_reclaim(ai->gfp_mask, ai->order,
+						ai->zonelist, ai->nodemask);
 	if (unlikely(!(*did_some_progress)))
 		return NULL;
 
 	/* After successful reclaim, reconsider all zones for allocation */
 	if (IS_ENABLED(CONFIG_NUMA))
-		zlc_clear_zones_full(zonelist);
+		zlc_clear_zones_full(ai->zonelist);
 
+	ai->alloc_flags &= ~ALLOC_NO_WATERMARKS;
 retry:
-	page = get_page_from_freelist(gfp_mask, nodemask, order,
-					zonelist, high_zoneidx,
-					alloc_flags & ~ALLOC_NO_WATERMARKS,
-					preferred_zone, classzone_idx,
-					migratetype);
+	page = get_page_from_freelist(ai);
 
 	/*
 	 * If an allocation failed after direct reclaim, it could be because
@@ -2427,6 +2436,7 @@ retry:
 		goto retry;
 	}
 
+	ai->alloc_flags = alloc_flags_saved;
 	return page;
 }
 
@@ -2435,22 +2445,21 @@ retry:
  * sufficient urgency to ignore watermarks and take other desperate measures
  */
 static inline struct page *
-__alloc_pages_high_priority(gfp_t gfp_mask, unsigned int order,
-	struct zonelist *zonelist, enum zone_type high_zoneidx,
-	nodemask_t *nodemask, struct zone *preferred_zone,
-	int classzone_idx, int migratetype)
+__alloc_pages_high_priority(struct alloc_info *ai)
 {
 	struct page *page;
+	const int alloc_flags_saved = ai->alloc_flags;
 
+	ai->alloc_flags = ALLOC_NO_WATERMARKS;
 	do {
-		page = get_page_from_freelist(gfp_mask, nodemask, order,
-			zonelist, high_zoneidx, ALLOC_NO_WATERMARKS,
-			preferred_zone, classzone_idx, migratetype);
+		page = get_page_from_freelist(ai);
 
-		if (!page && gfp_mask & __GFP_NOFAIL)
-			wait_iff_congested(preferred_zone, BLK_RW_ASYNC, HZ/50);
-	} while (!page && (gfp_mask & __GFP_NOFAIL));
+		if (!page && ai->gfp_mask & __GFP_NOFAIL)
+			wait_iff_congested(ai->preferred_zone, BLK_RW_ASYNC,
+									HZ/50);
+	} while (!page && (ai->gfp_mask & __GFP_NOFAIL));
 
+	ai->alloc_flags = alloc_flags_saved;
 	return page;
 }
 
@@ -2521,11 +2530,10 @@ bool gfp_pfmemalloc_allowed(gfp_t gfp_mask)
 }
 
 static inline struct page *
-__alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
-	struct zonelist *zonelist, enum zone_type high_zoneidx,
-	nodemask_t *nodemask, struct zone *preferred_zone,
-	int classzone_idx, int migratetype)
+__alloc_pages_slowpath(struct alloc_info *ai)
 {
+	const unsigned int order = ai->order;
+	const gfp_t gfp_mask = ai->gfp_mask;
 	const gfp_t wait = gfp_mask & __GFP_WAIT;
 	struct page *page = NULL;
 	int alloc_flags;
@@ -2560,7 +2568,8 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 
 restart:
 	if (!(gfp_mask & __GFP_NO_KSWAPD))
-		wake_all_kswapds(order, zonelist, high_zoneidx, preferred_zone);
+		wake_all_kswapds(order, ai->zonelist, ai->high_zoneidx,
+							ai->preferred_zone);
 
 	/*
 	 * OK, we're below the kswapd watermark and have kicked background
@@ -2573,33 +2582,33 @@ restart:
 	 * Find the true preferred zone if the allocation is unconstrained by
 	 * cpusets.
 	 */
-	if (!(alloc_flags & ALLOC_CPUSET) && !nodemask) {
+	if (!(alloc_flags & ALLOC_CPUSET) && !ai->nodemask) {
 		struct zoneref *preferred_zoneref;
-		preferred_zoneref = first_zones_zonelist(zonelist, high_zoneidx,
-				NULL, &preferred_zone);
-		classzone_idx = zonelist_zone_idx(preferred_zoneref);
+		preferred_zoneref = first_zones_zonelist(ai->zonelist,
+				ai->high_zoneidx, NULL, &ai->preferred_zone);
+		ai->classzone_idx = zonelist_zone_idx(preferred_zoneref);
 	}
 
 rebalance:
 	/* This is the last chance, in general, before the goto nopage. */
-	page = get_page_from_freelist(gfp_mask, nodemask, order, zonelist,
-			high_zoneidx, alloc_flags & ~ALLOC_NO_WATERMARKS,
-			preferred_zone, classzone_idx, migratetype);
+	ai->alloc_flags = alloc_flags & ~ALLOC_NO_WATERMARKS;
+	page = get_page_from_freelist(ai);
 	if (page)
 		goto got_pg;
 
 	/* Allocate without watermarks if the context allows */
 	if (alloc_flags & ALLOC_NO_WATERMARKS) {
+		/* We have removed ALLOC_NO_WATERMARKS from alloc_info */
+		ai->alloc_flags = alloc_flags;
 		/*
 		 * Ignore mempolicies if ALLOC_NO_WATERMARKS on the grounds
 		 * the allocation is high priority and these type of
 		 * allocations are system rather than user orientated
 		 */
-		zonelist = node_zonelist(numa_node_id(), gfp_mask);
+		ai->zonelist = node_zonelist(numa_node_id(), gfp_mask);
+
+		page = __alloc_pages_high_priority(ai);
 
-		page = __alloc_pages_high_priority(gfp_mask, order,
-				zonelist, high_zoneidx, nodemask,
-				preferred_zone, classzone_idx, migratetype);
 		if (page) {
 			goto got_pg;
 		}
@@ -2628,11 +2637,8 @@ rebalance:
 	 * Try direct compaction. The first pass is asynchronous. Subsequent
 	 * attempts after direct reclaim are synchronous
 	 */
-	page = __alloc_pages_direct_compact(gfp_mask, order, zonelist,
-					high_zoneidx, nodemask, alloc_flags,
-					preferred_zone,
-					classzone_idx, migratetype,
-					migration_mode, &contended_compaction,
+	page = __alloc_pages_direct_compact(ai, migration_mode,
+					&contended_compaction,
 					&deferred_compaction,
 					&did_some_progress);
 	if (page)
@@ -2658,12 +2664,7 @@ rebalance:
 		migration_mode = MIGRATE_SYNC_LIGHT;
 
 	/* Try direct reclaim and then allocating */
-	page = __alloc_pages_direct_reclaim(gfp_mask, order,
-					zonelist, high_zoneidx,
-					nodemask,
-					alloc_flags, preferred_zone,
-					classzone_idx, migratetype,
-					&did_some_progress);
+	page = __alloc_pages_direct_reclaim(ai, &did_some_progress);
 	if (page)
 		goto got_pg;
 
@@ -2679,10 +2680,7 @@ rebalance:
 			if ((current->flags & PF_DUMPCORE) &&
 			    !(gfp_mask & __GFP_NOFAIL))
 				goto nopage;
-			page = __alloc_pages_may_oom(gfp_mask, order,
-					zonelist, high_zoneidx,
-					nodemask, preferred_zone,
-					classzone_idx, migratetype);
+			page = __alloc_pages_may_oom(ai);
 			if (page)
 				goto got_pg;
 
@@ -2700,7 +2698,7 @@ rebalance:
 				 * allocations to prevent needlessly killing
 				 * innocent tasks.
 				 */
-				if (high_zoneidx < ZONE_NORMAL)
+				if (ai->high_zoneidx < ZONE_NORMAL)
 					goto nopage;
 			}
 
@@ -2713,7 +2711,7 @@ rebalance:
 	if (should_alloc_retry(gfp_mask, order, did_some_progress,
 						pages_reclaimed)) {
 		/* Wait for some write requests to complete then retry */
-		wait_iff_congested(preferred_zone, BLK_RW_ASYNC, HZ/50);
+		wait_iff_congested(ai->preferred_zone, BLK_RW_ASYNC, HZ/50);
 		goto rebalance;
 	} else {
 		/*
@@ -2721,11 +2719,8 @@ rebalance:
 		 * direct reclaim and reclaim/compaction depends on compaction
 		 * being called after reclaim so call directly if necessary
 		 */
-		page = __alloc_pages_direct_compact(gfp_mask, order, zonelist,
-					high_zoneidx, nodemask, alloc_flags,
-					preferred_zone,
-					classzone_idx, migratetype,
-					migration_mode, &contended_compaction,
+		page = __alloc_pages_direct_compact(ai, migration_mode,
+					&contended_compaction,
 					&deferred_compaction,
 					&did_some_progress);
 		if (page)
@@ -2749,14 +2744,17 @@ struct page *
 __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
 			struct zonelist *zonelist, nodemask_t *nodemask)
 {
-	enum zone_type high_zoneidx = gfp_zone(gfp_mask);
-	struct zone *preferred_zone;
 	struct zoneref *preferred_zoneref;
 	struct page *page = NULL;
-	int migratetype = allocflags_to_migratetype(gfp_mask);
 	unsigned int cpuset_mems_cookie;
-	int alloc_flags = ALLOC_WMARK_LOW|ALLOC_CPUSET|ALLOC_FAIR;
-	int classzone_idx;
+	struct alloc_info ai = {
+		.order = order,
+		.alloc_flags = ALLOC_WMARK_LOW|ALLOC_CPUSET|ALLOC_FAIR,
+		.zonelist = zonelist,
+		.high_zoneidx = gfp_zone(gfp_mask),
+		.nodemask = nodemask,
+		.migratetype = allocflags_to_migratetype(gfp_mask),
+	};
 
 	gfp_mask &= gfp_allowed_mask;
 
@@ -2775,37 +2773,34 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
 	if (unlikely(!zonelist->_zonerefs->zone))
 		return NULL;
 
-	if (IS_ENABLED(CONFIG_CMA) && migratetype == MIGRATE_MOVABLE)
-		alloc_flags |= ALLOC_CMA;
+	if (IS_ENABLED(CONFIG_CMA) && ai.migratetype == MIGRATE_MOVABLE)
+		ai.alloc_flags |= ALLOC_CMA;
 
 retry_cpuset:
 	cpuset_mems_cookie = read_mems_allowed_begin();
 
 	/* The preferred zone is used for statistics later */
-	preferred_zoneref = first_zones_zonelist(zonelist, high_zoneidx,
-				nodemask ? : &cpuset_current_mems_allowed,
-				&preferred_zone);
-	if (!preferred_zone)
+	preferred_zoneref = first_zones_zonelist(ai.zonelist, ai.high_zoneidx,
+				ai.nodemask ? : &cpuset_current_mems_allowed,
+				&ai.preferred_zone);
+	if (!ai.preferred_zone)
 		goto out;
-	classzone_idx = zonelist_zone_idx(preferred_zoneref);
+	ai.classzone_idx = zonelist_zone_idx(preferred_zoneref);
 
 	/* First allocation attempt */
-	page = get_page_from_freelist(gfp_mask|__GFP_HARDWALL, nodemask, order,
-			zonelist, high_zoneidx, alloc_flags,
-			preferred_zone, classzone_idx, migratetype);
+	ai.gfp_mask = gfp_mask|__GFP_HARDWALL;
+	page = get_page_from_freelist(&ai);
 	if (unlikely(!page)) {
 		/*
 		 * Runtime PM, block IO and its error handling path
 		 * can deadlock because I/O on the device might not
 		 * complete.
 		 */
-		gfp_mask = memalloc_noio_flags(gfp_mask);
-		page = __alloc_pages_slowpath(gfp_mask, order,
-				zonelist, high_zoneidx, nodemask,
-				preferred_zone, classzone_idx, migratetype);
+		ai.gfp_mask = memalloc_noio_flags(gfp_mask);
+		page = __alloc_pages_slowpath(&ai);
 	}
 
-	trace_mm_page_alloc(page, order, gfp_mask, migratetype);
+	trace_mm_page_alloc(page, order, ai.gfp_mask, ai.migratetype);
 
 out:
 	/*
-- 
1.8.4.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
