Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id 0E82E6B0068
	for <linux-mm@kvack.org>; Mon,  9 Jan 2012 21:34:36 -0500 (EST)
Date: Mon, 9 Jan 2012 21:33:57 -0500
From: Rik van Riel <riel@redhat.com>
Subject: [PATCH -mm 2/2] mm: kswapd carefully invoke compaction
Message-ID: <20120109213357.148e7927@annuminas.surriel.com>
In-Reply-To: <20120109213156.0ff47ee5@annuminas.surriel.com>
References: <20120109213156.0ff47ee5@annuminas.surriel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, aarcange@redhat.com
Cc: linux-kernel@vger.kernel.org, Mel Gorman <mel@csn.ul.ie>, akpm@linux-foundation.org, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, hughd@google.com

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
---
 include/linux/compaction.h |    6 ++++++
 mm/compaction.c            |   22 ++++++++++++++--------
 mm/vmscan.c                |    9 +++++++++
 3 files changed, 29 insertions(+), 8 deletions(-)

diff --git a/include/linux/compaction.h b/include/linux/compaction.h
index bb2bbdb..df31dab 100644
--- a/include/linux/compaction.h
+++ b/include/linux/compaction.h
@@ -23,6 +23,7 @@ extern int fragmentation_index(struct zone *zone, unsigned int order);
 extern unsigned long try_to_compact_pages(struct zonelist *zonelist,
 			int order, gfp_t gfp_mask, nodemask_t *mask,
 			bool sync);
+extern int compact_pgdat(pg_data_t *pgdat, int order, bool force);
 extern unsigned long compaction_suitable(struct zone *zone, int order);
 
 /* Do not skip compaction more than 64 times */
@@ -62,6 +63,11 @@ static inline unsigned long try_to_compact_pages(struct zonelist *zonelist,
 	return COMPACT_CONTINUE;
 }
 
+static inline int compact_pgdat(pg_data_t *pgdat, int order, bool force)
+{
+	return COMPACT_CONTINUE;
+}
+
 static inline unsigned long compaction_suitable(struct zone *zone, int order)
 {
 	return COMPACT_SKIPPED;
diff --git a/mm/compaction.c b/mm/compaction.c
index 1253d7a..1962a0e 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -651,16 +651,11 @@ unsigned long try_to_compact_pages(struct zonelist *zonelist,
 
 
 /* Compact all zones within a node */
-static int compact_node(int nid)
+int compact_pgdat(pg_data_t *pgdat, int order, bool force)
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
 
@@ -668,7 +663,7 @@ static int compact_node(int nid)
 		struct compact_control cc = {
 			.nr_freepages = 0,
 			.nr_migratepages = 0,
-			.order = -1,
+			.order = order,
 		};
 
 		zone = &pgdat->node_zones[zoneid];
@@ -679,7 +674,8 @@ static int compact_node(int nid)
 		INIT_LIST_HEAD(&cc.freepages);
 		INIT_LIST_HEAD(&cc.migratepages);
 
-		compact_zone(zone, &cc);
+		if (force || !compaction_deferred(zone))
+			compact_zone(zone, &cc);
 
 		VM_BUG_ON(!list_empty(&cc.freepages));
 		VM_BUG_ON(!list_empty(&cc.migratepages));
@@ -688,6 +684,16 @@ static int compact_node(int nid)
 	return 0;
 }
 
+static int compact_node(int nid)
+{
+	pg_data_t *pgdat;
+	if (nid < 0 || nid >= nr_node_ids || !node_online(nid))
+		return -EINVAL;
+	pgdat = NODE_DATA(nid);
+
+	return compact_pgdat(pgdat, -1, true);
+}
+
 /* Compact all nodes in the system */
 static int compact_nodes(void)
 {
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 0fb469a..65bf21db 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2522,6 +2522,7 @@ static unsigned long balance_pgdat(pg_data_t *pgdat, int order,
 	int priority;
 	int i;
 	int end_zone = 0;	/* Inclusive.  0 = ZONE_DMA */
+	int zones_need_compaction = 1;
 	unsigned long total_scanned;
 	struct reclaim_state *reclaim_state = current->reclaim_state;
 	unsigned long nr_soft_reclaimed;
@@ -2788,9 +2789,17 @@ out:
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
+			compact_pgdat(pgdat, order, false);
 	}
 
 	/*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
