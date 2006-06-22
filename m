Date: Thu, 22 Jun 2006 09:41:01 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Message-Id: <20060622164101.28809.84628.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20060622164004.28809.8446.sendpatchset@schroedinger.engr.sgi.com>
References: <20060622164004.28809.8446.sendpatchset@schroedinger.engr.sgi.com>
Subject: [PATCH 11/14] Conversion of nr_writeback to per zone counter
Sender: owner-linux-mm@kvack.org
Subject: zoned vm counters: conversion of nr_writeback to per zone counter
From: Christoph Lameter <clameter@sgi.com>
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm@kvack.org, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

Conversion of nr_writeback to per zone counter.

This removes the last page_state counter from arch/i386/mm/pgtable.c
so we drop the page_state from there.

Signed-off-by: Christoph Lameter <clameter@sgi.com>
Signed-off-by: Andrew Morton <akpm@osdl.org>

Index: linux-2.6.17-mm1/arch/i386/mm/pgtable.c
===================================================================
--- linux-2.6.17-mm1.orig/arch/i386/mm/pgtable.c	2006-06-22 08:43:21.308619504 -0700
+++ linux-2.6.17-mm1/arch/i386/mm/pgtable.c	2006-06-22 08:49:30.151016328 -0700
@@ -30,7 +30,6 @@ void show_mem(void)
 	struct page *page;
 	pg_data_t *pgdat;
 	unsigned long i;
-	struct page_state ps;
 	unsigned long flags;
 
 	printk(KERN_INFO "Mem-info:\n");
@@ -58,9 +57,9 @@ void show_mem(void)
 	printk(KERN_INFO "%d pages shared\n", shared);
 	printk(KERN_INFO "%d pages swap cached\n", cached);
 
-	get_page_state(&ps);
 	printk(KERN_INFO "%lu pages dirty\n", global_page_state(NR_FILE_DIRTY));
