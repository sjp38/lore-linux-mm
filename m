Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 88BBD6B0266
	for <linux-mm@kvack.org>; Wed, 18 Oct 2017 03:59:56 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id z55so2072281wrz.2
        for <linux-mm@kvack.org>; Wed, 18 Oct 2017 00:59:56 -0700 (PDT)
Received: from outbound-smtp10.blacknight.com (outbound-smtp10.blacknight.com. [46.22.139.15])
        by mx.google.com with ESMTPS id c64si111403edd.550.2017.10.18.00.59.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Oct 2017 00:59:54 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail04.blacknight.ie [81.17.254.17])
	by outbound-smtp10.blacknight.com (Postfix) with ESMTPS id A16C61C2F9B
	for <linux-mm@kvack.org>; Wed, 18 Oct 2017 08:59:54 +0100 (IST)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 7/8] mm, Remove cold parameter from free_hot_cold_page*
Date: Wed, 18 Oct 2017 08:59:51 +0100
Message-Id: <20171018075952.10627-8-mgorman@techsingularity.net>
In-Reply-To: <20171018075952.10627-1-mgorman@techsingularity.net>
References: <20171018075952.10627-1-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Jan Kara <jack@suse.cz>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Dave Chinner <david@fromorbit.com>, Mel Gorman <mgorman@techsingularity.net>

Most callers users of free_hot_cold_page claim the pages being released are
cache hot. The exception is the page reclaim paths where it is likely that
enough pages will be freed in the near future that the per-cpu lists are
going to be recycled and the cache hotness information is lost. As no one
really cares about the hotness of pages being released to the allocator,
just ditch the parameter.

The APIs are renamed to indicate that it's no longer about hot/cold pages. It
should also be less confusing as there are subtle differences between them.
__free_pages drops a reference and frees a page when the refcount reaches
zero. free_hot_cold_page handled pages whose refcount was already zero
which is non-obvious from the name. free_unref_page should be more obvious.

No performance impact is expected as the overhead is marginal. The parameter
is removed simply because it is a bit stupid to have a useless parameter
copied everywhere.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 arch/powerpc/mm/mmu_context_book3s64.c |  2 +-
 arch/powerpc/mm/pgtable_64.c           |  2 +-
 arch/sparc/mm/init_64.c                |  2 +-
 arch/tile/mm/homecache.c               |  2 +-
 include/linux/gfp.h                    |  4 ++--
 include/trace/events/kmem.h            | 11 ++++-------
 mm/page_alloc.c                        | 29 ++++++++++++-----------------
 mm/rmap.c                              |  2 +-
 mm/swap.c                              |  4 ++--
 mm/vmscan.c                            |  6 +++---
 10 files changed, 28 insertions(+), 36 deletions(-)

diff --git a/arch/powerpc/mm/mmu_context_book3s64.c b/arch/powerpc/mm/mmu_context_book3s64.c
index 05e15386d4cb..a7e998158f37 100644
--- a/arch/powerpc/mm/mmu_context_book3s64.c
+++ b/arch/powerpc/mm/mmu_context_book3s64.c
@@ -200,7 +200,7 @@ static void destroy_pagetable_page(struct mm_struct *mm)
 	/* We allow PTE_FRAG_NR fragments from a PTE page */
 	if (page_ref_sub_and_test(page, PTE_FRAG_NR - count)) {
 		pgtable_page_dtor(page);
-		free_hot_cold_page(page, 0);
+		free_unref_page(page);
 	}
 }
 
diff --git a/arch/powerpc/mm/pgtable_64.c b/arch/powerpc/mm/pgtable_64.c
index ac0717a90ca6..1ec3aee43624 100644
--- a/arch/powerpc/mm/pgtable_64.c
+++ b/arch/powerpc/mm/pgtable_64.c
@@ -404,7 +404,7 @@ void pte_fragment_free(unsigned long *table, int kernel)
 	if (put_page_testzero(page)) {
 		if (!kernel)
 			pgtable_page_dtor(page);
-		free_hot_cold_page(page, 0);
+		free_unref_page(page);
 	}
 }
 
