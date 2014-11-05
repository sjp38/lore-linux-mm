Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 335576B00AB
	for <linux-mm@kvack.org>; Wed,  5 Nov 2014 09:50:53 -0500 (EST)
Received: by mail-pa0-f50.google.com with SMTP id eu11so900321pac.37
        for <linux-mm@kvack.org>; Wed, 05 Nov 2014 06:50:52 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id uv6si3082252pbc.255.2014.11.05.06.50.46
        for <linux-mm@kvack.org>;
        Wed, 05 Nov 2014 06:50:47 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 12/19] thp: implement new split_huge_page()
Date: Wed,  5 Nov 2014 16:49:47 +0200
Message-Id: <1415198994-15252-13-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1415198994-15252-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1415198994-15252-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

The new split_huge_page() can fail if the compound is pinned: we expect
only caller to have one reference to head page. If the page is pinned
split_huge_page() returns -EBUSY and caller must handle this correctly.

We don't need mark PMDs splitting since now we can split one PMD a time
with split_huge_pmd().

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/linux/hugetlb_inline.h |   9 +-
 include/linux/mm.h             |  22 +++--
 mm/huge_memory.c               | 183 +++++++++++++++++++++++------------------
 mm/swap.c                      | 126 +++++++++++++++++++++++++++-
 4 files changed, 244 insertions(+), 96 deletions(-)

diff --git a/include/linux/hugetlb_inline.h b/include/linux/hugetlb_inline.h
index 2bb681fbeb35..c5cd37479731 100644
--- a/include/linux/hugetlb_inline.h
+++ b/include/linux/hugetlb_inline.h
@@ -10,6 +10,8 @@ static inline int is_vm_hugetlb_page(struct vm_area_struct *vma)
 	return !!(vma->vm_flags & VM_HUGETLB);
 }
 
+int PageHeadHuge(struct page *page_head);
+
 #else
 
 static inline int is_vm_hugetlb_page(struct vm_area_struct *vma)
@@ -17,6 +19,11 @@ static inline int is_vm_hugetlb_page(struct vm_area_struct *vma)
 	return 0;
 }
 
-#endif
+static inline int PageHeadHuge(struct page *page_head)
+{
+       return 0;
+}
+
+#endif /* CONFIG_HUGETLB_PAGE */
 
 #endif
diff --git a/include/linux/mm.h b/include/linux/mm.h
index d36ad0575e58..f2f95469f1c3 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -453,20 +453,18 @@ static inline int page_count(struct page *page)
 	return atomic_read(&compound_head(page)->_count);
 }
 
-#ifdef CONFIG_HUGETLB_PAGE
-extern int PageHeadHuge(struct page *page_head);
-#else /* CONFIG_HUGETLB_PAGE */
-static inline int PageHeadHuge(struct page *page_head)
-{
-	return 0;
-}
-#endif /* CONFIG_HUGETLB_PAGE */
-
+void __get_page_tail(struct page *page);
 static inline void get_page(struct page *page)
 {
-	struct page *page_head = compound_head(page);
-	VM_BUG_ON_PAGE(atomic_read(&page_head->_count) <= 0, page);
-	atomic_inc(&page_head->_count);
+	if (unlikely(PageTail(page)))
+		return __get_page_tail(page);
+
+	/*
+	 * Getting a normal page or the head of a compound page
+	 * requires to already have an elevated page->_count.
+	 */
+	VM_BUG_ON_PAGE(atomic_read(&page->_count) <= 0, page);
+	atomic_inc(&page->_count);
 }
 
 static inline struct page *virt_to_head_page(const void *x)
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index c63911b10143..36fa0d505956 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1708,31 +1708,52 @@ static void split_huge_page_address(struct vm_area_struct *vma,
 	__split_huge_pmd(vma, pmd, address);
 }
 
