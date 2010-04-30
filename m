Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id D68226004A3
	for <linux-mm@kvack.org>; Fri, 30 Apr 2010 19:05:49 -0400 (EDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 4/5] vmscan: remove isolate_pages callback scan control
Date: Sat,  1 May 2010 01:05:32 +0200
Message-Id: <20100430224316.121105897@cmpxchg.org>
In-Reply-To: <20100430222009.379195565@cmpxchg.org>
References: <20100430222009.379195565@cmpxchg.org>
References: <20100430222009.379195565@cmpxchg.org>
Content-Disposition: inline; filename=vmscan-remove-isolate_pages-callback-scan-control.patch
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

For now, we have global isolation vs. memory control group isolation,
do not allow the reclaim entry function to set an arbitrary page
isolation callback, we do not need that flexibility.

And since we already pass around the group descriptor for the memory
control group isolation case, just use it to decide which one of the
two isolator functions to use.

The decisions can be merged into nearby branches, so no extra cost
there.  In fact, we save the indirect calls.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 include/linux/memcontrol.h |   13 ++++++-----
 mm/vmscan.c                |   52 ++++++++++++++++++++++++---------------------
 2 files changed, 35 insertions(+), 30 deletions(-)

--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -82,12 +82,6 @@ struct scan_control {
 	 * are scanned.
 	 */
 	nodemask_t	*nodemask;
-
-	/* Pluggable isolate pages callback */
-	unsigned long (*isolate_pages)(unsigned long nr, struct list_head *dst,
-			unsigned long *scanned, int order, int mode,
-			struct zone *z, struct mem_cgroup *mem_cont,
-			int active, int file);
 };
 
 #define lru_to_page(_head) (list_entry((_head)->prev, struct page, lru))
@@ -1000,7 +994,6 @@ static unsigned long isolate_pages_globa
 					struct list_head *dst,
 					unsigned long *scanned, int order,
 					int mode, struct zone *z,
