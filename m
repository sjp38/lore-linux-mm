Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f49.google.com (mail-ee0-f49.google.com [74.125.83.49])
	by kanga.kvack.org (Postfix) with ESMTP id DB6A36B0035
	for <linux-mm@kvack.org>; Fri, 18 Apr 2014 10:50:46 -0400 (EDT)
Received: by mail-ee0-f49.google.com with SMTP id c41so1687513eek.36
        for <linux-mm@kvack.org>; Fri, 18 Apr 2014 07:50:46 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z42si40611009eel.62.2014.04.18.07.50.45
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 18 Apr 2014 07:50:45 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 02/16] mm: page_alloc: Do not cache reclaim distances
Date: Fri, 18 Apr 2014 15:50:29 +0100
Message-Id: <1397832643-14275-3-git-send-email-mgorman@suse.de>
In-Reply-To: <1397832643-14275-1-git-send-email-mgorman@suse.de>
References: <1397832643-14275-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Linux-FSDevel <linux-fsdevel@vger.kernel.org>

pgdat->reclaim_nodes tracks if a remote node is allowed to be reclaimed by
zone_reclaim due to its distance. As it is expected that zone_reclaim_mode
will be rarely enabled it is unreasonable for all machines to take a penalty.
Fortunately, the zone_reclaim_mode() path is already slow and it is the path
that takes the hit.

Signed-off-by: Mel Gorman <mgorman@suse.de>
Acked-by: Johannes Weiner <hannes@cmpxchg.org>
Reviewed-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
---
 include/linux/mmzone.h |  1 -
 mm/page_alloc.c        | 18 ++----------------
 2 files changed, 2 insertions(+), 17 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index fac5509..c1dbe0b 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -763,7 +763,6 @@ typedef struct pglist_data {
 	unsigned long node_spanned_pages; /* total size of physical page
 					     range, including holes */
 	int node_id;
-	nodemask_t reclaim_nodes;	/* Nodes allowed to reclaim from */
 	wait_queue_head_t kswapd_wait;
 	wait_queue_head_t pfmemalloc_wait;
 	struct task_struct *kswapd;	/* Protected by lock_memory_hotplug() */
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 628f1e7..3c8200c5 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1850,16 +1850,8 @@ static bool zone_local(struct zone *local_zone, struct zone *zone)
 
 static bool zone_allows_reclaim(struct zone *local_zone, struct zone *zone)
 {
-	return node_isset(local_zone->node, zone->zone_pgdat->reclaim_nodes);
-}
-
-static void __paginginit init_zone_allows_reclaim(int nid)
-{
-	int i;
-
-	for_each_node_state(i, N_MEMORY)
-		if (node_distance(nid, i) <= RECLAIM_DISTANCE)
-			node_set(i, NODE_DATA(nid)->reclaim_nodes);
+	return node_distance(zone_to_nid(local_zone), zone_to_nid(zone)) <
+							RECLAIM_DISTANCE;
 }
 
 #else	/* CONFIG_NUMA */
@@ -1892,10 +1884,6 @@ static bool zone_allows_reclaim(struct zone *local_zone, struct zone *zone)
 {
 	return true;
 }
-
-static inline void init_zone_allows_reclaim(int nid)
-{
-}
 #endif	/* CONFIG_NUMA */
 
 /*
@@ -4919,8 +4907,6 @@ void __paginginit free_area_init_node(int nid, unsigned long *zones_size,
 
 	pgdat->node_id = nid;
 	pgdat->node_start_pfn = node_start_pfn;
-	if (node_state(nid, N_MEMORY))
-		init_zone_allows_reclaim(nid);
 #ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
 	get_pfn_range_for_nid(nid, &start_pfn, &end_pfn);
 #endif
-- 
1.8.4.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
