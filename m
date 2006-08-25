Date: Fri, 25 Aug 2006 15:22:14 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: zone_reclaim: dynamic zone based slab reclaim
In-Reply-To: <Pine.LNX.4.64.0608251500560.11154@schroedinger.engr.sgi.com>
Message-ID: <Pine.LNX.4.64.0608251521190.11205@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0608251500560.11154@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: npiggin@suse.de, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Currently one can enable slab reclaim by setting an explicit option. Slab
reclaim is then used as a final option if the freeing of unmapped file
backed pages is not enough to free enough pages to allow a local allocation.

However, that means that the slab can grow excessively and that most memory
of a node may be used by slabs. We have had a case where a machine with 46GB
of memory was using 40-42GB for slab. Zone reclaim was effective in dealing
with pagecache pages. However, slab reclaim was only done during global
reclaim (which is a bit rare on NUMA systems).

This patch implements slab reclaim during zone reclaim. Zone reclaim occurs
if there is a danger of an off node allocation. At that point we

1. Shrink the per node page cache if the number of pagecache
   pages is more than min_unmapped_ratio percent of pages in a zone.

2. Shrink the slab cache if the number of the nodes reclaimable slab pages
   (patch depends on earlier one that implements that counter)
   are more than min_slab_ratio (a new /proc/sys/vm tunable).

The shrinking of the slab cache is a bit problematic since it is not node
specific. So we simply calculate what point in the slab we want to reach
(current per node slab use minus the number of pages that neeed to be
allocated) and then repeately run the global reclaim until that is
unsuccessful or we have reached the limit. I hope we will have zone based
slab reclaim at some point which will make that easier.

The default for the min_slab_limit is 5%

Also remove the slab option from /proc/sys/vm/zone_reclaim_mode.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.18-rc4-mm2/mm/vmscan.c
===================================================================
--- linux-2.6.18-rc4-mm2.orig/mm/vmscan.c	2006-08-25 15:16:33.916779821 -0700
+++ linux-2.6.18-rc4-mm2/mm/vmscan.c	2006-08-25 15:16:48.634619679 -0700
@@ -1535,7 +1535,6 @@ int zone_reclaim_mode __read_mostly;
 #define RECLAIM_ZONE (1<<0)	/* Run shrink_cache on the zone */
 #define RECLAIM_WRITE (1<<1)	/* Writeout pages during reclaim */
 #define RECLAIM_SWAP (1<<2)	/* Swap pages out during reclaim */
-#define RECLAIM_SLAB (1<<3)	/* Do a global slab shrink if the zone is out of memory */
 
 /*
  * Priority for ZONE_RECLAIM. This determines the fraction of pages
@@ -1551,6 +1550,12 @@ int zone_reclaim_mode __read_mostly;
 int sysctl_min_unmapped_ratio = 1;
 
 /*
+ * If the number of slab pages in a zone grows beyond this percentage then
+ * slab reclaim needs to occur.
+ */
+int sysctl_min_slab_ratio = 5;
+
+/*
  * Try to free up some pages from this zone through reclaim.
  */
 static int __zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
