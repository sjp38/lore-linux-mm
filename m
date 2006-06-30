Date: Fri, 30 Jun 2006 14:14:55 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: ZVC/zone_reclaim: Leave 1% of unmapped pagecache pages for file
 I/O
In-Reply-To: <200606301219.19473.ak@suse.de>
Message-ID: <Pine.LNX.4.64.0606301407460.8022@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0606291949320.30754@schroedinger.engr.sgi.com>
 <200606301219.19473.ak@suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: akpm@osdl.org, schamp@sgi.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 30 Jun 2006, Andi Kleen wrote:

> Shouldn't that be some kind of tunable? Magic numbers are bad.

Is this okay?

zone_reclaim: proc limit for the minimal amount of unmapped pagecache pages

Add /proc/sys/vm/min_unmapped to be able to control
the percentage of unmapped pages. Zone reclaim will only be triggered
if more than that number of unmapped pages exist in a zone.

And remove some outdated comments.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.17-mm4/include/linux/swap.h
===================================================================
--- linux-2.6.17-mm4.orig/include/linux/swap.h	2006-06-29 13:34:12.572520730 -0700
+++ linux-2.6.17-mm4/include/linux/swap.h	2006-06-30 14:02:47.801113209 -0700
@@ -190,6 +190,7 @@ extern long vm_total_pages;
 
 #ifdef CONFIG_NUMA
 extern int zone_reclaim_mode;
+extern int sysctl_min_unmapped;
 extern int zone_reclaim(struct zone *, gfp_t, unsigned int);
 #else
 #define zone_reclaim_mode 0
Index: linux-2.6.17-mm4/mm/vmscan.c
===================================================================
--- linux-2.6.17-mm4.orig/mm/vmscan.c	2006-06-30 13:35:32.094681361 -0700
+++ linux-2.6.17-mm4/mm/vmscan.c	2006-06-30 14:04:48.663761285 -0700
@@ -1511,10 +1511,6 @@ module_init(kswapd_init)
  *
  * If non-zero call zone_reclaim when the number of free pages falls below
  * the watermarks.
- *
- * In the future we may add flags to the mode. However, the page allocator
- * should only have to check that zone_reclaim_mode != 0 before calling
- * zone_reclaim().
  */
 int zone_reclaim_mode __read_mostly;
 
@@ -1532,6 +1528,12 @@ int zone_reclaim_mode __read_mostly;
 #define ZONE_RECLAIM_PRIORITY 4
 
 /*
+ * Percentile of pages in a zone that must be unmapped
+ * for zone_reclaim to occur.
+ */
+int sysctl_min_unmapped = 1;
+
+/*
  * Try to free up some pages from this zone through reclaim.
  */
 static int __zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
@@ -1603,16 +1605,11 @@ int zone_reclaim(struct zone *zone, gfp_
 	 * A small portion of unmapped file backed pages is needed for
 	 * file I/O otherwise pages read by file I/O will be immediately
 	 * thrown out if the zone is overallocated. So we do not reclaim
-	 * if less than 1% of the zone is used by unmapped file backed pages.
-	 *
-	 * The division by 128 approximates this and is here because a division
-	 * would be too expensive in this hot code path.
-	 *
-	 * Is it be useful to have a way to set the limit via /proc?
+	 * if less than a specified percentage of the zone is used by
+	 * unmapped file backed pages.
 	 */
 	if (zone_page_state(zone, NR_FILE_PAGES) -
-		zone_page_state(zone, NR_FILE_MAPPED) <
-			zone->present_pages / 128)
+		zone_page_state(zone, NR_FILE_MAPPED) <= zone->min_unmapped)
 				return 0;
 
 	/*
Index: linux-2.6.17-mm4/mm/page_alloc.c
===================================================================
--- linux-2.6.17-mm4.orig/mm/page_alloc.c	2006-06-29 13:34:13.101784855 -0700
+++ linux-2.6.17-mm4/mm/page_alloc.c	2006-06-30 13:52:05.542017732 -0700
@@ -2098,6 +2098,10 @@ static void __meminit free_area_init_cor
 
 		zone->spanned_pages = size;
 		zone->present_pages = realsize;
+#ifdef CONFIG_NUMA
+		zone->min_unmapped = (realsize * sysctl_min_unmapped)
+						/ 100;
+#endif
 		zone->name = zone_names[j];
 		spin_lock_init(&zone->lock);
 		spin_lock_init(&zone->lru_lock);
@@ -2391,6 +2395,24 @@ int min_free_kbytes_sysctl_handler(ctl_t
 	return 0;
 }
 
+#ifdef CONFIG_NUMA
+int sysctl_min_unmapped_sysctl_handler(ctl_table *table, int write,
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
+		zone->min_unmapped = (zone->present_pages *
+				sysctl_min_unmapped) / 100;
+	return 0;
+}
+#endif
+
 /*
  * lowmem_reserve_ratio_sysctl_handler - just a wrapper around
  *	proc_dointvec() so that we can call setup_per_zone_lowmem_reserve()
Index: linux-2.6.17-mm4/kernel/sysctl.c
===================================================================
--- linux-2.6.17-mm4.orig/kernel/sysctl.c	2006-06-29 13:34:12.980698597 -0700
+++ linux-2.6.17-mm4/kernel/sysctl.c	2006-06-30 13:50:32.609293703 -0700
@@ -998,6 +998,17 @@ static ctl_table vm_table[] = {
 		.strategy	= &sysctl_intvec,
 		.extra1		= &zero,
 	},
+	{
+		.ctl_name	= VM_MIN_UNMAPPED,
+		.procname	= "min_unmapped",
+		.data		= &sysctl_min_unmapped,
+		.maxlen		= sizeof(sysctl_min_unmapped),
+		.mode		= 0644,
+		.proc_handler	= &sysctl_min_unmapped_sysctl_handler,
+		.strategy	= &sysctl_intvec,
+		.extra1		= &zero,
+		.extra2		= &one_hundred,
+	},
 #endif
 #ifdef CONFIG_X86_32
 	{
Index: linux-2.6.17-mm4/include/linux/sysctl.h
===================================================================
--- linux-2.6.17-mm4.orig/include/linux/sysctl.h	2006-06-29 13:34:12.603768796 -0700
+++ linux-2.6.17-mm4/include/linux/sysctl.h	2006-06-30 13:50:32.610270205 -0700
@@ -189,7 +189,7 @@ enum
 	VM_DROP_PAGECACHE=29,	/* int: nuke lots of pagecache */
 	VM_PERCPU_PAGELIST_FRACTION=30,/* int: fraction of pages in each percpu_pagelist */
 	VM_ZONE_RECLAIM_MODE=31, /* reclaim local zone memory before going off node */
