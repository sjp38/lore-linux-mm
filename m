Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 09DE482F64
	for <linux-mm@kvack.org>; Mon, 21 Dec 2015 00:46:00 -0500 (EST)
Received: by mail-pa0-f50.google.com with SMTP id wq6so93766180pac.1
        for <linux-mm@kvack.org>; Sun, 20 Dec 2015 21:46:00 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id aj9si2106505pad.211.2015.12.20.21.45.58
        for <linux-mm@kvack.org>;
        Sun, 20 Dec 2015 21:45:59 -0800 (PST)
Subject: [-mm PATCH v4 16/18] mm, x86: get_user_pages() for dax mappings
From: Dan Williams <dan.j.williams@intel.com>
Date: Sun, 20 Dec 2015 21:45:32 -0800
Message-ID: <20151221054532.34542.69282.stgit@dwillia2-desk3.jf.intel.com>
In-Reply-To: <20151221054406.34542.64393.stgit@dwillia2-desk3.jf.intel.com>
References: <20151221054406.34542.64393.stgit@dwillia2-desk3.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave@sr71.net>, linux-nvdimm@lists.01.org, Peter Zijlstra <peterz@infradead.org>, x86@kernel.org, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Logan Gunthorpe <logang@deltatee.com>

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
Cc: x86@kernel.org
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>
Tested-by: Logan Gunthorpe <logang@deltatee.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 arch/x86/include/asm/pgtable.h |    7 ++++
 arch/x86/mm/gup.c              |   57 +++++++++++++++++++++++++++++-
 include/linux/huge_mm.h        |   10 +++++
 include/linux/mm.h             |   42 +++++++++++++++++-----
 kernel/memremap.c              |   20 +++++++++++
 mm/gup.c                       |   19 ++++++++++
 mm/huge_memory.c               |   75 ++++++++++++++++++++++++++++++++--------
 mm/swap.c                      |    3 ++
 8 files changed, 202 insertions(+), 31 deletions(-)

diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtable.h
index 993ce3c84ff4..40fe31853f07 100644
--- a/arch/x86/include/asm/pgtable.h
+++ b/arch/x86/include/asm/pgtable.h
@@ -482,6 +482,13 @@ static inline int pte_present(pte_t a)
 	return pte_flags(a) & (_PAGE_PRESENT | _PAGE_PROTNONE);
 }
 
