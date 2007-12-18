Message-Id: <20071218211550.491193582@redhat.com>
References: <20071218211539.250334036@redhat.com>
Date: Tue, 18 Dec 2007 16:15:59 -0500
From: Rik van Riel <riel@redhat.com>
Subject: [patch 20/20] account mlocked pages
Content-Disposition: inline; filename=noreclaim-04.3-account-mlocked-pages.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, lee.shermerhorn@hp.com, Nick Piggin <npiggin@suse.de>, Lee Schermerhorn <lee.schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

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


Index: Linux/drivers/base/node.c
===================================================================
--- Linux.orig/drivers/base/node.c	2007-11-14 09:26:19.000000000 -0500
+++ Linux/drivers/base/node.c	2007-11-14 10:06:14.000000000 -0500
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
Index: Linux/fs/proc/proc_misc.c
===================================================================
--- Linux.orig/fs/proc/proc_misc.c	2007-11-14 09:26:19.000000000 -0500
+++ Linux/fs/proc/proc_misc.c	2007-11-14 09:27:21.000000000 -0500
@@ -160,6 +160,9 @@ static int meminfo_read_proc(char *page,
 		"Inactive(file): %8lu kB\n"
 #ifdef CONFIG_NORECLAIM
 		"Noreclaim:    %8lu kB\n"
+#ifdef CONFIG_NORECLAIM_MLOCK
+		"Mlocked:      %8lu kB\n"
+#endif
 #endif
 #ifdef CONFIG_HIGHMEM
 		"HighTotal:      %8lu kB\n"
@@ -195,6 +198,9 @@ static int meminfo_read_proc(char *page,
 		K(global_page_state(NR_INACTIVE_FILE)),
 #ifdef CONFIG_NORECLAIM
 		K(global_page_state(NR_NORECLAIM)),
+#ifdef CONFIG_NORECLAIM_MLOCK
+		K(global_page_state(NR_MLOCK)),
+#endif
 #endif
 #ifdef CONFIG_HIGHMEM
 		K(i.totalhigh),
Index: Linux/include/linux/mmzone.h
===================================================================
--- Linux.orig/include/linux/mmzone.h	2007-11-14 09:26:19.000000000 -0500
+++ Linux/include/linux/mmzone.h	2007-11-14 09:54:53.000000000 -0500
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
Index: Linux/mm/mlock.c
===================================================================
--- Linux.orig/mm/mlock.c	2007-11-14 09:27:18.000000000 -0500
+++ Linux/mm/mlock.c	2007-11-14 10:05:37.000000000 -0500
@@ -75,11 +75,11 @@ void clear_page_mlock(struct page *page)
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
@@ -90,8 +90,11 @@ void mlock_vma_page(struct page *page)
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
@@ -113,10 +116,22 @@ static void munlock_vma_page(struct page
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
 
@@ -133,7 +148,8 @@ int is_mlocked_vma(struct vm_area_struct
 	if (likely(!(vma->vm_flags & VM_LOCKED)))
 		return 0;
 
-	SetPageMlocked(page);
+	if (!TestSetPageMlocked(page))
+		inc_zone_page_state(page, NR_MLOCK);
 	return 1;
 }
 
Index: Linux/mm/migrate.c
===================================================================
--- Linux.orig/mm/migrate.c	2007-11-14 09:27:17.000000000 -0500
+++ Linux/mm/migrate.c	2007-11-14 09:27:21.000000000 -0500
@@ -371,8 +371,15 @@ static void migrate_page_copy(struct pag
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

-- 
All Rights Reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