diff --git a/arch/sparc/mm/init_64.c b/arch/sparc/mm/init_64.c
index b2ba410b26f4..42f535b6935a 100644
--- a/arch/sparc/mm/init_64.c
+++ b/arch/sparc/mm/init_64.c
@@ -2942,7 +2942,7 @@ pgtable_t pte_alloc_one(struct mm_struct *mm,
 	if (!page)
 		return NULL;
 	if (!pgtable_page_ctor(page)) {
-		free_hot_cold_page(page, 0);
+		free_unref_page(page);
 		return NULL;
 	}
 	return (pte_t *) page_address(page);
diff --git a/arch/tile/mm/homecache.c b/arch/tile/mm/homecache.c
index b51cc28acd0a..4432f31e8479 100644
--- a/arch/tile/mm/homecache.c
+++ b/arch/tile/mm/homecache.c
@@ -409,7 +409,7 @@ void __homecache_free_pages(struct page *page, unsigned int order)
 	if (put_page_testzero(page)) {
 		homecache_change_page_home(page, order, PAGE_HOME_HASH);
 		if (order == 0) {
-			free_hot_cold_page(page, false);
+			free_unref_page(page);
 		} else {
 			init_page_count(page);
 			__free_pages(page, order);
diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index f780718b7391..cc0cdbaa1b24 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -538,8 +538,8 @@ void * __meminit alloc_pages_exact_nid(int nid, size_t size, gfp_t gfp_mask);
 
 extern void __free_pages(struct page *page, unsigned int order);
 extern void free_pages(unsigned long addr, unsigned int order);
-extern void free_hot_cold_page(struct page *page, bool cold);
-extern void free_hot_cold_page_list(struct list_head *list, bool cold);
+extern void free_unref_page(struct page *page);
+extern void free_unref_page_list(struct list_head *list);
 
 struct page_frag_cache;
 extern void __page_frag_cache_drain(struct page *page, unsigned int count);
diff --git a/include/trace/events/kmem.h b/include/trace/events/kmem.h
index 6b2e154fd23a..8e87ee321c33 100644
--- a/include/trace/events/kmem.h
+++ b/include/trace/events/kmem.h
@@ -171,24 +171,21 @@ TRACE_EVENT(mm_page_free,
 
 TRACE_EVENT(mm_page_free_batched,
 
-	TP_PROTO(struct page *page, int cold),
+	TP_PROTO(struct page *page),
 
-	TP_ARGS(page, cold),
+	TP_ARGS(page),
 
 	TP_STRUCT__entry(
 		__field(	unsigned long,	pfn		)
-		__field(	int,		cold		)
 	),
 
 	TP_fast_assign(
 		__entry->pfn		= page_to_pfn(page);
-		__entry->cold		= cold;
 	),
 
-	TP_printk("page=%p pfn=%lu order=0 cold=%d",
+	TP_printk("page=%p pfn=%lu order=0",
 			pfn_to_page(__entry->pfn),
-			__entry->pfn,
-			__entry->cold)
+			__entry->pfn)
 );
 
 TRACE_EVENT(mm_page_alloc,
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 167e163cf733..13582efc57a0 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2590,7 +2590,7 @@ void mark_free_pages(struct zone *zone)
 }
 #endif /* CONFIG_PM */
 
-static bool free_hot_cold_page_prepare(struct page *page, unsigned long pfn)
+static bool free_unref_page_prepare(struct page *page, unsigned long pfn)
 {
 	int migratetype;
 
@@ -2602,8 +2602,7 @@ static bool free_hot_cold_page_prepare(struct page *page, unsigned long pfn)
 	return true;
 }
 
-static void free_hot_cold_page_commit(struct page *page, unsigned long pfn,
-				bool cold)
+static void free_unref_page_commit(struct page *page, unsigned long pfn)
 {
 	struct zone *zone = page_zone(page);
 	struct per_cpu_pages *pcp;
@@ -2628,10 +2627,7 @@ static void free_hot_cold_page_commit(struct page *page, unsigned long pfn,
 	}
 
 	pcp = &this_cpu_ptr(zone->pageset)->pcp;
-	if (!cold)
-		list_add(&page->lru, &pcp->lists[migratetype]);
-	else
-		list_add_tail(&page->lru, &pcp->lists[migratetype]);
+	list_add_tail(&page->lru, &pcp->lists[migratetype]);
 	pcp->count++;
 	if (pcp->count >= pcp->high) {
 		unsigned long batch = READ_ONCE(pcp->batch);
@@ -2642,25 +2638,24 @@ static void free_hot_cold_page_commit(struct page *page, unsigned long pfn,
 
 /*
  * Free a 0-order page
- * cold == true ? free a cold page : free a hot page
  */
-void free_hot_cold_page(struct page *page, bool cold)
+void free_unref_page(struct page *page)
 {
 	unsigned long flags;
 	unsigned long pfn = page_to_pfn(page);
 
-	if (!free_hot_cold_page_prepare(page, pfn))
+	if (!free_unref_page_prepare(page, pfn))
 		return;
 
 	local_irq_save(flags);
-	free_hot_cold_page_commit(page, pfn, cold);
+	free_unref_page_commit(page, pfn);
 	local_irq_restore(flags);
 }
 
 /*
  * Free a list of 0-order pages
  */
-void free_hot_cold_page_list(struct list_head *list, bool cold)
+void free_unref_page_list(struct list_head *list)
 {
 	struct page *page, *next;
 	unsigned long flags, pfn;
@@ -2668,7 +2663,7 @@ void free_hot_cold_page_list(struct list_head *list, bool cold)
 	/* Prepare pages for freeing */
 	list_for_each_entry_safe(page, next, list, lru) {
 		pfn = page_to_pfn(page);
-		if (!free_hot_cold_page_prepare(page, pfn))
+		if (!free_unref_page_prepare(page, pfn))
 			list_del(&page->lru);
 		page->private = pfn;
 	}
@@ -2678,8 +2673,8 @@ void free_hot_cold_page_list(struct list_head *list, bool cold)
 		unsigned long pfn = page->private;
 
 		page->private = 0;
-		trace_mm_page_free_batched(page, cold);
-		free_hot_cold_page_commit(page, pfn, cold);
+		trace_mm_page_free_batched(page);
+		free_unref_page_commit(page, pfn);
 	}
 	local_irq_restore(flags);
 }
@@ -4292,7 +4287,7 @@ void __free_pages(struct page *page, unsigned int order)
 {
 	if (put_page_testzero(page)) {
 		if (order == 0)
-			free_hot_cold_page(page, false);
+			free_unref_page(page);
 		else
 			__free_pages_ok(page, order);
 	}
@@ -4350,7 +4345,7 @@ void __page_frag_cache_drain(struct page *page, unsigned int count)
 		unsigned int order = compound_order(page);
 
 		if (order == 0)
-			free_hot_cold_page(page, false);
+			free_unref_page(page);
 		else
 			__free_pages_ok(page, order);
 	}
diff --git a/mm/rmap.c b/mm/rmap.c
index b874c4761e84..8f3889553209 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1318,7 +1318,7 @@ void page_remove_rmap(struct page *page, bool compound)
 	 * It would be tidy to reset the PageAnon mapping here,
 	 * but that might overwrite a racing page_add_anon_rmap
 	 * which increments mapcount after us but sets mapping
-	 * before us: so leave the reset to free_hot_cold_page,
+	 * before us: so leave the reset to free_unref_page,
 	 * and remember that it's only reliable while mapped.
 	 * Leaving it set also helps swapoff to reinstate ptes
 	 * faster for those pages still in swapcache.
diff --git a/mm/swap.c b/mm/swap.c
index 0b78ea3cbdea..beaf11ff67d5 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -76,7 +76,7 @@ static void __page_cache_release(struct page *page)
 static void __put_single_page(struct page *page)
 {
 	__page_cache_release(page);
-	free_hot_cold_page(page, false);
+	free_unref_page(page);
 }
 
 static void __put_compound_page(struct page *page)
@@ -817,7 +817,7 @@ void release_pages(struct page **pages, int nr)
 		spin_unlock_irqrestore(&locked_pgdat->lru_lock, flags);
 
 	mem_cgroup_uncharge_list(&pages_to_free);
-	free_hot_cold_page_list(&pages_to_free, 0);
+	free_unref_page_list(&pages_to_free);
 }
 EXPORT_SYMBOL(release_pages);
 
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 13d711dd8776..e574e6266ab8 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1348,7 +1348,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 
 	mem_cgroup_uncharge_list(&free_pages);
 	try_to_unmap_flush();
-	free_hot_cold_page_list(&free_pages, true);
+	free_unref_page_list(&free_pages);
 
 	list_splice(&ret_pages, page_list);
 	count_vm_events(PGACTIVATE, pgactivate);
@@ -1823,7 +1823,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 	spin_unlock_irq(&pgdat->lru_lock);
 
 	mem_cgroup_uncharge_list(&page_list);
-	free_hot_cold_page_list(&page_list, true);
+	free_unref_page_list(&page_list);
 
 	/*
 	 * If reclaim is isolating dirty pages under writeback, it implies
@@ -2062,7 +2062,7 @@ static void shrink_active_list(unsigned long nr_to_scan,
 	spin_unlock_irq(&pgdat->lru_lock);
 
 	mem_cgroup_uncharge_list(&l_hold);
-	free_hot_cold_page_list(&l_hold, true);
+	free_unref_page_list(&l_hold);
 	trace_mm_vmscan_lru_shrink_active(pgdat->node_id, nr_taken, nr_activate,
 			nr_deactivate, nr_rotated, sc->priority, file);
 }
-- 
2.14.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
