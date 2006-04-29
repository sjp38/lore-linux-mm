Date: Fri, 28 Apr 2006 20:23:12 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Message-Id: <20060429032312.4999.78688.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20060429032246.4999.21714.sendpatchset@schroedinger.engr.sgi.com>
References: <20060429032246.4999.21714.sendpatchset@schroedinger.engr.sgi.com>
Subject: [PATCH 5/7] PM cleanup: Extract try_to_unmap from migration functions
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm@kvack.org, Hugh Dickins <hugh@veritas.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>, Christoph Lameter <clameter@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

page migration: Extract try_to_unmap and rename remove_references -> move_mapping

try_to_unmap may significantly change the page state by for example setting
the dirty bit. It is therefore best to unmap in migrate_pages() before
calling any migration functions.

migrate_page_remove_references() will then only move the new page in
place of the old page in the mapping. Rename the function to
migrate_page_move_mapping().

This allows us to get rid of the special unmapping for the
fallback path.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.17-rc3/mm/migrate.c
===================================================================
--- linux-2.6.17-rc3.orig/mm/migrate.c	2006-04-28 17:31:10.325193799 -0700
+++ linux-2.6.17-rc3/mm/migrate.c	2006-04-28 17:42:24.342949272 -0700
@@ -166,15 +166,14 @@
 }
 
 /*
- * Remove references for a page and establish the new page with the correct
- * basic settings to be able to stop accesses to the page.
+ * Remove or replace the page in the mapping.
  *
  * The number of remaining references must be:
  * 1 for anonymous pages without a mapping
  * 2 for pages with a mapping
  * 3 for pages with a mapping and PagePrivate set.
  */
-static int migrate_page_remove_references(struct page *newpage,
+static int migrate_page_move_mapping(struct page *newpage,
 				struct page *page)
 {
 	struct address_space *mapping = page_mapping(page);
@@ -183,35 +182,6 @@
 	if (!mapping)
 		return -EAGAIN;
 
-	/*
-	 * Establish swap ptes for anonymous pages or destroy pte
-	 * maps for files.
-	 *
-	 * In order to reestablish file backed mappings the fault handlers
-	 * will take the radix tree_lock which may then be used to stop
-  	 * processses from accessing this page until the new page is ready.
-	 *
-	 * A process accessing via a swap pte (an anonymous page) will take a
-	 * page_lock on the old page which will block the process until the
-	 * migration attempt is complete. At that time the PageSwapCache bit
-	 * will be examined. If the page was migrated then the PageSwapCache
-	 * bit will be clear and the operation to retrieve the page will be
-	 * retried which will find the new page in the radix tree. Then a new
-	 * direct mapping may be generated based on the radix tree contents.
-	 *
-	 * If the page was not migrated then the PageSwapCache bit
-	 * is still set and the operation may continue.
-	 */
-	if (try_to_unmap(page, 1) == SWAP_FAIL)
-		/* A vma has VM_LOCKED set -> permanent failure */
-		return -EPERM;
-
-	/*
-	 * Give up if we were unable to remove all mappings.
-	 */
-	if (page_mapcount(page))
-		return -EAGAIN;
-
 	write_lock_irq(&mapping->tree_lock);
 
 	radix_pointer = (struct page **)radix_tree_lookup_slot(
@@ -310,7 +280,7 @@
 
 	BUG_ON(PageWriteback(page));	/* Writeback must be complete */
 
-	rc = migrate_page_remove_references(newpage, page);
+	rc = migrate_page_move_mapping(newpage, page);
 
 	if (rc)
 		return rc;
@@ -349,7 +319,7 @@
 
 	head = page_buffers(page);
 
-	rc = migrate_page_remove_references(newpage, page);
+	rc = migrate_page_move_mapping(newpage, page);
 
 	if (rc)
 		return rc;
@@ -482,6 +452,33 @@
 		lock_page(newpage);
 
 		/*
+		 * Establish swap ptes for anonymous pages or destroy pte
+		 * maps for files.
+		 *
+		 * In order to reestablish file backed mappings the fault handlers
+		 * will take the radix tree_lock which may then be used to stop
+	  	 * processses from accessing this page until the new page is ready.
+		 *
+		 * A process accessing via a swap pte (an anonymous page) will take a
+		 * page_lock on the old page which will block the process until the
+		 * migration attempt is complete. At that time the PageSwapCache bit
+		 * will be examined. If the page was migrated then the PageSwapCache
+		 * bit will be clear and the operation to retrieve the page will be
+		 * retried which will find the new page in the radix tree. Then a new
+		 * direct mapping may be generated based on the radix tree contents.
+		 *
+		 * If the page was not migrated then the PageSwapCache bit
+		 * is still set and the operation may continue.
+		 */
+		rc = -EPERM;
+		if (try_to_unmap(page, 1) == SWAP_FAIL)
+			/* A vma has VM_LOCKED set -> permanent failure */
+			goto unlock_both;
+
+		rc = -EAGAIN;
+		if (page_mapped(page))
+			goto unlock_both;
+		/*
 		 * Pages are properly locked and writeback is complete.
 		 * Try to migrate the page.
 		 */
@@ -501,17 +498,6 @@
 			goto unlock_both;
                 }
 
-		/* Make sure the dirty bit is up to date */
-		if (try_to_unmap(page, 1) == SWAP_FAIL) {
-			rc = -EPERM;
-			goto unlock_both;
-		}
-
-		if (page_mapcount(page)) {
-			rc = -EAGAIN;
-			goto unlock_both;
-		}
-
 		/*
 		 * Default handling if a filesystem does not provide
 		 * a migration function. We can only migrate clean

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
