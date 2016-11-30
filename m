Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8A6676B0260
	for <linux-mm@kvack.org>; Tue, 29 Nov 2016 19:16:20 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id q10so465210016pgq.7
        for <linux-mm@kvack.org>; Tue, 29 Nov 2016 16:16:20 -0800 (PST)
Received: from mail-pf0-x231.google.com (mail-pf0-x231.google.com. [2607:f8b0:400e:c00::231])
        by mx.google.com with ESMTPS id f35si33219659plh.192.2016.11.29.16.16.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Nov 2016 16:16:19 -0800 (PST)
Received: by mail-pf0-x231.google.com with SMTP id i88so34753024pfk.2
        for <linux-mm@kvack.org>; Tue, 29 Nov 2016 16:16:19 -0800 (PST)
Date: Tue, 29 Nov 2016 16:16:18 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: [patch v2 2/2] mm, compaction: avoid async compaction if most free
 memory is ineligible
In-Reply-To: <alpine.DEB.2.10.1611291615400.103050@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.10.1611291616020.103050@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1611161731350.17379@chino.kir.corp.google.com> <alpine.DEB.2.10.1611291615400.103050@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Memory compaction will only migrate memory to MIGRATE_MOVABLE pageblocks
for asynchronous compaction.

If most free memory on the system is not eligible for migration in this
context, isolate_freepages() can take an extreme amount of time trying to
find a free page.  For example, we have encountered the following
scenario many times, specifically due to slab fragmentation:

Free pages count per migrate type at order       0      1      2      3      4      5      6      7      8      9     10 
Node    0, zone   Normal, type    Unmovable  40000   3778      2      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, type  Reclaimable     11      6      0      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, type      Movable      1      1      0      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, type      Reserve      0      0      0      0      0      0      0      0      0      0      0

The compaction freeing scanner will end up scanning this entire zone,
perhaps finding no memory free and terminating compaction after pages
have already been isolated for migration.  It is unnecessary to even
start async compaction in a scenario where free memory cannot be
isolated as a migration target.

This patch does not deem async compaction to be suitable when the
watermark checks using only the amount of free movable memory fails.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 v2: convert to per-zone watermark check

 fs/buffer.c                |  2 +-
 include/linux/compaction.h |  8 ++++----
 include/linux/swap.h       |  3 ++-
 mm/compaction.c            | 37 ++++++++++++++++++++++++++++---------
 mm/internal.h              |  1 +
 mm/page_alloc.c            | 15 ++++++++-------
 mm/vmscan.c                | 20 +++++++++++++++++---
 7 files changed, 61 insertions(+), 25 deletions(-)

diff --git a/fs/buffer.c b/fs/buffer.c
--- a/fs/buffer.c
+++ b/fs/buffer.c
@@ -268,7 +268,7 @@ static void free_more_memory(void)
 						gfp_zone(GFP_NOFS), NULL);
 		if (z->zone)
 			try_to_free_pages(node_zonelist(nid, GFP_NOFS), 0,
-						GFP_NOFS, NULL);
+					  GFP_NOFS, MIN_COMPACT_PRIORITY, NULL);
 	}
 }
 
diff --git a/include/linux/compaction.h b/include/linux/compaction.h
--- a/include/linux/compaction.h
+++ b/include/linux/compaction.h
@@ -97,7 +97,7 @@ extern enum compact_result try_to_compact_pages(gfp_t gfp_mask,
 		const struct alloc_context *ac, enum compact_priority prio);
 extern void reset_isolation_suitable(pg_data_t *pgdat);
 extern enum compact_result compaction_suitable(struct zone *zone, int order,
-		unsigned int alloc_flags, int classzone_idx);
+		unsigned int alloc_flags, int classzone_idx, bool sync);
 
 extern void defer_compaction(struct zone *zone, int order);
 extern bool compaction_deferred(struct zone *zone, int order);
@@ -171,7 +171,7 @@ static inline bool compaction_withdrawn(enum compact_result result)
 
 
 bool compaction_zonelist_suitable(struct alloc_context *ac, int order,
-					int alloc_flags);
+				  int alloc_flags, enum compact_priority prio);
 
 extern int kcompactd_run(int nid);
 extern void kcompactd_stop(int nid);
@@ -182,8 +182,8 @@ static inline void reset_isolation_suitable(pg_data_t *pgdat)
 {
 }
 
-static inline enum compact_result compaction_suitable(struct zone *zone, int order,
-					int alloc_flags, int classzone_idx)
+static inline enum compact_result compaction_suitable(struct zone *zone,
+		int order, int alloc_flags, int classzone_idx, bool sync)
 {
 	return COMPACT_SKIPPED;
 }
