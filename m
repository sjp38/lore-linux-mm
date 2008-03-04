Message-Id: <20080304225226.583970867@redhat.com>
References: <20080304225157.573336066@redhat.com>
Date: Tue, 04 Mar 2008 17:51:58 -0500
From: Rik van Riel <riel@redhat.com>
Subject: [patch 01/20] move isolate_lru_page() to vmscan.c
Content-Disposition: inline; filename=np-01-move-and-rework-isolate_lru_page-v2.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

V1 -> V2 [lts]:
+  fix botched merge -- add back "get_page_unless_zero()"

  From: Nick Piggin <npiggin@suse.de>
  To: Linux Memory Management <linux-mm@kvack.org>
  Subject: [patch 1/4] mm: move and rework isolate_lru_page
  Date:	Mon, 12 Mar 2007 07:38:44 +0100 (CET)

isolate_lru_page logically belongs to be in vmscan.c than migrate.c.

It is tough, because we don't need that function without memory migration
so there is a valid argument to have it in migrate.c. However a subsequent
patch needs to make use of it in the core mm, so we can happily move it
to vmscan.c.

Also, make the function a little more generic by not requiring that it
adds an isolated page to a given list. Callers can do that.

	Note that we now have '__isolate_lru_page()', that does
	something quite different, visible outside of vmscan.c
	for use with memory controller.  Methinks we need to
	rationalize these names/purposes.	--lts

Signed-off-by: Nick Piggin <npiggin@suse.de>
Signed-off-by: Rik van Riel <riel@redhat.com>
Signed-off-by: Lee Schermerhorn <Lee.Schermerhorn@hp.com>

Index: linux-2.6.25-rc3-mm1/include/linux/migrate.h
===================================================================
--- linux-2.6.25-rc3-mm1.orig/include/linux/migrate.h	2007-07-08 19:32:17.000000000 -0400
+++ linux-2.6.25-rc3-mm1/include/linux/migrate.h	2008-03-04 14:43:26.000000000 -0500
@@ -25,7 +25,6 @@ static inline int vma_migratable(struct 
 	return 1;
 }
 
-extern int isolate_lru_page(struct page *p, struct list_head *pagelist);
 extern int putback_lru_pages(struct list_head *l);
 extern int migrate_page(struct address_space *,
 			struct page *, struct page *);
