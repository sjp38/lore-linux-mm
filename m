Date: Thu, 27 Apr 2006 23:03:02 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Message-Id: <20060428060302.30257.76871.sendpatchset@schroedinger.engr.sgi.com>
Subject: [PATCH 1/7] page migration: Reorder functions in migrate.c
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>, Christoph Lameter <clameter@sgi.com>, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

page migration: Reorder functions in migrate.c

Build a group of migration functions that can be used for
struct address_operations.

Group remove_migration_pte() and remove_migration_ptes() together.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.17-rc2-mm1/mm/migrate.c
===================================================================
--- linux-2.6.17-rc2-mm1.orig/mm/migrate.c	2006-04-27 19:24:03.576736398 -0700
+++ linux-2.6.17-rc2-mm1/mm/migrate.c	2006-04-27 19:28:57.347549552 -0700
@@ -177,6 +177,37 @@
 }
 
 /*
+ * Get rid of all migration entries and replace them by
+ * references to the indicated page.
+ *
+ * Must hold mmap_sem lock on at least one of the vmas containing
+ * the page so that the anon_vma cannot vanish.
+ */
+static void remove_migration_ptes(struct page *old, struct page *new)
+{
+	struct anon_vma *anon_vma;
+	struct vm_area_struct *vma;
+	unsigned long mapping;
+
+	mapping = (unsigned long)new->mapping;
+
+	if (!mapping || (mapping & PAGE_MAPPING_ANON) == 0)
+		return;
+
+	/*
+	 * We hold the mmap_sem lock. So no need to call page_lock_anon_vma.
+	 */
+	anon_vma = (struct anon_vma *) (mapping - PAGE_MAPPING_ANON);
+	spin_lock(&anon_vma->lock);
+
+	list_for_each_entry(vma, &anon_vma->head, anon_vma_node)
+		remove_migration_pte(vma, page_address_in_vma(new, vma),
+					old, new);
+
+	spin_unlock(&anon_vma->lock);
+}
+
+/*
  * Something used the pte of a page under migration. We need to
  * get to the page and wait until migration is finished.
  * When we return from this function the fault will be retried.
@@ -215,46 +246,6 @@
 }
 
 /*
- * Get rid of all migration entries and replace them by
- * references to the indicated page.
- *
- * Must hold mmap_sem lock on at least one of the vmas containing
- * the page so that the anon_vma cannot vanish.
- */
-static void remove_migration_ptes(struct page *old, struct page *new)
-{
-	struct anon_vma *anon_vma;
-	struct vm_area_struct *vma;
-	unsigned long mapping;
-
-	mapping = (unsigned long)new->mapping;
-
-	if (!mapping || (mapping & PAGE_MAPPING_ANON) == 0)
-		return;
-
-	/*
-	 * We hold the mmap_sem lock. So no need to call page_lock_anon_vma.
-	 */
-	anon_vma = (struct anon_vma *) (mapping - PAGE_MAPPING_ANON);
-	spin_lock(&anon_vma->lock);
-
-	list_for_each_entry(vma, &anon_vma->head, anon_vma_node)
-		remove_migration_pte(vma, page_address_in_vma(new, vma),
-					old, new);
-
-	spin_unlock(&anon_vma->lock);
-}
-
-/*
- * Non migratable page
- */
-int fail_migrate_page(struct page *newpage, struct page *page)
-{
-	return -EIO;
-}
-EXPORT_SYMBOL(fail_migrate_page);
-
-/*
  * Remove or replace all references to a page so that future accesses to
  * the page can be blocked. Establish the new page
  * with the basic settings to be able to stop accesses to the page.
@@ -396,11 +387,18 @@
 }
 EXPORT_SYMBOL(migrate_page_copy);
 
+/************************************************************
+ *                    Migration functions
+ ***********************************************************/
+
+int fail_migrate_page(struct page *newpage, struct page *page)
+{
+	return -EIO;
+}
+EXPORT_SYMBOL(fail_migrate_page);
+
 /*
- * Common logic to directly migrate a single page suitable for
- * pages that do not use PagePrivate.
- *
- * Pages are locked upon entry and exit.
+ * migrate a page that does not use PagePrivate.
  */
 int migrate_page(struct page *newpage, struct page *page)
 {
@@ -423,6 +421,67 @@
 EXPORT_SYMBOL(migrate_page);
 
 /*
+ * Migration function for pages with buffers. This function can only be used
+ * if the underlying filesystem guarantees that no other references to "page"
+ * exist.
+ */
+int buffer_migrate_page(struct page *newpage, struct page *page)
+{
+	struct address_space *mapping = page->mapping;
+	struct buffer_head *bh, *head;
+	int rc;
+
+	if (!mapping)
+		return -EAGAIN;
+
+	if (!page_has_buffers(page))
+		return migrate_page(newpage, page);
+
+	head = page_buffers(page);
+
+	rc = migrate_page_remove_references(newpage, page, 3);
+
+	if (rc)
+		return rc;
+
+	bh = head;
+	do {
+		get_bh(bh);
+		lock_buffer(bh);
+		bh = bh->b_this_page;
+
+	} while (bh != head);
+
+	ClearPagePrivate(page);
+	set_page_private(newpage, page_private(page));
+	set_page_private(page, 0);
+	put_page(page);
+	get_page(newpage);
+
+	bh = head;
+	do {
+		set_bh_page(bh, newpage, bh_offset(bh));
+		bh = bh->b_this_page;
+
+	} while (bh != head);
+
+	SetPagePrivate(newpage);
+
+	migrate_page_copy(newpage, page);
+
+	bh = head;
+	do {
+		unlock_buffer(bh);
+ 		put_bh(bh);
+		bh = bh->b_this_page;
+
+	} while (bh != head);
+
+	return 0;
+}
+EXPORT_SYMBOL(buffer_migrate_page);
+
+/*
  * migrate_pages
  *
  * Two lists are passed to this function. The first list
@@ -577,67 +636,6 @@
 }
 
 /*
- * Migration function for pages with buffers. This function can only be used
- * if the underlying filesystem guarantees that no other references to "page"
- * exist.
- */
-int buffer_migrate_page(struct page *newpage, struct page *page)
-{
-	struct address_space *mapping = page->mapping;
-	struct buffer_head *bh, *head;
-	int rc;
-
-	if (!mapping)
-		return -EAGAIN;
-
-	if (!page_has_buffers(page))
-		return migrate_page(newpage, page);
-
-	head = page_buffers(page);
-
-	rc = migrate_page_remove_references(newpage, page, 3);
-
-	if (rc)
-		return rc;
-
-	bh = head;
-	do {
-		get_bh(bh);
-		lock_buffer(bh);
-		bh = bh->b_this_page;
-
-	} while (bh != head);
-
-	ClearPagePrivate(page);
-	set_page_private(newpage, page_private(page));
-	set_page_private(page, 0);
-	put_page(page);
-	get_page(newpage);
-
-	bh = head;
-	do {
-		set_bh_page(bh, newpage, bh_offset(bh));
-		bh = bh->b_this_page;
-
-	} while (bh != head);
-
-	SetPagePrivate(newpage);
-
-	migrate_page_copy(newpage, page);
-
-	bh = head;
-	do {
-		unlock_buffer(bh);
- 		put_bh(bh);
-		bh = bh->b_this_page;
-
-	} while (bh != head);
-
-	return 0;
-}
-EXPORT_SYMBOL(buffer_migrate_page);
-
-/*
  * Migrate the list 'pagelist' of pages to a certain destination.
  *
  * Specify destination with either non-NULL vma or dest_node >= 0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
