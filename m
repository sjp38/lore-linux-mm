Message-Id: <20071114221021.174310314@sgi.com>
References: <20071114220906.206294426@sgi.com>
Date: Wed, 14 Nov 2007 14:09:13 -0800
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

Index: linux-2.6.24-rc2-mm1/fs/drop_caches.c
===================================================================
--- linux-2.6.24-rc2-mm1.orig/fs/drop_caches.c	2007-11-14 12:45:08.121992890 -0800
+++ linux-2.6.24-rc2-mm1/fs/drop_caches.c	2007-11-14 12:49:42.694743384 -0800
@@ -52,7 +52,7 @@ void drop_slab(void)
 	int nr_objects;
 
 	do {
-		nr_objects = shrink_slab(1000, GFP_KERNEL, 1000);
+		nr_objects = shrink_slab(1000, GFP_KERNEL, 1000, NULL);
 	} while (nr_objects > 10);
 }
 
Index: linux-2.6.24-rc2-mm1/mm/vmscan.c
===================================================================
--- linux-2.6.24-rc2-mm1.orig/mm/vmscan.c	2007-11-14 12:45:08.145992649 -0800
+++ linux-2.6.24-rc2-mm1/mm/vmscan.c	2007-11-14 12:49:42.694743384 -0800
@@ -168,10 +168,18 @@ EXPORT_SYMBOL(unregister_shrinker);
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
@@ -234,6 +242,8 @@ unsigned long shrink_slab(unsigned long 
 		shrinker->nr += total_scan;
 	}
 	up_read(&shrinker_rwsem);
+	if (gfp_mask & __GFP_FS)
+		kmem_cache_defrag(zone ? zone_to_nid(zone) : -1);
 	return ret;
 }
 
@@ -1291,7 +1301,7 @@ static unsigned long do_try_to_free_page
 		 * over limit cgroups
 		 */
 		if (sc->mem_cgroup == NULL)
-			shrink_slab(sc->nr_scanned, gfp_mask, lru_pages);
+			shrink_slab(sc->nr_scanned, gfp_mask, lru_pages, NULL);
 		if (reclaim_state) {
 			nr_reclaimed += reclaim_state->reclaimed_slab;
 			reclaim_state->reclaimed_slab = 0;
@@ -1515,7 +1525,7 @@ loop_again:
 				nr_reclaimed += shrink_zone(priority, zone, &sc);
 			reclaim_state->reclaimed_slab = 0;
 			nr_slab = shrink_slab(sc.nr_scanned, GFP_KERNEL,
-						lru_pages);
+						lru_pages, zone);
 			nr_reclaimed += reclaim_state->reclaimed_slab;
 			total_scanned += sc.nr_scanned;
 			if (zone_is_all_unreclaimable(zone))
@@ -1756,7 +1766,7 @@ unsigned long shrink_all_memory(unsigned
 	/* If slab caches are huge, it's better to hit them first */
 	while (nr_slab >= lru_pages) {
 		reclaim_state.reclaimed_slab = 0;
-		shrink_slab(nr_pages, sc.gfp_mask, lru_pages);
+		shrink_slab(nr_pages, sc.gfp_mask, lru_pages, NULL);
 		if (!reclaim_state.reclaimed_slab)
 			break;
 
@@ -1794,7 +1804,7 @@ unsigned long shrink_all_memory(unsigned
 
 			reclaim_state.reclaimed_slab = 0;
 			shrink_slab(sc.nr_scanned, sc.gfp_mask,
-					count_lru_pages());
+					count_lru_pages(), NULL);
 			ret += reclaim_state.reclaimed_slab;
 			if (ret >= nr_pages)
 				goto out;
@@ -1811,7 +1821,8 @@ unsigned long shrink_all_memory(unsigned
 	if (!ret) {
 		do {
 			reclaim_state.reclaimed_slab = 0;
-			shrink_slab(nr_pages, sc.gfp_mask, count_lru_pages());
+			shrink_slab(nr_pages, sc.gfp_mask,
+					count_lru_pages(), NULL);
 			ret += reclaim_state.reclaimed_slab;
 		} while (ret < nr_pages && reclaim_state.reclaimed_slab > 0);
 	}
@@ -1974,7 +1985,8 @@ static int __zone_reclaim(struct zone *z
 		 * Note that shrink_slab will free memory on all zones and may
 		 * take a long time.
 		 */
-		while (shrink_slab(sc.nr_scanned, gfp_mask, order) &&
+		while (shrink_slab(sc.nr_scanned, gfp_mask, order,
+						zone) &&
 			zone_page_state(zone, NR_SLAB_RECLAIMABLE) >
 				slab_reclaimable - nr_pages)
 			;
Index: linux-2.6.24-rc2-mm1/include/linux/mm.h
===================================================================
--- linux-2.6.24-rc2-mm1.orig/include/linux/mm.h	2007-11-14 12:45:08.137992655 -0800
+++ linux-2.6.24-rc2-mm1/include/linux/mm.h	2007-11-14 12:49:42.694743384 -0800
@@ -1165,7 +1165,7 @@ int in_gate_area_no_task(unsigned long a
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
