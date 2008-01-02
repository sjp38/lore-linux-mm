From: linux-kernel@vger.kernel.org
Subject: [patch 18/19] account mlocked pages
Date: Wed, 02 Jan 2008 17:42:02 -0500
Message-ID: <20080102224155.408830686@redhat.com>
References: <20080102224144.885671949@redhat.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1760303AbYABX1o@vger.kernel.org>
Content-Disposition: inline; filename=noreclaim-04.3-account-mlocked-pages.patch
Sender: linux-kernel-owner@vger.kernel.org
Cc: linux-mm@kvack.org, lee.schermerhorn@hp.com, Nick Piggin <npiggin@suse.de>
List-Id: linux-mm.kvack.org

V2 -> V3:
+ rebase to 23-mm1 atop RvR's split lru series
+ fix definitions of NR_MLOCK to fix build errors when not configured.

V1 -> V2:
+  new in V2 -- pulled in & reworked from Nick's previous series

  From: Nick Piggin <npiggin@suse.de>
  To: Linux Memory Management <linux-mm@kvack.org>
  Cc: Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@osdl.org>
  Subject: [patch 4/4] mm: account mlocked pages
  Date:	Mon, 12 Mar 2007 07:39:14 +0100 (CET)

Add NR_MLOCK zone page state, which provides a (conservative) count of
mlocked pages (actually, the number of mlocked pages moved off the LRU).

Reworked by lts to fit in with the modified mlock page support in the
Reclaim Scalability series.  I don't know whether we'll want to keep
these stats in the long run, but during testing of this series, I find
them useful.

Signed-off-by: Nick Piggin <npiggin@suse.de>
Signed-off-by: Lee Schermerhorn <lee.schermerhorn@hp.com>
Signed-off-by: Rik van Riel <riel@redhat.com>


