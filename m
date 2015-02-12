Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 68A0D6B0073
	for <linux-mm@kvack.org>; Thu, 12 Feb 2015 11:20:16 -0500 (EST)
Received: by mail-pa0-f49.google.com with SMTP id fb1so12385337pad.8
        for <linux-mm@kvack.org>; Thu, 12 Feb 2015 08:20:16 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id dh1si1708434pbc.142.2015.02.12.08.20.10
        for <linux-mm@kvack.org>;
        Thu, 12 Feb 2015 08:20:10 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv3 12/24] thp: PMD splitting without splitting compound page
Date: Thu, 12 Feb 2015 18:18:26 +0200
Message-Id: <1423757918-197669-13-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1423757918-197669-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1423757918-197669-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Current split_huge_page() combines two operations: splitting PMDs into
tables of PTEs and splitting underlying compound page. This patch
changes split_huge_pmd() implementation to split the given PMD without
splitting other PMDs this page mapped with or underlying compound page.

In order to do this we have to get rid of tail page refcounting, which
uses _mapcount of tail pages. Tail page refcounting is needed to be able
to split THP page at any point: we always know which of tail pages is
pinned (i.e. by get_user_pages()) and can distribute page count
correctly.

We can avoid this by allowing split_huge_page() to fail if the compound
page is pinned. This patch removes all infrastructure for tail page
refcounting and make split_huge_page() to always return -EBUSY. All
split_huge_page() users already know how to handle its fail. Proper
implementation will be added later.

Without tail page refcounting, implementation of split_huge_pmd() is
pretty straight-forward.

Memory cgroup is not yet ready for new refcouting. Let's disable it on
Kconfig level.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/mips/mm/gup.c            |   4 -
 arch/powerpc/mm/hugetlbpage.c |  13 +-
 arch/s390/mm/gup.c            |  13 +-
 arch/sparc/mm/gup.c           |  14 +--
 arch/x86/mm/gup.c             |   4 -
 include/linux/huge_mm.h       |   7 +-
 include/linux/mm.h            |  68 +----------
 include/linux/mm_types.h      |  19 +--
 mm/Kconfig                    |   2 +-
 mm/gup.c                      |  31 +----
 mm/huge_memory.c              | 275 ++++++++++--------------------------------
 mm/internal.h                 |  31 +----
 mm/swap.c                     | 245 +------------------------------------
 13 files changed, 88 insertions(+), 638 deletions(-)

