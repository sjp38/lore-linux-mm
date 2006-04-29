Date: Fri, 28 Apr 2006 20:23:17 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Message-Id: <20060429032317.4999.6940.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20060429032246.4999.21714.sendpatchset@schroedinger.engr.sgi.com>
References: <20060429032246.4999.21714.sendpatchset@schroedinger.engr.sgi.com>
Subject: [PATCH 6/7] PM cleanup: Pass "mapping" to migration functions
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>, Christoph Lameter <clameter@sgi.com>, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

page migration: Change handling of address spaces.

Pass a pointer to the address space in which the page is migrated
to all migration function. This avoids repeatedly having to retrieve
the address space pointer from the page and checking it for validity.
The old page mapping will change once migration has gone to a certain
step, so it is less confusing to have the pointer always available.

Move the setting of the mapping and index for the new page into
migrate_pages().

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.17-rc3/mm/migrate.c
===================================================================
--- linux-2.6.17-rc3.orig/mm/migrate.c	2006-04-28 18:12:57.786776854 -0700
+++ linux-2.6.17-rc3/mm/migrate.c	2006-04-28 18:40:22.939488970 -0700
@@ -173,15 +173,11 @@
  * 2 for pages with a mapping
  * 3 for pages with a mapping and PagePrivate set.
  */
