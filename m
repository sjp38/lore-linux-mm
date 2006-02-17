Subject: [RFC] 4/4 Migration Cache - use for direct migration
From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Reply-To: lee.schermerhorn@hp.com
Content-Type: text/plain
Date: Fri, 17 Feb 2006 10:37:31 -0500
Message-Id: <1140190651.5219.25.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>
Cc: Christoph Lameter <clameter@sgi.com>, Marcelo Tosatti <marcelo.tosatti@cyclades.com>
List-ID: <linux-mm.kvack.org>

Migration Cache "V8" 4/4

This patch hooks the migration cache up to direct page migration.
If a destination page exists, and the old page is not already in
a swap cache, we place it in the migration cache instead.

If direct migration is successful, the page will be removed by
remove_from_swap(), et al.  If migration is not successful after
4 or 5 passes, migrate_pages() drops back to swapping.  In this
case, we must move the page from the migration cache to the swap
cache.

Signed-off-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>

Index: linux-2.6.16-rc3-mm1/mm/vmscan.c
===================================================================
--- linux-2.6.16-rc3-mm1.orig/mm/vmscan.c	2006-02-15 10:50:59.000000000 -0500
+++ linux-2.6.16-rc3-mm1/mm/vmscan.c	2006-02-15 10:51:09.000000000 -0500
@@ -911,7 +911,12 @@ redo:
 		 * preserved.
 		 */
 		if (PageAnon(page) && !PageSwapCache(page)) {
-			if (!add_to_swap(page, GFP_KERNEL)) {
+			if (!to) {
+				if (!add_to_swap(page, GFP_KERNEL)) {
+					rc = -ENOMEM;
+					goto unlock_page;
+				}
+			} else if (add_to_migration_cache(page, GFP_KERNEL)) {
 				rc = -ENOMEM;
 				goto unlock_page;
 			}
@@ -989,6 +994,12 @@ redo:
 			 */
 			unlock_page(newpage);
 			newpage = NULL;
+			if (page_is_migration(page)) {
+				if (!migration_move_to_swap(page)) {
+					rc = -ENOMEM;
+					goto unlock_page;
+				}
+			}
 			rc = swap_page(page);
 			goto next;
 		}


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
