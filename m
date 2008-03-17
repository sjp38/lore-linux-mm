Message-Id: <20080317191942.482475908@szeredi.hu>
References: <20080317191908.123631326@szeredi.hu>
Date: Mon, 17 Mar 2008 20:19:10 +0100
From: Miklos Szeredi <miklos@szeredi.hu>
Subject: [patch 2/8] mm: Add NR_WRITEBACK_TEMP counter
Content-Disposition: inline; filename=add_nr_writeback_temp_stat.patch
Sender: owner-linux-mm@kvack.org
From: Miklos Szeredi <mszeredi@suse.cz>
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Fuse will use temporary buffers to write back dirty data from memory
mappings (normal writes are done synchronously).  This is needed,
because there cannot be any guarantee about the time in which a write
will complete.

By using temporary buffers, from the MM's point if view the page is
written back immediately.  If the writeout was due to memory pressure,
this effectively migrates data from a full zone to a less full zone.

This patch adds a new counter (NR_WRITEBACK_TEMP) for the number of
pages used as temporary buffers.

Signed-off-by: Miklos Szeredi <mszeredi@suse.cz>
---
 drivers/base/node.c    |    2 ++
 fs/proc/proc_misc.c    |    2 ++
 include/linux/mmzone.h |    1 +
 mm/page-writeback.c    |    3 ++-
 4 files changed, 7 insertions(+), 1 deletion(-)

Index: linux/fs/proc/proc_misc.c
===================================================================
--- linux.orig/fs/proc/proc_misc.c	2008-03-17 18:24:13.000000000 +0100
+++ linux/fs/proc/proc_misc.c	2008-03-17 18:25:17.000000000 +0100
@@ -179,6 +179,7 @@ static int meminfo_read_proc(char *page,
 		"PageTables:   %8lu kB\n"
 		"NFS_Unstable: %8lu kB\n"
 		"Bounce:       %8lu kB\n"
+		"WritebackTmp: %8lu kB\n"
 		"CommitLimit:  %8lu kB\n"
 		"Committed_AS: %8lu kB\n"
 		"VmallocTotal: %8lu kB\n"
@@ -210,6 +211,7 @@ static int meminfo_read_proc(char *page,
 		K(global_page_state(NR_PAGETABLE)),
 		K(global_page_state(NR_UNSTABLE_NFS)),
 		K(global_page_state(NR_BOUNCE)),
+		K(global_page_state(NR_WRITEBACK_TEMP)),
 		K(allowed),
 		K(committed),
 		(unsigned long)VMALLOC_TOTAL >> 10,
Index: linux/include/linux/mmzone.h
===================================================================
--- linux.orig/include/linux/mmzone.h	2008-03-17 18:24:13.000000000 +0100
+++ linux/include/linux/mmzone.h	2008-03-17 18:25:17.000000000 +0100
@@ -95,6 +95,7 @@ enum zone_stat_item {
 	NR_UNSTABLE_NFS,	/* NFS unstable pages */
 	NR_BOUNCE,
 	NR_VMSCAN_WRITE,
+	NR_WRITEBACK_TEMP,	/* Writeback using temporary buffers */
 #ifdef CONFIG_NUMA
 	NUMA_HIT,		/* allocated in intended node */
 	NUMA_MISS,		/* allocated in non intended node */
Index: linux/drivers/base/node.c
===================================================================
--- linux.orig/drivers/base/node.c	2008-03-17 18:24:13.000000000 +0100
+++ linux/drivers/base/node.c	2008-03-17 18:25:17.000000000 +0100
@@ -64,6 +64,7 @@ static ssize_t node_read_meminfo(struct 
 		       "Node %d PageTables:   %8lu kB\n"
 		       "Node %d NFS_Unstable: %8lu kB\n"
 		       "Node %d Bounce:       %8lu kB\n"
+		       "Node %d WritebackTmp: %8lu kB\n"
 		       "Node %d Slab:         %8lu kB\n"
 		       "Node %d SReclaimable: %8lu kB\n"
 		       "Node %d SUnreclaim:   %8lu kB\n",
@@ -86,6 +87,7 @@ static ssize_t node_read_meminfo(struct 
 		       nid, K(node_page_state(nid, NR_PAGETABLE)),
 		       nid, K(node_page_state(nid, NR_UNSTABLE_NFS)),
 		       nid, K(node_page_state(nid, NR_BOUNCE)),
+		       nid, K(node_page_state(nid, NR_WRITEBACK_TEMP)),
 		       nid, K(node_page_state(nid, NR_SLAB_RECLAIMABLE) +
 				node_page_state(nid, NR_SLAB_UNRECLAIMABLE)),
 		       nid, K(node_page_state(nid, NR_SLAB_RECLAIMABLE)),
Index: linux/mm/page-writeback.c
===================================================================
--- linux.orig/mm/page-writeback.c	2008-03-17 18:24:36.000000000 +0100
+++ linux/mm/page-writeback.c	2008-03-17 18:25:17.000000000 +0100
@@ -211,7 +211,8 @@ clip_bdi_dirty_limit(struct backing_dev_
 	avail_dirty = dirty -
 		(global_page_state(NR_FILE_DIRTY) +
 		 global_page_state(NR_WRITEBACK) +
-		 global_page_state(NR_UNSTABLE_NFS));
+		 global_page_state(NR_UNSTABLE_NFS) +
+		 global_page_state(NR_WRITEBACK_TEMP));
 
 	if (avail_dirty < 0)
 		avail_dirty = 0;

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
