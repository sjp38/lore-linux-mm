From: Christoph Lameter <clameter@sgi.com>
Message-Id: <20070215012505.5343.65950.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20070215012449.5343.22942.sendpatchset@schroedinger.engr.sgi.com>
References: <20070215012449.5343.22942.sendpatchset@schroedinger.engr.sgi.com>
Subject: [PATCH 3/7] Add NR_MLOCK ZVC
Date: Wed, 14 Feb 2007 17:25:05 -0800 (PST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: Christoph Hellwig <hch@infradead.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, "Martin J. Bligh" <mbligh@mbligh.org>, Arjan van de Ven <arjan@infradead.org>, Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org, Matt Mackall <mpm@selenic.com>, Christoph Lameter <clameter@sgi.com>, Nigel Cunningham <nigel@nigel.suspend2.net>, Rik van Riel <riel@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Basic infrastructure to support NR_MLOCK

Add a new ZVC to support NR_MLOCK. NR_MLOCK counts the number of
mlocked pages taken off the LRU. Get rid of wrong calculation
of cache line size in the comments in mmzone.h.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: current/drivers/base/node.c
===================================================================
--- current.orig/drivers/base/node.c	2007-02-05 11:30:47.000000000 -0800
+++ current/drivers/base/node.c	2007-02-05 11:39:26.000000000 -0800
@@ -60,6 +60,7 @@ static ssize_t node_read_meminfo(struct 
 		       "Node %d FilePages:    %8lu kB\n"
 		       "Node %d Mapped:       %8lu kB\n"
 		       "Node %d AnonPages:    %8lu kB\n"
+		       "Node %d Mlock:        %8lu KB\n"
 		       "Node %d PageTables:   %8lu kB\n"
 		       "Node %d NFS_Unstable: %8lu kB\n"
 		       "Node %d Bounce:       %8lu kB\n"
@@ -82,6 +83,7 @@ static ssize_t node_read_meminfo(struct 
 		       nid, K(node_page_state(nid, NR_FILE_PAGES)),
 		       nid, K(node_page_state(nid, NR_FILE_MAPPED)),
 		       nid, K(node_page_state(nid, NR_ANON_PAGES)),
+		       nid, K(node_page_state(nid, NR_MLOCK)),
 		       nid, K(node_page_state(nid, NR_PAGETABLE)),
 		       nid, K(node_page_state(nid, NR_UNSTABLE_NFS)),
 		       nid, K(node_page_state(nid, NR_BOUNCE)),
Index: current/fs/proc/proc_misc.c
===================================================================
--- current.orig/fs/proc/proc_misc.c	2007-02-05 11:30:47.000000000 -0800
+++ current/fs/proc/proc_misc.c	2007-02-05 11:39:26.000000000 -0800
@@ -166,6 +166,7 @@ static int meminfo_read_proc(char *page,
 		"Writeback:    %8lu kB\n"
 		"AnonPages:    %8lu kB\n"
 		"Mapped:       %8lu kB\n"
+		"Mlock:        %8lu KB\n"
 		"Slab:         %8lu kB\n"
 		"SReclaimable: %8lu kB\n"
 		"SUnreclaim:   %8lu kB\n"
@@ -196,6 +197,7 @@ static int meminfo_read_proc(char *page,
 		K(global_page_state(NR_WRITEBACK)),
 		K(global_page_state(NR_ANON_PAGES)),
 		K(global_page_state(NR_FILE_MAPPED)),
+		K(global_page_state(NR_MLOCK)),
 		K(global_page_state(NR_SLAB_RECLAIMABLE) +
 				global_page_state(NR_SLAB_UNRECLAIMABLE)),
 		K(global_page_state(NR_SLAB_RECLAIMABLE)),
Index: current/include/linux/mmzone.h
===================================================================
--- current.orig/include/linux/mmzone.h	2007-02-05 11:30:47.000000000 -0800
+++ current/include/linux/mmzone.h	2007-02-05 11:45:12.000000000 -0800
@@ -47,17 +47,16 @@ struct zone_padding {
 #endif
 
 enum zone_stat_item {
-	/* First 128 byte cacheline (assuming 64 bit words) */
 	NR_FREE_PAGES,
 	NR_INACTIVE,
 	NR_ACTIVE,
+	NR_MLOCK,	/* Mlocked pages */
 	NR_ANON_PAGES,	/* Mapped anonymous pages */
 	NR_FILE_MAPPED,	/* pagecache pages mapped into pagetables.
 			   only modified from process context */
 	NR_FILE_PAGES,
 	NR_FILE_DIRTY,
 	NR_WRITEBACK,
-	/* Second 128 byte cacheline */
 	NR_SLAB_RECLAIMABLE,
 	NR_SLAB_UNRECLAIMABLE,
 	NR_PAGETABLE,		/* used for pagetables */
Index: current/mm/vmstat.c
===================================================================
--- current.orig/mm/vmstat.c	2007-02-05 11:30:47.000000000 -0800
+++ current/mm/vmstat.c	2007-02-05 11:43:38.000000000 -0800
@@ -434,6 +434,7 @@ static const char * const vmstat_text[] 
 	"nr_free_pages",
 	"nr_active",
 	"nr_inactive",
+	"nr_mlock",
 	"nr_anon_pages",
 	"nr_mapped",
 	"nr_file_pages",

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
