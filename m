Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f44.google.com (mail-wg0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id 80D646B0070
	for <linux-mm@kvack.org>; Fri,  5 Dec 2014 14:59:20 -0500 (EST)
Received: by mail-wg0-f44.google.com with SMTP id b13so1800862wgh.31
        for <linux-mm@kvack.org>; Fri, 05 Dec 2014 11:59:20 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id wx8si50925977wjb.75.2014.12.05.11.59.17
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 05 Dec 2014 11:59:17 -0800 (PST)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [RFC PATCH 2/4] mm, page_alloc: reduce number of alloc_pages* functions' parameters
Date: Fri,  5 Dec 2014 20:59:03 +0100
Message-Id: <1417809545-4540-3-git-send-email-vbabka@suse.cz>
In-Reply-To: <1417809545-4540-1-git-send-email-vbabka@suse.cz>
References: <1417809545-4540-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>

Introduce struct alloc_context to accumulate the numerous parameters passed
between the alloc_pages* family of functions and get_page_from_freelist().
This excludes gfp_flags and alloc_info, which mutate too much along the way.

The result is shorter function signatures, as well as code size and stack
usage reductions.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 mm/page_alloc.c | 228 +++++++++++++++++++++++++-------------------------------
 1 file changed, 100 insertions(+), 128 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index bfc00c3..1ee3ee1 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -232,6 +232,17 @@ EXPORT_SYMBOL(nr_node_ids);
 EXPORT_SYMBOL(nr_online_nodes);
 #endif
 
+struct alloc_context {
+	struct zonelist *zonelist;
+	nodemask_t *nodemask;
+	struct zone *preferred_zone;
+
+	unsigned int order;
+	int classzone_idx;
+	int migratetype;
+	enum zone_type high_zoneidx;
+};
+
 int page_group_by_mobility_disabled __read_mostly;
 
 void set_pageblock_migratetype(struct page *page, int migratetype)
@@ -2037,10 +2048,11 @@ static void reset_alloc_batches(struct zone *preferred_zone)
  * a page.
  */
 static struct page *
-get_page_from_freelist(gfp_t gfp_mask, nodemask_t *nodemask, unsigned int order,
-		struct zonelist *zonelist, int high_zoneidx, int alloc_flags,
-		struct zone *preferred_zone, int classzone_idx, int migratetype)
+get_page_from_freelist(gfp_t gfp_mask, int alloc_flags, const struct
+		alloc_context *ac)
 {
+	const unsigned int order = ac->order;
+	struct zonelist *zonelist = ac->zonelist;
 	struct zoneref *z;
 	struct page *page = NULL;
 	struct zone *zone;
@@ -2060,7 +2072,7 @@ zonelist_scan:
 	 * See also __cpuset_node_allowed() comment in kernel/cpuset.c.
 	 */
 	for_each_zone_zonelist_nodemask(zone, z, zonelist,
-						high_zoneidx, nodemask) {
+						ac->high_zoneidx, ac->nodemask) {
 		unsigned long mark;
 
 		if (IS_ENABLED(CONFIG_NUMA) && zlc_active &&
@@ -2077,7 +2089,7 @@ zonelist_scan:
 		 * time the page has in memory before being reclaimed.
 		 */
 		if (alloc_flags & ALLOC_FAIR) {
-			if (!zone_local(preferred_zone, zone))
+			if (!zone_local(ac->preferred_zone, zone))
 				break;
 			if (test_bit(ZONE_FAIR_DEPLETED, &zone->flags)) {
 				nr_fair_skipped++;
@@ -2115,7 +2127,7 @@ zonelist_scan:
 
 		mark = zone->watermark[alloc_flags & ALLOC_WMARK_MASK];
 		if (!zone_watermark_ok(zone, order, mark,
-				       classzone_idx, alloc_flags)) {
+				       ac->classzone_idx, alloc_flags)) {
 			int ret;
 
 			/* Checked here to keep the fast path fast */
@@ -2136,7 +2148,7 @@ zonelist_scan:
 			}
 
 			if (zone_reclaim_mode == 0 ||
-			    !zone_allows_reclaim(preferred_zone, zone))
+			    !zone_allows_reclaim(ac->preferred_zone, zone))
 				goto this_zone_full;
 
 			/*
@@ -2158,7 +2170,7 @@ zonelist_scan:
 			default:
 				/* did we reclaim enough */
 				if (zone_watermark_ok(zone, order, mark,
-						classzone_idx, alloc_flags))
+						ac->classzone_idx, alloc_flags))
 					goto try_this_zone;
 
 				/*
@@ -2179,8 +2191,8 @@ zonelist_scan:
 		}
 
 try_this_zone:
-		page = buffered_rmqueue(preferred_zone, zone, order,
-						gfp_mask, migratetype);
+		page = buffered_rmqueue(ac->preferred_zone, zone, order,
+						gfp_mask, ac->migratetype);
 		if (page) {
 			if (prep_new_page(page, order, gfp_mask, alloc_flags))
 				goto try_this_zone;
@@ -2203,7 +2215,7 @@ this_zone_full:
 		alloc_flags &= ~ALLOC_FAIR;
 		if (nr_fair_skipped) {
 			zonelist_rescan = true;
-			reset_alloc_batches(preferred_zone);
+			reset_alloc_batches(ac->preferred_zone);
 		}
 		if (nr_online_nodes > 1)
 			zonelist_rescan = true;
@@ -2324,15 +2336,13 @@ should_alloc_retry(gfp_t gfp_mask, unsigned int order,
 }
 
 static inline struct page *
-__alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
-	struct zonelist *zonelist, enum zone_type high_zoneidx,
-	nodemask_t *nodemask, struct zone *preferred_zone,
-	int classzone_idx, int migratetype)
+__alloc_pages_may_oom(gfp_t gfp_mask, int alloc_flags, const struct
+		alloc_context *ac)
 {
 	struct page *page;
 
 	/* Acquire the per-zone oom lock for each zone */
-	if (!oom_zonelist_trylock(zonelist, gfp_mask)) {
+	if (!oom_zonelist_trylock(ac->zonelist, gfp_mask)) {
 		schedule_timeout_uninterruptible(1);
 		return NULL;
 	}
@@ -2342,19 +2352,17 @@ __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
 	 * here, this is only to catch a parallel oom killing, we must fail if
 	 * we're still under heavy pressure.
 	 */
-	page = get_page_from_freelist(gfp_mask|__GFP_HARDWALL, nodemask,
-		order, zonelist, high_zoneidx,
-		ALLOC_WMARK_HIGH|ALLOC_CPUSET,
-		preferred_zone, classzone_idx, migratetype);
+	page = get_page_from_freelist(gfp_mask | __GFP_HARDWALL,
+					ALLOC_WMARK_HIGH|ALLOC_CPUSET, ac);
 	if (page)
 		goto out;
 
 	if (!(gfp_mask & __GFP_NOFAIL)) {
 		/* The OOM killer will not help higher order allocs */
-		if (order > PAGE_ALLOC_COSTLY_ORDER)
+		if (ac->order > PAGE_ALLOC_COSTLY_ORDER)
 			goto out;
 		/* The OOM killer does not needlessly kill tasks for lowmem */
-		if (high_zoneidx < ZONE_NORMAL)
+		if (ac->high_zoneidx < ZONE_NORMAL)
 			goto out;
 		/*
 		 * GFP_THISNODE contains __GFP_NORETRY and we never hit this.
@@ -2367,22 +2375,21 @@ __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
 			goto out;
 	}
 	/* Exhausted what can be done so it's blamo time */
-	out_of_memory(zonelist, gfp_mask, order, nodemask, false);
+	out_of_memory(ac->zonelist, gfp_mask, ac->order, ac->nodemask, false);
 
 out:
-	oom_zonelist_unlock(zonelist, gfp_mask);
+	oom_zonelist_unlock(ac->zonelist, gfp_mask);
 	return page;
 }
 
 #ifdef CONFIG_COMPACTION
 /* Try memory compaction for high-order allocations before reclaim */
 static struct page *
-__alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
-	struct zonelist *zonelist, enum zone_type high_zoneidx,
-	nodemask_t *nodemask, int alloc_flags, struct zone *preferred_zone,
-	int classzone_idx, int migratetype, enum migrate_mode mode,
+__alloc_pages_direct_compact(gfp_t gfp_mask, int alloc_flags,
+	const struct alloc_context *ac, enum migrate_mode mode,
 	int *contended_compaction, bool *deferred_compaction)
 {
+	const unsigned int order = ac->order;
 	unsigned long compact_result;
 	struct page *page;
 
@@ -2390,10 +2397,10 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
 		return NULL;
 
 	current->flags |= PF_MEMALLOC;
-	compact_result = try_to_compact_pages(zonelist, order, gfp_mask,
-						nodemask, mode,
+	compact_result = try_to_compact_pages(ac->zonelist, order, gfp_mask,
+						ac->nodemask, mode,
 						contended_compaction,
-						alloc_flags, classzone_idx);
+						alloc_flags, ac->classzone_idx);
 	current->flags &= ~PF_MEMALLOC;
 
 	switch (compact_result) {
@@ -2412,10 +2419,8 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
 	 */
 	count_vm_event(COMPACTSTALL);
 
-	page = get_page_from_freelist(gfp_mask, nodemask,
-			order, zonelist, high_zoneidx,
-			alloc_flags & ~ALLOC_NO_WATERMARKS,
-			preferred_zone, classzone_idx, migratetype);
+	page = get_page_from_freelist(gfp_mask,
+					alloc_flags & ~ALLOC_NO_WATERMARKS, ac);
 
 	if (page) {
 		struct zone *zone = page_zone(page);
@@ -2438,10 +2443,8 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
 }
 #else
 static inline struct page *
-__alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
-	struct zonelist *zonelist, enum zone_type high_zoneidx,
-	nodemask_t *nodemask, int alloc_flags, struct zone *preferred_zone,
-	int classzone_idx, int migratetype, enum migrate_mode mode,
+__alloc_pages_direct_compact(gfp_t gfp_mask, int alloc_flags,
+	const struct alloc_context *ac, enum migrate_mode mode,
 	int *contended_compaction, bool *deferred_compaction)
 {
 	return NULL;
@@ -2450,8 +2453,7 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
 
 /* Perform direct synchronous page reclaim */
 static int
-__perform_reclaim(gfp_t gfp_mask, unsigned int order, struct zonelist *zonelist,
-		  nodemask_t *nodemask)
+__perform_reclaim(gfp_t gfp_mask, const struct alloc_context *ac)
 {
 	struct reclaim_state reclaim_state;
 	int progress;
@@ -2465,7 +2467,8 @@ __perform_reclaim(gfp_t gfp_mask, unsigned int order, struct zonelist *zonelist,
 	reclaim_state.reclaimed_slab = 0;
 	current->reclaim_state = &reclaim_state;
 
-	progress = try_to_free_pages(zonelist, order, gfp_mask, nodemask);
+	progress = try_to_free_pages(ac->zonelist, ac->order, gfp_mask,
+								ac->nodemask);
 
 	current->reclaim_state = NULL;
 	lockdep_clear_current_reclaim_state();
@@ -2478,29 +2481,23 @@ __perform_reclaim(gfp_t gfp_mask, unsigned int order, struct zonelist *zonelist,
 
 /* The really slow allocator path where we enter direct reclaim */
 static inline struct page *
-__alloc_pages_direct_reclaim(gfp_t gfp_mask, unsigned int order,
-	struct zonelist *zonelist, enum zone_type high_zoneidx,
-	nodemask_t *nodemask, int alloc_flags, struct zone *preferred_zone,
-	int classzone_idx, int migratetype, unsigned long *did_some_progress)
+__alloc_pages_direct_reclaim(gfp_t gfp_mask, int alloc_flags,
+		const struct alloc_context *ac, unsigned long *did_some_progress)
 {
 	struct page *page = NULL;
 	bool drained = false;
 
-	*did_some_progress = __perform_reclaim(gfp_mask, order, zonelist,
-					       nodemask);
+	*did_some_progress = __perform_reclaim(gfp_mask, ac);
 	if (unlikely(!(*did_some_progress)))
 		return NULL;
 
 	/* After successful reclaim, reconsider all zones for allocation */
 	if (IS_ENABLED(CONFIG_NUMA))
-		zlc_clear_zones_full(zonelist);
+		zlc_clear_zones_full(ac->zonelist);
 
 retry:
-	page = get_page_from_freelist(gfp_mask, nodemask, order,
-					zonelist, high_zoneidx,
-					alloc_flags & ~ALLOC_NO_WATERMARKS,
-					preferred_zone, classzone_idx,
-					migratetype);
+	page = get_page_from_freelist(gfp_mask,
+					alloc_flags & ~ALLOC_NO_WATERMARKS, ac);
 
 	/*
 	 * If an allocation failed after direct reclaim, it could be because
@@ -2520,37 +2517,29 @@ retry:
  * sufficient urgency to ignore watermarks and take other desperate measures
  */
 static inline struct page *
-__alloc_pages_high_priority(gfp_t gfp_mask, unsigned int order,
-	struct zonelist *zonelist, enum zone_type high_zoneidx,
-	nodemask_t *nodemask, struct zone *preferred_zone,
-	int classzone_idx, int migratetype)
+__alloc_pages_high_priority(gfp_t gfp_mask, const struct alloc_context *ac)
 {
 	struct page *page;
 
 	do {
-		page = get_page_from_freelist(gfp_mask, nodemask, order,
-			zonelist, high_zoneidx, ALLOC_NO_WATERMARKS,
-			preferred_zone, classzone_idx, migratetype);
+		page = get_page_from_freelist(gfp_mask, ALLOC_NO_WATERMARKS, ac);
 
 		if (!page && gfp_mask & __GFP_NOFAIL)
-			wait_iff_congested(preferred_zone, BLK_RW_ASYNC, HZ/50);
+			wait_iff_congested(ac->preferred_zone, BLK_RW_ASYNC,
+									HZ/50);
 	} while (!page && (gfp_mask & __GFP_NOFAIL));
 
 	return page;
 }
 
-static void wake_all_kswapds(unsigned int order,
-			     struct zonelist *zonelist,
-			     enum zone_type high_zoneidx,
-			     struct zone *preferred_zone,
-			     nodemask_t *nodemask)
+static void wake_all_kswapds(const struct alloc_context *ac)
 {
 	struct zoneref *z;
 	struct zone *zone;
 
-	for_each_zone_zonelist_nodemask(zone, z, zonelist,
-						high_zoneidx, nodemask)
-		wakeup_kswapd(zone, order, zone_idx(preferred_zone));
+	for_each_zone_zonelist_nodemask(zone, z, ac->zonelist,
+						ac->high_zoneidx, ac->nodemask)
+		wakeup_kswapd(zone, ac->order, zone_idx(ac->preferred_zone));
 }
 
 static inline int
@@ -2608,11 +2597,9 @@ bool gfp_pfmemalloc_allowed(gfp_t gfp_mask)
 }
 
 static inline struct page *
-__alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
-	struct zonelist *zonelist, enum zone_type high_zoneidx,
-	nodemask_t *nodemask, struct zone *preferred_zone,
-	int classzone_idx, int migratetype)
+__alloc_pages_slowpath(gfp_t gfp_mask, struct alloc_context *ac)
 {
+	const unsigned int order = ac->order;
 	const gfp_t wait = gfp_mask & __GFP_WAIT;
 	struct page *page = NULL;
 	int alloc_flags;
@@ -2647,8 +2634,7 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 
 restart:
 	if (!(gfp_mask & __GFP_NO_KSWAPD))
-		wake_all_kswapds(order, zonelist, high_zoneidx,
-				preferred_zone, nodemask);
+		wake_all_kswapds(ac);
 
 	/*
 	 * OK, we're below the kswapd watermark and have kicked background
@@ -2661,18 +2647,17 @@ restart:
 	 * Find the true preferred zone if the allocation is unconstrained by
 	 * cpusets.
 	 */
-	if (!(alloc_flags & ALLOC_CPUSET) && !nodemask) {
+	if (!(alloc_flags & ALLOC_CPUSET) && !ac->nodemask) {
 		struct zoneref *preferred_zoneref;
-		preferred_zoneref = first_zones_zonelist(zonelist, high_zoneidx,
-				NULL, &preferred_zone);
-		classzone_idx = zonelist_zone_idx(preferred_zoneref);
+		preferred_zoneref = first_zones_zonelist(ac->zonelist,
+				ac->high_zoneidx, NULL, &ac->preferred_zone);
+		ac->classzone_idx = zonelist_zone_idx(preferred_zoneref);
 	}
 
 rebalance:
 	/* This is the last chance, in general, before the goto nopage. */
-	page = get_page_from_freelist(gfp_mask, nodemask, order, zonelist,
-			high_zoneidx, alloc_flags & ~ALLOC_NO_WATERMARKS,
-			preferred_zone, classzone_idx, migratetype);
+	page = get_page_from_freelist(gfp_mask,
+				alloc_flags & ~ALLOC_NO_WATERMARKS, ac);
 	if (page)
 		goto got_pg;
 
@@ -2683,11 +2668,10 @@ rebalance:
 		 * the allocation is high priority and these type of
 		 * allocations are system rather than user orientated
 		 */
-		zonelist = node_zonelist(numa_node_id(), gfp_mask);
+		ac->zonelist = node_zonelist(numa_node_id(), gfp_mask);
+
+		page = __alloc_pages_high_priority(gfp_mask, ac);
 
-		page = __alloc_pages_high_priority(gfp_mask, order,
-				zonelist, high_zoneidx, nodemask,
-				preferred_zone, classzone_idx, migratetype);
 		if (page) {
 			goto got_pg;
 		}
@@ -2716,11 +2700,9 @@ rebalance:
 	 * Try direct compaction. The first pass is asynchronous. Subsequent
 	 * attempts after direct reclaim are synchronous
 	 */
-	page = __alloc_pages_direct_compact(gfp_mask, order, zonelist,
-					high_zoneidx, nodemask, alloc_flags,
-					preferred_zone,
-					classzone_idx, migratetype,
-					migration_mode, &contended_compaction,
+	page = __alloc_pages_direct_compact(gfp_mask, alloc_flags, ac,
+					migration_mode,
+					&contended_compaction,
 					&deferred_compaction);
 	if (page)
 		goto got_pg;
@@ -2766,12 +2748,8 @@ rebalance:
 		migration_mode = MIGRATE_SYNC_LIGHT;
 
 	/* Try direct reclaim and then allocating */
-	page = __alloc_pages_direct_reclaim(gfp_mask, order,
-					zonelist, high_zoneidx,
-					nodemask,
-					alloc_flags, preferred_zone,
-					classzone_idx, migratetype,
-					&did_some_progress);
+	page = __alloc_pages_direct_reclaim(gfp_mask, alloc_flags, ac,
+							&did_some_progress);
 	if (page)
 		goto got_pg;
 
@@ -2787,10 +2765,7 @@ rebalance:
 			if ((current->flags & PF_DUMPCORE) &&
 			    !(gfp_mask & __GFP_NOFAIL))
 				goto nopage;
-			page = __alloc_pages_may_oom(gfp_mask, order,
-					zonelist, high_zoneidx,
-					nodemask, preferred_zone,
-					classzone_idx, migratetype);
+			page = __alloc_pages_may_oom(gfp_mask, alloc_flags, ac);
 			if (page)
 				goto got_pg;
 
@@ -2808,7 +2783,7 @@ rebalance:
 				 * allocations to prevent needlessly killing
 				 * innocent tasks.
 				 */
-				if (high_zoneidx < ZONE_NORMAL)
+				if (ac->high_zoneidx < ZONE_NORMAL)
 					goto nopage;
 			}
 
@@ -2821,7 +2796,7 @@ rebalance:
 	if (should_alloc_retry(gfp_mask, order, did_some_progress,
 						pages_reclaimed)) {
 		/* Wait for some write requests to complete then retry */
-		wait_iff_congested(preferred_zone, BLK_RW_ASYNC, HZ/50);
+		wait_iff_congested(ac->preferred_zone, BLK_RW_ASYNC, HZ/50);
 		goto rebalance;
 	} else {
 		/*
@@ -2829,11 +2804,9 @@ rebalance:
 		 * direct reclaim and reclaim/compaction depends on compaction
 		 * being called after reclaim so call directly if necessary
 		 */
-		page = __alloc_pages_direct_compact(gfp_mask, order, zonelist,
-					high_zoneidx, nodemask, alloc_flags,
-					preferred_zone,
-					classzone_idx, migratetype,
-					migration_mode, &contended_compaction,
+		page = __alloc_pages_direct_compact(gfp_mask, alloc_flags, ac,
+					migration_mode,
+					&contended_compaction,
 					&deferred_compaction);
 		if (page)
 			goto got_pg;
@@ -2856,14 +2829,16 @@ struct page *
 __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
 			struct zonelist *zonelist, nodemask_t *nodemask)
 {
-	enum zone_type high_zoneidx = gfp_zone(gfp_mask);
-	struct zone *preferred_zone;
 	struct zoneref *preferred_zoneref;
 	struct page *page = NULL;
-	int migratetype = gfpflags_to_migratetype(gfp_mask);
 	unsigned int cpuset_mems_cookie;
 	int alloc_flags = ALLOC_WMARK_LOW|ALLOC_CPUSET|ALLOC_FAIR;
-	int classzone_idx;
+	struct alloc_context ac = {
+		.order = order,
+		.high_zoneidx = gfp_zone(gfp_mask),
+		.nodemask = nodemask,
+		.migratetype = gfpflags_to_migratetype(gfp_mask),
+	};
 
 	gfp_mask &= gfp_allowed_mask;
 
@@ -2882,38 +2857,35 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
 	if (unlikely(!zonelist->_zonerefs->zone))
 		return NULL;
 
-	if (IS_ENABLED(CONFIG_CMA) && migratetype == MIGRATE_MOVABLE)
+	if (IS_ENABLED(CONFIG_CMA) && ac.migratetype == MIGRATE_MOVABLE)
 		alloc_flags |= ALLOC_CMA;
 
 retry_cpuset:
 	cpuset_mems_cookie = read_mems_allowed_begin();
 
+	/* We set it here, as __alloc_pages_slowpath might have changed it */
+	ac.zonelist = zonelist;
 	/* The preferred zone is used for statistics later */
-	preferred_zoneref = first_zones_zonelist(zonelist, high_zoneidx,
-				nodemask ? : &cpuset_current_mems_allowed,
-				&preferred_zone);
-	if (!preferred_zone)
+	preferred_zoneref = first_zones_zonelist(ac.zonelist, ac.high_zoneidx,
+				ac.nodemask ? : &cpuset_current_mems_allowed,
+				&ac.preferred_zone);
+	if (!ac.preferred_zone)
 		goto out;
-	classzone_idx = zonelist_zone_idx(preferred_zoneref);
+	ac.classzone_idx = zonelist_zone_idx(preferred_zoneref);
 
 	/* First allocation attempt */
-	page = get_page_from_freelist(gfp_mask|__GFP_HARDWALL, nodemask, order,
-			zonelist, high_zoneidx, alloc_flags,
-			preferred_zone, classzone_idx, migratetype);
+	page = get_page_from_freelist(gfp_mask|__GFP_HARDWALL, alloc_flags, &ac);
 	if (unlikely(!page)) {
 		/*
 		 * Runtime PM, block IO and its error handling path
 		 * can deadlock because I/O on the device might not
 		 * complete.
 		 */
-		gfp_t mask = memalloc_noio_flags(gfp_mask);
-
-		page = __alloc_pages_slowpath(mask, order,
-				zonelist, high_zoneidx, nodemask,
-				preferred_zone, classzone_idx, migratetype);
+		gfp_mask = memalloc_noio_flags(gfp_mask);
+		page = __alloc_pages_slowpath(gfp_mask, &ac);
 	}
 
-	trace_mm_page_alloc(page, order, gfp_mask, migratetype);
+	trace_mm_page_alloc(page, order, gfp_mask, ac.migratetype);
 
 out:
 	/*
-- 
2.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
