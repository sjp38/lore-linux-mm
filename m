Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 67B1F6B0096
	for <linux-mm@kvack.org>; Mon,  9 Jun 2014 12:04:38 -0400 (EDT)
Received: by mail-pa0-f46.google.com with SMTP id eu11so851225pac.5
        for <linux-mm@kvack.org>; Mon, 09 Jun 2014 09:04:38 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id ew3si31177133pbb.184.2014.06.09.09.04.37
        for <linux-mm@kvack.org>;
        Mon, 09 Jun 2014 09:04:37 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH, RFC 06/10] thp: implement new split_huge_page()
Date: Mon,  9 Jun 2014 19:04:17 +0300
Message-Id: <1402329861-7037-7-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1402329861-7037-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1402329861-7037-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

The new split_huge_page() can fail if the compound is pinned: we expect
only caller to have one reference to head page. If the page is pinned
split_huge_page() returns -EBUSY and caller must handle this correctly.

We don't need mark PMDs splitting since now we can split one PMD a time
with split_huge_pmd().

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/linux/hugetlb_inline.h |   9 +-
 include/linux/mm.h             |  22 +++--
 mm/huge_memory.c               | 191 ++++++++++++++++++++++++++++++++++++++++-
 mm/swap.c                      | 126 ++++++++++++++++++++++++++-
 4 files changed, 329 insertions(+), 19 deletions(-)

diff --git a/include/linux/hugetlb_inline.h b/include/linux/hugetlb_inline.h
index 4d60c82e9fda..1477dc1b3685 100644
--- a/include/linux/hugetlb_inline.h
+++ b/include/linux/hugetlb_inline.h
@@ -11,8 +11,9 @@ static inline int is_vm_hugetlb_page(struct vm_area_struct *vma)
 }
 
 int PageHuge(struct page *page);
+int PageHeadHuge(struct page *page_head);
 
-#else
+#else /* CONFIG_HUGETLB_PAGE */
 
 static inline int is_vm_hugetlb_page(struct vm_area_struct *vma)
 {
@@ -24,6 +25,10 @@ static inline int PageHuge(struct page *page)
 	return 0;
 }
 
-#endif
+static inline int PageHeadHuge(struct page *page_head)
+{
+	return 0;
+}
 
+#endif /* CONFIG_HUGETLB_PAGE */
 #endif
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 8885a7102aba..126112d46d85 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -440,20 +440,18 @@ static inline int page_count(struct page *page)
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
index fec89aedcedd..89c6f098f91f 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1576,10 +1576,197 @@ unlock:
 	return NULL;
 }
 
