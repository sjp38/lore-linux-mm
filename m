Date: Wed, 7 Mar 2007 12:04:29 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: [patch 8/6] mm: fix cpdfio vs fault race
Message-ID: <20070307110429.GF5555@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, miklos@szeredi.hu
Cc: Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

OK, this is how we can plug that hole, leveraging my
previous patches to lock page over do_no_page.

I'm pretty sure the PageLocked invariant is correct.


--
Fix msync data loss and (less importantly) dirty page accounting inaccuracies
due to the race remaining in clear_page_dirty_for_io().

The deleted comment explains what the race was, and the added comments
explain how it is fixed.

Signed-off-by: Nick Piggin <npiggin@suse.de>

Index: linux-2.6/mm/memory.c
===================================================================
--- linux-2.6.orig/mm/memory.c
+++ linux-2.6/mm/memory.c
@@ -1676,6 +1676,17 @@ gotten:
 unlock:
 	pte_unmap_unlock(page_table, ptl);
 	if (dirty_page) {
+		/*
+		 * Yes, Virginia, this is actually required to prevent a race
+		 * with clear_page_dirty_for_io() from clearing the page dirty
+		 * bit after it clear all dirty ptes, but before a racing
+		 * do_wp_page installs a dirty pte.
+		 *
+		 * do_fault is protected similarly by holding the page lock
+		 * after the dirty pte is installed.
+		 */
+		lock_page(dirty_page);
+		unlock_page(dirty_page);
 		set_page_dirty_balance(dirty_page);
 		put_page(dirty_page);
 	}
Index: linux-2.6/mm/page-writeback.c
===================================================================
--- linux-2.6.orig/mm/page-writeback.c
+++ linux-2.6/mm/page-writeback.c
@@ -903,6 +903,8 @@ int clear_page_dirty_for_io(struct page 
 {
 	struct address_space *mapping = page_mapping(page);
 
+	BUG_ON(!PageLocked(page));
+
 	if (mapping && mapping_cap_account_dirty(mapping)) {
 		/*
 		 * Yes, Virginia, this is indeed insane.
@@ -928,14 +930,19 @@ int clear_page_dirty_for_io(struct page 
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

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