-	VM_ZONE_RECLAIM_INTERVAL=32, /* time period to wait after reclaim failure */
+	VM_MIN_UNMAPPED=32,	/* Set min percent of unmapped pages */
 	VM_PANIC_ON_OOM=33,	/* panic at out-of-memory */
 	VM_VDSO_ENABLED=34,	/* map VDSO into new processes? */
 	VM_SWAP_PREFETCH=35,	/* swap prefetch */
Index: linux-2.6.17-mm4/include/linux/mmzone.h
===================================================================
--- linux-2.6.17-mm4.orig/include/linux/mmzone.h	2006-06-29 13:34:12.302029655 -0700
+++ linux-2.6.17-mm4/include/linux/mmzone.h	2006-06-30 13:50:32.611246707 -0700
@@ -150,6 +150,10 @@ struct zone {
 	unsigned long		lowmem_reserve[MAX_NR_ZONES];
 
 #ifdef CONFIG_NUMA
+	/*
+	 * zone reclaim becomes active if more unmapped pages exist.
+	 */
+	unsigned long		min_unmapped;
 	struct per_cpu_pageset	*pageset[NR_CPUS];
 #else
 	struct per_cpu_pageset	pageset[NR_CPUS];
@@ -420,6 +424,8 @@ int lowmem_reserve_ratio_sysctl_handler(
 					void __user *, size_t *, loff_t *);
 int percpu_pagelist_fraction_sysctl_handler(struct ctl_table *, int, struct file *,
 					void __user *, size_t *, loff_t *);
+int sysctl_min_unmapped_sysctl_handler(struct ctl_table *, int,
+			struct file *, void __user *, size_t *, loff_t *);
 
 #include <linux/topology.h>
 /* Returns the number of the current Node. */
Index: linux-2.6.17-mm4/Documentation/sysctl/vm.txt
===================================================================
--- linux-2.6.17-mm4.orig/Documentation/sysctl/vm.txt	2006-06-29 13:34:05.678416074 -0700
+++ linux-2.6.17-mm4/Documentation/sysctl/vm.txt	2006-06-30 13:50:32.611246707 -0700
@@ -28,6 +28,7 @@ Currently, these files are in /proc/sys/
 - block_dump
 - drop-caches
 - zone_reclaim_mode
+- min_unmapped
 - panic_on_oom
 - swap_prefetch
 - readahead_ratio
@@ -171,6 +172,17 @@ in all nodes of the system.
 
 =============================================================
 
+min_unmapped:
+
+A percentage of the file backed pages in each zone. Zone reclaim will only
+occur if more than this percentage of pages are file backed and unmapped.
+This is to insure that a minimal amount of local pages is still available
+for file I/O even if the node is overallocated.
+
+The default is 1 percent.
+
+=============================================================
+
 panic_on_oom
 
 This enables or disables panic on out-of-memory feature.  If this is set to 1,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
