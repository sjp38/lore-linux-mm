Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id D30426B0038
	for <linux-mm@kvack.org>; Tue, 21 Nov 2017 16:13:07 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id u3so13946963pgn.3
        for <linux-mm@kvack.org>; Tue, 21 Nov 2017 13:13:07 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id a83sor4232444pfj.32.2017.11.21.13.13.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 21 Nov 2017 13:13:05 -0800 (PST)
From: Shakeel Butt <shakeelb@google.com>
Subject: [PATCH v2] mm, mlock, vmscan: no more skipping pagevecs
Date: Tue, 21 Nov 2017 13:12:41 -0800
Message-Id: <20171121211241.18877-1-shakeelb@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Huang Ying <ying.huang@intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, Michal Hocko <mhocko@kernel.org>, Greg Thelen <gthelen@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <bsingharora@gmail.com>, Minchan Kim <minchan@kernel.org>, Shaohua Li <shli@fb.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Jan Kara <jack@suse.cz>, Nicholas Piggin <npiggin@gmail.com>, Dan Williams <dan.j.williams@intel.com>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Shakeel Butt <shakeelb@google.com>

When a thread mlocks an address space backed either by file
pages which are currently not present in memory or swapped
out anon pages (not in swapcache), a new page is allocated
and added to the local pagevec (lru_add_pvec), I/O is triggered
and the thread then sleeps on the page. On I/O completion, the
thread can wake on a different CPU, the mlock syscall will then
sets the PageMlocked() bit of the page but will not be able to
put that page in unevictable LRU as the page is on the pagevec
of a different CPU. Even on drain, that page will go to evictable
LRU because the PageMlocked() bit is not checked on pagevec
drain.

The page will eventually go to right LRU on reclaim but the
LRU stats will remain skewed for a long time.

This patch put all the pages, even unevictable, to the pagevecs
and on the drain, the pages will be added on their LRUs correctly
by checking their evictability. This resolves the mlocked pages
on pagevec of other CPUs issue because when those pagevecs will
be drained, the mlocked file pages will go to unevictable LRU.
Also this makes the race with munlock easier to resolve because
the pagevec drains happen in LRU lock.

However there is still one place which makes a page evictable
and does PageLRU check on that page without LRU lock and needs
special attention. TestClearPageMlocked() and isolate_lru_page()
in clear_page_mlock().

	#0: __pagevec_lru_add_fn	#1: clear_page_mlock

	SetPageLRU()			if (!TestClearPageMlocked())
					  return
	smp_mb() // <--required
					// inside does PageLRU
	if (!PageMlocked())		if (isolate_lru_page())
	  move to evictable LRU		  putback_lru_page()
	else
	  move to unevictable LRU

In '#1', TestClearPageMlocked() provides full memory barrier
semantics and thus the PageLRU check (inside isolate_lru_page)
can not be reordered before it.

In '#0', without explicit memory barrier, the PageMlocked() check
can be reordered before SetPageLRU(). If that happens, '#0' can
put a page in unevictable LRU and '#1' might have just cleared the
Mlocked bit of that page but fails to isolate as PageLRU fails as
'#0' still hasn't set PageLRU bit of that page. That page will be
stranded on the unevictable LRU.

There is one (good) side effect though. Without this patch, the
pages allocated for System V shared memory segment are added to
evictable LRUs even after shmctl(SHM_LOCK) on that segment. This
patch will correctly put such pages to unevictable LRU.

Signed-off-by: Shakeel Butt <shakeelb@google.com>
Acked-by: Vlastimil Babka <vbabka@suse.cz>

