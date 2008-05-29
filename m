From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Date: Thu, 29 May 2008 15:51:21 -0400
Message-Id: <20080529195121.27159.50114.sendpatchset@lts-notebook>
In-Reply-To: <20080529195030.27159.66161.sendpatchset@lts-notebook>
References: <20080529195030.27159.66161.sendpatchset@lts-notebook>
Subject: [PATCH 20/25] Mlocked Pages statistics
Sender: owner-linux-mm@kvack.org
From: Nick Piggin <npiggin@suse.de>
  To: Linux Memory Management <linux-mm@kvack.org>
  Subject: [patch 4/4] mm: account mlocked pages
  Date:	Mon, 12 Mar 2007 07:39:14 +0100 (CET)
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Kosaki Motohiro <kosaki.motohiro@jp.fujitsu.com>, Eric Whitney <eric.whitney@hp.com>, linux-mm@kvack.org, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Against:  2.6.26-rc2-mm1

V2 -> V3:
+ rebase to 23-mm1 atop RvR's split lru series
+ fix definitions of NR_MLOCK to fix build errors when not configured.

V1 -> V2:
+  new in V2 -- pulled in & reworked from Nick's previous series

Add NR_MLOCK zone page state, which provides a (conservative) count of
mlocked pages (actually, the number of mlocked pages moved off the LRU).

Reworked by lts to fit in with the modified mlock page support in the
Reclaim Scalability series.

Signed-off-by: Nick Piggin <npiggin@suse.de>
Signed-off-by: Lee Schermerhorn <lee.schermerhorn@hp.com>
Signed-off-by: Rik van Riel <riel@redhat.com>
Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

 drivers/base/node.c    |   24 +++++++++++++++---------
 fs/proc/proc_misc.c    |    6 ++++++
 include/linux/mmzone.h |    5 +++++
 mm/internal.h          |   14 +++++++++++---
 mm/mlock.c             |   22 ++++++++++++++++++----
 mm/vmstat.c            |    3 +++
 6 files changed, 58 insertions(+), 16 deletions(-)

