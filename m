Date: Wed, 21 Jan 2004 22:36:08 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [BENCHMARKS] Namesys VM patches improve kbuild
Message-Id: <20040121223608.1ea30097.akpm@osdl.org>
In-Reply-To: <400F630F.80205@cyberone.com.au>
References: <400F630F.80205@cyberone.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <piggin@cyberone.com.au>
Cc: linux-mm@kvack.org, Nikita@Namesys.COM
List-ID: <linux-mm.kvack.org>

Nick Piggin <piggin@cyberone.com.au> wrote:
>
> Hi,
> 
> The two namesys patches help kbuild quite a lot here.
> http://www.kerneltrap.org/~npiggin/vm/1/
> 
> The patches can be found at
> http://thebsh.namesys.com/snapshots/LATEST/extra/

I played with these back in July.  Had a few stability problems then but
yes, they did speed up some workloads a lot.


> I don't have much to comment on the patches. They do include
> some cleanup stuff which should be broken out.

Yup.  <dig, dig>  See below - it's six months old though.

> I don't really understand the dont-rotate-active-list patch:
> I don't see why we're losing LRU information because the pages
> that go to the head of the active list get their referenced
> bits cleared.

Yes, I do think that the "LRU" is a bit of a misnomer - it's very
approximate and only really suits simple workloads.  I suspect that once
things get hot and heavy the "lru" is only four-deep:
unreferenced/inactive, referenced/inactive, unreferenced/active and
referenced/active.

Can you test the patches separately, see what bits are actually helping?

Watch out for kswapd CPU utilisation as well - some of those changes have
the potential to increase it.




 include/linux/page-flags.h |    7 +++++++
 mm/page_alloc.c            |    1 +
 mm/truncate.c              |    2 ++
 mm/vmscan.c                |   10 ++++++++--
 5 files changed, 18 insertions(+), 2 deletions(-)

diff -puN include/linux/mm_inline.h~skip-writepage include/linux/mm_inline.h
diff -puN include/linux/page-flags.h~skip-writepage include/linux/page-flags.h
--- 25/include/linux/page-flags.h~skip-writepage	2003-07-09 02:58:48.000000000 -0700
+++ 25-akpm/include/linux/page-flags.h	2003-07-09 02:58:48.000000000 -0700
@@ -75,6 +75,7 @@
 #define PG_mappedtodisk		17	/* Has blocks allocated on-disk */
 #define PG_reclaim		18	/* To be reclaimed asap */
 #define PG_compound		19	/* Part of a compound page */
+#define PG_skipped		20	/* ->writepage() was skipped on this page */
 
 
 /*
@@ -267,6 +268,12 @@ extern void get_full_page_state(struct p
 #define SetPageCompound(page)	set_bit(PG_compound, &(page)->flags)
 #define ClearPageCompound(page)	clear_bit(PG_compound, &(page)->flags)
 
+#define PageSkipped(page)	test_bit(PG_skipped, &(page)->flags)
+#define SetPageSkipped(page)	set_bit(PG_skipped, &(page)->flags)
+#define TestSetPageSkipped(page)	test_and_set_bit(PG_skipped, &(page)->flags)
+#define ClearPageSkipped(page)		clear_bit(PG_skipped, &(page)->flags)
+#define TestClearPageSkipped(page)	test_and_clear_bit(PG_skipped, &(page)->flags)
+
 /*
  * The PageSwapCache predicate doesn't use a PG_flag at this time,
  * but it may again do so one day.
diff -puN mm/vmscan.c~skip-writepage mm/vmscan.c
--- 25/mm/vmscan.c~skip-writepage	2003-07-09 02:58:48.000000000 -0700
+++ 25-akpm/mm/vmscan.c	2003-07-09 03:05:43.000000000 -0700
@@ -328,6 +328,8 @@ shrink_list(struct list_head *page_list,
 		 * See swapfile.c:page_queue_congested().
 		 */
 		if (PageDirty(page)) {
+			if (!TestSetPageSkipped(page))
+				goto keep_locked;
 			if (!is_page_cache_freeable(page))
 				goto keep_locked;
 			if (!mapping)
@@ -351,6 +353,7 @@ shrink_list(struct list_head *page_list,
 				list_move(&page->list, &mapping->locked_pages);
 				spin_unlock(&mapping->page_lock);
 
+				ClearPageSkipped(page);
 				SetPageReclaim(page);
 				res = mapping->a_ops->writepage(page, &wbc);
 
@@ -533,10 +536,13 @@ shrink_cache(const int nr_pages, struct 
 			if (TestSetPageLRU(page))
 				BUG();
 			list_del(&page->lru);
-			if (PageActive(page))
+			if (PageActive(page)) {
+				if (PageSkipped(page))
+					ClearPageSkipped(page);
 				add_page_to_active_list(zone, page);
-			else
+			} else {
 				add_page_to_inactive_list(zone, page);
+			}
 			if (!pagevec_add(&pvec, page)) {
 				spin_unlock_irq(&zone->lru_lock);
 				__pagevec_release(&pvec);
diff -puN mm/truncate.c~skip-writepage mm/truncate.c
--- 25/mm/truncate.c~skip-writepage	2003-07-09 03:05:53.000000000 -0700
+++ 25-akpm/mm/truncate.c	2003-07-09 03:06:37.000000000 -0700
@@ -53,6 +53,7 @@ truncate_complete_page(struct address_sp
 	clear_page_dirty(page);
 	ClearPageUptodate(page);
 	ClearPageMappedToDisk(page);
+	ClearPageSkipped(page);
 	remove_from_page_cache(page);
 	page_cache_release(page);	/* pagecache ref */
 }
@@ -81,6 +82,7 @@ invalidate_complete_page(struct address_
 	__remove_from_page_cache(page);
 	spin_unlock(&mapping->page_lock);
 	ClearPageUptodate(page);
+	ClearPageSkipped(page);
 	page_cache_release(page);	/* pagecache ref */
 	return 1;
 }
diff -puN mm/page_alloc.c~skip-writepage mm/page_alloc.c
--- 25/mm/page_alloc.c~skip-writepage	2003-07-09 03:06:33.000000000 -0700
+++ 25-akpm/mm/page_alloc.c	2003-07-09 03:06:48.000000000 -0700
@@ -220,6 +220,7 @@ static inline void free_pages_check(cons
 			1 << PG_locked	|
 			1 << PG_active	|
 			1 << PG_reclaim	|
+			1 << PG_skipped	|
 			1 << PG_writeback )))
 		bad_page(function, page);
 	if (PageDirty(page))

_


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
