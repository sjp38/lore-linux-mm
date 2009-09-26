Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 3FCE36B0055
	for <linux-mm@kvack.org>; Fri, 25 Sep 2009 23:15:42 -0400 (EDT)
Date: Sat, 26 Sep 2009 11:15:37 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [RFC][PATCH] HWPOISON: remove the unsafe __set_page_locked()
Message-ID: <20090926031537.GA10176@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Andi Kleen <andi@firstfloor.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

The swap cache and page cache code assume that they 'own' the newly
allocated page and therefore can disregard the locking rules. However
now hwpoison can hit any time on any page.

So use the safer lock_page()/trylock_page(). The main intention is not
to close such a small time window of memory corruption. But to avoid
kernel oops that may result from such races, and also avoid raising
false alerts in hwpoison stress tests.

This in theory will slightly increase page cache/swap cache overheads,
however it seems to be too small to be measurable in benchmark.

CC: Hugh Dickins <hugh.dickins@tiscali.co.uk>
CC: Andi Kleen <andi@firstfloor.org> 
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 include/linux/pagemap.h |   13 ++++---------
 mm/migrate.c            |    2 +-
 mm/swap_state.c         |    4 ++--
 3 files changed, 7 insertions(+), 12 deletions(-)

--- sound-2.6.orig/mm/swap_state.c	2009-09-14 10:50:19.000000000 +0800
+++ sound-2.6/mm/swap_state.c	2009-09-25 18:42:23.000000000 +0800
@@ -306,7 +306,7 @@ struct page *read_swap_cache_async(swp_e
 		 * re-using the just freed swap entry for an existing page.
 		 * May fail (-ENOMEM) if radix-tree node allocation failed.
 		 */
-		__set_page_locked(new_page);
+		lock_page(new_page);
 		SetPageSwapBacked(new_page);
 		err = add_to_swap_cache(new_page, entry, gfp_mask & GFP_KERNEL);
 		if (likely(!err)) {
@@ -318,7 +318,7 @@ struct page *read_swap_cache_async(swp_e
 			return new_page;
 		}
 		ClearPageSwapBacked(new_page);
-		__clear_page_locked(new_page);
+		unlock_page(new_page);
 		swapcache_free(entry, NULL);
 	} while (err != -ENOMEM);
 
--- sound-2.6.orig/include/linux/pagemap.h	2009-09-14 10:50:19.000000000 +0800
+++ sound-2.6/include/linux/pagemap.h	2009-09-25 18:42:19.000000000 +0800
@@ -292,11 +292,6 @@ extern int __lock_page_killable(struct p
 extern void __lock_page_nosync(struct page *page);
 extern void unlock_page(struct page *page);
 
-static inline void __set_page_locked(struct page *page)
-{
-	__set_bit(PG_locked, &page->flags);
-}
-
 static inline void __clear_page_locked(struct page *page)
 {
 	__clear_bit(PG_locked, &page->flags);
@@ -435,18 +430,18 @@ extern void remove_from_page_cache(struc
 extern void __remove_from_page_cache(struct page *page);
 
 /*
- * Like add_to_page_cache_locked, but used to add newly allocated pages:
- * the page is new, so we can just run __set_page_locked() against it.
+ * Like add_to_page_cache_locked, but used to add newly allocated pages.
  */
 static inline int add_to_page_cache(struct page *page,
 		struct address_space *mapping, pgoff_t offset, gfp_t gfp_mask)
 {
 	int error;
 
-	__set_page_locked(page);
+	if (!trylock_page(page))
+		return -EIO;	/* hwpoisoned */
 	error = add_to_page_cache_locked(page, mapping, offset, gfp_mask);
 	if (unlikely(error))
-		__clear_page_locked(page);
+		unlock_page(page);
 	return error;
 }
 
--- sound-2.6.orig/mm/migrate.c	2009-09-14 10:50:19.000000000 +0800
+++ sound-2.6/mm/migrate.c	2009-09-25 18:42:19.000000000 +0800
@@ -551,7 +551,7 @@ static int move_to_new_page(struct page 
 	 * holding a reference to the new page at this point.
 	 */
 	if (!trylock_page(newpage))
-		BUG();
+		return -EAGAIN;		/* got by hwpoison */
 
 	/* Prepare mapping for the new page.*/
 	newpage->index = page->index;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