diff --git a/include/linux/swap.h b/include/linux/swap.h
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -11,6 +11,7 @@
 #include <linux/fs.h>
 #include <linux/atomic.h>
 #include <linux/page-flags.h>
+#include <linux/compaction.h>
 #include <asm/page.h>
 
 struct notifier_block;
@@ -315,7 +316,7 @@ extern void lru_cache_add_active_or_unevictable(struct page *page,
 extern unsigned long zone_reclaimable_pages(struct zone *zone);
 extern unsigned long pgdat_reclaimable_pages(struct pglist_data *pgdat);
 extern unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
-					gfp_t gfp_mask, nodemask_t *mask);
+		gfp_t gfp_mask, enum compact_priority prio, nodemask_t *mask);
 extern int __isolate_lru_page(struct page *page, isolate_mode_t mode);
 extern unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *memcg,
 						  unsigned long nr_pages,
diff --git a/mm/compaction.c b/mm/compaction.c
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -1377,7 +1377,7 @@ static enum compact_result compact_finished(struct zone *zone,
 static enum compact_result __compaction_suitable(struct zone *zone, int order,
 					unsigned int alloc_flags,
 					int classzone_idx,
-					unsigned long wmark_target)
+					unsigned long wmark_target, bool sync)
 {
 	unsigned long watermark;
 
@@ -1414,18 +1414,34 @@ static enum compact_result __compaction_suitable(struct zone *zone, int order,
 						ALLOC_CMA, wmark_target))
 		return COMPACT_SKIPPED;
 
+	if (!sync) {
+		unsigned long free;
+
+		free = zone_page_state(zone, NR_FREE_CMA_PAGES) +
+		       zone_page_state(zone, NR_FREE_MOVABLE_PAGES);
+		/*
+		 * Page migration can only migrate pages to MIGRATE_MOVABLE or
+		 * MIGRATE_CMA pageblocks for async compaction.  If there is
+		 * insufficient free target memory, do not attempt compaction
+		 * since free scanning will become unnecessarily expensive.
+		 */
+		if (!__zone_watermark_ok(zone, 0, watermark, classzone_idx,
+					 ALLOC_CMA, free))
+			return COMPACT_SKIPPED;
+	}
+
 	return COMPACT_CONTINUE;
 }
 
 enum compact_result compaction_suitable(struct zone *zone, int order,
 					unsigned int alloc_flags,
-					int classzone_idx)
+					int classzone_idx, bool sync)
 {
 	enum compact_result ret;
 	int fragindex;
 
 	ret = __compaction_suitable(zone, order, alloc_flags, classzone_idx,
-				    zone_page_state(zone, NR_FREE_PAGES));
+				    zone_page_state(zone, NR_FREE_PAGES), sync);
 	/*
 	 * fragmentation index determines if allocation failures are due to
 	 * low memory or external fragmentation
@@ -1456,7 +1472,7 @@ enum compact_result compaction_suitable(struct zone *zone, int order,
 }
 
 bool compaction_zonelist_suitable(struct alloc_context *ac, int order,
-		int alloc_flags)
+				  int alloc_flags, enum compact_priority prio)
 {
 	struct zone *zone;
 	struct zoneref *z;
@@ -1479,7 +1495,7 @@ bool compaction_zonelist_suitable(struct alloc_context *ac, int order,
 		available = zone_reclaimable_pages(zone) / order;
 		available += zone_page_state_snapshot(zone, NR_FREE_PAGES);
 		compact_result = __compaction_suitable(zone, order, alloc_flags,
-				ac_classzone_idx(ac), available);
+				ac_classzone_idx(ac), available, prio);
 		if (compact_result != COMPACT_SKIPPED)
 			return true;
 	}
@@ -1496,7 +1512,7 @@ static enum compact_result compact_zone(struct zone *zone, struct compact_contro
 	const bool sync = cc->mode != MIGRATE_ASYNC;
 
 	ret = compaction_suitable(zone, cc->order, cc->alloc_flags,
-							cc->classzone_idx);
+				  cc->classzone_idx, sync);
 	/* Compaction is likely to fail */
 	if (ret == COMPACT_SUCCESS || ret == COMPACT_SKIPPED)
 		return ret;
