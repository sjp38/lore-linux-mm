Date: Thu, 9 Feb 2006 21:39:25 -0800 (PST)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Minor updates for page migration
Message-ID: <Pine.LNX.4.62.0602092134290.13398@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This adds some additional comments in order to help others figure out
how exactly the code works. And fix a variable name.

Also swap_page does need to ignore all reference bits when unmapping
a page. Otherwise we may have to repeatedly unmap a frequently touched
page. So change the try_to_unmap parameter to 1.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.16-rc2-mm1/mm/vmscan.c
===================================================================
--- linux-2.6.16-rc2-mm1.orig/mm/vmscan.c	2006-02-09 20:04:37.000000000 -0800
+++ linux-2.6.16-rc2-mm1/mm/vmscan.c	2006-02-09 21:32:24.000000000 -0800
@@ -630,7 +630,7 @@ static int swap_page(struct page *page)
 	struct address_space *mapping = page_mapping(page);
 
 	if (page_mapped(page) && mapping)
-		if (try_to_unmap(page, 0) != SWAP_SUCCESS)
+		if (try_to_unmap(page, 1) != SWAP_SUCCESS)
 			goto unlock_retry;
 
 	if (PageDirty(page)) {
@@ -837,7 +837,7 @@ EXPORT_SYMBOL(migrate_page);
  * pages are swapped out.
  *
  * The function returns after 10 attempts or if no pages
- * are movable anymore because t has become empty
+ * are movable anymore because to has become empty
  * or no retryable pages exist anymore.
  *
  * Return: Number of pages not migrated when "to" ran empty.
@@ -926,12 +926,21 @@ redo:
 			goto unlock_both;
 
 		if (mapping->a_ops->migratepage) {
+			/*
+			 * Most pages have a mapping and most filesystems
+			 * should provide a migration function. Anonymous
+			 * pages are part of swap space which also has its
+			 * own migration function. This is the most common
+			 * path for page migration.
+			 */
 			rc = mapping->a_ops->migratepage(newpage, page);
 			goto unlock_both;
                 }
 
 		/*
-		 * Trigger writeout if page is dirty
+		 * Default handling if a filesystem does not provide
+		 * a migration function. We can only migrate clean
+		 * pages so try to write out any dirty pages first.
 		 */
 		if (PageDirty(page)) {
 			switch (pageout(page, mapping)) {
@@ -947,9 +956,10 @@ redo:
 				; /* try to migrate the page below */
 			}
                 }
+
 		/*
-		 * If we have no buffer or can release the buffer
-		 * then do a simple migration.
+		 * Buffers are managed in a filesystem specific way.
+		 * We must have no buffers or drop them.
 		 */
 		if (!page_has_buffers(page) ||
 		    try_to_release_page(page, GFP_KERNEL)) {
@@ -964,6 +974,11 @@ redo:
 		 * swap them out.
 		 */
 		if (pass > 4) {
+			/*
+			 * Persistently unable to drop buffers..... As a
+			 * measure of last resort we fall back to
+			 * swap_page().
+			 */
 			unlock_page(newpage);
 			newpage = NULL;
 			rc = swap_page(page);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
