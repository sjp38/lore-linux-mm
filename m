Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f180.google.com (mail-we0-f180.google.com [74.125.82.180])
	by kanga.kvack.org (Postfix) with ESMTP id 6DDD66B0098
	for <linux-mm@kvack.org>; Wed,  6 Aug 2014 09:56:18 -0400 (EDT)
Received: by mail-we0-f180.google.com with SMTP id w61so2678584wes.39
        for <linux-mm@kvack.org>; Wed, 06 Aug 2014 06:56:18 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w12si8771415wiv.0.2014.08.06.06.56.14
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 06 Aug 2014 06:56:14 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [RFC 3/4] mm, page_alloc: make alloc_flags a separate parameter again
Date: Wed,  6 Aug 2014 15:55:55 +0200
Message-Id: <1407333356-30928-4-git-send-email-vbabka@suse.cz>
In-Reply-To: <1407333356-30928-1-git-send-email-vbabka@suse.cz>
References: <1407333356-30928-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Vlastimil Babka <vbabka@suse.cz>

The alloc_flags parameter often changes between the various alloc_pages*
function so make it separate again to prevent the need for saving it etc.
It is also heavily used so it might benefit from being passed by register.
---
 mm/page_alloc.c | 62 +++++++++++++++++++++------------------------------------
 1 file changed, 23 insertions(+), 39 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 399d40d..c06ad53 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -238,7 +238,6 @@ struct alloc_info {
 
 	unsigned int order;
 	gfp_t gfp_mask;
-	int alloc_flags;
 	int classzone_idx;
 	int migratetype;
 	enum zone_type high_zoneidx;
@@ -1956,10 +1955,9 @@ static void reset_alloc_batches(struct zone *preferred_zone)
  * a page.
  */
 static struct page *
-get_page_from_freelist(const struct alloc_info *ai)
+get_page_from_freelist(int alloc_flags, const struct alloc_info *ai)
 {
 	const unsigned int order = ai->order;
-	int alloc_flags = ai->alloc_flags;
 	struct zonelist *zonelist = ai->zonelist;
 	struct zoneref *z;
 	struct page *page = NULL;
@@ -2253,11 +2251,10 @@ should_alloc_retry(gfp_t gfp_mask, unsigned int order,
 }
 
 static inline struct page *
-__alloc_pages_may_oom(struct alloc_info *ai)
+__alloc_pages_may_oom(int alloc_flags, struct alloc_info *ai)
 {
 	struct page *page;
 	const gfp_t gfp_mask = ai->gfp_mask;
-	const int alloc_flags_saved = ai->alloc_flags;
 
 	/* Acquire the per-zone oom lock for each zone */
 	if (!oom_zonelist_trylock(ai->zonelist, ai->gfp_mask)) {
@@ -2271,10 +2268,8 @@ __alloc_pages_may_oom(struct alloc_info *ai)
 	 * we're still under heavy pressure.
 	 */
 	ai->gfp_mask |= __GFP_HARDWALL;
-	ai->alloc_flags = ALLOC_WMARK_HIGH|ALLOC_CPUSET;
-	page = get_page_from_freelist(ai);
+	page = get_page_from_freelist(ALLOC_WMARK_HIGH|ALLOC_CPUSET, ai);
 	ai->gfp_mask = gfp_mask;
-	ai->alloc_flags = alloc_flags_saved;
 
 	if (page)
 		goto out;
@@ -2307,13 +2302,12 @@ out:
 #ifdef CONFIG_COMPACTION
 /* Try memory compaction for high-order allocations before reclaim */
 static struct page *
-__alloc_pages_direct_compact(struct alloc_info *ai, enum migrate_mode mode,
-	bool *contended_compaction, bool *deferred_compaction,
-	unsigned long *did_some_progress)
+__alloc_pages_direct_compact(int alloc_flags, const struct alloc_info *ai,
+	enum migrate_mode mode, bool *contended_compaction,
+	bool *deferred_compaction, unsigned long *did_some_progress)
 {
 	const unsigned int order = ai->order;
 	struct zone *preferred_zone = ai->preferred_zone;
-	const int alloc_flags_saved = ai->alloc_flags;
 
 	if (!order)
 		return NULL;
@@ -2336,9 +2330,8 @@ __alloc_pages_direct_compact(struct alloc_info *ai, enum migrate_mode mode,
 		drain_pages(get_cpu());
 		put_cpu();
 
-		ai->alloc_flags &= ~ALLOC_NO_WATERMARKS;
-		page = get_page_from_freelist(ai);
-		ai->alloc_flags = alloc_flags_saved;
+		page = get_page_from_freelist(alloc_flags &
+				~ALLOC_NO_WATERMARKS, ai);
 
 		if (page) {
 			preferred_zone->compact_blockskip_flush = false;
@@ -2368,9 +2361,9 @@ __alloc_pages_direct_compact(struct alloc_info *ai, enum migrate_mode mode,
 }
 #else
 static inline struct page *
-__alloc_pages_direct_compact(struct alloc_info *ai, enum migrate_mode mode,
-	bool *contended_compaction, bool *deferred_compaction,
-	unsigned long *did_some_progress)
+__alloc_pages_direct_compact(int alloc_flags, const struct alloc_info *ai,
+	enum migrate_mode mode, bool *contended_compaction,
+	bool *deferred_compaction, unsigned long *did_some_progress)
 {
 	return NULL;
 }
@@ -2406,12 +2399,11 @@ __perform_reclaim(gfp_t gfp_mask, unsigned int order, struct zonelist *zonelist,
 
 /* The really slow allocator path where we enter direct reclaim */
 static inline struct page *
-__alloc_pages_direct_reclaim(struct alloc_info *ai,
+__alloc_pages_direct_reclaim(int alloc_flags, const struct alloc_info *ai,
 				unsigned long *did_some_progress)
 {
 	struct page *page = NULL;
 	bool drained = false;
-	const int alloc_flags_saved = ai->alloc_flags;
 
 	*did_some_progress = __perform_reclaim(ai->gfp_mask, ai->order,
 						ai->zonelist, ai->nodemask);
@@ -2422,9 +2414,8 @@ __alloc_pages_direct_reclaim(struct alloc_info *ai,
 	if (IS_ENABLED(CONFIG_NUMA))
 		zlc_clear_zones_full(ai->zonelist);
 
-	ai->alloc_flags &= ~ALLOC_NO_WATERMARKS;
 retry:
-	page = get_page_from_freelist(ai);
+	page = get_page_from_freelist(alloc_flags & ~ALLOC_NO_WATERMARKS, ai);
 
 	/*
 	 * If an allocation failed after direct reclaim, it could be because
@@ -2436,7 +2427,6 @@ retry:
 		goto retry;
 	}
 
-	ai->alloc_flags = alloc_flags_saved;
 	return page;
 }
 
@@ -2445,21 +2435,18 @@ retry:
  * sufficient urgency to ignore watermarks and take other desperate measures
  */
 static inline struct page *
-__alloc_pages_high_priority(struct alloc_info *ai)
+__alloc_pages_high_priority(const struct alloc_info *ai)
 {
 	struct page *page;
-	const int alloc_flags_saved = ai->alloc_flags;
 
-	ai->alloc_flags = ALLOC_NO_WATERMARKS;
 	do {
-		page = get_page_from_freelist(ai);
+		page = get_page_from_freelist(ALLOC_NO_WATERMARKS, ai);
 
 		if (!page && ai->gfp_mask & __GFP_NOFAIL)
 			wait_iff_congested(ai->preferred_zone, BLK_RW_ASYNC,
 									HZ/50);
 	} while (!page && (ai->gfp_mask & __GFP_NOFAIL));
 
-	ai->alloc_flags = alloc_flags_saved;
 	return page;
 }
 
@@ -2591,15 +2578,12 @@ restart:
 
 rebalance:
 	/* This is the last chance, in general, before the goto nopage. */
-	ai->alloc_flags = alloc_flags & ~ALLOC_NO_WATERMARKS;
-	page = get_page_from_freelist(ai);
+	page = get_page_from_freelist(alloc_flags & ~ALLOC_NO_WATERMARKS, ai);
 	if (page)
 		goto got_pg;
 
 	/* Allocate without watermarks if the context allows */
 	if (alloc_flags & ALLOC_NO_WATERMARKS) {
-		/* We have removed ALLOC_NO_WATERMARKS from alloc_info */
-		ai->alloc_flags = alloc_flags;
 		/*
 		 * Ignore mempolicies if ALLOC_NO_WATERMARKS on the grounds
 		 * the allocation is high priority and these type of
@@ -2637,7 +2621,7 @@ rebalance:
 	 * Try direct compaction. The first pass is asynchronous. Subsequent
 	 * attempts after direct reclaim are synchronous
 	 */
-	page = __alloc_pages_direct_compact(ai, migration_mode,
+	page = __alloc_pages_direct_compact(alloc_flags, ai, migration_mode,
 					&contended_compaction,
 					&deferred_compaction,
 					&did_some_progress);
@@ -2664,7 +2648,7 @@ rebalance:
 		migration_mode = MIGRATE_SYNC_LIGHT;
 
 	/* Try direct reclaim and then allocating */
-	page = __alloc_pages_direct_reclaim(ai, &did_some_progress);
+	page = __alloc_pages_direct_reclaim(alloc_flags, ai, &did_some_progress);
 	if (page)
 		goto got_pg;
 
@@ -2680,7 +2664,7 @@ rebalance:
 			if ((current->flags & PF_DUMPCORE) &&
 			    !(gfp_mask & __GFP_NOFAIL))
 				goto nopage;
-			page = __alloc_pages_may_oom(ai);
+			page = __alloc_pages_may_oom(alloc_flags, ai);
 			if (page)
 				goto got_pg;
 
@@ -2719,7 +2703,7 @@ rebalance:
 		 * direct reclaim and reclaim/compaction depends on compaction
 		 * being called after reclaim so call directly if necessary
 		 */
-		page = __alloc_pages_direct_compact(ai, migration_mode,
+		page = __alloc_pages_direct_compact(alloc_flags, ai, migration_mode,
 					&contended_compaction,
 					&deferred_compaction,
 					&did_some_progress);
@@ -2747,9 +2731,9 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
 	struct zoneref *preferred_zoneref;
 	struct page *page = NULL;
 	unsigned int cpuset_mems_cookie;
+	int alloc_flags = ALLOC_WMARK_LOW|ALLOC_CPUSET|ALLOC_FAIR;
 	struct alloc_info ai = {
 		.order = order,
-		.alloc_flags = ALLOC_WMARK_LOW|ALLOC_CPUSET|ALLOC_FAIR,
 		.zonelist = zonelist,
 		.high_zoneidx = gfp_zone(gfp_mask),
 		.nodemask = nodemask,
@@ -2774,7 +2758,7 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
 		return NULL;
 
 	if (IS_ENABLED(CONFIG_CMA) && ai.migratetype == MIGRATE_MOVABLE)
-		ai.alloc_flags |= ALLOC_CMA;
+		alloc_flags |= ALLOC_CMA;
 
 retry_cpuset:
 	cpuset_mems_cookie = read_mems_allowed_begin();
@@ -2789,7 +2773,7 @@ retry_cpuset:
 
 	/* First allocation attempt */
 	ai.gfp_mask = gfp_mask|__GFP_HARDWALL;
-	page = get_page_from_freelist(&ai);
+	page = get_page_from_freelist(alloc_flags, &ai);
 	if (unlikely(!page)) {
 		/*
 		 * Runtime PM, block IO and its error handling path
-- 
1.8.4.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
