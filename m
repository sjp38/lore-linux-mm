Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id E7EA26B0269
	for <linux-mm@kvack.org>; Thu,  3 Sep 2015 11:21:54 -0400 (EDT)
Received: by padfa1 with SMTP id fa1so7360695pad.1
        for <linux-mm@kvack.org>; Thu, 03 Sep 2015 08:21:54 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id ry8si41888265pbb.86.2015.09.03.08.14.06
        for <linux-mm@kvack.org>;
        Thu, 03 Sep 2015 08:14:06 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv10 34/36] thp: introduce deferred_split_huge_page()
Date: Thu,  3 Sep 2015 18:13:20 +0300
Message-Id: <1441293202-137314-35-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1441293202-137314-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1441293202-137314-1-git-send-email-kirill.shutemov@linux.intel.com>
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
Acked-by: Jerome Marchand <jmarchan@redhat.com>
---
 include/linux/huge_mm.h  |   5 ++
 include/linux/mm.h       |   5 ++
 include/linux/mm_types.h |   2 +
 mm/huge_memory.c         | 137 +++++++++++++++++++++++++++++++++++++++++++++--
 mm/migrate.c             |   1 +
 mm/page_alloc.c          |  27 +++++++---
 mm/rmap.c                |   7 ++-
 7 files changed, 172 insertions(+), 12 deletions(-)

diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index 156290523a05..f7c3f13f3a9c 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -94,11 +94,15 @@ extern bool is_vma_temporary_stack(struct vm_area_struct *vma);
 
 extern unsigned long transparent_hugepage_flags;
 
+extern void prep_transhuge_page(struct page *page);
+extern void free_transhuge_page(struct page *page);
+
 int split_huge_page_to_list(struct page *page, struct list_head *list);
 static inline int split_huge_page(struct page *page)
 {
 	return split_huge_page_to_list(page, NULL);
 }
+void deferred_split_huge_page(struct page *page);
 
 void __split_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
 		unsigned long address);
@@ -174,6 +178,7 @@ static inline int split_huge_page(struct page *page)
 {
 	return 0;
 }
+static inline void deferred_split_huge_page(struct page *page) {}
 #define split_huge_pmd(__vma, __pmd, __address)	\
 	do { } while (0)
 static inline int hugepage_madvise(struct vm_area_struct *vma,
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 64493b7bd9f7..18c658487668 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -482,6 +482,9 @@ enum compound_dtor_id {
 #ifdef CONFIG_HUGETLB_PAGE
 	HUGETLB_PAGE_DTOR,
 #endif
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+	TRANSHUGE_PAGE_DTOR,
+#endif
 	NR_COMPOUND_DTORS,
 };
 extern compound_page_dtor * const compound_page_dtors[];
@@ -511,6 +514,8 @@ static inline void set_compound_order(struct page *page, unsigned int order)
 	page[1].compound_order = order;
 }
 
+void free_compound_page(struct page *page);
+
 #ifdef CONFIG_MMU
 /*
  * Do pte_mkwrite, but only if the vma says VM_WRITE.  We do this when
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 3779e8a2125c..04f2873cfe1e 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -55,6 +55,7 @@ struct page {
 						 */
 		void *s_mem;			/* slab first object */
 		atomic_t compound_mapcount;	/* first tail page */
+		/* page_deferred_list().next	 -- second tail page */
 	};
 
 	/* Second double word */
