Date: Tue, 23 Jan 2007 16:49:55 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: [RFC] Limit the size of the pagecache
Message-ID: <Pine.LNX.4.64.0701231645260.5239@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Aubrey Li <aubreylee@gmail.com>
Cc: Vaidyanathan Srinivasan <svaidy@linux.vnet.ibm.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Robin Getz <rgetz@blackfin.uclinux.org>, "Henn, erich, Michael" <Michael.Hennerich@analog.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

This is a patch using some of Aubrey's work plugging it in what is IMHO 
the right way. Feel free to improve on it. I have gotten repeatedly 
requests to be able to limit the pagecache. With the revised VM statistics 
this is now actually possile. I'd like to know more about possible uses of 
such a feature.




It may be useful to limit the size of the page cache for various reasons
such as

1. Insure that anonymous pages that may contain performance
   critical data is never subject to swap.

2. Insure rapid turnaround of pages in the cache.

3. Reserve memory for other uses? (Aubrey?)

We add a new variable "pagecache_ratio" to /proc/sys/vm/ that
defaults to 100 (all memory usable for the pagecache).

The size of the pagecache is the number of file backed
pages in a zone which is available through NR_FILE_PAGES.

We skip zones that contain too many page cache pages in
the page allocator which may cause us to enter reclaim.

If we enter reclaim and the number of page cache pages
is too high then we switch off swapping during reclaim
to avoid touching anonymous pages.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.20-rc5/include/linux/gfp.h
===================================================================
--- linux-2.6.20-rc5.orig/include/linux/gfp.h	2007-01-12 12:54:26.000000000 -0600
+++ linux-2.6.20-rc5/include/linux/gfp.h	2007-01-23 17:54:51.750696888 -0600
@@ -46,6 +46,7 @@ struct vm_area_struct;
 #define __GFP_NOMEMALLOC ((__force gfp_t)0x10000u) /* Don't use emergency reserves */
 #define __GFP_HARDWALL   ((__force gfp_t)0x20000u) /* Enforce hardwall cpuset memory allocs */
 #define __GFP_THISNODE	((__force gfp_t)0x40000u)/* No fallback, no policies */
+#define __GFP_PAGECACHE	((__force gfp_t)0x80000u) /* Page cache allocation */
 
 #define __GFP_BITS_SHIFT 20	/* Room for 20 __GFP_FOO bits */
 #define __GFP_BITS_MASK ((__force gfp_t)((1 << __GFP_BITS_SHIFT) - 1))
Index: linux-2.6.20-rc5/include/linux/pagemap.h
===================================================================
--- linux-2.6.20-rc5.orig/include/linux/pagemap.h	2007-01-12 12:54:26.000000000 -0600
+++ linux-2.6.20-rc5/include/linux/pagemap.h	2007-01-23 18:13:14.310062155 -0600
@@ -62,12 +62,13 @@ static inline struct page *__page_cache_
 
 static inline struct page *page_cache_alloc(struct address_space *x)
 {
-	return __page_cache_alloc(mapping_gfp_mask(x));
+	return __page_cache_alloc(mapping_gfp_mask(x)| __GFP_PAGECACHE);
 }
 
 static inline struct page *page_cache_alloc_cold(struct address_space *x)
 {
-	return __page_cache_alloc(mapping_gfp_mask(x)|__GFP_COLD);
+	return __page_cache_alloc(mapping_gfp_mask(x) |
+			 __GFP_COLD | __GFP_PAGECACHE);
 }
 
 typedef int filler_t(void *, struct page *);
Index: linux-2.6.20-rc5/include/linux/sysctl.h
===================================================================
--- linux-2.6.20-rc5.orig/include/linux/sysctl.h	2007-01-12 12:54:26.000000000 -0600
+++ linux-2.6.20-rc5/include/linux/sysctl.h	2007-01-23 18:17:09.285324555 -0600
@@ -202,6 +202,7 @@ enum
 	VM_PANIC_ON_OOM=33,	/* panic at out-of-memory */
 	VM_VDSO_ENABLED=34,	/* map VDSO into new processes? */
 	VM_MIN_SLAB=35,		 /* Percent pages ignored by zone reclaim */
+	VM_PAGECACHE_RATIO=36,	/* percent of RAM to use as page cache */
 };
 
 
@@ -956,7 +957,6 @@ extern ctl_handler sysctl_intvec;
 extern ctl_handler sysctl_jiffies;
 extern ctl_handler sysctl_ms_jiffies;
 
