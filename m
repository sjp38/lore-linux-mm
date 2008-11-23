Date: Sun, 23 Nov 2008 22:01:56 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: [PATCH 5/8] mm: try_to_unuse check removing right swap
In-Reply-To: <Pine.LNX.4.64.0811232151400.3748@blonde.site>
Message-ID: <Pine.LNX.4.64.0811232200560.4142@blonde.site>
References: <Pine.LNX.4.64.0811232151400.3748@blonde.site>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

There's a possible race in try_to_unuse() which Nick Piggin led me to two
years ago.  Where it does lock_page() after read_swap_cache_async(), what
if another task removed that page from swapcache just before we locked it?

It would sail though the (*swap_map > 1) tests doing nothing (because it
could not have been removed from swapcache before its swap references were
gone), until it reaches the delete_from_swap_cache(page) near the bottom.

Now imagine that this page has been allocated to swap on a different swap
area while we dropped page lock (perhaps at the top, perhaps in unuse_mm):
we could wrongly remove from swap cache before the page has been written
to swap, so a subsequent do_swap_page() would read in stale data from swap.

I think this case could not happen before: remove_exclusive_swap_page()
refused while page count was raised.  But now with reuse_swap_page() and
try_to_free_swap() removing from swap cache without minding page count,
I think it could happen - the previous patch argued that it was safe
because try_to_unuse() already ignored page count, but overlooked that
it might be breaking the assumptions in try_to_unuse() itself.

Signed-off-by: Hugh Dickins <hugh@veritas.com>
---

 mm/swapfile.c |   11 ++++++++++-
 1 file changed, 10 insertions(+), 1 deletion(-)

--- swapfree4/mm/swapfile.c	2008-11-21 18:50:50.000000000 +0000
+++ swapfree5/mm/swapfile.c	2008-11-21 18:50:59.000000000 +0000
@@ -889,7 +889,16 @@ static int try_to_unuse(unsigned int typ
 			lock_page(page);
 			wait_on_page_writeback(page);
 		}
-		if (PageSwapCache(page))
+
+		/*
+		 * It is conceivable that a racing task removed this page from
+		 * swap cache just before we acquired the page lock at the top,
+		 * or while we dropped it in unuse_mm().  The page might even
+		 * be back in swap cache on another swap area: that we must not
+		 * delete, since it may not have been written out to swap yet.
+		 */
+		if (PageSwapCache(page) &&
+		    likely(page_private(page) == entry.val))
 			delete_from_swap_cache(page);
 
 		/*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
