From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Date: Fri, 14 Sep 2007 16:54:18 -0400
Message-Id: <20070914205418.6536.5921.sendpatchset@localhost>
In-Reply-To: <20070914205359.6536.98017.sendpatchset@localhost>
References: <20070914205359.6536.98017.sendpatchset@localhost>
Subject: [PATCH/RFC 3/14] Reclaim Scalability:  move isolate_lru_page() to vmscan.c
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, mel@csn.ul.ie, clameter@sgi.com, riel@redhat.com, balbir@linux.vnet.ibm.com, andrea@suse.de, a.p.zijlstra@chello.nl, eric.whitney@hp.com, npiggin@suse.de
List-ID: <linux-mm.kvack.org>

PATCH/RFC 03/14 Reclaim Scalability:  move isolate_lru_page() to vmscan.c

Against 2.6.23-rc4-mm1

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

 include/linux/migrate.h |    3 ---
 mm/internal.h           |    2 ++
 mm/mempolicy.c          |   10 ++++++++--
 mm/migrate.c            |   47 ++++++++++-------------------------------------
 mm/vmscan.c             |   41 +++++++++++++++++++++++++++++++++++++++++
 5 files changed, 61 insertions(+), 42 deletions(-)

Index: Linux/include/linux/migrate.h
===================================================================
--- Linux.orig/include/linux/migrate.h	2007-09-12 16:08:51.000000000 -0400
+++ Linux/include/linux/migrate.h	2007-09-12 16:10:11.000000000 -0400
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
Index: Linux/mm/internal.h
===================================================================
--- Linux.orig/mm/internal.h	2007-09-12 16:08:51.000000000 -0400
+++ Linux/mm/internal.h	2007-09-14 10:17:54.000000000 -0400
@@ -34,6 +34,8 @@ static inline void __put_page(struct pag
 	atomic_dec(&page->_count);
 }
 
+extern int isolate_lru_page(struct page *page);
+
 extern void fastcall __init __free_pages_bootmem(struct page *page,
 						unsigned int order);
 
Index: Linux/mm/migrate.c
===================================================================
--- Linux.orig/mm/migrate.c	2007-09-12 16:10:11.000000000 -0400
+++ Linux/mm/migrate.c	2007-09-14 10:17:54.000000000 -0400
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
@@ -850,14 +820,17 @@ static int do_move_pages(struct mm_struc
 				!migrate_all)
 			goto put_and_set;
 
-		err = isolate_lru_page(page, &pagelist);
+		err = isolate_lru_page(page);
+		if (err) {
 put_and_set:
-		/*
-		 * Either remove the duplicate refcount from
-		 * isolate_lru_page() or drop the page ref if it was
-		 * not isolated.
-		 */
-		put_page(page);
+			/*
+			 * Either remove the duplicate refcount from
+			 * isolate_lru_page() or drop the page ref if it was
+			 * not isolated.
+			 */
+			put_page(page);
+		} else
+			list_add_tail(&page->lru, &pagelist);
 set_status:
 		pp->status = err;
 	}
Index: Linux/mm/vmscan.c
===================================================================
--- Linux.orig/mm/vmscan.c	2007-09-12 16:08:51.000000000 -0400
+++ Linux/mm/vmscan.c	2007-09-14 10:21:38.000000000 -0400
@@ -810,6 +810,47 @@ static unsigned long clear_active_flags(
 	return nr_active;
 }
 
+/**
+ * isolate_lru_page(@page)
+ *
+ * Isolate one @page from the LRU lists. Must be called with an elevated
+ * refcount on the page, which is a fundamentnal difference from
+ * isolate_lru_pages (which is called without a stable reference).
+ *
+ * The returned page will have PageLru() cleared, and PageActive set,
+ * if it was found on the active list. This flag generally will need to be
+ * cleared by the caller before letting the page go.
+ *
+ * The vmstat page counts corresponding to the list on which the page was
+ * found will be decremented.
+ *
+ * lru_lock must not be held, interrupts must be enabled.
+ *
+ * Returns:
+ *  -EBUSY: page not on LRU list
+ *  0: page removed from LRU list.
+ */
+int isolate_lru_page(struct page *page)
+{
+	int ret = -EBUSY;
+
+	if (PageLRU(page)) {
+		struct zone *zone = page_zone(page);
+
+		spin_lock_irq(&zone->lru_lock);
+		if (PageLRU(page)) {
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
Index: Linux/mm/mempolicy.c
===================================================================
--- Linux.orig/mm/mempolicy.c	2007-09-12 16:08:51.000000000 -0400
+++ Linux/mm/mempolicy.c	2007-09-14 10:17:54.000000000 -0400
@@ -93,6 +93,8 @@
 #include <asm/tlbflush.h>
 #include <asm/uaccess.h>
 
+#include "internal.h"
+
 /* Internal flags */
 #define MPOL_MF_DISCONTIG_OK (MPOL_MF_INTERNAL << 0)	/* Skip checks for continuous vmas */
 #define MPOL_MF_INVERT (MPOL_MF_INTERNAL << 1)		/* Invert check for nodemask */
@@ -593,8 +595,12 @@ static void migrate_page_add(struct page
 	/*
 	 * Avoid migrating a page that is shared with others.
 	 */
-	if ((flags & MPOL_MF_MOVE_ALL) || page_mapcount(page) == 1)
-		isolate_lru_page(page, pagelist);
+	if ((flags & MPOL_MF_MOVE_ALL) || page_mapcount(page) == 1) {
+		if (!isolate_lru_page(page)) {
+			get_page(page);
+			list_add_tail(&page->lru, pagelist);
+		}
+	}
 }
 
 static struct page *new_node_page(struct page *page, unsigned long node, int **x)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
