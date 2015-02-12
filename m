Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id D01396B0070
	for <linux-mm@kvack.org>; Thu, 12 Feb 2015 11:19:01 -0500 (EST)
Received: by pdev10 with SMTP id v10so12874502pde.7
        for <linux-mm@kvack.org>; Thu, 12 Feb 2015 08:19:01 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id tv6si5283814pab.83.2015.02.12.08.18.59
        for <linux-mm@kvack.org>;
        Thu, 12 Feb 2015 08:19:00 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv3 06/24] mm: store mapcount for compound page separately
Date: Thu, 12 Feb 2015 18:18:20 +0200
Message-Id: <1423757918-197669-7-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1423757918-197669-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1423757918-197669-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

We're going to allow mapping of individual 4k pages of THP compound and
we need a cheap way to find out how many time the compound page is
mapped with PMD -- compound_mapcount() does this.

We use the same approach as with compound page destructor and compound
order: use space in first tail page, ->mapping this time.

page_mapcount() counts both: PTE and PMD mappings of the page.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/linux/mm.h       | 16 ++++++++++++++--
 include/linux/mm_types.h |  1 +
 include/linux/rmap.h     |  4 ++--
 mm/debug.c               |  5 ++++-
 mm/huge_memory.c         | 23 ++++++++++++++---------
 mm/hugetlb.c             |  4 ++--
 mm/memory.c              |  4 ++--
 mm/migrate.c             |  2 +-
 mm/page_alloc.c          |  7 ++++++-
 mm/rmap.c                | 47 +++++++++++++++++++++++++++++++++++++++--------
 10 files changed, 85 insertions(+), 28 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 9071066b7c2e..624cbeb58048 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -472,6 +472,18 @@ static inline struct page *compound_head_fast(struct page *page)
 		return page->first_page;
 	return page;
 }
+static inline atomic_t *compound_mapcount_ptr(struct page *page)
+{
+	return &page[1].compound_mapcount;
+}
+
+static inline int compound_mapcount(struct page *page)
+{
+	if (!PageCompound(page))
+		return 0;
+	page = compound_head(page);
+	return atomic_read(compound_mapcount_ptr(page)) + 1;
+}
 
 /*
  * The atomic page->_mapcount, starts from -1: so that transitions
@@ -486,7 +498,7 @@ static inline void page_mapcount_reset(struct page *page)
 static inline int page_mapcount(struct page *page)
 {
 	VM_BUG_ON_PAGE(PageSlab(page), page);
-	return atomic_read(&page->_mapcount) + 1;
+	return atomic_read(&page->_mapcount) + compound_mapcount(page) + 1;
 }
 
 static inline int page_count(struct page *page)
@@ -1081,7 +1093,7 @@ static inline pgoff_t page_file_index(struct page *page)
  */
 static inline int page_mapped(struct page *page)
 {
-	return atomic_read(&(page)->_mapcount) >= 0;
+	return atomic_read(&(page)->_mapcount) + compound_mapcount(page) >= 0;
 }
 
 /*
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 199a03aab8dc..2d19a4b6f6a6 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -56,6 +56,7 @@ struct page {
 						 * see PAGE_MAPPING_ANON below.
 						 */
 		void *s_mem;			/* slab first object */
+		atomic_t compound_mapcount;	/* first tail page */
 	};
 
 	/* Second double word */
