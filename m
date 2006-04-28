Date: Thu, 27 Apr 2006 23:03:18 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Message-Id: <20060428060317.30257.27066.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20060428060302.30257.76871.sendpatchset@schroedinger.engr.sgi.com>
References: <20060428060302.30257.76871.sendpatchset@schroedinger.engr.sgi.com>
Subject: [PATCH 4/7] page migration: Drop nr_refs parameter
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm@kvack.org, Hugh Dickins <hugh@veritas.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>, Christoph Lameter <clameter@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

page migration: Drop nr_refs parameter from migrate_page_remove_references()

The nr_refs parameter is not really useful since the number of remaining
references is always

1 for anonymous pages without a mapping
2 for pages with a mapping
3 for pages with a mapping and PagePrivate set.

Remove the early check for the number of references since we are
checking page_mapcount() anyways. Ultimately only the refcount
matters after the tree_lock has been obtained.

Signed-off-by: Christoph Lameter <clameter@sgi.coim>

Index: linux-2.6.17-rc2-mm1/mm/migrate.c
===================================================================
--- linux-2.6.17-rc2-mm1.orig/mm/migrate.c	2006-04-27 21:32:18.134185419 -0700
+++ linux-2.6.17-rc2-mm1/mm/migrate.c	2006-04-27 21:32:46.933165848 -0700
@@ -251,20 +251,11 @@
  * with the basic settings to be able to stop accesses to the page.
  */
 static int migrate_page_remove_references(struct address_space *mapping,
-		struct page *newpage, struct page *page, int nr_refs)
+		struct page *newpage, struct page *page)
 {
 	struct page **radix_pointer;
 
 	/*
-	 * Avoid doing any of the following work if the page count
-	 * indicates that the page is in use or truncate has removed
-	 * the page.
-	 */
-	if (!page->mapping ||
-		page_mapcount(page) + nr_refs != page_count(page))
-			return -EAGAIN;
-
-	/*
 	 * Establish migration ptes for anonymous pages or destroy pte
 	 * maps for files.
 	 *
@@ -293,7 +284,7 @@
 		 * removed the ptes. Now check if the kernel still has
 		 * pending references.
 		 */
-		if (page_count(page) != nr_refs)
+		if (page_count(page) != 1)
 			return -EAGAIN;
 
 		return 0;
@@ -308,7 +299,8 @@
 						&mapping->page_tree,
 						page_index(page));
 
-	if (!page_mapping(page) || page_count(page) != nr_refs ||
+	if (!page_mapping(page) ||
+			page_count(page) != 2 + !!PagePrivate(page) ||
 			*radix_pointer != page) {
 		write_unlock_irq(&mapping->tree_lock);
 		return -EAGAIN;
@@ -395,8 +387,7 @@
 
 	BUG_ON(PageWriteback(page));	/* Writeback must be complete */
 
-	rc = migrate_page_remove_references(mapping, newpage, page,
-			mapping ? 2 : 1);
+	rc = migrate_page_remove_references(mapping, newpage, page);
 
 	if (rc) {
 		remove_migration_ptes(page, page);
@@ -425,7 +416,7 @@
 
 	head = page_buffers(page);
 
-	rc = migrate_page_remove_references(mapping, newpage, page, 3);
+	rc = migrate_page_remove_references(mapping, newpage, page);
 
 	if (rc)
 		return rc;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