-#if 0
-static void __split_huge_page_refcount(struct page *page,
+static int __split_huge_page_refcount(struct page *page,
 				       struct list_head *list)
 {
 	int i;
 	struct zone *zone = page_zone(page);
 	struct lruvec *lruvec;
-	int tail_count = 0;
+	int tail_mapcount = 0;
 
 	/* prevent PageLRU to go away from under us, and freeze lru stats */
 	spin_lock_irq(&zone->lru_lock);
 	lruvec = mem_cgroup_page_lruvec(page, zone);
 
 	compound_lock(page);
+
+	/*
+	 * We cannot split pinned THP page: we expect page count to be equal
+	 * to sum of mapcount of all sub-pages plus one (split_huge_page()
+	 * caller must take reference for head page).
+	 *
+	 * Compound lock only prevents page->_count to be updated from
+	 * get_page() or put_page() on tail page. It means means page_count()
+	 * can change under us from head page after the check, but it's okay:
+	 * all new refernces will stay on head page after split.
+	 */
+	tail_mapcount = 0;
+	for (i = 0; i < HPAGE_PMD_NR; i++)
+		tail_mapcount += page_mapcount(page + i);
+	if (tail_mapcount != page_count(page) - 1) {
+		BUG_ON(tail_mapcount > page_count(page) - 1);
+		compound_unlock(page);
+		spin_unlock_irq(&zone->lru_lock);
+		return -EBUSY;
+	}
+
 	/* complete memcg works before add pages to LRU */
 	mem_cgroup_split_huge_fixup(page);
 
+	tail_mapcount = 0;
 	for (i = HPAGE_PMD_NR - 1; i >= 1; i--) {
 		struct page *page_tail = page + i;
 
 		/* tail_page->_mapcount cannot change */
-		BUG_ON(atomic_read(&page_tail->_mapcount) + 1 < 0);
-		tail_count += atomic_read(&page_tail->_mapcount) + 1;
+		BUG_ON(page_mapcount(page_tail) < 0);
+		tail_mapcount += page_mapcount(page_tail);
 		/* check for overflow */
-		BUG_ON(tail_count < 0);
+		BUG_ON(tail_mapcount < 0);
 		BUG_ON(atomic_read(&page_tail->_count) != 0);
 		/*
 		 * tail_page->_count is zero and not changing from
@@ -1770,28 +1791,9 @@ static void __split_huge_page_refcount(struct page *page,
 		/* clear PageTail before overwriting first_page */
 		smp_wmb();
 
-		/*
-		 * __split_huge_page_splitting() already set the
-		 * splitting bit in all pmd that could map this
-		 * hugepage, that will ensure no CPU can alter the
-		 * mapcount on the head page. The mapcount is only
-		 * accounted in the head page and it has to be
-		 * transferred to all tail pages in the below code. So
-		 * for this code to be safe, the split the mapcount
-		 * can't change. But that doesn't mean userland can't
-		 * keep changing and reading the page contents while
-		 * we transfer the mapcount, so the pmd splitting
-		 * status is achieved setting a reserved bit in the
-		 * pmd, not by clearing the present bit.
-		*/
-		atomic_set(&page_tail->_mapcount, compound_mapcount(page) - 1);
-
 		/* ->mapping in first tail page is compound_mapcount */
-		if (i != 1) {
-			BUG_ON(page_tail->mapping);
-			page_tail->mapping = page->mapping;
-			BUG_ON(!PageAnon(page_tail));
-		}
+		BUG_ON(i != 1 && page_tail->mapping);
+		page_tail->mapping = page->mapping;
 
 		page_tail->index = page->index + i;
 		page_cpupid_xchg_last(page_tail, page_cpupid_last(page));
@@ -1802,12 +1804,9 @@ static void __split_huge_page_refcount(struct page *page,
 
 		lru_add_page_tail(page, page_tail, lruvec, list);
 	}
-	atomic_sub(tail_count, &page->_count);
+	atomic_sub(tail_mapcount, &page->_count);
 	BUG_ON(atomic_read(&page->_count) <= 0);
 
-	page->_mapcount = *compound_mapcount_ptr(page);
-	page[1].mapping = page->mapping;
-
 	__mod_zone_page_state(zone, NR_ANON_TRANSPARENT_HUGEPAGES, -1);
 
 	ClearPageCompound(page);
@@ -1832,71 +1831,95 @@ static void __split_huge_page_refcount(struct page *page,
 	 * to be pinned by the caller.
 	 */
 	BUG_ON(page_count(page) <= 0);
+	return 0;
 }
 
-/* must be called with anon_vma->root->rwsem held */
-static void __split_huge_page(struct page *page,
-			      struct anon_vma *anon_vma,
-			      struct list_head *list)
+/*
+ * Split a hugepage into normal pages. This doesn't change the position of head
+ * page. If @list is null, tail pages will be added to LRU list, otherwise, to
+ * @list. Both head page and tail pages will inherit mapping, flags, and so on
+ * from the hugepage.
+ * Return 0 if the hugepage is split successfully otherwise return -errno.
+ */
+int split_huge_page_to_list(struct page *page, struct list_head *list)
 {
-	int mapcount, mapcount2;
-	pgoff_t pgoff = page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
+	struct anon_vma *anon_vma;
 	struct anon_vma_chain *avc;
+	pgoff_t pgoff = page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
+	int i, tail_mapcount;
+	int ret = -EBUSY;
 
-	BUG_ON(!PageHead(page));
-	BUG_ON(PageTail(page));
+	BUG_ON(is_huge_zero_page(page));
+	BUG_ON(!PageAnon(page));
 
-	mapcount = 0;
-	anon_vma_interval_tree_foreach(avc, &anon_vma->rb_root, pgoff, pgoff) {
-		struct vm_area_struct *vma = avc->vma;
-		unsigned long addr = vma_address(page, vma);
-		BUG_ON(is_vma_temporary_stack(vma));
-		mapcount += __split_huge_page_splitting(page, vma, addr);
-	}
 	/*
-	 * It is critical that new vmas are added to the tail of the
-	 * anon_vma list. This guarantes that if copy_huge_pmd() runs
-	 * and establishes a child pmd before
-	 * __split_huge_page_splitting() freezes the parent pmd (so if
-	 * we fail to prevent copy_huge_pmd() from running until the
-	 * whole __split_huge_page() is complete), we will still see
-	 * the newly established pmd of the child later during the
-	 * walk, to be able to set it as pmd_trans_splitting too.
+	 * The caller does not necessarily hold an mmap_sem that would prevent
+	 * the anon_vma disappearing so we first we take a reference to it
+	 * and then lock the anon_vma for write. This is similar to
+	 * page_lock_anon_vma_read except the write lock is taken to serialise
+	 * against parallel split or collapse operations.
 	 */
-	if (mapcount != page_mapcount(page)) {
-		pr_err("mapcount %d page_mapcount %d\n",
-			mapcount, page_mapcount(page));
-		BUG();
+	anon_vma = page_get_anon_vma(page);
+	if (!anon_vma)
+		goto out;
+	anon_vma_lock_write(anon_vma);
+
+	if (!PageCompound(page)) {
+		ret = 0;
+		goto out_unlock;
 	}
 
-	__split_huge_page_refcount(page, list);
+	BUG_ON(!PageSwapBacked(page));
+
+	/*
+	 * Racy check if __split_huge_page_refcount() can be successful, before
+	 * splitting PMDs.
+	 */
+	tail_mapcount = compound_mapcount(page);
+	for (i = 0; i < HPAGE_PMD_NR; i++)
+		tail_mapcount += atomic_read(&page[i]._mapcount) + 1;
+	if (tail_mapcount != page_count(page) - 1) {
+		VM_BUG_ON_PAGE(tail_mapcount > page_count(page) - 1, page);
+		ret = -EBUSY;
+		goto out_unlock;
+	}
 
-	mapcount2 = 0;
 	anon_vma_interval_tree_foreach(avc, &anon_vma->rb_root, pgoff, pgoff) {
 		struct vm_area_struct *vma = avc->vma;
 		unsigned long addr = vma_address(page, vma);
-		BUG_ON(is_vma_temporary_stack(vma));
-		mapcount2 += __split_huge_page_map(page, vma, addr);
-	}
-	if (mapcount != mapcount2) {
-		pr_err("mapcount %d mapcount2 %d page_mapcount %d\n",
-			mapcount, mapcount2, page_mapcount(page));
-		BUG();
+		spinlock_t *ptl;
+		pmd_t *pmd;
+		unsigned long haddr = addr & HPAGE_PMD_MASK;
+		unsigned long mmun_start;	/* For mmu_notifiers */
+		unsigned long mmun_end;		/* For mmu_notifiers */
+
+		mmun_start = haddr;
+		mmun_end   = haddr + HPAGE_PMD_SIZE;
+		mmu_notifier_invalidate_range_start(vma->vm_mm,
+				mmun_start, mmun_end);
+		pmd = page_check_address_pmd(page, vma->vm_mm, addr,
+				PAGE_CHECK_ADDRESS_PMD_FLAG, &ptl);
+		if (pmd) {
+			__split_huge_pmd_locked(vma, pmd, addr);
+			spin_unlock(ptl);
+		}
+		mmu_notifier_invalidate_range_end(vma->vm_mm,
+				mmun_start, mmun_end);
 	}
-}
-#endif
 
-/*
- * Split a hugepage into normal pages. This doesn't change the position of head
- * page. If @list is null, tail pages will be added to LRU list, otherwise, to
- * @list. Both head page and tail pages will inherit mapping, flags, and so on
- * from the hugepage.
- * Return 0 if the hugepage is split successfully otherwise return -errno.
- */
-int split_huge_page_to_list(struct page *page, struct list_head *list)
-{
-	count_vm_event(THP_SPLIT_PAGE_FAILED);
-	return -EBUSY;
+	BUG_ON(compound_mapcount(page));
+	ret = __split_huge_page_refcount(page, list);
+	BUG_ON(!ret && PageCompound(page));
+
+out_unlock:
+	anon_vma_unlock_write(anon_vma);
+	put_anon_vma(anon_vma);
+out:
+	if (ret)
+		count_vm_event(THP_SPLIT_PAGE_FAILED);
+	else
+		count_vm_event(THP_SPLIT_PAGE);
+	return ret;
 }
 
 #define VM_NO_THP (VM_SPECIAL | VM_HUGETLB | VM_SHARED | VM_MAYSHARE)
diff --git a/mm/swap.c b/mm/swap.c
index 826cab5f725a..da28e0767088 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -80,12 +80,86 @@ static void __put_compound_page(struct page *page)
 	(*dtor)(page);
 }
 
+static inline bool compound_lock_needed(struct page *page)
+{
+	return IS_ENABLED(CONFIG_TRANSPARENT_HUGEPAGE) &&
+		!PageSlab(page) && !PageHeadHuge(page);
+}
+
 static void put_compound_page(struct page *page)
 {
-	struct page *page_head = compound_head(page);
+	struct page *page_head;
+	unsigned long flags;
+
+	if (likely(!PageTail(page))) {
+		if (put_page_testzero(page)) {
+			/*
+			 * By the time all refcounts have been released
+			 * split_huge_page cannot run anymore from under us.
+			 */
+			if (PageHead(page))
+				__put_compound_page(page);
+			else
+				__put_single_page(page);
+		}
+		return;
+	}
+
+	/* __split_huge_page_refcount can run under us */
+	page_head = compound_head(page);
+
+	if (!compound_lock_needed(page_head)) {
+		/*
+		 * If "page" is a THP tail, we must read the tail page flags
+		 * after the head page flags. The split_huge_page side enforces
+		 * write memory barriers between clearing PageTail and before
+		 * the head page can be freed and reallocated.
+		 */
+		smp_rmb();
+		if (likely(PageTail(page))) {
+			/* __split_huge_page_refcount cannot race here. */
+			VM_BUG_ON_PAGE(!PageHead(page_head), page_head);
+			VM_BUG_ON_PAGE(page_mapcount(page) != 0, page);
+			if (put_page_testzero(page_head)) {
+				/*
+				 * If this is the tail of a slab compound page,
+				 * the tail pin must not be the last reference
+				 * held on the page, because the PG_slab cannot
+				 * be cleared before all tail pins (which skips
+				 * the _mapcount tail refcounting) have been
+				 * released. For hugetlbfs the tail pin may be
+				 * the last reference on the page instead,
+				 * because PageHeadHuge will not go away until
+				 * the compound page enters the buddy
+				 * allocator.
+				 */
+				VM_BUG_ON_PAGE(PageSlab(page_head), page_head);
+				__put_compound_page(page_head);
+			}
+		} else if (put_page_testzero(page))
+			__put_single_page(page);
+		return;
+	}
 
-	if (put_page_testzero(page_head))
-			__put_compound_page(page_head);
+	flags = compound_lock_irqsave(page_head);
+	/* here __split_huge_page_refcount won't run anymore */
+	if (likely(page != page_head && PageTail(page))) {
+		bool free;
+
+		free = put_page_testzero(page_head);
+		compound_unlock_irqrestore(page_head, flags);
+		if (free) {
+			if (PageHead(page_head))
+				__put_compound_page(page_head);
+			else
+				__put_single_page(page_head);
+		}
+	} else {
+		compound_unlock_irqrestore(page_head, flags);
+		VM_BUG_ON_PAGE(PageTail(page), page);
+		if (put_page_testzero(page))
+			__put_single_page(page);
+	}
 }
 
 void put_page(struct page *page)
@@ -97,6 +171,52 @@ void put_page(struct page *page)
 }
 EXPORT_SYMBOL(put_page);
 
+/*
+ * This function is exported but must not be called by anything other
+ * than get_page(). It implements the slow path of get_page().
+ */
+void __get_page_tail(struct page *page)
+{
+	struct page *page_head = compound_head(page);
+	unsigned long flags;
+
+	if (!compound_lock_needed(page_head)) {
+		smp_rmb();
+		if (likely(PageTail(page))) {
+			/*
+			 * This is a hugetlbfs page or a slab page.
+			 * __split_huge_page_refcount cannot race here.
+			 */
+			VM_BUG_ON_PAGE(!PageHead(page_head), page_head);
+			VM_BUG_ON(page_head != page->first_page);
+			VM_BUG_ON_PAGE(atomic_read(&page_head->_count) <= 0,
+					page);
+			atomic_inc(&page_head->_count);
+		} else {
+			/*
+			 * __split_huge_page_refcount run before us, "page" was
+			 * a thp tail. the split page_head has been freed and
+			 * reallocated as slab or hugetlbfs page of smaller
+			 * order (only possible if reallocated as slab on x86).
+			 */
+			VM_BUG_ON_PAGE(atomic_read(&page->_count) <= 0, page);
+			atomic_inc(&page->_count);
+		}
+		return;
+	}
+
+	flags = compound_lock_irqsave(page_head);
+	/* here __split_huge_page_refcount won't run anymore */
+	if (unlikely(page == page_head || !PageTail(page) ||
+				!get_page_unless_zero(page_head))) {
+		/* page is not part of THP page anymore */
+		VM_BUG_ON_PAGE(atomic_read(&page->_count) <= 0, page);
+		atomic_inc(&page->_count);
+	}
+	compound_unlock_irqrestore(page_head, flags);
+}
+EXPORT_SYMBOL(__get_page_tail);
+
 /**
  * put_pages_list() - release a list of pages
  * @pages: list of pages threaded on page->lru
-- 
2.1.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