-static int migrate_page_move_mapping(struct page *newpage,
-				struct page *page)
+static int migrate_page_move_mapping(struct address_space *mapping,
+		struct page *newpage, struct page *page)
 {
-	struct address_space *mapping = page_mapping(page);
 	struct page **radix_pointer;
 
-	if (!mapping)
-		return -EAGAIN;
-
 	write_lock_irq(&mapping->tree_lock);
 
 	radix_pointer = (struct page **)radix_tree_lookup_slot(
@@ -197,15 +193,8 @@
 
 	/*
 	 * Now we know that no one else is looking at the page.
-	 *
-	 * Certain minimal information about a page must be available
-	 * in order for other subsystems to properly handle the page if they
-	 * find it through the radix tree update before we are finished
-	 * copying the page.
 	 */
 	get_page(newpage);
-	newpage->index = page->index;
-	newpage->mapping = page->mapping;
 	if (PageSwapCache(page)) {
 		SetPageSwapCache(newpage);
 		set_page_private(newpage, page_private(page));
@@ -262,7 +251,8 @@
  ***********************************************************/
 
 /* Always fail migration. Used for mappings that are not movable */
-int fail_migrate_page(struct page *newpage, struct page *page)
+int fail_migrate_page(struct address_space *mapping,
+			struct page *newpage, struct page *page)
 {
 	return -EIO;
 }
@@ -274,13 +264,14 @@
  *
  * Pages are locked upon entry and exit.
  */
-int migrate_page(struct page *newpage, struct page *page)
+int migrate_page(struct address_space *mapping,
+		struct page *newpage, struct page *page)
 {
 	int rc;
 
 	BUG_ON(PageWriteback(page));	/* Writeback must be complete */
 
-	rc = migrate_page_move_mapping(newpage, page);
+	rc = migrate_page_move_mapping(mapping, newpage, page);
 
 	if (rc)
 		return rc;
@@ -305,21 +296,18 @@
  * if the underlying filesystem guarantees that no other references to "page"
  * exist.
  */
-int buffer_migrate_page(struct page *newpage, struct page *page)
+int buffer_migrate_page(struct address_space *mapping,
+		struct page *newpage, struct page *page)
 {
-	struct address_space *mapping = page->mapping;
 	struct buffer_head *bh, *head;
 	int rc;
 
-	if (!mapping)
-		return -EAGAIN;
-
 	if (!page_has_buffers(page))
-		return migrate_page(newpage, page);
+		return migrate_page(mapping, newpage, page);
 
 	head = page_buffers(page);
 
-	rc = migrate_page_move_mapping(newpage, page);
+	rc = migrate_page_move_mapping(mapping, newpage, page);
 
 	if (rc)
 		return rc;
@@ -448,9 +436,6 @@
 			goto next;
 		}
 
-		newpage = lru_to_page(to);
-		lock_page(newpage);
-
 		/*
 		 * Establish swap ptes for anonymous pages or destroy pte
 		 * maps for files.
@@ -473,11 +458,18 @@
 		rc = -EPERM;
 		if (try_to_unmap(page, 1) == SWAP_FAIL)
 			/* A vma has VM_LOCKED set -> permanent failure */
-			goto unlock_both;
+			goto unlock_page;
 
 		rc = -EAGAIN;
 		if (page_mapped(page))
-			goto unlock_both;
+			goto unlock_page;
+
+		newpage = lru_to_page(to);
+		lock_page(newpage);
+		/* Prepare mapping for the new page.*/
+		newpage->index = page->index;
+		newpage->mapping = page->mapping;
+
 		/*
 		 * Pages are properly locked and writeback is complete.
 		 * Try to migrate the page.
@@ -494,7 +486,8 @@
 			 * own migration function. This is the most common
 			 * path for page migration.
 			 */
-			rc = mapping->a_ops->migratepage(newpage, page);
+			rc = mapping->a_ops->migratepage(mapping,
+							newpage, page);
 			goto unlock_both;
                 }
 
@@ -524,7 +517,7 @@
 		 */
 		if (!page_has_buffers(page) ||
 		    try_to_release_page(page, GFP_KERNEL)) {
-			rc = migrate_page(newpage, page);
+			rc = migrate_page(mapping, newpage, page);
 			goto unlock_both;
 		}
 
@@ -553,12 +546,17 @@
 		unlock_page(page);
 
 next:
-		if (rc == -EAGAIN) {
-			retry++;
-		} else if (rc) {
-			/* Permanent failure */
-			list_move(&page->lru, failed);
-			nr_failed++;
+		if (rc) {
+			if (newpage)
+				newpage->mapping = NULL;
+
+			if (rc == -EAGAIN)
+				retry++;
+			else {
+				/* Permanent failure */
+				list_move(&page->lru, failed);
+				nr_failed++;
+			}
 		} else {
 			if (newpage) {
 				/* Successful migration. Return page to LRU */
Index: linux-2.6.17-rc3/include/linux/fs.h
===================================================================
--- linux-2.6.17-rc3.orig/include/linux/fs.h	2006-04-26 19:19:25.000000000 -0700
+++ linux-2.6.17-rc3/include/linux/fs.h	2006-04-28 18:12:58.597273361 -0700
@@ -373,7 +373,8 @@
 	struct page* (*get_xip_page)(struct address_space *, sector_t,
 			int);
 	/* migrate the contents of a page to the specified target */
-	int (*migratepage) (struct page *, struct page *);
+	int (*migratepage) (struct address_space *,
+			struct page *, struct page *);
 };
 
 struct backing_dev_info;
@@ -1768,7 +1769,8 @@
 extern ssize_t simple_read_from_buffer(void __user *, size_t, loff_t *, const void *, size_t);
 
 #ifdef CONFIG_MIGRATION
-extern int buffer_migrate_page(struct page *, struct page *);
+extern int buffer_migrate_page(struct address_space *,
+				struct page *, struct page *);
 #else
 #define buffer_migrate_page NULL
 #endif
Index: linux-2.6.17-rc3/include/linux/migrate.h
===================================================================
--- linux-2.6.17-rc3.orig/include/linux/migrate.h	2006-04-28 18:12:55.854279761 -0700
+++ linux-2.6.17-rc3/include/linux/migrate.h	2006-04-28 18:12:58.598249863 -0700
@@ -7,12 +7,14 @@
 #ifdef CONFIG_MIGRATION
 extern int isolate_lru_page(struct page *p, struct list_head *pagelist);
 extern int putback_lru_pages(struct list_head *l);
-extern int migrate_page(struct page *, struct page *);
+extern int migrate_page(struct address_space *,
+			struct page *, struct page *);
 extern int migrate_pages(struct list_head *l, struct list_head *t,
 		struct list_head *moved, struct list_head *failed);
 extern int migrate_pages_to(struct list_head *pagelist,
 			struct vm_area_struct *vma, int dest);
-extern int fail_migrate_page(struct page *, struct page *);
+extern int fail_migrate_page(struct address_space *,
+			struct page *, struct page *);
 
 extern int migrate_prep(void);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
