Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 9388C8D003B
	for <linux-mm@kvack.org>; Mon, 25 Apr 2011 13:22:54 -0400 (EDT)
From: Ying Han <yinghan@google.com>
Subject: [PATCH V2 1/2] change the shrink_slab by passing shrink_control
Date: Mon, 25 Apr 2011 10:22:13 -0700
Message-Id: <1303752134-4856-2-git-send-email-yinghan@google.com>
In-Reply-To: <1303752134-4856-1-git-send-email-yinghan@google.com>
References: <1303752134-4856-1-git-send-email-yinghan@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>
Cc: linux-mm@kvack.org

This patch consolidates existing parameters to shrink_slab() to
a new shrink_control struct. This is needed later to pass the same
struct to shrinkers.

changelog v2..v1:
1. define a new struct shrink_control and only pass some values down
to the shrinker instead of the scan_control.

Signed-off-by: Ying Han <yinghan@google.com>
---
 fs/drop_caches.c   |    6 +++++-
 include/linux/mm.h |   13 +++++++++++--
 mm/vmscan.c        |   30 ++++++++++++++++++++++--------
 3 files changed, 38 insertions(+), 11 deletions(-)

diff --git a/fs/drop_caches.c b/fs/drop_caches.c
index 816f88e..c671290 100644
--- a/fs/drop_caches.c
+++ b/fs/drop_caches.c
@@ -36,9 +36,13 @@ static void drop_pagecache_sb(struct super_block *sb, void *unused)
 static void drop_slab(void)
 {
 	int nr_objects;
+	struct shrink_control shrink = {
+		.gfp_mask = GFP_KERNEL,
+		.nr_scanned = 1000,
+	};
 
 	do {
-		nr_objects = shrink_slab(1000, GFP_KERNEL, 1000);
+		nr_objects = shrink_slab(&shrink, 1000);
 	} while (nr_objects > 10);
 }
 
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 0716517..7a2f657 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1131,6 +1131,15 @@ static inline void sync_mm_rss(struct task_struct *task, struct mm_struct *mm)
 #endif
 
 /*
+ * This struct is used to pass information from page reclaim to the shrinkers.
+ * We consolidate the values for easier extention later.
+ */
+struct shrink_control {
+	unsigned long nr_scanned;
+	gfp_t gfp_mask;
+};
+
+/*
  * A callback you can register to apply pressure to ageable caches.
  *
  * 'shrink' is passed a count 'nr_to_scan' and a 'gfpmask'.  It should
@@ -1601,8 +1610,8 @@ int in_gate_area_no_task(unsigned long addr);
 
 int drop_caches_sysctl_handler(struct ctl_table *, int,
 					void __user *, size_t *, loff_t *);
-unsigned long shrink_slab(unsigned long scanned, gfp_t gfp_mask,
-			unsigned long lru_pages);
+unsigned long shrink_slab(struct shrink_control *shrink,
+				unsigned long lru_pages);
 
 #ifndef CONFIG_MMU
 #define randomize_va_space 0
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 060e4c1..40edf73 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -220,11 +220,13 @@ EXPORT_SYMBOL(unregister_shrinker);
  *
  * Returns the number of slab objects which we shrunk.
  */
-unsigned long shrink_slab(unsigned long scanned, gfp_t gfp_mask,
-			unsigned long lru_pages)
+unsigned long shrink_slab(struct shrink_control *shrink,
+			  unsigned long lru_pages)
 {
 	struct shrinker *shrinker;
 	unsigned long ret = 0;
+	unsigned long scanned = shrink->nr_scanned;
+	gfp_t gfp_mask = shrink->gfp_mask;
 
 	if (scanned == 0)
 		scanned = SWAP_CLUSTER_MAX;
@@ -2032,7 +2034,8 @@ static bool all_unreclaimable(struct zonelist *zonelist,
  * 		else, the number of pages reclaimed
  */
 static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
-					struct scan_control *sc)
+					struct scan_control *sc,
+					struct shrink_control *shrink)
 {
 	int priority;
 	unsigned long total_scanned = 0;
@@ -2066,7 +2069,8 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
 				lru_pages += zone_reclaimable_pages(zone);
 			}
 
-			shrink_slab(sc->nr_scanned, sc->gfp_mask, lru_pages);
+			shrink->nr_scanned = sc->nr_scanned;
+			shrink_slab(shrink, lru_pages);
 			if (reclaim_state) {
 				sc->nr_reclaimed += reclaim_state->reclaimed_slab;
 				reclaim_state->reclaimed_slab = 0;
@@ -2130,12 +2134,15 @@ unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
 		.mem_cgroup = NULL,
 		.nodemask = nodemask,
 	};
+	struct shrink_control shrink = {
+		.gfp_mask = sc.gfp_mask,
+	};
 
 	trace_mm_vmscan_direct_reclaim_begin(order,
 				sc.may_writepage,
 				gfp_mask);
 
-	nr_reclaimed = do_try_to_free_pages(zonelist, &sc);
+	nr_reclaimed = do_try_to_free_pages(zonelist, &sc, &shrink);
 
 	trace_mm_vmscan_direct_reclaim_end(nr_reclaimed);
 
@@ -2333,6 +2340,9 @@ static unsigned long balance_pgdat(pg_data_t *pgdat, int order,
 		.order = order,
 		.mem_cgroup = NULL,
 	};
+	struct shrink_control shrink = {
+		.gfp_mask = sc.gfp_mask,
+	};
 loop_again:
 	total_scanned = 0;
 	sc.nr_reclaimed = 0;
@@ -2432,8 +2442,8 @@ loop_again:
 					end_zone, 0))
 				shrink_zone(priority, zone, &sc);
 			reclaim_state->reclaimed_slab = 0;
-			nr_slab = shrink_slab(sc.nr_scanned, GFP_KERNEL,
-						lru_pages);
+			shrink.nr_scanned = sc.nr_scanned;
+			nr_slab = shrink_slab(&shrink, lru_pages);
 			sc.nr_reclaimed += reclaim_state->reclaimed_slab;
 			total_scanned += sc.nr_scanned;
 
@@ -2969,6 +2979,9 @@ static int __zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
 		.swappiness = vm_swappiness,
 		.order = order,
 	};
+	struct shrink_control shrink = {
+		.gfp_mask = sc.gfp_mask,
+	};
 	unsigned long nr_slab_pages0, nr_slab_pages1;
 
 	cond_resched();
@@ -2995,6 +3008,7 @@ static int __zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
 	}
 
 	nr_slab_pages0 = zone_page_state(zone, NR_SLAB_RECLAIMABLE);
+	shrink.nr_scanned = sc.nr_scanned;
 	if (nr_slab_pages0 > zone->min_slab_pages) {
 		/*
 		 * shrink_slab() does not currently allow us to determine how
@@ -3010,7 +3024,7 @@ static int __zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
 			unsigned long lru_pages = zone_reclaimable_pages(zone);
 
 			/* No reclaimable slab or very low memory pressure */
-			if (!shrink_slab(sc.nr_scanned, gfp_mask, lru_pages))
+			if (!shrink_slab(&shrink, lru_pages))
 				break;
 
 			/* Freed enough memory */
-- 
1.7.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
