Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f177.google.com (mail-ig0-f177.google.com [209.85.213.177])
	by kanga.kvack.org (Postfix) with ESMTP id D0D4A280266
	for <linux-mm@kvack.org>; Mon, 20 Jul 2015 10:28:32 -0400 (EDT)
Received: by igbpg9 with SMTP id pg9so82686157igb.0
        for <linux-mm@kvack.org>; Mon, 20 Jul 2015 07:28:32 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id i33si16503807ioo.79.2015.07.20.07.21.32
        for <linux-mm@kvack.org>;
        Mon, 20 Jul 2015 07:21:32 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv9 34/36] thp: introduce deferred_split_huge_page()
Date: Mon, 20 Jul 2015 17:21:07 +0300
Message-Id: <1437402069-105900-35-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1437402069-105900-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1437402069-105900-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Currently we don't split huge page on partial unmap. It's not an ideal
situation. It can lead to memory overhead.

Furtunately, we can detect partial unmap on page_remove_rmap(). But we
cannot call split_huge_page() from there due to locking context.

It's also counterproductive to do directly from munmap() codepath: in
many cases we will hit this from exit(2) and splitting the huge page
just to free it up in small pages is not what we really want.

The patch introduce deferred_split_huge_page() which put the huge page
into queue for splitting. The splitting itself will happen when we get
memory pressure via shrinker interface. The page will be dropped from
list on freeing through compound page destructor.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Tested-by: Sasha Levin <sasha.levin@oracle.com>
Tested-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
Acked-by: Vlastimil Babka <vbabka@suse.cz>
---
 include/linux/huge_mm.h |   4 ++
 include/linux/mm.h      |   2 +
 mm/huge_memory.c        | 127 ++++++++++++++++++++++++++++++++++++++++++++++--
 mm/migrate.c            |   1 +
 mm/page_alloc.c         |   2 +-
 mm/rmap.c               |   7 ++-
 6 files changed, 138 insertions(+), 5 deletions(-)

diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index aa6c753f267e..ce5b9756570d 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -94,11 +94,14 @@ extern bool is_vma_temporary_stack(struct vm_area_struct *vma);
 
 extern unsigned long transparent_hugepage_flags;
 
+extern void prep_transhuge_page(struct page *page);
+
 int split_huge_page_to_list(struct page *page, struct list_head *list);
 static inline int split_huge_page(struct page *page)
 {
 	return split_huge_page_to_list(page, NULL);
 }
+void deferred_split_huge_page(struct page *page);
 
 void __split_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
 		unsigned long address);
@@ -177,6 +180,7 @@ static inline int split_huge_page(struct page *page)
 {
 	return 0;
 }
+static inline void deferred_split_huge_page(struct page *page) {}
 #define split_huge_pmd(__vma, __pmd, __address)	\
 	do { } while (0)
 static inline int hugepage_madvise(struct vm_area_struct *vma,
diff --git a/include/linux/mm.h b/include/linux/mm.h
index b41b1d8b9072..b3c19bdc62f1 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -515,6 +515,8 @@ static inline void set_compound_order(struct page *page, unsigned long order)
 	page[1].compound_order = order;
 }
 
