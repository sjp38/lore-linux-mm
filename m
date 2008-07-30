From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Date: Wed, 30 Jul 2008 16:06:49 -0400
Message-Id: <20080730200649.24272.58778.sendpatchset@lts-notebook>
In-Reply-To: <20080730200618.24272.31756.sendpatchset@lts-notebook>
References: <20080730200618.24272.31756.sendpatchset@lts-notebook>
Subject: [PATCH 5/7] mlocked-pages:  add event counting with statistics
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@surriel.com>, Eric.Whitney@hp.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Fix to vmstat-mlocked-pages-statistics.patch

Define mlocked pages vm events in the mlocked pages
statistics patch.  Makes for easier incremental patching.

Signed-off-by: Lee Schermerhorn <lee.schermerhorn@hp.com>

 include/linux/vmstat.h |    4 ++++
 mm/internal.h          |    4 +++-
 mm/mlock.c             |   33 +++++++++++++++++++++++++--------
 mm/vmstat.c            |    4 ++++
 4 files changed, 36 insertions(+), 9 deletions(-)

Index: linux-2.6.27-rc1-mmotm-30jul/include/linux/vmstat.h
===================================================================
--- linux-2.6.27-rc1-mmotm-30jul.orig/include/linux/vmstat.h	2008-07-30 13:26:08.000000000 -0400
+++ linux-2.6.27-rc1-mmotm-30jul/include/linux/vmstat.h	2008-07-30 13:40:43.000000000 -0400
@@ -45,6 +45,10 @@ enum vm_event_item { PGPGIN, PGPGOUT, PS
 		UNEVICTABLE_PGCULLED,	/* culled to noreclaim list */
 		UNEVICTABLE_PGSCANNED,	/* scanned for reclaimability */
 		UNEVICTABLE_PGRESCUED,	/* rescued from noreclaim list */
+		UNEVICTABLE_PGMLOCKED,
+		UNEVICTABLE_PGMUNLOCKED,
+		UNEVICTABLE_PGCLEARED,	/* on COW, page truncate */
+		UNEVICTABLE_PGSTRANDED,	/* unable to isolate on unlock */
 #endif
 		NR_VM_EVENT_ITEMS
 };
Index: linux-2.6.27-rc1-mmotm-30jul/mm/mlock.c
===================================================================
--- linux-2.6.27-rc1-mmotm-30jul.orig/mm/mlock.c	2008-07-30 13:36:17.000000000 -0400
+++ linux-2.6.27-rc1-mmotm-30jul/mm/mlock.c	2008-07-30 13:47:04.000000000 -0400
@@ -61,6 +61,7 @@ void __clear_page_mlock(struct page *pag
 	}
 
 	dec_zone_page_state(page, NR_MLOCK);
+	count_vm_event(UNEVICTABLE_PGCLEARED);
 	if (!isolate_lru_page(page)) {
 		putback_lru_page(page);
 	} else {
@@ -70,6 +71,9 @@ void __clear_page_mlock(struct page *pag
 		lru_add_drain_all();
 		if (!isolate_lru_page(page))
 			putback_lru_page(page);
+		else if (PageUnevictable(page))
+			count_vm_event(UNEVICTABLE_PGSTRANDED);
+
 	}
 }
 
@@ -83,6 +87,7 @@ void mlock_vma_page(struct page *page)
 
 	if (!TestSetPageMlocked(page)) {
 		inc_zone_page_state(page, NR_MLOCK);
+		count_vm_event(UNEVICTABLE_PGMLOCKED);
 		if (!isolate_lru_page(page))
 			putback_lru_page(page);
 	}
@@ -113,16 +118,28 @@ static void munlock_vma_page(struct page
 	if (TestClearPageMlocked(page)) {
 		dec_zone_page_state(page, NR_MLOCK);
 		if (!isolate_lru_page(page)) {
-			try_to_munlock(page);	/* maybe relock the page */
+			int ret = try_to_munlock(page);
+			/*
+			 * did try_to_unlock() succeed or punt?
+			 */
+			if (ret == SWAP_SUCCESS || ret == SWAP_AGAIN)
+				count_vm_event(UNEVICTABLE_PGMUNLOCKED);
+
 			putback_lru_page(page);
+		} else {
+			/*
+			 * We lost the race.  let try_to_unmap() deal
+			 * with it.  At least we get the page state and
+			 * mlock stats right.  However, page is still on
+			 * the noreclaim list.  We'll fix that up when
+			 * the page is eventually freed or we scan the
+			 * noreclaim list.
+			 */
+			if (PageUnevictable(page))
+				count_vm_event(UNEVICTABLE_PGSTRANDED);
+			else
+				count_vm_event(UNEVICTABLE_PGMUNLOCKED);
 		}
-		/*
-		 * Else we lost the race.  let try_to_unmap() deal with it.
-		 * At least we get the page state and mlock stats right.
-		 * However, page is still on the noreclaim list.  We'll fix
-		 * that up when the page is eventually freed or we scan the
-		 * noreclaim list.
-		 */
 	}
 }
 
Index: linux-2.6.27-rc1-mmotm-30jul/mm/vmstat.c
===================================================================
--- linux-2.6.27-rc1-mmotm-30jul.orig/mm/vmstat.c	2008-07-30 13:36:17.000000000 -0400
+++ linux-2.6.27-rc1-mmotm-30jul/mm/vmstat.c	2008-07-30 13:48:12.000000000 -0400
@@ -668,6 +668,10 @@ static const char * const vmstat_text[] 
 	"unevictable_pgs_culled",
 	"unevictable_pgs_scanned",
 	"unevictable_pgs_rescued",
+	"unevictable_pgs_mlocked",
+	"unevictable_pgs_munlocked",
+	"unevictable_pgs_cleared",
+	"unevictable_pgs_stranded",
 #endif
 #endif
 };
Index: linux-2.6.27-rc1-mmotm-30jul/mm/internal.h
===================================================================
--- linux-2.6.27-rc1-mmotm-30jul.orig/mm/internal.h	2008-07-30 13:36:17.000000000 -0400
+++ linux-2.6.27-rc1-mmotm-30jul/mm/internal.h	2008-07-30 13:46:31.000000000 -0400
@@ -101,8 +101,10 @@ static inline int is_mlocked_vma(struct 
 	if (likely((vma->vm_flags & (VM_LOCKED | VM_SPECIAL)) != VM_LOCKED))
 		return 0;
 
-	if (!TestSetPageMlocked(page))
+	if (!TestSetPageMlocked(page)) {
 		inc_zone_page_state(page, NR_MLOCK);
+		count_vm_event(UNEVICTABLE_PGMLOCKED);
+	}
 	return 1;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
