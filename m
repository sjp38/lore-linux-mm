Date: Thu, 22 Jun 2006 09:40:20 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Message-Id: <20060622164020.28809.86723.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20060622164004.28809.8446.sendpatchset@schroedinger.engr.sgi.com>
References: <20060622164004.28809.8446.sendpatchset@schroedinger.engr.sgi.com>
Subject: [PATCH 03/14] Convert nr_mapped to per zone counter
Sender: owner-linux-mm@kvack.org
Subject: zoned vm counters: conversion of nr_mapped to per zone counter
From: Christoph Lameter <clameter@sgi.com>
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm@kvack.org, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

nr_mapped is important because it allows a determination of how many pages of
a zone are not mapped, which would allow a more efficient means of determining
when we need to reclaim memory in a zone.

We take the nr_mapped field out of the page state structure and define a new
per zone counter named NR_FILE_MAPPED (the anonymous pages will be split
off from NR_MAPPED in the next patch).

We replace the use of nr_mapped in various kernel locations.  This avoids the
looping over all processors in try_to_free_pages(), writeback, reclaim (swap +
zone reclaim).

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.17-mm1/arch/i386/mm/pgtable.c
===================================================================
--- linux-2.6.17-mm1.orig/arch/i386/mm/pgtable.c	2006-06-17 18:49:35.000000000 -0700
+++ linux-2.6.17-mm1/arch/i386/mm/pgtable.c	2006-06-21 08:06:14.414759983 -0700
@@ -61,7 +61,7 @@ void show_mem(void)
 	get_page_state(&ps);
 	printk(KERN_INFO "%lu pages dirty\n", ps.nr_dirty);
 	printk(KERN_INFO "%lu pages writeback\n", ps.nr_writeback);
-	printk(KERN_INFO "%lu pages mapped\n", ps.nr_mapped);
+	printk(KERN_INFO "%lu pages mapped\n", global_page_state(NR_FILE_MAPPED));
 	printk(KERN_INFO "%lu pages slab\n", ps.nr_slab);
 	printk(KERN_INFO "%lu pages pagetables\n", ps.nr_page_table_pages);
 }
