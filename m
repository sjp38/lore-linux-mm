From: Nick Piggin <npiggin@suse.de>
Message-Id: <20070312042632.5536.82787.sendpatchset@linux.site>
In-Reply-To: <20070312042553.5536.73828.sendpatchset@linux.site>
References: <20070312042553.5536.73828.sendpatchset@linux.site>
Subject: [patch 4/4] mm: account mlocked pages
Date: Mon, 12 Mar 2007 07:39:14 +0100 (CET)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux Memory Management <linux-mm@kvack.org>
Cc: Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

Add NR_MLOCK zone page state, which provides a (conservative) count of
mlocked pages (actually, the number of mlocked pages moved off the LRU).

Signed-off-by: Nick Piggin <npiggin@suse.de>

 drivers/base/node.c    |    2 ++
 fs/proc/proc_misc.c    |    2 ++
 include/linux/mmzone.h |    1 +
 mm/mlock.c             |    2 ++
 4 files changed, 7 insertions(+)

Index: linux-2.6/drivers/base/node.c
===================================================================
--- linux-2.6.orig/drivers/base/node.c
+++ linux-2.6/drivers/base/node.c
@@ -60,6 +60,7 @@ static ssize_t node_read_meminfo(struct 
 		       "Node %d FilePages:    %8lu kB\n"
 		       "Node %d Mapped:       %8lu kB\n"
 		       "Node %d AnonPages:    %8lu kB\n"
+		       "Node %d Locked:       %8lu kB\n"
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
Index: linux-2.6/fs/proc/proc_misc.c
===================================================================
--- linux-2.6.orig/fs/proc/proc_misc.c
+++ linux-2.6/fs/proc/proc_misc.c
@@ -166,6 +166,7 @@ static int meminfo_read_proc(char *page,
 		"Writeback:    %8lu kB\n"
 		"AnonPages:    %8lu kB\n"
 		"Mapped:       %8lu kB\n"
+		"Locked:       %8lu kB\n"
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
Index: linux-2.6/include/linux/mmzone.h
===================================================================
--- linux-2.6.orig/include/linux/mmzone.h
+++ linux-2.6/include/linux/mmzone.h
@@ -73,6 +73,7 @@ enum zone_stat_item {
 	NR_ANON_PAGES,	/* Mapped anonymous pages */
 	NR_FILE_MAPPED,	/* pagecache pages mapped into pagetables.
 			   only modified from process context */
+	NR_MLOCK,	/* mlock()ed pages found and moved off LRU */
 	NR_FILE_PAGES,
 	NR_FILE_DIRTY,
 	NR_WRITEBACK,
Index: linux-2.6/mm/mlock.c
===================================================================
--- linux-2.6.orig/mm/mlock.c
+++ linux-2.6/mm/mlock.c
@@ -54,6 +54,7 @@ static void __set_page_mlock(struct page
 
 	SetPageMLock(page);
 	get_page(page);
+	inc_zone_page_state(page, NR_MLOCK);
 	set_page_mlock_count(page, 1);
 }
 
@@ -63,6 +64,7 @@ static void __clear_page_mlock(struct pa
 	BUG_ON(PageLRU(page));
 	BUG_ON(page_mlock_count(page));
 
+	dec_zone_page_state(page, NR_MLOCK);
 	ClearPageMLock(page);
 	lru_cache_add_active(page);
 	put_page(page);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