+static int __split_huge_page_refcount(struct page *page,
+				       struct list_head *list)
+{
+	int i;
+	struct zone *zone = page_zone(page);
+	struct lruvec *lruvec;
+	int tail_count;
+
+	/* prevent PageLRU to go away from under us, and freeze lru stats */
+	spin_lock_irq(&zone->lru_lock);
+	lruvec = mem_cgroup_page_lruvec(page, zone);
+
+	compound_lock(page);
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
+	tail_count = 0;
+	for (i = 0; i < HPAGE_PMD_NR; i++)
+		tail_count += page_mapcount(page + i);
+	if (tail_count != page_count(page) - 1) {
+		BUG_ON(tail_count > page_count(page) - 1);
+		compound_unlock(page);
+		spin_unlock_irq(&zone->lru_lock);
+		return -EBUSY;
+	}
+
+	/* complete memcg works before add pages to LRU */
+	mem_cgroup_split_huge_fixup(page);
+
+	tail_count = 0;
+	for (i = HPAGE_PMD_NR - 1; i >= 1; i--) {
+		struct page *page_tail = page + i;
+
+		/* tail_page->_mapcount cannot change */
+		BUG_ON(page_mapcount(page_tail) < 0);
+		tail_count += page_mapcount(page_tail);
+		/* check for overflow */
+		BUG_ON(tail_count < 0);
+		BUG_ON(atomic_read(&page_tail->_count) != 0);
+		/*
+		 * tail_page->_count is zero and not changing from
+		 * under us. But get_page_unless_zero() may be running
+		 * from under us on the tail_page. If we used
+		 * atomic_set() below instead of atomic_add(), we
+		 * would then run atomic_set() concurrently with
+		 * get_page_unless_zero(), and atomic_set() is
+		 * implemented in C not using locked ops. spin_unlock
+		 * on x86 sometime uses locked ops because of PPro
+		 * errata 66, 92, so unless somebody can guarantee
+		 * atomic_set() here would be safe on all archs (and
+		 * not only on x86), it's safer to use atomic_add().
+		 */
+		atomic_add(page_mapcount(page_tail) + 1, &page_tail->_count);
+
+		/* after clearing PageTail the gup refcount can be released */
+		smp_mb();
+
+		/*
+		 * retain hwpoison flag of the poisoned tail page:
+		 *   fix for the unsuitable process killed on Guest Machine(KVM)
+		 *   by the memory-failure.
+		 */
+		page_tail->flags &= ~PAGE_FLAGS_CHECK_AT_PREP | __PG_HWPOISON;
+		page_tail->flags |= (page->flags &
+				     ((1L << PG_referenced) |
+				      (1L << PG_swapbacked) |
+				      (1L << PG_mlocked) |
+				      (1L << PG_uptodate) |
+				      (1L << PG_active) |
+				      (1L << PG_unevictable)));
+		page_tail->flags |= (1L << PG_dirty);
+
+		/* clear PageTail before overwriting first_page */
+		smp_wmb();
+
+		BUG_ON(page_tail->mapping);
+		page_tail->mapping = page->mapping;
+
+		page_tail->index = page->index + i;
+		page_cpupid_xchg_last(page_tail, page_cpupid_last(page));
+
+		BUG_ON(!PageAnon(page_tail));
+		BUG_ON(!PageUptodate(page_tail));
+		BUG_ON(!PageDirty(page_tail));
+		BUG_ON(!PageSwapBacked(page_tail));
+
+		lru_add_page_tail(page, page_tail, lruvec, list);
+	}
+	atomic_sub(tail_count, &page->_count);
+	BUG_ON(atomic_read(&page->_count) <= 0);
+
+	__mod_zone_page_state(zone, NR_ANON_TRANSPARENT_HUGEPAGES, -1);
+
+	ClearPageCompound(page);
+	compound_unlock(page);
+	spin_unlock_irq(&zone->lru_lock);
+
+	for (i = 1; i < HPAGE_PMD_NR; i++) {
+		struct page *page_tail = page + i;
+		BUG_ON(page_count(page_tail) <= 0);
+		/*
+		 * Tail pages may be freed if there wasn't any mapping
+		 * like if add_to_swap() is running on a lru page that
+		 * had its mapping zapped. And freeing these pages
+		 * requires taking the lru_lock so we do the put_page
+		 * of the tail pages after the split is complete.
+		 */
+		put_page(page_tail);
+	}
+
+	/*
+	 * Only the head page (now become a regular page) is required
+	 * to be pinned by the caller.
+	 */
+	BUG_ON(page_count(page) <= 0);
+	return 0;
+}
+
 int split_huge_page_to_list(struct page *page, struct list_head *list)
 {
-	count_vm_event(THP_SPLIT_PAGE_FAILED);
-	return -EBUSY;
+	struct anon_vma *anon_vma;
+	struct anon_vma_chain *avc;
+	pgoff_t pgoff = page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
+	int i, tail_count;
+	int ret = -EBUSY;
+
+	BUG_ON(is_huge_zero_page(page));
+	BUG_ON(!PageAnon(page));
+
+	/*
+	 * The caller does not necessarily hold an mmap_sem that would prevent
+	 * the anon_vma disappearing so we first we take a reference to it
+	 * and then lock the anon_vma for write. This is similar to
+	 * page_lock_anon_vma_read except the write lock is taken to serialise
+	 * against parallel split or collapse operations.
+	 */
+	anon_vma = page_get_anon_vma(page);
+	if (!anon_vma)
+		goto out;
+	anon_vma_lock_write(anon_vma);
+
+	if (!PageCompound(page)) {
+		ret = 0;
+		goto out_unlock;
+	}
+
+	BUG_ON(!PageSwapBacked(page));
+
+	/*
+	 * Racy check if __split_huge_page_refcount() can be successful, before
+	 * splitting PMDs.
+	 */
+	tail_count = 0;
+	for (i = 0; i < HPAGE_PMD_NR; i++)
+		tail_count += page_mapcount(page + i);
+	if (tail_count != page_count(page) - 1) {
+		BUG_ON(tail_count > page_count(page) - 1);
+		return -EBUSY;
+	}
+
+	anon_vma_interval_tree_foreach(avc, &anon_vma->rb_root, pgoff, pgoff) {
+		struct vm_area_struct *vma = avc->vma;
+		unsigned long addr = vma_address(page, vma);
+		spinlock_t *ptl;
+		pmd_t *pmd;
+
+		pmd = page_check_address_pmd(page, vma->vm_mm, addr,
+				PAGE_CHECK_ADDRESS_PMD_FLAG, &ptl);
+		if (pmd)
+			__split_huge_pmd(vma, pmd, addr);
+	}
+
+	ret = __split_huge_page_refcount(page, list);
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
index 5faf87c3809b..0201c2704616 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -79,12 +79,86 @@ static void __put_compound_page(struct page *page)
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
@@ -96,6 +170,52 @@ void put_page(struct page *page)
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
2.0.0.rc4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
