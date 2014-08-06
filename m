Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f49.google.com (mail-wg0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 945216B0099
	for <linux-mm@kvack.org>; Wed,  6 Aug 2014 09:56:19 -0400 (EDT)
Received: by mail-wg0-f49.google.com with SMTP id k14so2721956wgh.32
        for <linux-mm@kvack.org>; Wed, 06 Aug 2014 06:56:19 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d12si3374038wic.93.2014.08.06.06.56.14
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 06 Aug 2014 06:56:14 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [RFC 4/4] mm, page_alloc: make gfp_mask a separate parameter again
Date: Wed,  6 Aug 2014 15:55:56 +0200
Message-Id: <1407333356-30928-5-git-send-email-vbabka@suse.cz>
In-Reply-To: <1407333356-30928-1-git-send-email-vbabka@suse.cz>
References: <1407333356-30928-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Vlastimil Babka <vbabka@suse.cz>

Similarly to alloc_flags, gfp_mask sometimes changes and is heavily used
so it might benefit from being passed in a register.
---
 mm/page_alloc.c | 85 +++++++++++++++++++++++++++++----------------------------
 1 file changed, 43 insertions(+), 42 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index c06ad53..b5c5944 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -237,7 +237,6 @@ struct alloc_info {
 	struct zone *preferred_zone;
 
 	unsigned int order;
-	gfp_t gfp_mask;
 	int classzone_idx;
 	int migratetype;
 	enum zone_type high_zoneidx;
@@ -1955,7 +1954,7 @@ static void reset_alloc_batches(struct zone *preferred_zone)
  * a page.
  */
 static struct page *
-get_page_from_freelist(int alloc_flags, const struct alloc_info *ai)
+get_page_from_freelist(gfp_t gfp_mask, int alloc_flags, const struct alloc_info *ai)
 {
 	const unsigned int order = ai->order;
 	struct zonelist *zonelist = ai->zonelist;
@@ -1966,7 +1965,7 @@ get_page_from_freelist(int alloc_flags, const struct alloc_info *ai)
 	int zlc_active = 0;		/* set if using zonelist_cache */
 	int did_zlc_setup = 0;		/* just call zlc_setup() one time */
 	bool consider_zone_dirty = (alloc_flags & ALLOC_WMARK_LOW) &&
-				(ai->gfp_mask & __GFP_WRITE);
+				(gfp_mask & __GFP_WRITE);
 	int nr_fair_skipped = 0;
 	bool zonelist_rescan;
 
@@ -1986,7 +1985,7 @@ zonelist_scan:
 				continue;
 		if (cpusets_enabled() &&
 			(alloc_flags & ALLOC_CPUSET) &&
-			!cpuset_zone_allowed_softwall(zone, ai->gfp_mask))
+			!cpuset_zone_allowed_softwall(zone, gfp_mask))
 				continue;
 		/*
 		 * Distribute pages in proportion to the individual
@@ -2065,7 +2064,7 @@ zonelist_scan:
 				!zlc_zone_worth_trying(zonelist, z, allowednodes))
 				continue;
 
-			ret = zone_reclaim(zone, ai->gfp_mask, order);
+			ret = zone_reclaim(zone, gfp_mask, order);
 			switch (ret) {
 			case ZONE_RECLAIM_NOSCAN:
 				/* did not scan */
@@ -2098,7 +2097,7 @@ zonelist_scan:
 
 try_this_zone:
 		page = buffered_rmqueue(ai->preferred_zone, zone, order,
-						ai->gfp_mask, ai->migratetype);
+						gfp_mask, ai->migratetype);
 		if (page)
 			break;
 this_zone_full:
@@ -2251,13 +2250,12 @@ should_alloc_retry(gfp_t gfp_mask, unsigned int order,
 }
 
 static inline struct page *
-__alloc_pages_may_oom(int alloc_flags, struct alloc_info *ai)
+__alloc_pages_may_oom(gfp_t gfp_mask, int alloc_flags, const struct alloc_info *ai)
 {
 	struct page *page;
-	const gfp_t gfp_mask = ai->gfp_mask;
 
 	/* Acquire the per-zone oom lock for each zone */
-	if (!oom_zonelist_trylock(ai->zonelist, ai->gfp_mask)) {
+	if (!oom_zonelist_trylock(ai->zonelist, gfp_mask)) {
 		schedule_timeout_uninterruptible(1);
 		return NULL;
 	}
@@ -2267,10 +2265,8 @@ __alloc_pages_may_oom(int alloc_flags, struct alloc_info *ai)
 	 * here, this is only to catch a parallel oom killing, we must fail if
 	 * we're still under heavy pressure.
 	 */
-	ai->gfp_mask |= __GFP_HARDWALL;
-	page = get_page_from_freelist(ALLOC_WMARK_HIGH|ALLOC_CPUSET, ai);
-	ai->gfp_mask = gfp_mask;
-
+	page = get_page_from_freelist(gfp_mask | __GFP_HARDWALL,
+					ALLOC_WMARK_HIGH|ALLOC_CPUSET, ai);
 	if (page)
 		goto out;
 
@@ -2302,9 +2298,10 @@ out:
 #ifdef CONFIG_COMPACTION
 /* Try memory compaction for high-order allocations before reclaim */
 static struct page *
-__alloc_pages_direct_compact(int alloc_flags, const struct alloc_info *ai,
-	enum migrate_mode mode, bool *contended_compaction,
-	bool *deferred_compaction, unsigned long *did_some_progress)
+__alloc_pages_direct_compact(gfp_t gfp_mask, int alloc_flags,
+	const struct alloc_info *ai, enum migrate_mode mode,
+	bool *contended_compaction, bool *deferred_compaction,
+	unsigned long *did_some_progress)
 {
 	const unsigned int order = ai->order;
 	struct zone *preferred_zone = ai->preferred_zone;
@@ -2318,7 +2315,7 @@ __alloc_pages_direct_compact(int alloc_flags, const struct alloc_info *ai,
 	}
 
 	current->flags |= PF_MEMALLOC;
-	*did_some_progress = try_to_compact_pages(ai->zonelist, order, ai->gfp_mask,
+	*did_some_progress = try_to_compact_pages(ai->zonelist, order, gfp_mask,
 						ai->nodemask, mode,
 						contended_compaction);
 	current->flags &= ~PF_MEMALLOC;
@@ -2330,7 +2327,7 @@ __alloc_pages_direct_compact(int alloc_flags, const struct alloc_info *ai,
 		drain_pages(get_cpu());
 		put_cpu();
 
-		page = get_page_from_freelist(alloc_flags &
+		page = get_page_from_freelist(gfp_mask, alloc_flags &
 				~ALLOC_NO_WATERMARKS, ai);
 
 		if (page) {
@@ -2361,9 +2358,10 @@ __alloc_pages_direct_compact(int alloc_flags, const struct alloc_info *ai,
 }
 #else
 static inline struct page *
-__alloc_pages_direct_compact(int alloc_flags, const struct alloc_info *ai,
-	enum migrate_mode mode, bool *contended_compaction,
-	bool *deferred_compaction, unsigned long *did_some_progress)
+__alloc_pages_direct_compact(gfp_t gfp_mask, int alloc_flags,
+	const struct alloc_info *ai, enum migrate_mode mode,
+	bool *contended_compaction, bool *deferred_compaction,
+	unsigned long *did_some_progress)
 {
 	return NULL;
 }
@@ -2399,13 +2397,13 @@ __perform_reclaim(gfp_t gfp_mask, unsigned int order, struct zonelist *zonelist,
 
 /* The really slow allocator path where we enter direct reclaim */
 static inline struct page *
-__alloc_pages_direct_reclaim(int alloc_flags, const struct alloc_info *ai,
-				unsigned long *did_some_progress)
+__alloc_pages_direct_reclaim(gfp_t gfp_mask, int alloc_flags,
+		const struct alloc_info *ai, unsigned long *did_some_progress)
 {
 	struct page *page = NULL;
 	bool drained = false;
 
-	*did_some_progress = __perform_reclaim(ai->gfp_mask, ai->order,
+	*did_some_progress = __perform_reclaim(gfp_mask, ai->order,
 						ai->zonelist, ai->nodemask);
 	if (unlikely(!(*did_some_progress)))
 		return NULL;
@@ -2415,7 +2413,8 @@ __alloc_pages_direct_reclaim(int alloc_flags, const struct alloc_info *ai,
 		zlc_clear_zones_full(ai->zonelist);
 
 retry:
-	page = get_page_from_freelist(alloc_flags & ~ALLOC_NO_WATERMARKS, ai);
+	page = get_page_from_freelist(gfp_mask,
+					alloc_flags & ~ALLOC_NO_WATERMARKS, ai);
 
 	/*
 	 * If an allocation failed after direct reclaim, it could be because
@@ -2435,17 +2434,17 @@ retry:
  * sufficient urgency to ignore watermarks and take other desperate measures
  */
 static inline struct page *
-__alloc_pages_high_priority(const struct alloc_info *ai)
+__alloc_pages_high_priority(gfp_t gfp_mask, const struct alloc_info *ai)
 {
 	struct page *page;
 
 	do {
-		page = get_page_from_freelist(ALLOC_NO_WATERMARKS, ai);
+		page = get_page_from_freelist(gfp_mask, ALLOC_NO_WATERMARKS, ai);
 
-		if (!page && ai->gfp_mask & __GFP_NOFAIL)
+		if (!page && gfp_mask & __GFP_NOFAIL)
 			wait_iff_congested(ai->preferred_zone, BLK_RW_ASYNC,
 									HZ/50);
-	} while (!page && (ai->gfp_mask & __GFP_NOFAIL));
+	} while (!page && (gfp_mask & __GFP_NOFAIL));
 
 	return page;
 }
@@ -2517,10 +2516,9 @@ bool gfp_pfmemalloc_allowed(gfp_t gfp_mask)
 }
 
 static inline struct page *
-__alloc_pages_slowpath(struct alloc_info *ai)
+__alloc_pages_slowpath(gfp_t gfp_mask, struct alloc_info *ai)
 {
 	const unsigned int order = ai->order;
-	const gfp_t gfp_mask = ai->gfp_mask;
 	const gfp_t wait = gfp_mask & __GFP_WAIT;
 	struct page *page = NULL;
 	int alloc_flags;
@@ -2578,7 +2576,8 @@ restart:
 
 rebalance:
 	/* This is the last chance, in general, before the goto nopage. */
-	page = get_page_from_freelist(alloc_flags & ~ALLOC_NO_WATERMARKS, ai);
+	page = get_page_from_freelist(gfp_mask,
+				alloc_flags & ~ALLOC_NO_WATERMARKS, ai);
 	if (page)
 		goto got_pg;
 
@@ -2591,7 +2590,7 @@ rebalance:
 		 */
 		ai->zonelist = node_zonelist(numa_node_id(), gfp_mask);
 
-		page = __alloc_pages_high_priority(ai);
+		page = __alloc_pages_high_priority(gfp_mask, ai);
 
 		if (page) {
 			goto got_pg;
@@ -2621,7 +2620,8 @@ rebalance:
 	 * Try direct compaction. The first pass is asynchronous. Subsequent
 	 * attempts after direct reclaim are synchronous
 	 */
-	page = __alloc_pages_direct_compact(alloc_flags, ai, migration_mode,
+	page = __alloc_pages_direct_compact(gfp_mask, alloc_flags, ai,
+					migration_mode,
 					&contended_compaction,
 					&deferred_compaction,
 					&did_some_progress);
@@ -2648,7 +2648,8 @@ rebalance:
 		migration_mode = MIGRATE_SYNC_LIGHT;
 
 	/* Try direct reclaim and then allocating */
-	page = __alloc_pages_direct_reclaim(alloc_flags, ai, &did_some_progress);
+	page = __alloc_pages_direct_reclaim(gfp_mask, alloc_flags, ai,
+							&did_some_progress);
 	if (page)
 		goto got_pg;
 
@@ -2664,7 +2665,7 @@ rebalance:
 			if ((current->flags & PF_DUMPCORE) &&
 			    !(gfp_mask & __GFP_NOFAIL))
 				goto nopage;
-			page = __alloc_pages_may_oom(alloc_flags, ai);
+			page = __alloc_pages_may_oom(gfp_mask, alloc_flags, ai);
 			if (page)
 				goto got_pg;
 
@@ -2703,7 +2704,8 @@ rebalance:
 		 * direct reclaim and reclaim/compaction depends on compaction
 		 * being called after reclaim so call directly if necessary
 		 */
-		page = __alloc_pages_direct_compact(alloc_flags, ai, migration_mode,
+		page = __alloc_pages_direct_compact(gfp_mask, alloc_flags, ai,
+					migration_mode,
 					&contended_compaction,
 					&deferred_compaction,
 					&did_some_progress);
@@ -2772,19 +2774,18 @@ retry_cpuset:
 	ai.classzone_idx = zonelist_zone_idx(preferred_zoneref);
 
 	/* First allocation attempt */
-	ai.gfp_mask = gfp_mask|__GFP_HARDWALL;
-	page = get_page_from_freelist(alloc_flags, &ai);
+	page = get_page_from_freelist(gfp_mask|__GFP_HARDWALL, alloc_flags, &ai);
 	if (unlikely(!page)) {
 		/*
 		 * Runtime PM, block IO and its error handling path
 		 * can deadlock because I/O on the device might not
 		 * complete.
 		 */
-		ai.gfp_mask = memalloc_noio_flags(gfp_mask);
-		page = __alloc_pages_slowpath(&ai);
+		gfp_mask = memalloc_noio_flags(gfp_mask);
+		page = __alloc_pages_slowpath(gfp_mask, &ai);
 	}
 
-	trace_mm_page_alloc(page, order, ai.gfp_mask, ai.migratetype);
+	trace_mm_page_alloc(page, order, gfp_mask, ai.migratetype);
 
 out:
 	/*
-- 
1.8.4.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
