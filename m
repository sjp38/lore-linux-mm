Date: Thu, 27 Apr 2006 23:03:12 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Message-Id: <20060428060312.30257.16842.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20060428060302.30257.76871.sendpatchset@schroedinger.engr.sgi.com>
References: <20060428060302.30257.76871.sendpatchset@schroedinger.engr.sgi.com>
Subject: [PATCH 3/7] page migration: Change handling of address spaces
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

Move the handling the mapping and index for the new page into
migrate_pages() in order to have stable mappings early
during migration.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.17-rc2-mm1/mm/migrate.c
===================================================================
--- linux-2.6.17-rc2-mm1.orig/mm/migrate.c	2006-04-27 21:11:49.278491812 -0700
+++ linux-2.6.17-rc2-mm1/mm/migrate.c	2006-04-27 21:32:18.134185419 -0700
@@ -250,10 +250,9 @@
  * the page can be blocked. Establish the new page
  * with the basic settings to be able to stop accesses to the page.
  */
-static int migrate_page_remove_references(struct page *newpage,
-				struct page *page, int nr_refs)
+static int migrate_page_remove_references(struct address_space *mapping,
+		struct page *newpage, struct page *page, int nr_refs)
 {
-	struct address_space *mapping = page_mapping(page);
 	struct page **radix_pointer;
 
 	/*
@@ -297,9 +296,6 @@
 		if (page_count(page) != nr_refs)
 			return -EAGAIN;
 
-		/* We are holding the only remaining reference */
-		newpage->index = page->index;
-		newpage->mapping = page->mapping;
 		return 0;
 	}
 
@@ -320,15 +316,8 @@
 
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
 
 #ifdef CONFIG_SWAP
 	if (PageSwapCache(page)) {
@@ -389,7 +378,8 @@
  *                    Migration functions
  ***********************************************************/
 
-int fail_migrate_page(struct page *newpage, struct page *page)
+int fail_migrate_page(struct address_space *mapping,
+			struct page *newpage, struct page *page)
 {
 	return -EIO;
 }
@@ -398,14 +388,15 @@
 /*
  * migrate a page that does not use PagePrivate.
  */
-int migrate_page(struct page *newpage, struct page *page)
+int migrate_page(struct address_space *mapping,
+		struct page *newpage, struct page *page)
 {
 	int rc;
 
 	BUG_ON(PageWriteback(page));	/* Writeback must be complete */
 
-	rc = migrate_page_remove_references(newpage, page,
-			page_mapping(page) ? 2 : 1);
+	rc = migrate_page_remove_references(mapping, newpage, page,
+			mapping ? 2 : 1);
 
 	if (rc) {
 		remove_migration_ptes(page, page);
@@ -423,21 +414,18 @@
  * if the underlying filesystem guarantees that no other references to "page"
  * exist.
  */
-int buffer_migrate_page(struct page *newpage, struct page *page)
+int buffer_migrate_page(struct address_space *mapping,
+			struct page *newpage, struct page *page)
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
 
-	rc = migrate_page_remove_references(newpage, page, 3);
+	rc = migrate_page_remove_references(mapping, newpage, page, 3);
 
 	if (rc)
 		return rc;
@@ -550,6 +538,9 @@
 
 		newpage = lru_to_page(to);
 		lock_page(newpage);
+		/* Prepare mapping for the new page.*/
+		newpage->index = page->index;
+		newpage->mapping = page->mapping;
 
 		/*
 		 * Pages are properly locked and writeback is complete.
@@ -557,7 +548,7 @@
 		 */
 		mapping = page_mapping(page);
 		if (!mapping) {
-			rc = migrate_page(newpage, page);
+			rc = migrate_page(mapping, newpage, page);
 			goto unlock_both;
 
 		} else
@@ -569,7 +560,8 @@
 			 * own migration function. This is the most common
 			 * path for page migration.
 			 */
-			rc = mapping->a_ops->migratepage(newpage, page);
+			rc = mapping->a_ops->migratepage(mapping,
+							newpage, page);
 			goto unlock_both;
                 }
 
@@ -599,7 +591,7 @@
 		 */
 		if (!page_has_buffers(page) ||
 		    try_to_release_page(page, GFP_KERNEL)) {
-			rc = migrate_page(newpage, page);
+			rc = migrate_page(mapping, newpage, page);
 			goto unlock_both;
 		}
 
@@ -610,12 +602,15 @@
 		unlock_page(page);
 
 next:
-		if (rc == -EAGAIN) {
-			retry++;
-		} else if (rc) {
-			/* Permanent failure */
-			list_move(&page->lru, failed);
-			nr_failed++;
+		if (rc) {
+			newpage->mapping = NULL;
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
Index: linux-2.6.17-rc2-mm1/include/linux/fs.h
===================================================================
--- linux-2.6.17-rc2-mm1.orig/include/linux/fs.h	2006-04-27 19:24:02.006521419 -0700
+++ linux-2.6.17-rc2-mm1/include/linux/fs.h	2006-04-27 21:15:09.388268028 -0700
@@ -373,7 +373,8 @@
 	struct page* (*get_xip_page)(struct address_space *, sector_t,
 			int);
 	/* migrate the contents of a page to the specified target */
-	int (*migratepage) (struct page *, struct page *);
+	int (*migratepage) (struct address_space *,
+			struct page *, struct page *);
 };
 
 struct backing_dev_info;
@@ -1773,7 +1774,8 @@
 extern ssize_t simple_read_from_buffer(void __user *, size_t, loff_t *, const void *, size_t);
 
 #ifdef CONFIG_MIGRATION
-extern int buffer_migrate_page(struct page *, struct page *);
+extern int buffer_migrate_page(struct address_space *,
+				struct page *, struct page *);
 #else
 #define buffer_migrate_page NULL
 #endif
Index: linux-2.6.17-rc2-mm1/include/linux/migrate.h
===================================================================
--- linux-2.6.17-rc2-mm1.orig/include/linux/migrate.h	2006-04-27 21:11:49.389813099 -0700
+++ linux-2.6.17-rc2-mm1/include/linux/migrate.h	2006-04-27 21:15:09.389244530 -0700
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