-					struct mem_cgroup *mem_cont,
 					int active, int file)
 {
 	int lru = LRU_BASE;
@@ -1144,11 +1137,11 @@ static unsigned long shrink_inactive_lis
 		unsigned long nr_anon;
 		unsigned long nr_file;
 
-		nr_taken = sc->isolate_pages(SWAP_CLUSTER_MAX,
-			     &page_list, &nr_scan, sc->order, mode,
-				zone, sc->mem_cgroup, 0, file);
-
 		if (scanning_global_lru(sc)) {
+			nr_taken = isolate_pages_global(SWAP_CLUSTER_MAX,
+							&page_list, &nr_scan,
+							sc->order, mode,
+							zone, 0, file);
 			zone->pages_scanned += nr_scan;
 			if (current_is_kswapd())
 				__count_zone_vm_events(PGSCAN_KSWAPD, zone,
@@ -1156,6 +1149,16 @@ static unsigned long shrink_inactive_lis
 			else
 				__count_zone_vm_events(PGSCAN_DIRECT, zone,
 						       nr_scan);
+		} else {
+			nr_taken = mem_cgroup_isolate_pages(SWAP_CLUSTER_MAX,
+							&page_list, &nr_scan,
+							sc->order, mode,
+							zone, sc->mem_cgroup,
+							0, file);
+			/*
+			 * mem_cgroup_isolate_pages() keeps track of
+			 * scanned pages on its own.
+			 */
 		}
 
 		if (nr_taken == 0)
@@ -1333,16 +1336,23 @@ static void shrink_active_list(unsigned 
 
 	lru_add_drain();
 	spin_lock_irq(&zone->lru_lock);
-	nr_taken = sc->isolate_pages(nr_pages, &l_hold, &pgscanned, sc->order,
-					ISOLATE_ACTIVE, zone,
-					sc->mem_cgroup, 1, file);
-	/*
-	 * zone->pages_scanned is used for detect zone's oom
-	 * mem_cgroup remembers nr_scan by itself.
-	 */
 	if (scanning_global_lru(sc)) {
+		nr_taken = isolate_pages_global(nr_pages, &l_hold,
+						&pgscanned, sc->order,
+						ISOLATE_ACTIVE, zone,
+						1, file);
 		zone->pages_scanned += pgscanned;
+	} else {
+		nr_taken = mem_cgroup_isolate_pages(nr_pages, &l_hold,
+						&pgscanned, sc->order,
+						ISOLATE_ACTIVE, zone,
+						sc->mem_cgroup, 1, file);
+		/*
+		 * mem_cgroup_isolate_pages() keeps track of
+		 * scanned pages on its own.
+		 */
 	}
+
 	reclaim_stat->recent_scanned[file] += nr_taken;
 
 	__count_zone_vm_events(PGREFILL, zone, pgscanned);
@@ -1864,7 +1874,6 @@ unsigned long try_to_free_pages(struct z
 		.swappiness = vm_swappiness,
 		.order = order,
 		.mem_cgroup = NULL,
-		.isolate_pages = isolate_pages_global,
 		.nodemask = nodemask,
 	};
 
@@ -1884,7 +1893,6 @@ unsigned long mem_cgroup_shrink_node_zon
 		.swappiness = swappiness,
 		.order = 0,
 		.mem_cgroup = mem,
-		.isolate_pages = mem_cgroup_isolate_pages,
 	};
 	nodemask_t nm  = nodemask_of_node(nid);
 
@@ -1917,7 +1925,6 @@ unsigned long try_to_free_mem_cgroup_pag
 		.swappiness = swappiness,
 		.order = 0,
 		.mem_cgroup = mem_cont,
-		.isolate_pages = mem_cgroup_isolate_pages,
 		.nodemask = NULL, /* we don't care the placement */
 	};
 
@@ -1994,7 +2001,6 @@ static unsigned long balance_pgdat(pg_da
 		.swappiness = vm_swappiness,
 		.order = order,
 		.mem_cgroup = NULL,
-		.isolate_pages = isolate_pages_global,
 	};
 	/*
 	 * temp_priority is used to remember the scanning priority at which
@@ -2372,7 +2378,6 @@ unsigned long shrink_all_memory(unsigned
 		.hibernation_mode = 1,
 		.swappiness = vm_swappiness,
 		.order = 0,
-		.isolate_pages = isolate_pages_global,
 	};
 	struct zonelist * zonelist = node_zonelist(numa_node_id(), sc.gfp_mask);
 	struct task_struct *p = current;
@@ -2556,7 +2561,6 @@ static int __zone_reclaim(struct zone *z
 		.gfp_mask = gfp_mask,
 		.swappiness = vm_swappiness,
 		.order = order,
-		.isolate_pages = isolate_pages_global,
 	};
 	unsigned long slab_reclaimable;
 
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -25,6 +25,13 @@ struct page_cgroup;
 struct page;
 struct mm_struct;
 
+extern unsigned long mem_cgroup_isolate_pages(unsigned long nr_to_scan,
+					struct list_head *dst,
+					unsigned long *scanned, int order,
+					int mode, struct zone *z,
+					struct mem_cgroup *mem_cont,
+					int active, int file);
+
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR
 /*
  * All "charge" functions with gfp_mask should use GFP_KERNEL or
@@ -64,12 +71,6 @@ extern void mem_cgroup_uncharge_cache_pa
 extern int mem_cgroup_shmem_charge_fallback(struct page *page,
 			struct mm_struct *mm, gfp_t gfp_mask);
 
-extern unsigned long mem_cgroup_isolate_pages(unsigned long nr_to_scan,
-					struct list_head *dst,
-					unsigned long *scanned, int order,
-					int mode, struct zone *z,
-					struct mem_cgroup *mem_cont,
-					int active, int file);
 extern void mem_cgroup_out_of_memory(struct mem_cgroup *mem, gfp_t gfp_mask);
 int task_in_mem_cgroup(struct task_struct *task, const struct mem_cgroup *mem);
 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
