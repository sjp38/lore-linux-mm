Message-Id: <200405222201.i4MM1Wr11300@mail.osdl.org>
Subject: [patch 02/57] __add_to_swap_cache and add_to_pagecache() simplification
From: akpm@osdl.org
Date: Sat, 22 May 2004 15:01:01 -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: torvalds@osdl.org
Cc: linux-mm@kvack.org, akpm@osdl.org
List-ID: <linux-mm.kvack.org>


Simplify the logic in there a bit.


---

 25-akpm/mm/filemap.c    |    4 +---
 25-akpm/mm/swap_state.c |    5 ++---
 2 files changed, 3 insertions(+), 6 deletions(-)

diff -puN mm/swap_state.c~__add_to_swap_cache-simplification mm/swap_state.c
--- 25/mm/swap_state.c~__add_to_swap_cache-simplification	2004-05-22 14:56:21.375841904 -0700
+++ 25-akpm/mm/swap_state.c	2004-05-22 14:59:44.832911728 -0700
@@ -68,18 +68,17 @@ static int __add_to_swap_cache(struct pa
 	BUG_ON(PagePrivate(page));
 	error = radix_tree_preload(gfp_mask);
 	if (!error) {
-		page_cache_get(page);
 		spin_lock_irq(&swapper_space.tree_lock);
 		error = radix_tree_insert(&swapper_space.page_tree,
 						entry.val, page);
 		if (!error) {
+			page_cache_get(page);
 			SetPageLocked(page);
 			SetPageSwapCache(page);
 			page->private = entry.val;
 			total_swapcache_pages++;
 			pagecache_acct(1);
-		} else
-			page_cache_release(page);
+		}
 		spin_unlock_irq(&swapper_space.tree_lock);
 		radix_tree_preload_end();
 	}
diff -puN mm/filemap.c~__add_to_swap_cache-simplification mm/filemap.c
--- 25/mm/filemap.c~__add_to_swap_cache-simplification	2004-05-22 14:56:21.376841752 -0700
+++ 25-akpm/mm/filemap.c	2004-05-22 14:59:44.199008096 -0700
@@ -252,17 +252,15 @@ int add_to_page_cache(struct page *page,
 	int error = radix_tree_preload(gfp_mask & ~__GFP_HIGHMEM);
 
 	if (error == 0) {
-		page_cache_get(page);
 		spin_lock_irq(&mapping->tree_lock);
 		error = radix_tree_insert(&mapping->page_tree, offset, page);
 		if (!error) {
+			page_cache_get(page);
 			SetPageLocked(page);
 			page->mapping = mapping;
 			page->index = offset;
 			mapping->nrpages++;
 			pagecache_acct(1);
-		} else {
-			page_cache_release(page);
 		}
 		spin_unlock_irq(&mapping->tree_lock);
 		radix_tree_preload_end();

_


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
