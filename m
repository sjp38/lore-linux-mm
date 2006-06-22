Date: Thu, 22 Jun 2006 09:41:11 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Message-Id: <20060622164111.28809.391.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20060622164004.28809.8446.sendpatchset@schroedinger.engr.sgi.com>
References: <20060622164004.28809.8446.sendpatchset@schroedinger.engr.sgi.com>
Subject: [PATCH 13/14] Conversion of nr_bounce to per zone counter
Sender: owner-linux-mm@kvack.org
Subject: zoned vm counters: conversion of nr_bounce to per zone counter
From: Christoph Lameter <clameter@sgi.com>
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm@kvack.org, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

Conversion of nr_bounce to a per zone counter

nr_bounce is only used for proc output.  So it could be left as an
event counter.  However, the event counters may not be accurate and nr_bounce
is categorizing types of pages in a zone.  So we really need this to also be a
per zone counter.

Signed-off-by: Christoph Lameter <clameter@sgi.com>
Signed-off-by: Andrew Morton <akpm@osdl.org>

Index: linux-2.6.17-mm1/drivers/base/node.c
===================================================================
--- linux-2.6.17-mm1.orig/drivers/base/node.c	2006-06-22 08:55:49.724221334 -0700
+++ linux-2.6.17-mm1/drivers/base/node.c	2006-06-22 09:15:08.668078402 -0700
@@ -64,6 +64,7 @@ static ssize_t node_read_meminfo(struct 
 		       "Node %d AnonPages:    %8lu kB\n"
 		       "Node %d PageTables:   %8lu kB\n"
 		       "Node %d NFS Unstable: %8lu kB\n"
+		       "Node %d Bounce:       %8lu kB\n"
 		       "Node %d Slab:         %8lu kB\n",
 		       nid, K(i.totalram),
 		       nid, K(i.freeram),
@@ -81,6 +82,7 @@ static ssize_t node_read_meminfo(struct 
 		       nid, K(node_page_state(nid, NR_ANON_PAGES)),
 		       nid, K(node_page_state(nid, NR_PAGETABLE)),
 		       nid, K(node_page_state(nid, NR_UNSTABLE_NFS)),
+		       nid, K(node_page_state(nid, NR_BOUNCE)),
 		       nid, K(node_page_state(nid, NR_SLAB)));
 	n += hugetlb_report_node_meminfo(nid, buf + n);
 	return n;
Index: linux-2.6.17-mm1/include/linux/mmzone.h
===================================================================
--- linux-2.6.17-mm1.orig/include/linux/mmzone.h	2006-06-22 08:55:49.727150841 -0700
+++ linux-2.6.17-mm1/include/linux/mmzone.h	2006-06-22 09:15:08.669054904 -0700
@@ -57,6 +57,7 @@ enum zone_stat_item {
 	NR_FILE_DIRTY,
 	NR_WRITEBACK,
 	NR_UNSTABLE_NFS,	/* NFS unstable pages */
+	NR_BOUNCE,
 	NR_VM_ZONE_STAT_ITEMS };
 
 struct per_cpu_pages {
Index: linux-2.6.17-mm1/mm/highmem.c
===================================================================
--- linux-2.6.17-mm1.orig/mm/highmem.c	2006-06-17 18:49:35.000000000 -0700
+++ linux-2.6.17-mm1/mm/highmem.c	2006-06-22 09:15:08.670031406 -0700
@@ -316,7 +316,7 @@ static void bounce_end_io(struct bio *bi
 			continue;
 
 		mempool_free(bvec->bv_page, pool);	
-		dec_page_state(nr_bounce);
+		dec_zone_page_state(bvec->bv_page, NR_BOUNCE);
 	}
 
 	bio_endio(bio_orig, bio_orig->bi_size, err);
@@ -397,7 +397,7 @@ static void __blk_queue_bounce(request_q
 		to->bv_page = mempool_alloc(pool, q->bounce_gfp);
 		to->bv_len = from->bv_len;
 		to->bv_offset = from->bv_offset;
-		inc_page_state(nr_bounce);
+		inc_zone_page_state(to->bv_page, NR_BOUNCE);
 
 		if (rw == WRITE) {
 			char *vto, *vfrom;
Index: linux-2.6.17-mm1/mm/vmstat.c
===================================================================
--- linux-2.6.17-mm1.orig/mm/vmstat.c	2006-06-22 08:56:55.160603832 -0700
+++ linux-2.6.17-mm1/mm/vmstat.c	2006-06-22 09:15:08.671007908 -0700
@@ -443,6 +443,7 @@ static char *vmstat_text[] = {
 	"nr_dirty",
 	"nr_writeback",
 	"nr_unstable",
+	"nr_bounce",
 
 	/* Event counters */
 	"pgpgin",
@@ -490,7 +491,6 @@ static char *vmstat_text[] = {
 	"allocstall",
 
 	"pgrotated",
-	"nr_bounce",
 };
 
 /*
Index: linux-2.6.17-mm1/fs/proc/proc_misc.c
===================================================================
--- linux-2.6.17-mm1.orig/fs/proc/proc_misc.c	2006-06-22 08:55:49.730080347 -0700
+++ linux-2.6.17-mm1/fs/proc/proc_misc.c	2006-06-22 09:15:08.671984410 -0700
@@ -171,6 +171,7 @@ static int meminfo_read_proc(char *page,
 		"Slab:         %8lu kB\n"
 		"PageTables:   %8lu kB\n"
 		"NFS Unstable: %8lu kB\n"
+		"Bounce:       %8lu kB\n"
 		"CommitLimit:  %8lu kB\n"
 		"Committed_AS: %8lu kB\n"
 		"VmallocTotal: %8lu kB\n"
@@ -196,6 +197,7 @@ static int meminfo_read_proc(char *page,
 		K(global_page_state(NR_SLAB)),
 		K(global_page_state(NR_PAGETABLE)),
 		K(global_page_state(NR_UNSTABLE_NFS)),
+		K(global_page_state(NR_BOUNCE)),
 		K(allowed),
 		K(committed),
 		(unsigned long)VMALLOC_TOTAL >> 10,
Index: linux-2.6.17-mm1/include/linux/vmstat.h
===================================================================
--- linux-2.6.17-mm1.orig/include/linux/vmstat.h	2006-06-22 09:15:20.479846399 -0700
+++ linux-2.6.17-mm1/include/linux/vmstat.h	2006-06-22 09:15:22.334223666 -0700
@@ -70,7 +70,6 @@ struct page_state {
 	unsigned long allocstall;	/* direct reclaim calls */
 
 	unsigned long pgrotated;	/* pages rotated to tail of the LRU */
-	unsigned long nr_bounce;	/* pages for bounce buffers */
 };
 
 extern void get_full_page_state(struct page_state *ret);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
