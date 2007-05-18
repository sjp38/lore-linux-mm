Message-Id: <200705180737.l4I7bAGo010774@shell0.pdx.osdl.net>
Subject: [patch 7/8] mm: fix clear_page_dirty_for_io vs fault race
From: akpm@linux-foundation.org
Date: Fri, 18 May 2007 00:37:10 -0700
Sender: owner-linux-mm@kvack.org
From: Nick Piggin <npiggin@suse.de>
Return-Path: <owner-linux-mm@kvack.org>
To: torvalds@linux-foundation.org
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, npiggin@suse.de, miklos@szeredi.hu
List-ID: <linux-mm.kvack.org>

Fix msync data loss and (less importantly) dirty page accounting
inaccuracies due to the race remaining in clear_page_dirty_for_io().

The deleted comment explains what the race was, and the added comments
explain how it is fixed.

Signed-off-by: Nick Piggin <npiggin@suse.de>
Acked-by: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Miklos Szeredi <miklos@szeredi.hu>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 mm/memory.c         |    9 +++++++++
 mm/page-writeback.c |   17 ++++++++++++-----
 2 files changed, 21 insertions(+), 5 deletions(-)

diff -puN mm/memory.c~mm-fix-clear_page_dirty_for_io-vs-fault-race mm/memory.c
--- a/mm/memory.c~mm-fix-clear_page_dirty_for_io-vs-fault-race
+++ a/mm/memory.c
@@ -1764,6 +1764,15 @@ gotten:
 unlock:
 	pte_unmap_unlock(page_table, ptl);
 	if (dirty_page) {
+		/*
+		 * Yes, Virginia, this is actually required to prevent a race
+		 * with clear_page_dirty_for_io() from clearing the page dirty
+		 * bit after it clear all dirty ptes, but before a racing
+		 * do_wp_page installs a dirty pte.
+		 *
+		 * do_no_page is protected similarly.
+		 */
+		wait_on_page_locked(dirty_page);
 		set_page_dirty_balance(dirty_page);
 		put_page(dirty_page);
 	}
diff -puN mm/page-writeback.c~mm-fix-clear_page_dirty_for_io-vs-fault-race mm/page-writeback.c
--- a/mm/page-writeback.c~mm-fix-clear_page_dirty_for_io-vs-fault-race
+++ a/mm/page-writeback.c
@@ -919,6 +919,8 @@ int clear_page_dirty_for_io(struct page 
 {
 	struct address_space *mapping = page_mapping(page);
 
+	BUG_ON(!PageLocked(page));
+
 	if (mapping && mapping_cap_account_dirty(mapping)) {
 		/*
 		 * Yes, Virginia, this is indeed insane.
@@ -944,14 +946,19 @@ int clear_page_dirty_for_io(struct page 
 		 * We basically use the page "master dirty bit"
 		 * as a serialization point for all the different
 		 * threads doing their things.
-		 *
-		 * FIXME! We still have a race here: if somebody
-		 * adds the page back to the page tables in
-		 * between the "page_mkclean()" and the "TestClearPageDirty()",
-		 * we might have it mapped without the dirty bit set.
 		 */
 		if (page_mkclean(page))
 			set_page_dirty(page);
+		/*
+		 * We carefully synchronise fault handlers against
+		 * installing a dirty pte and marking the page dirty
+		 * at this point. We do this by having them hold the
+		 * page lock at some point after installing their
+		 * pte, but before marking the page dirty.
+		 * Pages are always locked coming in here, so we get
+		 * the desired exclusion. See mm/memory.c:do_wp_page()
+		 * for more comments.
+		 */
 		if (TestClearPageDirty(page)) {
 			dec_zone_page_state(page, NR_FILE_DIRTY);
 			return 1;
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
