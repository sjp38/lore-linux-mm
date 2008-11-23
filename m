Date: Sun, 23 Nov 2008 21:58:57 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: [PATCH 3/8] mm: reuse_swap_page replaces can_share_swap_page
In-Reply-To: <Pine.LNX.4.64.0811232151400.3748@blonde.site>
Message-ID: <Pine.LNX.4.64.0811232156120.4142@blonde.site>
References: <Pine.LNX.4.64.0811232151400.3748@blonde.site>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Rik van Riel <riel@redhat.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

A good place to free up old swap is where do_wp_page(), or do_swap_page(),
is about to redirty the page: the data on disk is then stale and won't be
read again; and if we do decide to write the page out later, using the
previous swap location makes an unnecessary disk seek very likely.

So give can_share_swap_page() the side-effect of delete_from_swap_cache()
when it safely can.  And can_share_swap_page() was always a misleading
name, the more so if it has a side-effect: rename it reuse_swap_page().

Irrelevant cleanup nearby: remove swap_token_default_timeout definition
from swap.h: it's used nowhere.

Signed-off-by: Hugh Dickins <hugh@veritas.com>
---
I'm going to have to ask for your indulgence on this one: please would
you put it in -mm on a trial basis?  There's nothing incorrect about it
that I know of, but I'm having difficulty understanding its performance,
and need to get on with sending in the rest of my patches.

What I'd intended to report is that it cuts 30% off the elapsed time of
a test which does random writes into 600MB on machine with 512MB RAM and
plenty of swap.  That's roughly consistent across different machines
with mem=512M.  (It does nothing much for my swapping load tests, which
may be too close to thrashing to notice.)  I took it for granted that it
would do nothing much for a similar test which writes sequentially into
600MB given 512MB RAM: but I was wrong, it adds 30% and I don't get why.

I also took it for granted that it would do nothing much for swapping to
SD card: wrong again, it adds 30% to the sequential test, but speeds up
the random test by a factor of... 25 times at first, but then later
measurements showed "only" a factor 7.

It's usually like this when I try to come up with numbers: I get lost in
them!  If the patch is in -mm for a while, maybe someone else can make
better sense of it: I'll come back to study what's going on later.

 include/linux/swap.h |    6 ++----
 mm/memory.c          |    4 ++--
 mm/swapfile.c        |   15 +++++++++++----
 3 files changed, 15 insertions(+), 10 deletions(-)

--- swapfree2/include/linux/swap.h	2008-11-19 15:26:28.000000000 +0000
+++ swapfree3/include/linux/swap.h	2008-11-21 18:50:47.000000000 +0000
@@ -307,7 +307,7 @@ extern unsigned int count_swap_pages(int
 extern sector_t map_swap_page(struct swap_info_struct *, pgoff_t);
 extern sector_t swapdev_block(int, pgoff_t);
 extern struct swap_info_struct *get_swap_info_struct(unsigned);
-extern int can_share_swap_page(struct page *);
+extern int reuse_swap_page(struct page *);
 extern int remove_exclusive_swap_page(struct page *);
 extern int remove_exclusive_swap_page_ref(struct page *);
 struct backing_dev_info;
@@ -375,8 +375,6 @@ static inline struct page *lookup_swap_c
 	return NULL;
 }
 
-#define can_share_swap_page(p)			(page_mapcount(p) == 1)
-
 static inline int add_to_swap_cache(struct page *page, swp_entry_t entry,
 							gfp_t gfp_mask)
 {
@@ -391,7 +389,7 @@ static inline void delete_from_swap_cach
 {
 }
 
-#define swap_token_default_timeout		0
+#define reuse_swap_page(page)	(page_mapcount(page) == 1)
 
 static inline int remove_exclusive_swap_page(struct page *p)
 {
--- swapfree2/mm/memory.c	2008-11-21 18:50:43.000000000 +0000
+++ swapfree3/mm/memory.c	2008-11-21 18:50:48.000000000 +0000
@@ -1832,7 +1832,7 @@ static int do_wp_page(struct mm_struct *
 			}
 			page_cache_release(old_page);
 		}
-		reuse = can_share_swap_page(old_page);
+		reuse = reuse_swap_page(old_page);
 		unlock_page(old_page);
 	} else if (unlikely((vma->vm_flags & (VM_WRITE|VM_SHARED)) ==
 					(VM_WRITE|VM_SHARED))) {
@@ -2363,7 +2363,7 @@ static int do_swap_page(struct mm_struct
 
 	inc_mm_counter(mm, anon_rss);
 	pte = mk_pte(page, vma->vm_page_prot);
-	if (write_access && can_share_swap_page(page)) {
+	if (write_access && reuse_swap_page(page)) {
 		pte = maybe_mkwrite(pte_mkdirty(pte), vma);
 		write_access = 0;
 	}
--- swapfree2/mm/swapfile.c	2008-11-19 15:26:26.000000000 +0000
+++ swapfree3/mm/swapfile.c	2008-11-21 18:50:48.000000000 +0000
@@ -326,17 +326,24 @@ static inline int page_swapcount(struct 
 }
 
 /*
- * We can use this swap cache entry directly
- * if there are no other references to it.
+ * We can write to an anon page without COW if there are no other references
+ * to it.  And as a side-effect, free up its swap: because the old content
+ * on disk will never be read, and seeking back there to write new content
+ * later would only waste time away from clustering.
  */
-int can_share_swap_page(struct page *page)
+int reuse_swap_page(struct page *page)
 {
 	int count;
 
 	VM_BUG_ON(!PageLocked(page));
 	count = page_mapcount(page);
-	if (count <= 1 && PageSwapCache(page))
+	if (count <= 1 && PageSwapCache(page)) {
 		count += page_swapcount(page);
+		if (count == 1 && !PageWriteback(page)) {
+			delete_from_swap_cache(page);
+			SetPageDirty(page);
+		}
+	}
 	return count == 1;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
