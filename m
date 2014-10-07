Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f41.google.com (mail-wg0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 87B5A6B0075
	for <linux-mm@kvack.org>; Tue,  7 Oct 2014 11:34:02 -0400 (EDT)
Received: by mail-wg0-f41.google.com with SMTP id b13so9607111wgh.12
        for <linux-mm@kvack.org>; Tue, 07 Oct 2014 08:34:02 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id qd12si7234938wic.70.2014.10.07.08.34.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 07 Oct 2014 08:34:00 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH 1/5] mm, compaction: pass classzone_idx and alloc_flags to watermark checking
Date: Tue,  7 Oct 2014 17:33:35 +0200
Message-Id: <1412696019-21761-2-git-send-email-vbabka@suse.cz>
In-Reply-To: <1412696019-21761-1-git-send-email-vbabka@suse.cz>
References: <1412696019-21761-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Nazarewicz <mina86@mina86.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>

Compaction relies on zone watermark checks for decisions such as if it's worth
to start compacting in compaction_suitable() or whether compaction should stop
in compact_finished(). The watermark checks take classzone_idx and alloc_flags
parameters, which are related to the memory allocation request. But from the
context of compaction they are currently passed as 0, including the direct
compaction which is invoked to satisfy the allocation request, and could
therefore know the proper values.

The lack of proper values can lead to mismatch between decisions taken during
compaction and decisions related to the allocation request. Lack of proper
classzone_idx value means that lowmem_reserve is not taken into account.
This has manifested (during recent changes to deferred compaction) when DMA
zone was used as fallback for preferred Normal zone. compaction_suitable()
without proper classzone_idx would think that the watermarks are already
satisfied, but watermark check in get_page_from_freelist() would fail. Because
of this problem, deferring compaction has extra complexity that can be removed
in the following patch.

The issue (not confirmed in practice) with missing alloc_flags is opposite in
nature. For allocations that include ALLOC_HIGH, ALLOC_HIGHER or ALLOC_CMA in
alloc_flags (the last includes all MOVABLE allocations on CMA-enabled systems)
the watermark checking in compaction with 0 passed will be stricter than in
get_page_from_freelist(). In these cases compaction might be running for a
longer time than is really needed.

This patch fixes these problems by adding alloc_flags and classzone_idx to
struct compact_control and related functions involved in direct compaction and
watermark checking. Where possible, all other callers of compaction_suitable()
pass proper values where those are known. This is currently limited to
classzone_idx, which is sometimes known in kswapd context. However, the direct
reclaim callers should_continue_reclaim() and compaction_ready() do not
currently know the proper values, so the coordination between reclaim and
compaction may still not be as accurate as it could. This can be fixed later,
if it's shown to be an issue.

The effect of this patch should be slightly better high-order allocation
success rates and/or less compaction overhead, depending on the type of
allocations and presence of CMA. It allows simplifying deferred compaction
code in a followup patch.

When testing with stress-highalloc, there was some slight improvement (which
might be just due to variance) in success rates of non-THP-like allocations.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Michal Nazarewicz <mina86@mina86.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Christoph Lameter <cl@linux.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: David Rientjes <rientjes@google.com>
---
 include/linux/compaction.h |  8 ++++++--
 mm/compaction.c            | 29 +++++++++++++++--------------
 mm/internal.h              |  2 ++
 mm/page_alloc.c            |  1 +
 mm/vmscan.c                | 12 ++++++------
 5 files changed, 30 insertions(+), 22 deletions(-)

diff --git a/include/linux/compaction.h b/include/linux/compaction.h
index 60bdf8d..d896765 100644
--- a/include/linux/compaction.h
+++ b/include/linux/compaction.h
@@ -33,10 +33,12 @@ extern int fragmentation_index(struct zone *zone, unsigned int order);
 extern unsigned long try_to_compact_pages(struct zonelist *zonelist,
 			int order, gfp_t gfp_mask, nodemask_t *mask,
 			enum migrate_mode mode, int *contended,
+			int alloc_flags, int classzone_idx,
 			struct zone **candidate_zone);
 extern void compact_pgdat(pg_data_t *pgdat, int order);
 extern void reset_isolation_suitable(pg_data_t *pgdat);
-extern unsigned long compaction_suitable(struct zone *zone, int order);
+extern unsigned long compaction_suitable(struct zone *zone, int order,
+					int alloc_flags, int classzone_idx);
 
 /* Do not skip compaction more than 64 times */
 #define COMPACT_MAX_DEFER_SHIFT 6