@@ -1581,29 +1586,36 @@ static int __zone_reclaim(struct zone *z
 	reclaim_state.reclaimed_slab = 0;
 	p->reclaim_state = &reclaim_state;
 
-	/*
-	 * Free memory by calling shrink zone with increasing priorities
-	 * until we have enough memory freed.
-	 */
-	priority = ZONE_RECLAIM_PRIORITY;
-	do {
-		nr_reclaimed += shrink_zone(priority, zone, &sc);
-		priority--;
-	} while (priority >= 0 && nr_reclaimed < nr_pages);
+	if (zone_page_state(zone, NR_FILE_PAGES) -
+		zone_page_state(zone, NR_FILE_MAPPED) >
+		zone->min_unmapped_ratio) {
+		/*
+		 * Free memory by calling shrink zone with increasing
+		 * priorities until we have enough memory freed.
+		 */
+		priority = ZONE_RECLAIM_PRIORITY;
+		do {
+			nr_reclaimed += shrink_zone(priority, zone, &sc);
+			priority--;
+		} while (priority >= 0 && nr_reclaimed < nr_pages);
+	}
 
-	if (nr_reclaimed < nr_pages && (zone_reclaim_mode & RECLAIM_SLAB)) {
+	if (zone_page_state(zone, NR_SLAB_RECLAIM) > zone->min_slab_ratio) {
 		/*
 		 * shrink_slab() does not currently allow us to determine how
-		 * many pages were freed in this zone. So we just shake the slab
-		 * a bit and then go off node for this particular allocation
-		 * despite possibly having freed enough memory to allocate in
-		 * this zone.  If we freed local memory then the next
-		 * allocations will be local again.
+		 * many pages were freed in this zone. So we take the current
+		 * number of slab pages and shake the slab until it is reduced
+		 * by the same nr_pages that we used for reclaiming unmapped
+		 * pages.
 		 *
-		 * shrink_slab will free memory on all zones and may take
+		 * Note that shrink_slab will free memory on all zones and may take
 		 * a long time.
 		 */
-		shrink_slab(sc.nr_scanned, gfp_mask, order);
+		unsigned long limit = zone_page_state(zone, NR_SLAB_RECLAIM)
+							- nr_pages;
+
+		while (shrink_slab(sc.nr_scanned, gfp_mask, order) &&
+			zone_page_state(zone, NR_SLAB_RECLAIM) > limit) ;
 	}
 
 	p->reclaim_state = NULL;
@@ -1617,7 +1629,8 @@ int zone_reclaim(struct zone *zone, gfp_
 	int node_id;
 
 	/*
-	 * Zone reclaim reclaims unmapped file backed pages.
+	 * Zone reclaim reclaims unmapped file backed pages and
+	 * slab pages if we are over the defined limits.
 	 *
 	 * A small portion of unmapped file backed pages is needed for
 	 * file I/O otherwise pages read by file I/O will be immediately
@@ -1626,7 +1639,8 @@ int zone_reclaim(struct zone *zone, gfp_
 	 * unmapped file backed pages.
 	 */
 	if (zone_page_state(zone, NR_FILE_PAGES) -
-	    zone_page_state(zone, NR_FILE_MAPPED) <= zone->min_unmapped_ratio)
+	    zone_page_state(zone, NR_FILE_MAPPED) <= zone->min_unmapped_ratio
+	    && zone_page_state(zone, NR_SLAB_RECLAIM) <= zone->min_slab_ratio)
 		return 0;
 
 	/*
Index: linux-2.6.18-rc4-mm2/mm/page_alloc.c
===================================================================
--- linux-2.6.18-rc4-mm2.orig/mm/page_alloc.c	2006-08-23 12:37:01.845820991 -0700
+++ linux-2.6.18-rc4-mm2/mm/page_alloc.c	2006-08-25 15:16:35.083699847 -0700
@@ -2103,6 +2103,7 @@ static void __meminit free_area_init_cor
 #ifdef CONFIG_NUMA
 		zone->min_unmapped_ratio = (realsize*sysctl_min_unmapped_ratio)
 						/ 100;
+		zone->min_slab_ratio = (realsize*sysctl_min_slab_ratio) / 100;
 #endif
 		zone->name = zone_names[j];
 		spin_lock_init(&zone->lock);
@@ -2416,6 +2417,22 @@ int sysctl_min_unmapped_ratio_sysctl_han
 				sysctl_min_unmapped_ratio) / 100;
 	return 0;
 }
+
+int sysctl_min_slab_ratio_sysctl_handler(ctl_table *table, int write,
+	struct file *file, void __user *buffer, size_t *length, loff_t *ppos)
+{
+	struct zone *zone;
+	int rc;
+
+	rc = proc_dointvec_minmax(table, write, file, buffer, length, ppos);
+	if (rc)
+		return rc;
+
+	for_each_zone(zone)
+		zone->min_slab_ratio = (zone->present_pages *
+				sysctl_min_slab_ratio) / 100;
+	return 0;
+}
 #endif
 
 /*
Index: linux-2.6.18-rc4-mm2/kernel/sysctl.c
===================================================================
--- linux-2.6.18-rc4-mm2.orig/kernel/sysctl.c	2006-08-23 12:37:01.764771315 -0700
+++ linux-2.6.18-rc4-mm2/kernel/sysctl.c	2006-08-25 15:16:35.085652851 -0700
@@ -1023,6 +1023,17 @@ static ctl_table vm_table[] = {
 		.extra1		= &zero,
 		.extra2		= &one_hundred,
 	},
+	{
+		.ctl_name	= VM_MIN_SLAB,
+		.procname	= "min_slab_ratio",
+		.data		= &sysctl_min_slab_ratio,
+		.maxlen		= sizeof(sysctl_min_slab_ratio),
+		.mode		= 0644,
+		.proc_handler	= &sysctl_min_slab_ratio_sysctl_handler,
+		.strategy	= &sysctl_intvec,
+		.extra1		= &zero,
+		.extra2		= &one_hundred,
+	},
 #endif
 #ifdef CONFIG_X86_32
 	{
Index: linux-2.6.18-rc4-mm2/include/linux/mmzone.h
===================================================================
--- linux-2.6.18-rc4-mm2.orig/include/linux/mmzone.h	2006-08-25 15:16:33.911897310 -0700
+++ linux-2.6.18-rc4-mm2/include/linux/mmzone.h	2006-08-25 15:16:35.086629353 -0700
@@ -170,6 +170,7 @@ struct zone {
 	 * zone reclaim becomes active if more unmapped pages exist.
 	 */
 	unsigned long		min_unmapped_ratio;
+	unsigned long		min_slab_ratio;
 	struct per_cpu_pageset	*pageset[NR_CPUS];
 #else
 	struct per_cpu_pageset	pageset[NR_CPUS];
@@ -453,6 +454,8 @@ int percpu_pagelist_fraction_sysctl_hand
 					void __user *, size_t *, loff_t *);
 int sysctl_min_unmapped_ratio_sysctl_handler(struct ctl_table *, int,
 			struct file *, void __user *, size_t *, loff_t *);
+int sysctl_min_slab_ratio_sysctl_handler(struct ctl_table *, int,
+			struct file *, void __user *, size_t *, loff_t *);
 
 #include <linux/topology.h>
 /* Returns the number of the current Node. */
Index: linux-2.6.18-rc4-mm2/Documentation/sysctl/vm.txt
===================================================================
--- linux-2.6.18-rc4-mm2.orig/Documentation/sysctl/vm.txt	2006-08-23 12:36:55.553241342 -0700
+++ linux-2.6.18-rc4-mm2/Documentation/sysctl/vm.txt	2006-08-25 15:17:11.571677832 -0700
@@ -29,6 +29,7 @@ Currently, these files are in /proc/sys/
 - drop-caches
 - zone_reclaim_mode
 - min_unmapped_ratio
+- min_slab_ratio
 - panic_on_oom
 - swap_prefetch
 - readahead_ratio
@@ -141,7 +142,6 @@ This is value ORed together of
 1	= Zone reclaim on
 2	= Zone reclaim writes dirty pages out
 4	= Zone reclaim swaps pages
-8	= Also do a global slab reclaim pass
 
 zone_reclaim_mode is set during bootup to 1 if it is determined that pages
 from remote zones will cause a measurable performance reduction. The
@@ -165,18 +165,13 @@ Allowing regular swap effectively restri
 node unless explicitly overridden by memory policies or cpuset
 configurations.
 
-It may be advisable to allow slab reclaim if the system makes heavy
-use of files and builds up large slab caches. However, the slab
-shrink operation is global, may take a long time and free slabs
-in all nodes of the system.
-
 =============================================================
 
 min_unmapped_ratio:
 
 This is available only on NUMA kernels.
 
-A percentage of the file backed pages in each zone.  Zone reclaim will only
+A percentage of the total pages in each zone.  Zone reclaim will only
 occur if more than this percentage of pages are file backed and unmapped.
 This is to insure that a minimal amount of local pages is still available for
 file I/O even if the node is overallocated.
@@ -185,6 +180,24 @@ The default is 1 percent.
 
 =============================================================
 
+min_slab_ratio:
+
+This is available only on NUMA kernels.
+
+A percentage of the total pages in each zone.  On Zone reclaim
+(fallback from the local zone occurs) slabs will be reclaimed if more
+than this percentage of pages in a zone are reclaimable slab pages.
+This insures that the slab growth stays under control even in NUMA
+systems that rarely perform global reclaim.
+
+The default is 5 percent.
+
+Note that slab reclaim is triggered in a per zone / node fashion.
+The process of reclaiming slab memory is currently not node specific
+and may not be fast.
+
+=============================================================
+
 panic_on_oom
 
 This enables or disables panic on out-of-memory feature.  If this is set to 1,
Index: linux-2.6.18-rc4-mm2/include/linux/sysctl.h
===================================================================
--- linux-2.6.18-rc4-mm2.orig/include/linux/sysctl.h	2006-08-23 12:37:01.540175828 -0700
+++ linux-2.6.18-rc4-mm2/include/linux/sysctl.h	2006-08-25 15:16:35.088582357 -0700
@@ -197,6 +197,7 @@ enum
 	VM_SWAP_PREFETCH=35,	/* swap prefetch */
 	VM_READAHEAD_RATIO=36,	/* percent of read-ahead size to thrashing-threshold */
 	VM_READAHEAD_HIT_RATE=37, /* one accessed page legitimizes so many read-ahead pages */
+	VM_MIN_SLAB=38,		 /* Percent pages ignored by zone reclaim */
 };
 
 /* CTL_NET names: */
Index: linux-2.6.18-rc4-mm2/include/linux/swap.h
===================================================================
--- linux-2.6.18-rc4-mm2.orig/include/linux/swap.h	2006-08-23 12:37:01.539199326 -0700
+++ linux-2.6.18-rc4-mm2/include/linux/swap.h	2006-08-25 15:16:35.088582357 -0700
@@ -196,6 +196,7 @@ extern long vm_total_pages;
 #ifdef CONFIG_NUMA
 extern int zone_reclaim_mode;
 extern int sysctl_min_unmapped_ratio;
+extern int sysctl_min_slab_ratio;
 extern int zone_reclaim(struct zone *, gfp_t, unsigned int);
 #else
 #define zone_reclaim_mode 0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
