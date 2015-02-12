Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 132E16B0073
	for <linux-mm@kvack.org>; Thu, 12 Feb 2015 11:20:21 -0500 (EST)
Received: by mail-pa0-f45.google.com with SMTP id rd3so5644166pab.4
        for <linux-mm@kvack.org>; Thu, 12 Feb 2015 08:20:20 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id dh1si1708434pbc.142.2015.02.12.08.20.14
        for <linux-mm@kvack.org>;
        Thu, 12 Feb 2015 08:20:14 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv3 21/24] thp: introduce deferred_split_huge_page()
Date: Thu, 12 Feb 2015 18:18:35 +0200
Message-Id: <1423757918-197669-22-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1423757918-197669-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1423757918-197669-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Currently we don't split huge page on partial unmap. It's not an ideal
situation. It can lead to memory overhead.

Furtunately, we can detect partial unmap on page_remove_rmap(). But we
cannot call split_huge_page() from there due to locking context.

It's also counterproductive to do directly from munmap() codepath: in
many cases we will hit this from exit(2) and splitting the huge page
just to free it up in small pages is not what we really want.

The patch introduce deferred_split_huge_page() which put the huge page
into queue for splitting. The splitting itself will happen when we get
memory pressure. The page will be dropped from list on freeing through
compound page destructor.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/linux/huge_mm.h |  9 +++++
 include/linux/mm.h      |  2 ++
 include/linux/mmzone.h  |  5 +++
 mm/huge_memory.c        | 90 +++++++++++++++++++++++++++++++++++++++++++++++--
 mm/page_alloc.c         |  6 +++-
 mm/rmap.c               | 10 +++++-
 mm/vmscan.c             |  3 ++
 7 files changed, 120 insertions(+), 5 deletions(-)

diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index 7a0c477a2b38..0aaebd81beb6 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -96,6 +96,13 @@ static inline int split_huge_page(struct page *page)
 {
 	return split_huge_page_to_list(page, NULL);
 }
+void deferred_split_huge_page(struct page *page);
+void __drain_split_queue(struct zone *zone);
+static inline void drain_split_queue(struct zone *zone)
+{
+	if (!list_empty(&zone->split_queue))
+		__drain_split_queue(zone);
+}
 extern void __split_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
 		unsigned long address);
 #define split_huge_pmd(__vma, __pmd, __address)				\
@@ -170,6 +177,8 @@ static inline int split_huge_page(struct page *page)
 {
 	return 0;
 }
+static inline void deferred_split_huge_page(struct page *page) {}
+static inline void drain_split_queue(struct zone *zone) {}
 #define split_huge_pmd(__vma, __pmd, __address)	\
 	do { } while (0)
 static inline int hugepage_madvise(struct vm_area_struct *vma,
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 44e1d7f48158..f6ec7ed26168 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -568,6 +568,8 @@ static inline void set_compound_order(struct page *page, unsigned long order)
 	page[1].compound_order = order;
 }
 
+void free_compound_page(struct page *page);
+
 #ifdef CONFIG_MMU
 /*
  * Do pte_mkwrite, but only if the vma says VM_WRITE.  We do this when
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index f279d9c158cd..4f1afa447e2d 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -525,6 +525,11 @@ struct zone {
 	bool			compact_blockskip_flush;
 #endif
 
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+	unsigned long split_queue_length;
+	struct list_head split_queue;
+#endif
+
 	ZONE_PADDING(_pad3_)
 	/* Zone statistics */
 	atomic_long_t		vm_stat[NR_VM_ZONE_STAT_ITEMS];
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 7157975eeb1a..f42bd96e69a6 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -69,6 +69,8 @@ static unsigned int khugepaged_max_ptes_none __read_mostly = HPAGE_PMD_NR-1;
 static int khugepaged(void *none);
 static int khugepaged_slab_init(void);
 
+static void free_transhuge_page(struct page *page);
+
 #define MM_SLOTS_HASH_BITS 10
 static __read_mostly DEFINE_HASHTABLE(mm_slots_hash, MM_SLOTS_HASH_BITS);
 
@@ -825,6 +827,8 @@ int do_huge_pmd_anonymous_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		count_vm_event(THP_FAULT_FALLBACK);
 		return VM_FAULT_FALLBACK;
 	}
+	INIT_LIST_HEAD(&page[2].lru);
+	set_compound_page_dtor(page, free_transhuge_page);
 	if (unlikely(__do_huge_pmd_anonymous_page(mm, vma, haddr, pmd, page))) {
 		put_page(page);
 		count_vm_event(THP_FAULT_FALLBACK);
@@ -1086,7 +1090,10 @@ alloc:
 	} else
 		new_page = NULL;
 
