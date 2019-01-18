Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 09E558E0002
	for <linux-mm@kvack.org>; Fri, 18 Jan 2019 12:52:30 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id t7so5235930edr.21
        for <linux-mm@kvack.org>; Fri, 18 Jan 2019 09:52:29 -0800 (PST)
Received: from outbound-smtp26.blacknight.com (outbound-smtp26.blacknight.com. [81.17.249.194])
        by mx.google.com with ESMTPS id f27-v6si137708ejh.100.2019.01.18.09.52.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 Jan 2019 09:52:28 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp26.blacknight.com (Postfix) with ESMTPS id CA52FB8AA6
	for <linux-mm@kvack.org>; Fri, 18 Jan 2019 17:52:27 +0000 (GMT)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 04/22] mm, compaction: Remove unnecessary zone parameter in some instances
Date: Fri, 18 Jan 2019 17:51:18 +0000
Message-Id: <20190118175136.31341-5-mgorman@techsingularity.net>
In-Reply-To: <20190118175136.31341-1-mgorman@techsingularity.net>
References: <20190118175136.31341-1-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Linux List Kernel Mailing <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Mel Gorman <mgorman@techsingularity.net>

A zone parameter is passed into a number of top-level compaction functions
despite the fact that it's already in compact_control. This is harmless but
it did need an audit to check if zone actually ever changes meaningfully.
This patches removes the parameter in a number of top-level functions. The
change could be much deeper but this was enough to briefly clarify
the flow.

No functional change.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
Acked-by: Vlastimil Babka <vbabka@suse.cz>
---
 mm/compaction.c | 54 ++++++++++++++++++++++++++----------------------------
 1 file changed, 26 insertions(+), 28 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index e59dd7a7564c..163841e1b167 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -1300,8 +1300,7 @@ static inline bool is_via_compact_memory(int order)
 	return order == -1;
 }
 