@@ -103,6 +105,7 @@ static inline bool compaction_restarting(struct zone *zone, int order)
 static inline unsigned long try_to_compact_pages(struct zonelist *zonelist,
 			int order, gfp_t gfp_mask, nodemask_t *nodemask,
 			enum migrate_mode mode, int *contended,
+			int alloc_flags, int classzone_idx,
 			struct zone **candidate_zone)
 {
 	return COMPACT_CONTINUE;
@@ -116,7 +119,8 @@ static inline void reset_isolation_suitable(pg_data_t *pgdat)
 {
 }
 
-static inline unsigned long compaction_suitable(struct zone *zone, int order)
+static inline unsigned long compaction_suitable(struct zone *zone, int order,
+					int alloc_flags, int classzone_idx)
 {
 	return COMPACT_SKIPPED;
 }
diff --git a/mm/compaction.c b/mm/compaction.c
index edba18a..dba8891 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -1069,9 +1069,9 @@ static int compact_finished(struct zone *zone, struct compact_control *cc,
 
 	/* Compaction run is not finished if the watermark is not met */
 	watermark = low_wmark_pages(zone);
-	watermark += (1 << cc->order);
 
-	if (!zone_watermark_ok(zone, cc->order, watermark, 0, 0))
+	if (!zone_watermark_ok(zone, cc->order, watermark, cc->classzone_idx,
+							cc->alloc_flags))
 		return COMPACT_CONTINUE;
 
 	/* Direct compactor: Is a suitable page free? */
@@ -1097,7 +1097,8 @@ static int compact_finished(struct zone *zone, struct compact_control *cc,
  *   COMPACT_PARTIAL  - If the allocation would succeed without compaction
  *   COMPACT_CONTINUE - If compaction should run now
  */
-unsigned long compaction_suitable(struct zone *zone, int order)
+unsigned long compaction_suitable(struct zone *zone, int order,
+					int alloc_flags, int classzone_idx)
 {
 	int fragindex;
 	unsigned long watermark;
@@ -1134,7 +1135,7 @@ unsigned long compaction_suitable(struct zone *zone, int order)
 		return COMPACT_SKIPPED;
 
 	if (fragindex == -1000 && zone_watermark_ok(zone, order, watermark,
-	    0, 0))
+	    classzone_idx, alloc_flags))
 		return COMPACT_PARTIAL;
 
 	return COMPACT_CONTINUE;
@@ -1148,7 +1149,8 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
 	const int migratetype = gfpflags_to_migratetype(cc->gfp_mask);
 	const bool sync = cc->mode != MIGRATE_ASYNC;
 
-	ret = compaction_suitable(zone, cc->order);
+	ret = compaction_suitable(zone, cc->order, cc->alloc_flags,
+							cc->classzone_idx);
 	switch (ret) {
 	case COMPACT_PARTIAL:
 	case COMPACT_SKIPPED:
@@ -1237,7 +1239,8 @@ out:
 }
 
 static unsigned long compact_zone_order(struct zone *zone, int order,
-		gfp_t gfp_mask, enum migrate_mode mode, int *contended)
+		gfp_t gfp_mask, enum migrate_mode mode, int *contended,
+		int alloc_flags, int classzone_idx)
 {
 	unsigned long ret;
 	struct compact_control cc = {
@@ -1247,6 +1250,8 @@ static unsigned long compact_zone_order(struct zone *zone, int order,
 		.gfp_mask = gfp_mask,
 		.zone = zone,
 		.mode = mode,
+		.alloc_flags = alloc_flags,
+		.classzone_idx = classzone_idx,
 	};
 	INIT_LIST_HEAD(&cc.freepages);
 	INIT_LIST_HEAD(&cc.migratepages);
@@ -1278,6 +1283,7 @@ int sysctl_extfrag_threshold = 500;
 unsigned long try_to_compact_pages(struct zonelist *zonelist,
 			int order, gfp_t gfp_mask, nodemask_t *nodemask,
 			enum migrate_mode mode, int *contended,
+			int alloc_flags, int classzone_idx,
 			struct zone **candidate_zone)
 {
 	enum zone_type high_zoneidx = gfp_zone(gfp_mask);
@@ -1286,7 +1292,6 @@ unsigned long try_to_compact_pages(struct zonelist *zonelist,
 	struct zoneref *z;
 	struct zone *zone;
 	int rc = COMPACT_DEFERRED;
-	int alloc_flags = 0;
 	int all_zones_contended = COMPACT_CONTENDED_LOCK; /* init for &= op */
 
 	*contended = COMPACT_CONTENDED_NONE;
@@ -1295,10 +1300,6 @@ unsigned long try_to_compact_pages(struct zonelist *zonelist,
 	if (!order || !may_enter_fs || !may_perform_io)
 		return COMPACT_SKIPPED;
 
-#ifdef CONFIG_CMA
-	if (gfpflags_to_migratetype(gfp_mask) == MIGRATE_MOVABLE)
-		alloc_flags |= ALLOC_CMA;
-#endif
 	/* Compact each zone in the list */
 	for_each_zone_zonelist_nodemask(zone, z, zonelist, high_zoneidx,
 								nodemask) {
@@ -1309,7 +1310,7 @@ unsigned long try_to_compact_pages(struct zonelist *zonelist,
 			continue;
 
 		status = compact_zone_order(zone, order, gfp_mask, mode,
-							&zone_contended);
+				&zone_contended, alloc_flags, classzone_idx);
 		rc = max(status, rc);
 		/*
 		 * It takes at least one zone that wasn't lock contended
@@ -1318,8 +1319,8 @@ unsigned long try_to_compact_pages(struct zonelist *zonelist,
 		all_zones_contended &= zone_contended;
 
 		/* If a normal allocation would succeed, stop compacting */
-		if (zone_watermark_ok(zone, order, low_wmark_pages(zone), 0,
-				      alloc_flags)) {
+		if (zone_watermark_ok(zone, order, low_wmark_pages(zone),
+					classzone_idx, alloc_flags)) {
 			*candidate_zone = zone;
 			/*
 			 * We think the allocation will succeed in this zone,
diff --git a/mm/internal.h b/mm/internal.h
index 8293040..3cc9b0a 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -143,6 +143,8 @@ struct compact_control {
 
 	int order;			/* order a direct compactor needs */
 	const gfp_t gfp_mask;		/* gfp mask of a direct compactor */
+	const int alloc_flags;		/* alloc flags of a direct compactor */
+	const int classzone_idx;	/* zone index of a direct compactor */
 	struct zone *zone;
 	int contended;			/* Signal need_sched() or lock
 					 * contention detected during
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index e758159..8d143a0 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2339,6 +2339,7 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
 	compact_result = try_to_compact_pages(zonelist, order, gfp_mask,
 						nodemask, mode,
 						contended_compaction,
+						alloc_flags, classzone_idx,
 						&last_compact_zone);
 	current->flags &= ~PF_MEMALLOC;
 
diff --git a/mm/vmscan.c b/mm/vmscan.c
index dcb4707..19ba76d 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2249,7 +2249,7 @@ static inline bool should_continue_reclaim(struct zone *zone,
 		return true;
 
 	/* If compaction would go ahead or the allocation would succeed, stop */
-	switch (compaction_suitable(zone, sc->order)) {
+	switch (compaction_suitable(zone, sc->order, 0, 0)) {
 	case COMPACT_PARTIAL:
 	case COMPACT_CONTINUE:
 		return false;
@@ -2346,7 +2346,7 @@ static inline bool compaction_ready(struct zone *zone, int order)
 	 * If compaction is not ready to start and allocation is not likely
 	 * to succeed without it, then keep reclaiming.
 	 */
-	if (compaction_suitable(zone, order) == COMPACT_SKIPPED)
+	if (compaction_suitable(zone, order, 0, 0) == COMPACT_SKIPPED)
 		return false;
 
 	return watermark_ok;
@@ -2824,8 +2824,8 @@ static bool zone_balanced(struct zone *zone, int order,
 				    balance_gap, classzone_idx, 0))
 		return false;
 
-	if (IS_ENABLED(CONFIG_COMPACTION) && order &&
-	    compaction_suitable(zone, order) == COMPACT_SKIPPED)
+	if (IS_ENABLED(CONFIG_COMPACTION) && order && compaction_suitable(zone,
+				order, 0, classzone_idx) == COMPACT_SKIPPED)
 		return false;
 
 	return true;
@@ -2952,8 +2952,8 @@ static bool kswapd_shrink_zone(struct zone *zone,
 	 * from memory. Do not reclaim more than needed for compaction.
 	 */
 	if (IS_ENABLED(CONFIG_COMPACTION) && sc->order &&
-			compaction_suitable(zone, sc->order) !=
-				COMPACT_SKIPPED)
+			compaction_suitable(zone, sc->order, 0, classzone_idx)
+							!= COMPACT_SKIPPED)
 		testorder = 0;
 
 	/*
-- 
1.8.4.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