Index: linux-2.6.17-mm1/drivers/base/node.c
===================================================================
--- linux-2.6.17-mm1.orig/drivers/base/node.c	2006-06-17 18:49:35.000000000 -0700
+++ linux-2.6.17-mm1/drivers/base/node.c	2006-06-21 08:06:14.415736485 -0700
@@ -53,8 +53,6 @@ static ssize_t node_read_meminfo(struct 
 		ps.nr_dirty = 0;
 	if ((long)ps.nr_writeback < 0)
 		ps.nr_writeback = 0;
-	if ((long)ps.nr_mapped < 0)
-		ps.nr_mapped = 0;
 	if ((long)ps.nr_slab < 0)
 		ps.nr_slab = 0;
 
@@ -83,7 +81,7 @@ static ssize_t node_read_meminfo(struct 
 		       nid, K(i.freeram - i.freehigh),
 		       nid, K(ps.nr_dirty),
 		       nid, K(ps.nr_writeback),
-		       nid, K(ps.nr_mapped),
+		       nid, K(node_page_state(nid, NR_FILE_MAPPED)),
 		       nid, K(ps.nr_slab));
 	n += hugetlb_report_node_meminfo(nid, buf + n);
 	return n;
Index: linux-2.6.17-mm1/fs/proc/proc_misc.c
===================================================================
--- linux-2.6.17-mm1.orig/fs/proc/proc_misc.c	2006-06-17 18:49:35.000000000 -0700
+++ linux-2.6.17-mm1/fs/proc/proc_misc.c	2006-06-21 08:06:14.416712987 -0700
@@ -190,7 +190,7 @@ static int meminfo_read_proc(char *page,
 		K(i.freeswap),
 		K(ps.nr_dirty),
 		K(ps.nr_writeback),
-		K(ps.nr_mapped),
+		K(global_page_state(NR_FILE_MAPPED)),
 		K(ps.nr_slab),
 		K(allowed),
 		K(committed),
Index: linux-2.6.17-mm1/include/linux/mmzone.h
===================================================================
--- linux-2.6.17-mm1.orig/include/linux/mmzone.h	2006-06-21 08:04:57.507406207 -0700
+++ linux-2.6.17-mm1/include/linux/mmzone.h	2006-06-21 08:06:14.418665992 -0700
@@ -48,6 +48,9 @@ struct zone_padding {
 #endif
 
 enum zone_stat_item {
+	NR_FILE_MAPPED,	/* mapped into pagetables.
+			   only modified from process context */
+
 	NR_VM_ZONE_STAT_ITEMS };
 
 struct per_cpu_pages {
Index: linux-2.6.17-mm1/mm/page_alloc.c
===================================================================
--- linux-2.6.17-mm1.orig/mm/page_alloc.c	2006-06-21 08:04:57.509359211 -0700
+++ linux-2.6.17-mm1/mm/page_alloc.c	2006-06-21 08:06:14.419642494 -0700
@@ -1314,7 +1314,7 @@ void show_free_areas(void)
 		ps.nr_unstable,
 		nr_free_pages(),
 		ps.nr_slab,
-		ps.nr_mapped,
+		global_page_state(NR_FILE_MAPPED),
 		ps.nr_page_table_pages);
 
 	for_each_zone(zone) {
Index: linux-2.6.17-mm1/mm/page-writeback.c
===================================================================
--- linux-2.6.17-mm1.orig/mm/page-writeback.c	2006-06-17 18:49:35.000000000 -0700
+++ linux-2.6.17-mm1/mm/page-writeback.c	2006-06-21 08:06:14.420618996 -0700
@@ -111,7 +111,7 @@ static void get_writeback_state(struct w
 {
 	wbs->nr_dirty = read_page_state(nr_dirty);
 	wbs->nr_unstable = read_page_state(nr_unstable);
-	wbs->nr_mapped = read_page_state(nr_mapped);
+	wbs->nr_mapped = global_page_state(NR_FILE_MAPPED);
 	wbs->nr_writeback = read_page_state(nr_writeback);
 }
 
Index: linux-2.6.17-mm1/mm/rmap.c
===================================================================
--- linux-2.6.17-mm1.orig/mm/rmap.c	2006-06-17 18:49:35.000000000 -0700
+++ linux-2.6.17-mm1/mm/rmap.c	2006-06-21 08:06:14.421595498 -0700
@@ -493,7 +493,7 @@ static void __page_set_anon_rmap(struct 
 	 * nr_mapped state can be updated without turning off
 	 * interrupts because it is not modified via interrupt.
 	 */
-	__inc_page_state(nr_mapped);
+	__inc_zone_page_state(page, NR_FILE_MAPPED);
 }
 
 /**
@@ -537,7 +537,7 @@ void page_add_new_anon_rmap(struct page 
 void page_add_file_rmap(struct page *page)
 {
 	if (atomic_inc_and_test(&page->_mapcount))
-		__inc_page_state(nr_mapped);
+		__inc_zone_page_state(page, NR_FILE_MAPPED);
 }
 
 /**
@@ -569,7 +569,7 @@ void page_remove_rmap(struct page *page)
 		 */
 		if (page_test_and_clear_dirty(page))
 			set_page_dirty(page);
-		__dec_page_state(nr_mapped);
+		__dec_zone_page_state(page, NR_FILE_MAPPED);
 	}
 }
 
Index: linux-2.6.17-mm1/mm/vmscan.c
===================================================================
--- linux-2.6.17-mm1.orig/mm/vmscan.c	2006-06-17 18:49:35.000000000 -0700
+++ linux-2.6.17-mm1/mm/vmscan.c	2006-06-21 08:06:14.422572000 -0700
@@ -972,7 +972,7 @@ unsigned long try_to_free_pages(struct z
 	}
 
 	for (priority = DEF_PRIORITY; priority >= 0; priority--) {
-		sc.nr_mapped = read_page_state(nr_mapped);
+		sc.nr_mapped = global_page_state(NR_FILE_MAPPED);
 		sc.nr_scanned = 0;
 		if (!priority)
 			disable_swap_token();
@@ -1062,7 +1062,7 @@ loop_again:
 	total_scanned = 0;
 	nr_reclaimed = 0;
 	sc.may_writepage = !laptop_mode;
-	sc.nr_mapped = read_page_state(nr_mapped);
+	sc.nr_mapped = global_page_state(NR_FILE_MAPPED);
 
 	inc_page_state(pageoutrun);
 
@@ -1412,7 +1412,7 @@ static int __zone_reclaim(struct zone *z
 	struct scan_control sc = {
 		.may_writepage = !!(zone_reclaim_mode & RECLAIM_WRITE),
 		.may_swap = !!(zone_reclaim_mode & RECLAIM_SWAP),
-		.nr_mapped = read_page_state(nr_mapped),
+		.nr_mapped = global_page_state(NR_FILE_MAPPED),
 		.swap_cluster_max = max_t(unsigned long, nr_pages,
 					SWAP_CLUSTER_MAX),
 		.gfp_mask = gfp_mask,
Index: linux-2.6.17-mm1/mm/vmstat.c
===================================================================
--- linux-2.6.17-mm1.orig/mm/vmstat.c	2006-06-21 08:04:57.514241722 -0700
+++ linux-2.6.17-mm1/mm/vmstat.c	2006-06-21 08:06:14.423548502 -0700
@@ -463,13 +463,13 @@ struct seq_operations fragmentation_op =
 
 static char *vmstat_text[] = {
 	/* Zoned VM counters */
+	"nr_mapped",
 
 	/* Page state */
 	"nr_dirty",
 	"nr_writeback",
 	"nr_unstable",
 	"nr_page_table_pages",
-	"nr_mapped",
 	"nr_slab",
 
 	"pgpgin",
Index: linux-2.6.17-mm1/include/linux/vmstat.h
===================================================================
--- linux-2.6.17-mm1.orig/include/linux/vmstat.h	2006-06-21 08:04:57.512288718 -0700
+++ linux-2.6.17-mm1/include/linux/vmstat.h	2006-06-22 08:10:13.219810354 -0700
@@ -25,8 +25,6 @@ struct page_state {
 	unsigned long nr_writeback;	/* Pages under writeback */
 	unsigned long nr_unstable;	/* NFS unstable pages */
 	unsigned long nr_page_table_pages;/* Pages used for pagetables */
-	unsigned long nr_mapped;	/* mapped into pagetables.
-					 * only modified from process context */
 	unsigned long nr_slab;		/* In slab */
 #define GET_PAGE_STATE_LAST nr_slab
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
