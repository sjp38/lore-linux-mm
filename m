Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 4E8C86B007E
	for <linux-mm@kvack.org>; Thu, 16 Sep 2010 07:26:41 -0400 (EDT)
Subject: [RFC]pagealloc: compensate a task for direct page reclaim
From: Shaohua Li <shaohua.li@intel.com>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 16 Sep 2010 19:26:36 +0800
Message-ID: <1284636396.1726.5.camel@shli-laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

A task enters into direct page reclaim, free some memory. But sometimes
the task can't get a free page after direct page reclaim because
other tasks take them (this is quite common in a multi-task workload
in my test). This behavior will bring extra latency to the task and is
unfair. Since the task already gets penalty, we'd better give it a compensation.
If a task frees some pages from direct page reclaim, we cache one freed page,
and the task will get it soon. We only consider order 0 allocation, because
it's hard to cache order > 0 page.

Below is a trace output when a task frees some pages in try_to_free_pages(), but
get_page_from_freelist() can't get a page in direct page reclaim.

<...>-809   [004]   730.218991: __alloc_pages_nodemask: progress 147, order 0, pid 809, comm mmap_test
<...>-806   [001]   730.237969: __alloc_pages_nodemask: progress 147, order 0, pid 806, comm mmap_test
<...>-810   [005]   730.237971: __alloc_pages_nodemask: progress 147, order 0, pid 810, comm mmap_test
<...>-809   [004]   730.237972: __alloc_pages_nodemask: progress 147, order 0, pid 809, comm mmap_test
<...>-811   [006]   730.241409: __alloc_pages_nodemask: progress 147, order 0, pid 811, comm mmap_test
<...>-809   [004]   730.241412: __alloc_pages_nodemask: progress 147, order 0, pid 809, comm mmap_test
<...>-812   [007]   730.241435: __alloc_pages_nodemask: progress 147, order 0, pid 812, comm mmap_test
<...>-809   [004]   730.245036: __alloc_pages_nodemask: progress 147, order 0, pid 809, comm mmap_test
<...>-809   [004]   730.260360: __alloc_pages_nodemask: progress 147, order 0, pid 809, comm mmap_test
<...>-805   [000]   730.260362: __alloc_pages_nodemask: progress 147, order 0, pid 805, comm mmap_test
<...>-811   [006]   730.263877: __alloc_pages_nodemask: progress 147, order 0, pid 811, comm mmap_test

Signed-off-by: Shaohua Li <shaohua.li@intel.com>
---
 include/linux/swap.h |    1 +
 mm/page_alloc.c      |   23 +++++++++++++++++++++++
 mm/vmscan.c          |   10 ++++++++++
 3 files changed, 34 insertions(+)

Index: linux/include/linux/swap.h
===================================================================
--- linux.orig/include/linux/swap.h	2010-09-16 11:01:56.000000000 +0800
+++ linux/include/linux/swap.h	2010-09-16 11:03:07.000000000 +0800
@@ -109,6 +109,7 @@ typedef struct {
  */
 struct reclaim_state {
 	unsigned long reclaimed_slab;
+	struct page **cached_page;
 };
 
 #ifdef __KERNEL__
Index: linux/mm/page_alloc.c
===================================================================
--- linux.orig/mm/page_alloc.c	2010-09-16 11:01:56.000000000 +0800
+++ linux/mm/page_alloc.c	2010-09-16 16:51:12.000000000 +0800
@@ -1837,6 +1837,21 @@ __alloc_pages_direct_compact(gfp_t gfp_m
 }
 #endif /* CONFIG_COMPACTION */
 
+static void prepare_cached_page(struct page *page, gfp_t gfp_mask)
+{
+	int wasMlocked = __TestClearPageMlocked(page);
+	unsigned long flags;
+
+	if (!free_pages_prepare(page, 0))
+		return;
+
+	local_irq_save(flags);
+	if (unlikely(wasMlocked))
+		free_page_mlock(page);
+	local_irq_restore(flags);
+	prep_new_page(page, 0, gfp_mask);
+}
+
 /* The really slow allocator path where we enter direct reclaim */
 static inline struct page *
 __alloc_pages_direct_reclaim(gfp_t gfp_mask, unsigned int order,
@@ -1856,6 +1871,10 @@ __alloc_pages_direct_reclaim(gfp_t gfp_m
 	p->flags |= PF_MEMALLOC;
 	lockdep_set_current_reclaim_state(gfp_mask);
 	reclaim_state.reclaimed_slab = 0;
+	if (order == 0)
+		reclaim_state.cached_page = &page;
+	else
+		reclaim_state.cached_page = NULL;
 	p->reclaim_state = &reclaim_state;
 
 	*did_some_progress = try_to_free_pages(zonelist, order, gfp_mask, nodemask);
@@ -1864,6 +1883,10 @@ __alloc_pages_direct_reclaim(gfp_t gfp_m
 	lockdep_clear_current_reclaim_state();
 	p->flags &= ~PF_MEMALLOC;
 
+	if (page) {
+		prepare_cached_page(page, gfp_mask);
+		return page;
+	}
 	cond_resched();
 
 	if (unlikely(!(*did_some_progress)))
Index: linux/mm/vmscan.c
===================================================================
--- linux.orig/mm/vmscan.c	2010-09-16 11:01:56.000000000 +0800
+++ linux/mm/vmscan.c	2010-09-16 11:03:07.000000000 +0800
@@ -626,9 +626,17 @@ static noinline_for_stack void free_page
 {
 	struct pagevec freed_pvec;
 	struct page *page, *tmp;
+	struct reclaim_state *reclaim_state = current->reclaim_state;
 
 	pagevec_init(&freed_pvec, 1);
 
+	if (!list_empty(free_pages) && reclaim_state &&
+			reclaim_state->cached_page) {
+		page = list_entry(free_pages->next, struct page, lru);
+		list_del(&page->lru);
+		*reclaim_state->cached_page = page;
+	}
+
 	list_for_each_entry_safe(page, tmp, free_pages, lru) {
 		list_del(&page->lru);
 		if (!pagevec_add(&freed_pvec, page)) {
@@ -2467,6 +2475,7 @@ unsigned long shrink_all_memory(unsigned
 	p->flags |= PF_MEMALLOC;
 	lockdep_set_current_reclaim_state(sc.gfp_mask);
 	reclaim_state.reclaimed_slab = 0;
+	reclaim_state.cached_page = NULL;
 	p->reclaim_state = &reclaim_state;
 
 	nr_reclaimed = do_try_to_free_pages(zonelist, &sc);
@@ -2655,6 +2664,7 @@ static int __zone_reclaim(struct zone *z
 	p->flags |= PF_MEMALLOC | PF_SWAPWRITE;
 	lockdep_set_current_reclaim_state(gfp_mask);
 	reclaim_state.reclaimed_slab = 0;
+	reclaim_state.cached_page = NULL;
 	p->reclaim_state = &reclaim_state;
 
 	if (zone_pagecache_reclaimable(zone) > zone->min_unmapped_pages) {


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
