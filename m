Date: Fri, 17 Mar 2006 11:10:32 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: page migration reorg cleanup
Message-ID: <Pine.LNX.4.64.0603171109120.10226@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

- Fix up the #ifdeffery in mempoliy.c

- add migrate_prep() function to migrate.h

- add list parameter back to isolate_lru_page()

- allow use of migrate_pages_to() without CONFIG_NUMA

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.16-rc6/mm/mempolicy.c
===================================================================
--- linux-2.6.16-rc6.orig/mm/mempolicy.c	2006-03-17 10:55:11.000000000 -0800
+++ linux-2.6.16-rc6/mm/mempolicy.c	2006-03-17 10:58:23.000000000 -0800
@@ -329,21 +329,10 @@ check_range(struct mm_struct *mm, unsign
 	struct vm_area_struct *first, *vma, *prev;
 
 	if (flags & (MPOL_MF_MOVE | MPOL_MF_MOVE_ALL)) {
-#ifdef CONFIG_MIGRATION
-		/* Must have swap device for migration */
-		if (nr_swap_pages <= 0)
-			return ERR_PTR(-ENODEV);
 
-		/*
-		 * Clear the LRU lists so pages can be isolated.
-		 * Note that pages may be moved off the LRU after we have
-		 * drained them. Those pages will fail to migrate like other
-		 * pages that may be busy.
-		 */
-		lru_add_drain_all();
-#else
-		return -ENOSYS;
-#endif
+		err = migrate_prep();
+		if (err)
+			return ERR_PTR(err);
 	}
 
 	first = find_vma(mm, start);
@@ -552,24 +541,20 @@ long do_get_mempolicy(int *policy, nodem
 	return err;
 }
 
+#ifdef CONFIG_MIGRATION
 /*
  * page migration
  */
 static void migrate_page_add(struct page *page, struct list_head *pagelist,
 				unsigned long flags)
 {
-#ifdef CONFIG_MIGRATION
 	/*
 	 * Avoid migrating a page that is shared with others.
 	 */
-	if ((flags & MPOL_MF_MOVE_ALL) || page_mapcount(page) == 1) {
-		if (isolate_lru_page(page))
-			list_add_tail(&page->lru, pagelist);
-	}
-#endif
+	if ((flags & MPOL_MF_MOVE_ALL) || page_mapcount(page) == 1)
+		isolate_lru_page(page, pagelist);
 }
 
-#ifdef CONFIG_MIGRATION
 /*
  * Migrate pages from one node to a target node.
  * Returns error or the number of pages not migrated.
@@ -593,7 +578,6 @@ int migrate_to_node(struct mm_struct *mm
 	}
 	return err;
 }
-#endif
 
 /*
  * Move pages between the two nodesets so as to preserve the physical
@@ -604,7 +588,6 @@ int migrate_to_node(struct mm_struct *mm
 int do_migrate_pages(struct mm_struct *mm,
 	const nodemask_t *from_nodes, const nodemask_t *to_nodes, int flags)
 {
-#ifdef CONFIG_MIGRATION
 	LIST_HEAD(pagelist);
 	int busy = 0;
 	int err = 0;
@@ -676,10 +659,22 @@ int do_migrate_pages(struct mm_struct *m
 	if (err < 0)
 		return err;
 	return busy;
+
+}
+
 #else
+
+static void migrate_page_add(struct page *page, struct list_head *pagelist,
+				unsigned long flags)
+{
+}
+
+int do_migrate_pages(struct mm_struct *mm,
+	const nodemask_t *from_nodes, const nodemask_t *to_nodes, int flags)
+{
 	return -ENOSYS;
-#endif
 }
+#endif
 
 long do_mbind(unsigned long start, unsigned long len,
 		unsigned long mode, nodemask_t *nmask, unsigned long flags)
@@ -739,10 +734,8 @@ long do_mbind(unsigned long start, unsig
 
 		err = mbind_range(vma, start, end, new);
 
-#ifdef CONFIG_MIGRATION
 		if (!list_empty(&pagelist))
 			nr_failed = migrate_pages_to(&pagelist, vma, -1);
-#endif
 
 		if (!err && nr_failed && (flags & MPOL_MF_STRICT))
 			err = -EIO;
Index: linux-2.6.16-rc6/mm/migrate.c
===================================================================
--- linux-2.6.16-rc6.orig/mm/migrate.c	2006-03-17 10:55:11.000000000 -0800
+++ linux-2.6.16-rc6/mm/migrate.c	2006-03-17 11:04:56.000000000 -0800
@@ -26,11 +26,66 @@
 #include <linux/cpuset.h>
 #include <linux/swapops.h>
 
+#include "internal.h"
+
 /* The maximum number of pages to take off the LRU for migration */
 #define MIGRATE_CHUNK_SIZE 256
 
 #define lru_to_page(_head) (list_entry((_head)->prev, struct page, lru))
 
+/*
+ * Isolate one page from the LRU lists. If successful put it onto
+ * the indicated list with elevated page count.
+ *
+ * Result:
+ *  0 = page not on LRU list
+ *  1 = page removed from LRU list and added to the specified list.
+ */
+int isolate_lru_page(struct page *page, struct list_head *pagelist)
+{
+	int ret = -EBUSY;
+
+	if (PageLRU(page)) {
+		struct zone *zone = page_zone(page);
+
+		spin_lock_irq(&zone->lru_lock);
+		if (PageLRU(page)) {
+			ret = 0;
+			get_page(page);
+			ClearPageLRU(page);
+			if (PageActive(page))
+				del_page_from_active_list(zone, page);
+			else
+				del_page_from_inactive_list(zone, page);
+			list_add_tail(&page->lru, pagelist);
+		}
+		spin_unlock_irq(&zone->lru_lock);
+	}
+	return ret;
+}
+
+/*
+ * migrate_prep() needs to be called after we have compiled the list of pages
+ * to be migrated using isolate_lru_page() but before we begin a series of calls
+ * to migrate_pages().
+ */
+int migrate_prep(void)
+{
+	/* Must have swap device for migration */
+	if (nr_swap_pages <= 0)
+		return -ENODEV;
+
+	/*
+	 * Clear the LRU lists so pages can be isolated.
+	 * Note that pages may be moved off the LRU after we have
+	 * drained them. Those pages will fail to migrate like other
+	 * pages that may be busy.
+	 */
+	lru_add_drain_all();
+
+	return 0;
+}
+
 static inline void move_to_lru(struct page *page)
 {
 	list_del(&page->lru);
@@ -465,35 +520,6 @@ next:
 }
 
 /*
- * Isolate one page from the LRU lists and put it on the
- * indicated list with elevated refcount.
- *
- * Result:
- *  0 = page not on LRU list
- *  1 = page removed from LRU list and added to the specified list.
- */
-int isolate_lru_page(struct page *page)
-{
-	int ret = 0;
-
-	if (PageLRU(page)) {
-		struct zone *zone = page_zone(page);
-		spin_lock_irq(&zone->lru_lock);
-		if (TestClearPageLRU(page)) {
-			ret = 1;
-			get_page(page);
-			if (PageActive(page))
-				del_page_from_active_list(zone, page);
-			else
-				del_page_from_inactive_list(zone, page);
-		}
-		spin_unlock_irq(&zone->lru_lock);
-	}
-
-	return ret;
-}
-
-/*
  * Migration function for pages with buffers. This function can only be used
  * if the underlying filesystem guarantees that no other references to "page"
  * exist.
@@ -554,7 +580,6 @@ int buffer_migrate_page(struct page *new
 }
 EXPORT_SYMBOL(buffer_migrate_page);
 
-#ifdef CONFIG_NUMA
 /*
  * Migrate the list 'pagelist' of pages to a certain destination.
  *
@@ -626,4 +651,3 @@ out:
 		nr_pages++;
 	return nr_pages;
 }
-#endif
Index: linux-2.6.16-rc6/include/linux/migrate.h
===================================================================
--- linux-2.6.16-rc6.orig/include/linux/migrate.h	2006-03-17 10:55:11.000000000 -0800
+++ linux-2.6.16-rc6/include/linux/migrate.h	2006-03-17 10:58:23.000000000 -0800
@@ -5,7 +5,7 @@
 #include <linux/mm.h>
 
 #ifdef CONFIG_MIGRATION
-extern int isolate_lru_page(struct page *p);
+extern int isolate_lru_page(struct page *p, struct list_head *pagelist);
 extern int putback_lru_pages(struct list_head *l);
 extern int migrate_page(struct page *, struct page *);
 extern void migrate_page_copy(struct page *, struct page *);
@@ -16,13 +16,18 @@ int migrate_pages_to(struct list_head *p
 			struct vm_area_struct *vma, int dest);
 extern int fail_migrate_page(struct page *, struct page *);
 
+extern int migrate_prep(void);
+
 #else
 
-static inline int isolate_lru_page(struct page *p) { return -ENOSYS; }
+static inline int isolate_lru_page(struct page *p, struct list_head *list)
+					{ return -ENOSYS; }
 static inline int putback_lru_pages(struct list_head *l) { return 0; }
 static inline int migrate_pages(struct list_head *l, struct list_head *t,
 	struct list_head *moved, struct list_head *failed) { return -ENOSYS; }
 
+static inline int migrate_prep(void) { return -ENOSYS; }
+
 /* Possible settings for the migrate_page() method in address_operations */
 #define migrate_page NULL
 #define fail_migrate_page NULL

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
