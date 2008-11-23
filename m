Date: Sun, 23 Nov 2008 22:05:09 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: [PATCH 7/8] mm: remove gfp_mask from add_to_swap
In-Reply-To: <Pine.LNX.4.64.0811232151400.3748@blonde.site>
Message-ID: <Pine.LNX.4.64.0811232204041.4142@blonde.site>
References: <Pine.LNX.4.64.0811232151400.3748@blonde.site>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Remove gfp_mask argument from add_to_swap(): it's misleading because its
only caller, shrink_page_list(), is not atomic at that point; and in due
course (implementing discard) we'll sometimes want to allocate some memory
with GFP_NOIO (as is used in swap_writepage) when allocating swap.

No change to the gfp_mask passed down to add_to_swap_cache(): still use
__GFP_HIGH without __GFP_WAIT (with nomemalloc and nowarn as before):
though it's not obvious if that's the best combination to ask for here.

Signed-off-by: Hugh Dickins <hugh@veritas.com>
---

 include/linux/swap.h |    2 +-
 mm/swap_state.c      |    4 ++--
 mm/vmscan.c          |    2 +-
 3 files changed, 4 insertions(+), 4 deletions(-)

--- swapfree6/include/linux/swap.h	2008-11-21 18:50:50.000000000 +0000
+++ swapfree7/include/linux/swap.h	2008-11-21 18:51:05.000000000 +0000
@@ -281,7 +281,7 @@ extern void end_swap_bio_read(struct bio
 extern struct address_space swapper_space;
 #define total_swapcache_pages  swapper_space.nrpages
 extern void show_swap_cache_info(void);
-extern int add_to_swap(struct page *, gfp_t);
+extern int add_to_swap(struct page *);
 extern int add_to_swap_cache(struct page *, swp_entry_t, gfp_t);
 extern void __delete_from_swap_cache(struct page *);
 extern void delete_from_swap_cache(struct page *);
--- swapfree6/mm/swap_state.c	2008-11-21 18:50:50.000000000 +0000
+++ swapfree7/mm/swap_state.c	2008-11-21 18:51:05.000000000 +0000
@@ -128,7 +128,7 @@ void __delete_from_swap_cache(struct pag
  * Allocate swap space for the page and add the page to the
  * swap cache.  Caller needs to hold the page lock. 
  */
-int add_to_swap(struct page * page, gfp_t gfp_mask)
+int add_to_swap(struct page *page)
 {
 	swp_entry_t entry;
 	int err;
@@ -153,7 +153,7 @@ int add_to_swap(struct page * page, gfp_
 		 * Add it to the swap cache and mark it dirty
 		 */
 		err = add_to_swap_cache(page, entry,
-				gfp_mask|__GFP_NOMEMALLOC|__GFP_NOWARN);
+				__GFP_HIGH|__GFP_NOMEMALLOC|__GFP_NOWARN);
 
 		switch (err) {
 		case 0:				/* Success */
--- swapfree6/mm/vmscan.c	2008-11-21 18:51:01.000000000 +0000
+++ swapfree7/mm/vmscan.c	2008-11-21 18:51:05.000000000 +0000
@@ -673,7 +673,7 @@ static unsigned long shrink_page_list(st
 		if (PageAnon(page) && !PageSwapCache(page)) {
 			if (!(sc->gfp_mask & __GFP_IO))
 				goto keep_locked;
-			if (!add_to_swap(page, GFP_ATOMIC))
+			if (!add_to_swap(page))
 				goto activate_locked;
 			may_enter_fs = 1;
 		}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
