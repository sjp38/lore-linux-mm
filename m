Message-Id: <200405222204.i4MM4rr12547@mail.osdl.org>
Subject: [patch 14/57] rmap 13 include/asm deletions
From: akpm@osdl.org
Date: Sat, 22 May 2004 15:04:22 -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: torvalds@osdl.org
Cc: linux-mm@kvack.org, akpm@osdl.org, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

From: Hugh Dickins <hugh@veritas.com>

Delete include/asm*/rmap.h
Delete pte_addr_t typedef from include/asm*/pgtable.h
Delete KM_PTE2 from subset of include/asm*/kmap_types.h
Beware when 4G/4G returns to -mm: i386 may need KM_FILLER for 8K stack.


---

 /dev/null                               |  288 --------------------------------
 25-akpm/include/asm-alpha/pgtable.h     |    2 
 25-akpm/include/asm-arm/kmap_types.h    |    1 
 25-akpm/include/asm-arm/pgtable.h       |    2 
 25-akpm/include/asm-arm26/pgtable.h     |    2 
 25-akpm/include/asm-cris/pgtable.h      |    2 
 25-akpm/include/asm-h8300/pgtable.h     |    2 
 25-akpm/include/asm-i386/kmap_types.h   |   11 -
 25-akpm/include/asm-i386/pgtable.h      |   12 -
 25-akpm/include/asm-ia64/pgtable.h      |    2 
 25-akpm/include/asm-m68k/pgtable.h      |    2 
 25-akpm/include/asm-m68knommu/pgtable.h |    2 
 25-akpm/include/asm-mips/kmap_types.h   |   11 -
 25-akpm/include/asm-mips/pgtable-32.h   |    6 
 25-akpm/include/asm-mips/pgtable-64.h   |    2 
 25-akpm/include/asm-parisc/pgtable.h    |    2 
 25-akpm/include/asm-ppc/pgtable.h       |    2 
 25-akpm/include/asm-ppc64/pgtable.h     |    2 
 25-akpm/include/asm-s390/pgtable.h      |    2 
 25-akpm/include/asm-sh/pgtable.h        |    2 
 25-akpm/include/asm-sparc/kmap_types.h  |    1 
 25-akpm/include/asm-sparc/pgtable.h     |    2 
 25-akpm/include/asm-sparc64/pgtable.h   |    2 
 25-akpm/include/asm-um/pgtable.h        |   12 -
 25-akpm/include/asm-v850/pgtable.h      |    2 
 25-akpm/include/asm-x86_64/pgtable.h    |    2 
 26 files changed, 10 insertions(+), 368 deletions(-)

diff -puN include/asm-alpha/pgtable.h~rmap-13-include-asm-deletions include/asm-alpha/pgtable.h
--- 25/include/asm-alpha/pgtable.h~rmap-13-include-asm-deletions	2004-05-22 14:56:23.488520728 -0700
+++ 25-akpm/include/asm-alpha/pgtable.h	2004-05-22 14:56:23.547511760 -0700
@@ -349,6 +349,4 @@ extern void paging_init(void);
 /* We have our own get_unmapped_area to cope with ADDR_LIMIT_32BIT.  */
 #define HAVE_ARCH_UNMAPPED_AREA
 
-typedef pte_t *pte_addr_t;
-
 #endif /* _ALPHA_PGTABLE_H */
