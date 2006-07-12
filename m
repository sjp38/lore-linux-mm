From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Wed, 12 Jul 2006 16:40:15 +0200
Message-Id: <20060712144015.16998.39544.sendpatchset@lappy>
In-Reply-To: <20060712143659.16998.6444.sendpatchset@lappy>
References: <20060712143659.16998.6444.sendpatchset@lappy>
Subject: [PATCH 17/39] mm: pgrep: re-insertion logic
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

From: Peter Zijlstra <a.p.zijlstra@chello.nl>

API:

reinserts pages taken with isolate_lru_page() - use by page mirgration.

	void pgrep_reinsert(struct list_head*);

NOTE: these pages still have their reclaim page state and so can be
inserted at the proper place.

NOTE: this patch seems quite useless with the current use-once policy,
however for other policies re-insertion (where the page state is conserved)
is quite different from regular insertion (where the page state is set by
insertion hints).

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Signed-off-by: Marcelo Tosatti <marcelo.tosatti@cyclades.com>

 include/linux/migrate.h         |    2 --
 include/linux/mm_page_replace.h |    2 +-
 mm/mempolicy.c                  |    4 ++--
 mm/migrate.c                    |   29 +----------------------------
 mm/useonce.c                    |   10 ++++++++++
 5 files changed, 14 insertions(+), 33 deletions(-)

Index: linux-2.6/include/linux/mm_page_replace.h
===================================================================
--- linux-2.6.orig/include/linux/mm_page_replace.h	2006-07-12 16:09:18.000000000 +0200
+++ linux-2.6/include/linux/mm_page_replace.h	2006-07-12 16:11:41.000000000 +0200
@@ -84,7 +84,7 @@ extern unsigned long pgrep_shrink_zone(i
 /* void pgrep_clear_state(struct page *); */
 /* int pgrep_is_active(struct page *); */
 /* void __pgrep_remove(struct zone *zone, struct page *page); */
-
+extern void pgrep_reinsert(struct list_head *);
 
 #ifdef CONFIG_MM_POLICY_USEONCE
 #include <linux/mm_use_once_policy.h>
Index: linux-2.6/mm/useonce.c
===================================================================
--- linux-2.6.orig/mm/useonce.c	2006-07-12 16:09:18.000000000 +0200
+++ linux-2.6/mm/useonce.c	2006-07-12 16:11:41.000000000 +0200
@@ -52,6 +52,16 @@ void __pgrep_add_drain(unsigned int cpu)
 		__pagevec_pgrep_add(pvec);
 }
 
+void pgrep_reinsert(struct list_head *page_list)
+{
+	struct page *page, *page2;
+
+	list_for_each_entry_safe(page, page2, page_list, lru) {
+		list_del(&page->lru);
+		pgrep_add(page);
+		put_page(page);
+	}
+}
 /*
  * shrink_inactive_list() is a helper for shrink_zone().  It returns the number
  * of reclaimed pages
Index: linux-2.6/mm/mempolicy.c
===================================================================
--- linux-2.6.orig/mm/mempolicy.c	2006-07-12 16:09:18.000000000 +0200
+++ linux-2.6/mm/mempolicy.c	2006-07-12 16:09:18.000000000 +0200
@@ -607,7 +607,7 @@ int migrate_to_node(struct mm_struct *mm
 	if (!list_empty(&pagelist)) {
 		err = migrate_pages_to(&pagelist, NULL, dest);
 		if (!list_empty(&pagelist))
-			putback_lru_pages(&pagelist);
+			pgrep_reinsert(&pagelist);
 	}
 	return err;
 }
@@ -775,7 +775,7 @@ long do_mbind(unsigned long start, unsig
 	}
 
 	if (!list_empty(&pagelist))
-		putback_lru_pages(&pagelist);
+		pgrep_reinsert(&pagelist);
 
 	up_write(&mm->mmap_sem);
 	mpol_free(new);
Index: linux-2.6/include/linux/migrate.h
===================================================================
--- linux-2.6.orig/include/linux/migrate.h	2006-07-12 16:07:29.000000000 +0200
+++ linux-2.6/include/linux/migrate.h	2006-07-12 16:09:18.000000000 +0200
@@ -6,7 +6,6 @@
 
 #ifdef CONFIG_MIGRATION
 extern int isolate_lru_page(struct page *p, struct list_head *pagelist);
-extern int putback_lru_pages(struct list_head *l);
 extern int migrate_page(struct page *, struct page *);
 extern void migrate_page_copy(struct page *, struct page *);
 extern int migrate_page_remove_references(struct page *, struct page *, int);
@@ -22,7 +21,6 @@ extern int migrate_prep(void);
 
 static inline int isolate_lru_page(struct page *p, struct list_head *list)
 					{ return -ENOSYS; }
-static inline int putback_lru_pages(struct list_head *l) { return 0; }
 static inline int migrate_pages(struct list_head *l, struct list_head *t,
 	struct list_head *moved, struct list_head *failed) { return -ENOSYS; }
 
Index: linux-2.6/mm/migrate.c
===================================================================
--- linux-2.6.orig/mm/migrate.c	2006-07-12 16:09:18.000000000 +0200
+++ linux-2.6/mm/migrate.c	2006-07-12 16:09:18.000000000 +0200
@@ -25,8 +25,6 @@
 #include <linux/swapops.h>
 #include <linux/mm_page_replace.h>
 
-#include "internal.h"
-
 /* The maximum number of pages to take off the LRU for migration */
 #define MIGRATE_CHUNK_SIZE 256
 
@@ -82,31 +80,6 @@ int migrate_prep(void)
 	return 0;
 }
 
-static inline void move_to_lru(struct page *page)
-{
-	list_del(&page->lru);
-	pgrep_add(page);
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
@@ -626,7 +599,7 @@ redo:
 	}
 	err = migrate_pages(pagelist, &newlist, &moved, &failed);
 
-	putback_lru_pages(&moved);	/* Call release pages instead ?? */
+	pgrep_reinsert(&moved);	/* Call release pages instead ?? */
 
 	if (err >= 0 && list_empty(&newlist) && !list_empty(pagelist))
 		goto redo;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