-	if (unlikely(!new_page)) {
+	if (likely(new_page)) {
+		INIT_LIST_HEAD(&new_page[2].lru);
+		set_compound_page_dtor(new_page, free_transhuge_page);
+	} else {
 		if (!page) {
 			split_huge_pmd(vma, pmd, address);
 			ret |= VM_FAULT_FALLBACK;
@@ -1839,6 +1846,10 @@ static int __split_huge_page_refcount(struct anon_vma *anon_vma,
 		return -EBUSY;
 	}
 
+	spin_lock(&zone->lock);
+	list_del(&page[2].lru);
+	spin_unlock(&zone->lock);
+
 	/* complete memcg works before add pages to LRU */
 	mem_cgroup_split_huge_fixup(page);
 
@@ -1994,6 +2005,71 @@ out:
 	return ret;
 }
 
+static void free_transhuge_page(struct page *page)
+{
+	if (!list_empty(&page[2].lru)) {
+		struct zone *zone = page_zone(page);
+		unsigned long flags;
+
+		spin_lock_irqsave(&zone->lock, flags);
+		list_del(&page[2].lru);
+		memset(&page[2].lru, 0, sizeof(page[2].lru));
+		spin_unlock_irqrestore(&zone->lock, flags);
+	}
+	free_compound_page(page);
+}
+
+void deferred_split_huge_page(struct page *page)
+{
+	struct zone *zone = page_zone(page);
+	unsigned long flags;
+
+	VM_BUG_ON_PAGE(!PageTransHuge(page), page);
+
+	/* we use page->lru in second tail page: assuming THP order >= 2 */
+	BUILD_BUG_ON(HPAGE_PMD_ORDER < 2);
+
+	if (!list_empty(&page[2].lru))
+		return;
+
+	spin_lock_irqsave(&zone->lock, flags);
+	if (list_empty(&page[2].lru))
+		list_add_tail(&page[2].lru, &zone->split_queue);
+	spin_unlock_irqrestore(&zone->lock, flags);
+}
+
+void __drain_split_queue(struct zone *zone)
+{
+	unsigned long flags;
+	LIST_HEAD(list);
+	struct page *page, *next;
+
+	spin_lock_irqsave(&zone->lock, flags);
+	list_splice_init(&zone->split_queue, &list);
+	/*
+	 * take reference for all pages under zone->lock to avoid race
+	 * with free_transhuge_page().
+	 */
+	list_for_each_entry_safe(page, next, &list, lru)
+		get_page(compound_head(page));
+	spin_unlock_irqrestore(&zone->lock, flags);
+
+	list_for_each_entry_safe(page, next, &list, lru) {
+		page = compound_head(page);
+		lock_page(page);
+		/* split_huge_page() removes page from list on success */
+		split_huge_page(compound_head(page));
+		unlock_page(page);
+		put_page(page);
+	}
+
+	if (!list_empty(&list)) {
+		spin_lock_irqsave(&zone->lock, flags);
+		list_splice_tail(&list, &zone->split_queue);
+		spin_unlock_irqrestore(&zone->lock, flags);
+	}
+}
+
 #define VM_NO_THP (VM_SPECIAL | VM_HUGETLB | VM_SHARED | VM_MAYSHARE)
 
 int hugepage_madvise(struct vm_area_struct *vma,
@@ -2413,6 +2489,8 @@ static struct page
 		return NULL;
 	}
 
+	INIT_LIST_HEAD(&(*hpage)[2].lru);
+	set_compound_page_dtor(*hpage, free_transhuge_page);
 	count_vm_event(THP_COLLAPSE_ALLOC);
 	return *hpage;
 }
@@ -2424,8 +2502,14 @@ static int khugepaged_find_target_node(void)
 
 static inline struct page *alloc_hugepage(int defrag)
 {
-	return alloc_pages(alloc_hugepage_gfpmask(defrag, 0),
-			   HPAGE_PMD_ORDER);
+	struct page *page;
+
+	page = alloc_pages(alloc_hugepage_gfpmask(defrag, 0), HPAGE_PMD_ORDER);
+	if (page) {
+		INIT_LIST_HEAD(&page[2].lru);
+		set_compound_page_dtor(page, free_transhuge_page);
+	}
+	return page;
 }
 
 static struct page *khugepaged_alloc_hugepage(bool *wait)
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index b0ef1f6d2fb0..9010b60009f6 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -357,7 +357,7 @@ out:
  * This usage means that zero-order pages may not be compound.
  */
 
-static void free_compound_page(struct page *page)
+void free_compound_page(struct page *page)
 {
 	__free_pages_ok(page, compound_order(page));
 }
@@ -4920,6 +4920,10 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat,
 		zone->zone_pgdat = pgdat;
 		zone_pcp_init(zone);
 
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+		INIT_LIST_HEAD(&zone->split_queue);
+#endif
+
 		/* For bootup, initialized properly in watermark setup */
 		mod_zone_page_state(zone, NR_ALLOC_BATCH, zone->managed_pages);
 
diff --git a/mm/rmap.c b/mm/rmap.c
index 2dc26770d1d3..6795babf5739 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1165,6 +1165,7 @@ out:
 void page_remove_rmap(struct page *page, bool compound)
 {
 	int nr = compound ? hpage_nr_pages(page) : 1;
+	bool partial_thp_unmap;
 
 	if (!PageAnon(page)) {
 		VM_BUG_ON_PAGE(compound && !PageHuge(page), page);
@@ -1195,13 +1196,20 @@ void page_remove_rmap(struct page *page, bool compound)
 		for (i = 0; i < hpage_nr_pages(page); i++)
 			if (page_mapcount(page + i))
 				nr--;
-	}
+		partial_thp_unmap = nr != hpage_nr_pages(page);
+	} else if (PageTransCompound(page)) {
+		partial_thp_unmap = !compound_mapcount(page);
+	} else
+		partial_thp_unmap = false;
 
 	__mod_zone_page_state(page_zone(page), NR_ANON_PAGES, -nr);
 
 	if (unlikely(PageMlocked(page)))
 		clear_page_mlock(page);
 
+	if (partial_thp_unmap)
+		deferred_split_huge_page(compound_head(page));
+
 	/*
 	 * It would be tidy to reset the PageAnon mapping here,
 	 * but that might overwrite a racing page_add_anon_rmap
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 671e47edb584..741a215e3d73 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2376,6 +2376,9 @@ static bool shrink_zone(struct zone *zone, struct scan_control *sc,
 		unsigned long zone_lru_pages = 0;
 		struct mem_cgroup *memcg;
 
+		/* XXX: accounting for shrinking progress ? */
+		drain_split_queue(zone);
+
 		nr_reclaimed = sc->nr_reclaimed;
 		nr_scanned = sc->nr_scanned;
 
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