+void free_compound_page(struct page *page);
+
 #ifdef CONFIG_MMU
 /*
  * Do pte_mkwrite, but only if the vma says VM_WRITE.  We do this when
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index c8e497c05a9a..d32277463932 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -72,6 +72,8 @@ static int khugepaged(void *none);
 static int khugepaged_slab_init(void);
 static void khugepaged_slab_exit(void);
 
+static void free_transhuge_page(struct page *page);
+
 #define MM_SLOTS_HASH_BITS 10
 static __read_mostly DEFINE_HASHTABLE(mm_slots_hash, MM_SLOTS_HASH_BITS);
 
@@ -106,6 +108,10 @@ static struct khugepaged_scan khugepaged_scan = {
 	.mm_head = LIST_HEAD_INIT(khugepaged_scan.mm_head),
 };
 
+static DEFINE_SPINLOCK(split_queue_lock);
+static LIST_HEAD(split_queue);
+static unsigned long split_queue_len;
+static struct shrinker deferred_split_shrinker;
 
 static void set_recommended_min_free_kbytes(void)
 {
@@ -638,6 +644,9 @@ static int __init hugepage_init(void)
 	err = register_shrinker(&huge_zero_page_shrinker);
 	if (err)
 		goto err_hzp_shrinker;
+	err = register_shrinker(&deferred_split_shrinker);
+	if (err)
+		goto err_split_shrinker;
 
 	/*
 	 * By default disable transparent hugepages on smaller systems,
@@ -655,6 +664,8 @@ static int __init hugepage_init(void)
 
 	return 0;
 err_khugepaged:
+	unregister_shrinker(&deferred_split_shrinker);
+err_split_shrinker:
 	unregister_shrinker(&huge_zero_page_shrinker);
 err_hzp_shrinker:
 	khugepaged_slab_exit();
@@ -711,6 +722,19 @@ static inline pmd_t mk_huge_pmd(struct page *page, pgprot_t prot)
 	return entry;
 }
 
+void prep_transhuge_page(struct page *page)
+{
+	/* we use page->lru in second tail page: assuming THP order >= 2 */
+	BUILD_BUG_ON(HPAGE_PMD_ORDER < 2);
+
+	/*
+	 *  ->lru in the first tail page is occupied by destructor
+	 *  and order of the compound page
+	 */
+	INIT_LIST_HEAD(&page[2].lru);
+	set_compound_page_dtor(page, free_transhuge_page);
+}
+
 static int __do_huge_pmd_anonymous_page(struct mm_struct *mm,
 					struct vm_area_struct *vma,
 					unsigned long address, pmd_t *pmd,
@@ -867,6 +891,7 @@ int do_huge_pmd_anonymous_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		count_vm_event(THP_FAULT_FALLBACK);
 		return VM_FAULT_FALLBACK;
 	}
+	prep_transhuge_page(page);
 	return __do_huge_pmd_anonymous_page(mm, vma, address, pmd, page, gfp,
 					    flags);
 }
@@ -1163,7 +1188,9 @@ alloc:
 	} else
 		new_page = NULL;
 
