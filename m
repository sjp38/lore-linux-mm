From: Christoph Lameter <clameter@sgi.com>
Subject: [RFC 10/26] SLUB: Trigger defragmentation from memory reclaim
Date: Fri, 31 Aug 2007 18:41:17 -0700
Message-ID: <20070901014221.611405363@sgi.com>
References: <20070901014107.719506437@sgi.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline; filename=0010-slab_defrag_trigger_defrag_from_reclaim.patch
Sender: linux-fsdevel-owner@vger.kernel.org
To: Andy Whitcroft <apw@shadowen.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Christoph Hellwig <hch@lst.de>, Mel Gorman <mel@skynet.ie>, David Chinner <dgc@sgi.com>
List-Id: linux-mm.kvack.org

This patch triggers slab defragmentation from memory reclaim.
The logical point for this is after slab shrinking was performed in
vmscan.c. At that point the fragmentation ratio of a slab was increased
by objects being freed. So we call kmem_cache_defrag from there.

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

diff --git a/fs/drop_caches.c b/fs/drop_caches.c
index 59375ef..fb58e63 100644
--- a/fs/drop_caches.c
+++ b/fs/drop_caches.c
@@ -50,7 +50,7 @@ void drop_slab(void)
 	int nr_objects;
 
 	do {
-		nr_objects = shrink_slab(1000, GFP_KERNEL, 1000);
+		nr_objects = shrink_slab(1000, GFP_KERNEL, 1000, NULL);
 	} while (nr_objects > 10);
 }
 
diff --git a/include/linux/mm.h b/include/linux/mm.h
index a396aac..9fbb6ba 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1202,7 +1202,7 @@ int in_gate_area_no_task(unsigned long addr);
 int drop_caches_sysctl_handler(struct ctl_table *, int, struct file *,
 					void __user *, size_t *, loff_t *);
 unsigned long shrink_slab(unsigned long scanned, gfp_t gfp_mask,
-			unsigned long lru_pages);
+			unsigned long lru_pages, struct zone *zone);
 void drop_pagecache(void);
 void drop_slab(void);
 
diff --git a/include/linux/slab.h b/include/linux/slab.h
index 848e9a7..7d8ec17 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -61,6 +61,7 @@ void kmem_cache_free(struct kmem_cache *, void *);
 unsigned int kmem_cache_size(struct kmem_cache *);
 const char *kmem_cache_name(struct kmem_cache *);
 int kmem_ptr_validate(struct kmem_cache *cachep, const void *ptr);
+int kmem_cache_defrag(int node);
 
 /*
  * Please use this macro to create slab caches. Simply specify the
diff --git a/mm/vmscan.c b/mm/vmscan.c
index d419e10..c6882d8 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -150,10 +150,18 @@ EXPORT_SYMBOL(unregister_shrinker);
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
@@ -210,6 +218,8 @@ unsigned long shrink_slab(unsigned long scanned, gfp_t gfp_mask,
 		shrinker->nr += total_scan;
 	}
 	up_read(&shrinker_rwsem);
+	if (gfp_mask & __GFP_FS)
+		kmem_cache_defrag(zone ? zone_to_nid(zone) : -1);
 	return ret;
 }
 
@@ -1151,7 +1161,8 @@ unsigned long try_to_free_pages(struct zone **zones, int order, gfp_t gfp_mask)
 		if (!priority)
 			disable_swap_token();
 		nr_reclaimed += shrink_zones(priority, zones, &sc);
-		shrink_slab(sc.nr_scanned, gfp_mask, lru_pages);
+		shrink_slab(sc.nr_scanned, gfp_mask, lru_pages,
+						NULL);
 		if (reclaim_state) {
 			nr_reclaimed += reclaim_state->reclaimed_slab;
 			reclaim_state->reclaimed_slab = 0;
@@ -1321,7 +1332,7 @@ loop_again:
 			nr_reclaimed += shrink_zone(priority, zone, &sc);
 			reclaim_state->reclaimed_slab = 0;
 			nr_slab = shrink_slab(sc.nr_scanned, GFP_KERNEL,
-						lru_pages);
+						lru_pages, zone);
 			nr_reclaimed += reclaim_state->reclaimed_slab;
 			total_scanned += sc.nr_scanned;
 			if (zone->all_unreclaimable)
@@ -1559,7 +1570,7 @@ unsigned long shrink_all_memory(unsigned long nr_pages)
 	/* If slab caches are huge, it's better to hit them first */
 	while (nr_slab >= lru_pages) {
 		reclaim_state.reclaimed_slab = 0;
-		shrink_slab(nr_pages, sc.gfp_mask, lru_pages);
+		shrink_slab(nr_pages, sc.gfp_mask, lru_pages, NULL);
 		if (!reclaim_state.reclaimed_slab)
 			break;
 
@@ -1597,7 +1608,7 @@ unsigned long shrink_all_memory(unsigned long nr_pages)
 
 			reclaim_state.reclaimed_slab = 0;
 			shrink_slab(sc.nr_scanned, sc.gfp_mask,
-					count_lru_pages());
+					count_lru_pages(), NULL);
 			ret += reclaim_state.reclaimed_slab;
 			if (ret >= nr_pages)
 				goto out;
@@ -1614,7 +1625,8 @@ unsigned long shrink_all_memory(unsigned long nr_pages)
 	if (!ret) {
 		do {
 			reclaim_state.reclaimed_slab = 0;
-			shrink_slab(nr_pages, sc.gfp_mask, count_lru_pages());
+			shrink_slab(nr_pages, sc.gfp_mask,
+					count_lru_pages(), NULL);
 			ret += reclaim_state.reclaimed_slab;
 		} while (ret < nr_pages && reclaim_state.reclaimed_slab > 0);
 	}
@@ -1774,7 +1786,8 @@ static int __zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
 		 * Note that shrink_slab will free memory on all zones and may
 		 * take a long time.
 		 */
-		while (shrink_slab(sc.nr_scanned, gfp_mask, order) &&
+		while (shrink_slab(sc.nr_scanned, gfp_mask, order,
+						zone) &&
 			zone_page_state(zone, NR_SLAB_RECLAIMABLE) >
 				slab_reclaimable - nr_pages)
 			;
-- 
1.5.2.4

-- 
