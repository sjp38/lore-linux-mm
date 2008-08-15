Date: Fri, 15 Aug 2008 21:49:25 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: [PATCH] mm: page_remove_rmap comments on PageAnon
Message-ID: <Pine.LNX.4.64.0808152146220.7958@blonde.site>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Add a comment to s390's page_test_dirty/page_clear_dirty/page_set_dirty
dance in page_remove_rmap(): I was wrong to think the PageSwapCache test
could be avoided, and would like a comment in there to remind me.  And
mention s390, to help us remember that this block is not really common.

Also move down the "It would be tidy to reset PageAnon" comment: it does
not belong to s390's block, and it would be unwise to reset PageAnon
before we're done with testing it.

Signed-off-by: Hugh Dickins <hugh@veritas.com>
---
No big deal, but I hope for 2.6.27.

 mm/rmap.c |   25 ++++++++++++++++---------
 1 file changed, 16 insertions(+), 9 deletions(-)

--- 2.6.27-rc3/mm/rmap.c	2008-08-06 08:36:20.000000000 +0100
+++ linux/mm/rmap.c	2008-08-13 04:33:56.000000000 +0100
@@ -659,23 +659,30 @@ void page_remove_rmap(struct page *page,
 		}
 
 		/*
-		 * It would be tidy to reset the PageAnon mapping here,
-		 * but that might overwrite a racing page_add_anon_rmap
-		 * which increments mapcount after us but sets mapping
-		 * before us: so leave the reset to free_hot_cold_page,
-		 * and remember that it's only reliable while mapped.
-		 * Leaving it set also helps swapoff to reinstate ptes
-		 * faster for those pages still in swapcache.
+		 * Now that the last pte has gone, s390 must transfer dirty
+		 * flag from storage key to struct page.  We can usually skip
+		 * this if the page is anon, so about to be freed; but perhaps
+		 * not if it's in swapcache - there might be another pte slot
+		 * containing the swap entry, but page not yet written to swap.
 		 */
 		if ((!PageAnon(page) || PageSwapCache(page)) &&
 		    page_test_dirty(page)) {
 			page_clear_dirty(page);
 			set_page_dirty(page);
 		}
-		mem_cgroup_uncharge_page(page);
 
+		mem_cgroup_uncharge_page(page);
 		__dec_zone_page_state(page,
-				PageAnon(page) ? NR_ANON_PAGES : NR_FILE_MAPPED);
+			PageAnon(page) ? NR_ANON_PAGES : NR_FILE_MAPPED);
+		/*
+		 * It would be tidy to reset the PageAnon mapping here,
+		 * but that might overwrite a racing page_add_anon_rmap
+		 * which increments mapcount after us but sets mapping
+		 * before us: so leave the reset to free_hot_cold_page,
+		 * and remember that it's only reliable while mapped.
+		 * Leaving it set also helps swapoff to reinstate ptes
+		 * faster for those pages still in swapcache.
+		 */
 	}
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