-static enum compact_result __compact_finished(struct zone *zone,
-						struct compact_control *cc)
+static enum compact_result __compact_finished(struct compact_control *cc)
 {
 	unsigned int order;
 	const int migratetype = cc->migratetype;
@@ -1312,7 +1311,7 @@ static enum compact_result __compact_finished(struct zone *zone,
 	/* Compaction run completes if the migrate and free scanner meet */
 	if (compact_scanners_met(cc)) {
 		/* Let the next compaction start anew. */
-		reset_cached_positions(zone);
+		reset_cached_positions(cc->zone);
 
 		/*
 		 * Mark that the PG_migrate_skip information should be cleared
@@ -1321,7 +1320,7 @@ static enum compact_result __compact_finished(struct zone *zone,
 		 * based on an allocation request.
 		 */
 		if (cc->direct_compaction)
-			zone->compact_blockskip_flush = true;
+			cc->zone->compact_blockskip_flush = true;
 
 		if (cc->whole_zone)
 			return COMPACT_COMPLETE;
@@ -1345,7 +1344,7 @@ static enum compact_result __compact_finished(struct zone *zone,
 
 	/* Direct compactor: Is a suitable page free? */
 	for (order = cc->order; order < MAX_ORDER; order++) {
-		struct free_area *area = &zone->free_area[order];
+		struct free_area *area = &cc->zone->free_area[order];
 		bool can_steal;
 
 		/* Job done if page is free of the right migratetype */
@@ -1391,13 +1390,12 @@ static enum compact_result __compact_finished(struct zone *zone,
 	return COMPACT_NO_SUITABLE_PAGE;
 }
 
-static enum compact_result compact_finished(struct zone *zone,
-			struct compact_control *cc)
+static enum compact_result compact_finished(struct compact_control *cc)
 {
 	int ret;
 
-	ret = __compact_finished(zone, cc);
-	trace_mm_compaction_finished(zone, cc->order, ret);
+	ret = __compact_finished(cc);
+	trace_mm_compaction_finished(cc->zone, cc->order, ret);
 	if (ret == COMPACT_NO_SUITABLE_PAGE)
 		ret = COMPACT_CONTINUE;
 
@@ -1524,16 +1522,16 @@ bool compaction_zonelist_suitable(struct alloc_context *ac, int order,
 	return false;
 }
 
-static enum compact_result compact_zone(struct zone *zone, struct compact_control *cc)
+static enum compact_result compact_zone(struct compact_control *cc)
 {
 	enum compact_result ret;
-	unsigned long start_pfn = zone->zone_start_pfn;
-	unsigned long end_pfn = zone_end_pfn(zone);
+	unsigned long start_pfn = cc->zone->zone_start_pfn;
+	unsigned long end_pfn = zone_end_pfn(cc->zone);
 	unsigned long last_migrated_pfn;
 	const bool sync = cc->mode != MIGRATE_ASYNC;
 
 	cc->migratetype = gfpflags_to_migratetype(cc->gfp_mask);
-	ret = compaction_suitable(zone, cc->order, cc->alloc_flags,
+	ret = compaction_suitable(cc->zone, cc->order, cc->alloc_flags,
 							cc->classzone_idx);
 	/* Compaction is likely to fail */
 	if (ret == COMPACT_SUCCESS || ret == COMPACT_SKIPPED)
@@ -1546,8 +1544,8 @@ static enum compact_result compact_zone(struct zone *zone, struct compact_contro
 	 * Clear pageblock skip if there were failures recently and compaction
 	 * is about to be retried after being deferred.
 	 */
-	if (compaction_restarting(zone, cc->order))
-		__reset_isolation_suitable(zone);
+	if (compaction_restarting(cc->zone, cc->order))
+		__reset_isolation_suitable(cc->zone);
 
 	/*
 	 * Setup to move all movable pages to the end of the zone. Used cached
@@ -1559,16 +1557,16 @@ static enum compact_result compact_zone(struct zone *zone, struct compact_contro
 		cc->migrate_pfn = start_pfn;
 		cc->free_pfn = pageblock_start_pfn(end_pfn - 1);
 	} else {
-		cc->migrate_pfn = zone->compact_cached_migrate_pfn[sync];
-		cc->free_pfn = zone->compact_cached_free_pfn;
+		cc->migrate_pfn = cc->zone->compact_cached_migrate_pfn[sync];
+		cc->free_pfn = cc->zone->compact_cached_free_pfn;
 		if (cc->free_pfn < start_pfn || cc->free_pfn >= end_pfn) {
 			cc->free_pfn = pageblock_start_pfn(end_pfn - 1);
-			zone->compact_cached_free_pfn = cc->free_pfn;
+			cc->zone->compact_cached_free_pfn = cc->free_pfn;
 		}
 		if (cc->migrate_pfn < start_pfn || cc->migrate_pfn >= end_pfn) {
 			cc->migrate_pfn = start_pfn;
-			zone->compact_cached_migrate_pfn[0] = cc->migrate_pfn;
-			zone->compact_cached_migrate_pfn[1] = cc->migrate_pfn;
+			cc->zone->compact_cached_migrate_pfn[0] = cc->migrate_pfn;
+			cc->zone->compact_cached_migrate_pfn[1] = cc->migrate_pfn;
 		}
 
 		if (cc->migrate_pfn == start_pfn)
@@ -1582,11 +1580,11 @@ static enum compact_result compact_zone(struct zone *zone, struct compact_contro
 
 	migrate_prep_local();
 
-	while ((ret = compact_finished(zone, cc)) == COMPACT_CONTINUE) {
+	while ((ret = compact_finished(cc)) == COMPACT_CONTINUE) {
 		int err;
 		unsigned long start_pfn = cc->migrate_pfn;
 
-		switch (isolate_migratepages(zone, cc)) {
+		switch (isolate_migratepages(cc->zone, cc)) {
 		case ISOLATE_ABORT:
 			ret = COMPACT_CONTENDED;
 			putback_movable_pages(&cc->migratepages);
@@ -1653,7 +1651,7 @@ static enum compact_result compact_zone(struct zone *zone, struct compact_contro
 			if (last_migrated_pfn < current_block_start) {
 				cpu = get_cpu();
 				lru_add_drain_cpu(cpu);
-				drain_local_pages(zone);
+				drain_local_pages(cc->zone);
 				put_cpu();
 				/* No more flushing until we migrate again */
 				last_migrated_pfn = 0;
@@ -1678,8 +1676,8 @@ static enum compact_result compact_zone(struct zone *zone, struct compact_contro
 		 * Only go back, not forward. The cached pfn might have been
 		 * already reset to zone end in compact_finished()
 		 */
-		if (free_pfn > zone->compact_cached_free_pfn)
-			zone->compact_cached_free_pfn = free_pfn;
+		if (free_pfn > cc->zone->compact_cached_free_pfn)
+			cc->zone->compact_cached_free_pfn = free_pfn;
 	}
 
 	count_compact_events(COMPACTMIGRATE_SCANNED, cc->total_migrate_scanned);
@@ -1716,7 +1714,7 @@ static enum compact_result compact_zone_order(struct zone *zone, int order,
 	INIT_LIST_HEAD(&cc.freepages);
 	INIT_LIST_HEAD(&cc.migratepages);
 
-	ret = compact_zone(zone, &cc);
+	ret = compact_zone(&cc);
 
 	VM_BUG_ON(!list_empty(&cc.freepages));
 	VM_BUG_ON(!list_empty(&cc.migratepages));
@@ -1834,7 +1832,7 @@ static void compact_node(int nid)
 		INIT_LIST_HEAD(&cc.freepages);
 		INIT_LIST_HEAD(&cc.migratepages);
 
-		compact_zone(zone, &cc);
+		compact_zone(&cc);
 
 		VM_BUG_ON(!list_empty(&cc.freepages));
 		VM_BUG_ON(!list_empty(&cc.migratepages));
@@ -1968,7 +1966,7 @@ static void kcompactd_do_work(pg_data_t *pgdat)
 
 		if (kthread_should_stop())
 			return;
-		status = compact_zone(zone, &cc);
+		status = compact_zone(&cc);
 
 		if (status == COMPACT_SUCCESS) {
 			compaction_defer_reset(zone, cc.order, false);
-- 
2.16.4
