Date: Sun, 23 Nov 2008 22:00:46 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: [PATCH 4/8] mm: try_to_free_swap replaces remove_exclusive_swap_page
In-Reply-To: <Pine.LNX.4.64.0811232151400.3748@blonde.site>
Message-ID: <Pine.LNX.4.64.0811232159030.4142@blonde.site>
References: <Pine.LNX.4.64.0811232151400.3748@blonde.site>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Rik van Riel <riel@redhat.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

It doesn't matter if someone else has a reference to the page (raised
page_count); it doesn't matter if the page is mapped into userspace
(raised page_mapcount - though that hints it may be worth keeping the
swap): all that matters is that there be no more references to the swap
(and no writeback in progress).

swapoff (try_to_unuse) has been removing pages from swapcache for years,
with no concern for page count or page mapcount, and we used to have a
comment in lookup_swap_cache() recognizing that: if you go for a page
of swapcache, you'll get the right page, but it could have been removed
from swapcache by the time you get page lock.

So, give up asking for exclusivity: get rid of remove_exclusive_swap_page(),
and remove_exclusive_swap_page_ref() and remove_exclusive_swap_page_count()
which were spawned for the recent LRU work: replace them by the simpler
try_to_free_swap() which just checks page_swapcount().

Similarly, remove the page_count limitation from free_swap_and_count(),
but assume that it's worth holding on to the swap if page is mapped and
swap nowhere near full.  Add a vm_swap_full() test in free_swap_cache()?
It would be consistent, but I think we probably have enough for now.

Signed-off-by: Hugh Dickins <hugh@veritas.com>
---

 include/linux/swap.h |   10 +----
 mm/memory.c          |    2 -
 mm/page_io.c         |    2 -
 mm/swap.c            |    3 -
 mm/swap_state.c      |    8 ++--
 mm/swapfile.c        |   70 +++++++----------------------------------
 mm/vmscan.c          |    2 -
 7 files changed, 22 insertions(+), 75 deletions(-)

