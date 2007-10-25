Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate7.de.ibm.com (8.13.8/8.13.8) with ESMTP id l9PIJ1RY212274
	for <linux-mm@kvack.org>; Thu, 25 Oct 2007 18:19:01 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l9PIJ1lK2277564
	for <linux-mm@kvack.org>; Thu, 25 Oct 2007 20:19:01 +0200
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l9PIJ1gj016590
	for <linux-mm@kvack.org>; Thu, 25 Oct 2007 20:19:01 +0200
Message-Id: <20071025181901.212545095@de.ibm.com>
References: <20071025181520.880272069@de.ibm.com>
Date: Thu, 25 Oct 2007 20:15:22 +0200
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: [patch 2/6] CONFIG_HIGHPTE vs. sub-page page tables.
Content-Disposition: inline; filename=002-mm-pgtable.diff
Sender: owner-linux-mm@kvack.org
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-s390@vger.kernel.org
Cc: borntraeger@de.ibm.com, benh@kernel.crashing.org, Martin Schwidefsky <schwidefsky@de.ibm.com>
List-ID: <linux-mm.kvack.org>

Background: I've implemented 1K/2K page tables for s390. These sub-page
page tables are required to properly support the s390 virtualization
instruction with KVM. The SIE instruction requires that the page tables
have 256 page table entries (pte) followed by 256 page status table
entries (pgste). The pgstes are only required if the process is using
the SIE instruction. The pgstes are updated by the hardware and by the
hypervisor for a number of reasons, one of them is dirty and reference
bit tracking. To avoid wasting memory the standard pte table allocation
should return 1K/2K (31/64 bit) and 2K/4K if the process is using SIE.

Problem: Page size on s390 is 4K, page table size is 1K or 2K. That
means the s390 version for pte_alloc_one cannot return a pointer to
a struct page. Trouble is that with the CONFIG_HIGHPTE feature on x86
pte_alloc_one cannot return a pointer to a pte either, since that would
require more than 32 bit for the return value of pte_alloc_one (and the
pte * would not be accessible since its not kmapped).

Solution: The only solution I found to this dilemma is a new typedef:
a pgtable_t. For s390 pgtable_t will be a (pte *) - to be introduced
with a later patch. For everybody else it will be a (struct page *).
The additional problem with the initialization of the ptl lock and the
NR_PAGETABLE accounting is solved with a constructor pgtable_page_ctor
and a destructor pgtable_page_dtor. The page table allocation and free
functions need to call these two whenever a page table page is allocated
or freed. pmd_populate will get a pgtable_t instead of a struct page
pointer. To get the pgtable_t back from a pmd entry that has been
installed with pmd_populate a new function pmd_pgtable is added. It
replaces the pmd_page call in free_pte_range and apply_to_pte_range.

Signed-off-by: Martin Schwidefsky <schwidefsky@de.ibm.com>
---

 arch/frv/mm/pgalloc.c               |    8 +++++---
 arch/powerpc/mm/pgtable_32.c        |   16 +++++++++-------
 arch/ppc/mm/pgtable.c               |    9 ++++++---
 arch/s390/mm/pgtable.c              |    2 ++
 arch/sparc/mm/srmmu.c               |   10 +++++++---
 arch/sparc/mm/sun4c.c               |   14 ++++++++++----
 arch/um/kernel/mem.c                |    4 +++-
 arch/x86/mm/pgtable_32.c            |    4 +++-
 include/asm-alpha/page.h            |    2 ++
 include/asm-alpha/pgalloc.h         |   22 ++++++++++++++--------
 include/asm-arm/page.h              |    2 ++
 include/asm-arm/pgalloc.h           |    9 ++++++---
 include/asm-avr32/page.h            |    1 +
 include/asm-avr32/pgalloc.h         |   16 ++++++++++++----
 include/asm-cris/page.h             |    1 +
 include/asm-cris/pgalloc.h          |   14 ++++++++++----
 include/asm-frv/page.h              |    1 +
 include/asm-frv/pgalloc.h           |   12 +++++++++---
 include/asm-ia64/page.h             |    2 ++
 include/asm-ia64/pgalloc.h          |   20 ++++++++++++++------
 include/asm-m32r/page.h             |    1 +
 include/asm-m32r/pgalloc.h          |   10 ++++++----
 include/asm-m68k/motorola_pgalloc.h |   14 ++++++++------
 include/asm-m68k/page.h             |    1 +
 include/asm-m68k/sun3_pgalloc.h     |   17 ++++++++++++-----
 include/asm-mips/page.h             |    1 +
 include/asm-mips/pgalloc.h          |    5 +++--
 include/asm-parisc/page.h           |    1 +
 include/asm-parisc/pgalloc.h        |   11 +++++++++--
 include/asm-powerpc/page.h          |    2 ++
 include/asm-powerpc/pgalloc-32.h    |    6 ++++--
 include/asm-powerpc/pgalloc-64.h    |   26 +++++++++++++++++++-------
 include/asm-ppc/pgalloc.h           |    6 ++++--
 include/asm-s390/page.h             |    2 ++
 include/asm-s390/pgalloc.h          |    3 ++-
 include/asm-s390/tlb.h              |    2 +-
 include/asm-sh/page.h               |    2 ++
 include/asm-sh/pgalloc.h            |   27 ++++++++++++++++++++-------
 include/asm-sh64/page.h             |    2 ++
 include/asm-sh64/pgalloc.h          |   27 ++++++++++++++++++++-------
 include/asm-sparc/page.h            |    2 ++
 include/asm-sparc/pgalloc.h         |    5 +++--
 include/asm-sparc64/page.h          |    2 ++
 include/asm-sparc64/pgalloc.h       |   19 ++++++++++++++-----
 include/asm-um/page.h               |    2 ++
 include/asm-um/pgalloc.h            |   12 +++++++++---
 include/asm-x86/page_32.h           |    2 ++
 include/asm-x86/page_64.h           |    2 ++
 include/asm-x86/pgalloc_32.h        |    7 +++++--
 include/asm-x86/pgalloc_64.h        |   22 +++++++++++++++++-----
 include/asm-xtensa/page.h           |    1 +
 include/asm-xtensa/pgalloc.h        |   17 ++++++++++++-----
 include/linux/mm.h                  |   14 +++++++++++++-
 mm/memory.c                         |   32 +++++++++++++++-----------------
 mm/vmalloc.c                        |    2 +-
 55 files changed, 339 insertions(+), 137 deletions(-)

Index: quilt-2.6/arch/frv/mm/pgalloc.c
===================================================================
--- quilt-2.6.orig/arch/frv/mm/pgalloc.c
+++ quilt-2.6/arch/frv/mm/pgalloc.c
@@ -28,7 +28,7 @@ pte_t *pte_alloc_one_kernel(struct mm_st
 	return pte;
 }
 
-struct page *pte_alloc_one(struct mm_struct *mm, unsigned long address)
+pgtable_t pte_alloc_one(struct mm_struct *mm, unsigned long address)
 {
 	struct page *page;
 
@@ -37,9 +37,11 @@ struct page *pte_alloc_one(struct mm_str
 #else
 	page = alloc_pages(GFP_KERNEL|__GFP_REPEAT, 0);
 #endif
-	if (page)
+	if (page) {
 		clear_highpage(page);
-	flush_dcache_page(page);
+		pgtable_page_ctor(page);
+		flush_dcache_page(page);
+	}
 	return page;
 }
 
Index: quilt-2.6/arch/powerpc/mm/pgtable_32.c
===================================================================
--- quilt-2.6.orig/arch/powerpc/mm/pgtable_32.c
+++ quilt-2.6/arch/powerpc/mm/pgtable_32.c
@@ -107,20 +107,21 @@ __init_refok pte_t *pte_alloc_one_kernel
 	return pte;
 }
 
-struct page *pte_alloc_one(struct mm_struct *mm, unsigned long address)
+pgtable_t pte_alloc_one(struct mm_struct *mm, unsigned long address)
 {
 	struct page *ptepage;
 
 #ifdef CONFIG_HIGHPTE
-	gfp_t flags = GFP_KERNEL | __GFP_HIGHMEM | __GFP_REPEAT;
+	gfp_t flags = GFP_KERNEL | __GFP_HIGHMEM | __GFP_REPEAT | __GFP_ZERO;
 #else
-	gfp_t flags = GFP_KERNEL | __GFP_REPEAT;
+	gfp_t flags = GFP_KERNEL | __GFP_REPEAT | __GFP_ZERO;
 #endif
 
 	ptepage = alloc_pages(flags, 0);
-	if (ptepage)
-		clear_highpage(ptepage);
-	return ptepage;
+	if (!ptepage)
+		return NULL;
+	pgtable_page_ctor(ptepage);
+	return page_address(ptepage);
 }
 
 void pte_free_kernel(struct mm_struct *mm, pte_t *pte)
@@ -131,11 +132,12 @@ void pte_free_kernel(struct mm_struct *m
 	free_page((unsigned long)pte);
 }
 
-void pte_free(struct mm_struct *mm, struct page *ptepage)
+void pte_free(struct mm_struct *mm, pgtable_t ptepage)
 {
 #ifdef CONFIG_SMP
 	hash_page_sync();
 #endif
+	pgtable_page_dtor(ptepage);
 	__free_page(ptepage);
 }
 
Index: quilt-2.6/arch/ppc/mm/pgtable.c
===================================================================
--- quilt-2.6.orig/arch/ppc/mm/pgtable.c
+++ quilt-2.6/arch/ppc/mm/pgtable.c
@@ -108,7 +108,7 @@ __init_refok pte_t *pte_alloc_one_kernel
 	return pte;
 }
 
