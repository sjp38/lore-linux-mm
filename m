Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 828B682F64
	for <linux-mm@kvack.org>; Fri,  9 Oct 2015 21:02:55 -0400 (EDT)
Received: by pabve7 with SMTP id ve7so42220034pab.2
        for <linux-mm@kvack.org>; Fri, 09 Oct 2015 18:02:55 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id vb4si6496877pbc.53.2015.10.09.18.02.54
        for <linux-mm@kvack.org>;
        Fri, 09 Oct 2015 18:02:54 -0700 (PDT)
Subject: [PATCH v2 20/20] mm, x86: get_user_pages() for dax mappings
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 09 Oct 2015 20:57:11 -0400
Message-ID: <20151010005711.17221.27221.stgit@dwillia2-desk3.jf.intel.com>
In-Reply-To: <20151010005522.17221.87557.stgit@dwillia2-desk3.jf.intel.com>
References: <20151010005522.17221.87557.stgit@dwillia2-desk3.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-nvdimm@lists.01.org
Cc: Dave Hansen <dave@sr71.net>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Dave Chinner <david@fromorbit.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Jeff Moyer <jmoyer@redhat.com>, Ingo Molnar <mingo@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Alexander Viro <viro@zeniv.linux.org.uk>, "H. Peter Anvin" <hpa@zytor.com>, Matthew Wilcox <willy@linux.intel.com>, ross.zwisler@linux.intel.com, hch@lst.de

A dax mapping establishes a pte with _PAGE_DEVMAP set when the driver
has established a devm_memremap_pages() mapping, i.e. when the pfn_t
return from ->direct_access() has PFN_DEV and PFN_MAP set.  Later, when
encountering _PAGE_DEVMAP during a page table walk we lookup and pin a
struct dev_pagemap instance to keep the result of pfn_to_page() valid
until put_page().

Cc: Dave Hansen <dave@sr71.net>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Hellwig <hch@lst.de>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: H. Peter Anvin <hpa@zytor.com>
Cc: Jeff Moyer <jmoyer@redhat.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Matthew Wilcox <willy@linux.intel.com>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>
Cc: Dave Chinner <david@fromorbit.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 arch/ia64/include/asm/pgtable.h |    1 +
 arch/x86/include/asm/pgtable.h  |    2 +
 arch/x86/mm/gup.c               |   56 +++++++++++++++++++++++++++++++++++++--
 include/linux/mm.h              |   40 +++++++++++++++++++---------
 mm/gup.c                        |   11 +++++++-
 mm/hugetlb.c                    |   18 ++++++++++++-
 mm/swap.c                       |   15 ++++++++++
 7 files changed, 124 insertions(+), 19 deletions(-)

diff --git a/arch/ia64/include/asm/pgtable.h b/arch/ia64/include/asm/pgtable.h
index 9f3ed9ee8f13..81d2af23958f 100644
--- a/arch/ia64/include/asm/pgtable.h
+++ b/arch/ia64/include/asm/pgtable.h
@@ -273,6 +273,7 @@ extern unsigned long VMALLOC_END;
 #define pmd_clear(pmdp)			(pmd_val(*(pmdp)) = 0UL)
 #define pmd_page_vaddr(pmd)		((unsigned long) __va(pmd_val(pmd) & _PFN_MASK))
 #define pmd_page(pmd)			virt_to_page((pmd_val(pmd) + PAGE_OFFSET))
+#define pmd_pfn(pmd)			(pmd_val(pmd) >> PAGE_SHIFT)
 
 #define pud_none(pud)			(!pud_val(pud))
 #define pud_bad(pud)			(!ia64_phys_addr_valid(pud_val(pud)))
diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtable.h
index 84d1346e1cda..d29dc7b4924b 100644
--- a/arch/x86/include/asm/pgtable.h
+++ b/arch/x86/include/asm/pgtable.h
@@ -461,7 +461,7 @@ static inline int pte_present(pte_t a)
 #define pte_devmap pte_devmap
 static inline int pte_devmap(pte_t a)
 {
-	return pte_flags(a) & _PAGE_DEVMAP;
+	return (pte_flags(a) & _PAGE_DEVMAP) == _PAGE_DEVMAP;
 }
 
 #define pte_accessible pte_accessible
diff --git a/arch/x86/mm/gup.c b/arch/x86/mm/gup.c
index 81bf3d2af3eb..7254ba4f791d 100644
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
@@ -127,9 +173,13 @@ static noinline int gup_huge_pmd(pmd_t pmd, unsigned long addr,
 		mask |= _PAGE_RW;
 	if ((pte_flags(pte) & mask) != mask)
 		return 0;
+
+	VM_BUG_ON(!pfn_valid(pmd_pfn(pmd)));
+	if (pmd_devmap(pmd))
+		return __gup_device_huge_pmd(pmd, addr, end, pages, nr);
+
 	/* hugepages are never "special" */
 	VM_BUG_ON(pte_flags(pte) & _PAGE_SPECIAL);
-	VM_BUG_ON(!pfn_valid(pte_pfn(pte)));
 
 	refs = 0;
 	head = pte_page(pte);
diff --git a/include/linux/mm.h b/include/linux/mm.h
index af7597410cb9..a8400652ccbf 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -522,19 +522,6 @@ static inline void get_huge_page_tail(struct page *page)
 
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
@@ -800,12 +787,22 @@ struct dev_pagemap {
 };
 
 #ifdef CONFIG_ZONE_DEVICE
+static inline bool is_zone_device_page(const struct page *page)
+{
+	return page_zonenum(page) == ZONE_DEVICE;
+}
+
 struct dev_pagemap *__get_dev_pagemap(resource_size_t phys);
 void devm_memunmap_pages(struct device *dev, void *addr);
 void *devm_memremap_pages(struct device *dev, struct resource *res,
 		struct percpu_ref *ref, struct vmem_altmap *altmap);
 struct vmem_altmap *to_vmem_altmap(unsigned long memmap_start);
 #else
+static inline bool is_zone_device_page(const struct page *page)
+{
+	return false;
+}
+
 static inline struct dev_pagemap *__get_dev_pagemap(resource_size_t phys)
 {
 	return NULL;
@@ -864,6 +861,23 @@ static inline void put_dev_pagemap(struct dev_pagemap *pgmap)
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
index a798293fc648..1064e9a489a4 100644
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
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 9cc773483624..6bcc7cdee5a2 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -4229,7 +4229,23 @@ retry:
 	 */
 	if (!pmd_huge(*pmd))
 		goto out;
-	if (pmd_present(*pmd)) {
+	if (pmd_present(*pmd) && pmd_devmap(*pmd)) {
+		unsigned long pfn = pmd_pfn(*pmd);
+		struct dev_pagemap *pgmap;
+
+		/*
+		 * device mapped pages can only be returned if the
+		 * caller will manage the page reference count.
+		 */
+		if (!(flags & FOLL_GET))
+			goto out;
+		pgmap = get_dev_pagemap(pfn, NULL);
+		if (!pgmap)
+			goto out;
+		page = pfn_to_page(pfn);
+		get_page(page);
+		put_dev_pagemap(pgmap);
+	} else if (pmd_present(*pmd)) {
 		page = pmd_page(*pmd) + ((address & ~PMD_MASK) >> PAGE_SHIFT);
 		if (flags & FOLL_GET)
 			get_page(page);
diff --git a/mm/swap.c b/mm/swap.c
index 983f692a47fd..05a8a51c648e 100644
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