-	printk(KERN_INFO "%lu pages writeback\n", ps.nr_writeback);
+	printk(KERN_INFO "%lu pages writeback\n",
+					global_page_state(NR_WRITEBACK));
 	printk(KERN_INFO "%lu pages mapped\n", global_page_state(NR_FILE_MAPPED));
 	printk(KERN_INFO "%lu pages slab\n", global_page_state(NR_SLAB));
 	printk(KERN_INFO "%lu pages pagetables\n",
Index: linux-2.6.17-mm1/drivers/base/node.c
===================================================================
--- linux-2.6.17-mm1.orig/drivers/base/node.c	2006-06-22 08:43:21.309596006 -0700
+++ linux-2.6.17-mm1/drivers/base/node.c	2006-06-22 08:49:30.151992830 -0700
@@ -48,9 +48,6 @@ static ssize_t node_read_meminfo(struct 
 	get_page_state_node(&ps, nid);
 	__get_zone_counts(&active, &inactive, &free, NODE_DATA(nid));
 
-	/* Check for negative values in these approximate counters */
-	if ((long)ps.nr_writeback < 0)
-		ps.nr_writeback = 0;
 
 	n = sprintf(buf, "\n"
 		       "Node %d MemTotal:     %8lu kB\n"
@@ -79,7 +76,7 @@ static ssize_t node_read_meminfo(struct 
 		       nid, K(i.totalram - i.totalhigh),
 		       nid, K(i.freeram - i.freehigh),
 		       nid, K(node_page_state(nid, NR_FILE_DIRTY)),
-		       nid, K(ps.nr_writeback),
+		       nid, K(node_page_state(nid, NR_WRITEBACK)),
 		       nid, K(node_page_state(nid, NR_FILE_PAGES)),
 		       nid, K(node_page_state(nid, NR_FILE_MAPPED)),
 		       nid, K(node_page_state(nid, NR_ANON_PAGES)),
Index: linux-2.6.17-mm1/fs/proc/proc_misc.c
===================================================================
--- linux-2.6.17-mm1.orig/fs/proc/proc_misc.c	2006-06-22 08:43:21.314478516 -0700
+++ linux-2.6.17-mm1/fs/proc/proc_misc.c	2006-06-22 08:49:30.152969332 -0700
@@ -191,7 +191,7 @@ static int meminfo_read_proc(char *page,
 		K(i.totalswap),
 		K(i.freeswap),
 		K(global_page_state(NR_FILE_DIRTY)),
-		K(ps.nr_writeback),
+		K(global_page_state(NR_WRITEBACK)),
 		K(global_page_state(NR_ANON_PAGES)),
 		K(global_page_state(NR_FILE_MAPPED)),
 		K(global_page_state(NR_SLAB)),
Index: linux-2.6.17-mm1/include/linux/mmzone.h
===================================================================
--- linux-2.6.17-mm1.orig/include/linux/mmzone.h	2006-06-22 08:43:21.315455018 -0700
+++ linux-2.6.17-mm1/include/linux/mmzone.h	2006-06-22 08:49:30.152969332 -0700
@@ -55,6 +55,7 @@ enum zone_stat_item {
 	NR_SLAB,	/* Pages used by slab allocator */
 	NR_PAGETABLE,	/* used for pagetables */
 	NR_FILE_DIRTY,
+	NR_WRITEBACK,
 	NR_VM_ZONE_STAT_ITEMS };
 
 struct per_cpu_pages {
Index: linux-2.6.17-mm1/include/linux/page-flags.h
===================================================================
--- linux-2.6.17-mm1.orig/include/linux/page-flags.h	2006-06-21 07:45:02.657540879 -0700
+++ linux-2.6.17-mm1/include/linux/page-flags.h	2006-06-22 08:49:30.153945834 -0700
@@ -164,7 +164,7 @@
 	do {								\
 		if (!test_and_set_bit(PG_writeback,			\
 				&(page)->flags))			\
-			inc_page_state(nr_writeback);			\
+			inc_zone_page_state(page, NR_WRITEBACK);	\
 	} while (0)
 #define TestSetPageWriteback(page)					\
 	({								\
@@ -172,14 +172,14 @@
 		ret = test_and_set_bit(PG_writeback,			\
 					&(page)->flags);		\
 		if (!ret)						\
-			inc_page_state(nr_writeback);			\
+			inc_zone_page_state(page, NR_WRITEBACK);	\
 		ret;							\
 	})
 #define ClearPageWriteback(page)					\
 	do {								\
 		if (test_and_clear_bit(PG_writeback,			\
 				&(page)->flags))			\
-			dec_page_state(nr_writeback);			\
+			dec_zone_page_state(page, NR_WRITEBACK);	\
 	} while (0)
 #define TestClearPageWriteback(page)					\
 	({								\
@@ -187,7 +187,7 @@
 		ret = test_and_clear_bit(PG_writeback,			\
 				&(page)->flags);			\
 		if (ret)						\
-			dec_page_state(nr_writeback);			\
+			dec_zone_page_state(page, NR_WRITEBACK);	\
 		ret;							\
 	})
 
Index: linux-2.6.17-mm1/mm/page_alloc.c
===================================================================
--- linux-2.6.17-mm1.orig/mm/page_alloc.c	2006-06-22 08:43:21.317408022 -0700
+++ linux-2.6.17-mm1/mm/page_alloc.c	2006-06-22 08:49:30.155898838 -0700
@@ -1310,7 +1310,7 @@ void show_free_areas(void)
 		active,
 		inactive,
 		global_page_state(NR_FILE_DIRTY),
-		ps.nr_writeback,
+		global_page_state(NR_WRITEBACK),
 		ps.nr_unstable,
 		nr_free_pages(),
 		global_page_state(NR_SLAB),
Index: linux-2.6.17-mm1/mm/page-writeback.c
===================================================================
--- linux-2.6.17-mm1.orig/mm/page-writeback.c	2006-06-22 08:43:21.318384524 -0700
+++ linux-2.6.17-mm1/mm/page-writeback.c	2006-06-22 08:49:30.155898838 -0700
@@ -113,7 +113,7 @@ static void get_writeback_state(struct w
 	wbs->nr_unstable = read_page_state(nr_unstable);
 	wbs->nr_mapped = global_page_state(NR_FILE_MAPPED) +
 				global_page_state(NR_ANON_PAGES);
-	wbs->nr_writeback = read_page_state(nr_writeback);
+	wbs->nr_writeback = global_page_state(NR_WRITEBACK);
 }
 
 /*
Index: linux-2.6.17-mm1/mm/vmstat.c
===================================================================
--- linux-2.6.17-mm1.orig/mm/vmstat.c	2006-06-22 08:43:21.318384524 -0700
+++ linux-2.6.17-mm1/mm/vmstat.c	2006-06-22 08:49:30.156875341 -0700
@@ -463,9 +463,9 @@ static char *vmstat_text[] = {
 	"nr_slab",
 	"nr_page_table_pages",
 	"nr_dirty",
+	"nr_writeback",
 
 	/* Page state */
-	"nr_writeback",
 	"nr_unstable",
 
 	"pgpgin",
Index: linux-2.6.17-mm1/include/linux/vmstat.h
===================================================================
--- linux-2.6.17-mm1.orig/include/linux/vmstat.h	2006-06-22 08:43:32.863567390 -0700
+++ linux-2.6.17-mm1/include/linux/vmstat.h	2006-06-22 08:49:41.977433405 -0700
@@ -21,7 +21,6 @@
  * commented here.
  */
 struct page_state {
-	unsigned long nr_writeback;	/* Pages under writeback */
 	unsigned long nr_unstable;	/* NFS unstable pages */
 #define GET_PAGE_STATE_LAST nr_unstable
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
