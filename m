Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 664DE828E4
	for <linux-mm@kvack.org>; Fri, 24 Jun 2016 05:55:26 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id f126so13065836wma.3
        for <linux-mm@kvack.org>; Fri, 24 Jun 2016 02:55:26 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id je6si6077148wjb.80.2016.06.24.02.55.03
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 24 Jun 2016 02:55:03 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH v3 10/17] mm, compaction: cleanup unused functions
Date: Fri, 24 Jun 2016 11:54:30 +0200
Message-Id: <20160624095437.16385-11-vbabka@suse.cz>
In-Reply-To: <20160624095437.16385-1-vbabka@suse.cz>
References: <20160624095437.16385-1-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michal Hocko <mhocko@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>

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
index 095aaa220952..0cc702ec80a2 100644
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
@@ -167,10 +166,6 @@ static inline void __ClearPageMovable(struct page *page)
 {
 }
 
-static inline void compact_pgdat(pg_data_t *pgdat, int order)
-{
-}
-
 static inline void reset_isolation_suitable(pg_data_t *pgdat)
 {
 }
diff --git a/mm/compaction.c b/mm/compaction.c
index e7fe848e318e..5c15db0001a5 100644
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
2.8.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