-
 /*
  * Register a set of sysctl names by calling register_sysctl_table
  * with an initialised array of ctl_table's.  An entry with zero
Index: linux-2.6.20-rc5/kernel/sysctl.c
===================================================================
--- linux-2.6.20-rc5.orig/kernel/sysctl.c	2007-01-12 12:54:26.000000000 -0600
+++ linux-2.6.20-rc5/kernel/sysctl.c	2007-01-23 18:24:04.763443772 -0600
@@ -1023,6 +1023,17 @@ static ctl_table vm_table[] = {
 		.extra2		= &one_hundred,
 	},
 #endif
+	{
+		.ctl_name	= VM_PAGECACHE_RATIO,
+		.procname	= "pagecache_ratio",
+		.data		= &sysctl_pagecache_ratio,
+		.maxlen		= sizeof(sysctl_pagecache_ratio),
+		.mode		= 0644,
+		.proc_handler	= &sysctl_pagecache_ratio_sysctl_handler,
+		.strategy	= &sysctl_intvec,
+		.extra1		= &zero,
+		.extra2		= &one_hundred,
+	},
 #ifdef CONFIG_X86_32
 	{
 		.ctl_name	= VM_VDSO_ENABLED,
Index: linux-2.6.20-rc5/mm/page_alloc.c
===================================================================
--- linux-2.6.20-rc5.orig/mm/page_alloc.c	2007-01-16 23:26:28.000000000 -0600
+++ linux-2.6.20-rc5/mm/page_alloc.c	2007-01-23 18:11:40.484617205 -0600
@@ -59,6 +59,8 @@ unsigned long totalreserve_pages __read_
 long nr_swap_pages;
 int percpu_pagelist_fraction;
 
+int sysctl_pagecache_ratio = 100;
+
 static void __free_pages_ok(struct page *page, unsigned int order);
 
 /*
@@ -1168,6 +1170,11 @@ zonelist_scan:
 			!cpuset_zone_allowed_softwall(zone, gfp_mask))
 				goto try_next_zone;
 
+		if ((gfp_mask & __GFP_PAGECACHE) &&
+				zone_page_state(zone, NR_FILE_PAGES) >
+					zone->max_pagecache_pages)
+				goto try_next_zone;
+
 		if (!(alloc_flags & ALLOC_NO_WATERMARKS)) {
 			unsigned long mark;
 			if (alloc_flags & ALLOC_WMARK_MIN)
@@ -2670,6 +2677,8 @@ static void __meminit free_area_init_cor
 						/ 100;
 		zone->min_slab_pages = (realsize * sysctl_min_slab_ratio) / 100;
 #endif
+		zone->max_pagecache_pages =
+			(realsize * sysctl_pagecache_ratio) / 100;
 		zone->name = zone_names[j];
 		spin_lock_init(&zone->lock);
 		spin_lock_init(&zone->lru_lock);
@@ -3245,6 +3254,22 @@ int sysctl_min_slab_ratio_sysctl_handler
 }
 #endif
 
+int sysctl_pagecache_ratio_sysctl_handler(ctl_table *table, int write,
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
+		zone->max_pagecache_pages = (zone->present_pages *
+				sysctl_pagecache_ratio) / 100;
+	return 0;
+}
+
 /*
  * lowmem_reserve_ratio_sysctl_handler - just a wrapper around
  *	proc_dointvec() so that we can call setup_per_zone_lowmem_reserve()
Index: linux-2.6.20-rc5/mm/vmscan.c
===================================================================
--- linux-2.6.20-rc5.orig/mm/vmscan.c	2007-01-23 17:35:53.000000000 -0600
+++ linux-2.6.20-rc5/mm/vmscan.c	2007-01-23 18:20:19.118051138 -0600
@@ -932,6 +932,14 @@ static unsigned long shrink_zone(int pri
 	else
 		nr_inactive = 0;
 
+	/*
+	 * If the page cache is too big then focus on page cache
+	 * and ignore anonymous pages
+	 */
+	if (sc->may_swap && zone_page_state(zone, NR_FILE_PAGES)
+			> zone->max_pagecache_pages)
+		sc->may_swap = 0;
+
 	while (nr_active || nr_inactive) {
 		if (nr_active) {
 			nr_to_scan = min(nr_active,
Index: linux-2.6.20-rc5/include/linux/mmzone.h
===================================================================
--- linux-2.6.20-rc5.orig/include/linux/mmzone.h	2007-01-17 22:06:02.000000000 -0600
+++ linux-2.6.20-rc5/include/linux/mmzone.h	2007-01-23 18:22:11.473419856 -0600
@@ -167,6 +167,8 @@ struct zone {
 	 */
 	unsigned long		lowmem_reserve[MAX_NR_ZONES];
 
+	unsigned long 		max_pagecache_pages;
+
 #ifdef CONFIG_NUMA
 	int node;
 	/*
@@ -540,6 +542,8 @@ int sysctl_min_unmapped_ratio_sysctl_han
 			struct file *, void __user *, size_t *, loff_t *);
 int sysctl_min_slab_ratio_sysctl_handler(struct ctl_table *, int,
 			struct file *, void __user *, size_t *, loff_t *);
+int sysctl_pagecache_ratio_sysctl_handler(struct ctl_table *, int,
+			struct file *, void __user *, size_t *, loff_t *);
 
 #include <linux/topology.h>
 /* Returns the number of the current Node. */
Index: linux-2.6.20-rc5/include/linux/swap.h
===================================================================
--- linux-2.6.20-rc5.orig/include/linux/swap.h	2007-01-12 12:54:26.000000000 -0600
+++ linux-2.6.20-rc5/include/linux/swap.h	2007-01-23 18:18:43.943851519 -0600
@@ -192,6 +192,8 @@ extern int vm_swappiness;
 extern int remove_mapping(struct address_space *mapping, struct page *page);
 extern long vm_total_pages;
 
+extern int sysctl_pagecache_ratio;
+
 #ifdef CONFIG_NUMA
 extern int zone_reclaim_mode;
 extern int sysctl_min_unmapped_ratio;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