-struct page *pte_alloc_one(struct mm_struct *mm, unsigned long address)
+pgtable_t pte_alloc_one(struct mm_struct *mm, unsigned long address)
 {
 	struct page *ptepage;
 
@@ -119,8 +119,10 @@ struct page *pte_alloc_one(struct mm_str
 #endif
 
 	ptepage = alloc_pages(flags, 0);
-	if (ptepage)
+	if (ptepage) {
 		clear_highpage(ptepage);
+		pgtable_page_ctor(ptepage);
+	}
 	return ptepage;
 }
 
@@ -132,11 +134,12 @@ void pte_free_kernel(struct mm_struct *m
 	free_page((unsigned long)pte);
 }
 
-void pte_free(struct mm_struct *mm, struct page *ptepage)
+void pte_free(struct mm_struct *mm, pgtable_t ptepage)
 {
 #ifdef CONFIG_SMP
 	hash_page_sync();
 #endif
+	pgtable_page_dtor(ptepage);
 	__free_page(ptepage);
 }
 
Index: quilt-2.6/arch/s390/mm/pgtable.c
===================================================================
--- quilt-2.6.orig/arch/s390/mm/pgtable.c
+++ quilt-2.6/arch/s390/mm/pgtable.c
@@ -78,6 +78,7 @@ unsigned long *page_table_alloc(int noex
 		clear_table(table, _PAGE_TYPE_EMPTY, PAGE_SIZE);
 		page->index = (addr_t) table;
 	}
+	pgtable_page_ctor(page);
 	table = (unsigned long *) page_to_phys(page);
 	clear_table(table, _PAGE_TYPE_EMPTY, PAGE_SIZE);
 	return table;
@@ -87,6 +88,7 @@ void page_table_free(unsigned long *tabl
 {
 	unsigned long *shadow = get_shadow_pte(table);
 
+	pgtable_page_dtor(virt_to_page(table));
 	if (shadow)
 		free_page((unsigned long) shadow);
 	free_page((unsigned long) table);
Index: quilt-2.6/arch/sparc/mm/srmmu.c
===================================================================
--- quilt-2.6.orig/arch/sparc/mm/srmmu.c
+++ quilt-2.6/arch/sparc/mm/srmmu.c
@@ -490,14 +490,17 @@ srmmu_pte_alloc_one_kernel(struct mm_str
 	return (pte_t *)srmmu_get_nocache(PTE_SIZE, PTE_SIZE);
 }
 
-static struct page *
+static pgtable_t
 srmmu_pte_alloc_one(struct mm_struct *mm, unsigned long address)
 {
 	unsigned long pte;
+	struct page *page;
 
 	if ((pte = (unsigned long)srmmu_pte_alloc_one_kernel(mm, address)) == 0)
 		return NULL;
-	return pfn_to_page( __nocache_pa(pte) >> PAGE_SHIFT );
+	page = pfn_to_page( __nocache_pa(pte) >> PAGE_SHIFT );
+	pgtable_page_ctor(page);
+	return page;
 }
 
 static void srmmu_free_pte_fast(pte_t *pte)
@@ -505,10 +508,11 @@ static void srmmu_free_pte_fast(pte_t *p
 	srmmu_free_nocache((unsigned long)pte, PTE_SIZE);
 }
 
-static void srmmu_pte_free(struct page *pte)
+static void srmmu_pte_free(pgtable_t pte)
 {
 	unsigned long p;
 
+	pgtable_page_dtor(pte);
 	p = (unsigned long)page_address(pte);	/* Cached address (for test) */
 	if (p == 0)
 		BUG();
Index: quilt-2.6/arch/sparc/mm/sun4c.c
===================================================================
--- quilt-2.6.orig/arch/sparc/mm/sun4c.c
+++ quilt-2.6/arch/sparc/mm/sun4c.c
@@ -1948,12 +1948,17 @@ static pte_t *sun4c_pte_alloc_one_kernel
 	return pte;
 }
 
-static struct page *sun4c_pte_alloc_one(struct mm_struct *mm, unsigned long address)
+static pgtable_t sun4c_pte_alloc_one(struct mm_struct *mm, unsigned long address)
 {
-	pte_t *pte = sun4c_pte_alloc_one_kernel(mm, address);
+	pte_t *pte;
+	struct page *page;
+
+	pte = sun4c_pte_alloc_one_kernel(mm, address);
 	if (pte == NULL)
 		return NULL;
-	return virt_to_page(pte);
+	page = virt_to_page(pte);
+	pgtable_page_ctor(page);
+	return page;
 }
 
 static __inline__ void sun4c_free_pte_fast(pte_t *pte)
@@ -1963,8 +1968,9 @@ static __inline__ void sun4c_free_pte_fa
 	pgtable_cache_size++;
 }
 
-static void sun4c_pte_free(struct page *pte)
+static void sun4c_pte_free(pgtable_t pte)
 {
+	pgtable_page_dtor(pte);
 	sun4c_free_pte_fast(page_address(pte));
 }
 
Index: quilt-2.6/arch/um/kernel/mem.c
===================================================================
--- quilt-2.6.orig/arch/um/kernel/mem.c
+++ quilt-2.6/arch/um/kernel/mem.c
@@ -361,10 +361,12 @@ pte_t *pte_alloc_one_kernel(struct mm_st
 	return pte;
 }
 
-struct page *pte_alloc_one(struct mm_struct *mm, unsigned long address)
+pgtable_t pte_alloc_one(struct mm_struct *mm, unsigned long address)
 {
 	struct page *pte;
 
 	pte = alloc_page(GFP_KERNEL|__GFP_REPEAT|__GFP_ZERO);
+	if (pte)
+		pgtable_page_ctor(pte);
 	return pte;
 }
Index: quilt-2.6/arch/x86/mm/pgtable_32.c
===================================================================
--- quilt-2.6.orig/arch/x86/mm/pgtable_32.c
+++ quilt-2.6/arch/x86/mm/pgtable_32.c
@@ -183,7 +183,7 @@ pte_t *pte_alloc_one_kernel(struct mm_st
 	return (pte_t *)__get_free_page(GFP_KERNEL|__GFP_REPEAT|__GFP_ZERO);
 }
 
-struct page *pte_alloc_one(struct mm_struct *mm, unsigned long address)
+pgtable_t pte_alloc_one(struct mm_struct *mm, unsigned long address)
 {
 	struct page *pte;
 
@@ -192,6 +192,8 @@ struct page *pte_alloc_one(struct mm_str
 #else
 	pte = alloc_pages(GFP_KERNEL|__GFP_REPEAT|__GFP_ZERO, 0);
 #endif
+	if (pte)
+		pgtable_page_ctor(pte);
 	return pte;
 }
 
Index: quilt-2.6/include/asm-alpha/page.h
===================================================================
--- quilt-2.6.orig/include/asm-alpha/page.h
+++ quilt-2.6/include/asm-alpha/page.h
@@ -64,6 +64,8 @@ typedef unsigned long pgprot_t;
 
 #endif /* STRICT_MM_TYPECHECKS */
 
+typedef struct page *pgtable_t;
+
 #ifdef USE_48_BIT_KSEG
 #define PAGE_OFFSET		0xffff800000000000UL
 #else
Index: quilt-2.6/include/asm-alpha/pgalloc.h
===================================================================
--- quilt-2.6.orig/include/asm-alpha/pgalloc.h
+++ quilt-2.6/include/asm-alpha/pgalloc.h
@@ -11,10 +11,11 @@
  */
 
 static inline void
-pmd_populate(struct mm_struct *mm, pmd_t *pmd, struct page *pte)
+pmd_populate(struct mm_struct *mm, pmd_t *pmd, pgtable_t pte)
 {
 	pmd_set(pmd, (pte_t *)(page_to_pa(pte) + PAGE_OFFSET));
 }
+#define pmd_pgtable(pmd) pmd_page(pmd)
 
 static inline void
 pmd_populate_kernel(struct mm_struct *mm, pmd_t *pmd, pte_t *pte)
@@ -57,18 +58,23 @@ pte_free_kernel(struct mm_struct *mm, pt
 	free_page((unsigned long)pte);
 }
 
-static inline struct page *
-pte_alloc_one(struct mm_struct *mm, unsigned long addr)
+static inline pgtable_t
+pte_alloc_one(struct mm_struct *mm, unsigned long address)
 {
-	pte_t *pte = pte_alloc_one_kernel(mm, addr);
-	if (pte)
-		return virt_to_page(pte);
-	return NULL;
+	pte_t *pte = pte_alloc_one_kernel(mm, address);
+	struct page *page;
+
+	if (!pte)
+		return NULL;
+	page = virt_to_page(pte);
+	pgtable_page_ctor(page);
+	return page;
 }
 
 static inline void
-pte_free(struct mm_struct *mm, struct page *page)
+pte_free(struct mm_struct *mm, pgtable_t page)
 {
+	pgtable_page_dtor(page);
 	__free_page(page);
 }
 
Index: quilt-2.6/include/asm-arm/page.h
===================================================================
--- quilt-2.6.orig/include/asm-arm/page.h
+++ quilt-2.6/include/asm-arm/page.h
@@ -174,6 +174,8 @@ typedef unsigned long pgprot_t;
 
 #endif /* STRICT_MM_TYPECHECKS */
 
+typedef struct page *pgtable_t;
+
 #endif /* CONFIG_MMU */
 
 #include <asm/memory.h>
Index: quilt-2.6/include/asm-arm/pgalloc.h
===================================================================
--- quilt-2.6.orig/include/asm-arm/pgalloc.h
+++ quilt-2.6/include/asm-arm/pgalloc.h
@@ -66,7 +66,7 @@ pte_alloc_one_kernel(struct mm_struct *m
 	return pte;
 }
 
-static inline struct page *
+static inline pgtable_t
 pte_alloc_one(struct mm_struct *mm, unsigned long addr)
 {
 	struct page *pte;
@@ -75,6 +75,7 @@ pte_alloc_one(struct mm_struct *mm, unsi
 	if (pte) {
 		void *page = page_address(pte);
 		clean_dcache_area(page, sizeof(pte_t) * PTRS_PER_PTE);
+		pgtable_page_ctor(pte);
 	}
 
 	return pte;
@@ -91,8 +92,9 @@ static inline void pte_free_kernel(struc
 	}
 }
 
-static inline void pte_free(struct mm_struct *mm, struct page *pte)
+static inline void pte_free(struct mm_struct *mm, pgtable_t pte)
 {
+	pgtable_page_dtor(pte);
 	__free_page(pte);
 }
 
@@ -123,10 +125,11 @@ pmd_populate_kernel(struct mm_struct *mm
 }
 
 static inline void
-pmd_populate(struct mm_struct *mm, pmd_t *pmdp, struct page *ptep)
+pmd_populate(struct mm_struct *mm, pmd_t *pmdp, pgtable_t ptep)
 {
 	__pmd_populate(pmdp, page_to_pfn(ptep) << PAGE_SHIFT | _PAGE_USER_TABLE);
 }
+#define pmd_pgtable(pmd) pmd_page(pmd)
 
 #endif /* CONFIG_MMU */
 
Index: quilt-2.6/include/asm-avr32/page.h
===================================================================
--- quilt-2.6.orig/include/asm-avr32/page.h
+++ quilt-2.6/include/asm-avr32/page.h
@@ -36,6 +36,7 @@ extern void copy_page(void *to, void *fr
 typedef struct { unsigned long pte; } pte_t;
 typedef struct { unsigned long pgd; } pgd_t;
 typedef struct { unsigned long pgprot; } pgprot_t;
+typedef struct page *pgtable_t;
 
 #define pte_val(x)		((x).pte)
 #define pgd_val(x)		((x).pgd)
Index: quilt-2.6/include/asm-avr32/pgalloc.h
===================================================================
--- quilt-2.6.orig/include/asm-avr32/pgalloc.h
+++ quilt-2.6/include/asm-avr32/pgalloc.h
@@ -17,10 +17,11 @@
 	set_pmd(pmd, __pmd(_PAGE_TABLE + __pa(pte)))
 
 static __inline__ void pmd_populate(struct mm_struct *mm, pmd_t *pmd,
-				    struct page *pte)
+				    pgtable_t pte)
 {
 	set_pmd(pmd, __pmd(_PAGE_TABLE + page_to_phys(pte)));
 }
+#define pmd_pgtable(pmd) pmd_page(pmd)
 
 /*
  * Allocate and free page tables
@@ -51,7 +52,9 @@ static inline struct page *pte_alloc_one
 	struct page *pte;
 
 	pte = alloc_page(GFP_KERNEL | __GFP_REPEAT | __GFP_ZERO);
-
+	if (!page)
+		return NULL;
+	pgtable_page_ctor(page);
 	return pte;
 }
 
@@ -60,12 +63,17 @@ static inline void pte_free_kernel(struc
 	free_page((unsigned long)pte);
 }
 
-static inline void pte_free(struct mm_struct *mm, struct page *pte)
+static inline void pte_free(struct mm_struct *mm, pgtable_t pte)
 {
+	pgtable_page_dtor(pte);
 	__free_page(pte);
 }
 
-#define __pte_free_tlb(tlb,pte) tlb_remove_page((tlb),(pte))
+#define __pte_free_tlb(tlb,pte)				\
+do {							\
+	pgtable_page_dtor(pte);				\
+	tlb_remove_page((tlb), pte);			\
+} while (0)
 
 #define check_pgt_cache() do { } while(0)
 
Index: quilt-2.6/include/asm-cris/page.h
===================================================================
--- quilt-2.6.orig/include/asm-cris/page.h
+++ quilt-2.6/include/asm-cris/page.h
@@ -31,6 +31,7 @@
 typedef struct { unsigned long pte; } pte_t;
 typedef struct { unsigned long pgd; } pgd_t;
 typedef struct { unsigned long pgprot; } pgprot_t;
+typedef struct page *pgtable_t;
 #endif
 
 #define pte_val(x)	((x).pte)
Index: quilt-2.6/include/asm-cris/pgalloc.h
===================================================================
--- quilt-2.6.orig/include/asm-cris/pgalloc.h
+++ quilt-2.6/include/asm-cris/pgalloc.h
@@ -6,6 +6,7 @@
 
 #define pmd_populate_kernel(mm, pmd, pte) pmd_set(pmd, pte)
 #define pmd_populate(mm, pmd, pte) pmd_set(pmd, page_address(pte))
+#define pmd_pgtable(pmd) pmd_page(pmd)
 
 /*
  * Allocate and free page tables.
@@ -27,10 +28,11 @@ static inline pte_t *pte_alloc_one_kerne
  	return pte;
 }
 
-static inline struct page *pte_alloc_one(struct mm_struct *mm, unsigned long address)
+static inline pgtable_t pte_alloc_one(struct mm_struct *mm, unsigned long address)
 {
 	struct page *pte;
 	pte = alloc_pages(GFP_KERNEL|__GFP_REPEAT|__GFP_ZERO, 0);
+	pgtable_page_ctor(pte);
 	return pte;
 }
 
@@ -39,13 +41,17 @@ static inline void pte_free_kernel(struc
 	free_page((unsigned long)pte);
 }
 
-static inline void pte_free(struct mm_struct *mm, struct page *pte)
+static inline void pte_free(struct mm_struct *mm, pgtable_t pte)
 {
+	pgtable_page_dtor(pte);
 	__free_page(pte);
 }
 
-
-#define __pte_free_tlb(tlb,pte) tlb_remove_page((tlb),(pte))
+#define __pte_free_tlb(tlb,pte)				\
+do {							\
+	pgtable_page_dtor(pte);				\
+	tlb_remove_page((tlb), pte);			\
+} while (0)
 
 #define check_pgt_cache()          do { } while (0)
 
Index: quilt-2.6/include/asm-frv/page.h
===================================================================
--- quilt-2.6.orig/include/asm-frv/page.h
+++ quilt-2.6/include/asm-frv/page.h
@@ -27,6 +27,7 @@ typedef struct { unsigned long	ste[64];}
 typedef struct { pmd_t		pue[1]; } pud_t;
 typedef struct { pud_t		pge[1];	} pgd_t;
 typedef struct { unsigned long	pgprot;	} pgprot_t;
+typedef struct page *pgtable_t;
 
 #define pte_val(x)	((x).pte)
 #define pmd_val(x)	((x).ste[0])
Index: quilt-2.6/include/asm-frv/pgalloc.h
===================================================================
--- quilt-2.6.orig/include/asm-frv/pgalloc.h
+++ quilt-2.6/include/asm-frv/pgalloc.h
@@ -25,6 +25,7 @@
 do {										\
 	__set_pmd((PMD), page_to_pfn(PAGE) << PAGE_SHIFT | _PAGE_TABLE);	\
 } while(0)
+#define pmd_pgtable(pmd) pmd_page(pmd)
 
 /*
  * Allocate and free page tables.
@@ -35,19 +36,24 @@ extern void pgd_free(struct mm_struct *m
 
 extern pte_t *pte_alloc_one_kernel(struct mm_struct *, unsigned long);
 
-extern struct page *pte_alloc_one(struct mm_struct *, unsigned long);
+extern pgtable_t pte_alloc_one(struct mm_struct *, unsigned long);
 
 static inline void pte_free_kernel(struct mm_struct *mm, pte_t *pte)
 {
 	free_page((unsigned long)pte);
 }
 
-static inline void pte_free(struct mm_struct *mm, struct page *pte)
+static inline void pte_free(struct mm_struct *mm, pgtable_t pte)
 {
+	pgtable_page_dtor(pte);
 	__free_page(pte);
 }
 
-#define __pte_free_tlb(tlb,pte)		tlb_remove_page((tlb),(pte))
+#define __pte_free_tlb(tlb,pte)				\
+do {							\
+	pgtable_page_dtor(pte);				\
+	tlb_remove_page((tlb),(pte));			\
+} while (0)
 
 /*
  * allocating and freeing a pmd is trivial: the 1-entry pmd is
Index: quilt-2.6/include/asm-ia64/page.h
===================================================================
--- quilt-2.6.orig/include/asm-ia64/page.h
+++ quilt-2.6/include/asm-ia64/page.h
@@ -187,6 +187,7 @@ get_order (unsigned long size)
 #endif
   typedef struct { unsigned long pgd; } pgd_t;
   typedef struct { unsigned long pgprot; } pgprot_t;
+  typedef struct page *pgtable_t;
 
 # define pte_val(x)	((x).pte)
 # define pmd_val(x)	((x).pmd)
@@ -208,6 +209,7 @@ get_order (unsigned long size)
     typedef unsigned long pmd_t;
     typedef unsigned long pgd_t;
     typedef unsigned long pgprot_t;
+    typedef struct page *pgtable_t;
 # endif
 
 # define pte_val(x)	(x)
Index: quilt-2.6/include/asm-ia64/pgalloc.h
===================================================================
--- quilt-2.6.orig/include/asm-ia64/pgalloc.h
+++ quilt-2.6/include/asm-ia64/pgalloc.h
@@ -70,10 +70,11 @@ static inline void pmd_free(struct mm_st
 #define __pmd_free_tlb(tlb, pmd)	pmd_free((tlb)->mm, pmd)
 
 static inline void
-pmd_populate(struct mm_struct *mm, pmd_t * pmd_entry, struct page *pte)
+pmd_populate(struct mm_struct *mm, pmd_t * pmd_entry, pgtable_t pte)
 {
 	pmd_val(*pmd_entry) = page_to_phys(pte);
 }
+#define pmd_pgtable(pmd) pmd_page(pmd)
 
 static inline void
 pmd_populate_kernel(struct mm_struct *mm, pmd_t * pmd_entry, pte_t * pte)
@@ -81,11 +82,17 @@ pmd_populate_kernel(struct mm_struct *mm
 	pmd_val(*pmd_entry) = __pa(pte);
 }
 
-static inline struct page *pte_alloc_one(struct mm_struct *mm,
-					 unsigned long addr)
+static inline pgtable_t pte_alloc_one(struct mm_struct *mm, unsigned long addr)
 {
-	void *pg = quicklist_alloc(0, GFP_KERNEL, NULL);
-	return pg ? virt_to_page(pg) : NULL;
+	struct page *page;
+	void *pg;
+
+	pg = quicklist_alloc(0, GFP_KERNEL, NULL);
+	if (!pg)
+		return NULL;
+	page = virt_to_page(pg);
+	pgtable_page_ctor(page);
+	return page;
 }
 
 static inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm,
@@ -94,8 +101,9 @@ static inline pte_t *pte_alloc_one_kerne
 	return quicklist_alloc(0, GFP_KERNEL, NULL);
 }
 
-static inline void pte_free(struct mm_struct *mm, struct page *pte)
+static inline void pte_free(struct mm_struct *mm, pgtable_t pte)
 {
+	pgtable_page_dtor(pte);
 	quicklist_free_page(0, NULL, pte);
 }
 
Index: quilt-2.6/include/asm-m32r/page.h
===================================================================
--- quilt-2.6.orig/include/asm-m32r/page.h
+++ quilt-2.6/include/asm-m32r/page.h
@@ -29,6 +29,7 @@ typedef struct { unsigned long pgd; } pg
 #define PTE_MASK	PAGE_MASK
 
 typedef struct { unsigned long pgprot; } pgprot_t;
+typedef struct page *pgtable_t;
 
 #define pmd_val(x)	((x).pmd)
 #define pgd_val(x)	((x).pgd)
Index: quilt-2.6/include/asm-m32r/pgalloc.h
===================================================================
--- quilt-2.6.orig/include/asm-m32r/pgalloc.h
+++ quilt-2.6/include/asm-m32r/pgalloc.h
@@ -9,10 +9,11 @@
 	set_pmd(pmd, __pmd(_PAGE_TABLE + __pa(pte)))
 
 static __inline__ void pmd_populate(struct mm_struct *mm, pmd_t *pmd,
-	struct page *pte)
+	pgtable_t pte)
 {
 	set_pmd(pmd, __pmd(_PAGE_TABLE + page_to_phys(pte)));
 }
+#define pmd_pgtable(pmd) pmd_page(pmd)
 
 /*
  * Allocate and free page tables.
@@ -37,12 +38,12 @@ static __inline__ pte_t *pte_alloc_one_k
 	return pte;
 }
 
-static __inline__ struct page *pte_alloc_one(struct mm_struct *mm,
+static __inline__ pgtable_t pte_alloc_one(struct mm_struct *mm,
 	unsigned long address)
 {
 	struct page *pte = alloc_page(GFP_KERNEL|__GFP_ZERO);
 
-
+	pgtable_page_ctor(pte);
 	return pte;
 }
 
@@ -51,8 +52,9 @@ static __inline__ void pte_free_kernel(s
 	free_page((unsigned long)pte);
 }
 
-static __inline__ void pte_free(struct mm_struct *mm, struct page *pte)
+static __inline__ void pte_free(struct mm_struct *mm, pgtable_t pte)
 {
+	pgtable_page_dtor(pte);
 	__free_page(pte);
 }
 
Index: quilt-2.6/include/asm-m68k/motorola_pgalloc.h
===================================================================
--- quilt-2.6.orig/include/asm-m68k/motorola_pgalloc.h
+++ quilt-2.6/include/asm-m68k/motorola_pgalloc.h
@@ -7,7 +7,6 @@
 extern pmd_t *get_pointer_table(void);
 extern int free_pointer_table(pmd_t *);
 
-
 static inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm, unsigned long address)
 {
 	pte_t *pte;
@@ -28,7 +27,7 @@ static inline void pte_free_kernel(struc
 	free_page((unsigned long) pte);
 }
 
-static inline struct page *pte_alloc_one(struct mm_struct *mm, unsigned long address)
+static inline pgtable_t pte_alloc_one(struct mm_struct *mm, unsigned long address)
 {
 	struct page *page = alloc_pages(GFP_KERNEL|__GFP_REPEAT|__GFP_ZERO, 0);
 	pte_t *pte;
@@ -43,19 +42,21 @@ static inline struct page *pte_alloc_one
 		nocache_page(pte);
 	}
 	kunmap(pte);
-
+	pgtable_page_ctor(page);
 	return page;
 }
 
-static inline void pte_free(struct mm_struct *mm, struct page *page)
+static inline void pte_free(struct mm_struct *mm, pgtable_t page)
 {
+	pgtable_page_dtor(page);
 	cache_page(kmap(page));
 	kunmap(page);
 	__free_page(page);
 }
 
-static inline void __pte_free_tlb(struct mmu_gather *tlb, struct page *page)
+static inline void __pte_free_tlb(struct mmu_gather *tlb, pgtable_t page)
 {
+	pgtable_page_dtor(page);
 	cache_page(kmap(page));
 	kunmap(page);
 	__free_page(page);
@@ -94,10 +95,11 @@ static inline void pmd_populate_kernel(s
 	pmd_set(pmd, pte);
 }
 
-static inline void pmd_populate(struct mm_struct *mm, pmd_t *pmd, struct page *page)
+static inline void pmd_populate(struct mm_struct *mm, pmd_t *pmd, pgtable_t page)
 {
 	pmd_set(pmd, page_address(page));
 }
+#define pmd_pgtable(pmd) pmd_page(pmd)
 
 static inline void pgd_populate(struct mm_struct *mm, pgd_t *pgd, pmd_t *pmd)
 {
Index: quilt-2.6/include/asm-m68k/page.h
===================================================================
--- quilt-2.6.orig/include/asm-m68k/page.h
+++ quilt-2.6/include/asm-m68k/page.h
@@ -94,6 +94,7 @@ typedef struct { unsigned long pte; } pt
 typedef struct { unsigned long pmd[16]; } pmd_t;
 typedef struct { unsigned long pgd; } pgd_t;
 typedef struct { unsigned long pgprot; } pgprot_t;
+typedef struct page *pgtable_t;
 
 #define pte_val(x)	((x).pte)
 #define pmd_val(x)	((&x)->pmd[0])
Index: quilt-2.6/include/asm-m68k/sun3_pgalloc.h
===================================================================
--- quilt-2.6.orig/include/asm-m68k/sun3_pgalloc.h
+++ quilt-2.6/include/asm-m68k/sun3_pgalloc.h
@@ -26,12 +26,17 @@ static inline void pte_free_kernel(struc
         free_page((unsigned long) pte);
 }
 
-static inline void pte_free(struct mm_struct *mm, struct page *page)
+static inline void pte_free(struct mm_struct *mm, pgtable_t page)
 {
+	pgtable_page_dtor(page);
         __free_page(page);
 }
 
-#define __pte_free_tlb(tlb,pte) tlb_remove_page((tlb),(pte))
+#define __pte_free_tlb(tlb,pte)				\
+do {							\
+	pgtable_page_dtor(pte);				\
+	tlb_remove_page((tlb), pte);			\
+} while (0)
 
 static inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm,
 					  unsigned long address)
@@ -45,8 +50,8 @@ static inline pte_t *pte_alloc_one_kerne
 	return (pte_t *) (page);
 }
 
-static inline struct page *pte_alloc_one(struct mm_struct *mm,
-					 unsigned long address)
+static inline pgtable_t pte_alloc_one(struct mm_struct *mm,
+					unsigned long address)
 {
         struct page *page = alloc_pages(GFP_KERNEL|__GFP_REPEAT, 0);
 
@@ -54,6 +59,7 @@ static inline struct page *pte_alloc_one
 		return NULL;
 
 	clear_highpage(page);
+	pgtable_page_ctor(page);
 	return page;
 
 }
@@ -63,10 +69,11 @@ static inline void pmd_populate_kernel(s
 	pmd_val(*pmd) = __pa((unsigned long)pte);
 }
 
-static inline void pmd_populate(struct mm_struct *mm, pmd_t *pmd, struct page *page)
+static inline void pmd_populate(struct mm_struct *mm, pmd_t *pmd, pgtable_t page)
 {
 	pmd_val(*pmd) = __pa((unsigned long)page_address(page));
 }
+#define pmd_pgtable(pmd) pmd_page(pmd)
 
 /*
  * allocating and freeing a pmd is trivial: the 1-entry pmd is
Index: quilt-2.6/include/asm-mips/page.h
===================================================================
--- quilt-2.6.orig/include/asm-mips/page.h
+++ quilt-2.6/include/asm-mips/page.h
@@ -93,6 +93,7 @@ typedef struct { unsigned long pte; } pt
 #define pte_val(x)	((x).pte)
 #define __pte(x)	((pte_t) { (x) } )
 #endif
+typedef struct page *pgtable_t;
 
 /*
  * For 3-level pagetables we defines these ourselves, for 2-level the
Index: quilt-2.6/include/asm-mips/pgalloc.h
===================================================================
--- quilt-2.6.orig/include/asm-mips/pgalloc.h
+++ quilt-2.6/include/asm-mips/pgalloc.h
@@ -20,10 +20,11 @@ static inline void pmd_populate_kernel(s
 }
 
 static inline void pmd_populate(struct mm_struct *mm, pmd_t *pmd,
-	struct page *pte)
+	pgtable_t pte)
 {
 	set_pmd(pmd, __pmd((unsigned long)page_address(pte)));
 }
+#define pmd_pgtable(pmd) pmd_page(pmd)
 
 /*
  * Initialize a new pmd table with invalid pointers.
@@ -90,7 +91,7 @@ static inline void pte_free_kernel(struc
 	free_pages((unsigned long)pte, PTE_ORDER);
 }
 
-static inline void pte_free(struct mm_struct *mm, struct page *pte)
+static inline void pte_free(struct mm_struct *mm, pgtable_t pte)
 {
 	__free_pages(pte, PTE_ORDER);
 }
Index: quilt-2.6/include/asm-parisc/page.h
===================================================================
--- quilt-2.6.orig/include/asm-parisc/page.h
+++ quilt-2.6/include/asm-parisc/page.h
@@ -93,6 +93,7 @@ typedef unsigned long pgprot_t;
 
 #endif /* STRICT_MM_TYPECHECKS */
 
+typedef struct page *pgtable_t;
 
 typedef struct __physmem_range {
 	unsigned long start_pfn;
Index: quilt-2.6/include/asm-parisc/pgalloc.h
===================================================================
--- quilt-2.6.orig/include/asm-parisc/pgalloc.h
+++ quilt-2.6/include/asm-parisc/pgalloc.h
@@ -115,11 +115,14 @@ pmd_populate_kernel(struct mm_struct *mm
 
 #define pmd_populate(mm, pmd, pte_page) \
 	pmd_populate_kernel(mm, pmd, page_address(pte_page))
+#define pmd_pgtable(pmd) pmd_page(pmd)
 
-static inline struct page *
+static inline pgtable_t
 pte_alloc_one(struct mm_struct *mm, unsigned long address)
 {
 	struct page *page = alloc_page(GFP_KERNEL|__GFP_REPEAT|__GFP_ZERO);
+	if (page)
+		pgtable_page_ctor(page);
 	return page;
 }
 
@@ -135,7 +138,11 @@ static inline void pte_free_kernel(struc
 	free_page((unsigned long)pte);
 }
 
-#define pte_free(mm, page) pte_free_kernel(page_address(page))
+static inline void pte_free_kernel(struct mm_struct *mm, struct page *pte)
+{
+	pgtable_page_dtor(pte);
+	pte_free_kernel(page_address((pte));
+}
 
 #define check_pgt_cache()	do { } while (0)
 
Index: quilt-2.6/include/asm-powerpc/page.h
===================================================================
--- quilt-2.6.orig/include/asm-powerpc/page.h
+++ quilt-2.6/include/asm-powerpc/page.h
@@ -191,6 +191,8 @@ extern int page_is_ram(unsigned long pfn
 
 struct vm_area_struct;
 
+typedef struct page *pgtable_t;
+
 #include <asm-generic/memory_model.h>
 #endif /* __ASSEMBLY__ */
 
Index: quilt-2.6/include/asm-powerpc/pgalloc-32.h
===================================================================
--- quilt-2.6.orig/include/asm-powerpc/pgalloc-32.h
+++ quilt-2.6/include/asm-powerpc/pgalloc-32.h
@@ -22,17 +22,19 @@ extern void pgd_free(struct mm_struct *m
 		(pmd_val(*(pmd)) = __pa(pte) | _PMD_PRESENT)
 #define pmd_populate(mm, pmd, pte)	\
 		(pmd_val(*(pmd)) = (page_to_pfn(pte) << PAGE_SHIFT) | _PMD_PRESENT)
+#define pmd_pgtable(pmd) pmd_page(pmd)
 #else
 #define pmd_populate_kernel(mm, pmd, pte)	\
 		(pmd_val(*(pmd)) = (unsigned long)pte | _PMD_PRESENT)
 #define pmd_populate(mm, pmd, pte)	\
 		(pmd_val(*(pmd)) = (unsigned long)lowmem_page_address(pte) | _PMD_PRESENT)
+#define pmd_pgtable(pmd) pmd_page(pmd)
 #endif
 
 extern pte_t *pte_alloc_one_kernel(struct mm_struct *mm, unsigned long addr);
-extern struct page *pte_alloc_one(struct mm_struct *mm, unsigned long addr);
+extern pgtable_t pte_alloc_one(struct mm_struct *mm, unsigned long addr);
 extern void pte_free_kernel(struct mm_struct *mm, pte_t *pte);
-extern void pte_free(struct mm_struct *mm, struct page *pte);
+extern void pte_free(struct mm_struct *mm, pgtable_t pte);
 
 #define __pte_free_tlb(tlb, pte)	pte_free((tlb)->mm, (pte))
 
Index: quilt-2.6/include/asm-powerpc/pgalloc-64.h
===================================================================
--- quilt-2.6.orig/include/asm-powerpc/pgalloc-64.h
+++ quilt-2.6/include/asm-powerpc/pgalloc-64.h
@@ -53,6 +53,7 @@ static inline void pud_populate(struct m
 #define pmd_populate(mm, pmd, pte_page) \
 	pmd_populate_kernel(mm, pmd, page_address(pte_page))
 #define pmd_populate_kernel(mm, pmd, pte) pmd_set(pmd, (unsigned long)(pte))
+#define pmd_pgtable(pmd) pmd_page(pmd)
 
 
 #else /* CONFIG_PPC_64K_PAGES */
@@ -87,11 +88,18 @@ static inline pte_t *pte_alloc_one_kerne
         return (pte_t *)__get_free_page(GFP_KERNEL | __GFP_REPEAT | __GFP_ZERO);
 }
 
-static inline struct page *pte_alloc_one(struct mm_struct *mm,
-					 unsigned long address)
+static inline pgtable_t pte_alloc_one(struct mm_struct *mm,
+					unsigned long address)
 {
-	pte_t *pte = pte_alloc_one_kernel(mm, address);
-	return pte ? virt_to_page(pte) : NULL;
+	struct page *page;
+	pte_t *pte;
+
+	pte = pte_alloc_one_kernel(mm, address);
+	if (!pte)
+		return NULL;
+	page = virt_to_page(pte);
+	pgtable_page_ctor(page);
+	return page;
 }
 
 static inline void pte_free_kernel(struct mm_struct *mm, pte_t *pte)
@@ -99,8 +107,9 @@ static inline void pte_free_kernel(struc
 	free_page((unsigned long)pte);
 }
 
-static inline void pte_free(struct mm_struct *mm, struct page *ptepage)
+static inline void pte_free(struct mm_struct *mm, pgtable_t ptepage)
 {
+	pgtable_page_dtor(ptepage);
 	__free_page(ptepage);
 }
 
@@ -131,9 +140,12 @@ static inline void pgtable_free(pgtable_
 
 extern void pgtable_free_tlb(struct mmu_gather *tlb, pgtable_free_t pgf);
 
-#define __pte_free_tlb(tlb, ptepage)	\
+#define __pte_free_tlb(tlb,ptepage)	\
+do { \
+	pgtable_page_dtor(ptepage); \
 	pgtable_free_tlb(tlb, pgtable_free_cache(page_address(ptepage), \
-		PTE_NONCACHE_NUM, PTE_TABLE_SIZE-1))
+		PTE_NONCACHE_NUM, PTE_TABLE_SIZE-1)); \
+} while (0)
 #define __pmd_free_tlb(tlb, pmd) 	\
 	pgtable_free_tlb(tlb, pgtable_free_cache(pmd, \
 		PMD_CACHE_NUM, PMD_TABLE_SIZE-1))
Index: quilt-2.6/include/asm-ppc/pgalloc.h
===================================================================
--- quilt-2.6.orig/include/asm-ppc/pgalloc.h
+++ quilt-2.6/include/asm-ppc/pgalloc.h
@@ -23,17 +23,19 @@ extern void pgd_free(struct mm_struct *m
 		(pmd_val(*(pmd)) = __pa(pte) | _PMD_PRESENT)
 #define pmd_populate(mm, pmd, pte)	\
 		(pmd_val(*(pmd)) = (page_to_pfn(pte) << PAGE_SHIFT) | _PMD_PRESENT)
+#define pmd_pgtable(pmd) pmd_page(pmd)
 #else
 #define pmd_populate_kernel(mm, pmd, pte)	\
 		(pmd_val(*(pmd)) = (unsigned long)pte | _PMD_PRESENT)
 #define pmd_populate(mm, pmd, pte)	\
 		(pmd_val(*(pmd)) = (unsigned long)lowmem_page_address(pte) | _PMD_PRESENT)
+#define pmd_pgtable(pmd) pmd_page(pmd)
 #endif
 
 extern pte_t *pte_alloc_one_kernel(struct mm_struct *mm, unsigned long addr);
-extern struct page *pte_alloc_one(struct mm_struct *mm, unsigned long addr);
+extern pgtable_t pte_alloc_one(struct mm_struct *mm, unsigned long addr);
 extern void pte_free_kernel(struct mm_struct *mm, pte_t *pte);
-extern void pte_free(struct mm_struct *mm, struct page *pte);
+extern void pte_free(struct mm_struct *mm, pgtable_t pte);
 
 #define __pte_free_tlb(tlb, pte)	pte_free((tlb)->mm, (pte))
 
Index: quilt-2.6/include/asm-s390/page.h
===================================================================
--- quilt-2.6.orig/include/asm-s390/page.h
+++ quilt-2.6/include/asm-s390/page.h
@@ -110,6 +110,8 @@ typedef struct { unsigned long pgd; } pg
 
 #endif /* __s390x__ */
 
+typedef struct page *pgtable_t;
+
 #define __pte(x)        ((pte_t) { (x) } )
 #define __pmd(x)        ((pmd_t) { (x) } )
 #define __pgd(x)        ((pgd_t) { (x) } )
Index: quilt-2.6/include/asm-s390/pgalloc.h
===================================================================
--- quilt-2.6.orig/include/asm-s390/pgalloc.h
+++ quilt-2.6/include/asm-s390/pgalloc.h
@@ -132,7 +132,7 @@ pmd_populate_kernel(struct mm_struct *mm
 }
 
 static inline void
-pmd_populate(struct mm_struct *mm, pmd_t *pmd, struct page *page)
+pmd_populate(struct mm_struct *mm, pmd_t *pmd, pgtable_t page)
 {
 	pte_t *pte = (pte_t *)page_to_phys(page);
 	pmd_t *shadow_pmd = get_shadow_table(pmd);
@@ -142,6 +142,7 @@ pmd_populate(struct mm_struct *mm, pmd_t
 	if (shadow_pmd && shadow_pte)
 		pmd_populate_kernel(mm, shadow_pmd, shadow_pte);
 }
+#define pmd_pgtable(pmd) pmd_page(pmd)
 
 /*
  * page table entry allocation/free routines.
Index: quilt-2.6/include/asm-s390/tlb.h
===================================================================
--- quilt-2.6.orig/include/asm-s390/tlb.h
+++ quilt-2.6/include/asm-s390/tlb.h
@@ -95,7 +95,7 @@ static inline void tlb_remove_page(struc
  * pte_free_tlb frees a pte table and clears the CRSTE for the
  * page table from the tlb.
  */
-static inline void pte_free_tlb(struct mmu_gather *tlb, struct page *page)
+static inline void pte_free_tlb(struct mmu_gather *tlb, pgtable_t page)
 {
 	if (!tlb->fullmm) {
 		tlb->array[tlb->nr_ptes++] = page;
Index: quilt-2.6/include/asm-sh/page.h
===================================================================
--- quilt-2.6.orig/include/asm-sh/page.h
+++ quilt-2.6/include/asm-sh/page.h
@@ -107,6 +107,8 @@ typedef struct { unsigned long pgd; } pg
 #define __pgd(x) ((pgd_t) { (x) } )
 #define __pgprot(x)	((pgprot_t) { (x) } )
 
+typedef struct page *pgtable_t;
+
 #endif /* !__ASSEMBLY__ */
 
 /* to align the pointer to the (next) page boundary */
Index: quilt-2.6/include/asm-sh/pgalloc.h
===================================================================
--- quilt-2.6.orig/include/asm-sh/pgalloc.h
+++ quilt-2.6/include/asm-sh/pgalloc.h
@@ -14,10 +14,11 @@ static inline void pmd_populate_kernel(s
 }
 
 static inline void pmd_populate(struct mm_struct *mm, pmd_t *pmd,
-				struct page *pte)
+				pgtable_t pte)
 {
 	set_pmd(pmd, __pmd((unsigned long)page_address(pte)));
 }
+#define pmd_pgtable(pmd) pmd_page(pmd)
 
 static inline void pgd_ctor(void *x)
 {
@@ -47,11 +48,18 @@ static inline pte_t *pte_alloc_one_kerne
 	return quicklist_alloc(QUICK_PT, GFP_KERNEL | __GFP_REPEAT, NULL);
 }
 
-static inline struct page *pte_alloc_one(struct mm_struct *mm,
-					 unsigned long address)
+static inline pgtable_t pte_alloc_one(struct mm_struct *mm,
+					unsigned long address)
 {
-	void *pg = quicklist_alloc(QUICK_PT, GFP_KERNEL | __GFP_REPEAT, NULL);
-	return pg ? virt_to_page(pg) : NULL;
+	struct page *page;
+	void *pg;
+
+	pg = quicklist_alloc(QUICK_PT, GFP_KERNEL | __GFP_REPEAT, NULL);
+	if (!pg)
+		return NULL;
+	page = virt_to_page(pg);
+	pgtable_page_ctor(page);
+	return page;
 }
 
 static inline void pte_free_kernel(struct mm_struct *mm, pte_t *pte)
@@ -59,12 +67,17 @@ static inline void pte_free_kernel(struc
 	quicklist_free(QUICK_PT, NULL, pte);
 }
 
-static inline void pte_free(struct mm_struct *mm, struct page *pte)
+static inline void pte_free(struct mm_struct *mm, pgtable_t pte)
 {
+	pgtable_page_dtor(pte);
 	quicklist_free_page(QUICK_PT, NULL, pte);
 }
 
-#define __pte_free_tlb(tlb,pte) tlb_remove_page((tlb),(pte))
+#define __pte_free_tlb(tlb,pte)				\
+do {							\
+	pgtable_page_dtor(pte);				\
+	tlb_remove_page((tlb), (pte));			\
+} while (0)
 
 /*
  * allocating and freeing a pmd is trivial: the 1-entry pmd is
Index: quilt-2.6/include/asm-sh64/page.h
===================================================================
--- quilt-2.6.orig/include/asm-sh64/page.h
+++ quilt-2.6/include/asm-sh64/page.h
@@ -83,6 +83,8 @@ typedef struct { unsigned long pgprot; }
 #define __pgd(x) ((pgd_t) { (x) } )
 #define __pgprot(x)	((pgprot_t) { (x) } )
 
+typedef struct page *pgtable_t;
+
 #endif /* !__ASSEMBLY__ */
 
 /* to align the pointer to the (next) page boundary */
Index: quilt-2.6/include/asm-sh64/pgalloc.h
===================================================================
--- quilt-2.6.orig/include/asm-sh64/pgalloc.h
+++ quilt-2.6/include/asm-sh64/pgalloc.h
@@ -51,11 +51,18 @@ static inline void pgd_free(struct mm_st
 	quicklist_free(0, NULL, pgd);
 }
 
-static inline struct page *pte_alloc_one(struct mm_struct *mm,
-					 unsigned long address)
+static inline pgtable_t pte_alloc_one(struct mm_struct *mm,
+					unsigned long address)
 {
-	void *pg = quicklist_alloc(0, GFP_KERNEL, NULL);
-	return pg ? virt_to_page(pg) : NULL;
+	struct page *page;
+	void *pg;
+
+	pg = quicklist_alloc(0, GFP_KERNEL, NULL);
+	if (!pg)
+		return NULL;
+	page = virt_to_page(pg);
+	pgtable_page_ctor(page);
+	return page;
 }
 
 static inline void pte_free_kernel(struct mm_struct *mm, pte_t *pte)
@@ -63,8 +70,9 @@ static inline void pte_free_kernel(struc
 	quicklist_free(0, NULL, pte);
 }
 
-static inline void pte_free(struct mm_struct *mm, struct page *pte)
+static inline void pte_free(struct mm_struct *mm, pgtable_t pte)
 {
+	pgtable_page_dtor(pte);
 	quicklist_free_page(0, NULL, pte);
 }
 
@@ -74,7 +82,11 @@ static inline pte_t *pte_alloc_one_kerne
 	return quicklist_alloc(0, GFP_KERNEL, NULL);
 }
 
-#define __pte_free_tlb(tlb,pte) tlb_remove_page((tlb),(pte))
+#define __pte_free_tlb(tlb,pte)				\
+do {							\
+	pgtable_page_dtor(pte);				\
+	tlb_remove_page((tlb),(pte));			\
+} while (0)
 
 /*
  * allocating and freeing a pmd is trivial: the 1-entry pmd is
@@ -112,10 +124,11 @@ static inline void pmd_free(struct mm_st
 	set_pmd(pmd, __pmd(_PAGE_TABLE + (unsigned long) (pte)))
 
 static inline void pmd_populate(struct mm_struct *mm, pmd_t *pmd,
-				struct page *pte)
+				pgtable_t pte)
 {
 	set_pmd(pmd, __pmd(_PAGE_TABLE + (unsigned long) page_address (pte)));
 }
+#define pmd_pgtable(pmd) pmd_page(pmd)
 
 static inline void check_pgt_cache(void)
 {
Index: quilt-2.6/include/asm-sparc/page.h
===================================================================
--- quilt-2.6.orig/include/asm-sparc/page.h
+++ quilt-2.6/include/asm-sparc/page.h
@@ -125,6 +125,8 @@ typedef unsigned long iopgprot_t;
 
 #endif
 
+typedef struct page *pgtable_t;
+
 extern unsigned long sparc_unmapped_base;
 
 BTFIXUPDEF_SETHI(sparc_unmapped_base)
Index: quilt-2.6/include/asm-sparc/pgalloc.h
===================================================================
--- quilt-2.6.orig/include/asm-sparc/pgalloc.h
+++ quilt-2.6/include/asm-sparc/pgalloc.h
@@ -50,10 +50,11 @@ BTFIXUPDEF_CALL(void, free_pmd_fast, pmd
 
 BTFIXUPDEF_CALL(void, pmd_populate, pmd_t *, struct page *)
 #define pmd_populate(MM, PMD, PTE)        BTFIXUP_CALL(pmd_populate)(PMD, PTE)
+#define pmd_pgtable(pmd) pmd_page(pmd)
 BTFIXUPDEF_CALL(void, pmd_set, pmd_t *, pte_t *)
 #define pmd_populate_kernel(MM, PMD, PTE) BTFIXUP_CALL(pmd_set)(PMD, PTE)
 
-BTFIXUPDEF_CALL(struct page *, pte_alloc_one, struct mm_struct *, unsigned long)
+BTFIXUPDEF_CALL(pgtable_t , pte_alloc_one, struct mm_struct *, unsigned long)
 #define pte_alloc_one(mm, address)	BTFIXUP_CALL(pte_alloc_one)(mm, address)
 BTFIXUPDEF_CALL(pte_t *, pte_alloc_one_kernel, struct mm_struct *, unsigned long)
 #define pte_alloc_one_kernel(mm, addr)	BTFIXUP_CALL(pte_alloc_one_kernel)(mm, addr)
@@ -61,7 +62,7 @@ BTFIXUPDEF_CALL(pte_t *, pte_alloc_one_k
 BTFIXUPDEF_CALL(void, free_pte_fast, pte_t *)
 #define pte_free_kernel(mm,pte)	BTFIXUP_CALL(free_pte_fast)(pte)
 
-BTFIXUPDEF_CALL(void, pte_free, struct page *)
+BTFIXUPDEF_CALL(void, pte_free, pgtable_t )
 #define pte_free(mm,pte)	BTFIXUP_CALL(pte_free)(pte)
 #define __pte_free_tlb(tlb, pte)	pte_free((tlb)->mm, pte)
 
Index: quilt-2.6/include/asm-sparc64/page.h
===================================================================
--- quilt-2.6.orig/include/asm-sparc64/page.h
+++ quilt-2.6/include/asm-sparc64/page.h
@@ -106,6 +106,8 @@ typedef unsigned long pgprot_t;
 
 #endif /* (STRICT_MM_TYPECHECKS) */
 
+typedef struct page *pgtable_t;
+
 #define TASK_UNMAPPED_BASE	(test_thread_flag(TIF_32BIT) ? \
 				 (_AC(0x0000000070000000,UL)) : \
 				 (_AC(0xfffff80000000000,UL) + (1UL << 32UL)))
Index: quilt-2.6/include/asm-sparc64/pgalloc.h
===================================================================
--- quilt-2.6.orig/include/asm-sparc64/pgalloc.h
+++ quilt-2.6/include/asm-sparc64/pgalloc.h
@@ -43,11 +43,18 @@ static inline pte_t *pte_alloc_one_kerne
 	return quicklist_alloc(0, GFP_KERNEL, NULL);
 }
 
-static inline struct page *pte_alloc_one(struct mm_struct *mm,
-					 unsigned long address)
+static inline pgtable_t pte_alloc_one(struct mm_struct *mm,
+					unsigned long address)
 {
-	void *pg = quicklist_alloc(0, GFP_KERNEL, NULL);
-	return pg ? virt_to_page(pg) : NULL;
+	struct page *page;
+	void *pg;
+
+	pg = quicklist_alloc(0, GFP_KERNEL, NULL);
+	if (!pg)
+		return NULL;
+	page = virt_to_page(pg);
+	pgtable_page_ctor(page);
+	return page;
 }
 		
 static inline void pte_free_kernel(struct mm_struct *mm, pte_t *pte)
@@ -55,8 +62,9 @@ static inline void pte_free_kernel(struc
 	quicklist_free(0, NULL, pte);
 }
 
-static inline void pte_free(struct mm_struct *mm, struct page *ptepage)
+static inline void pte_free(struct mm_struct *mm, pgtable_t ptepage)
 {
+	pgtable_page_dtor(ptepage);
 	quicklist_free_page(0, NULL, ptepage);
 }
 
@@ -64,6 +72,7 @@ static inline void pte_free(struct mm_st
 #define pmd_populate_kernel(MM, PMD, PTE)	pmd_set(PMD, PTE)
 #define pmd_populate(MM,PMD,PTE_PAGE)		\
 	pmd_populate_kernel(MM,PMD,page_address(PTE_PAGE))
+#define pmd_pgtable(pmd) pmd_page(pmd)
 
 static inline void check_pgt_cache(void)
 {
Index: quilt-2.6/include/asm-um/page.h
===================================================================
--- quilt-2.6.orig/include/asm-um/page.h
+++ quilt-2.6/include/asm-um/page.h
@@ -79,6 +79,8 @@ typedef unsigned long phys_t;
 
 typedef struct { unsigned long pgprot; } pgprot_t;
 
+typedef struct page *pgtable_t;
+
 #define pgd_val(x)	((x).pgd)
 #define pgprot_val(x)	((x).pgprot)
 
Index: quilt-2.6/include/asm-um/pgalloc.h
===================================================================
--- quilt-2.6.orig/include/asm-um/pgalloc.h
+++ quilt-2.6/include/asm-um/pgalloc.h
@@ -18,6 +18,7 @@
 	set_pmd(pmd, __pmd(_PAGE_TABLE +			\
 		((unsigned long long)page_to_pfn(pte) <<	\
 			(unsigned long long) PAGE_SHIFT)))
+#define pmd_pgtable(pmd) pmd_page(pmd)
 
 /*
  * Allocate and free page tables.
@@ -26,19 +27,24 @@ extern pgd_t *pgd_alloc(struct mm_struct
 extern void pgd_free(struct mm_struct *mm, pgd_t *pgd);
 
 extern pte_t *pte_alloc_one_kernel(struct mm_struct *, unsigned long);
-extern struct page *pte_alloc_one(struct mm_struct *, unsigned long);
+extern pgtable_t pte_alloc_one(struct mm_struct *, unsigned long);
 
 static inline void pte_free_kernel(struct mm_struct *mm, pte_t *pte)
 {
 	free_page((unsigned long) pte);
 }
 
-static inline void pte_free(struct mm_struct *mm, struct page *pte)
+static inline void pte_free(struct mm_struct *mm, pgtable_t pte)
 {
+	pgtable_page_dtor(pte);
 	__free_page(pte);
 }
 
-#define __pte_free_tlb(tlb,pte) tlb_remove_page((tlb),(pte))
+#define __pte_free_tlb(tlb,pte)				\
+do {							\
+	pgtable_page_dtor(pte);				\
+	tlb_remove_page((tlb),(pte));			\
+} while (0)
 
 #ifdef CONFIG_3_LEVEL_PGTABLES
 
Index: quilt-2.6/include/asm-x86/page_32.h
===================================================================
--- quilt-2.6.orig/include/asm-x86/page_32.h
+++ quilt-2.6/include/asm-x86/page_32.h
@@ -116,6 +116,8 @@ static inline pte_t native_make_pte(unsi
 #include <asm-generic/pgtable-nopmd.h>
 #endif	/* CONFIG_X86_PAE */
 
+typedef struct page *pgtable_t;
+
 #define PTE_MASK	PAGE_MASK
 
 #ifdef CONFIG_HUGETLB_PAGE
Index: quilt-2.6/include/asm-x86/page_64.h
===================================================================
--- quilt-2.6.orig/include/asm-x86/page_64.h
+++ quilt-2.6/include/asm-x86/page_64.h
@@ -62,6 +62,8 @@ typedef struct { unsigned long pgd; } pg
 
 typedef struct { unsigned long pgprot; } pgprot_t;
 
+typedef struct page *pgtable_t;
+
 extern unsigned long phys_base;
 
 #define pte_val(x)	((x).pte)
Index: quilt-2.6/include/asm-x86/pgalloc_32.h
===================================================================
--- quilt-2.6.orig/include/asm-x86/pgalloc_32.h
+++ quilt-2.6/include/asm-x86/pgalloc_32.h
@@ -28,6 +28,7 @@ do {								\
 		((unsigned long long)page_to_pfn(pte) <<	\
 			(unsigned long long) PAGE_SHIFT)));	\
 } while (0)
+#define pmd_pgtable(pmd) pmd_page(pmd)
 
 /*
  * Allocate and free page tables.
@@ -36,21 +37,23 @@ extern pgd_t *pgd_alloc(struct mm_struct
 extern void pgd_free(struct mm_struct *mm, pgd_t *pgd);
 
 extern pte_t *pte_alloc_one_kernel(struct mm_struct *, unsigned long);
-extern struct page *pte_alloc_one(struct mm_struct *, unsigned long);
+extern pgtable_t pte_alloc_one(struct mm_struct *, unsigned long);
 
 static inline void pte_free_kernel(struct mm_struct *mm, pte_t *pte)
 {
 	free_page((unsigned long)pte);
 }
 
-static inline void pte_free(struct mm_struct *mm, struct page *pte)
+static inline void pte_free(struct mm_struct *mm, pgtable_t pte)
 {
+	pgtable_page_dtor(pte);
 	__free_page(pte);
 }
 
 
 #define __pte_free_tlb(tlb,pte) 					\
 do {									\
+	pgtable_page_dtor(pte);						\
 	paravirt_release_pt(page_to_pfn(pte));				\
 	tlb_remove_page((tlb),(pte));					\
 } while (0)
Index: quilt-2.6/include/asm-x86/pgalloc_64.h
===================================================================
--- quilt-2.6.orig/include/asm-x86/pgalloc_64.h
+++ quilt-2.6/include/asm-x86/pgalloc_64.h
@@ -12,6 +12,8 @@
 #define pgd_populate(mm, pgd, pud) \
 		set_pgd(pgd, __pgd(_PAGE_TABLE | __pa(pud)))
 
+#define pmd_pgtable(pmd) pmd_page(pmd)
+
 static inline void pmd_populate(struct mm_struct *mm, pmd_t *pmd, struct page *pte)
 {
 	set_pmd(pmd, __pmd(_PAGE_TABLE | (page_to_pfn(pte) << PAGE_SHIFT)));
@@ -89,12 +91,17 @@ static inline pte_t *pte_alloc_one_kerne
 	return (pte_t *)get_zeroed_page(GFP_KERNEL|__GFP_REPEAT);
 }
 
-static inline struct page *pte_alloc_one(struct mm_struct *mm, unsigned long address)
+static inline pgtable_t pte_alloc_one(struct mm_struct *mm, unsigned long address)
 {
-	void *p = (void *)get_zeroed_page(GFP_KERNEL|__GFP_REPEAT);
+	struct page *page;
+	void *p;
+
+	p = (void *)get_zeroed_page(GFP_KERNEL|__GFP_REPEAT);
 	if (!p)
 		return NULL;
-	return virt_to_page(p);
+	page = virt_to_page(p);
+	pgtable_page_ctor(page);
+	return page;
 }
 
 /* Should really implement gc for free page table pages. This could be
@@ -106,12 +113,17 @@ static inline void pte_free_kernel(struc
 	free_page((unsigned long)pte); 
 }
 
-static inline void pte_free(struct mm_struct *mm, struct page *pte)
+static inline void pte_free(struct mm_struct *mm, pgtable_t pte)
 {
+	pgtable_page_dtor(pte);
 	__free_page(pte);
 } 
 
-#define __pte_free_tlb(tlb,pte) tlb_remove_page((tlb),(pte))
+#define __pte_free_tlb(tlb,pte)				\
+do {							\
+	pgtable_page_dtor((pte));				\
+	tlb_remove_page((tlb), (pte));			\
+} while (0)
 
 #define __pmd_free_tlb(tlb,x)   tlb_remove_page((tlb),virt_to_page(x))
 #define __pud_free_tlb(tlb,x)   tlb_remove_page((tlb),virt_to_page(x))
Index: quilt-2.6/include/asm-xtensa/page.h
===================================================================
--- quilt-2.6.orig/include/asm-xtensa/page.h
+++ quilt-2.6/include/asm-xtensa/page.h
@@ -100,6 +100,7 @@
 typedef struct { unsigned long pte; } pte_t;		/* page table entry */
 typedef struct { unsigned long pgd; } pgd_t;		/* PGD table entry */
 typedef struct { unsigned long pgprot; } pgprot_t;
+typedef struct page *pgtable_t;
 
 #define pte_val(x)	((x).pte)
 #define pgd_val(x)	((x).pgd)
Index: quilt-2.6/include/asm-xtensa/pgalloc.h
===================================================================
--- quilt-2.6.orig/include/asm-xtensa/pgalloc.h
+++ quilt-2.6/include/asm-xtensa/pgalloc.h
@@ -24,6 +24,7 @@
 	(pmd_val(*(pmdp)) = ((unsigned long)ptep))
 #define pmd_populate(mm, pmdp, page)					     \
 	(pmd_val(*(pmdp)) = ((unsigned long)page_to_virt(page)))
+#define pmd_pgtable(pmd) pmd_page(pmd)
 
 static inline pgd_t*
 pgd_alloc(struct mm_struct *mm)
@@ -46,10 +47,14 @@ static inline pte_t *pte_alloc_one_kerne
 	return kmem_cache_alloc(pgtable_cache, GFP_KERNEL|__GFP_REPEAT);
 }
 
-static inline struct page *pte_alloc_one(struct mm_struct *mm, 
-					 unsigned long addr)
+static inline pte_token_t pte_alloc_one(struct mm_struct *mm,
+					unsigned long addr)
 {
-	return virt_to_page(pte_alloc_one_kernel(mm, addr));
+	struct page *page;
+
+	page = virt_to_page(pte_alloc_one_kernel(mm, addr));
+	pgtable_page_ctor(page);
+	return page;
 }
 
 static inline void pte_free_kernel(struct mm_struct *mm, pte_t *pte)
@@ -57,10 +62,12 @@ static inline void pte_free_kernel(struc
 	kmem_cache_free(pgtable_cache, pte);
 }
 
-static inline void pte_free(struct mm_struct *mm, struct page *page)
+static inline void pte_free(struct mm_struct *mm, pgtable_t pte)
 {
-	kmem_cache_free(pgtable_cache, page_address(page));
+	pgtable_page_dtor(pte);
+	kmem_cache_free(pgtable_cache, page_address(pte));
 }
+#define pmd_pgtable(pmd) pmd_page(pmd)
 
 #endif /* __KERNEL__ */
 #endif /* _XTENSA_PGALLOC_H */
Index: quilt-2.6/include/linux/mm.h
===================================================================
--- quilt-2.6.orig/include/linux/mm.h
+++ quilt-2.6/include/linux/mm.h
@@ -843,6 +843,18 @@ static inline pmd_t *pmd_alloc(struct mm
 #define pte_lockptr(mm, pmd)	({(void)(pmd); &(mm)->page_table_lock;})
 #endif /* NR_CPUS < CONFIG_SPLIT_PTLOCK_CPUS */
 
+static inline void pgtable_page_ctor(struct page *page)
+{
+	pte_lock_init(page);
+	inc_zone_page_state(page, NR_PAGETABLE);
+}
+
+static inline void pgtable_page_dtor(struct page *page)
+{
+	pte_lock_deinit(page);
+	dec_zone_page_state(page, NR_PAGETABLE);
+}
+
 #define pte_offset_map_lock(mm, pmd, address, ptlp)	\
 ({							\
 	spinlock_t *__ptl = pte_lockptr(mm, pmd);	\
@@ -1087,7 +1099,7 @@ struct page *follow_page(struct vm_area_
 #define FOLL_GET	0x04	/* do get_page on page */
 #define FOLL_ANON	0x08	/* give ZERO_PAGE if no pgtable */
 
-typedef int (*pte_fn_t)(pte_t *pte, struct page *pmd_page, unsigned long addr,
+typedef int (*pte_fn_t)(pte_t *pte, pgtable_t token, unsigned long addr,
 			void *data);
 extern int apply_to_page_range(struct mm_struct *mm, unsigned long address,
 			       unsigned long size, pte_fn_t fn, void *data);
Index: quilt-2.6/mm/memory.c
===================================================================
--- quilt-2.6.orig/mm/memory.c
+++ quilt-2.6/mm/memory.c
@@ -122,11 +122,9 @@ void pmd_clear_bad(pmd_t *pmd)
  */
 static void free_pte_range(struct mmu_gather *tlb, pmd_t *pmd)
 {
-	struct page *page = pmd_page(*pmd);
+	pgtable_t token = pmd_pgtable(*pmd);
 	pmd_clear(pmd);
-	pte_lock_deinit(page);
-	pte_free_tlb(tlb, page);
-	dec_zone_page_state(page, NR_PAGETABLE);
+	pte_free_tlb(tlb, token);
 	tlb->mm->nr_ptes--;
 }
 
@@ -297,21 +295,19 @@ void free_pgtables(struct mmu_gather **t
 
 int __pte_alloc(struct mm_struct *mm, pmd_t *pmd, unsigned long address)
 {
-	struct page *new = pte_alloc_one(mm, address);
+	pgtable_t new = pte_alloc_one(mm, address);
 	if (!new)
 		return -ENOMEM;
 
-	pte_lock_init(new);
 	spin_lock(&mm->page_table_lock);
-	if (pmd_present(*pmd)) {	/* Another has populated it */
-		pte_lock_deinit(new);
-		pte_free(mm, new);
-	} else {
+	if (!pmd_present(*pmd)) {	/* Has another populated it ? */
 		mm->nr_ptes++;
-		inc_zone_page_state(new, NR_PAGETABLE);
 		pmd_populate(mm, pmd, new);
+		new = NULL;
 	}
 	spin_unlock(&mm->page_table_lock);
+	if (new)
+		pte_free(mm, new);
 	return 0;
 }
 
@@ -322,11 +318,13 @@ int __pte_alloc_kernel(pmd_t *pmd, unsig
 		return -ENOMEM;
 
 	spin_lock(&init_mm.page_table_lock);
-	if (pmd_present(*pmd))		/* Another has populated it */
-		pte_free_kernel(&init_mm, new);
-	else
+	if (!pmd_present(*pmd)) {	/* Has another populated it ? */
 		pmd_populate_kernel(&init_mm, pmd, new);
+		new = NULL;
+	}
 	spin_unlock(&init_mm.page_table_lock);
+	if (new)
+		pte_free_kernel(&init_mm, new);
 	return 0;
 }
 
@@ -1368,7 +1366,7 @@ static int apply_to_pte_range(struct mm_
 {
 	pte_t *pte;
 	int err;
-	struct page *pmd_page;
+	pgtable_t token;
 	spinlock_t *uninitialized_var(ptl);
 
 	pte = (mm == &init_mm) ?
@@ -1379,10 +1377,10 @@ static int apply_to_pte_range(struct mm_
 
 	BUG_ON(pmd_huge(*pmd));
 
-	pmd_page = pmd_page(*pmd);
+	token = pmd_pgtable(*pmd);
 
 	do {
-		err = fn(pte, pmd_page, addr, data);
+		err = fn(pte, token, addr, data);
 		if (err)
 			break;
 	} while (pte++, addr += PAGE_SIZE, addr != end);
Index: quilt-2.6/mm/vmalloc.c
===================================================================
--- quilt-2.6.orig/mm/vmalloc.c
+++ quilt-2.6/mm/vmalloc.c
@@ -772,7 +772,7 @@ void  __attribute__((weak)) vmalloc_sync
 }
 
 
-static int f(pte_t *pte, struct page *pmd_page, unsigned long addr, void *data)
+static int f(pte_t *pte, pgtable_t table, unsigned long addr, void *data)
 {
 	/* apply_to_page_range() does all the hard work. */
 	return 0;

-- 
blue skies,
   Martin.

"Reality continues to ruin my life." - Calvin.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
