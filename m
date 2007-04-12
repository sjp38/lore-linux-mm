From: Nick Piggin <npiggin@suse.de>
Message-Id: <20070412103159.5564.35387.sendpatchset@linux.site>
In-Reply-To: <20070412103151.5564.16127.sendpatchset@linux.site>
References: <20070412103151.5564.16127.sendpatchset@linux.site>
Subject: [patch 1/9] mm: prep find_lock_page
Date: Thu, 12 Apr 2007 14:44:49 +0200 (CEST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux Memory Management <linux-mm@kvack.org>
Cc: Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

find_lock_page does not need to recheck ->index because if the page
is in the right mapping then the index must be the same. Also, tree_lock
does not need to be retaken after the page is locked in order to test
->mapped has not changed.

Signed-off-by: Nick Piggin <npiggin@suse.de>

Index: linux-2.6/mm/filemap.c
===================================================================
--- linux-2.6.orig/mm/filemap.c
+++ linux-2.6/mm/filemap.c
@@ -620,26 +620,26 @@ struct page *find_lock_page(struct addre
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