@@ -42,8 +41,6 @@ extern int migrate_vmas(struct mm_struct
 static inline int vma_migratable(struct vm_area_struct *vma)
 					{ return 0; }
 
-static inline int isolate_lru_page(struct page *p, struct list_head *list)
-					{ return -ENOSYS; }
 static inline int putback_lru_pages(struct list_head *l) { return 0; }
 static inline int migrate_pages(struct list_head *l, new_page_t x,
 		unsigned long private) { return -ENOSYS; }
Index: linux-2.6.25-rc3-mm1/mm/internal.h
===================================================================
--- linux-2.6.25-rc3-mm1.orig/mm/internal.h	2008-03-04 14:12:40.000000000 -0500
+++ linux-2.6.25-rc3-mm1/mm/internal.h	2008-03-04 14:43:26.000000000 -0500
@@ -34,6 +34,8 @@ static inline void __put_page(struct pag
 	atomic_dec(&page->_count);
 }
 
+extern int isolate_lru_page(struct page *page);
+
 extern void __init __free_pages_bootmem(struct page *page,
 						unsigned int order);
 
Index: linux-2.6.25-rc3-mm1/mm/migrate.c
===================================================================
--- linux-2.6.25-rc3-mm1.orig/mm/migrate.c	2008-03-04 14:12:52.000000000 -0500
+++ linux-2.6.25-rc3-mm1/mm/migrate.c	2008-03-04 14:43:26.000000000 -0500
@@ -36,36 +36,6 @@
 #define lru_to_page(_head) (list_entry((_head)->prev, struct page, lru))
 
 /*
- * Isolate one page from the LRU lists. If successful put it onto
- * the indicated list with elevated page count.
- *
- * Result:
- *  -EBUSY: page not on LRU list
- *  0: page removed from LRU list and added to the specified list.
- */
-int isolate_lru_page(struct page *page, struct list_head *pagelist)
-{
-	int ret = -EBUSY;
-
-	if (PageLRU(page)) {
-		struct zone *zone = page_zone(page);
-
-		spin_lock_irq(&zone->lru_lock);
-		if (PageLRU(page) && get_page_unless_zero(page)) {
-			ret = 0;
-			ClearPageLRU(page);
-			if (PageActive(page))
-				del_page_from_active_list(zone, page);
-			else
-				del_page_from_inactive_list(zone, page);
-			list_add_tail(&page->lru, pagelist);
-		}
-		spin_unlock_irq(&zone->lru_lock);
-	}
-	return ret;
-}
-
-/*
  * migrate_prep() needs to be called before we start compiling a list of pages
  * to be migrated using isolate_lru_page().
  */
@@ -880,7 +850,9 @@ static int do_move_pages(struct mm_struc
 				!migrate_all)
 			goto put_and_set;
 
-		err = isolate_lru_page(page, &pagelist);
+		err = isolate_lru_page(page);
+		if (!err)
+			list_add_tail(&page->lru, &pagelist);
 put_and_set:
 		/*
 		 * Either remove the duplicate refcount from
Index: linux-2.6.25-rc3-mm1/mm/vmscan.c
===================================================================
--- linux-2.6.25-rc3-mm1.orig/mm/vmscan.c	2008-03-04 14:12:52.000000000 -0500
+++ linux-2.6.25-rc3-mm1/mm/vmscan.c	2008-03-04 14:43:26.000000000 -0500
@@ -829,6 +829,51 @@ static unsigned long clear_active_flags(
 	return nr_active;
 }
 
+/**
+ * isolate_lru_page - tries to isolate a page from its LRU list
+ * @page: page to isolate from its LRU list
+ *
+ * Isolates a @page from an LRU list, clears PageLRU and adjusts the
+ * vmstat statistic corresponding to whatever LRU list the page was on.
+ *
+ * Returns 0 if the page was removed from an LRU list.
+ * Returns -EBUSY if the page was not on an LRU list.
+ *
+ * The returned page will have PageLRU() cleared.  If it was found on
+ * the active list, it will have PageActive set.  That flag may need
+ * to be cleared by the caller before letting the page go.
+ *
+ * The vmstat statistic corresponding to the list on which the page was
+ * found will be decremented.
+ *
+ * Restrictions:
+ * (1) Must be called with an elevated refcount on the page. This is a
+ *     fundamentnal difference from isolate_lru_pages (which is called
+ *     without a stable reference).
+ * (2) the lru_lock must not be held.
+ * (3) interrupts must be enabled.
+ */
+int isolate_lru_page(struct page *page)
+{
+	int ret = -EBUSY;
+
+	if (PageLRU(page)) {
+		struct zone *zone = page_zone(page);
+
+		spin_lock_irq(&zone->lru_lock);
+		if (PageLRU(page) && get_page_unless_zero(page)) {
+			ret = 0;
+			ClearPageLRU(page);
+			if (PageActive(page))
+				del_page_from_active_list(zone, page);
+			else
+				del_page_from_inactive_list(zone, page);
+		}
+		spin_unlock_irq(&zone->lru_lock);
+	}
+	return ret;
+}
+
 /*
  * shrink_inactive_list() is a helper for shrink_zone().  It returns the number
  * of reclaimed pages
Index: linux-2.6.25-rc3-mm1/mm/mempolicy.c
===================================================================
--- linux-2.6.25-rc3-mm1.orig/mm/mempolicy.c	2008-03-04 14:12:52.000000000 -0500
+++ linux-2.6.25-rc3-mm1/mm/mempolicy.c	2008-03-04 14:43:26.000000000 -0500
@@ -93,6 +93,8 @@
 #include <asm/tlbflush.h>
 #include <asm/uaccess.h>
 
+#include "internal.h"
+
 /* Internal flags */
 #define MPOL_MF_DISCONTIG_OK (MPOL_MF_INTERNAL << 0)	/* Skip checks for continuous vmas */
 #define MPOL_MF_INVERT (MPOL_MF_INTERNAL << 1)		/* Invert check for nodemask */
@@ -596,8 +598,11 @@ static void migrate_page_add(struct page
 	/*
 	 * Avoid migrating a page that is shared with others.
 	 */
-	if ((flags & MPOL_MF_MOVE_ALL) || page_mapcount(page) == 1)
-		isolate_lru_page(page, pagelist);
+	if ((flags & MPOL_MF_MOVE_ALL) || page_mapcount(page) == 1) {
+		if (!isolate_lru_page(page)) {
+			list_add_tail(&page->lru, pagelist);
+		}
+	}
 }
 
 static struct page *new_node_page(struct page *page, unsigned long node, int **x)

-- 
All Rights Reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
