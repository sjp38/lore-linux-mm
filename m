Date: Thu, 22 Jun 2006 09:40:46 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Message-Id: <20060622164046.28809.63132.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20060622164004.28809.8446.sendpatchset@schroedinger.engr.sgi.com>
References: <20060622164004.28809.8446.sendpatchset@schroedinger.engr.sgi.com>
Subject: [PATCH 08/14] Conversion of nr_slab to per zone counter
Sender: owner-linux-mm@kvack.org
Subject: zoned vm counters: conversion of nr_slab to per zone counter
From: Christoph Lameter <clameter@sgi.com>
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm@kvack.org, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

- Allows reclaim to access counter without looping over processor counts.

- Allows accurate statistics on how many pages are used in a zone by
  the slab. This may become useful to balance slab allocations over
  various zones.

Signed-off-by: Christoph Lameter <clameter@sgi.com>
Signed-off-by: Andrew Morton <akpm@osdl.org>

Index: linux-2.6.17-mm1/arch/i386/mm/pgtable.c
===================================================================
--- linux-2.6.17-mm1.orig/arch/i386/mm/pgtable.c	2006-06-21 08:06:14.414759983 -0700
+++ linux-2.6.17-mm1/arch/i386/mm/pgtable.c	2006-06-22 08:23:00.263168234 -0700
@@ -62,7 +62,7 @@ void show_mem(void)
 	printk(KERN_INFO "%lu pages dirty\n", ps.nr_dirty);
 	printk(KERN_INFO "%lu pages writeback\n", ps.nr_writeback);
 	printk(KERN_INFO "%lu pages mapped\n", global_page_state(NR_FILE_MAPPED));
-	printk(KERN_INFO "%lu pages slab\n", ps.nr_slab);
+	printk(KERN_INFO "%lu pages slab\n", global_page_state(NR_SLAB));
 	printk(KERN_INFO "%lu pages pagetables\n", ps.nr_page_table_pages);
 }
 
Index: linux-2.6.17-mm1/drivers/base/node.c
===================================================================
--- linux-2.6.17-mm1.orig/drivers/base/node.c	2006-06-22 08:22:54.960761923 -0700
+++ linux-2.6.17-mm1/drivers/base/node.c	2006-06-22 08:23:00.264144736 -0700
@@ -53,8 +53,6 @@ static ssize_t node_read_meminfo(struct 
 		ps.nr_dirty = 0;
 	if ((long)ps.nr_writeback < 0)
 		ps.nr_writeback = 0;
-	if ((long)ps.nr_slab < 0)
-		ps.nr_slab = 0;
 
 	n = sprintf(buf, "\n"
 		       "Node %d MemTotal:     %8lu kB\n"
@@ -86,7 +84,7 @@ static ssize_t node_read_meminfo(struct 
 		       nid, K(node_page_state(nid, NR_FILE_PAGES)),
 		       nid, K(node_page_state(nid, NR_FILE_MAPPED)),
 		       nid, K(node_page_state(nid, NR_ANON_PAGES)),
-		       nid, K(ps.nr_slab));
+		       nid, K(node_page_state(nid, NR_SLAB)));
 	n += hugetlb_report_node_meminfo(nid, buf + n);
 	return n;
 }