Index: linux-2.6.26-rc2-mm1/drivers/base/node.c
===================================================================
--- linux-2.6.26-rc2-mm1.orig/drivers/base/node.c	2008-05-22 15:24:51.000000000 -0400
+++ linux-2.6.26-rc2-mm1/drivers/base/node.c	2008-05-22 15:26:49.000000000 -0400
@@ -69,6 +69,9 @@ static ssize_t node_read_meminfo(struct 
 		       "Node %d Inactive(file): %8lu kB\n"
 #ifdef CONFIG_NORECLAIM_LRU
 		       "Node %d Noreclaim:      %8lu kB\n"
+#ifdef CONFIG_NORECLAIM_MLOCK
+		       "Node %d Mlocked:        %8lu kB\n"
+#endif
 #endif
 #ifdef CONFIG_HIGHMEM
 		       "Node %d HighTotal:      %8lu kB\n"
@@ -91,16 +94,19 @@ static ssize_t node_read_meminfo(struct 
 		       nid, K(i.totalram),
 		       nid, K(i.freeram),
 		       nid, K(i.totalram - i.freeram),
-		       nid, node_page_state(nid, NR_ACTIVE_ANON) +
-				node_page_state(nid, NR_ACTIVE_FILE),
-		       nid, node_page_state(nid, NR_INACTIVE_ANON) +
-				node_page_state(nid, NR_INACTIVE_FILE),
-		       nid, node_page_state(nid, NR_ACTIVE_ANON),
-		       nid, node_page_state(nid, NR_INACTIVE_ANON),
-		       nid, node_page_state(nid, NR_ACTIVE_FILE),
-		       nid, node_page_state(nid, NR_INACTIVE_FILE),
+		       nid, K(node_page_state(nid, NR_ACTIVE_ANON) +
+				node_page_state(nid, NR_ACTIVE_FILE)),
+		       nid, K(node_page_state(nid, NR_INACTIVE_ANON) +
+				node_page_state(nid, NR_INACTIVE_FILE)),
+		       nid, K(node_page_state(nid, NR_ACTIVE_ANON)),
+		       nid, K(node_page_state(nid, NR_INACTIVE_ANON)),
+		       nid, K(node_page_state(nid, NR_ACTIVE_FILE)),
+		       nid, K(node_page_state(nid, NR_INACTIVE_FILE)),
 #ifdef CONFIG_NORECLAIM_LRU
-		       nid, node_page_state(nid, NR_NORECLAIM),
+		       nid, K(node_page_state(nid, NR_NORECLAIM)),
+#ifdef CONFIG_NORECLAIM_MLOCK
+		       nid, K(node_page_state(nid, NR_MLOCK)),
+#endif
 #endif
 #ifdef CONFIG_HIGHMEM
 		       nid, K(i.totalhigh),
Index: linux-2.6.26-rc2-mm1/fs/proc/proc_misc.c
===================================================================
--- linux-2.6.26-rc2-mm1.orig/fs/proc/proc_misc.c	2008-05-22 15:24:51.000000000 -0400
+++ linux-2.6.26-rc2-mm1/fs/proc/proc_misc.c	2008-05-22 15:26:49.000000000 -0400
@@ -176,6 +176,9 @@ static int meminfo_read_proc(char *page,
 		"Inactive(file): %8lu kB\n"
 #ifdef CONFIG_NORECLAIM_LRU
 		"Noreclaim:      %8lu kB\n"
+#ifdef CONFIG_NORECLAIM_MLOCK
+		"Mlocked:        %8lu kB\n"
+#endif
 #endif
 #ifdef CONFIG_HIGHMEM
 		"HighTotal:      %8lu kB\n"
@@ -214,6 +217,9 @@ static int meminfo_read_proc(char *page,
 		K(inactive_file),
 #ifdef CONFIG_NORECLAIM_LRU
 		K(global_page_state(NR_NORECLAIM)),
+#ifdef CONFIG_NORECLAIM_MLOCK
+		K(global_page_state(NR_MLOCK)),
+#endif
 #endif
 #ifdef CONFIG_HIGHMEM
 		K(i.totalhigh),
Index: linux-2.6.26-rc2-mm1/include/linux/mmzone.h
===================================================================
--- linux-2.6.26-rc2-mm1.orig/include/linux/mmzone.h	2008-05-22 15:19:31.000000000 -0400
+++ linux-2.6.26-rc2-mm1/include/linux/mmzone.h	2008-05-22 15:26:49.000000000 -0400
@@ -90,6 +90,11 @@ enum zone_stat_item {
 #else
 	NR_NORECLAIM = NR_ACTIVE_FILE, /* avoid compiler errors in dead code */
 #endif
+#ifdef CONFIG_NORECLAIM_MLOCK
+	NR_MLOCK,		/* mlock()ed pages found and moved off LRU */
+#else
+	NR_MLOCK = NR_ACTIVE_FILE,	/* avoid compier errors... */
+#endif
 	NR_ANON_PAGES,	/* Mapped anonymous pages */
 	NR_FILE_MAPPED,	/* pagecache pages mapped into pagetables.
 			   only modified from process context */
Index: linux-2.6.26-rc2-mm1/mm/mlock.c
===================================================================
--- linux-2.6.26-rc2-mm1.orig/mm/mlock.c	2008-05-22 15:26:47.000000000 -0400
+++ linux-2.6.26-rc2-mm1/mm/mlock.c	2008-05-22 15:26:49.000000000 -0400
@@ -56,6 +56,7 @@ void __clear_page_mlock(struct page *pag
 {
 	VM_BUG_ON(!PageLocked(page));	/* for LRU islolate/putback */
 
+	dec_zone_page_state(page, NR_MLOCK);
 	if (!isolate_lru_page(page)) {
 		putback_lru_page(page);
 	} else {
@@ -76,8 +77,11 @@ void mlock_vma_page(struct page *page)
 {
 	BUG_ON(!PageLocked(page));
 
-	if (!TestSetPageMlocked(page) && !isolate_lru_page(page))
+	if (!TestSetPageMlocked(page)) {
+		inc_zone_page_state(page, NR_MLOCK);
+		if (!isolate_lru_page(page))
 			putback_lru_page(page);
+	}
 }
 
 /*
@@ -102,9 +106,19 @@ static void munlock_vma_page(struct page
 {
 	BUG_ON(!PageLocked(page));
 
-	if (TestClearPageMlocked(page) && !isolate_lru_page(page)) {
-		try_to_unlock(page);
-		putback_lru_page(page);
+	if (TestClearPageMlocked(page)) {
+		dec_zone_page_state(page, NR_MLOCK);
+		if (!isolate_lru_page(page)) {
+			try_to_unlock(page);	/* maybe relock the page */
+			putback_lru_page(page);
+		}
+		/*
+		 * Else we lost the race.  let try_to_unmap() deal with it.
+		 * At least we get the page state and mlock stats right.
+		 * However, page is still on the noreclaim list.  We'll fix
+		 * that up when the page is eventually freed or we scan the
+		 * noreclaim list.
+		 */
 	}
 }
 
Index: linux-2.6.26-rc2-mm1/mm/vmstat.c
===================================================================
--- linux-2.6.26-rc2-mm1.orig/mm/vmstat.c	2008-05-22 15:24:51.000000000 -0400
+++ linux-2.6.26-rc2-mm1/mm/vmstat.c	2008-05-22 15:26:49.000000000 -0400
@@ -702,6 +702,9 @@ static const char * const vmstat_text[] 
 #ifdef CONFIG_NORECLAIM_LRU
 	"nr_noreclaim",
 #endif
+#ifdef CONFIG_NORECLAIM_MLOCK
+	"nr_mlock",
+#endif
 	"nr_anon_pages",
 	"nr_mapped",
 	"nr_file_pages",
Index: linux-2.6.26-rc2-mm1/mm/internal.h
===================================================================
--- linux-2.6.26-rc2-mm1.orig/mm/internal.h	2008-05-22 15:26:47.000000000 -0400
+++ linux-2.6.26-rc2-mm1/mm/internal.h	2008-05-22 15:26:49.000000000 -0400
@@ -107,7 +107,8 @@ static inline int is_mlocked_vma(struct 
 	if (likely((vma->vm_flags & (VM_LOCKED | VM_SPECIAL)) != VM_LOCKED))
 		return 0;
 
-	SetPageMlocked(page);
+	if (!TestSetPageMlocked(page))
+		inc_zone_page_state(page, NR_MLOCK);
 	return 1;
 }
 
@@ -134,12 +135,19 @@ static inline void clear_page_mlock(stru
 
 /*
  * mlock_migrate_page - called only from migrate_page_copy() to
- * migrate the Mlocked page flag
+ * migrate the Mlocked page flag; update statistics.
  */
 static inline void mlock_migrate_page(struct page *newpage, struct page *page)
 {
-	if (TestClearPageMlocked(page))
+	if (TestClearPageMlocked(page)) {
+		unsigned long flags;
+
+		local_irq_save(flags);
+		__dec_zone_page_state(page, NR_MLOCK);
 		SetPageMlocked(newpage);
+		__inc_zone_page_state(newpage, NR_MLOCK);
+		local_irq_restore(flags);
+	}
 }
 
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
