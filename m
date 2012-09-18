Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id 108966B005A
	for <linux-mm@kvack.org>; Tue, 18 Sep 2012 03:04:00 -0400 (EDT)
Received: by pbbro12 with SMTP id ro12so11787312pbb.14
        for <linux-mm@kvack.org>; Tue, 18 Sep 2012 00:03:59 -0700 (PDT)
Date: Tue, 18 Sep 2012 00:03:57 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch] mm, numa: reclaim from all nodes within reclaim distance
Message-ID: <alpine.DEB.2.00.1209180003340.16777@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

RECLAIM_DISTANCE represents the distance between nodes at which it is
deemed too costly to allocate from; it's preferred to try to reclaim from
a local zone before falling back to allocating on a remote node with such
a distance.

To do this, zone_reclaim_mode is set if the distance between any two
nodes on the system is greather than this distance.  This, however, ends
up causing the page allocator to reclaim from every zone regardless of
its affinity.

What we really want is to reclaim only from zones that are closer than 
RECLAIM_DISTANCE.  This patch adds a nodemask to each node that
represents the set of nodes that are within this distance.  During the
zone iteration, if the bit for a zone's node is set for the local node,
then reclaim is attempted; otherwise, the zone is skipped.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 include/linux/mmzone.h |    1 +
 mm/page_alloc.c        |   31 ++++++++++++++++++++-----------
 2 files changed, 21 insertions(+), 11 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -704,6 +704,7 @@ typedef struct pglist_data {
 	unsigned long node_spanned_pages; /* total size of physical page
 					     range, including holes */
 	int node_id;
+	nodemask_t reclaim_nodes;	/* Nodes allowed to reclaim from */
 	wait_queue_head_t kswapd_wait;
 	wait_queue_head_t pfmemalloc_wait;
 	struct task_struct *kswapd;	/* Protected by lock_memory_hotplug() */
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1782,6 +1782,11 @@ static void zlc_clear_zones_full(struct zonelist *zonelist)
 	bitmap_zero(zlc->fullzones, MAX_ZONES_PER_ZONELIST);
 }
 
+static bool zone_allows_reclaim(struct zone *local_zone, struct zone *zone)
+{
+	return node_isset(local_zone->node, zone->zone_pgdat->reclaim_nodes);
+}
+
 #else	/* CONFIG_NUMA */
 
 static nodemask_t *zlc_setup(struct zonelist *zonelist, int alloc_flags)
@@ -1802,6 +1807,11 @@ static void zlc_mark_zone_full(struct zonelist *zonelist, struct zoneref *z)
 static void zlc_clear_zones_full(struct zonelist *zonelist)
 {
 }
+
+static bool zone_allows_reclaim(struct zone *local_zone, struct zone *zone)
+{
+	return true;
+}
 #endif	/* CONFIG_NUMA */
 
 /*
@@ -1886,7 +1896,8 @@ zonelist_scan:
 				did_zlc_setup = 1;
 			}
 
-			if (zone_reclaim_mode == 0)
+			if (zone_reclaim_mode == 0 ||
+			    !zone_allows_reclaim(preferred_zone, zone))
 				goto this_zone_full;
 
 			/*
@@ -3328,21 +3339,13 @@ static void build_zonelists(pg_data_t *pgdat)
 	j = 0;
 
 	while ((node = find_next_best_node(local_node, &used_mask)) >= 0) {
-		int distance = node_distance(local_node, node);
-
-		/*
-		 * If another node is sufficiently far away then it is better
-		 * to reclaim pages in a zone before going off node.
-		 */
-		if (distance > RECLAIM_DISTANCE)
-			zone_reclaim_mode = 1;
-
 		/*
 		 * We don't want to pressure a particular node.
 		 * So adding penalty to the first node in same
 		 * distance group to make it round-robin.
 		 */
-		if (distance != node_distance(local_node, prev_node))
+		if (node_distance(local_node, node) !=
+		    node_distance(local_node, prev_node))
 			node_load[node] = load;
 
 		prev_node = node;
@@ -4515,12 +4518,18 @@ void __paginginit free_area_init_node(int nid, unsigned long *zones_size,
 		unsigned long node_start_pfn, unsigned long *zholes_size)
 {
 	pg_data_t *pgdat = NODE_DATA(nid);
+	int i;
 
 	/* pg_data_t should be reset to zero when it's allocated */
 	WARN_ON(pgdat->nr_zones || pgdat->classzone_idx);
 
 	pgdat->node_id = nid;
 	pgdat->node_start_pfn = node_start_pfn;
+	for_each_online_node(i)
+		if (node_distance(nid, i) <= RECLAIM_DISTANCE) {
+			node_set(i, pgdat->reclaim_nodes);
+			zone_reclaim_mode = 1;
+		}
 	calculate_node_totalpages(pgdat, zones_size, zholes_size);
 
 	alloc_node_mem_map(pgdat);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
