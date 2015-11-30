Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 0896D6B0259
	for <linux-mm@kvack.org>; Mon, 30 Nov 2015 00:09:18 -0500 (EST)
Received: by pacej9 with SMTP id ej9so172235031pac.2
        for <linux-mm@kvack.org>; Sun, 29 Nov 2015 21:09:17 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id sf3si7629268pac.58.2015.11.29.21.09.17
        for <linux-mm@kvack.org>;
        Sun, 29 Nov 2015 21:09:17 -0800 (PST)
Subject: [RFC PATCH 3/5] mm, x86: get_user_pages() for dax mappings
From: Dan Williams <dan.j.williams@intel.com>
Date: Sun, 29 Nov 2015 21:08:49 -0800
Message-ID: <20151130050849.18366.26200.stgit@dwillia2-desk3.jf.intel.com>
In-Reply-To: <20151130050833.18366.21963.stgit@dwillia2-desk3.jf.intel.com>
References: <20151130050833.18366.21963.stgit@dwillia2-desk3.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave@sr71.net>, toshi.kani@hp.com, linux-nvdimm@lists.01.org, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>

A dax mapping establishes a pte with _PAGE_DEVMAP set when the driver
has established a devm_memremap_pages() mapping, i.e. when the pfn_t
return from ->direct_access() has PFN_DEV and PFN_MAP set.  Later, when
encountering _PAGE_DEVMAP during a page table walk we lookup and pin a
struct dev_pagemap instance to keep the result of pfn_to_page() valid
until put_page().

Cc: Dave Hansen <dave@sr71.net>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 arch/x86/mm/gup.c       |   56 ++++++++++++++++++++++++++++++++++--
 include/linux/huge_mm.h |   10 ++++++
 include/linux/mm.h      |   40 +++++++++++++++++--------
 mm/gup.c                |   17 ++++++++++-
 mm/huge_memory.c        |   74 +++++++++++++++++++++++++++++++++++++----------
 mm/swap.c               |   15 ++++++++++
 6 files changed, 179 insertions(+), 33 deletions(-)

diff --git a/arch/x86/mm/gup.c b/arch/x86/mm/gup.c
index ae9a37bf1371..9fa9e8be6e70 100644
--- a/arch/x86/mm/gup.c
+++ b/arch/x86/mm/gup.c
@@ -63,6 +63,16 @@ retry:
 #endif
 }
 
