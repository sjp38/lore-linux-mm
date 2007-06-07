From: clameter@sgi.com
Subject: [patch 04/12] SLUB: Slab defragmentation trigger
Date: Thu, 07 Jun 2007 14:55:33 -0700
Message-ID: <20070607215908.970794413@sgi.com>
References: <20070607215529.147027769@sgi.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S966698AbXFGWGS@vger.kernel.org>
Content-Disposition: inline; filename=slab_defrag_trigger
Sender: linux-kernel-owner@vger.kernel.org
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, dgc@sgi.com, Michal Piotrowski <michal.k.k.piotrowski@gmail.com>, Mel Gorman <mel@skynet.ie>
List-Id: linux-mm.kvack.org

At some point slab defragmentation needs to be triggered. The logical
point for this is after slab shrinking was performed in vmscan.c. At
that point the fragmentation ratio of a slab was increased by objects
being freed. So we call kmem_cache_defrag from there.

kmem_cache_defrag takes the defrag ratio to make the decision to
defrag a slab or not. We define a new VM tunable

slab_defrag_ratio

that contains the limit to trigger slab defragmentation.

slab_shrink() from vmscan.c is called in some contexts to do
global shrinking of slabs and in others to do shrinking for
a particular zone. Pass the node number of the zone to
slab_shrink, so that slab_shrink can call kmem_cache_defrag()
and restrict the defragmentation to the node that is under
memory pressure.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 Documentation/sysctl/vm.txt |   25 +++++++++++++++++++++++++
 fs/drop_caches.c            |    2 +-
 include/linux/mm.h          |    2 +-
 include/linux/slab.h        |    1 +
 kernel/sysctl.c             |   10 ++++++++++
 mm/vmscan.c                 |   34 +++++++++++++++++++++++++++-------
 6 files changed, 65 insertions(+), 9 deletions(-)

Index: slub/Documentation/sysctl/vm.txt
===================================================================
--- slub.orig/Documentation/sysctl/vm.txt	2007-06-07 14:20:48.000000000 -0700
+++ slub/Documentation/sysctl/vm.txt	2007-06-07 14:22:35.000000000 -0700
@@ -35,6 +35,7 @@ Currently, these files are in /proc/sys/
 - swap_prefetch
 - swap_prefetch_delay
 - swap_prefetch_sleep
+- slab_defrag_ratio
 
 ==============================================================
 
@@ -300,3 +301,27 @@ sleep for when the ram is found to be fu
 further.
 
 The default value is 5.
