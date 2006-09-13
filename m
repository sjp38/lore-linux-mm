Subject: [PATCH 2.6.18-rc6.mm2] revert migrate_move_mapping to use direct
	radix tree slot update
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Content-Type: text/plain
Date: Wed, 13 Sep 2006 15:09:34 -0400
Message-Id: <1158174574.5328.37.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>


Now that the problem with the rcu radix tree replace slot function has
been fixed, we can, if Christoph agrees:

Revert migrate_page_move_mapping() to use direct radix tree
slot replacement.  Fix up variable types to match modified
interfaces to radix_tree_{deref|replace}_slot().


Signed-off-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>

 mm/migrate.c |   23 ++++++++++++-----------
 1 files changed, 12 insertions(+), 11 deletions(-)

Index: linux-2.6.18-rc6-mm2/mm/migrate.c
===================================================================
--- linux-2.6.18-rc6-mm2.orig/mm/migrate.c	2006-09-13 11:39:14.000000000 -0400
+++ linux-2.6.18-rc6-mm2/mm/migrate.c	2006-09-13 11:42:36.000000000 -0400
@@ -294,8 +294,7 @@ out:
 static int migrate_page_move_mapping(struct address_space *mapping,
 		struct page *newpage, struct page *page)
 {
-	struct page *current_page;
-	long index;
+	void **pslot;
 
 	if (!mapping) {
 		/* Anonymous page */
@@ -306,14 +305,11 @@ static int migrate_page_move_mapping(str
 
 	write_lock_irq(&mapping->tree_lock);
 
-	index = page_index(page);
-
-	current_page = (struct page *)radix_tree_lookup(
-						&mapping->page_tree,
-						index);
+	pslot = radix_tree_lookup_slot(&mapping->page_tree,
+ 					page_index(page));
 
 	if (page_count(page) != 2 + !!PagePrivate(page) ||
-			current_page != page) {
+			(struct page *)radix_tree_deref_slot(pslot) != page) {
 		write_unlock_irq(&mapping->tree_lock);
 		return -EAGAIN;
 	}
@@ -321,7 +317,7 @@ static int migrate_page_move_mapping(str
 	/*
 	 * Now we know that no one else is looking at the page.
 	 */
-	get_page(newpage);
+	get_page(newpage);	/* add cache reference */
 #ifdef CONFIG_SWAP
 	if (PageSwapCache(page)) {
 		SetPageSwapCache(newpage);
@@ -329,9 +325,14 @@ static int migrate_page_move_mapping(str
 	}
 #endif
 
-	radix_tree_delete(&mapping->page_tree, index);
-	radix_tree_insert(&mapping->page_tree, index, newpage);
+	radix_tree_replace_slot(pslot, newpage);
+
+	/*
+	 * Drop cache reference from old page.
+	 * We know this isn't the last reference.
+	 */
 	__put_page(page);
+
 	write_unlock_irq(&mapping->tree_lock);
 
 	return 0;


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
