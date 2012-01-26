Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx110.postini.com [74.125.245.110])
	by kanga.kvack.org (Postfix) with SMTP id A3B176B005C
	for <linux-mm@kvack.org>; Thu, 26 Jan 2012 15:02:50 -0500 (EST)
Date: Thu, 26 Jan 2012 14:59:58 -0500
From: Rik van Riel <riel@redhat.com>
Subject: [PATCH v3 -mm 2/3] mm: kswapd carefully call compaction
Message-ID: <20120126145958.4c37ea04@cuia.bos.redhat.com>
In-Reply-To: <20120126145450.2d3d2f4c@cuia.bos.redhat.com>
References: <20120126145450.2d3d2f4c@cuia.bos.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: lkml <linux-kernel@vger.kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

With CONFIG_COMPACTION enabled, kswapd does not try to free
contiguous free pages, even when it is woken for a higher order
request.

This could be bad for eg. jumbo frame network allocations, which
are done from interrupt context and cannot compact memory themselves.
Higher than before allocation failure rates in the network receive
path have been observed in kernels with compaction enabled.

Teach kswapd to defragment the memory zones in a node, but only
if required and compaction is not deferred in a zone.

Signed-off-by: Rik van Riel <riel@redhat.com>
Acked-by: Mel Gorman <mel@csn.ul.ie>
---
 include/linux/compaction.h |    6 +++++
 mm/compaction.c            |   53 +++++++++++++++++++++++++++++---------------
 mm/vmscan.c                |    9 +++++++
 3 files changed, 50 insertions(+), 18 deletions(-)

diff --git a/include/linux/compaction.h b/include/linux/compaction.h
index bb2bbdb..7a9323a 100644
--- a/include/linux/compaction.h
+++ b/include/linux/compaction.h
@@ -23,6 +23,7 @@ extern int fragmentation_index(struct zone *zone, unsigned int order);
 extern unsigned long try_to_compact_pages(struct zonelist *zonelist,
 			int order, gfp_t gfp_mask, nodemask_t *mask,
 			bool sync);
+extern int compact_pgdat(pg_data_t *pgdat, int order);
 extern unsigned long compaction_suitable(struct zone *zone, int order);
 
 /* Do not skip compaction more than 64 times */
@@ -62,6 +63,11 @@ static inline unsigned long try_to_compact_pages(struct zonelist *zonelist,
 	return COMPACT_CONTINUE;
 }
 
+static inline int compact_pgdat(pg_data_t *pgdat, int order)
+{
+	return COMPACT_CONTINUE;
+}
+
 static inline unsigned long compaction_suitable(struct zone *zone, int order)
 {
 	return COMPACT_SKIPPED;
diff --git a/mm/compaction.c b/mm/compaction.c
index 71a58f6..51ece75 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -653,44 +653,61 @@ unsigned long try_to_compact_pages(struct zonelist *zonelist,
 
 
 /* Compact all zones within a node */
-static int compact_node(int nid)
+static int __compact_pgdat(pg_data_t *pgdat, struct compact_control *cc)
 {
 	int zoneid;
-	pg_data_t *pgdat;
 	struct zone *zone;
 
-	if (nid < 0 || nid >= nr_node_ids || !node_online(nid))
-		return -EINVAL;
-	pgdat = NODE_DATA(nid);
-
 	/* Flush pending updates to the LRU lists */
 	lru_add_drain_all();
 
 	for (zoneid = 0; zoneid < MAX_NR_ZONES; zoneid++) {
-		struct compact_control cc = {
-			.nr_freepages = 0,
-			.nr_migratepages = 0,
-			.order = -1,
-			.sync = true,
-		};
 
 		zone = &pgdat->node_zones[zoneid];
 		if (!populated_zone(zone))
 			continue;
 
-		cc.zone = zone;
-		INIT_LIST_HEAD(&cc.freepages);
-		INIT_LIST_HEAD(&cc.migratepages);
+		cc->nr_freepages = 0;
+		cc->nr_migratepages = 0;
+		cc->zone = zone;
+		INIT_LIST_HEAD(&cc->freepages);
+		INIT_LIST_HEAD(&cc->migratepages);
 
-		compact_zone(zone, &cc);
+		if (cc->order < 0 || !compaction_deferred(zone))
+			compact_zone(zone, cc);
 
-		VM_BUG_ON(!list_empty(&cc.freepages));
-		VM_BUG_ON(!list_empty(&cc.migratepages));
+		VM_BUG_ON(!list_empty(&cc->freepages));
+		VM_BUG_ON(!list_empty(&cc->migratepages));
 	}
 
 	return 0;
 }
 
+int compact_pgdat(pg_data_t *pgdat, int order)
+{
+	struct compact_control cc = {
+		.order = order,
+		.sync = false,
+	};
+
+	return __compact_pgdat(pgdat, &cc);
+}
+
+static int compact_node(int nid)
+{
+	pg_data_t *pgdat;
+	struct compact_control cc = {
+		.order = -1,
+		.sync = true,
+	};
+
+	if (nid < 0 || nid >= nr_node_ids || !node_online(nid))
+		return -EINVAL;
+	pgdat = NODE_DATA(nid);
+
+	return __compact_pgdat(pgdat, &cc);
+}
+
 /* Compact all nodes in the system */
 static int compact_nodes(void)
 {
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 0398fab..fa17794 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2673,6 +2673,7 @@ static unsigned long balance_pgdat(pg_data_t *pgdat, int order,
 	int priority;
 	int i;
 	int end_zone = 0;	/* Inclusive.  0 = ZONE_DMA */
+	int zones_need_compaction = 1;
 	unsigned long total_scanned;
 	struct reclaim_state *reclaim_state = current->reclaim_state;
 	unsigned long nr_soft_reclaimed;
@@ -2937,9 +2938,17 @@ out:
 				goto loop_again;
 			}
 
+			/* Check if the memory needs to be defragmented. */
+			if (zone_watermark_ok(zone, order,
+				    low_wmark_pages(zone), *classzone_idx, 0))
+				zones_need_compaction = 0;
+
 			/* If balanced, clear the congested flag */
 			zone_clear_flag(zone, ZONE_CONGESTED);
 		}
+
+		if (zones_need_compaction)
+			compact_pgdat(pgdat, order);
 	}
 
 	/*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