@@ -62,6 +63,7 @@ struct page {
 		union {
 			pgoff_t index;		/* Our offset within mapping. */
 			void *freelist;		/* sl[aou]b first free object */
+			/* page_deferred_list().prev	-- second tail page */
 		};
 
 		union {
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index bfec3a03f0f6..2cc99f9096a8 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -107,6 +107,10 @@ static struct khugepaged_scan khugepaged_scan = {
 	.mm_head = LIST_HEAD_INIT(khugepaged_scan.mm_head),
 };
 
+static DEFINE_SPINLOCK(split_queue_lock);
+static LIST_HEAD(split_queue);
+static unsigned long split_queue_len;
+static struct shrinker deferred_split_shrinker;
 
 static void set_recommended_min_free_kbytes(void)
 {
@@ -639,6 +643,9 @@ static int __init hugepage_init(void)
 	err = register_shrinker(&huge_zero_page_shrinker);
 	if (err)
 		goto err_hzp_shrinker;
+	err = register_shrinker(&deferred_split_shrinker);
+	if (err)
+		goto err_split_shrinker;
 
 	/*
 	 * By default disable transparent hugepages on smaller systems,
@@ -656,6 +663,8 @@ static int __init hugepage_init(void)
 
 	return 0;
 err_khugepaged:
+	unregister_shrinker(&deferred_split_shrinker);
+err_split_shrinker:
 	unregister_shrinker(&huge_zero_page_shrinker);
 err_hzp_shrinker:
 	khugepaged_slab_exit();
@@ -712,6 +721,27 @@ static inline pmd_t mk_huge_pmd(struct page *page, pgprot_t prot)
 	return entry;
 }
 
+static inline struct list_head *page_deferred_list(struct page *page)
+{
+	/*
+	 * ->lru in the tail pages is occupied by compound_head.
+	 * Let's use ->mapping + ->index in the second tail page as list_head.
+	 */
+	return (struct list_head *)&page[2].mapping;
+}
+
+void prep_transhuge_page(struct page *page)
+{
+	/*
+	 * we use page->mapping and page->indexlru in second tail page
+	 * as list_head: assuming THP order >= 2
+	 */
+	BUILD_BUG_ON(HPAGE_PMD_ORDER < 2);
+
+	INIT_LIST_HEAD(page_deferred_list(page));
+	set_compound_page_dtor(page, TRANSHUGE_PAGE_DTOR);
+}
+
 static int __do_huge_pmd_anonymous_page(struct mm_struct *mm,
 					struct vm_area_struct *vma,
 					unsigned long address, pmd_t *pmd,
@@ -868,6 +898,7 @@ int do_huge_pmd_anonymous_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		count_vm_event(THP_FAULT_FALLBACK);
 		return VM_FAULT_FALLBACK;
 	}
+	prep_transhuge_page(page);
 	return __do_huge_pmd_anonymous_page(mm, vma, address, pmd, page, gfp,
 					    flags);
 }
@@ -1164,7 +1195,9 @@ alloc:
 	} else
 		new_page = NULL;
 