Index: linux-2.6.17-mm1/fs/proc/proc_misc.c
===================================================================
--- linux-2.6.17-mm1.orig/fs/proc/proc_misc.c	2006-06-22 08:22:54.955879413 -0700
+++ linux-2.6.17-mm1/fs/proc/proc_misc.c	2006-06-22 08:23:00.265121238 -0700
@@ -194,7 +194,7 @@ static int meminfo_read_proc(char *page,
 		K(ps.nr_writeback),
 		K(global_page_state(NR_ANON_PAGES)),
 		K(global_page_state(NR_FILE_MAPPED)),
-		K(ps.nr_slab),
+		K(global_page_state(NR_SLAB)),
 		K(allowed),
 		K(committed),
 		K(ps.nr_page_table_pages),
Index: linux-2.6.17-mm1/include/linux/mmzone.h
===================================================================
--- linux-2.6.17-mm1.orig/include/linux/mmzone.h	2006-06-22 08:22:58.091427601 -0700
+++ linux-2.6.17-mm1/include/linux/mmzone.h	2006-06-22 08:23:00.266097740 -0700
@@ -52,6 +52,7 @@ enum zone_stat_item {
 	NR_FILE_MAPPED,	/* pagecache pages mapped into pagetables.
 			   only modified from process context */
 	NR_FILE_PAGES,
+	NR_SLAB,	/* Pages used by slab allocator */
 	NR_VM_ZONE_STAT_ITEMS };
 
 struct per_cpu_pages {
Index: linux-2.6.17-mm1/mm/page_alloc.c
===================================================================
--- linux-2.6.17-mm1.orig/mm/page_alloc.c	2006-06-22 08:19:49.773977174 -0700
+++ linux-2.6.17-mm1/mm/page_alloc.c	2006-06-22 08:23:00.267074242 -0700
@@ -1313,7 +1313,7 @@ void show_free_areas(void)
 		ps.nr_writeback,
 		ps.nr_unstable,
 		nr_free_pages(),
-		ps.nr_slab,
+		global_page_state(NR_SLAB),
 		global_page_state(NR_FILE_MAPPED),
 		ps.nr_page_table_pages);
 
Index: linux-2.6.17-mm1/mm/slab.c
===================================================================
--- linux-2.6.17-mm1.orig/mm/slab.c	2006-06-21 08:04:57.511312216 -0700
+++ linux-2.6.17-mm1/mm/slab.c	2006-06-22 08:23:00.270003748 -0700
@@ -1469,7 +1469,7 @@ static void *kmem_getpages(struct kmem_c
 	i = (1 << cachep->gfporder);
 	if (cachep->flags & SLAB_RECLAIM_ACCOUNT)
 		atomic_add(i, &slab_reclaim_pages);
-	add_page_state(nr_slab, i);
+	add_zone_page_state(page_zone(page), NR_SLAB, i);
 	while (i--) {
 		__SetPageSlab(page);
 		page++;
@@ -1491,7 +1491,7 @@ static void kmem_freepages(struct kmem_c
 		__ClearPageSlab(page);
 		page++;
 	}
-	sub_page_state(nr_slab, nr_freed);
+	sub_zone_page_state(page_zone(page), NR_SLAB, nr_freed);
 	if (current->reclaim_state)
 		current->reclaim_state->reclaimed_slab += nr_freed;
 	free_pages((unsigned long)addr, cachep->gfporder);
Index: linux-2.6.17-mm1/mm/vmstat.c
===================================================================
--- linux-2.6.17-mm1.orig/mm/vmstat.c	2006-06-22 08:22:54.961738425 -0700
+++ linux-2.6.17-mm1/mm/vmstat.c	2006-06-22 08:23:00.270003748 -0700
@@ -460,13 +460,13 @@ static char *vmstat_text[] = {
 	"nr_anon_pages",
 	"nr_mapped",
 	"nr_file_pages",
+	"nr_slab",
 
 	/* Page state */
 	"nr_dirty",
 	"nr_writeback",
 	"nr_unstable",
 	"nr_page_table_pages",
-	"nr_slab",
 
 	"pgpgin",
 	"pgpgout",
Index: linux-2.6.17-mm1/include/linux/vmstat.h
===================================================================
--- linux-2.6.17-mm1.orig/include/linux/vmstat.h	2006-06-22 08:10:13.219810354 -0700
+++ linux-2.6.17-mm1/include/linux/vmstat.h	2006-06-22 08:23:17.482805961 -0700
@@ -25,8 +25,7 @@ struct page_state {
 	unsigned long nr_writeback;	/* Pages under writeback */
 	unsigned long nr_unstable;	/* NFS unstable pages */
 	unsigned long nr_page_table_pages;/* Pages used for pagetables */
-	unsigned long nr_slab;		/* In slab */
-#define GET_PAGE_STATE_LAST nr_slab
+#define GET_PAGE_STATE_LAST nr_page_table_pages
 
 	/*
 	 * The below are zeroed by get_page_state().  Use get_full_page_state()

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