---
Changelog since v1:
- Fixed the commit message.
- Added more comments based on Johannes's suggestion.

 include/linux/swap.h |  2 --
 mm/mlock.c           |  6 ++++
 mm/swap.c            | 82 ++++++++++++++++++++++++++++++----------------------
 mm/vmscan.c          | 59 +------------------------------------
 4 files changed, 54 insertions(+), 95 deletions(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index c2b8128799c1..4aebd2b760c8 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -338,8 +338,6 @@ extern void deactivate_file_page(struct page *page);
 extern void mark_page_lazyfree(struct page *page);
 extern void swap_setup(void);
 
-extern void add_page_to_unevictable_list(struct page *page);
-
 extern void lru_cache_add_active_or_unevictable(struct page *page,
 						struct vm_area_struct *vma);
 
diff --git a/mm/mlock.c b/mm/mlock.c
index 30472d438794..c3d2d0d3d73b 100644
--- a/mm/mlock.c
+++ b/mm/mlock.c
@@ -64,6 +64,12 @@ void clear_page_mlock(struct page *page)
 	mod_zone_page_state(page_zone(page), NR_MLOCK,
 			    -hpage_nr_pages(page));
 	count_vm_event(UNEVICTABLE_PGCLEARED);
+	/*
+	 * The previous TestClearPageMlocked() corresponds to the smp_mb()
+	 * in __pagevec_lru_add_fn().
+	 *
+	 * See __pagevec_lru_add_fn for more explanation.
+	 */
 	if (!isolate_lru_page(page)) {
 		putback_lru_page(page);
 	} else {
diff --git a/mm/swap.c b/mm/swap.c
index 38e1b6374a97..31869a543270 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -445,30 +445,6 @@ void lru_cache_add(struct page *page)
 	__lru_cache_add(page);
 }
 
-/**
- * add_page_to_unevictable_list - add a page to the unevictable list
- * @page:  the page to be added to the unevictable list
- *
- * Add page directly to its zone's unevictable list.  To avoid races with
- * tasks that might be making the page evictable, through eg. munlock,
- * munmap or exit, while it's not on the lru, we want to add the page
- * while it's locked or otherwise "invisible" to other tasks.  This is
- * difficult to do when using the pagevec cache, so bypass that.
- */
-void add_page_to_unevictable_list(struct page *page)
-{
-	struct pglist_data *pgdat = page_pgdat(page);
-	struct lruvec *lruvec;
-
-	spin_lock_irq(&pgdat->lru_lock);
-	lruvec = mem_cgroup_page_lruvec(page, pgdat);
-	ClearPageActive(page);
-	SetPageUnevictable(page);
-	SetPageLRU(page);
-	add_page_to_lru_list(page, lruvec, LRU_UNEVICTABLE);
-	spin_unlock_irq(&pgdat->lru_lock);
-}
-
 /**
  * lru_cache_add_active_or_unevictable
  * @page:  the page to be added to LRU
@@ -484,13 +460,9 @@ void lru_cache_add_active_or_unevictable(struct page *page,
 {
 	VM_BUG_ON_PAGE(PageLRU(page), page);
 
-	if (likely((vma->vm_flags & (VM_LOCKED | VM_SPECIAL)) != VM_LOCKED)) {
+	if (likely((vma->vm_flags & (VM_LOCKED | VM_SPECIAL)) != VM_LOCKED))
 		SetPageActive(page);
-		lru_cache_add(page);
-		return;
-	}
-
-	if (!TestSetPageMlocked(page)) {
+	else if (!TestSetPageMlocked(page)) {
 		/*
 		 * We use the irq-unsafe __mod_zone_page_stat because this
 		 * counter is not modified from interrupt context, and the pte
@@ -500,7 +472,7 @@ void lru_cache_add_active_or_unevictable(struct page *page,
 				    hpage_nr_pages(page));
 		count_vm_event(UNEVICTABLE_PGMLOCKED);
 	}
-	add_page_to_unevictable_list(page);
+	lru_cache_add(page);
 }
 
 /*
@@ -886,15 +858,55 @@ void lru_add_page_tail(struct page *page, struct page *page_tail,
 static void __pagevec_lru_add_fn(struct page *page, struct lruvec *lruvec,
 				 void *arg)
 {
-	int file = page_is_file_cache(page);
-	int active = PageActive(page);
-	enum lru_list lru = page_lru(page);
+	enum lru_list lru;
+	int was_unevictable = TestClearPageUnevictable(page);
 
 	VM_BUG_ON_PAGE(PageLRU(page), page);
 
 	SetPageLRU(page);
+	/*
+	 * Page becomes evictable in two ways:
+	 * 1) Within LRU lock [munlock_vma_pages() and __munlock_pagevec()].
+	 * 2) Before acquiring LRU lock to put the page to correct LRU and then
+	 *   a) do PageLRU check with lock [check_move_unevictable_pages]
+	 *   b) do PageLRU check before lock [clear_page_mlock]
+	 *
+	 * (1) & (2a) are ok as LRU lock will serialize them. For (2b), we need
+	 * following strict ordering:
+	 *
+	 * #0: __pagevec_lru_add_fn		#1: clear_page_mlock
+	 *
+	 * SetPageLRU()				TestClearPageMlocked()
+	 * smp_mb() // explicit ordering	// above provides strict
+	 *					// ordering
+	 * PageMlocked()			PageLRU()
+	 *
+	 *
+	 * if '#1' does not observe setting of PG_lru by '#0' and fails
+	 * isolation, the explicit barrier will make sure that page_evictable
+	 * check will put the page in correct LRU. Without smp_mb(), SetPageLRU
+	 * can be reordered after PageMlocked check and can make '#1' to fail
+	 * the isolation of the page whose Mlocked bit is cleared (#0 is also
+	 * looking at the same page) and the evictable page will be stranded
+	 * in an unevictable LRU.
+	 */
+	smp_mb();
+
+	if (page_evictable(page)) {
+		lru = page_lru(page);
+		update_page_reclaim_stat(lruvec, page_is_file_cache(page),
+					 PageActive(page));
+		if (was_unevictable)
+			count_vm_event(UNEVICTABLE_PGRESCUED);
+	} else {
+		lru = LRU_UNEVICTABLE;
+		ClearPageActive(page);
+		SetPageUnevictable(page);
+		if (!was_unevictable)
+			count_vm_event(UNEVICTABLE_PGCULLED);
+	}
+
 	add_page_to_lru_list(page, lruvec, lru);
-	update_page_reclaim_stat(lruvec, file, active);
 	trace_mm_lru_insertion(page, lru);
 }
 
