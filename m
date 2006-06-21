Received: from internal-mail-relay1.corp.sgi.com (internal-mail-relay1.corp.sgi.com [198.149.32.52])
	by omx2.sgi.com (8.12.11/8.12.9/linux-outbound_gateway-1.1) with ESMTP id k5LI9bRN027664
	for <linux-mm@kvack.org>; Wed, 21 Jun 2006 11:09:37 -0700
Received: from spindle.corp.sgi.com (spindle.corp.sgi.com [198.29.75.13])
	by internal-mail-relay1.corp.sgi.com (8.12.9/8.12.10/SGI_generic_relay-1.2) with ESMTP id k5LFkr8s14892501
	for <linux-mm@kvack.org>; Wed, 21 Jun 2006 08:46:53 -0700 (PDT)
Received: from schroedinger.engr.sgi.com (schroedinger.engr.sgi.com [163.154.5.55])
	by spindle.corp.sgi.com (SGI-8.12.5/8.12.9/generic_config-1.2) with ESMTP id k5LFkrnB42426224
	for <linux-mm@kvack.org>; Wed, 21 Jun 2006 08:46:53 -0700 (PDT)
Received: from christoph (helo=localhost)
	by schroedinger.engr.sgi.com with local-esmtp (Exim 3.36 #1 (Debian))
	id 1Ft4ur-0004xA-00
	for <linux-mm@kvack.org>; Wed, 21 Jun 2006 08:46:53 -0700
Date: Wed, 21 Jun 2006 08:45:11 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Message-Id: <20060621154511.18741.8677.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20060621154419.18741.76233.sendpatchset@schroedinger.engr.sgi.com>
References: <20060621154419.18741.76233.sendpatchset@schroedinger.engr.sgi.com>
Subject: [PATCH 10/14] Conversion of nr_dirty to per zone counter
ReSent-To: linux-mm@kvack.org
ReSent-Message-ID: <Pine.LNX.4.64.0606210846534.18960@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Subject: zoned vm counters: conversion of nr_dirty to per zone counter
From: Christoph Lameter <clameter@sgi.com>
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: Martin Bligh <mbligh@google.com>, linux-mm@vger.kernel.org, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

This makes nr_dirty a per zone counter.  Looping over all processors is
avoided during writeback state determination.

The counter aggregation for nr_dirty had to be undone in the NFS layer since
we summed up the page counts from multiple zones. Someone more familiar with
NFS should probably review what I have done.

Signed-off-by: Christoph Lameter <clameter@sgi.com>
Signed-off-by: Andrew Morton <akpm@osdl.org>

Index: linux-2.6.17-mm1/arch/i386/mm/pgtable.c
===================================================================
--- linux-2.6.17-mm1.orig/arch/i386/mm/pgtable.c	2006-06-21 08:16:48.391177832 -0700
+++ linux-2.6.17-mm1/arch/i386/mm/pgtable.c	2006-06-21 08:18:32.596647499 -0700
@@ -59,7 +59,7 @@ void show_mem(void)
 	printk(KERN_INFO "%d pages swap cached\n", cached);
 
 	get_page_state(&ps);
-	printk(KERN_INFO "%lu pages dirty\n", ps.nr_dirty);
+	printk(KERN_INFO "%lu pages dirty\n", global_page_state(NR_FILE_DIRTY));
 	printk(KERN_INFO "%lu pages writeback\n", ps.nr_writeback);
 	printk(KERN_INFO "%lu pages mapped\n", global_page_state(NR_FILE_MAPPED));
 	printk(KERN_INFO "%lu pages slab\n", global_page_state(NR_SLAB));
Index: linux-2.6.17-mm1/drivers/base/node.c
===================================================================
--- linux-2.6.17-mm1.orig/drivers/base/node.c	2006-06-21 08:17:19.709553287 -0700
+++ linux-2.6.17-mm1/drivers/base/node.c	2006-06-21 08:18:32.597624001 -0700
@@ -49,8 +49,6 @@ static ssize_t node_read_meminfo(struct 
 	__get_zone_counts(&active, &inactive, &free, NODE_DATA(nid));
 
 	/* Check for negative values in these approximate counters */
-	if ((long)ps.nr_dirty < 0)
-		ps.nr_dirty = 0;
 	if ((long)ps.nr_writeback < 0)
 		ps.nr_writeback = 0;
 
@@ -80,7 +78,7 @@ static ssize_t node_read_meminfo(struct 
 		       nid, K(i.freehigh),
 		       nid, K(i.totalram - i.totalhigh),
 		       nid, K(i.freeram - i.freehigh),
-		       nid, K(ps.nr_dirty),
+		       nid, K(node_page_state(nid, NR_FILE_DIRTY)),
 		       nid, K(ps.nr_writeback),
 		       nid, K(node_page_state(nid, NR_FILE_PAGES)),
 		       nid, K(node_page_state(nid, NR_FILE_MAPPED)),
Index: linux-2.6.17-mm1/fs/buffer.c
===================================================================
--- linux-2.6.17-mm1.orig/fs/buffer.c	2006-06-17 18:49:35.000000000 -0700
+++ linux-2.6.17-mm1/fs/buffer.c	2006-06-21 08:18:32.599577006 -0700
@@ -854,7 +854,7 @@ int __set_page_dirty_buffers(struct page
 		write_lock_irq(&mapping->tree_lock);
 		if (page->mapping) {	/* Race with truncate? */
 			if (mapping_cap_account_dirty(mapping))
-				inc_page_state(nr_dirty);
+				__inc_zone_page_state(page, NR_FILE_DIRTY);
 			radix_tree_tag_set(&mapping->page_tree,
 						page_index(page),
 						PAGECACHE_TAG_DIRTY);
Index: linux-2.6.17-mm1/fs/fs-writeback.c
===================================================================
--- linux-2.6.17-mm1.orig/fs/fs-writeback.c	2006-06-17 18:49:35.000000000 -0700
+++ linux-2.6.17-mm1/fs/fs-writeback.c	2006-06-21 08:18:32.599577006 -0700
@@ -462,7 +462,7 @@ void sync_inodes_sb(struct super_block *
 	struct writeback_control wbc = {
 		.sync_mode	= wait ? WB_SYNC_ALL : WB_SYNC_HOLD,
 	};
-	unsigned long nr_dirty = read_page_state(nr_dirty);
+	unsigned long nr_dirty = global_page_state(NR_FILE_DIRTY);
 	unsigned long nr_unstable = read_page_state(nr_unstable);
 
 	wbc.nr_to_write = nr_dirty + nr_unstable +
Index: linux-2.6.17-mm1/fs/nfs/pagelist.c
===================================================================
--- linux-2.6.17-mm1.orig/fs/nfs/pagelist.c	2006-06-17 18:49:35.000000000 -0700
+++ linux-2.6.17-mm1/fs/nfs/pagelist.c	2006-06-21 08:18:32.600553508 -0700
@@ -315,6 +315,7 @@ nfs_scan_lock_dirty(struct nfs_inode *nf
 						req->wb_index, NFS_PAGE_TAG_DIRTY);
 				nfs_list_remove_request(req);
 				nfs_list_add_request(req, dst);
+				dec_zone_page_state(req->wb_page, NR_FILE_DIRTY);
 				res++;
 			}
 		}
Index: linux-2.6.17-mm1/fs/nfs/write.c
===================================================================
--- linux-2.6.17-mm1.orig/fs/nfs/write.c	2006-06-17 18:49:35.000000000 -0700
+++ linux-2.6.17-mm1/fs/nfs/write.c	2006-06-21 08:18:32.601530010 -0700
@@ -501,7 +501,7 @@ nfs_mark_request_dirty(struct nfs_page *
 	nfs_list_add_request(req, &nfsi->dirty);
 	nfsi->ndirty++;
 	spin_unlock(&nfsi->req_lock);
-	inc_page_state(nr_dirty);
+	inc_zone_page_state(req->wb_page, NR_FILE_DIRTY);
 	mark_inode_dirty(inode);
 }
 
@@ -602,7 +602,6 @@ nfs_scan_dirty(struct inode *inode, stru
 	if (nfsi->ndirty != 0) {
 		res = nfs_scan_lock_dirty(nfsi, dst, idx_start, npages);
 		nfsi->ndirty -= res;
-		sub_page_state(nr_dirty,res);
 		if ((nfsi->ndirty == 0) != list_empty(&nfsi->dirty))
 			printk(KERN_ERR "NFS: desynchronized value of nfs_i.ndirty.\n");
 	}
Index: linux-2.6.17-mm1/fs/proc/proc_misc.c
===================================================================
--- linux-2.6.17-mm1.orig/fs/proc/proc_misc.c	2006-06-21 08:16:48.392154334 -0700
+++ linux-2.6.17-mm1/fs/proc/proc_misc.c	2006-06-21 08:18:32.602506512 -0700
@@ -190,7 +190,7 @@ static int meminfo_read_proc(char *page,
 		K(i.freeram-i.freehigh),
 		K(i.totalswap),
 		K(i.freeswap),
-		K(ps.nr_dirty),
+		K(global_page_state(NR_FILE_DIRTY)),
 		K(ps.nr_writeback),
 		K(global_page_state(NR_ANON_PAGES)),
 		K(global_page_state(NR_FILE_MAPPED)),
Index: linux-2.6.17-mm1/include/linux/mmzone.h
===================================================================
--- linux-2.6.17-mm1.orig/include/linux/mmzone.h	2006-06-21 08:16:48.394107338 -0700
+++ linux-2.6.17-mm1/include/linux/mmzone.h	2006-06-21 08:18:32.603483014 -0700
@@ -54,6 +54,7 @@ enum zone_stat_item {
 	NR_FILE_PAGES,
 	NR_SLAB,	/* Pages used by slab allocator */
 	NR_PAGETABLE,	/* used for pagetables */
+	NR_FILE_DIRTY,
 	NR_VM_ZONE_STAT_ITEMS };
 
 struct per_cpu_pages {
Index: linux-2.6.17-mm1/mm/page_alloc.c
===================================================================
--- linux-2.6.17-mm1.orig/mm/page_alloc.c	2006-06-21 08:16:48.397036845 -0700
+++ linux-2.6.17-mm1/mm/page_alloc.c	2006-06-21 08:18:32.605436019 -0700
@@ -1309,7 +1309,7 @@ void show_free_areas(void)
 		"unstable:%lu free:%u slab:%lu mapped:%lu pagetables:%lu\n",
 		active,
 		inactive,
-		ps.nr_dirty,
+		global_page_state(NR_FILE_DIRTY),
 		ps.nr_writeback,
 		ps.nr_unstable,
 		nr_free_pages(),
Index: linux-2.6.17-mm1/mm/page-writeback.c
===================================================================
--- linux-2.6.17-mm1.orig/mm/page-writeback.c	2006-06-21 08:13:22.421494717 -0700
+++ linux-2.6.17-mm1/mm/page-writeback.c	2006-06-21 08:18:32.606412521 -0700
@@ -109,7 +109,7 @@ struct writeback_state
 
 static void get_writeback_state(struct writeback_state *wbs)
 {
-	wbs->nr_dirty = read_page_state(nr_dirty);
+	wbs->nr_dirty = global_page_state(NR_FILE_DIRTY);
 	wbs->nr_unstable = read_page_state(nr_unstable);
 	wbs->nr_mapped = global_page_state(NR_FILE_MAPPED) +
 				global_page_state(NR_ANON_PAGES);
@@ -638,7 +638,7 @@ int __set_page_dirty_nobuffers(struct pa
 			if (mapping2) { /* Race with truncate? */
 				BUG_ON(mapping2 != mapping);
 				if (mapping_cap_account_dirty(mapping))
-					inc_page_state(nr_dirty);
+					__inc_zone_page_state(page, NR_FILE_DIRTY);
 				radix_tree_tag_set(&mapping->page_tree,
 					page_index(page), PAGECACHE_TAG_DIRTY);
 			}
@@ -725,9 +725,9 @@ int test_clear_page_dirty(struct page *p
 			radix_tree_tag_clear(&mapping->page_tree,
 						page_index(page),
 						PAGECACHE_TAG_DIRTY);
-			write_unlock_irqrestore(&mapping->tree_lock, flags);
 			if (mapping_cap_account_dirty(mapping))
-				dec_page_state(nr_dirty);
+				__dec_zone_page_state(page, NR_FILE_DIRTY);
+			write_unlock_irqrestore(&mapping->tree_lock, flags);
 			return 1;
 		}
 		write_unlock_irqrestore(&mapping->tree_lock, flags);
@@ -758,7 +758,7 @@ int clear_page_dirty_for_io(struct page 
 	if (mapping) {
 		if (TestClearPageDirty(page)) {
 			if (mapping_cap_account_dirty(mapping))
-				dec_page_state(nr_dirty);
+				dec_zone_page_state(page, NR_FILE_DIRTY);
 			return 1;
 		}
 		return 0;
Index: linux-2.6.17-mm1/mm/vmstat.c
===================================================================
--- linux-2.6.17-mm1.orig/mm/vmstat.c	2006-06-21 08:16:48.400942853 -0700
+++ linux-2.6.17-mm1/mm/vmstat.c	2006-06-21 08:18:32.607389023 -0700
@@ -462,9 +462,9 @@ static char *vmstat_text[] = {
 	"nr_file_pages",
 	"nr_slab",
 	"nr_page_table_pages",
+	"nr_dirty",
 
 	/* Page state */
-	"nr_dirty",
 	"nr_writeback",
 	"nr_unstable",
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
