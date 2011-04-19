Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id AB1E58D0040
	for <linux-mm@kvack.org>; Tue, 19 Apr 2011 13:52:53 -0400 (EDT)
From: Ying Han <yinghan@google.com>
Subject: [PATCH 2/3] change the shrink_slab by passing scan_control.
Date: Tue, 19 Apr 2011 10:51:35 -0700
Message-Id: <1303235496-3060-3-git-send-email-yinghan@google.com>
In-Reply-To: <1303235496-3060-1-git-send-email-yinghan@google.com>
References: <1303235496-3060-1-git-send-email-yinghan@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>
Cc: linux-mm@kvack.org

This patch consolidates existing parameters to shrink_slab() to
scan_control struct. This is needed later to pass the same struct
to shrinkers.

Signed-off-by: Ying Han <yinghan@google.com>
---
 fs/drop_caches.c   |    7 ++++++-
 include/linux/mm.h |    4 ++--
 mm/vmscan.c        |   12 ++++++------
 3 files changed, 14 insertions(+), 9 deletions(-)

diff --git a/fs/drop_caches.c b/fs/drop_caches.c
index 816f88e..0e5ef62 100644
--- a/fs/drop_caches.c
+++ b/fs/drop_caches.c
@@ -8,6 +8,7 @@
 #include <linux/writeback.h>
 #include <linux/sysctl.h>
 #include <linux/gfp.h>
+#include <linux/swap.h>
 
 /* A global variable is a bit ugly, but it keeps the code simple */
 int sysctl_drop_caches;
@@ -36,9 +37,13 @@ static void drop_pagecache_sb(struct super_block *sb, void *unused)
 static void drop_slab(void)
 {
 	int nr_objects;
+	struct scan_control sc = {
+		.gfp_mask = GFP_KERNEL,
+		.nr_scanned = 1000,
+	};
 
 	do {
-		nr_objects = shrink_slab(1000, GFP_KERNEL, 1000);
+		nr_objects = shrink_slab(&sc, 1000);
 	} while (nr_objects > 10);
 }
 
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 0716517..42c2bf4 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -21,6 +21,7 @@ struct anon_vma;
 struct file_ra_state;
 struct user_struct;
 struct writeback_control;
+struct scan_control;
 
 #ifndef CONFIG_DISCONTIGMEM          /* Don't use mapnrs, do it properly */
 extern unsigned long max_mapnr;
@@ -1601,8 +1602,7 @@ int in_gate_area_no_task(unsigned long addr);
 
 int drop_caches_sysctl_handler(struct ctl_table *, int,
 					void __user *, size_t *, loff_t *);
-unsigned long shrink_slab(unsigned long scanned, gfp_t gfp_mask,
-			unsigned long lru_pages);
+unsigned long shrink_slab(struct scan_control *sc, unsigned long lru_pages);
 
 #ifndef CONFIG_MMU
 #define randomize_va_space 0
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 08b1ab5..9662166 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -159,11 +159,12 @@ EXPORT_SYMBOL(unregister_shrinker);
  *
  * Returns the number of slab objects which we shrunk.
  */
-unsigned long shrink_slab(unsigned long scanned, gfp_t gfp_mask,
-			unsigned long lru_pages)
+unsigned long shrink_slab(struct scan_control *sc, unsigned long lru_pages)
 {
 	struct shrinker *shrinker;
 	unsigned long ret = 0;
+	unsigned long scanned = sc->nr_scanned;
+	gfp_t gfp_mask = sc->gfp_mask;
 
 	if (scanned == 0)
 		scanned = SWAP_CLUSTER_MAX;
@@ -2005,7 +2006,7 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
 				lru_pages += zone_reclaimable_pages(zone);
 			}
 
-			shrink_slab(sc->nr_scanned, sc->gfp_mask, lru_pages);
+			shrink_slab(sc, lru_pages);
 			if (reclaim_state) {
 				sc->nr_reclaimed += reclaim_state->reclaimed_slab;
 				reclaim_state->reclaimed_slab = 0;
@@ -2371,8 +2372,7 @@ loop_again:
 					end_zone, 0))
 				shrink_zone(priority, zone, &sc);
 			reclaim_state->reclaimed_slab = 0;
-			nr_slab = shrink_slab(sc.nr_scanned, GFP_KERNEL,
-						lru_pages);
+			nr_slab = shrink_slab(&sc, lru_pages);
 			sc.nr_reclaimed += reclaim_state->reclaimed_slab;
 			total_scanned += sc.nr_scanned;
 
@@ -2949,7 +2949,7 @@ static int __zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
 			unsigned long lru_pages = zone_reclaimable_pages(zone);
 
 			/* No reclaimable slab or very low memory pressure */
-			if (!shrink_slab(sc.nr_scanned, gfp_mask, lru_pages))
+			if (!shrink_slab(&sc, lru_pages))
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
