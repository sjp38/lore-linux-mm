Date: Thu, 22 Jun 2006 09:41:06 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Message-Id: <20060622164106.28809.78434.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20060622164004.28809.8446.sendpatchset@schroedinger.engr.sgi.com>
References: <20060622164004.28809.8446.sendpatchset@schroedinger.engr.sgi.com>
Subject: [PATCH 12/14] Conversion of nr_unstable to per zone counter
Sender: owner-linux-mm@kvack.org
Subject: zoned vm counters: conversion of nr_unstable to per zone counter
From: Christoph Lameter <clameter@sgi.com>
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm@kvack.org, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

Conversion of nr_unstable to a per zone counter

We need to do some special modifications to the nfs code
since there are multiple cases of disposition and we need
to have a page ref for proper accounting.

This converts the last critical page state of the VM and therefore
we need to remove several functions that were depending on
GET_PAGE_STATE_LAST in order to make the kernel compile again.
We are only left with event type counters in page state.

Signed-off-by: Christoph Lameter <clameter@sgi.com>
Signed-off-by: Andrew Morton <akpm@osdl.org>

Index: linux-2.6.17-mm1/drivers/base/node.c
===================================================================
--- linux-2.6.17-mm1.orig/drivers/base/node.c	2006-06-22 08:49:30.151992830 -0700
+++ linux-2.6.17-mm1/drivers/base/node.c	2006-06-22 08:55:49.724221334 -0700
@@ -39,13 +39,11 @@ static ssize_t node_read_meminfo(struct 
 	int n;
 	int nid = dev->id;
 	struct sysinfo i;
-	struct page_state ps;
 	unsigned long inactive;
 	unsigned long active;
 	unsigned long free;
 
 	si_meminfo_node(&i, nid);
-	get_page_state_node(&ps, nid);
 	__get_zone_counts(&active, &inactive, &free, NODE_DATA(nid));
 
 
@@ -65,6 +63,7 @@ static ssize_t node_read_meminfo(struct 
 		       "Node %d Mapped:       %8lu kB\n"
 		       "Node %d AnonPages:    %8lu kB\n"
 		       "Node %d PageTables:   %8lu kB\n"
+		       "Node %d NFS Unstable: %8lu kB\n"
 		       "Node %d Slab:         %8lu kB\n",
 		       nid, K(i.totalram),
 		       nid, K(i.freeram),
@@ -81,6 +80,7 @@ static ssize_t node_read_meminfo(struct 
 		       nid, K(node_page_state(nid, NR_FILE_MAPPED)),
 		       nid, K(node_page_state(nid, NR_ANON_PAGES)),
 		       nid, K(node_page_state(nid, NR_PAGETABLE)),
+		       nid, K(node_page_state(nid, NR_UNSTABLE_NFS)),
 		       nid, K(node_page_state(nid, NR_SLAB)));
 	n += hugetlb_report_node_meminfo(nid, buf + n);
 	return n;
Index: linux-2.6.17-mm1/fs/fs-writeback.c
===================================================================
--- linux-2.6.17-mm1.orig/fs/fs-writeback.c	2006-06-22 08:43:21.312525512 -0700
+++ linux-2.6.17-mm1/fs/fs-writeback.c	2006-06-22 08:55:49.725197836 -0700
@@ -463,7 +463,7 @@ void sync_inodes_sb(struct super_block *
 		.sync_mode	= wait ? WB_SYNC_ALL : WB_SYNC_HOLD,
 	};
 	unsigned long nr_dirty = global_page_state(NR_FILE_DIRTY);
-	unsigned long nr_unstable = read_page_state(nr_unstable);
+	unsigned long nr_unstable = global_page_state(NR_UNSTABLE_NFS);
 
 	wbc.nr_to_write = nr_dirty + nr_unstable +
 			(inodes_stat.nr_inodes - inodes_stat.nr_unused) +
Index: linux-2.6.17-mm1/fs/nfs/write.c
===================================================================
--- linux-2.6.17-mm1.orig/fs/nfs/write.c	2006-06-22 08:43:21.314478516 -0700
+++ linux-2.6.17-mm1/fs/nfs/write.c	2006-06-22 08:55:49.726174339 -0700
@@ -529,7 +529,7 @@ nfs_mark_request_commit(struct nfs_page 
 	nfs_list_add_request(req, &nfsi->commit);
 	nfsi->ncommit++;
 	spin_unlock(&nfsi->req_lock);
-	inc_page_state(nr_unstable);
+	inc_zone_page_state(req->wb_page, NR_UNSTABLE_NFS);
 	mark_inode_dirty(inode);
 }
 #endif
@@ -1386,7 +1386,6 @@ static void nfs_commit_done(struct rpc_t
 {
 	struct nfs_write_data	*data = calldata;
 	struct nfs_page		*req;
-	int res = 0;
 
         dprintk("NFS: %4d nfs_commit_done (status %d)\n",
                                 task->tk_pid, task->tk_status);
@@ -1423,10 +1422,10 @@ static void nfs_commit_done(struct rpc_t
 		dprintk(" mismatch\n");
 		nfs_mark_request_dirty(req);
 	next:
+		if (req->wb_page)
+			dec_zone_page_state(req->wb_page, NR_UNSTABLE_NFS);
 		nfs_clear_page_writeback(req);
-		res++;
 	}
-	sub_page_state(nr_unstable,res);
 }
 
 static const struct rpc_call_ops nfs_commit_ops = {
Index: linux-2.6.17-mm1/include/linux/mmzone.h
===================================================================
--- linux-2.6.17-mm1.orig/include/linux/mmzone.h	2006-06-22 08:49:30.152969332 -0700
+++ linux-2.6.17-mm1/include/linux/mmzone.h	2006-06-22 08:55:49.727150841 -0700
@@ -56,6 +56,7 @@ enum zone_stat_item {
 	NR_PAGETABLE,	/* used for pagetables */
 	NR_FILE_DIRTY,
 	NR_WRITEBACK,
+	NR_UNSTABLE_NFS,	/* NFS unstable pages */
 	NR_VM_ZONE_STAT_ITEMS };
 
 struct per_cpu_pages {
Index: linux-2.6.17-mm1/mm/page_alloc.c
===================================================================
--- linux-2.6.17-mm1.orig/mm/page_alloc.c	2006-06-22 08:49:30.155898838 -0700
+++ linux-2.6.17-mm1/mm/page_alloc.c	2006-06-22 08:55:49.728127343 -0700
@@ -1266,7 +1266,6 @@ void si_meminfo_node(struct sysinfo *val
  */
 void show_free_areas(void)
 {
-	struct page_state ps;
 	int cpu, temperature;
 	unsigned long active;
 	unsigned long inactive;
@@ -1298,7 +1297,6 @@ void show_free_areas(void)
 		}
 	}
 
-	get_page_state(&ps);
 	get_zone_counts(&active, &inactive, &free);
 
 	printk("Free pages: %11ukB (%ukB HighMem)\n",
@@ -1311,7 +1309,7 @@ void show_free_areas(void)
 		inactive,
 		global_page_state(NR_FILE_DIRTY),
 		global_page_state(NR_WRITEBACK),
-		ps.nr_unstable,
+		global_page_state(NR_UNSTABLE_NFS),
 		nr_free_pages(),
 		global_page_state(NR_SLAB),
 		global_page_state(NR_FILE_MAPPED),
Index: linux-2.6.17-mm1/mm/page-writeback.c
===================================================================
--- linux-2.6.17-mm1.orig/mm/page-writeback.c	2006-06-22 08:49:30.155898838 -0700
+++ linux-2.6.17-mm1/mm/page-writeback.c	2006-06-22 08:55:49.729103845 -0700
@@ -110,7 +110,7 @@ struct writeback_state
 static void get_writeback_state(struct writeback_state *wbs)
 {
 	wbs->nr_dirty = global_page_state(NR_FILE_DIRTY);
-	wbs->nr_unstable = read_page_state(nr_unstable);
+	wbs->nr_unstable = global_page_state(NR_UNSTABLE_NFS);
 	wbs->nr_mapped = global_page_state(NR_FILE_MAPPED) +
 				global_page_state(NR_ANON_PAGES);
 	wbs->nr_writeback = global_page_state(NR_WRITEBACK);
Index: linux-2.6.17-mm1/fs/proc/proc_misc.c
===================================================================
--- linux-2.6.17-mm1.orig/fs/proc/proc_misc.c	2006-06-22 08:49:30.152969332 -0700
+++ linux-2.6.17-mm1/fs/proc/proc_misc.c	2006-06-22 08:55:49.730080347 -0700
@@ -120,7 +120,6 @@ static int meminfo_read_proc(char *page,
 {
 	struct sysinfo i;
 	int len;
-	struct page_state ps;
 	unsigned long inactive;
 	unsigned long active;
 	unsigned long free;
@@ -129,7 +128,6 @@ static int meminfo_read_proc(char *page,
 	struct vmalloc_info vmi;
 	long cached;
 
-	get_page_state(&ps);
 	get_zone_counts(&active, &inactive, &free);
 
 /*
@@ -172,6 +170,7 @@ static int meminfo_read_proc(char *page,
 		"Mapped:       %8lu kB\n"
 		"Slab:         %8lu kB\n"
 		"PageTables:   %8lu kB\n"
+		"NFS Unstable: %8lu kB\n"
 		"CommitLimit:  %8lu kB\n"
 		"Committed_AS: %8lu kB\n"
 		"VmallocTotal: %8lu kB\n"
@@ -196,6 +195,7 @@ static int meminfo_read_proc(char *page,
 		K(global_page_state(NR_FILE_MAPPED)),
 		K(global_page_state(NR_SLAB)),
 		K(global_page_state(NR_PAGETABLE)),
+		K(global_page_state(NR_UNSTABLE_NFS)),
 		K(allowed),
 		K(committed),
 		(unsigned long)VMALLOC_TOTAL >> 10,
Index: linux-2.6.17-mm1/mm/vmstat.c
===================================================================
--- linux-2.6.17-mm1.orig/mm/vmstat.c	2006-06-22 08:49:30.156875341 -0700
+++ linux-2.6.17-mm1/mm/vmstat.c	2006-06-22 08:56:55.160603832 -0700
@@ -45,28 +45,6 @@ static void __get_page_state(struct page
 	}
 }
 
-void get_page_state_node(struct page_state *ret, int node)
-{
-	int nr;
-	cpumask_t mask = node_to_cpumask(node);
-
-	nr = offsetof(struct page_state, GET_PAGE_STATE_LAST);
-	nr /= sizeof(unsigned long);
-
-	__get_page_state(ret, nr+1, &mask);
-}
-
-void get_page_state(struct page_state *ret)
-{
-	int nr;
-	cpumask_t mask = CPU_MASK_ALL;
-
-	nr = offsetof(struct page_state, GET_PAGE_STATE_LAST);
-	nr /= sizeof(unsigned long);
-
-	__get_page_state(ret, nr + 1, &mask);
-}
-
 void get_full_page_state(struct page_state *ret)
 {
 	cpumask_t mask = CPU_MASK_ALL;
@@ -464,10 +442,9 @@ static char *vmstat_text[] = {
 	"nr_page_table_pages",
 	"nr_dirty",
 	"nr_writeback",
-
-	/* Page state */
 	"nr_unstable",
 
+	/* Event counters */
 	"pgpgin",
 	"pgpgout",
 	"pswpin",
Index: linux-2.6.17-mm1/fs/nfs/pagelist.c
===================================================================
--- linux-2.6.17-mm1.orig/fs/nfs/pagelist.c	2006-06-22 08:43:21.313502014 -0700
+++ linux-2.6.17-mm1/fs/nfs/pagelist.c	2006-06-22 08:55:49.731056849 -0700
@@ -154,6 +154,7 @@ void nfs_clear_request(struct nfs_page *
 {
 	struct page *page = req->wb_page;
 	if (page != NULL) {
+		dec_zone_page_state(page, NR_UNSTABLE_NFS);
 		page_cache_release(page);
 		req->wb_page = NULL;
 	}
Index: linux-2.6.17-mm1/include/linux/vmstat.h
===================================================================
--- linux-2.6.17-mm1.orig/include/linux/vmstat.h	2006-06-22 08:49:41.977433405 -0700
+++ linux-2.6.17-mm1/include/linux/vmstat.h	2006-06-22 08:57:08.529894129 -0700
@@ -21,9 +21,6 @@
  * commented here.
  */
 struct page_state {
-	unsigned long nr_unstable;	/* NFS unstable pages */
-#define GET_PAGE_STATE_LAST nr_unstable
-
 	/*
 	 * The below are zeroed by get_page_state().  Use get_full_page_state()
 	 * to add up all these.
@@ -76,8 +73,6 @@ struct page_state {
 	unsigned long nr_bounce;	/* pages for bounce buffers */
 };
 
-extern void get_page_state(struct page_state *ret);
-extern void get_page_state_node(struct page_state *ret, int node);
 extern void get_full_page_state(struct page_state *ret);
 extern unsigned long read_page_state_offset(unsigned long offset);
 extern void mod_page_state_offset(unsigned long offset, unsigned long delta);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
