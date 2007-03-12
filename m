From: Nick Piggin <npiggin@suse.de>
Message-Id: <20070312042602.5536.59068.sendpatchset@linux.site>
In-Reply-To: <20070312042553.5536.73828.sendpatchset@linux.site>
References: <20070312042553.5536.73828.sendpatchset@linux.site>
Subject: [patch 1/4] mm: move and rework isolate_lru_page
Date: Mon, 12 Mar 2007 07:38:44 +0100 (CET)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux Memory Management <linux-mm@kvack.org>
Cc: Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

isolate_lru_page logically belongs to be in vmscan.c than migrate.c.

It is tough, because we don't need that function without memory migration
so there is a valid argument to have it in migrate.c. However a subsequent
patch needs to make use of it in the core mm, so we can happily move it
to vmscan.c.

Also, make the function a little more generic by not requiring that it
adds an isolated page to a given list. Callers can do that.

Signed-off-by: Nick Piggin <npiggin@suse.de>

 include/linux/migrate.h |    3 ---
 mm/internal.h           |    2 ++
 mm/mempolicy.c          |   10 ++++++++--
 mm/migrate.c            |   48 ++++++++++--------------------------------------
 mm/vmscan.c             |   36 ++++++++++++++++++++++++++++++++++++
 5 files changed, 56 insertions(+), 43 deletions(-)

Index: linux-2.6/include/linux/migrate.h
===================================================================
--- linux-2.6.orig/include/linux/migrate.h
+++ linux-2.6/include/linux/migrate.h
@@ -14,7 +14,6 @@ static inline int vma_migratable(struct 
 }
 
 #ifdef CONFIG_MIGRATION
-extern int isolate_lru_page(struct page *p, struct list_head *pagelist);
 extern int putback_lru_pages(struct list_head *l);
 extern int migrate_page(struct address_space *,
 			struct page *, struct page *);
@@ -29,8 +28,6 @@ extern int migrate_vmas(struct mm_struct
 		unsigned long flags);
 #else
 
-static inline int isolate_lru_page(struct page *p, struct list_head *list)
-					{ return -ENOSYS; }
 static inline int putback_lru_pages(struct list_head *l) { return 0; }
 static inline int migrate_pages(struct list_head *l, new_page_t x,
 		unsigned long private) { return -ENOSYS; }
Index: linux-2.6/mm/internal.h
===================================================================
--- linux-2.6.orig/mm/internal.h
+++ linux-2.6/mm/internal.h
@@ -34,6 +34,8 @@ static inline void __put_page(struct pag
 	atomic_dec(&page->_count);
 }
 
+extern int isolate_lru_page(struct page *page);
+
 extern void fastcall __init __free_pages_bootmem(struct page *page,
 						unsigned int order);
 
Index: linux-2.6/mm/migrate.c
===================================================================
--- linux-2.6.orig/mm/migrate.c
+++ linux-2.6/mm/migrate.c
@@ -34,37 +34,6 @@
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
-		if (PageLRU(page)) {
-			ret = 0;
-			get_page(page);
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
@@ -806,14 +775,17 @@ static int do_move_pages(struct mm_struc
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
Index: linux-2.6/mm/vmscan.c
===================================================================
--- linux-2.6.orig/mm/vmscan.c
+++ linux-2.6/mm/vmscan.c
@@ -658,6 +658,42 @@ static unsigned long isolate_lru_pages(u
 }
 
 /*
+ * Isolate one page from the LRU lists. Must be called with an elevated
+ * refcount on the page, which is a fundamentnal difference from
+ * isolate_lru_pages (which is called without a stable reference).
+ *
+ * The returned page will have PageActive set, depending on whether it was
+ * found on the active list. This flag generally will need to be cleared
+ * by the caller before letting the page go.
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
+/*
  * shrink_inactive_list() is a helper for shrink_zone().  It returns the number
  * of reclaimed pages
  */
Index: linux-2.6/mm/mempolicy.c
===================================================================
--- linux-2.6.orig/mm/mempolicy.c
+++ linux-2.6/mm/mempolicy.c
@@ -93,6 +93,8 @@
 #include <asm/tlbflush.h>
 #include <asm/uaccess.h>
 
+#include "internal.h"
+
 /* Internal flags */
 #define MPOL_MF_DISCONTIG_OK (MPOL_MF_INTERNAL << 0)	/* Skip checks for continuous vmas */
 #define MPOL_MF_INVERT (MPOL_MF_INTERNAL << 1)		/* Invert check for nodemask */
@@ -588,8 +590,12 @@ static void migrate_page_add(struct page
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