diff --git a/include/linux/rmap.h b/include/linux/rmap.h
index 3bf73620b672..046e3bc810e6 100644
--- a/include/linux/rmap.h
+++ b/include/linux/rmap.h
@@ -192,9 +192,9 @@ void hugepage_add_anon_rmap(struct page *, struct vm_area_struct *,
 void hugepage_add_new_anon_rmap(struct page *, struct vm_area_struct *,
 				unsigned long);
 
-static inline void page_dup_rmap(struct page *page)
+static inline void page_dup_rmap(struct page *page, bool compound)
 {
-	atomic_inc(&page->_mapcount);
+	atomic_inc(compound ? compound_mapcount_ptr(page) : &page->_mapcount);
 }
 
 /*
diff --git a/mm/debug.c b/mm/debug.c
index 3eb3ac2fcee7..13d2b8146ef9 100644
--- a/mm/debug.c
+++ b/mm/debug.c
@@ -83,9 +83,12 @@ static void dump_flags(unsigned long flags,
 void dump_page_badflags(struct page *page, const char *reason,
 		unsigned long badflags)
 {
-	pr_emerg("page:%p count:%d mapcount:%d mapping:%p index:%#lx\n",
+	pr_emerg("page:%p count:%d mapcount:%d mapping:%p index:%#lx",
 		  page, atomic_read(&page->_count), page_mapcount(page),
 		  page->mapping, page->index);
+	if (PageCompound(page))
+		pr_cont(" compound_mapcount: %d", compound_mapcount(page));
+	pr_cont("\n");
 	BUILD_BUG_ON(ARRAY_SIZE(pageflag_names) != __NR_PAGEFLAGS);
 	dump_flags(page->flags, pageflag_names, ARRAY_SIZE(pageflag_names));
 	if (reason)
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 36637a80669e..17be7a978f17 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -890,7 +890,7 @@ int copy_huge_pmd(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 	src_page = pmd_page(pmd);
 	VM_BUG_ON_PAGE(!PageHead(src_page), src_page);
 	get_page(src_page);
-	page_dup_rmap(src_page);
+	page_dup_rmap(src_page, true);
 	add_mm_counter(dst_mm, MM_ANONPAGES, HPAGE_PMD_NR);
 
 	pmdp_set_wrprotect(src_mm, addr, src_pmd);
@@ -1787,8 +1787,8 @@ static void __split_huge_page_refcount(struct page *page,
 		struct page *page_tail = page + i;
 
 		/* tail_page->_mapcount cannot change */
-		BUG_ON(page_mapcount(page_tail) < 0);
-		tail_count += page_mapcount(page_tail);
+		BUG_ON(atomic_read(&page_tail->_mapcount) + 1 < 0);
+		tail_count += atomic_read(&page_tail->_mapcount) + 1;
 		/* check for overflow */
 		BUG_ON(tail_count < 0);
 		BUG_ON(atomic_read(&page_tail->_count) != 0);
@@ -1805,8 +1805,7 @@ static void __split_huge_page_refcount(struct page *page,
 		 * atomic_set() here would be safe on all archs (and
 		 * not only on x86), it's safer to use atomic_add().
 		 */
-		atomic_add(page_mapcount(page) + page_mapcount(page_tail) + 1,
-			   &page_tail->_count);
+		atomic_add(page_mapcount(page_tail) + 1, &page_tail->_count);
 
 		/* after clearing PageTail the gup refcount can be released */
 		smp_mb__after_atomic();
@@ -1843,15 +1842,18 @@ static void __split_huge_page_refcount(struct page *page,
 		 * status is achieved setting a reserved bit in the
 		 * pmd, not by clearing the present bit.
 		*/
-		page_tail->_mapcount = page->_mapcount;
+		atomic_set(&page_tail->_mapcount, compound_mapcount(page) - 1);
 
-		BUG_ON(page_tail->mapping);
-		page_tail->mapping = page->mapping;
+		/* ->mapping in first tail page is compound_mapcount */
+		if (i != 1) {
+			BUG_ON(page_tail->mapping);
+			page_tail->mapping = page->mapping;
+			BUG_ON(!PageAnon(page_tail));
+		}
 
 		page_tail->index = page->index + i;
 		page_cpupid_xchg_last(page_tail, page_cpupid_last(page));
 
-		BUG_ON(!PageAnon(page_tail));
 		BUG_ON(!PageUptodate(page_tail));
 		BUG_ON(!PageDirty(page_tail));
 		BUG_ON(!PageSwapBacked(page_tail));
@@ -1861,6 +1863,9 @@ static void __split_huge_page_refcount(struct page *page,
 	atomic_sub(tail_count, &page->_count);
 	BUG_ON(atomic_read(&page->_count) <= 0);
 
+	page->_mapcount = *compound_mapcount_ptr(page);
+	page[1].mapping = page->mapping;
+
 	__mod_zone_page_state(zone, NR_ANON_TRANSPARENT_HUGEPAGES, -1);
 
 	ClearPageCompound(page);
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index ebb7329301c4..2aa2a850d002 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -2606,7 +2606,7 @@ int copy_hugetlb_page_range(struct mm_struct *dst, struct mm_struct *src,
 			entry = huge_ptep_get(src_pte);
 			ptepage = pte_page(entry);
 			get_page(ptepage);
-			page_dup_rmap(ptepage);
+			page_dup_rmap(ptepage, true);
 			set_huge_pte_at(dst, addr, dst_pte, entry);
 		}
 		spin_unlock(src_ptl);
@@ -3065,7 +3065,7 @@ retry:
 		ClearPagePrivate(page);
 		hugepage_add_new_anon_rmap(page, vma, address);
 	} else
-		page_dup_rmap(page);
+		page_dup_rmap(page, true);
 	new_pte = make_huge_pte(vma, page, ((vma->vm_flags & VM_WRITE)
 				&& (vma->vm_flags & VM_SHARED)));
 	set_huge_pte_at(mm, address, ptep, new_pte);
diff --git a/mm/memory.c b/mm/memory.c
index 5529627d2cd6..343f800dff25 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -873,7 +873,7 @@ copy_one_pte(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 	page = vm_normal_page(vma, addr, pte);
 	if (page) {
 		get_page(page);
-		page_dup_rmap(page);
+		page_dup_rmap(page, false);
 		if (PageAnon(page))
 			rss[MM_ANONPAGES]++;
 		else
@@ -2972,7 +2972,7 @@ static int do_shared_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 	 * pinned by vma->vm_file's reference.  We rely on unlock_page()'s
 	 * release semantics to prevent the compiler from undoing this copying.
 	 */
-	mapping = fault_page->mapping;
+	mapping = compound_head(fault_page)->mapping;
 	unlock_page(fault_page);
 	if ((dirtied || vma->vm_ops->page_mkwrite) && mapping) {
 		/*
diff --git a/mm/migrate.c b/mm/migrate.c
index 0d2b3110277a..01449826b914 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -164,7 +164,7 @@ static int remove_migration_pte(struct page *new, struct vm_area_struct *vma,
 		if (PageAnon(new))
 			hugepage_add_anon_rmap(new, vma, addr);
 		else
-			page_dup_rmap(new);
+			page_dup_rmap(new, false);
 	} else if (PageAnon(new))
 		page_add_anon_rmap(new, vma, addr, false);
 	else
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 31bc2e8b5d99..b0ef1f6d2fb0 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -369,6 +369,7 @@ void prep_compound_page(struct page *page, unsigned long order)
 
 	set_compound_page_dtor(page, free_compound_page);
 	set_compound_order(page, order);
+	atomic_set(compound_mapcount_ptr(page), -1);
 	__SetPageHead(page);
 	for (i = 1; i < nr_pages; i++) {
 		struct page *p = page + i;
@@ -658,7 +659,9 @@ static inline int free_pages_check(struct page *page)
 
 	if (unlikely(page_mapcount(page)))
 		bad_reason = "nonzero mapcount";
-	if (unlikely(page->mapping != NULL))
+	if (unlikely(compound_mapcount(page)))
+		bad_reason = "nonzero compound_mapcount";
+	if (unlikely(page->mapping != NULL) && !PageTail(page))
 		bad_reason = "non-NULL mapping";
 	if (unlikely(atomic_read(&page->_count) != 0))
 		bad_reason = "nonzero _count";
@@ -800,6 +803,8 @@ static bool free_pages_prepare(struct page *page, unsigned int order)
 	}
 	if (bad)
 		return false;
+	if (order)
+		page[1].mapping = NULL;
 
 	reset_page_owner(page, order);
 
diff --git a/mm/rmap.c b/mm/rmap.c
index f67e83be75e4..333938475831 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1025,7 +1025,7 @@ static void __page_check_anon_rmap(struct page *page,
 	 * over the call to page_add_new_anon_rmap.
 	 */
 	BUG_ON(page_anon_vma(page)->root != vma->anon_vma->root);
-	BUG_ON(page->index != linear_page_index(vma, address));
+	BUG_ON(page_to_pgoff(page) != linear_page_index(vma, address));
 #endif
 }
 
@@ -1054,9 +1054,26 @@ void page_add_anon_rmap(struct page *page,
 void do_page_add_anon_rmap(struct page *page,
 	struct vm_area_struct *vma, unsigned long address, int flags)
 {
-	int first = atomic_inc_and_test(&page->_mapcount);
+	bool compound = flags & RMAP_COMPOUND;
+	bool first;
+
+	if (PageTransCompound(page)) {
+		VM_BUG_ON_PAGE(!PageLocked(compound_head(page)), page);
+		if (compound) {
+			VM_BUG_ON_PAGE(!PageTransHuge(page), page);
+			first = atomic_inc_and_test(compound_mapcount_ptr(page));
+		} else {
+			/* Anon THP always mapped first with PMD */
+			first = 0;
+			VM_BUG_ON_PAGE(!page_mapcount(page), page);
+			atomic_inc(&page->_mapcount);
+		}
+	} else {
+		VM_BUG_ON_PAGE(compound, page);
+		first = atomic_inc_and_test(&page->_mapcount);
+	}
+
 	if (first) {
-		bool compound = flags & RMAP_COMPOUND;
 		int nr = compound ? hpage_nr_pages(page) : 1;
 		/*
 		 * We use the irq-unsafe __{inc|mod}_zone_page_stat because
@@ -1074,7 +1091,8 @@ void do_page_add_anon_rmap(struct page *page,
 	if (unlikely(PageKsm(page)))
 		return;
 
-	VM_BUG_ON_PAGE(!PageLocked(page), page);
+	VM_BUG_ON_PAGE(!PageLocked(compound_head(page)), page);
+
 	/* address might be in next vma when migration races vma_adjust */
 	if (first)
 		__page_set_anon_rmap(page, vma, address,
@@ -1100,10 +1118,16 @@ void page_add_new_anon_rmap(struct page *page,
 
 	VM_BUG_ON_VMA(address < vma->vm_start || address >= vma->vm_end, vma);
 	SetPageSwapBacked(page);
-	atomic_set(&page->_mapcount, 0); /* increment count (starts at -1) */
 	if (compound) {
 		VM_BUG_ON_PAGE(!PageTransHuge(page), page);
+		/* increment count (starts at -1) */
+		atomic_set(compound_mapcount_ptr(page), 0);
 		__inc_zone_page_state(page, NR_ANON_TRANSPARENT_HUGEPAGES);
+	} else {
+		/* Anon THP always mapped first with PMD */
+		VM_BUG_ON_PAGE(PageTransCompound(page), page);
+		/* increment count (starts at -1) */
+		atomic_set(&page->_mapcount, 0);
 	}
 	__mod_zone_page_state(page_zone(page), NR_ANON_PAGES, nr);
 	__page_set_anon_rmap(page, vma, address, 1);
@@ -1172,7 +1196,9 @@ void page_remove_rmap(struct page *page, bool compound)
 	}
 
 	/* page still mapped by someone else? */
-	if (!atomic_add_negative(-1, &page->_mapcount))
+	if (!atomic_add_negative(-1, compound ?
+			       compound_mapcount_ptr(page) :
+			       &page->_mapcount))
 		return;
 
 	/* Hugepages are not counted in NR_ANON_PAGES for now. */
@@ -1185,8 +1211,13 @@ void page_remove_rmap(struct page *page, bool compound)
 	 * pte lock(a spinlock) is held, which implies preemption disabled.
 	 */
 	if (compound) {
+		int i;
 		VM_BUG_ON_PAGE(!PageTransHuge(page), page);
 		__dec_zone_page_state(page, NR_ANON_TRANSPARENT_HUGEPAGES);
+		/* The page can be mapped with ptes */
+		for (i = 0; i < HPAGE_PMD_NR; i++)
+			if (page_mapcount(page + i))
+				nr--;
 	}
 
 	__mod_zone_page_state(page_zone(page), NR_ANON_PAGES, -nr);
@@ -1630,7 +1661,7 @@ void hugepage_add_anon_rmap(struct page *page,
 	BUG_ON(!PageLocked(page));
 	BUG_ON(!anon_vma);
 	/* address might be in next vma when migration races vma_adjust */
-	first = atomic_inc_and_test(&page->_mapcount);
+	first = atomic_inc_and_test(compound_mapcount_ptr(page));
 	if (first)
 		__hugepage_set_anon_rmap(page, vma, address, 0);
 }
@@ -1639,7 +1670,7 @@ void hugepage_add_new_anon_rmap(struct page *page,
 			struct vm_area_struct *vma, unsigned long address)
 {
 	BUG_ON(address < vma->vm_start || address >= vma->vm_end);
-	atomic_set(&page->_mapcount, 0);
+	atomic_set(compound_mapcount_ptr(page), 0);
 	__hugepage_set_anon_rmap(page, vma, address, 1);
 }
 #endif /* CONFIG_HUGETLB_PAGE */
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