+
+==============================================================
+
+slab_defrag_ratio
+
+After shrinking the slabs the system checks if slabs have a lower usage
+ratio than the percentage given here. If so then slab defragmentation is
+activated to increase the usage ratio of the slab and in order to free
+memory.
+
+This is the percentage of objects allocated of the total possible number
+of objects in a slab. A lower percentage signifies more fragmentation.
+
+Note slab defragmentation only works on slabs that have the proper methods
+defined (see /sys/slab/<slabname>/ops). When this text was written slab
+defragmentation was only supported by the dentry cache and the inode cache.
+
+The main purpose of the slab defragmentation is to address pathological
+situations in which large amounts of inodes or dentries have been
+removed from the system. That may leave lots of slabs around with just
+a few objects. Slab defragmentation removes these slabs.
+
+The default value is 30% meaning for 3 items in use we have 7 free
+and unused items.
Index: slub/include/linux/slab.h
===================================================================
--- slub.orig/include/linux/slab.h	2007-06-07 14:20:48.000000000 -0700
+++ slub/include/linux/slab.h	2007-06-07 14:22:35.000000000 -0700
@@ -85,6 +85,7 @@ void kmem_cache_free(struct kmem_cache *
 unsigned int kmem_cache_size(struct kmem_cache *);
 const char *kmem_cache_name(struct kmem_cache *);
 int kmem_ptr_validate(struct kmem_cache *cachep, const void *ptr);
+int kmem_cache_defrag(int percentage, int node);
 
 /*
  * Please use this macro to create slab caches. Simply specify the
Index: slub/kernel/sysctl.c
===================================================================
--- slub.orig/kernel/sysctl.c	2007-06-07 14:20:48.000000000 -0700
+++ slub/kernel/sysctl.c	2007-06-07 14:22:35.000000000 -0700
@@ -81,6 +81,7 @@ extern int percpu_pagelist_fraction;
 extern int compat_log;
 extern int maps_protect;
 extern int sysctl_stat_interval;
+extern int sysctl_slab_defrag_ratio;
 extern int audit_argv_kb;
 
 /* this is needed for the proc_dointvec_minmax for [fs_]overflow UID and GID */
@@ -928,6 +929,15 @@ static ctl_table vm_table[] = {
 		.strategy	= &sysctl_intvec,
 		.extra1		= &zero,
 	},
+	{
+		.ctl_name	= CTL_UNNUMBERED,
+		.procname	= "slab_defrag_ratio",
+		.data		= &sysctl_slab_defrag_ratio,
+		.maxlen		= sizeof(sysctl_slab_defrag_ratio),
+		.mode		= 0644,
+		.proc_handler	= &proc_dointvec,
+		.strategy	= &sysctl_intvec,
+	},
 #ifdef HAVE_ARCH_PICK_MMAP_LAYOUT
 	{
 		.ctl_name	= VM_LEGACY_VA_LAYOUT,
Index: slub/mm/vmscan.c
===================================================================
--- slub.orig/mm/vmscan.c	2007-06-07 14:20:48.000000000 -0700
+++ slub/mm/vmscan.c	2007-06-07 14:25:25.000000000 -0700
@@ -135,6 +135,12 @@ void unregister_shrinker(struct shrinker
 EXPORT_SYMBOL(unregister_shrinker);
 
 #define SHRINK_BATCH 128
+
+/*
+ * Slabs should be defragmented if less than 30% of objects are allocated.
+ */
+int sysctl_slab_defrag_ratio = 30;
+
 /*
  * Call the shrink functions to age shrinkable caches
  *
@@ -152,10 +158,19 @@ EXPORT_SYMBOL(unregister_shrinker);
  * are eligible for the caller's allocation attempt.  It is used for balancing
  * slab reclaim versus page reclaim.
  *
+ * zone is the zone for which we are shrinking the slabs. If the intent
+ * is to do a global shrink then zone can be be NULL. This is currently
+ * only used to limit slab defragmentation to a NUMA node. The performace
+ * of shrink_slab would be better (in particular under NUMA) if it could
+ * be targeted as a whole to a zone that is under memory pressure but
+ * the VFS datastructures do not allow that at the present time. As a
+ * result zone_reclaim must perform global slab reclaim in order
+ * to free up memory in a zone.
+ *
  * Returns the number of slab objects which we shrunk.
  */
 unsigned long shrink_slab(unsigned long scanned, gfp_t gfp_mask,
-			unsigned long lru_pages)
+			unsigned long lru_pages, struct zone *zone)
 {
 	struct shrinker *shrinker;
 	unsigned long ret = 0;
@@ -218,6 +233,8 @@ unsigned long shrink_slab(unsigned long 
 		shrinker->nr += total_scan;
 	}
 	up_read(&shrinker_rwsem);
+	kmem_cache_defrag(sysctl_slab_defrag_ratio,
+		zone ? zone_to_nid(zone) : -1);
 	return ret;
 }
 
@@ -1163,7 +1180,8 @@ unsigned long try_to_free_pages(struct z
 		if (!priority)
 			disable_swap_token();
 		nr_reclaimed += shrink_zones(priority, zones, &sc);
-		shrink_slab(sc.nr_scanned, gfp_mask, lru_pages);
+		shrink_slab(sc.nr_scanned, gfp_mask, lru_pages,
+						NULL);
 		if (reclaim_state) {
 			nr_reclaimed += reclaim_state->reclaimed_slab;
 			reclaim_state->reclaimed_slab = 0;
@@ -1333,7 +1351,7 @@ loop_again:
 			nr_reclaimed += shrink_zone(priority, zone, &sc);
 			reclaim_state->reclaimed_slab = 0;
 			nr_slab = shrink_slab(sc.nr_scanned, GFP_KERNEL,
-						lru_pages);
+						lru_pages, zone);
 			nr_reclaimed += reclaim_state->reclaimed_slab;
 			total_scanned += sc.nr_scanned;
 			if (zone->all_unreclaimable)
@@ -1601,7 +1619,7 @@ unsigned long shrink_all_memory(unsigned
 	/* If slab caches are huge, it's better to hit them first */
 	while (nr_slab >= lru_pages) {
 		reclaim_state.reclaimed_slab = 0;
-		shrink_slab(nr_pages, sc.gfp_mask, lru_pages);
+		shrink_slab(nr_pages, sc.gfp_mask, lru_pages, NULL);
 		if (!reclaim_state.reclaimed_slab)
 			break;
 
@@ -1639,7 +1657,7 @@ unsigned long shrink_all_memory(unsigned
 
 			reclaim_state.reclaimed_slab = 0;
 			shrink_slab(sc.nr_scanned, sc.gfp_mask,
-					count_lru_pages());
+					count_lru_pages(), NULL);
 			ret += reclaim_state.reclaimed_slab;
 			if (ret >= nr_pages)
 				goto out;
@@ -1656,7 +1674,8 @@ unsigned long shrink_all_memory(unsigned
 	if (!ret) {
 		do {
 			reclaim_state.reclaimed_slab = 0;
-			shrink_slab(nr_pages, sc.gfp_mask, count_lru_pages());
+			shrink_slab(nr_pages, sc.gfp_mask,
+					count_lru_pages(), NULL);
 			ret += reclaim_state.reclaimed_slab;
 		} while (ret < nr_pages && reclaim_state.reclaimed_slab > 0);
 	}
@@ -1816,7 +1835,8 @@ static int __zone_reclaim(struct zone *z
 		 * Note that shrink_slab will free memory on all zones and may
 		 * take a long time.
 		 */
-		while (shrink_slab(sc.nr_scanned, gfp_mask, order) &&
+		while (shrink_slab(sc.nr_scanned, gfp_mask, order,
+						zone) &&
 			zone_page_state(zone, NR_SLAB_RECLAIMABLE) >
 				slab_reclaimable - nr_pages)
 			;
Index: slub/fs/drop_caches.c
===================================================================
--- slub.orig/fs/drop_caches.c	2007-06-07 14:20:48.000000000 -0700
+++ slub/fs/drop_caches.c	2007-06-07 14:22:35.000000000 -0700
@@ -52,7 +52,7 @@ void drop_slab(void)
 	int nr_objects;
 
 	do {
-		nr_objects = shrink_slab(1000, GFP_KERNEL, 1000);
+		nr_objects = shrink_slab(1000, GFP_KERNEL, 1000, NULL);
 	} while (nr_objects > 10);
 }
 
Index: slub/include/linux/mm.h
===================================================================
--- slub.orig/include/linux/mm.h	2007-06-07 14:20:48.000000000 -0700
+++ slub/include/linux/mm.h	2007-06-07 14:22:35.000000000 -0700
@@ -1240,7 +1240,7 @@ int in_gate_area_no_task(unsigned long a
 int drop_caches_sysctl_handler(struct ctl_table *, int, struct file *,
 					void __user *, size_t *, loff_t *);
 unsigned long shrink_slab(unsigned long scanned, gfp_t gfp_mask,
-			unsigned long lru_pages);
+			unsigned long lru_pages, struct zone *zone);
 extern void drop_pagecache_sb(struct super_block *);
 void drop_pagecache(void);
 void drop_slab(void);

-- 