diff --git a/arch/mips/mm/gup.c b/arch/mips/mm/gup.c
index 349995d19c7f..36a35115dc2e 100644
--- a/arch/mips/mm/gup.c
+++ b/arch/mips/mm/gup.c
@@ -87,8 +87,6 @@ static int gup_huge_pmd(pmd_t pmd, unsigned long addr, unsigned long end,
 	do {
 		VM_BUG_ON(compound_head(page) != head);
 		pages[*nr] = page;
-		if (PageTail(page))
-			get_huge_page_tail(page);
 		(*nr)++;
 		page++;
 		refs++;
@@ -153,8 +151,6 @@ static int gup_huge_pud(pud_t pud, unsigned long addr, unsigned long end,
 	do {
 		VM_BUG_ON(compound_head(page) != head);
 		pages[*nr] = page;
-		if (PageTail(page))
-			get_huge_page_tail(page);
 		(*nr)++;
 		page++;
 		refs++;
diff --git a/arch/powerpc/mm/hugetlbpage.c b/arch/powerpc/mm/hugetlbpage.c
index 7e408bfc7948..9a7f513d0068 100644
--- a/arch/powerpc/mm/hugetlbpage.c
+++ b/arch/powerpc/mm/hugetlbpage.c
@@ -1037,7 +1037,7 @@ int gup_hugepte(pte_t *ptep, unsigned long sz, unsigned long addr,
 {
 	unsigned long mask;
 	unsigned long pte_end;
-	struct page *head, *page, *tail;
+	struct page *head, *page;
 	pte_t pte;
 	int refs;
 
@@ -1060,7 +1060,6 @@ int gup_hugepte(pte_t *ptep, unsigned long sz, unsigned long addr,
 	head = pte_page(pte);
 
 	page = head + ((addr & (sz-1)) >> PAGE_SHIFT);
-	tail = page;
 	do {
 		VM_BUG_ON(compound_head(page) != head);
 		pages[*nr] = page;
@@ -1082,15 +1081,5 @@ int gup_hugepte(pte_t *ptep, unsigned long sz, unsigned long addr,
 		return 0;
 	}
 
-	/*
-	 * Any tail page need their mapcount reference taken before we
-	 * return.
-	 */
-	while (refs--) {
-		if (PageTail(tail))
-			get_huge_page_tail(tail);
-		tail++;
-	}
-
 	return 1;
 }
diff --git a/arch/s390/mm/gup.c b/arch/s390/mm/gup.c
index 5c586c78ca8d..dab30527ad41 100644
--- a/arch/s390/mm/gup.c
+++ b/arch/s390/mm/gup.c
@@ -52,7 +52,7 @@ static inline int gup_huge_pmd(pmd_t *pmdp, pmd_t pmd, unsigned long addr,
 		unsigned long end, int write, struct page **pages, int *nr)
 {
 	unsigned long mask, result;
-	struct page *head, *page, *tail;
+	struct page *head, *page;
 	int refs;
 
 	result = write ? 0 : _SEGMENT_ENTRY_PROTECT;
@@ -64,7 +64,6 @@ static inline int gup_huge_pmd(pmd_t *pmdp, pmd_t pmd, unsigned long addr,
 	refs = 0;
 	head = pmd_page(pmd);
 	page = head + ((addr & ~PMD_MASK) >> PAGE_SHIFT);
-	tail = page;
 	do {
 		VM_BUG_ON(compound_head(page) != head);
 		pages[*nr] = page;
@@ -85,16 +84,6 @@ static inline int gup_huge_pmd(pmd_t *pmdp, pmd_t pmd, unsigned long addr,
 		return 0;
 	}
 
-	/*
-	 * Any tail page need their mapcount reference taken before we
-	 * return.
-	 */
-	while (refs--) {
-		if (PageTail(tail))
-			get_huge_page_tail(tail);
-		tail++;
-	}
-
 	return 1;
 }
 
diff --git a/arch/sparc/mm/gup.c b/arch/sparc/mm/gup.c
index 2e5c4fc2daa9..9091c5daa2e1 100644
--- a/arch/sparc/mm/gup.c
+++ b/arch/sparc/mm/gup.c
@@ -56,8 +56,6 @@ static noinline int gup_pte_range(pmd_t pmd, unsigned long addr,
 			put_page(head);
 			return 0;
 		}
-		if (head != page)
-			get_huge_page_tail(page);
 
 		pages[*nr] = page;
 		(*nr)++;
@@ -70,7 +68,7 @@ static int gup_huge_pmd(pmd_t *pmdp, pmd_t pmd, unsigned long addr,
 			unsigned long end, int write, struct page **pages,
 			int *nr)
 {
-	struct page *head, *page, *tail;
+	struct page *head, *page;
 	int refs;
 
 	if (!(pmd_val(pmd) & _PAGE_VALID))
@@ -82,7 +80,6 @@ static int gup_huge_pmd(pmd_t *pmdp, pmd_t pmd, unsigned long addr,
 	refs = 0;
 	head = pmd_page(pmd);
 	page = head + ((addr & ~PMD_MASK) >> PAGE_SHIFT);
-	tail = page;
 	do {
 		VM_BUG_ON(compound_head(page) != head);
 		pages[*nr] = page;
@@ -103,15 +100,6 @@ static int gup_huge_pmd(pmd_t *pmdp, pmd_t pmd, unsigned long addr,
 		return 0;
 	}
 
-	/* Any tail page need their mapcount reference taken before we
-	 * return.
-	 */
-	while (refs--) {
-		if (PageTail(tail))
-			get_huge_page_tail(tail);
-		tail++;
-	}
-
 	return 1;
 }
 
diff --git a/arch/x86/mm/gup.c b/arch/x86/mm/gup.c
index 81bf3d2af3eb..62a887a3cf50 100644
--- a/arch/x86/mm/gup.c
+++ b/arch/x86/mm/gup.c
@@ -137,8 +137,6 @@ static noinline int gup_huge_pmd(pmd_t pmd, unsigned long addr,
 	do {
 		VM_BUG_ON_PAGE(compound_head(page) != head, page);
 		pages[*nr] = page;
-		if (PageTail(page))
-			get_huge_page_tail(page);
 		(*nr)++;
 		page++;
 		refs++;
@@ -214,8 +212,6 @@ static noinline int gup_huge_pud(pud_t pud, unsigned long addr,
 	do {
 		VM_BUG_ON_PAGE(compound_head(page) != head, page);
 		pages[*nr] = page;
-		if (PageTail(page))
-			get_huge_page_tail(page);
 		(*nr)++;
 		page++;
 		refs++;
diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index 34bbf769d52e..3c5fe722cc14 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -102,14 +102,13 @@ static inline int split_huge_page(struct page *page)
 {
 	return split_huge_page_to_list(page, NULL);
 }
-extern void __split_huge_page_pmd(struct vm_area_struct *vma,
-		unsigned long address, pmd_t *pmd);
+extern void __split_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
+		unsigned long address);
 #define split_huge_pmd(__vma, __pmd, __address)				\
 	do {								\
 		pmd_t *____pmd = (__pmd);				\
 		if (unlikely(pmd_trans_huge(*____pmd)))			\
-			__split_huge_page_pmd(__vma, __address,		\
-					____pmd);			\
+			__split_huge_pmd(__vma, __pmd, __address);	\
 	}  while (0)
 #define wait_split_huge_page(__anon_vma, __pmd)				\
 	do {								\
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 624cbeb58048..43468ebefaff 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -433,31 +433,10 @@ static inline void compound_unlock_irqrestore(struct page *page,
 #endif
 }
 
-static inline struct page *compound_head_by_tail(struct page *tail)
-{
-	struct page *head = tail->first_page;
-
-	/*
-	 * page->first_page may be a dangling pointer to an old
-	 * compound page, so recheck that it is still a tail
-	 * page before returning.
-	 */
-	smp_rmb();
-	if (likely(PageTail(tail)))
-		return head;
-	return tail;
-}
-
-/*
- * Since either compound page could be dismantled asynchronously in THP
- * or we access asynchronously arbitrary positioned struct page, there
- * would be tail flag race. To handle this race, we should call
- * smp_rmb() before checking tail flag. compound_head_by_tail() did it.
- */
 static inline struct page *compound_head(struct page *page)
 {
 	if (unlikely(PageTail(page)))
-		return compound_head_by_tail(page);
+		return page->first_page;
 	return page;
 }
 
@@ -515,50 +494,11 @@ static inline int PageHeadHuge(struct page *page_head)
 }
 #endif /* CONFIG_HUGETLB_PAGE */
 
-static inline bool __compound_tail_refcounted(struct page *page)
-{
-	return !PageSlab(page) && !PageHeadHuge(page);
-}
-
-/*
- * This takes a head page as parameter and tells if the
- * tail page reference counting can be skipped.
- *
- * For this to be safe, PageSlab and PageHeadHuge must remain true on
- * any given page where they return true here, until all tail pins
- * have been released.
- */
-static inline bool compound_tail_refcounted(struct page *page)
-{
-	VM_BUG_ON_PAGE(!PageHead(page), page);
-	return __compound_tail_refcounted(page);
-}
-
-static inline void get_huge_page_tail(struct page *page)
-{
-	/*
-	 * __split_huge_page_refcount() cannot run from under us.
-	 */
-	VM_BUG_ON_PAGE(!PageTail(page), page);
-	VM_BUG_ON_PAGE(page_mapcount(page) < 0, page);
-	VM_BUG_ON_PAGE(atomic_read(&page->_count) != 0, page);
-	if (compound_tail_refcounted(page->first_page))
-		atomic_inc(&page->_mapcount);
-}
-
-extern bool __get_page_tail(struct page *page);
-
 static inline void get_page(struct page *page)
 {
-	if (unlikely(PageTail(page)))
-		if (likely(__get_page_tail(page)))
-			return;
-	/*
-	 * Getting a normal page or the head of a compound page
-	 * requires to already have an elevated page->_count.
-	 */
-	VM_BUG_ON_PAGE(atomic_read(&page->_count) <= 0, page);
-	atomic_inc(&page->_count);
+	struct page *page_head = compound_head(page);
+	VM_BUG_ON_PAGE(atomic_read(&page_head->_count) <= 0, page);
+	atomic_inc(&page_head->_count);
 }
 
 static inline struct page *virt_to_head_page(const void *x)
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 2d19a4b6f6a6..1087672a04d5 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -93,20 +93,9 @@ struct page {
 
 				union {
 					/*
-					 * Count of ptes mapped in
-					 * mms, to show when page is
-					 * mapped & limit reverse map
-					 * searches.
-					 *
-					 * Used also for tail pages
-					 * refcounting instead of
-					 * _count. Tail pages cannot
-					 * be mapped and keeping the
-					 * tail page _count zero at
-					 * all times guarantees
-					 * get_page_unless_zero() will
-					 * never succeed on tail
-					 * pages.
+					 * Count of ptes mapped in mms, to show
+					 * when page is mapped & limit reverse
+					 * map searches.
 					 */
 					atomic_t _mapcount;
 
@@ -117,7 +106,7 @@ struct page {
 					};
 					int units;	/* SLOB */
 				};
-				atomic_t _count;		/* Usage count, see below. */
+				atomic_t _count; /* Usage count, see below. */
 			};
 			unsigned int active;	/* SLAB */
 		};
diff --git a/mm/Kconfig b/mm/Kconfig
index a03131b6ba8e..9ce853d2af5d 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -409,7 +409,7 @@ config NOMMU_INITIAL_TRIM_EXCESS
 
 config TRANSPARENT_HUGEPAGE
 	bool "Transparent Hugepage Support"
-	depends on HAVE_ARCH_TRANSPARENT_HUGEPAGE
+	depends on HAVE_ARCH_TRANSPARENT_HUGEPAGE && !MEMCG
 	select COMPACTION
 	help
 	  Transparent Hugepages allows the kernel to use huge pages and
diff --git a/mm/gup.c b/mm/gup.c
index 022d7a91de03..0c8d076d7744 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -980,7 +980,7 @@ static int gup_pte_range(pmd_t pmd, unsigned long addr, unsigned long end,
 static int gup_huge_pmd(pmd_t orig, pmd_t *pmdp, unsigned long addr,
 		unsigned long end, int write, struct page **pages, int *nr)
 {
-	struct page *head, *page, *tail;
+	struct page *head, *page;
 	int refs;
 
 	if (write && !pmd_write(orig))
@@ -989,7 +989,6 @@ static int gup_huge_pmd(pmd_t orig, pmd_t *pmdp, unsigned long addr,
 	refs = 0;
 	head = pmd_page(orig);
 	page = head + ((addr & ~PMD_MASK) >> PAGE_SHIFT);
-	tail = page;
 	do {
 		VM_BUG_ON_PAGE(compound_head(page) != head, page);
 		pages[*nr] = page;
@@ -1010,24 +1009,13 @@ static int gup_huge_pmd(pmd_t orig, pmd_t *pmdp, unsigned long addr,
 		return 0;
 	}
 
-	/*
-	 * Any tail pages need their mapcount reference taken before we
-	 * return. (This allows the THP code to bump their ref count when
-	 * they are split into base pages).
-	 */
-	while (refs--) {
-		if (PageTail(tail))
-			get_huge_page_tail(tail);
-		tail++;
-	}
-
 	return 1;
 }
 
 static int gup_huge_pud(pud_t orig, pud_t *pudp, unsigned long addr,
 		unsigned long end, int write, struct page **pages, int *nr)
 {
-	struct page *head, *page, *tail;
+	struct page *head, *page;
 	int refs;
 
 	if (write && !pud_write(orig))
@@ -1036,7 +1024,6 @@ static int gup_huge_pud(pud_t orig, pud_t *pudp, unsigned long addr,
 	refs = 0;
 	head = pud_page(orig);
 	page = head + ((addr & ~PUD_MASK) >> PAGE_SHIFT);
-	tail = page;
 	do {
 		VM_BUG_ON_PAGE(compound_head(page) != head, page);
 		pages[*nr] = page;
@@ -1057,12 +1044,6 @@ static int gup_huge_pud(pud_t orig, pud_t *pudp, unsigned long addr,
 		return 0;
 	}
 
-	while (refs--) {
-		if (PageTail(tail))
-			get_huge_page_tail(tail);
-		tail++;
-	}
-
 	return 1;
 }
 
@@ -1071,7 +1052,7 @@ static int gup_huge_pgd(pgd_t orig, pgd_t *pgdp, unsigned long addr,
 			struct page **pages, int *nr)
 {
 	int refs;
-	struct page *head, *page, *tail;
+	struct page *head, *page;
 
 	if (write && !pgd_write(orig))
 		return 0;
@@ -1100,12 +1081,6 @@ static int gup_huge_pgd(pgd_t orig, pgd_t *pgdp, unsigned long addr,
 		return 0;
 	}
 
-	while (refs--) {
-		if (PageTail(tail))
-			get_huge_page_tail(tail);
-		tail++;
-	}
-
 	return 1;
 }
 
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index d447afc039f9..46c3cd26f837 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -932,37 +932,6 @@ unlock:
 	spin_unlock(ptl);
 }
 
-/*
- * Save CONFIG_DEBUG_PAGEALLOC from faulting falsely on tail pages
- * during copy_user_huge_page()'s copy_page_rep(): in the case when
- * the source page gets split and a tail freed before copy completes.
- * Called under pmd_lock of checked pmd, so safe from splitting itself.
- */
-static void get_user_huge_page(struct page *page)
-{
-	if (IS_ENABLED(CONFIG_DEBUG_PAGEALLOC)) {
-		struct page *endpage = page + HPAGE_PMD_NR;
-
-		atomic_add(HPAGE_PMD_NR, &page->_count);
-		while (++page < endpage)
-			get_huge_page_tail(page);
-	} else {
-		get_page(page);
-	}
-}
-
-static void put_user_huge_page(struct page *page)
-{
-	if (IS_ENABLED(CONFIG_DEBUG_PAGEALLOC)) {
-		struct page *endpage = page + HPAGE_PMD_NR;
-
-		while (page < endpage)
-			put_page(page++);
-	} else {
-		put_page(page);
-	}
-}
-
 static int do_huge_pmd_wp_page_fallback(struct mm_struct *mm,
 					struct vm_area_struct *vma,
 					unsigned long address,
@@ -1113,7 +1082,7 @@ int do_huge_pmd_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		ret |= VM_FAULT_WRITE;
 		goto out_unlock;
 	}
-	get_user_huge_page(page);
+	get_page(page);
 	spin_unlock(ptl);
 alloc:
 	if (transparent_hugepage_enabled(vma) &&
@@ -1136,7 +1105,7 @@ alloc:
 				split_huge_pmd(vma, pmd, address);
 				ret |= VM_FAULT_FALLBACK;
 			}
-			put_user_huge_page(page);
+			put_page(page);
 		}
 		count_vm_event(THP_FAULT_FALLBACK);
 		goto out;
@@ -1147,7 +1116,7 @@ alloc:
 		put_page(new_page);
 		if (page) {
 			split_huge_pmd(vma, pmd, address);
-			put_user_huge_page(page);
+			put_page(page);
 		} else
 			split_huge_pmd(vma, pmd, address);
 		ret |= VM_FAULT_FALLBACK;
@@ -1169,7 +1138,7 @@ alloc:
 
 	spin_lock(ptl);
 	if (page)
-		put_user_huge_page(page);
+		put_page(page);
 	if (unlikely(!pmd_same(*pmd, orig_pmd))) {
 		spin_unlock(ptl);
 		mem_cgroup_cancel_charge(new_page, memcg);
@@ -1662,51 +1631,73 @@ static void __split_huge_zero_page_pmd(struct vm_area_struct *vma,
 	put_huge_zero_page();
 }
 
-void __split_huge_page_pmd(struct vm_area_struct *vma, unsigned long address,
-		pmd_t *pmd)
+
+static void __split_huge_pmd_locked(struct vm_area_struct *vma,
+		pmd_t *pmd, unsigned long address)
 {
-	spinlock_t *ptl;
+	unsigned long haddr = address & HPAGE_PMD_MASK;
 	struct page *page;
 	struct mm_struct *mm = vma->vm_mm;
-	unsigned long haddr = address & HPAGE_PMD_MASK;
-	unsigned long mmun_start;	/* For mmu_notifiers */
-	unsigned long mmun_end;		/* For mmu_notifiers */
+	pgtable_t pgtable;
+	pmd_t _pmd;
+	int i;
 
 	BUG_ON(vma->vm_start > haddr || vma->vm_end < haddr + HPAGE_PMD_SIZE);
 
+	if (is_huge_zero_pmd(*pmd))
+		return __split_huge_zero_page_pmd(vma, haddr, pmd);
+
+	page = pmd_page(*pmd);
+	VM_BUG_ON_PAGE(!page_count(page), page);
+	atomic_add(HPAGE_PMD_NR - 1, &page->_count);
+
+	/* leave pmd empty until pte is filled */
+	pmdp_clear_flush_notify(vma, haddr, pmd);
+
+	pgtable = pgtable_trans_huge_withdraw(mm, pmd);
+	pmd_populate(mm, &_pmd, pgtable);
+
+	for (i = 0; i < HPAGE_PMD_NR; i++, haddr += PAGE_SIZE) {
+		pte_t entry, *pte;
+		/*
+		 * Note that NUMA hinting access restrictions are not
+		 * transferred to avoid any possibility of altering
+		 * permissions across VMAs.
+		 */
+		entry = mk_pte(page + i, vma->vm_page_prot);
+		entry = maybe_mkwrite(pte_mkdirty(entry), vma);
+		if (!pmd_write(*pmd))
+			entry = pte_wrprotect(entry);
+		if (!pmd_young(*pmd))
+			entry = pte_mkold(entry);
+		pte = pte_offset_map(&_pmd, haddr);
+		BUG_ON(!pte_none(*pte));
+		atomic_inc(&page[i]._mapcount);
+		set_pte_at(mm, haddr, pte, entry);
+		pte_unmap(pte);
+	}
+	smp_wmb(); /* make pte visible before pmd */
+	pmd_populate(mm, pmd, pgtable);
+	atomic_dec(compound_mapcount_ptr(page));
+}
+
+void __split_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
+		unsigned long address)
+{
+	spinlock_t *ptl;
+	struct mm_struct *mm = vma->vm_mm;
+	unsigned long haddr = address & HPAGE_PMD_MASK;
+	unsigned long mmun_start;       /* For mmu_notifiers */
+	unsigned long mmun_end;         /* For mmu_notifiers */
+
 	mmun_start = haddr;
 	mmun_end   = haddr + HPAGE_PMD_SIZE;
-again:
 	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end);
 	ptl = pmd_lock(mm, pmd);
-	if (unlikely(!pmd_trans_huge(*pmd))) {
-		spin_unlock(ptl);
-		mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
-		return;
-	}
-	if (is_huge_zero_pmd(*pmd)) {
-		__split_huge_zero_page_pmd(vma, haddr, pmd);
-		spin_unlock(ptl);
-		mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
-		return;
-	}
-	page = pmd_page(*pmd);
-	VM_BUG_ON_PAGE(!page_count(page), page);
-	get_page(page);
+	if (likely(pmd_trans_huge(*pmd)))
+		__split_huge_pmd_locked(vma, pmd, address);
 	spin_unlock(ptl);
 	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
-
-	split_huge_page(page);
-
-	put_page(page);
-
-	/*
-	 * We don't always have down_write of mmap_sem here: a racing
-	 * do_huge_pmd_wp_page() might have copied-on-write to another
-	 * huge page before our split_huge_page() got the anon_vma lock.
-	 */
-	if (unlikely(pmd_trans_huge(*pmd)))
-		goto again;
 }
 
 static void split_huge_pmd_address(struct vm_area_struct *vma,
@@ -1736,42 +1727,10 @@ static void split_huge_pmd_address(struct vm_area_struct *vma,
 	 * Caller holds the mmap_sem write mode, so a huge pmd cannot
 	 * materialize from under us.
 	 */
-	__split_huge_page_pmd(vma, address, pmd);
-}
-
-static int __split_huge_page_splitting(struct page *page,
-				       struct vm_area_struct *vma,
-				       unsigned long address)
-{
-	struct mm_struct *mm = vma->vm_mm;
-	spinlock_t *ptl;
-	pmd_t *pmd;
-	int ret = 0;
-	/* For mmu_notifiers */
-	const unsigned long mmun_start = address;
-	const unsigned long mmun_end   = address + HPAGE_PMD_SIZE;
-
-	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end);
-	pmd = page_check_address_pmd(page, mm, address,
-			PAGE_CHECK_ADDRESS_PMD_NOTSPLITTING_FLAG, &ptl);
-	if (pmd) {
-		/*
-		 * We can't temporarily set the pmd to null in order
-		 * to split it, the pmd must remain marked huge at all
-		 * times or the VM won't take the pmd_trans_huge paths
-		 * and it won't wait on the anon_vma->root->rwsem to
-		 * serialize against split_huge_page*.
-		 */
-		pmdp_splitting_flush(vma, address, pmd);
-
-		ret = 1;
-		spin_unlock(ptl);
-	}
-	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
-
-	return ret;
+	__split_huge_pmd(vma, pmd, address);
 }
 
+#if 0
 static void __split_huge_page_refcount(struct page *page,
 				       struct list_head *list)
 {
@@ -1897,82 +1856,6 @@ static void __split_huge_page_refcount(struct page *page,
 	BUG_ON(page_count(page) <= 0);
 }
 
-static int __split_huge_page_map(struct page *page,
-				 struct vm_area_struct *vma,
-				 unsigned long address)
-{
-	struct mm_struct *mm = vma->vm_mm;
-	spinlock_t *ptl;
-	pmd_t *pmd, _pmd;
-	int ret = 0, i;
-	pgtable_t pgtable;
-	unsigned long haddr;
-
-	pmd = page_check_address_pmd(page, mm, address,
-			PAGE_CHECK_ADDRESS_PMD_SPLITTING_FLAG, &ptl);
-	if (pmd) {
-		pgtable = pgtable_trans_huge_withdraw(mm, pmd);
-		pmd_populate(mm, &_pmd, pgtable);
-		if (pmd_write(*pmd))
-			BUG_ON(page_mapcount(page) != 1);
-
-		haddr = address;
-		for (i = 0; i < HPAGE_PMD_NR; i++, haddr += PAGE_SIZE) {
-			pte_t *pte, entry;
-			BUG_ON(PageCompound(page+i));
-			/*
-			 * Note that NUMA hinting access restrictions are not
-			 * transferred to avoid any possibility of altering
-			 * permissions across VMAs.
-			 */
-			entry = mk_pte(page + i, vma->vm_page_prot);
-			entry = maybe_mkwrite(pte_mkdirty(entry), vma);
-			if (!pmd_write(*pmd))
-				entry = pte_wrprotect(entry);
-			if (!pmd_young(*pmd))
-				entry = pte_mkold(entry);
-			pte = pte_offset_map(&_pmd, haddr);
-			BUG_ON(!pte_none(*pte));
-			set_pte_at(mm, haddr, pte, entry);
-			pte_unmap(pte);
-		}
-
-		smp_wmb(); /* make pte visible before pmd */
-		/*
-		 * Up to this point the pmd is present and huge and
-		 * userland has the whole access to the hugepage
-		 * during the split (which happens in place). If we
-		 * overwrite the pmd with the not-huge version
-		 * pointing to the pte here (which of course we could
-		 * if all CPUs were bug free), userland could trigger
-		 * a small page size TLB miss on the small sized TLB
-		 * while the hugepage TLB entry is still established
-		 * in the huge TLB. Some CPU doesn't like that. See
-		 * http://support.amd.com/us/Processor_TechDocs/41322.pdf,
-		 * Erratum 383 on page 93. Intel should be safe but is
-		 * also warns that it's only safe if the permission
-		 * and cache attributes of the two entries loaded in
-		 * the two TLB is identical (which should be the case
-		 * here). But it is generally safer to never allow
-		 * small and huge TLB entries for the same virtual
-		 * address to be loaded simultaneously. So instead of
-		 * doing "pmd_populate(); flush_tlb_range();" we first
-		 * mark the current pmd notpresent (atomically because
-		 * here the pmd_trans_huge and pmd_trans_splitting
-		 * must remain set at all times on the pmd until the
-		 * split is complete for this pmd), then we flush the
-		 * SMP TLB and finally we write the non-huge version
-		 * of the pmd entry with pmd_populate.
-		 */
-		pmdp_invalidate(vma, address, pmd);
-		pmd_populate(mm, pmd, pgtable);
-		ret = 1;
-		spin_unlock(ptl);
-	}
-
-	return ret;
-}
-
 /* must be called with anon_vma->root->rwsem held */
 static void __split_huge_page(struct page *page,
 			      struct anon_vma *anon_vma,
@@ -2023,48 +1906,18 @@ static void __split_huge_page(struct page *page,
 		BUG();
 	}
 }
+#endif
 
 /*
  * Split a hugepage into normal pages. This doesn't change the position of head
  * page. If @list is null, tail pages will be added to LRU list, otherwise, to
  * @list. Both head page and tail pages will inherit mapping, flags, and so on
  * from the hugepage.
- * Return 0 if the hugepage is split successfully otherwise return 1.
+ * Return 0 if the hugepage is split successfully otherwise return -errno.
  */
 int split_huge_page_to_list(struct page *page, struct list_head *list)
 {
-	struct anon_vma *anon_vma;
-	int ret = 1;
-
-	BUG_ON(is_huge_zero_page(page));
-	BUG_ON(!PageAnon(page));
-
-	/*
-	 * The caller does not necessarily hold an mmap_sem that would prevent
-	 * the anon_vma disappearing so we first we take a reference to it
-	 * and then lock the anon_vma for write. This is similar to
-	 * page_lock_anon_vma_read except the write lock is taken to serialise
-	 * against parallel split or collapse operations.
-	 */
-	anon_vma = page_get_anon_vma(page);
-	if (!anon_vma)
-		goto out;
-	anon_vma_lock_write(anon_vma);
-
-	ret = 0;
-	if (!PageCompound(page))
-		goto out_unlock;
-
-	BUG_ON(!PageSwapBacked(page));
-	__split_huge_page(page, anon_vma, list);
-	count_vm_event(THP_SPLIT);
-
-	BUG_ON(PageCompound(page));
-out_unlock:
-	anon_vma_unlock_write(anon_vma);
-	put_anon_vma(anon_vma);
-out:
-	return ret;
+	return -EBUSY;
 }
 
 #define VM_NO_THP (VM_SPECIAL | VM_HUGETLB | VM_SHARED | VM_MAYSHARE)
diff --git a/mm/internal.h b/mm/internal.h
index c4d6c9b43491..ed57cc24802b 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -47,26 +47,6 @@ static inline void set_page_refcounted(struct page *page)
 	set_page_count(page, 1);
 }
 
-static inline void __get_page_tail_foll(struct page *page,
-					bool get_page_head)
-{
-	/*
-	 * If we're getting a tail page, the elevated page->_count is
-	 * required only in the head page and we will elevate the head
-	 * page->_count and tail page->_mapcount.
-	 *
-	 * We elevate page_tail->_mapcount for tail pages to force
-	 * page_tail->_count to be zero at all times to avoid getting
-	 * false positives from get_page_unless_zero() with
-	 * speculative page access (like in
-	 * page_cache_get_speculative()) on tail pages.
-	 */
-	VM_BUG_ON_PAGE(atomic_read(&page->first_page->_count) <= 0, page);
-	if (get_page_head)
-		atomic_inc(&page->first_page->_count);
-	get_huge_page_tail(page);
-}
-
 /*
  * This is meant to be called as the FOLL_GET operation of
  * follow_page() and it must be called while holding the proper PT
@@ -74,14 +54,9 @@ static inline void __get_page_tail_foll(struct page *page,
  */
 static inline void get_page_foll(struct page *page)
 {
-	if (unlikely(PageTail(page)))
-		/*
-		 * This is safe only because
-		 * __split_huge_page_refcount() can't run under
-		 * get_page_foll() because we hold the proper PT lock.
-		 */
-		__get_page_tail_foll(page, true);
-	else {
+	if (unlikely(PageTail(page))) {
+		atomic_inc(&page->first_page->_count);
+	} else {
 		/*
 		 * Getting a normal page or the head of a compound page
 		 * requires to already have an elevated page->_count.
diff --git a/mm/swap.c b/mm/swap.c
index cd3a5e64cea9..2e647d4dc6bb 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -80,185 +80,12 @@ static void __put_compound_page(struct page *page)
 	(*dtor)(page);
 }
 
-/**
- * Two special cases here: we could avoid taking compound_lock_irqsave
- * and could skip the tail refcounting(in _mapcount).
- *
- * 1. Hugetlbfs page:
- *
- *    PageHeadHuge will remain true until the compound page
- *    is released and enters the buddy allocator, and it could
- *    not be split by __split_huge_page_refcount().
- *
- *    So if we see PageHeadHuge set, and we have the tail page pin,
- *    then we could safely put head page.
- *
- * 2. Slab THP page:
- *
- *    PG_slab is cleared before the slab frees the head page, and
- *    tail pin cannot be the last reference left on the head page,
- *    because the slab code is free to reuse the compound page
- *    after a kfree/kmem_cache_free without having to check if
- *    there's any tail pin left.  In turn all tail pinsmust be always
- *    released while the head is still pinned by the slab code
- *    and so we know PG_slab will be still set too.
- *
- *    So if we see PageSlab set, and we have the tail page pin,
- *    then we could safely put head page.
- */
-static __always_inline
-void put_unrefcounted_compound_page(struct page *page_head, struct page *page)
-{
-	/*
-	 * If @page is a THP tail, we must read the tail page
-	 * flags after the head page flags. The
-	 * __split_huge_page_refcount side enforces write memory barriers
-	 * between clearing PageTail and before the head page
-	 * can be freed and reallocated.
-	 */
-	smp_rmb();
-	if (likely(PageTail(page))) {
-		/*
-		 * __split_huge_page_refcount cannot race
-		 * here, see the comment above this function.
-		 */
-		VM_BUG_ON_PAGE(!PageHead(page_head), page_head);
-		VM_BUG_ON_PAGE(page_mapcount(page) != 0, page);
-		if (put_page_testzero(page_head)) {
-			/*
-			 * If this is the tail of a slab THP page,
-			 * the tail pin must not be the last reference
-			 * held on the page, because the PG_slab cannot
-			 * be cleared before all tail pins (which skips
-			 * the _mapcount tail refcounting) have been
-			 * released.
-			 *
-			 * If this is the tail of a hugetlbfs page,
-			 * the tail pin may be the last reference on
-			 * the page instead, because PageHeadHuge will
-			 * not go away until the compound page enters
-			 * the buddy allocator.
-			 */
-			VM_BUG_ON_PAGE(PageSlab(page_head), page_head);
-			__put_compound_page(page_head);
-		}
-	} else
-		/*
-		 * __split_huge_page_refcount run before us,
-		 * @page was a THP tail. The split @page_head
-		 * has been freed and reallocated as slab or
-		 * hugetlbfs page of smaller order (only
-		 * possible if reallocated as slab on x86).
-		 */
-		if (put_page_testzero(page))
-			__put_single_page(page);
-}
-
-static __always_inline
-void put_refcounted_compound_page(struct page *page_head, struct page *page)
-{
-	if (likely(page != page_head && get_page_unless_zero(page_head))) {
-		unsigned long flags;
-
-		/*
-		 * @page_head wasn't a dangling pointer but it may not
-		 * be a head page anymore by the time we obtain the
-		 * lock. That is ok as long as it can't be freed from
-		 * under us.
-		 */
-		flags = compound_lock_irqsave(page_head);
-		if (unlikely(!PageTail(page))) {
-			/* __split_huge_page_refcount run before us */
-			compound_unlock_irqrestore(page_head, flags);
-			if (put_page_testzero(page_head)) {
-				/*
-				 * The @page_head may have been freed
-				 * and reallocated as a compound page
-				 * of smaller order and then freed
-				 * again.  All we know is that it
-				 * cannot have become: a THP page, a
-				 * compound page of higher order, a
-				 * tail page.  That is because we
-				 * still hold the refcount of the
-				 * split THP tail and page_head was
-				 * the THP head before the split.
-				 */
-				if (PageHead(page_head))
-					__put_compound_page(page_head);
-				else
-					__put_single_page(page_head);
-			}
-out_put_single:
-			if (put_page_testzero(page))
-				__put_single_page(page);
-			return;
-		}
-		VM_BUG_ON_PAGE(page_head != page->first_page, page);
-		/*
-		 * We can release the refcount taken by
-		 * get_page_unless_zero() now that
-		 * __split_huge_page_refcount() is blocked on the
-		 * compound_lock.
-		 */
-		if (put_page_testzero(page_head))
-			VM_BUG_ON_PAGE(1, page_head);
-		/* __split_huge_page_refcount will wait now */
-		VM_BUG_ON_PAGE(page_mapcount(page) <= 0, page);
-		atomic_dec(&page->_mapcount);
-		VM_BUG_ON_PAGE(atomic_read(&page_head->_count) <= 0, page_head);
-		VM_BUG_ON_PAGE(atomic_read(&page->_count) != 0, page);
-		compound_unlock_irqrestore(page_head, flags);
-
-		if (put_page_testzero(page_head)) {
-			if (PageHead(page_head))
-				__put_compound_page(page_head);
-			else
-				__put_single_page(page_head);
-		}
-	} else {
-		/* @page_head is a dangling pointer */
-		VM_BUG_ON_PAGE(PageTail(page), page);
-		goto out_put_single;
-	}
-}
-
 static void put_compound_page(struct page *page)
 {
-	struct page *page_head;
-
-	/*
-	 * We see the PageCompound set and PageTail not set, so @page maybe:
-	 *  1. hugetlbfs head page, or
-	 *  2. THP head page.
-	 */
-	if (likely(!PageTail(page))) {
-		if (put_page_testzero(page)) {
-			/*
-			 * By the time all refcounts have been released
-			 * split_huge_page cannot run anymore from under us.
-			 */
-			if (PageHead(page))
-				__put_compound_page(page);
-			else
-				__put_single_page(page);
-		}
-		return;
-	}
+	struct page *page_head = compound_head(page);
 
-	/*
-	 * We see the PageCompound set and PageTail set, so @page maybe:
-	 *  1. a tail hugetlbfs page, or
-	 *  2. a tail THP page, or
-	 *  3. a split THP page.
-	 *
-	 *  Case 3 is possible, as we may race with
-	 *  __split_huge_page_refcount tearing down a THP page.
-	 */
-	page_head = compound_head_by_tail(page);
-	if (!__compound_tail_refcounted(page_head))
-		put_unrefcounted_compound_page(page_head, page);
-	else
-		put_refcounted_compound_page(page_head, page);
+	if (put_page_testzero(page_head))
+			__put_compound_page(page_head);
 }
 
 void put_page(struct page *page)
@@ -270,72 +97,6 @@ void put_page(struct page *page)
 }
 EXPORT_SYMBOL(put_page);
 
-/*
- * This function is exported but must not be called by anything other
- * than get_page(). It implements the slow path of get_page().
- */
-bool __get_page_tail(struct page *page)
-{
-	/*
-	 * This takes care of get_page() if run on a tail page
-	 * returned by one of the get_user_pages/follow_page variants.
-	 * get_user_pages/follow_page itself doesn't need the compound
-	 * lock because it runs __get_page_tail_foll() under the
-	 * proper PT lock that already serializes against
-	 * split_huge_page().
-	 */
-	unsigned long flags;
-	bool got;
-	struct page *page_head = compound_head(page);
-
-	/* Ref to put_compound_page() comment. */
-	if (!__compound_tail_refcounted(page_head)) {
-		smp_rmb();
-		if (likely(PageTail(page))) {
-			/*
-			 * This is a hugetlbfs page or a slab
-			 * page. __split_huge_page_refcount
-			 * cannot race here.
-			 */
-			VM_BUG_ON_PAGE(!PageHead(page_head), page_head);
-			__get_page_tail_foll(page, true);
-			return true;
-		} else {
-			/*
-			 * __split_huge_page_refcount run
-			 * before us, "page" was a THP
-			 * tail. The split page_head has been
-			 * freed and reallocated as slab or
-			 * hugetlbfs page of smaller order
-			 * (only possible if reallocated as
-			 * slab on x86).
-			 */
-			return false;
-		}
-	}
-
-	got = false;
-	if (likely(page != page_head && get_page_unless_zero(page_head))) {
-		/*
-		 * page_head wasn't a dangling pointer but it
-		 * may not be a head page anymore by the time
-		 * we obtain the lock. That is ok as long as it
-		 * can't be freed from under us.
-		 */
-		flags = compound_lock_irqsave(page_head);
-		/* here __split_huge_page_refcount won't run anymore */
-		if (likely(PageTail(page))) {
-			__get_page_tail_foll(page, false);
-			got = true;
-		}
-		compound_unlock_irqrestore(page_head, flags);
-		if (unlikely(!got))
-			put_page(page_head);
-	}
-	return got;
-}
-EXPORT_SYMBOL(__get_page_tail);
-
 /**
  * put_pages_list() - release a list of pages
  * @pages: list of pages threaded on page->lru
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