-	if (unlikely(!new_page)) {
+	if (likely(new_page)) {
+		prep_transhuge_page(new_page);
+	} else {
 		if (!page) {
 			split_huge_pmd(vma, pmd, address);
 			ret |= VM_FAULT_FALLBACK;
@@ -2097,6 +2124,7 @@ khugepaged_alloc_page(struct page **hpage, gfp_t gfp, struct mm_struct *mm,
 		return NULL;
 	}
 
+	prep_transhuge_page(*hpage);
 	count_vm_event(THP_COLLAPSE_ALLOC);
 	return *hpage;
 }
@@ -2108,8 +2136,12 @@ static int khugepaged_find_target_node(void)
 
 static inline struct page *alloc_hugepage(int defrag)
 {
-	return alloc_pages(alloc_hugepage_gfpmask(defrag, 0),
-			   HPAGE_PMD_ORDER);
+	struct page *page;
+
+	page = alloc_pages(alloc_hugepage_gfpmask(defrag, 0), HPAGE_PMD_ORDER);
+	if (page)
+		prep_transhuge_page(page);
+	return page;
 }
 
 static struct page *khugepaged_alloc_hugepage(bool *wait)
@@ -3002,6 +3034,13 @@ static void __split_huge_page(struct page *page, struct list_head *list)
 	spin_lock_irq(&zone->lru_lock);
 	lruvec = mem_cgroup_page_lruvec(head, zone);
 
+	spin_lock(&split_queue_lock);
+	if (!list_empty(&head[2].lru)) {
+		split_queue_len--;
+		list_del(&head[2].lru);
+	}
+	spin_unlock(&split_queue_lock);
+
 	/* complete memcg works before add pages to LRU */
 	mem_cgroup_split_huge_fixup(head);
 
@@ -3113,3 +3152,85 @@ out:
 	count_vm_event(!ret ? THP_SPLIT_PAGE : THP_SPLIT_PAGE_FAILED);
 	return ret;
 }
+
+static void free_transhuge_page(struct page *page)
+{
+	unsigned long flags;
+
+	spin_lock_irqsave(&split_queue_lock, flags);
+	if (!list_empty(&page[2].lru)) {
+		split_queue_len--;
+		list_del(&page[2].lru);
+	}
+	spin_unlock_irqrestore(&split_queue_lock, flags);
+	free_compound_page(page);
+}
+
+void deferred_split_huge_page(struct page *page)
+{
+	unsigned long flags;
+
+	VM_BUG_ON_PAGE(!PageTransHuge(page), page);
+
+	spin_lock_irqsave(&split_queue_lock, flags);
+	if (list_empty(&page[2].lru)) {
+		list_add_tail(&page[2].lru, &split_queue);
+		split_queue_len++;
+	}
+	spin_unlock_irqrestore(&split_queue_lock, flags);
+}
+
+static unsigned long deferred_split_count(struct shrinker *shrink,
+		struct shrink_control *sc)
+{
+	/*
+	 * Split a page from split_queue will free up at least one page,
+	 * at most HPAGE_PMD_NR - 1. We don't track exact number.
+	 * Let's use HPAGE_PMD_NR / 2 as ballpark.
+	 */
+	return ACCESS_ONCE(split_queue_len) * HPAGE_PMD_NR / 2;
+}
+
+static unsigned long deferred_split_scan(struct shrinker *shrink,
+		struct shrink_control *sc)
+{
+	unsigned long flags;
+	LIST_HEAD(list);
+	struct page *page, *next;
+	int split = 0;
+
+	spin_lock_irqsave(&split_queue_lock, flags);
+	list_splice_init(&split_queue, &list);
+
+	/* Take pin on all head pages to avoid freeing them under us */
+	list_for_each_entry_safe(page, next, &list, lru) {
+		page = compound_head(page);
+		/* race with put_compound_page() */
+		if (!get_page_unless_zero(page)) {
+			list_del_init(&page[2].lru);
+			split_queue_len--;
+		}
+	}
+	spin_unlock_irqrestore(&split_queue_lock, flags);
+
+	list_for_each_entry_safe(page, next, &list, lru) {
+		lock_page(page);
+		/* split_huge_page() removes page from list on success */
+		if (!split_huge_page(page))
+			split++;
+		unlock_page(page);
+		put_page(page);
+	}
+
+	spin_lock_irqsave(&split_queue_lock, flags);
+	list_splice_tail(&list, &split_queue);
+	spin_unlock_irqrestore(&split_queue_lock, flags);
+
+	return split * HPAGE_PMD_NR / 2;
+}
+
+static struct shrinker deferred_split_shrinker = {
+	.count_objects = deferred_split_count,
+	.scan_objects = deferred_split_scan,
+	.seeks = DEFAULT_SEEKS,
+};
diff --git a/mm/migrate.c b/mm/migrate.c
index a9dbfd356e9d..91bb504a8cc8 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1736,6 +1736,7 @@ int migrate_misplaced_transhuge_page(struct mm_struct *mm,
 		HPAGE_PMD_ORDER);
 	if (!new_page)
 		goto out_fail;
+	prep_transhuge_page(new_page);
 
 	isolated = numamigrate_isolate_page(pgdat, page);
 	if (!isolated) {
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index cfd3a34e41f1..c78cc0ff99bd 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -428,7 +428,7 @@ out:
  * This usage means that zero-order pages may not be compound.
  */
 
-static void free_compound_page(struct page *page)
+void free_compound_page(struct page *page)
 {
 	__free_pages_ok(page, compound_order(page));
 }
diff --git a/mm/rmap.c b/mm/rmap.c
index e2b23a3e5fc5..df8b6ded9b80 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1309,8 +1309,10 @@ static void page_remove_anon_compound_rmap(struct page *page)
 		nr = HPAGE_PMD_NR;
 	}
 
-	if (nr)
+	if (nr) {
 		__mod_zone_page_state(page_zone(page), NR_ANON_PAGES, -nr);
+		deferred_split_huge_page(page);
+	}
 }
 
 /**
@@ -1345,6 +1347,9 @@ void page_remove_rmap(struct page *page, bool compound)
 	if (unlikely(PageMlocked(page)))
 		clear_page_mlock(page);
 
+	if (PageTransCompound(page))
+		deferred_split_huge_page(compound_head(page));
+
 	/*
 	 * It would be tidy to reset the PageAnon mapping here,
 	 * but that might overwrite a racing page_add_anon_rmap
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
