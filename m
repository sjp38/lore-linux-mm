Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4F3FC828F3
	for <linux-mm@kvack.org>; Wed, 10 Aug 2016 05:12:49 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id u81so51929906wmu.3
        for <linux-mm@kvack.org>; Wed, 10 Aug 2016 02:12:49 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q18si38844785wjr.197.2016.08.10.02.12.41
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 10 Aug 2016 02:12:42 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH v6 02/11] mm, compaction: cleanup unused functions
Date: Wed, 10 Aug 2016 11:12:17 +0200
Message-Id: <20160810091226.6709-3-vbabka@suse.cz>
In-Reply-To: <20160810091226.6709-1-vbabka@suse.cz>
References: <20160810091226.6709-1-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>

Since kswapd compaction moved to kcompactd, compact_pgdat() is not called
anymore, so we remove it. The only caller of __compact_pgdat() is
compact_node(), so we merge them and remove code that was only reachable from
kswapd.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
Acked-by: Michal Hocko <mhocko@suse.com>
---
 include/linux/compaction.h |  5 ----
 mm/compaction.c            | 60 +++++++++++++---------------------------------
 2 files changed, 17 insertions(+), 48 deletions(-)

diff --git a/include/linux/compaction.h b/include/linux/compaction.h
index d4e106b5dc27..1bb58581301c 100644
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
index 5b0483ce6cb1..328bdfeece2d 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -1736,10 +1736,18 @@ enum compact_result try_to_compact_pages(gfp_t gfp_mask, unsigned int order,
 
 
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
 
@@ -1747,53 +1755,19 @@ static void __compact_pgdat(pg_data_t *pgdat, struct compact_control *cc)
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
2.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