-	if (unlikely(!new_page)) {
+	if (likely(new_page)) {
+		prep_transhuge_page(new_page);
+	} else {
 		if (!page) {
 			split_huge_pmd(vma, pmd, address);
 			ret |= VM_FAULT_FALLBACK;
@@ -2093,6 +2126,7 @@ khugepaged_alloc_page(struct page **hpage, gfp_t gfp, struct mm_struct *mm,
 		return NULL;
 	}
 
+	prep_transhuge_page(*hpage);
 	count_vm_event(THP_COLLAPSE_ALLOC);
 	return *hpage;
 }
@@ -2104,8 +2138,12 @@ static int khugepaged_find_target_node(void)
 
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
@@ -2978,7 +3016,7 @@ static int __split_huge_page_tail(struct page *head, int tail,
 		set_page_idle(page_tail);
 
 	/* ->mapping in first tail page is compound_mapcount */
-	VM_BUG_ON_PAGE(tail != 1 && page_tail->mapping != TAIL_MAPPING,
+	VM_BUG_ON_PAGE(tail > 2 && page_tail->mapping != TAIL_MAPPING,
 			page_tail);
 	page_tail->mapping = head->mapping;
 
@@ -3000,6 +3038,13 @@ static void __split_huge_page(struct page *page, struct list_head *list)
 	spin_lock_irq(&zone->lru_lock);
 	lruvec = mem_cgroup_page_lruvec(head, zone);
 
+	spin_lock(&split_queue_lock);
+	if (!list_empty(page_deferred_list(head))) {
+		split_queue_len--;
+		list_del(page_deferred_list(head));
+	}
+	spin_unlock(&split_queue_lock);
+
 	/* complete memcg works before add pages to LRU */
 	mem_cgroup_split_huge_fixup(head);
 
@@ -3111,3 +3156,87 @@ out:
 	count_vm_event(!ret ? THP_SPLIT_PAGE : THP_SPLIT_PAGE_FAILED);
 	return ret;
 }
+
+void free_transhuge_page(struct page *page)
+{
+	unsigned long flags;
+
+	spin_lock_irqsave(&split_queue_lock, flags);
+	if (!list_empty(page_deferred_list(page))) {
+		split_queue_len--;
+		list_del(page_deferred_list(page));
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
+	if (list_empty(page_deferred_list(page))) {
+		list_add_tail(page_deferred_list(page), &split_queue);
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
+	LIST_HEAD(list), *pos, *next;
+	struct page *page;
+	int split = 0;
+
+	spin_lock_irqsave(&split_queue_lock, flags);
+	list_splice_init(&split_queue, &list);
+
+	/* Take pin on all head pages to avoid freeing them under us */
+	list_for_each_safe(pos, next, &list) {
+		page = list_entry((void *)pos, struct page, mapping);
+		page = compound_head(page);
+		/* race with put_compound_page() */
+		if (!get_page_unless_zero(page)) {
+			list_del_init(page_deferred_list(page));
+			split_queue_len--;
+		}
+	}
+	spin_unlock_irqrestore(&split_queue_lock, flags);
+
+	list_for_each_safe(pos, next, &list) {
+		page = list_entry((void *)pos, struct page, mapping);
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
index b8e968fab1d2..397eb647e496 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1747,6 +1747,7 @@ int migrate_misplaced_transhuge_page(struct mm_struct *mm,
 		HPAGE_PMD_ORDER);
 	if (!new_page)
 		goto out_fail;
+	prep_transhuge_page(new_page);
 
 	isolated = numamigrate_isolate_page(pgdat, page);
 	if (!isolated) {
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index c86a18ddbcf2..9d7619104753 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -226,13 +226,15 @@ static char * const zone_names[MAX_NR_ZONES] = {
 	 "Movable",
 };
 
-static void free_compound_page(struct page *page);
 compound_page_dtor * const compound_page_dtors[] = {
 	NULL,
 	free_compound_page,
 #ifdef CONFIG_HUGETLB_PAGE
 	free_huge_page,
 #endif
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+	free_transhuge_page,
+#endif
 };
 
 int min_free_kbytes = 1024;
@@ -454,7 +456,7 @@ out:
  * This usage means that zero-order pages may not be compound.
  */
 
-static void free_compound_page(struct page *page)
+void free_compound_page(struct page *page)
 {
 	__free_pages_ok(page, compound_order(page));
 }
@@ -863,15 +865,26 @@ static int free_tail_pages_check(struct page *head_page, struct page *page)
 		ret = 0;
 		goto out;
 	}
-	/* mapping in first tail page is used for compound_mapcount() */
-	if (page - head_page == 1) {
+	switch (page - head_page) {
+	case 1:
+		/* the first tail page: ->mapping is compound_mapcount() */
 		if (unlikely(compound_mapcount(page))) {
 			bad_page(page, "nonzero compound_mapcount", 0);
 			goto out;
 		}
-	} else if (page->mapping != TAIL_MAPPING) {
-		bad_page(page, "corrupted mapping in tail page", 0);
-		goto out;
+		break;
+	case 2:
+		/*
+		 * the second tail page: ->mapping is
+		 * page_deferred_list().next -- ignore value.
+		 */
+		break;
+	default:
+		if (page->mapping != TAIL_MAPPING) {
+			bad_page(page, "corrupted mapping in tail page", 0);
+			goto out;
+		}
+		break;
 	}
 	if (unlikely(!PageTail(page))) {
 		bad_page(page, "PageTail not set", 0);
diff --git a/mm/rmap.c b/mm/rmap.c
index 200ec96bc705..d16719e999a8 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1318,8 +1318,10 @@ static void page_remove_anon_compound_rmap(struct page *page)
 		nr = HPAGE_PMD_NR;
 	}
 
-	if (nr)
+	if (nr) {
 		__mod_zone_page_state(page_zone(page), NR_ANON_PAGES, -nr);
+		deferred_split_huge_page(page);
+	}
 }
 
 /**
@@ -1354,6 +1356,9 @@ void page_remove_rmap(struct page *page, bool compound)
 	if (unlikely(PageMlocked(page)))
 		clear_page_mlock(page);
 
+	if (PageTransCompound(page))
+		deferred_split_huge_page(compound_head(page));
+
 	/*
 	 * It would be tidy to reset the PageAnon mapping here,
 	 * but that might overwrite a racing page_add_anon_rmap
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