diff -L include/asm-alpha/rmap.h -puN include/asm-alpha/rmap.h~rmap-13-include-asm-deletions /dev/null
--- 25/include/asm-alpha/rmap.h
+++ /dev/null	2003-09-15 06:40:47.000000000 -0700
@@ -1,7 +0,0 @@
-#ifndef _ALPHA_RMAP_H
-#define _ALPHA_RMAP_H
-
-/* nothing to see, move along */
-#include <asm-generic/rmap.h>
-
-#endif
diff -puN include/asm-arm26/pgtable.h~rmap-13-include-asm-deletions include/asm-arm26/pgtable.h
--- 25/include/asm-arm26/pgtable.h~rmap-13-include-asm-deletions	2004-05-22 14:56:23.490520424 -0700
+++ 25-akpm/include/asm-arm26/pgtable.h	2004-05-22 14:56:23.548511608 -0700
@@ -290,8 +290,6 @@ static inline pte_t mk_pte_phys(unsigned
 #define io_remap_page_range(vma,from,phys,size,prot) \
 		remap_page_range(vma,from,phys,size,prot)
 
-typedef pte_t *pte_addr_t;
-
 #endif /* !__ASSEMBLY__ */
 
 #endif /* _ASMARM_PGTABLE_H */
diff -L include/asm-arm26/rmap.h -puN include/asm-arm26/rmap.h~rmap-13-include-asm-deletions /dev/null
--- 25/include/asm-arm26/rmap.h
+++ /dev/null	2003-09-15 06:40:47.000000000 -0700
@@ -1,66 +0,0 @@
-#ifndef _ARM_RMAP_H
-#define _ARM_RMAP_H
-
-/*
- * linux/include/asm-arm26/proc-armv/rmap.h
- *
- * Architecture dependant parts of the reverse mapping code,
- *
- * ARM is different since hardware page tables are smaller than
- * the page size and Linux uses a "duplicate" one with extra info.
- * For rmap this means that the first 2 kB of a page are the hardware
- * page tables and the last 2 kB are the software page tables.
- */
-
-static inline void pgtable_add_rmap(struct page *page, struct mm_struct * mm, unsigned long address)
-{
-        page->mapping = (void *)mm;
-        page->index = address & ~((PTRS_PER_PTE * PAGE_SIZE) - 1);
-        inc_page_state(nr_page_table_pages);
-}
-
-static inline void pgtable_remove_rmap(struct page *page)
-{
-        page->mapping = NULL;
-        page->index = 0;
-        dec_page_state(nr_page_table_pages);
-}
-
-static inline struct mm_struct * ptep_to_mm(pte_t * ptep)
-{
-	struct page * page = virt_to_page(ptep);
-        return (struct mm_struct *)page->mapping;
-}
-
-/* The page table takes half of the page */
-#define PTE_MASK  ((PAGE_SIZE / 2) - 1)
-
-static inline unsigned long ptep_to_address(pte_t * ptep)
-{
-        struct page * page = virt_to_page(ptep);
-        unsigned long low_bits;
-
-        low_bits = ((unsigned long)ptep & PTE_MASK) * PTRS_PER_PTE;
-        return page->index + low_bits;
-}
- 
-//FIXME!!! IS these correct?
-static inline pte_addr_t ptep_to_paddr(pte_t *ptep)
-{
-        return (pte_addr_t)ptep;
-}
-
-static inline pte_t *rmap_ptep_map(pte_addr_t pte_paddr)
-{
-        return (pte_t *)pte_paddr;
-}
-
-static inline void rmap_ptep_unmap(pte_t *pte)
-{
-        return;
-}
-
-
-//#include <asm-generic/rmap.h>
-
-#endif /* _ARM_RMAP_H */
diff -puN include/asm-arm/kmap_types.h~rmap-13-include-asm-deletions include/asm-arm/kmap_types.h
--- 25/include/asm-arm/kmap_types.h~rmap-13-include-asm-deletions	2004-05-22 14:56:23.493519968 -0700
+++ 25-akpm/include/asm-arm/kmap_types.h	2004-05-22 14:56:23.549511456 -0700
@@ -14,7 +14,6 @@ enum km_type {
 	KM_BIO_DST_IRQ,
 	KM_PTE0,
 	KM_PTE1,
-	KM_PTE2,
 	KM_IRQ0,
 	KM_IRQ1,
 	KM_SOFTIRQ0,
diff -puN include/asm-arm/pgtable.h~rmap-13-include-asm-deletions include/asm-arm/pgtable.h
--- 25/include/asm-arm/pgtable.h~rmap-13-include-asm-deletions	2004-05-22 14:56:23.495519664 -0700
+++ 25-akpm/include/asm-arm/pgtable.h	2004-05-22 14:56:23.550511304 -0700
@@ -407,8 +407,6 @@ extern pgd_t swapper_pg_dir[PTRS_PER_PGD
 #define io_remap_page_range(vma,from,phys,size,prot) \
 		remap_page_range(vma,from,phys,size,prot)
 
-typedef pte_t *pte_addr_t;
-
 #define pgtable_cache_init() do { } while (0)
 
 #endif /* !__ASSEMBLY__ */
diff -L include/asm-arm/rmap.h -puN include/asm-arm/rmap.h~rmap-13-include-asm-deletions /dev/null
--- 25/include/asm-arm/rmap.h
+++ /dev/null	2003-09-15 06:40:47.000000000 -0700
@@ -1,6 +0,0 @@
-#ifndef _ARM_RMAP_H
-#define _ARM_RMAP_H
-
-#include <asm-generic/rmap.h>
-
-#endif /* _ARM_RMAP_H */
diff -puN include/asm-cris/pgtable.h~rmap-13-include-asm-deletions include/asm-cris/pgtable.h
--- 25/include/asm-cris/pgtable.h~rmap-13-include-asm-deletions	2004-05-22 14:56:23.497519360 -0700
+++ 25-akpm/include/asm-cris/pgtable.h	2004-05-22 14:56:23.550511304 -0700
@@ -337,6 +337,4 @@ extern inline void update_mmu_cache(stru
 #define pte_to_pgoff(x)	(pte_val(x) >> 6)
 #define pgoff_to_pte(x)	__pte(((x) << 6) | _PAGE_FILE)
 
-typedef pte_t *pte_addr_t;
-
 #endif /* _CRIS_PGTABLE_H */
diff -L include/asm-cris/rmap.h -puN include/asm-cris/rmap.h~rmap-13-include-asm-deletions /dev/null
--- 25/include/asm-cris/rmap.h
+++ /dev/null	2003-09-15 06:40:47.000000000 -0700
@@ -1,7 +0,0 @@
-#ifndef _CRIS_RMAP_H
-#define _CRIS_RMAP_H
-
-/* nothing to see, move along :) */
-#include <asm-generic/rmap.h>
-
-#endif
diff -L include/asm-generic/rmap.h -puN include/asm-generic/rmap.h~rmap-13-include-asm-deletions /dev/null
--- 25/include/asm-generic/rmap.h
+++ /dev/null	2003-09-15 06:40:47.000000000 -0700
@@ -1,91 +0,0 @@
-#ifndef _GENERIC_RMAP_H
-#define _GENERIC_RMAP_H
-/*
- * linux/include/asm-generic/rmap.h
- *
- * Architecture dependent parts of the reverse mapping code,
- * this version should work for most architectures with a
- * 'normal' page table layout.
- *
- * We use the struct page of the page table page to find out
- * the process and full address of a page table entry:
- * - page->mapping points to the process' mm_struct
- * - page->index has the high bits of the address
- * - the lower bits of the address are calculated from the
- *   offset of the page table entry within the page table page
- *
- * For CONFIG_HIGHPTE, we need to represent the address of a pte in a
- * scalar pte_addr_t.  The pfn of the pte's page is shifted left by PAGE_SIZE
- * bits and is then ORed with the byte offset of the pte within its page.
- *
- * For CONFIG_HIGHMEM4G, the pte_addr_t is 32 bits.  20 for the pfn, 12 for
- * the offset.
- *
- * For CONFIG_HIGHMEM64G, the pte_addr_t is 64 bits.  52 for the pfn, 12 for
- * the offset.
- */
-#include <linux/mm.h>
-
-static inline void pgtable_add_rmap(struct page * page, struct mm_struct * mm, unsigned long address)
-{
-#ifdef BROKEN_PPC_PTE_ALLOC_ONE
-	/* OK, so PPC calls pte_alloc() before mem_map[] is setup ... ;( */
-	extern int mem_init_done;
-
-	if (!mem_init_done)
-		return;
-#endif
-	page->mapping = (void *)mm;
-	page->index = address & ~((PTRS_PER_PTE * PAGE_SIZE) - 1);
-	inc_page_state(nr_page_table_pages);
-}
-
-static inline void pgtable_remove_rmap(struct page * page)
-{
-	page->mapping = NULL;
-	page->index = 0;
-	dec_page_state(nr_page_table_pages);
-}
-
-static inline struct mm_struct * ptep_to_mm(pte_t * ptep)
-{
-	struct page * page = kmap_atomic_to_page(ptep);
-	return (struct mm_struct *) page->mapping;
-}
-
-static inline unsigned long ptep_to_address(pte_t * ptep)
-{
-	struct page * page = kmap_atomic_to_page(ptep);
-	unsigned long low_bits;
-	low_bits = ((unsigned long)ptep & (PTRS_PER_PTE*sizeof(pte_t) - 1))
-			* (PAGE_SIZE/sizeof(pte_t));
-	return page->index + low_bits;
-}
-
-#ifdef CONFIG_HIGHPTE
-static inline pte_addr_t ptep_to_paddr(pte_t *ptep)
-{
-	pte_addr_t paddr;
-	paddr = ((pte_addr_t)page_to_pfn(kmap_atomic_to_page(ptep))) << PAGE_SHIFT;
-	return paddr + (pte_addr_t)((unsigned long)ptep & ~PAGE_MASK);
-}
-#else
-static inline pte_addr_t ptep_to_paddr(pte_t *ptep)
-{
-	return (pte_addr_t)ptep;
-}
-#endif
-
-#ifndef CONFIG_HIGHPTE
-static inline pte_t *rmap_ptep_map(pte_addr_t pte_paddr)
-{
-	return (pte_t *)pte_paddr;
-}
-
-static inline void rmap_ptep_unmap(pte_t *pte)
-{
-	return;
-}
-#endif
-
-#endif /* _GENERIC_RMAP_H */
diff -puN include/asm-h8300/pgtable.h~rmap-13-include-asm-deletions include/asm-h8300/pgtable.h
--- 25/include/asm-h8300/pgtable.h~rmap-13-include-asm-deletions	2004-05-22 14:56:23.501518752 -0700
+++ 25-akpm/include/asm-h8300/pgtable.h	2004-05-22 14:56:23.551511152 -0700
@@ -7,8 +7,6 @@
 #include <asm/page.h>
 #include <asm/io.h>
 
-typedef pte_t *pte_addr_t;
-
 #define pgd_present(pgd)     (1)       /* pages are always present on NO_MM */
 #define pgd_none(pgd)		(0)
 #define pgd_bad(pgd)		(0)
diff -puN include/asm-i386/kmap_types.h~rmap-13-include-asm-deletions include/asm-i386/kmap_types.h
--- 25/include/asm-i386/kmap_types.h~rmap-13-include-asm-deletions	2004-05-22 14:56:23.502518600 -0700
+++ 25-akpm/include/asm-i386/kmap_types.h	2004-05-22 14:56:23.552511000 -0700
@@ -19,12 +19,11 @@ D(5)	KM_BIO_SRC_IRQ,
 D(6)	KM_BIO_DST_IRQ,
 D(7)	KM_PTE0,
 D(8)	KM_PTE1,
-D(9)	KM_PTE2,
-D(10)	KM_IRQ0,
-D(11)	KM_IRQ1,
-D(12)	KM_SOFTIRQ0,
-D(13)	KM_SOFTIRQ1,
-D(14)	KM_TYPE_NR
+D(9)	KM_IRQ0,
+D(10)	KM_IRQ1,
+D(11)	KM_SOFTIRQ0,
+D(12)	KM_SOFTIRQ1,
+D(13)	KM_TYPE_NR
 };
 
 #undef D
diff -puN include/asm-i386/pgtable.h~rmap-13-include-asm-deletions include/asm-i386/pgtable.h
--- 25/include/asm-i386/pgtable.h~rmap-13-include-asm-deletions	2004-05-22 14:56:23.504518296 -0700
+++ 25-akpm/include/asm-i386/pgtable.h	2004-05-22 14:56:23.552511000 -0700
@@ -314,18 +314,6 @@ static inline pte_t pte_modify(pte_t pte
 #define pte_unmap_nested(pte) do { } while (0)
 #endif
 
-#if defined(CONFIG_HIGHPTE) && defined(CONFIG_HIGHMEM4G)
-typedef u32 pte_addr_t;
-#endif
-
-#if defined(CONFIG_HIGHPTE) && defined(CONFIG_HIGHMEM64G)
-typedef u64 pte_addr_t;
-#endif
-
-#if !defined(CONFIG_HIGHPTE)
-typedef pte_t *pte_addr_t;
-#endif
-
 /*
  * The i386 doesn't have any external MMU info: the kernel page
  * tables contain all the necessary information.
diff -L include/asm-i386/rmap.h -puN include/asm-i386/rmap.h~rmap-13-include-asm-deletions /dev/null
--- 25/include/asm-i386/rmap.h
+++ /dev/null	2003-09-15 06:40:47.000000000 -0700
@@ -1,21 +0,0 @@
-#ifndef _I386_RMAP_H
-#define _I386_RMAP_H
-
-/* nothing to see, move along */
-#include <asm-generic/rmap.h>
-
-#ifdef CONFIG_HIGHPTE
-static inline pte_t *rmap_ptep_map(pte_addr_t pte_paddr)
-{
-	unsigned long pfn = (unsigned long)(pte_paddr >> PAGE_SHIFT);
-	unsigned long off = ((unsigned long)pte_paddr) & ~PAGE_MASK;
-	return (pte_t *)((char *)kmap_atomic(pfn_to_page(pfn), KM_PTE2) + off);
-}
-
-static inline void rmap_ptep_unmap(pte_t *pte)
-{
-	kunmap_atomic(pte, KM_PTE2);
-}
-#endif
-
-#endif
diff -puN include/asm-ia64/pgtable.h~rmap-13-include-asm-deletions include/asm-ia64/pgtable.h
--- 25/include/asm-ia64/pgtable.h~rmap-13-include-asm-deletions	2004-05-22 14:56:23.506517992 -0700
+++ 25-akpm/include/asm-ia64/pgtable.h	2004-05-22 14:56:23.553510848 -0700
@@ -469,8 +469,6 @@ extern void hugetlb_free_pgtables(struct
 	struct vm_area_struct * prev, unsigned long start, unsigned long end);
 #endif
 
-typedef pte_t *pte_addr_t;
-
 /*
  * IA-64 doesn't have any external MMU info: the page tables contain all the necessary
  * information.  However, we use this routine to take care of any (delayed) i-cache
diff -L include/asm-ia64/rmap.h -puN include/asm-ia64/rmap.h~rmap-13-include-asm-deletions /dev/null
--- 25/include/asm-ia64/rmap.h
+++ /dev/null	2003-09-15 06:40:47.000000000 -0700
@@ -1,7 +0,0 @@
-#ifndef _ASM_IA64_RMAP_H
-#define _ASM_IA64_RMAP_H
-
-/* nothing to see, move along */
-#include <asm-generic/rmap.h>
-
-#endif /* _ASM_IA64_RMAP_H */
diff -puN include/asm-m68knommu/pgtable.h~rmap-13-include-asm-deletions include/asm-m68knommu/pgtable.h
--- 25/include/asm-m68knommu/pgtable.h~rmap-13-include-asm-deletions	2004-05-22 14:56:23.509517536 -0700
+++ 25-akpm/include/asm-m68knommu/pgtable.h	2004-05-22 14:56:23.554510696 -0700
@@ -11,8 +11,6 @@
 #include <asm/page.h>
 #include <asm/io.h>
 
-typedef pte_t *pte_addr_t;
-
 /*
  * Trivial page table functions.
  */
diff -L include/asm-m68knommu/rmap.h -puN include/asm-m68knommu/rmap.h~rmap-13-include-asm-deletions /dev/null
--- 25/include/asm-m68knommu/rmap.h
+++ /dev/null	2003-09-15 06:40:47.000000000 -0700
@@ -1,2 +0,0 @@
-/* Do not need anything here */
-
diff -puN include/asm-m68k/pgtable.h~rmap-13-include-asm-deletions include/asm-m68k/pgtable.h
--- 25/include/asm-m68k/pgtable.h~rmap-13-include-asm-deletions	2004-05-22 14:56:23.511517232 -0700
+++ 25-akpm/include/asm-m68k/pgtable.h	2004-05-22 14:56:23.554510696 -0700
@@ -168,8 +168,6 @@ static inline void update_mmu_cache(stru
 	    ? (__pgprot((pgprot_val(prot) & _CACHEMASK040) | _PAGE_NOCACHE_S))	\
 	    : (prot)))
 
-typedef pte_t *pte_addr_t;
-
 #endif /* !__ASSEMBLY__ */
 
 /*
diff -L include/asm-m68k/rmap.h -puN include/asm-m68k/rmap.h~rmap-13-include-asm-deletions /dev/null
--- 25/include/asm-m68k/rmap.h
+++ /dev/null	2003-09-15 06:40:47.000000000 -0700
@@ -1,7 +0,0 @@
-#ifndef _M68K_RMAP_H
-#define _M68K_RMAP_H
-
-/* nothing to see, move along */
-#include <asm-generic/rmap.h>
-
-#endif
diff -puN include/asm-mips/kmap_types.h~rmap-13-include-asm-deletions include/asm-mips/kmap_types.h
--- 25/include/asm-mips/kmap_types.h~rmap-13-include-asm-deletions	2004-05-22 14:56:23.514516776 -0700
+++ 25-akpm/include/asm-mips/kmap_types.h	2004-05-22 14:56:23.555510544 -0700
@@ -19,12 +19,11 @@ D(5)	KM_BIO_SRC_IRQ,
 D(6)	KM_BIO_DST_IRQ,
 D(7)	KM_PTE0,
 D(8)	KM_PTE1,
-D(9)	KM_PTE2,
-D(10)	KM_IRQ0,
-D(11)	KM_IRQ1,
-D(12)	KM_SOFTIRQ0,
-D(13)	KM_SOFTIRQ1,
-D(14)	KM_TYPE_NR
+D(9)	KM_IRQ0,
+D(10)	KM_IRQ1,
+D(11)	KM_SOFTIRQ0,
+D(12)	KM_SOFTIRQ1,
+D(13)	KM_TYPE_NR
 };
 
 #undef D
diff -puN include/asm-mips/pgtable-32.h~rmap-13-include-asm-deletions include/asm-mips/pgtable-32.h
--- 25/include/asm-mips/pgtable-32.h~rmap-13-include-asm-deletions	2004-05-22 14:56:23.515516624 -0700
+++ 25-akpm/include/asm-mips/pgtable-32.h	2004-05-22 14:56:23.555510544 -0700
@@ -216,10 +216,4 @@ static inline pmd_t *pmd_offset(pgd_t *d
 #define __pte_to_swp_entry(pte)	((swp_entry_t) { pte_val(pte) })
 #define __swp_entry_to_pte(x)	((pte_t) { (x).val })
 
-#ifdef CONFIG_64BIT_PHYS_ADDR
-typedef u64 pte_addr_t;
-#else
-typedef pte_t *pte_addr_t;
-#endif
-
 #endif /* _ASM_PGTABLE_32_H */
diff -puN include/asm-mips/pgtable-64.h~rmap-13-include-asm-deletions include/asm-mips/pgtable-64.h
--- 25/include/asm-mips/pgtable-64.h~rmap-13-include-asm-deletions	2004-05-22 14:56:23.516516472 -0700
+++ 25-akpm/include/asm-mips/pgtable-64.h	2004-05-22 14:56:23.555510544 -0700
@@ -214,8 +214,6 @@ static inline pte_t mk_swap_pte(unsigned
 #define __pte_to_swp_entry(pte)	((swp_entry_t) { pte_val(pte) })
 #define __swp_entry_to_pte(x)	((pte_t) { (x).val })
 
-typedef pte_t *pte_addr_t;
-
 /*
  * Used for the b0rked handling of kernel pagetables on the 64-bit kernel.
  */
diff -L include/asm-mips/rmap.h -puN include/asm-mips/rmap.h~rmap-13-include-asm-deletions /dev/null
--- 25/include/asm-mips/rmap.h
+++ /dev/null	2003-09-15 06:40:47.000000000 -0700
@@ -1,7 +0,0 @@
-#ifndef __ASM_RMAP_H
-#define __ASM_RMAP_H
-
-/* nothing to see, move along */
-#include <asm-generic/rmap.h>
-
-#endif /* __ASM_RMAP_H */
diff -puN include/asm-parisc/pgtable.h~rmap-13-include-asm-deletions include/asm-parisc/pgtable.h
--- 25/include/asm-parisc/pgtable.h~rmap-13-include-asm-deletions	2004-05-22 14:56:23.519516016 -0700
+++ 25-akpm/include/asm-parisc/pgtable.h	2004-05-22 14:56:23.556510392 -0700
@@ -488,8 +488,6 @@ static inline void ptep_mkdirty(pte_t *p
 
 #define pte_same(A,B)	(pte_val(A) == pte_val(B))
 
-typedef pte_t *pte_addr_t;
-
 #endif /* !__ASSEMBLY__ */
 
 #define io_remap_page_range remap_page_range
diff -L include/asm-parisc/rmap.h -puN include/asm-parisc/rmap.h~rmap-13-include-asm-deletions /dev/null
--- 25/include/asm-parisc/rmap.h
+++ /dev/null	2003-09-15 06:40:47.000000000 -0700
@@ -1,7 +0,0 @@
-#ifndef _PARISC_RMAP_H
-#define _PARISC_RMAP_H
-
-/* nothing to see, move along */
-#include <asm-generic/rmap.h>
-
-#endif
diff -puN include/asm-ppc64/pgtable.h~rmap-13-include-asm-deletions include/asm-ppc64/pgtable.h
--- 25/include/asm-ppc64/pgtable.h~rmap-13-include-asm-deletions	2004-05-22 14:56:23.521515712 -0700
+++ 25-akpm/include/asm-ppc64/pgtable.h	2004-05-22 14:56:23.557510240 -0700
@@ -471,8 +471,6 @@ extern struct vm_struct * im_get_area(un
 			int region_type);
 unsigned long im_free(void *addr);
 
-typedef pte_t *pte_addr_t;
-
 long pSeries_lpar_hpte_insert(unsigned long hpte_group,
 			      unsigned long va, unsigned long prpn,
 			      int secondary, unsigned long hpteflags,
diff -L include/asm-ppc64/rmap.h -puN include/asm-ppc64/rmap.h~rmap-13-include-asm-deletions /dev/null
--- 25/include/asm-ppc64/rmap.h
+++ /dev/null	2003-09-15 06:40:47.000000000 -0700
@@ -1,9 +0,0 @@
-#ifndef _PPC64_RMAP_H
-#define _PPC64_RMAP_H
-
-/* PPC64 calls pte_alloc() before mem_map[] is setup ... */
-#define BROKEN_PPC_PTE_ALLOC_ONE
-
-#include <asm-generic/rmap.h>
-
-#endif
diff -puN include/asm-ppc/pgtable.h~rmap-13-include-asm-deletions include/asm-ppc/pgtable.h
--- 25/include/asm-ppc/pgtable.h~rmap-13-include-asm-deletions	2004-05-22 14:56:23.523515408 -0700
+++ 25-akpm/include/asm-ppc/pgtable.h	2004-05-22 14:56:23.558510088 -0700
@@ -670,8 +670,6 @@ extern void kernel_set_cachemode (unsign
  */
 #define pgtable_cache_init()	do { } while (0)
 
-typedef pte_t *pte_addr_t;
-
 extern int get_pteptr(struct mm_struct *mm, unsigned long addr, pte_t **ptep);
 
 #endif /* !__ASSEMBLY__ */
diff -L include/asm-ppc/rmap.h -puN include/asm-ppc/rmap.h~rmap-13-include-asm-deletions /dev/null
--- 25/include/asm-ppc/rmap.h
+++ /dev/null	2003-09-15 06:40:47.000000000 -0700
@@ -1,9 +0,0 @@
-#ifndef _PPC_RMAP_H
-#define _PPC_RMAP_H
-
-/* PPC calls pte_alloc() before mem_map[] is setup ... */
-#define BROKEN_PPC_PTE_ALLOC_ONE
-
-#include <asm-generic/rmap.h>
-
-#endif
diff -puN include/asm-s390/pgtable.h~rmap-13-include-asm-deletions include/asm-s390/pgtable.h
--- 25/include/asm-s390/pgtable.h~rmap-13-include-asm-deletions	2004-05-22 14:56:23.526514952 -0700
+++ 25-akpm/include/asm-s390/pgtable.h	2004-05-22 14:56:23.559509936 -0700
@@ -760,8 +760,6 @@ extern inline pte_t mk_swap_pte(unsigned
 #define __pte_to_swp_entry(pte)	((swp_entry_t) { pte_val(pte) })
 #define __swp_entry_to_pte(x)	((pte_t) { (x).val })
 
-typedef pte_t *pte_addr_t;
-
 #ifndef __s390x__
 # define PTE_FILE_MAX_BITS	26
 #else /* __s390x__ */
diff -L include/asm-s390/rmap.h -puN include/asm-s390/rmap.h~rmap-13-include-asm-deletions /dev/null
--- 25/include/asm-s390/rmap.h
+++ /dev/null	2003-09-15 06:40:47.000000000 -0700
@@ -1,7 +0,0 @@
-#ifndef _S390_RMAP_H
-#define _S390_RMAP_H
-
-/* nothing to see, move along */
-#include <asm-generic/rmap.h>
-
-#endif
diff -puN include/asm-sh/pgtable.h~rmap-13-include-asm-deletions include/asm-sh/pgtable.h
--- 25/include/asm-sh/pgtable.h~rmap-13-include-asm-deletions	2004-05-22 14:56:23.528514648 -0700
+++ 25-akpm/include/asm-sh/pgtable.h	2004-05-22 14:56:23.560509784 -0700
@@ -274,8 +274,6 @@ extern void update_mmu_cache(struct vm_a
 
 #define pte_same(A,B)	(pte_val(A) == pte_val(B))
 
-typedef pte_t *pte_addr_t;
-
 #endif /* !__ASSEMBLY__ */
 
 #define kern_addr_valid(addr)	(1)
diff -L include/asm-sh/rmap.h -puN include/asm-sh/rmap.h~rmap-13-include-asm-deletions /dev/null
--- 25/include/asm-sh/rmap.h
+++ /dev/null	2003-09-15 06:40:47.000000000 -0700
@@ -1,7 +0,0 @@
-#ifndef _SH_RMAP_H
-#define _SH_RMAP_H
-
-/* nothing to see, move along */
-#include <asm-generic/rmap.h>
-
-#endif
diff -puN include/asm-sparc64/pgtable.h~rmap-13-include-asm-deletions include/asm-sparc64/pgtable.h
--- 25/include/asm-sparc64/pgtable.h~rmap-13-include-asm-deletions	2004-05-22 14:56:23.531514192 -0700
+++ 25-akpm/include/asm-sparc64/pgtable.h	2004-05-22 14:56:23.561509632 -0700
@@ -386,8 +386,6 @@ extern unsigned long get_fb_unmapped_are
 
 extern void check_pgt_cache(void);
 
-typedef pte_t *pte_addr_t;
-
 #endif /* !(__ASSEMBLY__) */
 
 #endif /* !(_SPARC64_PGTABLE_H) */
diff -L include/asm-sparc64/rmap.h -puN include/asm-sparc64/rmap.h~rmap-13-include-asm-deletions /dev/null
--- 25/include/asm-sparc64/rmap.h
+++ /dev/null	2003-09-15 06:40:47.000000000 -0700
@@ -1,7 +0,0 @@
-#ifndef _SPARC64_RMAP_H
-#define _SPARC64_RMAP_H
-
-/* nothing to see, move along */
-#include <asm-generic/rmap.h>
-
-#endif
diff -puN include/asm-sparc/kmap_types.h~rmap-13-include-asm-deletions include/asm-sparc/kmap_types.h
--- 25/include/asm-sparc/kmap_types.h~rmap-13-include-asm-deletions	2004-05-22 14:56:23.533513888 -0700
+++ 25-akpm/include/asm-sparc/kmap_types.h	2004-05-22 14:56:23.561509632 -0700
@@ -11,7 +11,6 @@ enum km_type {
 	KM_BIO_DST_IRQ,
 	KM_PTE0,
 	KM_PTE1,
-	KM_PTE2,
 	KM_IRQ0,
 	KM_IRQ1,
 	KM_SOFTIRQ0,
diff -puN include/asm-sparc/pgtable.h~rmap-13-include-asm-deletions include/asm-sparc/pgtable.h
--- 25/include/asm-sparc/pgtable.h~rmap-13-include-asm-deletions	2004-05-22 14:56:23.535513584 -0700
+++ 25-akpm/include/asm-sparc/pgtable.h	2004-05-22 14:56:23.562509480 -0700
@@ -497,8 +497,6 @@ extern int io_remap_page_range(struct vm
 
 #include <asm-generic/pgtable.h>
 
-typedef pte_t *pte_addr_t;
-
 #endif /* !(__ASSEMBLY__) */
 
 /* We provide our own get_unmapped_area to cope with VA holes for userland */
diff -L include/asm-sparc/rmap.h -puN include/asm-sparc/rmap.h~rmap-13-include-asm-deletions /dev/null
--- 25/include/asm-sparc/rmap.h
+++ /dev/null	2003-09-15 06:40:47.000000000 -0700
@@ -1,7 +0,0 @@
-#ifndef _SPARC_RMAP_H
-#define _SPARC_RMAP_H
-
-/* nothing to see, move along */
-#include <asm-generic/rmap.h>
-
-#endif
diff -puN include/asm-um/pgtable.h~rmap-13-include-asm-deletions include/asm-um/pgtable.h
--- 25/include/asm-um/pgtable.h~rmap-13-include-asm-deletions	2004-05-22 14:56:23.537513280 -0700
+++ 25-akpm/include/asm-um/pgtable.h	2004-05-22 14:56:23.562509480 -0700
@@ -384,18 +384,6 @@ static inline pmd_t * pmd_offset(pgd_t *
 #define pte_unmap(pte) kunmap_atomic((pte), KM_PTE0)
 #define pte_unmap_nested(pte) kunmap_atomic((pte), KM_PTE1)
 
-#if defined(CONFIG_HIGHPTE) && defined(CONFIG_HIGHMEM4G)
-typedef u32 pte_addr_t;
-#endif
-
-#if defined(CONFIG_HIGHPTE) && defined(CONFIG_HIGHMEM64G)
-typedef u64 pte_addr_t;
-#endif
-
-#if !defined(CONFIG_HIGHPTE)
-typedef pte_t *pte_addr_t;
-#endif
-
 #define update_mmu_cache(vma,address,pte) do ; while (0)
 
 /* Encode and de-code a swap entry */
diff -L include/asm-um/rmap.h -puN include/asm-um/rmap.h~rmap-13-include-asm-deletions /dev/null
--- 25/include/asm-um/rmap.h
+++ /dev/null	2003-09-15 06:40:47.000000000 -0700
@@ -1,6 +0,0 @@
-#ifndef __UM_RMAP_H
-#define __UM_RMAP_H
-
-#include "asm/arch/rmap.h"
-
-#endif
diff -puN include/asm-v850/pgtable.h~rmap-13-include-asm-deletions include/asm-v850/pgtable.h
--- 25/include/asm-v850/pgtable.h~rmap-13-include-asm-deletions	2004-05-22 14:56:23.540512824 -0700
+++ 25-akpm/include/asm-v850/pgtable.h	2004-05-22 14:56:23.563509328 -0700
@@ -5,8 +5,6 @@
 #include <asm/page.h>
 
 
-typedef pte_t *pte_addr_t;
-
 #define pgd_present(pgd)	(1) /* pages are always present on NO_MM */
 #define pgd_none(pgd)		(0)
 #define pgd_bad(pgd)		(0)
diff -L include/asm-v850/rmap.h -puN include/asm-v850/rmap.h~rmap-13-include-asm-deletions /dev/null
--- 25/include/asm-v850/rmap.h
+++ /dev/null	2003-09-15 06:40:47.000000000 -0700
@@ -1 +0,0 @@
-/* Do not need anything here */
diff -puN include/asm-x86_64/pgtable.h~rmap-13-include-asm-deletions include/asm-x86_64/pgtable.h
--- 25/include/asm-x86_64/pgtable.h~rmap-13-include-asm-deletions	2004-05-22 14:56:23.542512520 -0700
+++ 25-akpm/include/asm-x86_64/pgtable.h	2004-05-22 14:56:23.564509176 -0700
@@ -390,8 +390,6 @@ extern inline pte_t pte_modify(pte_t pte
 #define __pte_to_swp_entry(pte)		((swp_entry_t) { pte_val(pte) })
 #define __swp_entry_to_pte(x)		((pte_t) { (x).val })
 
-typedef pte_t *pte_addr_t;
-
 #endif /* !__ASSEMBLY__ */
 
 extern int kern_addr_valid(unsigned long addr); 
diff -L include/asm-x86_64/rmap.h -puN include/asm-x86_64/rmap.h~rmap-13-include-asm-deletions /dev/null
--- 25/include/asm-x86_64/rmap.h
+++ /dev/null	2003-09-15 06:40:47.000000000 -0700
@@ -1,7 +0,0 @@
-#ifndef _X8664_RMAP_H
-#define _X8664_RMAP_H
-
-/* nothing to see, move along */
-#include <asm-generic/rmap.h>
-
-#endif

_
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
