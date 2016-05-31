Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0C7C66B0269
	for <linux-mm@kvack.org>; Tue, 31 May 2016 09:08:58 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id h68so64433120lfh.2
        for <linux-mm@kvack.org>; Tue, 31 May 2016 06:08:57 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x187si36847657wmd.86.2016.05.31.06.08.36
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 31 May 2016 06:08:36 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH v2 10/18] mm, compaction: cleanup unused functions
Date: Tue, 31 May 2016 15:08:10 +0200
Message-Id: <20160531130818.28724-11-vbabka@suse.cz>
In-Reply-To: <20160531130818.28724-1-vbabka@suse.cz>
References: <20160531130818.28724-1-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@techsingularity.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>

Since kswapd compaction moved to kcompactd, compact_pgdat() is not called
anymore, so we remove it. The only caller of __compact_pgdat() is
compact_node(), so we merge them and remove code that was only reachable from
kswapd.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 include/linux/compaction.h |  5 ----
 mm/compaction.c            | 60 +++++++++++++---------------------------------
 2 files changed, 17 insertions(+), 48 deletions(-)

diff --git a/include/linux/compaction.h b/include/linux/compaction.h
index b3bb66e7ce55..22a5fb9c509c 100644
--- a/include/linux/compaction.h
+++ b/include/linux/compaction.h
@@ -70,7 +70,6 @@ extern int fragmentation_index(struct zone *zone, unsigned int order);
 extern enum compact_result try_to_compact_pages(gfp_t gfp_mask,
 		unsigned int order, unsigned int alloc_flags,
 		const struct alloc_context *ac, enum compact_priority prio);
-extern void compact_pgdat(pg_data_t *pgdat, int order);
 extern void reset_isolation_suitable(pg_data_t *pgdat);
 extern enum compact_result compaction_suitable(struct zone *zone, int order,
 		unsigned int alloc_flags, int classzone_idx);
@@ -154,10 +153,6 @@ extern void kcompactd_stop(int nid);
 extern void wakeup_kcompactd(pg_data_t *pgdat, int order, int classzone_idx);
 
 #else
-static inline void compact_pgdat(pg_data_t *pgdat, int order)
-{
-}
-
 static inline void reset_isolation_suitable(pg_data_t *pgdat)
 {
 }
diff --git a/mm/compaction.c b/mm/compaction.c
index 78c99300b911..af50f20de369 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -1678,10 +1678,18 @@ enum compact_result try_to_compact_pages(gfp_t gfp_mask, unsigned int order,
 
 
 /* Compact all zones within a node */
-static void __compact_pgdat(pg_data_t *pgdat, struct compact_control *cc)
+static void compact_node(int nid)
 {
+	pg_data_t *pgdat = NODE_DATA(nid);
 	int zoneid;
 	struct zone *zone;
+	struct compact_control cc = {
+		.order = -1,
+		.mode = MIGRATE_SYNC,
+		.ignore_skip_hint = true,
+		.whole_zone = true,
+	};
+
 
 	for (zoneid = 0; zoneid < MAX_NR_ZONES; zoneid++) {
 
@@ -1689,53 +1697,19 @@ static void __compact_pgdat(pg_data_t *pgdat, struct compact_control *cc)
 		if (!populated_zone(zone))
 			continue;
 
-		cc->nr_freepages = 0;
-		cc->nr_migratepages = 0;
-		cc->zone = zone;
-		INIT_LIST_HEAD(&cc->freepages);
-		INIT_LIST_HEAD(&cc->migratepages);
-
-		if (is_via_compact_memory(cc->order) ||
-				!compaction_deferred(zone, cc->order))
-			compact_zone(zone, cc);
-
-		VM_BUG_ON(!list_empty(&cc->freepages));
-		VM_BUG_ON(!list_empty(&cc->migratepages));
+		cc.nr_freepages = 0;
+		cc.nr_migratepages = 0;
+		cc.zone = zone;
+		INIT_LIST_HEAD(&cc.freepages);
+		INIT_LIST_HEAD(&cc.migratepages);
 
-		if (is_via_compact_memory(cc->order))
-			continue;
+		compact_zone(zone, &cc);
 
-		if (zone_watermark_ok(zone, cc->order,
-				low_wmark_pages(zone), 0, 0))
-			compaction_defer_reset(zone, cc->order, false);
+		VM_BUG_ON(!list_empty(&cc.freepages));
+		VM_BUG_ON(!list_empty(&cc.migratepages));
 	}
 }
 
-void compact_pgdat(pg_data_t *pgdat, int order)
-{
-	struct compact_control cc = {
-		.order = order,
-		.mode = MIGRATE_ASYNC,
-	};
-
-	if (!order)
-		return;
-
-	__compact_pgdat(pgdat, &cc);
-}
-
-static void compact_node(int nid)
-{
-	struct compact_control cc = {
-		.order = -1,
-		.mode = MIGRATE_SYNC,
-		.ignore_skip_hint = true,
-		.whole_zone = true,
-	};
-
-	__compact_pgdat(NODE_DATA(nid), &cc);
-}
-
 /* Compact all nodes in the system */
 static void compact_nodes(void)
 {
-- 
2.8.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
