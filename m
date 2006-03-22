From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Message-Id: <20060322223248.12658.9617.sendpatchset@twins.localnet>
In-Reply-To: <20060322223107.12658.14997.sendpatchset@twins.localnet>
References: <20060322223107.12658.14997.sendpatchset@twins.localnet>
Subject: [PATCH 10/34] mm: page-replace-reinsert.patch
Date: Wed, 22 Mar 2006 23:33:20 +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Bob Picco <bob.picco@hp.com>, Andrew Morton <akpm@osdl.org>, IWAMOTO Toshihiro <iwamoto@valinux.co.jp>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Christoph Lameter <christoph@lameter.com>, Wu Fengguang <wfg@mail.ustc.edu.cn>, Nick Piggin <npiggin@suse.de>, Linus Torvalds <torvalds@osdl.org>, Rik van Riel <riel@redhat.com>, Marcelo Tosatti <marcelo.tosatti@cyclades.com>
List-ID: <linux-mm.kvack.org>

From: Peter Zijlstra <a.p.zijlstra@chello.nl>

API:
	void page_replace_reinsert(struct list_head*);

reinserts pages taken with page_replace_isolate().
NOTE: these pages still have their reclaim page state and so can be
inserted at the proper place.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Signed-off-by: Marcelo Tosatti <marcelo.tosatti@cyclades.com>

---

 include/linux/mm_page_replace.h |    2 +-
 mm/mempolicy.c                  |    6 +++---
 mm/useonce.c                    |   11 +++++++++++
 mm/vmscan.c                     |   26 --------------------------
 4 files changed, 15 insertions(+), 30 deletions(-)

Index: linux-2.6-git/include/linux/mm_page_replace.h
===================================================================
--- linux-2.6-git.orig/include/linux/mm_page_replace.h
+++ linux-2.6-git/include/linux/mm_page_replace.h
@@ -86,7 +86,7 @@ typedef enum {
 
 /* reclaim_t page_replace_reclaimable(struct page *); */
 /* int page_replace_activate(struct page *page); */
-
+extern void page_replace_reinsert(struct list_head *);
 
 #ifdef CONFIG_MIGRATION
 extern int page_replace_isolate(struct page *p);
Index: linux-2.6-git/mm/useonce.c
===================================================================
--- linux-2.6-git.orig/mm/useonce.c
+++ linux-2.6-git/mm/useonce.c
@@ -107,6 +107,17 @@ int page_replace_isolate(struct page *pa
 }
 #endif
 
+void page_replace_reinsert(struct list_head *page_list)
+{
+	struct page *page, *page2;
+
+	list_for_each_entry_safe(page, page2, page_list, lru) {
+		list_del(&page->lru);
+		page_replace_add(page);
+		put_page(page);
+	}
+}
+
 /*
  * zone->lru_lock is heavily contended.  Some of the functions that
  * shrink the lists perform better by taking out a batch of pages
Index: linux-2.6-git/mm/vmscan.c
===================================================================
--- linux-2.6-git.orig/mm/vmscan.c
+++ linux-2.6-git/mm/vmscan.c
@@ -509,32 +509,6 @@ keep:
 }
 
 #ifdef CONFIG_MIGRATION
-
-static inline void move_to_lru(struct page *page)
-{
-	list_del(&page->lru);
-	page_replace_add(page);
-	put_page(page);
-}
-
-/*
- * Add isolated pages on the list back to the LRU.
- *
- * returns the number of pages put back.
- */
-int putback_lru_pages(struct list_head *l)
-{
-	struct page *page;
-	struct page *page2;
-	int count = 0;
-
-	list_for_each_entry_safe(page, page2, l, lru) {
-		move_to_lru(page);
-		count++;
-	}
-	return count;
-}
-
 /*
  * Non migratable page
  */
Index: linux-2.6-git/mm/mempolicy.c
===================================================================
--- linux-2.6-git.orig/mm/mempolicy.c
+++ linux-2.6-git/mm/mempolicy.c
@@ -607,7 +607,7 @@ redo:
 	}
 	err = migrate_pages(pagelist, &newlist, &moved, &failed);
 
-	putback_lru_pages(&moved);	/* Call release pages instead ?? */
+	page_replace_reinsert(&moved);	/* Call release pages instead ?? */
 
 	if (err >= 0 && list_empty(&newlist) && !list_empty(pagelist))
 		goto redo;
@@ -648,7 +648,7 @@ int migrate_to_node(struct mm_struct *mm
 	if (!list_empty(&pagelist)) {
 		err = migrate_pages_to(&pagelist, NULL, dest);
 		if (!list_empty(&pagelist))
-			putback_lru_pages(&pagelist);
+			page_replace_reinsert(&pagelist);
 	}
 	return err;
 }
@@ -800,7 +800,7 @@ long do_mbind(unsigned long start, unsig
 			err = -EIO;
 	}
 	if (!list_empty(&pagelist))
-		putback_lru_pages(&pagelist);
+		page_replace_reinsert(&pagelist);
 
 	up_write(&mm->mmap_sem);
 	mpol_free(new);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
