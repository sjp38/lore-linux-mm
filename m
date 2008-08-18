Date: Mon, 18 Aug 2008 14:24:28 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: [patch] mm: pagecache insertion fewer atomics
Message-ID: <20080818122428.GA9062@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Setting and clearing the page locked when inserting it into swapcache /
pagecache when it has no other references can use non-atomic page flags
operations because no other CPU may be operating on it at this time.

This saves one atomic operation when inserting a page into pagecache.

Signed-off-by: Nick Piggin <npiggin@suse.de>
---
 include/linux/pagemap.h |   37 +++++++++++++++++++++++++++++++++----
 mm/swap_state.c         |    4 ++--
 2 files changed, 35 insertions(+), 6 deletions(-)

Index: linux-2.6/mm/swap_state.c
===================================================================
--- linux-2.6.orig/mm/swap_state.c
+++ linux-2.6/mm/swap_state.c
@@ -302,7 +302,7 @@ struct page *read_swap_cache_async(swp_e
 		 * re-using the just freed swap entry for an existing page.
 		 * May fail (-ENOMEM) if radix-tree node allocation failed.
 		 */
-		set_page_locked(new_page);
+		__set_page_locked(new_page);
 		err = add_to_swap_cache(new_page, entry, gfp_mask & GFP_KERNEL);
 		if (likely(!err)) {
 			/*
@@ -312,7 +312,7 @@ struct page *read_swap_cache_async(swp_e
 			swap_readpage(NULL, new_page);
 			return new_page;
 		}
-		clear_page_locked(new_page);
+		__clear_page_locked(new_page);
 		swap_free(entry);
 	} while (err != -ENOMEM);
 
Index: linux-2.6/include/linux/pagemap.h
===================================================================
--- linux-2.6.orig/include/linux/pagemap.h
+++ linux-2.6/include/linux/pagemap.h
@@ -271,14 +271,14 @@ extern int __lock_page_killable(struct p
 extern void __lock_page_nosync(struct page *page);
 extern void unlock_page(struct page *page);
 
-static inline void set_page_locked(struct page *page)
+static inline void __set_page_locked(struct page *page)
 {
-	set_bit(PG_locked, &page->flags);
+	__set_bit(PG_locked, &page->flags);
 }
 
-static inline void clear_page_locked(struct page *page)
+static inline void __clear_page_locked(struct page *page)
 {
-	clear_bit(PG_locked, &page->flags);
+	__clear_bit(PG_locked, &page->flags);
 }
 
 static inline int trylock_page(struct page *page)
@@ -410,17 +410,17 @@ extern void __remove_from_page_cache(str
 
 /*
  * Like add_to_page_cache_locked, but used to add newly allocated pages:
- * the page is new, so we can just run set_page_locked() against it.
+ * the page is new, so we can just run __set_page_locked() against it.
  */
 static inline int add_to_page_cache(struct page *page,
 		struct address_space *mapping, pgoff_t offset, gfp_t gfp_mask)
 {
 	int error;
 
-	set_page_locked(page);
+	__set_page_locked(page);
 	error = add_to_page_cache_locked(page, mapping, offset, gfp_mask);
 	if (unlikely(error))
-		clear_page_locked(page);
+		__clear_page_locked(page);
 	return error;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
