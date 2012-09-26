Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id 67E3E6B002B
	for <linux-mm@kvack.org>; Tue, 25 Sep 2012 23:50:54 -0400 (EDT)
Received: by padfa10 with SMTP id fa10so128558pad.14
        for <linux-mm@kvack.org>; Tue, 25 Sep 2012 20:50:53 -0700 (PDT)
Date: Tue, 25 Sep 2012 20:50:51 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch -mm] mm, numa: reclaim from all nodes within reclaim distance
 fix fix
In-Reply-To: <20120919164654.43204ba9.akpm@linux-foundation.org>
Message-ID: <alpine.DEB.2.00.1209252049210.28360@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1209180003340.16777@chino.kir.corp.google.com> <20120919164654.43204ba9.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

It's cleaner if the iteration is explicitly done only for NUMA kernels.  
No functional change.

Intended to be folded into 
mm-numa-reclaim-from-all-nodes-within-reclaim-distance.patch already in 
-mm.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/page_alloc.c |   24 ++++++++++++++++--------
 1 files changed, 16 insertions(+), 8 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1802,6 +1802,17 @@ static bool zone_allows_reclaim(struct zone *local_zone, struct zone *zone)
 	return node_isset(local_zone->node, zone->zone_pgdat->reclaim_nodes);
 }
 
+static void __paginginit init_zone_allows_reclaim(int nid)
+{
+	int i;
+
+	for_each_online_node(i)
+		if (node_distance(nid, i) <= RECLAIM_DISTANCE) {
+			node_set(i, NODE_DATA(nid)->reclaim_nodes);
+			zone_reclaim_mode = 1;
+		}
+}
+
 #else	/* CONFIG_NUMA */
 
 static nodemask_t *zlc_setup(struct zonelist *zonelist, int alloc_flags)
@@ -1827,6 +1838,10 @@ static bool zone_allows_reclaim(struct zone *local_zone, struct zone *zone)
 {
 	return true;
 }
+
+static inline void init_zone_allows_reclaim(int nid)
+{
+}
 #endif	/* CONFIG_NUMA */
 
 /*
@@ -4551,20 +4566,13 @@ void __paginginit free_area_init_node(int nid, unsigned long *zones_size,
 		unsigned long node_start_pfn, unsigned long *zholes_size)
 {
 	pg_data_t *pgdat = NODE_DATA(nid);
-	int i;
 
 	/* pg_data_t should be reset to zero when it's allocated */
 	WARN_ON(pgdat->nr_zones || pgdat->classzone_idx);
 
 	pgdat->node_id = nid;
 	pgdat->node_start_pfn = node_start_pfn;
-	for_each_online_node(i)
-		if (node_distance(nid, i) <= RECLAIM_DISTANCE) {
-			node_set(i, pgdat->reclaim_nodes);
-#ifdef CONFIG_NUMA
-			zone_reclaim_mode = 1;
-#endif
-		}
+	init_zone_allows_reclaim(nid);
 	calculate_node_totalpages(pgdat, zones_size, zholes_size);
 
 	alloc_node_mem_map(pgdat);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