--- swapfree3/include/linux/swap.h	2008-11-21 18:50:47.000000000 +0000
+++ swapfree4/include/linux/swap.h	2008-11-21 18:50:50.000000000 +0000
@@ -308,8 +308,7 @@ extern sector_t map_swap_page(struct swa
 extern sector_t swapdev_block(int, pgoff_t);
 extern struct swap_info_struct *get_swap_info_struct(unsigned);
 extern int reuse_swap_page(struct page *);
-extern int remove_exclusive_swap_page(struct page *);
-extern int remove_exclusive_swap_page_ref(struct page *);
+extern int try_to_free_swap(struct page *);
 struct backing_dev_info;
 
 /* linux/mm/thrash.c */
@@ -391,12 +390,7 @@ static inline void delete_from_swap_cach
 
 #define reuse_swap_page(page)	(page_mapcount(page) == 1)
 
-static inline int remove_exclusive_swap_page(struct page *p)
-{
-	return 0;
-}
-
-static inline int remove_exclusive_swap_page_ref(struct page *page)
+static inline int try_to_free_swap(struct page *page)
 {
 	return 0;
 }
--- swapfree3/mm/memory.c	2008-11-21 18:50:48.000000000 +0000
+++ swapfree4/mm/memory.c	2008-11-21 18:50:50.000000000 +0000
@@ -2374,7 +2374,7 @@ static int do_swap_page(struct mm_struct
 
 	swap_free(entry);
 	if (vm_swap_full() || (vma->vm_flags & VM_LOCKED) || PageMlocked(page))
-		remove_exclusive_swap_page(page);
+		try_to_free_swap(page);
 	unlock_page(page);
 
 	if (write_access) {
--- swapfree3/mm/page_io.c	2008-11-19 15:26:26.000000000 +0000
+++ swapfree4/mm/page_io.c	2008-11-21 18:50:50.000000000 +0000
@@ -98,7 +98,7 @@ int swap_writepage(struct page *page, st
 	struct bio *bio;
 	int ret = 0, rw = WRITE;
 
-	if (remove_exclusive_swap_page(page)) {
+	if (try_to_free_swap(page)) {
 		unlock_page(page);
 		goto out;
 	}
--- swapfree3/mm/swap.c	2008-11-19 15:26:28.000000000 +0000
+++ swapfree4/mm/swap.c	2008-11-21 18:50:50.000000000 +0000
@@ -467,8 +467,7 @@ void pagevec_swap_free(struct pagevec *p
 		struct page *page = pvec->pages[i];
 
 		if (PageSwapCache(page) && trylock_page(page)) {
-			if (PageSwapCache(page))
-				remove_exclusive_swap_page_ref(page);
+			try_to_free_swap(page);
 			unlock_page(page);
 		}
 	}
--- swapfree3/mm/swap_state.c	2008-11-19 15:26:26.000000000 +0000
+++ swapfree4/mm/swap_state.c	2008-11-21 18:50:50.000000000 +0000
@@ -195,14 +195,14 @@ void delete_from_swap_cache(struct page 
  * If we are the only user, then try to free up the swap cache. 
  * 
  * Its ok to check for PageSwapCache without the page lock
- * here because we are going to recheck again inside 
- * exclusive_swap_page() _with_ the lock. 
+ * here because we are going to recheck again inside
+ * try_to_free_swap() _with_ the lock.
  * 					- Marcelo
  */
 static inline void free_swap_cache(struct page *page)
 {
-	if (PageSwapCache(page) && trylock_page(page)) {
-		remove_exclusive_swap_page(page);
+	if (PageSwapCache(page) && !page_mapped(page) && trylock_page(page)) {
+		try_to_free_swap(page);
 		unlock_page(page);
 	}
 }
--- swapfree3/mm/swapfile.c	2008-11-21 18:50:48.000000000 +0000
+++ swapfree4/mm/swapfile.c	2008-11-21 18:50:50.000000000 +0000
@@ -348,68 +348,23 @@ int reuse_swap_page(struct page *page)
 }
 
 /*
- * Work out if there are any other processes sharing this
- * swap cache page. Free it if you can. Return success.
+ * If swap is getting full, or if there are no more mappings of this page,
+ * then try_to_free_swap is called to free its swap space.
  */
-static int remove_exclusive_swap_page_count(struct page *page, int count)
+int try_to_free_swap(struct page *page)
 {
-	int retval;
-	struct swap_info_struct * p;
-	swp_entry_t entry;
-
 	VM_BUG_ON(!PageLocked(page));
 
 	if (!PageSwapCache(page))
 		return 0;
 	if (PageWriteback(page))
 		return 0;
-	if (page_count(page) != count) /* us + cache + ptes */
-		return 0;
-
-	entry.val = page_private(page);
-	p = swap_info_get(entry);
-	if (!p)
+	if (page_swapcount(page))
 		return 0;
 
-	/* Is the only swap cache user the cache itself? */
-	retval = 0;
-	if (p->swap_map[swp_offset(entry)] == 1) {
-		/* Recheck the page count with the swapcache lock held.. */
-		spin_lock_irq(&swapper_space.tree_lock);
-		if ((page_count(page) == count) && !PageWriteback(page)) {
-			__delete_from_swap_cache(page);
-			SetPageDirty(page);
-			retval = 1;
-		}
-		spin_unlock_irq(&swapper_space.tree_lock);
-	}
-	spin_unlock(&swap_lock);
-
-	if (retval) {
-		swap_free(entry);
-		page_cache_release(page);
-	}
-
-	return retval;
-}
-
-/*
- * Most of the time the page should have two references: one for the
- * process and one for the swap cache.
- */
-int remove_exclusive_swap_page(struct page *page)
-{
-	return remove_exclusive_swap_page_count(page, 2);
-}
-
-/*
- * The pageout code holds an extra reference to the page.  That raises
- * the reference count to test for to 2 for a page that is only in the
- * swap cache plus 1 for each process that maps the page.
- */
-int remove_exclusive_swap_page_ref(struct page *page)
-{
-	return remove_exclusive_swap_page_count(page, 2 + page_mapcount(page));
+	delete_from_swap_cache(page);
+	SetPageDirty(page);
+	return 1;
 }
 
 /*
@@ -436,13 +391,12 @@ void free_swap_and_cache(swp_entry_t ent
 		spin_unlock(&swap_lock);
 	}
 	if (page) {
-		int one_user;
-
-		one_user = (page_count(page) == 2);
-		/* Only cache user (+us), or swap space full? Free it! */
-		/* Also recheck PageSwapCache after page is locked (above) */
+		/*
+		 * Not mapped elsewhere, or swap space full? Free it!
+		 * Also recheck PageSwapCache now page is locked (above).
+		 */
 		if (PageSwapCache(page) && !PageWriteback(page) &&
-					(one_user || vm_swap_full())) {
+				(!page_mapped(page) || vm_swap_full())) {
 			delete_from_swap_cache(page);
 			SetPageDirty(page);
 		}
--- swapfree3/mm/vmscan.c	2008-11-19 15:26:13.000000000 +0000
+++ swapfree4/mm/vmscan.c	2008-11-21 18:50:50.000000000 +0000
@@ -805,7 +805,7 @@ cull_mlocked:
 activate_locked:
 		/* Not a candidate for swapping, so reclaim swap space. */
 		if (PageSwapCache(page) && vm_swap_full())
-			remove_exclusive_swap_page_ref(page);
+			try_to_free_swap(page);
 		VM_BUG_ON(PageActive(page));
 		SetPageActive(page);
 keep_locked:

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