diff --git a/mm/vmscan.c b/mm/vmscan.c
index c02c850ea349..0cc1304b86d2 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -787,64 +787,7 @@ int remove_mapping(struct address_space *mapping, struct page *page)
  */
 void putback_lru_page(struct page *page)
 {
-	bool is_unevictable;
-	int was_unevictable = PageUnevictable(page);
-
-	VM_BUG_ON_PAGE(PageLRU(page), page);
-
-redo:
-	ClearPageUnevictable(page);
-
-	if (page_evictable(page)) {
-		/*
-		 * For evictable pages, we can use the cache.
-		 * In event of a race, worst case is we end up with an
-		 * unevictable page on [in]active list.
-		 * We know how to handle that.
-		 */
-		is_unevictable = false;
-		lru_cache_add(page);
-	} else {
-		/*
-		 * Put unevictable pages directly on zone's unevictable
-		 * list.
-		 */
-		is_unevictable = true;
-		add_page_to_unevictable_list(page);
-		/*
-		 * When racing with an mlock or AS_UNEVICTABLE clearing
-		 * (page is unlocked) make sure that if the other thread
-		 * does not observe our setting of PG_lru and fails
-		 * isolation/check_move_unevictable_pages,
-		 * we see PG_mlocked/AS_UNEVICTABLE cleared below and move
-		 * the page back to the evictable list.
-		 *
-		 * The other side is TestClearPageMlocked() or shmem_lock().
-		 */
-		smp_mb();
-	}
-
-	/*
-	 * page's status can change while we move it among lru. If an evictable
-	 * page is on unevictable list, it never be freed. To avoid that,
-	 * check after we added it to the list, again.
-	 */
-	if (is_unevictable && page_evictable(page)) {
-		if (!isolate_lru_page(page)) {
-			put_page(page);
-			goto redo;
-		}
-		/* This means someone else dropped this page from LRU
-		 * So, it will be freed or putback to LRU again. There is
-		 * nothing to do here.
-		 */
-	}
-
-	if (was_unevictable && !is_unevictable)
-		count_vm_event(UNEVICTABLE_PGRESCUED);
-	else if (!was_unevictable && is_unevictable)
-		count_vm_event(UNEVICTABLE_PGCULLED);
-
+	lru_cache_add(page);
 	put_page(page);		/* drop ref from isolate */
 }
 
-- 
2.15.0.448.gf294e3d99a-goog

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
