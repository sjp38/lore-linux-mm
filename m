Date: Thu, 2 Aug 2007 07:08:42 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: [patch] mm: clarify __add_to_swap_cache locking
Message-ID: <20070802050842.GB31121@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hugh@veritas.com>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

__add_to_swap_cache unconditionally sets the page locked, which can be
a bit alarming to the unsuspecting reader: in the code paths where the
page is visible to other CPUs, the page should be (and is) already locked.

Instead, just add a check to ensure the page is locked here, and teach
the one path relying on the old behaviour to call SetPageLocked itself.

Signed-off-by: Nick Piggin <npiggin@suse.de>

Index: linux-2.6/mm/swap_state.c
===================================================================
--- linux-2.6.orig/mm/swap_state.c
+++ linux-2.6/mm/swap_state.c
@@ -74,6 +74,7 @@ static int __add_to_swap_cache(struct pa
 {
 	int error;
 
+	BUG_ON(!PageLocked(page));
 	BUG_ON(PageSwapCache(page));
 	BUG_ON(PagePrivate(page));
 	error = radix_tree_preload(gfp_mask);
@@ -83,7 +84,6 @@ static int __add_to_swap_cache(struct pa
 						entry.val, page);
 		if (!error) {
 			page_cache_get(page);
-			SetPageLocked(page);
 			SetPageSwapCache(page);
 			set_page_private(page, entry.val);
 			total_swapcache_pages++;
@@ -338,6 +338,7 @@ struct page *read_swap_cache_async(swp_e
 								vma, addr);
 			if (!new_page)
 				break;		/* Out of memory */
+			SetPageLocked(new_page);/* could be non-atomic op */
 		}
 
 		/*
@@ -361,7 +362,9 @@ struct page *read_swap_cache_async(swp_e
 		}
 	} while (err != -ENOENT && err != -ENOMEM);
 
-	if (new_page)
+	if (new_page) {
+		ClearPageLocked(new_page);
 		page_cache_release(new_page);
+	}
 	return found_page;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
