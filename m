Message-Id: <20071128223156.521223204@sgi.com>
References: <20071128223101.864822396@sgi.com>
Date: Wed, 28 Nov 2007 14:31:08 -0800
From: Christoph Lameter <clameter@sgi.com>
Subject: [patch 07/17] SLUB: Trigger defragmentation from memory reclaim
Content-Disposition: inline; filename=0053-SLUB-Trigger-defragmentation-from-memory-reclaim.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, Mel Gorman <mel@skynet.ie>
List-ID: <linux-mm.kvack.org>

This patch triggers slab defragmentation from memory reclaim.
The logical point for this is after slab shrinking was performed in
vmscan.c. At that point the fragmentation ratio of a slab was increased
because objects were freed via the LRUs. So we call kmem_cache_defrag() from
there.

slab_shrink() from vmscan.c is called in some contexts to do
global shrinking of slabs and in others to do shrinking for
a particular zone. Pass the zone to slab_shrink, so that slab_shrink
can call kmem_cache_defrag() and restrict the defragmentation to
the node that is under memory pressure.

Reviewed-by: Rik van Riel <riel@redhat.com>
Signed-off-by: Christoph Lameter <clameter@sgi.com>
---
 fs/drop_caches.c   |    2 +-
 include/linux/mm.h |    2 +-
 mm/vmscan.c        |   26 +++++++++++++++++++-------
 3 files changed, 21 insertions(+), 9 deletions(-)

Index: mm/fs/drop_caches.c
===================================================================
--- mm.orig/fs/drop_caches.c	2007-11-28 12:24:24.332964809 -0800
+++ mm/fs/drop_caches.c	2007-11-28 12:30:00.484463542 -0800
@@ -52,7 +52,7 @@ void drop_slab(void)
 	int nr_objects;
 
 	do {
-		nr_objects = shrink_slab(1000, GFP_KERNEL, 1000);
+		nr_objects = shrink_slab(1000, GFP_KERNEL, 1000, NULL);
 	} while (nr_objects > 10);
 }
 
Index: mm/mm/vmscan.c
===================================================================
--- mm.orig/mm/vmscan.c	2007-11-28 12:27:32.487962592 -0800
+++ mm/mm/vmscan.c	2007-11-28 12:31:09.514355974 -0800
@@ -174,10 +174,18 @@ EXPORT_SYMBOL(unregister_shrinker);
  * are eligible for the caller's allocation attempt.  It is used for balancing
  * slab reclaim versus page reclaim.
  *
+ * zone is the zone for which we are shrinking the slabs. If the intent
+ * is to do a global shrink then zone may be NULL. Specification of a
+ * zone is currently only used to limit slab defragmentation to a NUMA node.
+ * The performace of shrink_slab would be better (in particular under NUMA)
+ * if it could be targeted as a whole to the zone that is under memory
+ * pressure but the VFS infrastructure does not allow that at the present
+ * time.
+ *
  * Returns the number of slab objects which we shrunk.
  */
 unsigned long shrink_slab(unsigned long scanned, gfp_t gfp_mask,
-			unsigned long lru_pages)
+			unsigned long lru_pages, struct zone *zone)
 {
 	struct shrinker *shrinker;
 	unsigned long ret = 0;
@@ -240,6 +248,8 @@ unsigned long shrink_slab(unsigned long 
 		shrinker->nr += total_scan;
 	}
 	up_read(&shrinker_rwsem);
+	if (gfp_mask & __GFP_FS)
+		kmem_cache_defrag(zone ? zone_to_nid(zone) : -1);
 	return ret;
 }
 
@@ -1360,7 +1370,7 @@ static unsigned long do_try_to_free_page
 		 * over limit cgroups
 		 */
 		if (scan_global_lru(sc)) {
-			shrink_slab(sc->nr_scanned, gfp_mask, lru_pages);
+			shrink_slab(sc->nr_scanned, gfp_mask, lru_pages, NULL);
 			if (reclaim_state) {
 				nr_reclaimed += reclaim_state->reclaimed_slab;
 				reclaim_state->reclaimed_slab = 0;
@@ -1589,7 +1599,7 @@ loop_again:
 				nr_reclaimed += shrink_zone(priority, zone, &sc);
 			reclaim_state->reclaimed_slab = 0;
 			nr_slab = shrink_slab(sc.nr_scanned, GFP_KERNEL,
-						lru_pages);
+						lru_pages, zone);
 			nr_reclaimed += reclaim_state->reclaimed_slab;
 			total_scanned += sc.nr_scanned;
 			if (zone_is_all_unreclaimable(zone))
@@ -1830,7 +1840,7 @@ unsigned long shrink_all_memory(unsigned
 	/* If slab caches are huge, it's better to hit them first */
 	while (nr_slab >= lru_pages) {
 		reclaim_state.reclaimed_slab = 0;
-		shrink_slab(nr_pages, sc.gfp_mask, lru_pages);
+		shrink_slab(nr_pages, sc.gfp_mask, lru_pages, NULL);
 		if (!reclaim_state.reclaimed_slab)
 			break;
 
@@ -1868,7 +1878,7 @@ unsigned long shrink_all_memory(unsigned
 
 			reclaim_state.reclaimed_slab = 0;
 			shrink_slab(sc.nr_scanned, sc.gfp_mask,
-					count_lru_pages());
+					count_lru_pages(), NULL);
 			ret += reclaim_state.reclaimed_slab;
 			if (ret >= nr_pages)
 				goto out;
@@ -1885,7 +1895,8 @@ unsigned long shrink_all_memory(unsigned
 	if (!ret) {
 		do {
 			reclaim_state.reclaimed_slab = 0;
-			shrink_slab(nr_pages, sc.gfp_mask, count_lru_pages());
+			shrink_slab(nr_pages, sc.gfp_mask,
+					count_lru_pages(), NULL);
 			ret += reclaim_state.reclaimed_slab;
 		} while (ret < nr_pages && reclaim_state.reclaimed_slab > 0);
 	}
@@ -2048,7 +2059,8 @@ static int __zone_reclaim(struct zone *z
 		 * Note that shrink_slab will free memory on all zones and may
 		 * take a long time.
 		 */
-		while (shrink_slab(sc.nr_scanned, gfp_mask, order) &&
+		while (shrink_slab(sc.nr_scanned, gfp_mask, order,
+						zone) &&
 			zone_page_state(zone, NR_SLAB_RECLAIMABLE) >
 				slab_reclaimable - nr_pages)
 			;
Index: mm/include/linux/mm.h
===================================================================
--- mm.orig/include/linux/mm.h	2007-11-28 12:26:53.408463773 -0800
+++ mm/include/linux/mm.h	2007-11-28 12:30:00.488463488 -0800
@@ -1179,7 +1179,7 @@ int in_gate_area_no_task(unsigned long a
 int drop_caches_sysctl_handler(struct ctl_table *, int, struct file *,
 					void __user *, size_t *, loff_t *);
 unsigned long shrink_slab(unsigned long scanned, gfp_t gfp_mask,
-			unsigned long lru_pages);
+			unsigned long lru_pages, struct zone *z);
 extern void drop_pagecache_sb(struct super_block *);
 void drop_pagecache(void);
 void drop_slab(void);

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