+static void undo_dev_pagemap(int *nr, int nr_start, struct page **pages)
+{
+	while ((*nr) - nr_start) {
+		struct page *page = pages[--(*nr)];
+
+		ClearPageReferenced(page);
+		put_page(page);
+	}
+}
+
 /*
  * The performance critical leaf functions are made noinline otherwise gcc
  * inlines everything into a single function which results in too much
@@ -71,7 +81,9 @@ retry:
 static noinline int gup_pte_range(pmd_t pmd, unsigned long addr,
 		unsigned long end, int write, struct page **pages, int *nr)
 {
+	struct dev_pagemap *pgmap = NULL;
 	unsigned long mask;
+	int nr_start = *nr;
 	pte_t *ptep;
 
 	mask = _PAGE_PRESENT|_PAGE_USER;
@@ -89,13 +101,21 @@ static noinline int gup_pte_range(pmd_t pmd, unsigned long addr,
 			return 0;
 		}
 
-		if ((pte_flags(pte) & (mask | _PAGE_SPECIAL)) != mask) {
+		page = pte_page(pte);
+		if (pte_devmap(pte)) {
+			pgmap = get_dev_pagemap(pte_pfn(pte), pgmap);
+			if (unlikely(!pgmap)) {
+				undo_dev_pagemap(nr, nr_start, pages);
+				pte_unmap(ptep);
+				return 0;
+			}
+		} else if ((pte_flags(pte) & (mask | _PAGE_SPECIAL)) != mask) {
 			pte_unmap(ptep);
 			return 0;
 		}
 		VM_BUG_ON(!pfn_valid(pte_pfn(pte)));
-		page = pte_page(pte);
 		get_page(page);
+		put_dev_pagemap(pgmap);
 		SetPageReferenced(page);
 		pages[*nr] = page;
 		(*nr)++;
@@ -114,6 +134,32 @@ static inline void get_head_page_multiple(struct page *page, int nr)
 	SetPageReferenced(page);
 }
 
+static int __gup_device_huge_pmd(pmd_t pmd, unsigned long addr,
+		unsigned long end, struct page **pages, int *nr)
+{
+	int nr_start = *nr;
+	unsigned long pfn = pmd_pfn(pmd);
+	struct dev_pagemap *pgmap = NULL;
+
+	pfn += (addr & ~PMD_MASK) >> PAGE_SHIFT;
+	do {
+		struct page *page = pfn_to_page(pfn);
+
+		pgmap = get_dev_pagemap(pfn, pgmap);
+		if (unlikely(!pgmap)) {
+			undo_dev_pagemap(nr, nr_start, pages);
+			return 0;
+		}
+		SetPageReferenced(page);
+		pages[*nr] = page;
+		get_page(page);
+		put_dev_pagemap(pgmap);
+		(*nr)++;
+		pfn++;
+	} while (addr += PAGE_SIZE, addr != end);
+	return 1;
+}
+
 static noinline int gup_huge_pmd(pmd_t pmd, unsigned long addr,
 		unsigned long end, int write, struct page **pages, int *nr)
 {
@@ -126,9 +172,13 @@ static noinline int gup_huge_pmd(pmd_t pmd, unsigned long addr,
 		mask |= _PAGE_RW;
 	if ((pmd_flags(pmd) & mask) != mask)
 		return 0;
+
+	VM_BUG_ON(!pfn_valid(pmd_pfn(pmd)));
+	if (pmd_devmap(pmd))
+		return __gup_device_huge_pmd(pmd, addr, end, pages, nr);
+
 	/* hugepages are never "special" */
 	VM_BUG_ON(pmd_flags(pmd) & _PAGE_SPECIAL);
-	VM_BUG_ON(!pfn_valid(pmd_pfn(pmd)));
 
 	refs = 0;
 	head = pmd_page(pmd);
diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index 9c9c1688889a..9278ba57b390 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -35,7 +35,6 @@ extern int change_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
 			int prot_numa);
 int vmf_insert_pfn_pmd(struct vm_area_struct *, unsigned long addr, pmd_t *,
 			pfn_t pfn, bool write);
