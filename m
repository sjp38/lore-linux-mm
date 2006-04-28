Date: Thu, 27 Apr 2006 23:03:28 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Message-Id: <20060428060328.30257.71534.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20060428060302.30257.76871.sendpatchset@schroedinger.engr.sgi.com>
References: <20060428060302.30257.76871.sendpatchset@schroedinger.engr.sgi.com>
Subject: [PATCH 6/7] page migration: Extract try_to_unmap
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm@kvack.org, Hugh Dickins <hugh@veritas.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>, Christoph Lameter <clameter@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

page migration: Extract try_to_unmap and rename remove_references -> move_mapping

try_to_unmap may significantly change the page state by for example setting
the dirty bit. It is therefore best for each migration function to do
try_to_unmap on their own before examining the page state.

migrate_page_remove_references() will then only move the new page in
place of the old page in the mapping. Rename the function to
migrate_page_move_mapping().

Signed-off-by: Christoph Lameter <clameter@sgi.com>


Index: linux-2.6.17-rc2-mm1/mm/migrate.c
===================================================================
--- linux-2.6.17-rc2-mm1.orig/mm/migrate.c	2006-04-27 21:32:50.417322988 -0700
+++ linux-2.6.17-rc2-mm1/mm/migrate.c	2006-04-27 21:34:12.171976982 -0700
@@ -246,32 +246,14 @@
 }
 
 /*
- * Remove or replace all references to a page so that future accesses to
- * the page can be blocked. Establish the new page
- * with the basic settings to be able to stop accesses to the page.
+ * Remove or replace the page in the mapping
  */
-static int migrate_page_remove_references(struct address_space *mapping,
+static int migrate_page_move_mapping(struct address_space *mapping,
 		struct page *newpage, struct page *page)
 {
 	struct page **radix_pointer;
 
 	/*
-	 * Establish migration ptes for anonymous pages or destroy pte
-	 * maps for files.
-	 *
-	 * In order to reestablish file backed mappings the fault handlers
-	 * will take the radix tree_lock which may then be used to stop
-  	 * processses from accessing this page until the new page is ready.
-	 *
-	 * A process accessing via a migration pte (an anonymous page) will
-	 * take a page_lock on the old page which will block the process
-	 * until the migration attempt is complete.
-	 */
-	if (try_to_unmap(page, 1) == SWAP_FAIL)
-		/* A vma has VM_LOCKED set -> permanent failure */
-		return -EPERM;
-
-	/*
 	 * Retry if we were unable to remove all mappings.
 	 */
 	if (page_mapcount(page))
@@ -280,9 +262,6 @@
 	if (!mapping) {
 		/*
 		 * Anonymous page without swap mapping.
-		 * User space cannot access the page anymore since we
-		 * removed the ptes. Now check if the kernel still has
-		 * pending references.
 		 */
 		if (page_count(page) != 1)
 			return -EAGAIN;
@@ -387,7 +366,12 @@
 
 	BUG_ON(PageWriteback(page));	/* Writeback must be complete */
 
-	rc = migrate_page_remove_references(mapping, newpage, page);
+	if (try_to_unmap(page, 1) == SWAP_FAIL) {
+		remove_migration_ptes(page, page);
+		return -EPERM;
+	}
+
+	rc = migrate_page_move_mapping(mapping, newpage, page);
 
 	if (rc) {
 		remove_migration_ptes(page, page);
@@ -414,9 +398,12 @@
 	if (!page_has_buffers(page))
 		return migrate_page(mapping, newpage, page);
 
+	if (try_to_unmap(page, 1) == SWAP_FAIL)
+		return -EPERM;
+
 	head = page_buffers(page);
 
-	rc = migrate_page_remove_references(mapping, newpage, page);
+	rc = migrate_page_move_mapping(mapping, newpage, page);
 
 	if (rc)
 		return rc;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
