From: Christoph Lameter <clameter@sgi.com>
Subject: [patch 04/12] Slab defragmentation: Logic to trigger defragmentation from memory reclaim
Date: Sat, 07 Jul 2007 20:05:42 -0700
Message-ID: <20070708030844.327742445@sgi.com>
References: <20070708030538.729027694@sgi.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756515AbXGHDJl@vger.kernel.org>
Content-Disposition: inline; filename=slab_defrag_trigger
Sender: linux-kernel-owner@vger.kernel.org
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, dgc@sgi.com
List-Id: linux-mm.kvack.org

At some point slab defragmentation needs to be triggered. The logical
point for this is after slab shrinking was performed in vmscan.c. At
that point the fragmentation ratio of a slab was increased by objects
being freed. So we call kmem_cache_defrag from there.

slab_shrink() from vmscan.c is called in some contexts to do
global shrinking of slabs and in others to do shrinking for
a particular zone. Pass the zone to slab_shrink, so that slab_shrink
can call kmem_cache_defrag() and restrict the defragmentation to
the node that is under memory pressure.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 fs/drop_caches.c     |    2 +-
 include/linux/mm.h   |    2 +-
 include/linux/slab.h |    1 +
 mm/vmscan.c          |   27 ++++++++++++++++++++-------
 4 files changed, 23 insertions(+), 9 deletions(-)

Index: linux-2.6.22-rc6-mm1/include/linux/slab.h
===================================================================
--- linux-2.6.22-rc6-mm1.orig/include/linux/slab.h	2007-07-04 09:53:59.000000000 -0700
+++ linux-2.6.22-rc6-mm1/include/linux/slab.h	2007-07-04 09:56:22.000000000 -0700
@@ -96,6 +96,7 @@ void kmem_cache_free(struct kmem_cache *
 unsigned int kmem_cache_size(struct kmem_cache *);
 const char *kmem_cache_name(struct kmem_cache *);
 int kmem_ptr_validate(struct kmem_cache *cachep, const void *ptr);
+int kmem_cache_defrag(int node);
 
 /*
  * Please use this macro to create slab caches. Simply specify the
Index: linux-2.6.22-rc6-mm1/mm/vmscan.c
===================================================================
--- linux-2.6.22-rc6-mm1.orig/mm/vmscan.c	2007-07-04 09:53:59.000000000 -0700
+++ linux-2.6.22-rc6-mm1/mm/vmscan.c	2007-07-04 09:59:08.000000000 -0700
@@ -152,10 +152,18 @@ EXPORT_SYMBOL(unregister_shrinker);
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
@@ -218,6 +226,8 @@ unsigned long shrink_slab(unsigned long 
 		shrinker->nr += total_scan;
 	}
 	up_read(&shrinker_rwsem);
+	if (gfp_mask & __GFP_FS)
+		kmem_cache_defrag(zone ? zone_to_nid(zone) : -1);
 	return ret;
 }
 
@@ -1163,7 +1173,8 @@ unsigned long try_to_free_pages(struct z
 		if (!priority)
 			disable_swap_token();
 		nr_reclaimed += shrink_zones(priority, zones, &sc);
-		shrink_slab(sc.nr_scanned, gfp_mask, lru_pages);
+		shrink_slab(sc.nr_scanned, gfp_mask, lru_pages,
+						NULL);
 		if (reclaim_state) {
 			nr_reclaimed += reclaim_state->reclaimed_slab;
 			reclaim_state->reclaimed_slab = 0;
@@ -1333,7 +1344,7 @@ loop_again:
 			nr_reclaimed += shrink_zone(priority, zone, &sc);
 			reclaim_state->reclaimed_slab = 0;
 			nr_slab = shrink_slab(sc.nr_scanned, GFP_KERNEL,
-						lru_pages);
+						lru_pages, zone);
 			nr_reclaimed += reclaim_state->reclaimed_slab;
 			total_scanned += sc.nr_scanned;
 			if (zone->all_unreclaimable)
@@ -1601,7 +1612,7 @@ unsigned long shrink_all_memory(unsigned
 	/* If slab caches are huge, it's better to hit them first */
 	while (nr_slab >= lru_pages) {
 		reclaim_state.reclaimed_slab = 0;
-		shrink_slab(nr_pages, sc.gfp_mask, lru_pages);
+		shrink_slab(nr_pages, sc.gfp_mask, lru_pages, NULL);
 		if (!reclaim_state.reclaimed_slab)
 			break;
 
@@ -1639,7 +1650,7 @@ unsigned long shrink_all_memory(unsigned
 
 			reclaim_state.reclaimed_slab = 0;
 			shrink_slab(sc.nr_scanned, sc.gfp_mask,
-					count_lru_pages());
+					count_lru_pages(), NULL);
 			ret += reclaim_state.reclaimed_slab;
 			if (ret >= nr_pages)
 				goto out;
@@ -1656,7 +1667,8 @@ unsigned long shrink_all_memory(unsigned
 	if (!ret) {
 		do {
 			reclaim_state.reclaimed_slab = 0;
-			shrink_slab(nr_pages, sc.gfp_mask, count_lru_pages());
+			shrink_slab(nr_pages, sc.gfp_mask,
+					count_lru_pages(), NULL);
 			ret += reclaim_state.reclaimed_slab;
 		} while (ret < nr_pages && reclaim_state.reclaimed_slab > 0);
 	}
@@ -1816,7 +1828,8 @@ static int __zone_reclaim(struct zone *z
 		 * Note that shrink_slab will free memory on all zones and may
 		 * take a long time.
 		 */
-		while (shrink_slab(sc.nr_scanned, gfp_mask, order) &&
+		while (shrink_slab(sc.nr_scanned, gfp_mask, order,
+						zone) &&
 			zone_page_state(zone, NR_SLAB_RECLAIMABLE) >
 				slab_reclaimable - nr_pages)
 			;
Index: linux-2.6.22-rc6-mm1/fs/drop_caches.c
===================================================================
--- linux-2.6.22-rc6-mm1.orig/fs/drop_caches.c	2007-07-04 09:53:59.000000000 -0700
+++ linux-2.6.22-rc6-mm1/fs/drop_caches.c	2007-07-04 09:56:22.000000000 -0700
@@ -52,7 +52,7 @@ void drop_slab(void)
 	int nr_objects;
 
 	do {
-		nr_objects = shrink_slab(1000, GFP_KERNEL, 1000);
+		nr_objects = shrink_slab(1000, GFP_KERNEL, 1000, NULL);
 	} while (nr_objects > 10);
 }
 
Index: linux-2.6.22-rc6-mm1/include/linux/mm.h
===================================================================
--- linux-2.6.22-rc6-mm1.orig/include/linux/mm.h	2007-07-04 09:53:59.000000000 -0700
+++ linux-2.6.22-rc6-mm1/include/linux/mm.h	2007-07-04 09:56:22.000000000 -0700
@@ -1248,7 +1248,7 @@ int in_gate_area_no_task(unsigned long a
 int drop_caches_sysctl_handler(struct ctl_table *, int, struct file *,
 					void __user *, size_t *, loff_t *);
 unsigned long shrink_slab(unsigned long scanned, gfp_t gfp_mask,
-			unsigned long lru_pages);
+			unsigned long lru_pages, struct zone *zone);
 extern void drop_pagecache_sb(struct super_block *);
 void drop_pagecache(void);
 void drop_slab(void);

-- 
