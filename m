Date: Fri, 28 Apr 2006 14:24:39 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Message-Id: <20060428212439.2737.94818.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20060428212434.2737.43187.sendpatchset@schroedinger.engr.sgi.com>
References: <20060428212434.2737.43187.sendpatchset@schroedinger.engr.sgi.com>
Subject: [PATCH 2/3] more page migration: move common code to migrate pages()
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm@kvack.org, Hugh Dickins <hugh@veritas.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>, Christoph Lameter <clameter@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

more page migration: move common code from migration functions to migrate pages()

All migration functions start by unmapping ptes and thereby potentially
creating migration ptes. They all end by replacing the migration ptes with
real ones.

So extract the common code and put it into migrate_pages().

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.17-rc2-mm1/mm/migrate.c
===================================================================
--- linux-2.6.17-rc2-mm1.orig/mm/migrate.c	2006-04-28 11:21:51.877154899 -0700
+++ linux-2.6.17-rc2-mm1/mm/migrate.c	2006-04-28 13:29:36.577252635 -0700
@@ -258,17 +258,11 @@
 {
 	struct page **radix_pointer;
 
-	/*
-	 * Retry if we were unable to remove all mappings.
-	 */
-	if (page_mapcount(page))
-		return -EAGAIN;
-
 	if (!mapping) {
 		/*
 		 * Anonymous page without swap mapping.
 		 */
-		if (page_count(page) != 1)
+		if (page_count(page) != 1 || !page->mapping)
 			return -EAGAIN;
 
 		return 0;
@@ -371,21 +365,12 @@
 
 	BUG_ON(PageWriteback(page));	/* Writeback must be complete */
 
-	if (try_to_unmap(page, 1) == SWAP_FAIL) {
-		remove_migration_ptes(page, page);
-		return -EPERM;
-	}
-
 	rc = migrate_page_move_mapping(mapping, newpage, page);
 
-	if (rc) {
-		remove_migration_ptes(page, page);
-		return rc;
-	}
+	if (!rc)
+		migrate_page_copy(newpage, page);
 
-	migrate_page_copy(newpage, page);
-	remove_migration_ptes(page, newpage);
-	return 0;
+	return rc;
 }
 EXPORT_SYMBOL(migrate_page);
 
@@ -403,9 +388,6 @@
 	if (!page_has_buffers(page))
 		return migrate_page(mapping, newpage, page);
 
-	if (try_to_unmap(page, 1) == SWAP_FAIL)
-		return -EPERM;
-
 	head = page_buffers(page);
 
 	rc = migrate_page_move_mapping(mapping, newpage, page);
@@ -455,10 +437,6 @@
 {
 	int rc;
 
-	if (try_to_unmap(page, 1) == SWAP_FAIL)
-		/* A vma has VM_LOCKED set -> permanent failure */
-		return -EPERM;
-
 	/*
 	 * Removing the ptes may have dirtied the page
 	 */
@@ -590,6 +568,21 @@
 		else if (PageWriteback(page))
 				goto unlock_page;
 
+		/*
+		 * Establish migration entries or unmap file ptes.
+		 */
+		rc = -EPERM;
+		if (try_to_unmap(page, 1) == SWAP_FAIL)
+			/* A vma has VM_LOCKED set -> permanent failure */
+			goto remove_migentry;
+
+		/*
+		 * Retry if we were unable to remove all mappings.
+		 */
+		rc = -EAGAIN;
+		if (page_mapcount(page))
+			goto remove_migentry;
+
 		lock_page(newpage);
 		/* Prepare mapping for the new page.*/
 		newpage->index = page->index;
@@ -609,7 +602,13 @@
 		else
 			rc = fallback_migrate_page(mapping, newpage, page);
 
+		if (rc == 0)
+			remove_migration_ptes(page, newpage);
 		unlock_page(newpage);
+
+remove_migentry:
+		if (rc)
+			remove_migration_ptes(page, page);
 unlock_page:
 		unlock_page(page);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