Index: linux-2.6.24-rc6-mm1/drivers/base/node.c
===================================================================
--- linux-2.6.24-rc6-mm1.orig/drivers/base/node.c	2008-01-02 17:08:16.000000000 -0500
+++ linux-2.6.24-rc6-mm1/drivers/base/node.c	2008-01-02 17:08:17.000000000 -0500
@@ -55,6 +55,9 @@ static ssize_t node_read_meminfo(struct 
 		       "Node %d Inactive(file): %8lu kB\n"
 #ifdef CONFIG_NORECLAIM
 		       "Node %d Noreclaim:    %8lu kB\n"
+#ifdef CONFIG_NORECLAIM_MLOCK
+		       "Node %d Mlocked:       %8lu kB\n"
+#endif
 #endif
 #ifdef CONFIG_HIGHMEM
 		       "Node %d HighTotal:      %8lu kB\n"
@@ -82,6 +85,9 @@ static ssize_t node_read_meminfo(struct 
 		       nid, node_page_state(nid, NR_INACTIVE_FILE),
 #ifdef CONFIG_NORECLAIM
 		       nid, node_page_state(nid, NR_NORECLAIM),
+#ifdef CONFIG_NORECLAIM_MLOCK
+		       nid, K(node_page_state(nid, NR_MLOCK)),
+#endif
 #endif
 #ifdef CONFIG_HIGHMEM
 		       nid, K(i.totalhigh),
Index: linux-2.6.24-rc6-mm1/fs/proc/proc_misc.c
===================================================================
--- linux-2.6.24-rc6-mm1.orig/fs/proc/proc_misc.c	2008-01-02 16:28:35.000000000 -0500
+++ linux-2.6.24-rc6-mm1/fs/proc/proc_misc.c	2008-01-02 17:08:17.000000000 -0500
@@ -164,6 +164,9 @@ static int meminfo_read_proc(char *page,
 		"Inactive(file): %8lu kB\n"
 #ifdef CONFIG_NORECLAIM
 		"Noreclaim:    %8lu kB\n"
+#ifdef CONFIG_NORECLAIM_MLOCK
+		"Mlocked:      %8lu kB\n"
+#endif
 #endif
 #ifdef CONFIG_HIGHMEM
 		"HighTotal:      %8lu kB\n"
@@ -199,6 +202,9 @@ static int meminfo_read_proc(char *page,
 		K(global_page_state(NR_INACTIVE_FILE)),
 #ifdef CONFIG_NORECLAIM
 		K(global_page_state(NR_NORECLAIM)),
+#ifdef CONFIG_NORECLAIM_MLOCK
+		K(global_page_state(NR_MLOCK)),
+#endif
 #endif
 #ifdef CONFIG_HIGHMEM
 		K(i.totalhigh),
Index: linux-2.6.24-rc6-mm1/include/linux/mmzone.h
===================================================================
--- linux-2.6.24-rc6-mm1.orig/include/linux/mmzone.h	2008-01-02 16:28:35.000000000 -0500
+++ linux-2.6.24-rc6-mm1/include/linux/mmzone.h	2008-01-02 17:08:17.000000000 -0500
@@ -86,8 +86,12 @@ enum zone_stat_item {
 	NR_ACTIVE_FILE,		/*  "     "     "   "       "           */
 #ifdef CONFIG_NORECLAIM
 	NR_NORECLAIM,	/*  "     "     "   "       "         */
+#ifdef CONFIG_NORECLAIM_MLOCK
+	NR_MLOCK,		/* mlock()ed pages found and moved off LRU */
+#endif
 #else
-	NR_NORECLAIM=NR_ACTIVE_FILE, /* avoid compiler errors in dead code */
+	NR_NORECLAIM=NR_ACTIVE_FILE,	/* avoid compiler errors in dead code */
+	NR_MLOCK=NR_ACTIVE_FILE,	/* avoid compiler errors... */
 #endif
 	NR_ANON_PAGES,	/* Mapped anonymous pages */
 	NR_FILE_MAPPED,	/* pagecache pages mapped into pagetables.
Index: linux-2.6.24-rc6-mm1/mm/mlock.c
===================================================================
--- linux-2.6.24-rc6-mm1.orig/mm/mlock.c	2008-01-02 17:08:17.000000000 -0500
+++ linux-2.6.24-rc6-mm1/mm/mlock.c	2008-01-02 17:08:17.000000000 -0500
@@ -60,11 +60,11 @@ void clear_page_mlock(struct page *page)
 {
 	BUG_ON(!PageLocked(page));
 
-	if (likely(!PageMlocked(page)))
-		return;
-	ClearPageMlocked(page);
-	if (!isolate_lru_page(page))
-		putback_lru_page(page);
+	if (unlikely(TestClearPageMlocked(page))) {
+		dec_zone_page_state(page, NR_MLOCK);
+		if (!isolate_lru_page(page))
+			putback_lru_page(page);
+	}
 }
 
 /*
@@ -75,8 +75,11 @@ void mlock_vma_page(struct page *page)
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
@@ -98,10 +101,22 @@ static void munlock_vma_page(struct page
 {
 	BUG_ON(!PageLocked(page));
 
-	if (TestClearPageMlocked(page) && !isolate_lru_page(page)) {
-		if (try_to_unlock(page) == SWAP_MLOCK)
-			SetPageMlocked(page);	/* still VM_LOCKED */
-		putback_lru_page(page);
+	if (TestClearPageMlocked(page)) {
+		dec_zone_page_state(page, NR_MLOCK);
+		if (!isolate_lru_page(page)) {
+			if (try_to_unlock(page) == SWAP_MLOCK) {
+				SetPageMlocked(page);	/* still VM_LOCKED */
+				inc_zone_page_state(page, NR_MLOCK);
+			}
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
 
@@ -118,7 +133,8 @@ int is_mlocked_vma(struct vm_area_struct
 	if (likely(!(vma->vm_flags & VM_LOCKED)))
 		return 0;
 
-	SetPageMlocked(page);
+	if (!TestSetPageMlocked(page))
+		inc_zone_page_state(page, NR_MLOCK);
 	return 1;
 }
 
Index: linux-2.6.24-rc6-mm1/mm/migrate.c
===================================================================
--- linux-2.6.24-rc6-mm1.orig/mm/migrate.c	2008-01-02 17:08:17.000000000 -0500
+++ linux-2.6.24-rc6-mm1/mm/migrate.c	2008-01-02 17:08:17.000000000 -0500
@@ -366,8 +366,15 @@ static void migrate_page_copy(struct pag
 		set_page_dirty(newpage);
  	}
 
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
 
 #ifdef CONFIG_SWAP
 	ClearPageSwapCache(page);
Index: linux-2.6.24-rc6-mm1/mm/vmstat.c
===================================================================
--- linux-2.6.24-rc6-mm1.orig/mm/vmstat.c	2008-01-02 16:01:21.000000000 -0500
+++ linux-2.6.24-rc6-mm1/mm/vmstat.c	2008-01-02 17:09:20.000000000 -0500
@@ -693,6 +693,9 @@ static const char * const vmstat_text[] 
 #ifdef CONFIG_NORECLAIM
 	"nr_noreclaim",
 #endif
+#ifdef CONFIG_NORECLAIM_MLOCK
+	"nr_mlock",
+#endif
 	"nr_anon_pages",
 	"nr_mapped",
 	"nr_file_pages",

-- 
All Rights Reversed

