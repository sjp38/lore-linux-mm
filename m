Date: Thu, 2 Aug 2007 06:55:46 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: [patch] mm: improve find_lock_page
Message-ID: <20070802045546.GC13591@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

OK this patch isn't really going to help performance much (it's all
slowpath stuff), but it does help to clarify the locking.

--

find_lock_page does not need to recheck ->index because if the page
is in the right mapping then the index must be the same. Also, tree_lock
does not need to be retaken after the page is locked in order to test
that ->mapping has not changed, because holding the page lock pins its
mapping.

Signed-off-by: Nick Piggin <npiggin@suse.de>

Index: linux-2.6/mm/filemap.c
===================================================================
--- linux-2.6.orig/mm/filemap.c
+++ linux-2.6/mm/filemap.c
@@ -621,26 +621,27 @@ struct page *find_lock_page(struct addre
 {
 	struct page *page;
 
-	read_lock_irq(&mapping->tree_lock);
 repeat:
+	read_lock_irq(&mapping->tree_lock);
 	page = radix_tree_lookup(&mapping->page_tree, offset);
 	if (page) {
 		page_cache_get(page);
 		if (TestSetPageLocked(page)) {
 			read_unlock_irq(&mapping->tree_lock);
 			__lock_page(page);
-			read_lock_irq(&mapping->tree_lock);
 
 			/* Has the page been truncated while we slept? */
-			if (unlikely(page->mapping != mapping ||
-				     page->index != offset)) {
+			if (unlikely(page->mapping != mapping)) {
 				unlock_page(page);
 				page_cache_release(page);
 				goto repeat;
 			}
+			VM_BUG_ON(page->index != offset);
+			goto out;
 		}
 	}
 	read_unlock_irq(&mapping->tree_lock);
+out:
 	return page;
 }
 EXPORT_SYMBOL(find_lock_page);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
