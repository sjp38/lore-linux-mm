Subject: [PATCH 2.6.18-rc6-mm2] fix migrate_page_move_mapping for radix
	tree cleanup
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Content-Type: text/plain
Date: Wed, 13 Sep 2006 18:48:27 -0400
Message-Id: <1158187707.5328.86.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>
Cc: Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

Alternative to my "revert migrate_move_mapping ..." patch:


Change to radix_tree_{deref|replace}_slot() API requires
change to migrate_page_move_mapping() [only user of those
APIs, so far] to eliminate compiler warnings.

Apply only after backing out the patch:

page-migration-replace-radix_tree_lookup_slot-with-radix_tree_lockup.patch


Signed-off-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>

 mm/migrate.c |   11 +++++------
 1 files changed, 5 insertions(+), 6 deletions(-)

Index: linux-2.6.18-rc6-mm2/mm/migrate.c
===================================================================
--- linux-2.6.18-rc6-mm2.orig/mm/migrate.c	2006-09-13 22:32:44.000000000 -0400
+++ linux-2.6.18-rc6-mm2/mm/migrate.c	2006-09-13 22:38:43.000000000 -0400
@@ -294,7 +294,7 @@ out:
 static int migrate_page_move_mapping(struct address_space *mapping,
 		struct page *newpage, struct page *page)
 {
-	struct page **radix_pointer;
+	void **pslot;
 
 	if (!mapping) {
 		/* Anonymous page */
@@ -305,12 +305,11 @@ static int migrate_page_move_mapping(str
 
 	write_lock_irq(&mapping->tree_lock);
 
-	radix_pointer = (struct page **)radix_tree_lookup_slot(
-						&mapping->page_tree,
-						page_index(page));
+	pslot = radix_tree_lookup_slot(&mapping->page_tree,
+					page_index(page));
 
 	if (page_count(page) != 2 + !!PagePrivate(page) ||
-			radix_tree_deref_slot(radix_pointer) != page) {
+			(struct page *)radix_tree_deref_slot(pslot) != page) {
 		write_unlock_irq(&mapping->tree_lock);
 		return -EAGAIN;
 	}
@@ -326,7 +325,7 @@ static int migrate_page_move_mapping(str
 	}
 #endif
 
-	radix_tree_replace_slot(radix_pointer, newpage);
+	radix_tree_replace_slot(pslot, newpage);
 	__put_page(page);
 	write_unlock_irq(&mapping->tree_lock);
 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