-
 enum transparent_hugepage_flag {
 	TRANSPARENT_HUGEPAGE_FLAG,
 	TRANSPARENT_HUGEPAGE_REQ_MADV_FLAG,
@@ -63,6 +62,9 @@ extern pmd_t *page_check_address_pmd(struct page *page,
 #define HPAGE_PMD_NR (1<<HPAGE_PMD_ORDER)
 
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
+struct page *follow_devmap_pmd(struct vm_area_struct *vma, unsigned long addr,
+		pmd_t *pmd, int flags);
+
 #define HPAGE_PMD_SHIFT PMD_SHIFT
 #define HPAGE_PMD_SIZE	((1UL) << HPAGE_PMD_SHIFT)
 #define HPAGE_PMD_MASK	(~(HPAGE_PMD_SIZE - 1))
@@ -219,6 +221,12 @@ static inline bool is_huge_zero_page(struct page *page)
 	return false;
 }
 
+
+static inline struct page *follow_devmap_pmd(struct vm_area_struct *vma,
+		unsigned long addr, pmd_t *pmd, int flags)
+{
+	return NULL;
+}
 #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
 
 #endif /* _LINUX_HUGE_MM_H */
diff --git a/include/linux/mm.h b/include/linux/mm.h
index f985d181e730..40ee1d17f847 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -486,19 +486,6 @@ static inline void get_huge_page_tail(struct page *page)
 
 extern bool __get_page_tail(struct page *page);
 
-static inline void get_page(struct page *page)
-{
-	if (unlikely(PageTail(page)))
-		if (likely(__get_page_tail(page)))
-			return;
-	/*
-	 * Getting a normal page or the head of a compound page
-	 * requires to already have an elevated page->_count.
-	 */
-	VM_BUG_ON_PAGE(atomic_read(&page->_count) <= 0, page);
-	atomic_inc(&page->_count);
-}
-
 static inline struct page *virt_to_head_page(const void *x)
 {
 	struct page *page = virt_to_page(x);
@@ -777,6 +764,11 @@ struct dev_pagemap {
 void *devm_memremap_pages(struct device *dev, struct resource *res,
 		struct percpu_ref *ref, struct vmem_altmap *altmap);
 struct dev_pagemap *find_dev_pagemap(resource_size_t phys);
+
+static inline bool is_zone_device_page(const struct page *page)
+{
+	return page_zonenum(page) == ZONE_DEVICE;
+}
 #else
 static inline void *devm_memremap_pages(struct device *dev,
 		struct resource *res, struct percpu_ref *ref,
@@ -795,6 +787,11 @@ static inline struct dev_pagemap *find_dev_pagemap(resource_size_t phys)
 {
 	return NULL;
 }
+
+static inline bool is_zone_device_page(const struct page *page)
+{
+	return false;
+}
 #endif
 
 #if defined(CONFIG_SPARSEMEM_VMEMMAP) && defined(CONFIG_ZONE_DEVICE)
@@ -845,6 +842,23 @@ static inline void put_dev_pagemap(struct dev_pagemap *pgmap)
 		percpu_ref_put(pgmap->ref);
 }
 
+static inline void get_page(struct page *page)
+{
+	if (unlikely(PageTail(page)))
+		if (likely(__get_page_tail(page)))
+			return;
+
+	if (is_zone_device_page(page))
+		percpu_ref_get(page->pgmap->ref);
+
+	/*
+	 * Getting a normal page or the head of a compound page
+	 * requires to already have an elevated page->_count.
+	 */
+	VM_BUG_ON_PAGE(atomic_read(&page->_count) <= 0, page);
+	atomic_inc(&page->_count);
+}
+
 #if defined(CONFIG_SPARSEMEM) && !defined(CONFIG_SPARSEMEM_VMEMMAP)
 #define SECTION_IN_PAGE_FLAGS
 #endif
diff --git a/mm/gup.c b/mm/gup.c
index deafa2c91b36..32514c179830 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -98,7 +98,16 @@ retry:
 	}
 
 	page = vm_normal_page(vma, address, pte);
-	if (unlikely(!page)) {
+	if (!page && pte_devmap(pte) && (flags & FOLL_GET)) {
+		/*
+		 * Only return device mapping pages in the FOLL_GET case since
+		 * they are only valid while holding the pgmap reference.
+		 */
+		if (get_dev_pagemap(pte_pfn(pte), NULL))
+			page = pte_page(pte);
+		else
+			goto no_page;
+	} else if (unlikely(!page)) {
 		if (flags & FOLL_DUMP) {
 			/* Avoid special (like zero) pages in core dumps */
 			page = ERR_PTR(-EFAULT);
@@ -240,6 +249,12 @@ struct page *follow_page_mask(struct vm_area_struct *vma,
 		} else
 			spin_unlock(ptl);
 	}
+	if (pmd_devmap(*pmd)) {
+		ptl = pmd_lock(mm, pmd);
+		page = follow_devmap_pmd(vma, address, pmd, flags);
+		spin_unlock(ptl);
+		return page;
+	}
 	return follow_page_pte(vma, address, pmd, flags);
 }
 
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 329cedf48b8a..f0b020e65547 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -912,6 +912,63 @@ int vmf_insert_pfn_pmd(struct vm_area_struct *vma, unsigned long addr,
 	return VM_FAULT_NOPAGE;
 }
 
+static void touch_pmd(struct vm_area_struct *vma, unsigned long addr,
+		pmd_t *pmd)
+{
+	pmd_t _pmd;
+
+	/*
+	 * We should set the dirty bit only for FOLL_WRITE but for now
+	 * the dirty bit in the pmd is meaningless.  And if the dirty
+	 * bit will become meaningful and we'll only set it with
+	 * FOLL_WRITE, an atomic set_bit will be required on the pmd to
+	 * set the young bit, instead of the current set_pmd_at.
+	 */
+	_pmd = pmd_mkyoung(pmd_mkdirty(*pmd));
+	if (pmdp_set_access_flags(vma, addr & HPAGE_PMD_MASK,
+				pmd, _pmd,  1))
+		update_mmu_cache_pmd(vma, addr, pmd);
+}
+
+struct page *follow_devmap_pmd(struct vm_area_struct *vma, unsigned long addr,
+		pmd_t *pmd, int flags)
+{
+	unsigned long pfn = pmd_pfn(*pmd);
+	struct mm_struct *mm = vma->vm_mm;
+	struct dev_pagemap *pgmap;
+	struct page *page;
+
+	assert_spin_locked(pmd_lockptr(mm, pmd));
+
+	/*
+	 * device mapped pages can only be returned if the
+	 * caller will manage the page reference count.
+	 */
+	if (!(flags & FOLL_GET))
+		return NULL;
+
+	if (flags & FOLL_WRITE && !pmd_write(*pmd))
+		return NULL;
+
+	if (pmd_present(*pmd) && pmd_devmap(*pmd))
+		/* pass */;
+	else
+		return NULL;
+
+	if (flags & FOLL_TOUCH)
+		touch_pmd(vma, addr, pmd);
+
+	pfn += (addr & ~PMD_MASK) >> PAGE_SHIFT;
+	pgmap = get_dev_pagemap(pfn, NULL);
+	if (!pgmap)
+		return ERR_PTR(-EFAULT);
+	page = pfn_to_page(pfn);
+	get_page(page);
+	put_dev_pagemap(pgmap);
+
+	return page;
+}
+
 int copy_huge_pmd(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 		  pmd_t *dst_pmd, pmd_t *src_pmd, unsigned long addr,
 		  struct vm_area_struct *vma)
@@ -1295,21 +1352,8 @@ struct page *follow_trans_huge_pmd(struct vm_area_struct *vma,
 
 	page = pmd_page(*pmd);
 	VM_BUG_ON_PAGE(!PageHead(page), page);
-	if (flags & FOLL_TOUCH) {
-		pmd_t _pmd;
-		/*
-		 * We should set the dirty bit only for FOLL_WRITE but
-		 * for now the dirty bit in the pmd is meaningless.
-		 * And if the dirty bit will become meaningful and
-		 * we'll only set it with FOLL_WRITE, an atomic
-		 * set_bit will be required on the pmd to set the
-		 * young bit, instead of the current set_pmd_at.
-		 */
-		_pmd = pmd_mkyoung(pmd_mkdirty(*pmd));
-		if (pmdp_set_access_flags(vma, addr & HPAGE_PMD_MASK,
-					  pmd, _pmd,  1))
-			update_mmu_cache_pmd(vma, addr, pmd);
-	}
+	if (flags & FOLL_TOUCH)
+		touch_pmd(vma, addr, pmd);
 	if ((flags & FOLL_MLOCK) && (vma->vm_flags & VM_LOCKED)) {
 		if (page->mapping && trylock_page(page)) {
 			lru_add_drain();
diff --git a/mm/swap.c b/mm/swap.c
index 39395fb549c0..1d1d4309aff6 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -230,6 +230,19 @@ out_put_single:
 	}
 }
 
+static bool put_device_page(struct page *page)
+{
+	/*
+	 * ZONE_DEVICE pages are never "onlined" so their reference
+	 * counts never reach zero.  They are always owned by a device
+	 * driver, not the mm core.  I.e. the page is 'idle' when the
+	 * count is 1.
+	 */
+	VM_BUG_ON_PAGE(atomic_read(&page->_count) == 1, page);
+	put_dev_pagemap(page->pgmap);
+	return atomic_dec_return(&page->_count) == 1;
+}
+
 static void put_compound_page(struct page *page)
 {
 	struct page *page_head;
@@ -273,6 +286,8 @@ void put_page(struct page *page)
 {
 	if (unlikely(PageCompound(page)))
 		put_compound_page(page);
+	else if (is_zone_device_page(page))
+		put_device_page(page);
 	else if (put_page_testzero(page))
 		__put_single_page(page);
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
