Date: Fri, 28 Apr 2006 20:23:06 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Message-Id: <20060429032306.4999.92029.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20060429032246.4999.21714.sendpatchset@schroedinger.engr.sgi.com>
References: <20060429032246.4999.21714.sendpatchset@schroedinger.engr.sgi.com>
Subject: [PATCH 4/7] PM cleanup: Drop nr_refs in remove_references()
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>, Christoph Lameter <clameter@sgi.com>, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

page migration: Drop nr_refs parameter from migrate_page_remove_references()

The nr_refs parameter is not really useful since the number of remaining
references is always

1 for anonymous pages without a mapping
2 for pages with a mapping
3 for pages with a mapping and PagePrivate set.

Remove the early check for the number of references since we are
checking page_mapcount() earlier. Ultimately only the refcount
matters after the tree_lock has been obtained.

Signed-off-by: Christoph Lameter <clameter@sgi.coim>

Index: linux-2.6.17-rc3/mm/migrate.c
===================================================================
--- linux-2.6.17-rc3.orig/mm/migrate.c	2006-04-28 17:26:13.866044400 -0700
+++ linux-2.6.17-rc3/mm/migrate.c	2006-04-28 17:31:10.325193799 -0700
@@ -168,19 +168,19 @@
 /*
  * Remove references for a page and establish the new page with the correct
  * basic settings to be able to stop accesses to the page.
+ *
+ * The number of remaining references must be:
+ * 1 for anonymous pages without a mapping
+ * 2 for pages with a mapping
+ * 3 for pages with a mapping and PagePrivate set.
  */
 static int migrate_page_remove_references(struct page *newpage,
-				struct page *page, int nr_refs)
+				struct page *page)
 {
 	struct address_space *mapping = page_mapping(page);
 	struct page **radix_pointer;
 
-	/*
-	 * Avoid doing any of the following work if the page count
-	 * indicates that the page is in use or truncate has removed
-	 * the page.
-	 */
-	if (!mapping || page_mapcount(page) + nr_refs != page_count(page))
+	if (!mapping)
 		return -EAGAIN;
 
 	/*
@@ -218,7 +218,8 @@
 						&mapping->page_tree,
 						page_index(page));
 
-	if (!page_mapping(page) || page_count(page) != nr_refs ||
+	if (!page_mapping(page) ||
+			page_count(page) != 2 + !!PagePrivate(page) ||
 			*radix_pointer != page) {
 		write_unlock_irq(&mapping->tree_lock);
 		return -EAGAIN;
@@ -309,7 +310,7 @@
 
 	BUG_ON(PageWriteback(page));	/* Writeback must be complete */
 
-	rc = migrate_page_remove_references(newpage, page, 2);
+	rc = migrate_page_remove_references(newpage, page);
 
 	if (rc)
 		return rc;
@@ -348,7 +349,7 @@
 
 	head = page_buffers(page);
 
-	rc = migrate_page_remove_references(newpage, page, 3);
+	rc = migrate_page_remove_references(newpage, page);
 
 	if (rc)
 		return rc;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
