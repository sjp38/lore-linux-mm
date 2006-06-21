Received: from imr2.americas.sgi.com (imr2.americas.sgi.com [198.149.16.18])
	by omx1.americas.sgi.com (8.12.10/8.12.9/linux-outbound_gateway-1.1) with ESMTP id k5LFksnx030049
	for <linux-mm@kvack.org>; Wed, 21 Jun 2006 10:46:54 -0500
Received: from spindle.corp.sgi.com (spindle.corp.sgi.com [198.29.75.13])
	by imr2.americas.sgi.com (8.12.9/8.12.10/SGI_generic_relay-1.2) with ESMTP id k5LG3A7p35971863
	for <linux-mm@kvack.org>; Wed, 21 Jun 2006 09:03:10 -0700 (PDT)
Received: from schroedinger.engr.sgi.com (schroedinger.engr.sgi.com [163.154.5.55])
	by spindle.corp.sgi.com (SGI-8.12.5/8.12.9/generic_config-1.2) with ESMTP id k5LFkrnB42412632
	for <linux-mm@kvack.org>; Wed, 21 Jun 2006 08:46:53 -0700 (PDT)
Received: from christoph (helo=localhost)
	by schroedinger.engr.sgi.com with local-esmtp (Exim 3.36 #1 (Debian))
	id 1Ft4ur-0004xK-00
	for <linux-mm@kvack.org>; Wed, 21 Jun 2006 08:46:53 -0700
Date: Wed, 21 Jun 2006 08:45:16 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Message-Id: <20060621154516.18741.50905.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20060621154419.18741.76233.sendpatchset@schroedinger.engr.sgi.com>
References: <20060621154419.18741.76233.sendpatchset@schroedinger.engr.sgi.com>
Subject: [PATCH 11/14] Conversion of nr_writeback to per zone counter
ReSent-To: linux-mm@kvack.org
ReSent-Message-ID: <Pine.LNX.4.64.0606210846535.18960@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Subject: zoned vm counters: conversion of nr_writeback to per zone counter
From: Christoph Lameter <clameter@sgi.com>
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: Martin Bligh <mbligh@google.com>, linux-mm@vger.kernel.org, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

Conversion of nr_writeback to per zone counter.

This removes the last page_state counter from arch/i386/mm/pgtable.c
so we drop the page_state from there.

Signed-off-by: Christoph Lameter <clameter@sgi.com>
Signed-off-by: Andrew Morton <akpm@osdl.org>

Index: linux-2.6.17-mm1/arch/i386/mm/pgtable.c
===================================================================
--- linux-2.6.17-mm1.orig/arch/i386/mm/pgtable.c	2006-06-21 08:18:32.596647499 -0700
+++ linux-2.6.17-mm1/arch/i386/mm/pgtable.c	2006-06-21 08:19:11.006383777 -0700
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
--- linux-2.6.17-mm1.orig/drivers/base/node.c	2006-06-21 08:18:32.597624001 -0700
+++ linux-2.6.17-mm1/drivers/base/node.c	2006-06-21 08:19:11.007360279 -0700
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
--- linux-2.6.17-mm1.orig/fs/proc/proc_misc.c	2006-06-21 08:18:32.602506512 -0700
+++ linux-2.6.17-mm1/fs/proc/proc_misc.c	2006-06-21 08:19:11.008336781 -0700
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
--- linux-2.6.17-mm1.orig/include/linux/mmzone.h	2006-06-21 08:18:32.603483014 -0700
+++ linux-2.6.17-mm1/include/linux/mmzone.h	2006-06-21 08:19:11.009313283 -0700
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
+++ linux-2.6.17-mm1/include/linux/page-flags.h	2006-06-21 08:19:11.010289785 -0700
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
--- linux-2.6.17-mm1.orig/mm/page_alloc.c	2006-06-21 08:18:32.605436019 -0700
+++ linux-2.6.17-mm1/mm/page_alloc.c	2006-06-21 08:19:11.011266287 -0700
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
--- linux-2.6.17-mm1.orig/mm/page-writeback.c	2006-06-21 08:18:32.606412521 -0700
+++ linux-2.6.17-mm1/mm/page-writeback.c	2006-06-21 08:19:11.012242790 -0700
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
--- linux-2.6.17-mm1.orig/mm/vmstat.c	2006-06-21 08:18:32.607389023 -0700
+++ linux-2.6.17-mm1/mm/vmstat.c	2006-06-21 08:19:11.013219292 -0700
@@ -463,9 +463,9 @@ static char *vmstat_text[] = {
 	"nr_slab",
 	"nr_page_table_pages",
 	"nr_dirty",
+	"nr_writeback",
 
 	/* Page state */
-	"nr_writeback",
 	"nr_unstable",
 
 	"pgpgin",

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
