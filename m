Date: Fri, 28 Apr 2006 20:22:56 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Message-Id: <20060429032256.4999.45018.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20060429032246.4999.21714.sendpatchset@schroedinger.engr.sgi.com>
References: <20060429032246.4999.21714.sendpatchset@schroedinger.engr.sgi.com>
Subject: [PATCH 2/7] PM cleanup: Group functions
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>, Christoph Lameter <clameter@sgi.com>, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

page migration: Reorder functions in migrate.c

Group all migration functions for struct address_space_operations
together.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.17-rc3/mm/migrate.c
===================================================================
--- linux-2.6.17-rc3.orig/mm/migrate.c	2006-04-28 17:11:42.779439413 -0700
+++ linux-2.6.17-rc3/mm/migrate.c	2006-04-28 17:24:03.935627108 -0700
@@ -120,15 +120,6 @@
 }
 
 /*
- * Non migratable page
- */
-int fail_migrate_page(struct page *newpage, struct page *page)
-{
-	return -EIO;
-}
-EXPORT_SYMBOL(fail_migrate_page);
-
-/*
  * swapout a single page
  * page is locked upon entry, unlocked on exit
  */
@@ -297,6 +288,17 @@
 }
 EXPORT_SYMBOL(migrate_page_copy);
 
+/************************************************************
+ *                    Migration functions
+ ***********************************************************/
+
+/* Always fail migration. Used for mappings that are not movable */
+int fail_migrate_page(struct page *newpage, struct page *page)
+{
+	return -EIO;
+}
+EXPORT_SYMBOL(fail_migrate_page);
+
 /*
  * Common logic to directly migrate a single page suitable for
  * pages that do not use PagePrivate.
@@ -330,6 +332,67 @@
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
@@ -529,67 +592,6 @@
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
