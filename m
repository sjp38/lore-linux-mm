Received: from imr2.americas.sgi.com (imr2.americas.sgi.com [198.149.16.18])
	by omx1.americas.sgi.com (8.12.10/8.12.9/linux-outbound_gateway-1.1) with ESMTP id k5LFksnx030043
	for <linux-mm@kvack.org>; Wed, 21 Jun 2006 10:46:54 -0500
Received: from spindle.corp.sgi.com (spindle.corp.sgi.com [198.29.75.13])
	by imr2.americas.sgi.com (8.12.9/8.12.10/SGI_generic_relay-1.2) with ESMTP id k5LG3A7p35973994
	for <linux-mm@kvack.org>; Wed, 21 Jun 2006 09:03:10 -0700 (PDT)
Received: from schroedinger.engr.sgi.com (schroedinger.engr.sgi.com [163.154.5.55])
	by spindle.corp.sgi.com (SGI-8.12.5/8.12.9/generic_config-1.2) with ESMTP id k5LFkrnB42456852
	for <linux-mm@kvack.org>; Wed, 21 Jun 2006 08:46:53 -0700 (PDT)
Received: from christoph (helo=localhost)
	by schroedinger.engr.sgi.com with local-esmtp (Exim 3.36 #1 (Debian))
	id 1Ft4ur-0004wu-00
	for <linux-mm@kvack.org>; Wed, 21 Jun 2006 08:46:53 -0700
Date: Wed, 21 Jun 2006 08:45:01 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Message-Id: <20060621154501.18741.50035.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20060621154419.18741.76233.sendpatchset@schroedinger.engr.sgi.com>
References: <20060621154419.18741.76233.sendpatchset@schroedinger.engr.sgi.com>
Subject: [PATCH 08/14] Conversion of nr_slab to per zone counter
ReSent-To: linux-mm@kvack.org
ReSent-Message-ID: <Pine.LNX.4.64.0606210846532.18960@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Subject: zoned vm counters: conversion of nr_slab to per zone counter
From: Christoph Lameter <clameter@sgi.com>
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: Martin Bligh <mbligh@google.com>, linux-mm@vger.kernel.org, Christoph Lameter <clameter@sgi.com>
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
+++ linux-2.6.17-mm1/arch/i386/mm/pgtable.c	2006-06-21 08:15:33.093100572 -0700
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
--- linux-2.6.17-mm1.orig/drivers/base/node.c	2006-06-21 08:13:22.414659202 -0700
+++ linux-2.6.17-mm1/drivers/base/node.c	2006-06-21 08:15:33.094077074 -0700
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
--- linux-2.6.17-mm1.orig/fs/proc/proc_misc.c	2006-06-21 08:13:22.344351050 -0700
+++ linux-2.6.17-mm1/fs/proc/proc_misc.c	2006-06-21 08:15:33.095053576 -0700
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
--- linux-2.6.17-mm1.orig/include/linux/mmzone.h	2006-06-21 08:13:24.346180371 -0700
+++ linux-2.6.17-mm1/include/linux/mmzone.h	2006-06-21 08:15:33.097006580 -0700
@@ -52,6 +52,7 @@ enum zone_stat_item {
 	NR_FILE_MAPPED,	/* pagecache pages mapped into pagetables.
 			   only modified from process context */
 	NR_FILE_PAGES,
+	NR_SLAB,	/* Pages used by slab allocator */
 	NR_VM_ZONE_STAT_ITEMS };
 
 struct per_cpu_pages {
Index: linux-2.6.17-mm1/mm/page_alloc.c
===================================================================
--- linux-2.6.17-mm1.orig/mm/page_alloc.c	2006-06-21 08:12:30.665906484 -0700
+++ linux-2.6.17-mm1/mm/page_alloc.c	2006-06-21 08:15:33.097983082 -0700
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
+++ linux-2.6.17-mm1/mm/slab.c	2006-06-21 08:15:33.100912589 -0700
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
--- linux-2.6.17-mm1.orig/mm/vmstat.c	2006-06-21 08:13:22.431259738 -0700
+++ linux-2.6.17-mm1/mm/vmstat.c	2006-06-21 08:15:33.100912589 -0700
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

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
