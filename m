Message-Id: <200405222201.i4MM1Gr11266@mail.osdl.org>
Subject: [patch 01/57] Make swapper_space tree_lock irq-safe
From: akpm@osdl.org
Date: Sat, 22 May 2004 15:00:40 -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: torvalds@osdl.org
Cc: linux-mm@kvack.org, akpm@osdl.org
List-ID: <linux-mm.kvack.org>


->tree_lock is supposed to be IRQ-safe.  Hugh worked out that with his
changes, we never actually take it from interrupt context, so spin_lock() is
sufficient.

Apart from kinda freaking me out, the analysis which led to this decision
becomes untrue with later patches.  So make it irq-safe.


---

 25-akpm/mm/swap_state.c |   16 ++++++++--------
 25-akpm/mm/swapfile.c   |   12 ++++++------
 2 files changed, 14 insertions(+), 14 deletions(-)

diff -puN mm/swapfile.c~swapper_space-tree_lock-fix mm/swapfile.c
--- 25/mm/swapfile.c~swapper_space-tree_lock-fix	2004-05-22 14:56:21.221865312 -0700
+++ 25-akpm/mm/swapfile.c	2004-05-22 14:59:43.296145352 -0700
@@ -289,10 +289,10 @@ static int exclusive_swap_page(struct pa
 		/* Is the only swap cache user the cache itself? */
 		if (p->swap_map[swp_offset(entry)] == 1) {
 			/* Recheck the page count with the swapcache lock held.. */
-			spin_lock(&swapper_space.tree_lock);
+			spin_lock_irq(&swapper_space.tree_lock);
 			if (page_count(page) == 2)
 				retval = 1;
-			spin_unlock(&swapper_space.tree_lock);
+			spin_unlock_irq(&swapper_space.tree_lock);
 		}
 		swap_info_put(p);
 	}
@@ -360,13 +360,13 @@ int remove_exclusive_swap_page(struct pa
 	retval = 0;
 	if (p->swap_map[swp_offset(entry)] == 1) {
 		/* Recheck the page count with the swapcache lock held.. */
-		spin_lock(&swapper_space.tree_lock);
+		spin_lock_irq(&swapper_space.tree_lock);
 		if ((page_count(page) == 2) && !PageWriteback(page)) {
 			__delete_from_swap_cache(page);
 			SetPageDirty(page);
 			retval = 1;
 		}
-		spin_unlock(&swapper_space.tree_lock);
+		spin_unlock_irq(&swapper_space.tree_lock);
 	}
 	swap_info_put(p);
 
@@ -390,12 +390,12 @@ void free_swap_and_cache(swp_entry_t ent
 	p = swap_info_get(entry);
 	if (p) {
 		if (swap_entry_free(p, swp_offset(entry)) == 1) {
-			spin_lock(&swapper_space.tree_lock);
+			spin_lock_irq(&swapper_space.tree_lock);
 			page = radix_tree_lookup(&swapper_space.page_tree,
 				entry.val);
 			if (page && TestSetPageLocked(page))
 				page = NULL;
-			spin_unlock(&swapper_space.tree_lock);
+			spin_unlock_irq(&swapper_space.tree_lock);
 		}
 		swap_info_put(p);
 	}
diff -puN mm/swap_state.c~swapper_space-tree_lock-fix mm/swap_state.c
--- 25/mm/swap_state.c~swapper_space-tree_lock-fix	2004-05-22 14:56:21.223865008 -0700
+++ 25-akpm/mm/swap_state.c	2004-05-22 14:59:44.974890144 -0700
@@ -69,7 +69,7 @@ static int __add_to_swap_cache(struct pa
 	error = radix_tree_preload(gfp_mask);
 	if (!error) {
 		page_cache_get(page);
-		spin_lock(&swapper_space.tree_lock);
+		spin_lock_irq(&swapper_space.tree_lock);
 		error = radix_tree_insert(&swapper_space.page_tree,
 						entry.val, page);
 		if (!error) {
@@ -80,7 +80,7 @@ static int __add_to_swap_cache(struct pa
 			pagecache_acct(1);
 		} else
 			page_cache_release(page);
-		spin_unlock(&swapper_space.tree_lock);
+		spin_unlock_irq(&swapper_space.tree_lock);
 		radix_tree_preload_end();
 	}
 	return error;
@@ -207,9 +207,9 @@ void delete_from_swap_cache(struct page 
   
 	entry.val = page->private;
 
-	spin_lock(&swapper_space.tree_lock);
+	spin_lock_irq(&swapper_space.tree_lock);
 	__delete_from_swap_cache(page);
-	spin_unlock(&swapper_space.tree_lock);
+	spin_unlock_irq(&swapper_space.tree_lock);
 
 	swap_free(entry);
 	page_cache_release(page);
@@ -308,13 +308,13 @@ struct page * lookup_swap_cache(swp_entr
 {
 	struct page *page;
 
-	spin_lock(&swapper_space.tree_lock);
+	spin_lock_irq(&swapper_space.tree_lock);
 	page = radix_tree_lookup(&swapper_space.page_tree, entry.val);
 	if (page) {
 		page_cache_get(page);
 		INC_CACHE_INFO(find_success);
 	}
-	spin_unlock(&swapper_space.tree_lock);
+	spin_unlock_irq(&swapper_space.tree_lock);
 	INC_CACHE_INFO(find_total);
 	return page;
 }
@@ -336,12 +336,12 @@ struct page * read_swap_cache_async(swp_
 		 * called after lookup_swap_cache() failed, re-calling
 		 * that would confuse statistics.
 		 */
-		spin_lock(&swapper_space.tree_lock);
+		spin_lock_irq(&swapper_space.tree_lock);
 		found_page = radix_tree_lookup(&swapper_space.page_tree,
 						entry.val);
 		if (found_page)
 			page_cache_get(found_page);
-		spin_unlock(&swapper_space.tree_lock);
+		spin_unlock_irq(&swapper_space.tree_lock);
 		if (found_page)
 			break;
 

_
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