+#ifdef __HAVE_ARCH_PTE_DEVMAP
+static inline int pte_devmap(pte_t a)
+{
+	return (pte_flags(a) & _PAGE_DEVMAP) == _PAGE_DEVMAP;
+}
+#endif
+
 #define pte_accessible pte_accessible
 static inline bool pte_accessible(struct mm_struct *mm, pte_t a)
 {
diff --git a/arch/x86/mm/gup.c b/arch/x86/mm/gup.c
index f8cb3e8ac250..6d5eb5900372 100644
--- a/arch/x86/mm/gup.c
+++ b/arch/x86/mm/gup.c
@@ -9,6 +9,7 @@
 #include <linux/vmstat.h>
 #include <linux/highmem.h>
 #include <linux/swap.h>
+#include <linux/memremap.h>
 
 #include <asm/pgtable.h>
 
@@ -63,6 +64,16 @@ retry:
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
@@ -71,7 +82,9 @@ retry:
 static noinline int gup_pte_range(pmd_t pmd, unsigned long addr,
 		unsigned long end, int write, struct page **pages, int *nr)
 {
+	struct dev_pagemap *pgmap = NULL;
 	unsigned long mask;
+	int nr_start = *nr;
 	pte_t *ptep;
 
 	mask = _PAGE_PRESENT|_PAGE_USER;
@@ -89,13 +102,21 @@ static noinline int gup_pte_range(pmd_t pmd, unsigned long addr,
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
@@ -114,6 +135,32 @@ static inline void get_head_page_multiple(struct page *page, int nr)
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
@@ -126,9 +173,13 @@ static noinline int gup_huge_pmd(pmd_t pmd, unsigned long addr,
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
index 40c4db60c9e0..bc141a65b736 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -38,7 +38,6 @@ extern int change_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
 			int prot_numa);
 int vmf_insert_pfn_pmd(struct vm_area_struct *, unsigned long addr, pmd_t *,
 			pfn_t pfn, bool write);
-
 enum transparent_hugepage_flag {
 	TRANSPARENT_HUGEPAGE_FLAG,
 	TRANSPARENT_HUGEPAGE_REQ_MADV_FLAG,
@@ -55,6 +54,9 @@ enum transparent_hugepage_flag {
 #define HPAGE_PMD_NR (1<<HPAGE_PMD_ORDER)
 
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
+struct page *follow_devmap_pmd(struct vm_area_struct *vma, unsigned long addr,
+		pmd_t *pmd, int flags);
+
 #define HPAGE_PMD_SHIFT PMD_SHIFT
 #define HPAGE_PMD_SIZE	((1UL) << HPAGE_PMD_SHIFT)
 #define HPAGE_PMD_MASK	(~(HPAGE_PMD_SIZE - 1))
@@ -205,6 +207,12 @@ static inline bool is_huge_zero_page(struct page *page)
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
index 96f396bbcc9f..be0c31362baf 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -16,6 +16,7 @@
 #include <linux/mm_types.h>
 #include <linux/range.h>
 #include <linux/pfn.h>
+#include <linux/percpu-refcount.h>
 #include <linux/bit_spinlock.h>
 #include <linux/shrinker.h>
 #include <linux/resource.h>
@@ -470,17 +471,6 @@ static inline int page_count(struct page *page)
 	return atomic_read(&compound_head(page)->_count);
 }
 
-static inline void get_page(struct page *page)
-{
-	page = compound_head(page);
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
@@ -687,17 +677,40 @@ static inline enum zone_type page_zonenum(const struct page *page)
 }
 
 #ifdef CONFIG_ZONE_DEVICE
+void get_zone_device_page(struct page *page);
+int release_zone_device_page(struct page *page);
 static inline bool is_zone_device_page(const struct page *page)
 {
 	return page_zonenum(page) == ZONE_DEVICE;
 }
 #else
+static inline void get_zone_device_page(struct page *page)
+{
+}
+static inline int release_zone_device_page(struct page *page)
+{
+	return 0;
+}
 static inline bool is_zone_device_page(const struct page *page)
 {
 	return false;
 }
 #endif
 
+static inline void get_page(struct page *page)
+{
+	page = compound_head(page);
+	/*
+	 * Getting a normal page or the head of a compound page
+	 * requires to already have an elevated page->_count.
+	 */
+	VM_BUG_ON_PAGE(atomic_read(&page->_count) <= 0, page);
+	atomic_inc(&page->_count);
+
+	if (unlikely(is_zone_device_page(page)))
+		get_zone_device_page(page);
+}
+
 #if defined(CONFIG_SPARSEMEM) && !defined(CONFIG_SPARSEMEM_VMEMMAP)
 #define SECTION_IN_PAGE_FLAGS
 #endif
@@ -1478,6 +1491,13 @@ static inline int pmd_devmap(pmd_t pmd)
 }
 #endif
 
+#ifndef __HAVE_ARCH_PTE_DEVMAP
+static inline int pte_devmap(pte_t pte)
+{
+	return 0;
+}
+#endif
+
 #if defined(__PAGETABLE_PMD_FOLDED) || !defined(CONFIG_MMU)
 static inline int __pmd_alloc(struct mm_struct *mm, pud_t *pud,
 						unsigned long address)
diff --git a/kernel/memremap.c b/kernel/memremap.c
index 3eb8944265d5..ccbb4beeaa71 100644
--- a/kernel/memremap.c
+++ b/kernel/memremap.c
@@ -169,6 +169,26 @@ struct page_map {
 	struct vmem_altmap altmap;
 };
 
+void get_zone_device_page(struct page *page)
+{
+	percpu_ref_get(page->pgmap->ref);
+}
+EXPORT_SYMBOL(get_zone_device_page);
+
+int release_zone_device_page(struct page *page)
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
+EXPORT_SYMBOL(release_zone_device_page);
+
 static void pgmap_radix_release(struct resource *res)
 {
 	resource_size_t key;
diff --git a/mm/gup.c b/mm/gup.c
index e95b0cb6ed81..a484e0df88b6 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -4,6 +4,7 @@
 #include <linux/spinlock.h>
 
 #include <linux/mm.h>
+#include <linux/memremap.h>
 #include <linux/pagemap.h>
 #include <linux/rmap.h>
 #include <linux/swap.h>
@@ -98,7 +99,16 @@ retry:
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
@@ -237,6 +247,13 @@ struct page *follow_page_mask(struct vm_area_struct *vma,
 	}
 	if ((flags & FOLL_NUMA) && pmd_protnone(*pmd))
 		return no_page_table(vma, flags);
+	if (pmd_devmap(*pmd)) {
+		ptl = pmd_lock(mm, pmd);
+		page = follow_devmap_pmd(vma, address, pmd, flags);
+		spin_unlock(ptl);
+		if (page)
+			return page;
+	}
 	if (likely(!pmd_trans_huge(*pmd)))
 		return follow_page_pte(vma, address, pmd, flags);
 
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 0c114fa08349..5fd0c4a30ae9 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -22,6 +22,7 @@
 #include <linux/freezer.h>
 #include <linux/pfn_t.h>
 #include <linux/mman.h>
+#include <linux/memremap.h>
 #include <linux/pagemap.h>
 #include <linux/migrate.h>
 #include <linux/hashtable.h>
@@ -1003,6 +1004,63 @@ int vmf_insert_pfn_pmd(struct vm_area_struct *vma, unsigned long addr,
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
+	/*
+	 * device mapped pages can only be returned if the
+	 * caller will manage the page reference count.
+	 */
+	if (!(flags & FOLL_GET))
+		return ERR_PTR(-EEXIST);
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
@@ -1360,21 +1418,8 @@ struct page *follow_trans_huge_pmd(struct vm_area_struct *vma,
 
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
 		/*
 		 * We don't mlock() pte-mapped THPs. This way we can avoid
diff --git a/mm/swap.c b/mm/swap.c
index 674e2c93da4e..9a6e3db20e59 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -24,6 +24,7 @@
 #include <linux/export.h>
 #include <linux/mm_inline.h>
 #include <linux/percpu_counter.h>
+#include <linux/memremap.h>
 #include <linux/percpu.h>
 #include <linux/cpu.h>
 #include <linux/notifier.h>
@@ -94,6 +95,8 @@ void __put_page(struct page *page)
 {
 	if (unlikely(PageCompound(page)))
 		__put_compound_page(page);
+	else if (unlikely(is_zone_device_page(page)))
+		release_zone_device_page(page);
 	else
 		__put_single_page(page);
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