@@ -1869,13 +1885,16 @@ static bool kcompactd_node_suitable(pg_data_t *pgdat)
 	enum zone_type classzone_idx = pgdat->kcompactd_classzone_idx;
 
 	for (zoneid = 0; zoneid <= classzone_idx; zoneid++) {
+		enum compact_result result;
+
 		zone = &pgdat->node_zones[zoneid];
 
 		if (!populated_zone(zone))
 			continue;
 
-		if (compaction_suitable(zone, pgdat->kcompactd_max_order, 0,
-					classzone_idx) == COMPACT_CONTINUE)
+		result = compaction_suitable(zone, pgdat->kcompactd_max_order,
+					     0, classzone_idx, true);
+		if (result == COMPACT_CONTINUE)
 			return true;
 	}
 
@@ -1911,7 +1930,7 @@ static void kcompactd_do_work(pg_data_t *pgdat)
 		if (compaction_deferred(zone, cc.order))
 			continue;
 
-		if (compaction_suitable(zone, cc.order, 0, zoneid) !=
+		if (compaction_suitable(zone, cc.order, 0, zoneid, true) !=
 							COMPACT_CONTINUE)
 			continue;
 
diff --git a/mm/internal.h b/mm/internal.h
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -451,6 +451,7 @@ extern unsigned long  __must_check vm_mmap_pgoff(struct file *, unsigned long,
 
 extern void set_pageblock_order(void);
 unsigned long reclaim_clean_pages_from_list(struct zone *zone,
+					    enum migrate_mode mode,
 					    struct list_head *page_list);
 /* The ALLOC_WMARK bits are used as an index to zone->watermark */
 #define ALLOC_WMARK_MIN		WMARK_MIN
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3194,7 +3194,8 @@ should_compact_retry(struct alloc_context *ac, int order, int alloc_flags,
 	 * compaction.
 	 */
 	if (compaction_withdrawn(compact_result))
-		return compaction_zonelist_suitable(ac, order, alloc_flags);
+		return compaction_zonelist_suitable(ac, order, alloc_flags,
+						    *compact_priority);
 
 	/*
 	 * !costly requests are much more important than __GFP_REPEAT
@@ -3264,7 +3265,7 @@ should_compact_retry(struct alloc_context *ac, unsigned int order, int alloc_fla
 /* Perform direct synchronous page reclaim */
 static int
 __perform_reclaim(gfp_t gfp_mask, unsigned int order,
-					const struct alloc_context *ac)
+		  const struct alloc_context *ac, enum compact_priority prio)
 {
 	struct reclaim_state reclaim_state;
 	int progress;
@@ -3278,7 +3279,7 @@ __perform_reclaim(gfp_t gfp_mask, unsigned int order,
 	reclaim_state.reclaimed_slab = 0;
 	current->reclaim_state = &reclaim_state;
 
-	progress = try_to_free_pages(ac->zonelist, order, gfp_mask,
+	progress = try_to_free_pages(ac->zonelist, order, gfp_mask, prio,
 								ac->nodemask);
 
 	current->reclaim_state = NULL;
@@ -3294,12 +3295,12 @@ __perform_reclaim(gfp_t gfp_mask, unsigned int order,
 static inline struct page *
 __alloc_pages_direct_reclaim(gfp_t gfp_mask, unsigned int order,
 		unsigned int alloc_flags, const struct alloc_context *ac,
-		unsigned long *did_some_progress)
+		enum compact_priority prio, unsigned long *did_some_progress)
 {
 	struct page *page = NULL;
 	bool drained = false;
 
-	*did_some_progress = __perform_reclaim(gfp_mask, order, ac);
+	*did_some_progress = __perform_reclaim(gfp_mask, order, ac, prio);
 	if (unlikely(!(*did_some_progress)))
 		return NULL;
 
@@ -3641,7 +3642,7 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 
 	/* Try direct reclaim and then allocating */
 	page = __alloc_pages_direct_reclaim(gfp_mask, order, alloc_flags, ac,
-							&did_some_progress);
+					compact_priority, &did_some_progress);
 	if (page)
 		goto got_pg;
 
@@ -7163,7 +7164,7 @@ static int __alloc_contig_migrate_range(struct compact_control *cc,
 			break;
 		}
 
-		nr_reclaimed = reclaim_clean_pages_from_list(cc->zone,
+		nr_reclaimed = reclaim_clean_pages_from_list(cc->zone, cc->mode,
 							&cc->migratepages);
 		cc->nr_migratepages -= nr_reclaimed;
 
diff --git a/mm/vmscan.c b/mm/vmscan.c
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -84,6 +84,8 @@ struct scan_control {
 	/* Scan (total_size >> priority) pages at once */
 	int priority;
 
+	enum compact_priority compact_priority;
+
 	/* The highest zone to isolate pages for reclaim from */
 	enum zone_type reclaim_idx;
 
@@ -1267,11 +1269,15 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 }
 
 unsigned long reclaim_clean_pages_from_list(struct zone *zone,
+					    enum migrate_mode mode,
 					    struct list_head *page_list)
 {
 	struct scan_control sc = {
 		.gfp_mask = GFP_KERNEL,
 		.priority = DEF_PRIORITY,
+		.compact_priority = mode == MIGRATE_ASYNC ?
+				    COMPACT_PRIO_ASYNC :
+				    COMPACT_PRIO_SYNC_LIGHT,
 		.may_unmap = 1,
 	};
 	unsigned long ret, dummy1, dummy2, dummy3, dummy4, dummy5;
@@ -2492,7 +2498,8 @@ static inline bool should_continue_reclaim(struct pglist_data *pgdat,
 		if (!managed_zone(zone))
 			continue;
 
-		switch (compaction_suitable(zone, sc->order, 0, sc->reclaim_idx)) {
+		switch (compaction_suitable(zone, sc->order, 0, sc->reclaim_idx,
+					    sc->compact_priority)) {
 		case COMPACT_SUCCESS:
 		case COMPACT_CONTINUE:
 			return false;
@@ -2605,7 +2612,8 @@ static inline bool compaction_ready(struct zone *zone, struct scan_control *sc)
 	unsigned long watermark;
 	enum compact_result suitable;
 
-	suitable = compaction_suitable(zone, sc->order, 0, sc->reclaim_idx);
+	suitable = compaction_suitable(zone, sc->order, 0, sc->reclaim_idx,
+				       sc->compact_priority);
 	if (suitable == COMPACT_SUCCESS)
 		/* Allocation should succeed already. Don't reclaim. */
 		return true;
@@ -2934,7 +2942,8 @@ static bool throttle_direct_reclaim(gfp_t gfp_mask, struct zonelist *zonelist,
 }
 
 unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
-				gfp_t gfp_mask, nodemask_t *nodemask)
+				gfp_t gfp_mask, enum compact_priority prio,
+				nodemask_t *nodemask)
 {
 	unsigned long nr_reclaimed;
 	struct scan_control sc = {
@@ -2944,6 +2953,7 @@ unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
 		.order = order,
 		.nodemask = nodemask,
 		.priority = DEF_PRIORITY,
+		.compact_priority = prio,
 		.may_writepage = !laptop_mode,
 		.may_unmap = 1,
 		.may_swap = 1,
@@ -3024,6 +3034,7 @@ unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *memcg,
 		.reclaim_idx = MAX_NR_ZONES - 1,
 		.target_mem_cgroup = memcg,
 		.priority = DEF_PRIORITY,
+		.compact_priority = DEF_COMPACT_PRIORITY,
 		.may_writepage = !laptop_mode,
 		.may_unmap = 1,
 		.may_swap = may_swap,
@@ -3195,6 +3206,7 @@ static int balance_pgdat(pg_data_t *pgdat, int order, int classzone_idx)
 		.gfp_mask = GFP_KERNEL,
 		.order = order,
 		.priority = DEF_PRIORITY,
+		.compact_priority = DEF_COMPACT_PRIORITY,
 		.may_writepage = !laptop_mode,
 		.may_unmap = 1,
 		.may_swap = 1,
@@ -3528,6 +3540,7 @@ unsigned long shrink_all_memory(unsigned long nr_to_reclaim)
 		.gfp_mask = GFP_HIGHUSER_MOVABLE,
 		.reclaim_idx = MAX_NR_ZONES - 1,
 		.priority = DEF_PRIORITY,
+		.compact_priority = DEF_COMPACT_PRIORITY,
 		.may_writepage = 1,
 		.may_unmap = 1,
 		.may_swap = 1,
@@ -3716,6 +3729,7 @@ static int __node_reclaim(struct pglist_data *pgdat, gfp_t gfp_mask, unsigned in
 		.gfp_mask = (gfp_mask = memalloc_noio_flags(gfp_mask)),
 		.order = order,
 		.priority = NODE_RECLAIM_PRIORITY,
+		.compact_priority = DEF_COMPACT_PRIORITY,
 		.may_writepage = !!(node_reclaim_mode & RECLAIM_WRITE),
 		.may_unmap = !!(node_reclaim_mode & RECLAIM_UNMAP),
 		.may_swap = 1,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
