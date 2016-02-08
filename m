Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f179.google.com (mail-ob0-f179.google.com [209.85.214.179])
	by kanga.kvack.org (Postfix) with ESMTP id E6E17830C6
	for <linux-mm@kvack.org>; Mon,  8 Feb 2016 04:21:05 -0500 (EST)
Received: by mail-ob0-f179.google.com with SMTP id is5so143988423obc.0
        for <linux-mm@kvack.org>; Mon, 08 Feb 2016 01:21:05 -0800 (PST)
Received: from e37.co.us.ibm.com (e37.co.us.ibm.com. [32.97.110.158])
        by mx.google.com with ESMTPS id dp7si15252960obb.40.2016.02.08.01.21.04
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 08 Feb 2016 01:21:04 -0800 (PST)
Received: from localhost
	by e37.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Mon, 8 Feb 2016 02:21:04 -0700
Received: from b03cxnp08025.gho.boulder.ibm.com (b03cxnp08025.gho.boulder.ibm.com [9.17.130.17])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id 13B0C1FF0045
	for <linux-mm@kvack.org>; Mon,  8 Feb 2016 02:09:12 -0700 (MST)
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by b03cxnp08025.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u189L2XQ30408918
	for <linux-mm@kvack.org>; Mon, 8 Feb 2016 02:21:02 -0700
Received: from d03av01.boulder.ibm.com (localhost [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u189L1H4027430
	for <linux-mm@kvack.org>; Mon, 8 Feb 2016 02:21:01 -0700
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH V2 04/29] powerpc/mm: Copy pgalloc (part 1)
Date: Mon,  8 Feb 2016 14:50:16 +0530
Message-Id: <1454923241-6681-5-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1454923241-6681-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1454923241-6681-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

cp pgalloc-32.h book3s/32/pgalloc.h
cp pgalloc-64.h book3s/64/pgalloc.h

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 arch/powerpc/include/asm/book3s/32/pgalloc.h | 109 +++++++++++
 arch/powerpc/include/asm/book3s/64/pgalloc.h | 262 +++++++++++++++++++++++++++
 2 files changed, 371 insertions(+)
 create mode 100644 arch/powerpc/include/asm/book3s/32/pgalloc.h
 create mode 100644 arch/powerpc/include/asm/book3s/64/pgalloc.h

diff --git a/arch/powerpc/include/asm/book3s/32/pgalloc.h b/arch/powerpc/include/asm/book3s/32/pgalloc.h
new file mode 100644
index 000000000000..76d6b9e0c8a9
--- /dev/null
+++ b/arch/powerpc/include/asm/book3s/32/pgalloc.h
@@ -0,0 +1,109 @@
+#ifndef _ASM_POWERPC_PGALLOC_32_H
+#define _ASM_POWERPC_PGALLOC_32_H
+
+#include <linux/threads.h>
+
+/* For 32-bit, all levels of page tables are just drawn from get_free_page() */
+#define MAX_PGTABLE_INDEX_SIZE	0
+
+extern void __bad_pte(pmd_t *pmd);
+
+extern pgd_t *pgd_alloc(struct mm_struct *mm);
+extern void pgd_free(struct mm_struct *mm, pgd_t *pgd);
+
+/*
+ * We don't have any real pmd's, and this code never triggers because
+ * the pgd will always be present..
+ */
+/* #define pmd_alloc_one(mm,address)       ({ BUG(); ((pmd_t *)2); }) */
+#define pmd_free(mm, x) 		do { } while (0)
+#define __pmd_free_tlb(tlb,x,a)		do { } while (0)
+/* #define pgd_populate(mm, pmd, pte)      BUG() */
+
+#ifndef CONFIG_BOOKE
+
+static inline void pmd_populate_kernel(struct mm_struct *mm, pmd_t *pmdp,
+				       pte_t *pte)
+{
+	*pmdp = __pmd(__pa(pte) | _PMD_PRESENT);
+}
+
+static inline void pmd_populate(struct mm_struct *mm, pmd_t *pmdp,
+				pgtable_t pte_page)
+{
+	*pmdp = __pmd((page_to_pfn(pte_page) << PAGE_SHIFT) | _PMD_PRESENT);
+}
+
+#define pmd_pgtable(pmd) pmd_page(pmd)
+#else
+
+static inline void pmd_populate_kernel(struct mm_struct *mm, pmd_t *pmdp,
+				       pte_t *pte)
+{
+	*pmdp = __pmd((unsigned long)pte | _PMD_PRESENT);
+}
+
+static inline void pmd_populate(struct mm_struct *mm, pmd_t *pmdp,
+				pgtable_t pte_page)
+{
+	*pmdp = __pmd((unsigned long)lowmem_page_address(pte_page) | _PMD_PRESENT);
+}
+
+#define pmd_pgtable(pmd) pmd_page(pmd)
+#endif
+
+extern pte_t *pte_alloc_one_kernel(struct mm_struct *mm, unsigned long addr);
+extern pgtable_t pte_alloc_one(struct mm_struct *mm, unsigned long addr);
+
+static inline void pte_free_kernel(struct mm_struct *mm, pte_t *pte)
+{
+	free_page((unsigned long)pte);
+}
+
+static inline void pte_free(struct mm_struct *mm, pgtable_t ptepage)
+{
+	pgtable_page_dtor(ptepage);
+	__free_page(ptepage);
+}
+
+static inline void pgtable_free(void *table, unsigned index_size)
+{
+	BUG_ON(index_size); /* 32-bit doesn't use this */
+	free_page((unsigned long)table);
+}
+
+#define check_pgt_cache()	do { } while (0)
+
+#ifdef CONFIG_SMP
+static inline void pgtable_free_tlb(struct mmu_gather *tlb,
+				    void *table, int shift)
+{
+	unsigned long pgf = (unsigned long)table;
+	BUG_ON(shift > MAX_PGTABLE_INDEX_SIZE);
+	pgf |= shift;
+	tlb_remove_table(tlb, (void *)pgf);
+}
+
+static inline void __tlb_remove_table(void *_table)
+{
+	void *table = (void *)((unsigned long)_table & ~MAX_PGTABLE_INDEX_SIZE);
+	unsigned shift = (unsigned long)_table & MAX_PGTABLE_INDEX_SIZE;
+
+	pgtable_free(table, shift);
+}
+#else
+static inline void pgtable_free_tlb(struct mmu_gather *tlb,
+				    void *table, int shift)
+{
+	pgtable_free(table, shift);
+}
+#endif
+
+static inline void __pte_free_tlb(struct mmu_gather *tlb, pgtable_t table,
+				  unsigned long address)
+{
+	tlb_flush_pgtable(tlb, address);
+	pgtable_page_dtor(table);
+	pgtable_free_tlb(tlb, page_address(table), 0);
+}
+#endif /* _ASM_POWERPC_PGALLOC_32_H */
diff --git a/arch/powerpc/include/asm/book3s/64/pgalloc.h b/arch/powerpc/include/asm/book3s/64/pgalloc.h
new file mode 100644
index 000000000000..014489a619d0
--- /dev/null
+++ b/arch/powerpc/include/asm/book3s/64/pgalloc.h
@@ -0,0 +1,262 @@
+#ifndef _ASM_POWERPC_PGALLOC_64_H
+#define _ASM_POWERPC_PGALLOC_64_H
+/*
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; either version
+ * 2 of the License, or (at your option) any later version.
+ */
+
+#include <linux/slab.h>
+#include <linux/cpumask.h>
+#include <linux/percpu.h>
+
+struct vmemmap_backing {
+	struct vmemmap_backing *list;
+	unsigned long phys;
+	unsigned long virt_addr;
+};
+extern struct vmemmap_backing *vmemmap_list;
+
+/*
+ * Functions that deal with pagetables that could be at any level of
+ * the table need to be passed an "index_size" so they know how to
+ * handle allocation.  For PTE pages (which are linked to a struct
+ * page for now, and drawn from the main get_free_pages() pool), the
+ * allocation size will be (2^index_size * sizeof(pointer)) and
+ * allocations are drawn from the kmem_cache in PGT_CACHE(index_size).
+ *
+ * The maximum index size needs to be big enough to allow any
+ * pagetable sizes we need, but small enough to fit in the low bits of
+ * any page table pointer.  In other words all pagetables, even tiny
+ * ones, must be aligned to allow at least enough low 0 bits to
+ * contain this value.  This value is also used as a mask, so it must
+ * be one less than a power of two.
+ */
+#define MAX_PGTABLE_INDEX_SIZE	0xf
+
+extern struct kmem_cache *pgtable_cache[];
+#define PGT_CACHE(shift) ({				\
+			BUG_ON(!(shift));		\
+			pgtable_cache[(shift) - 1];	\
+		})
+
+static inline pgd_t *pgd_alloc(struct mm_struct *mm)
+{
+	return kmem_cache_alloc(PGT_CACHE(PGD_INDEX_SIZE), GFP_KERNEL);
+}
+
+static inline void pgd_free(struct mm_struct *mm, pgd_t *pgd)
+{
+	kmem_cache_free(PGT_CACHE(PGD_INDEX_SIZE), pgd);
+}
+
+#ifndef CONFIG_PPC_64K_PAGES
+
+#define pgd_populate(MM, PGD, PUD)	pgd_set(PGD, (unsigned long)PUD)
+
+static inline pud_t *pud_alloc_one(struct mm_struct *mm, unsigned long addr)
+{
+	return kmem_cache_alloc(PGT_CACHE(PUD_INDEX_SIZE),
+				GFP_KERNEL|__GFP_REPEAT);
+}
+
+static inline void pud_free(struct mm_struct *mm, pud_t *pud)
+{
+	kmem_cache_free(PGT_CACHE(PUD_INDEX_SIZE), pud);
+}
+
+static inline void pud_populate(struct mm_struct *mm, pud_t *pud, pmd_t *pmd)
+{
+	pud_set(pud, (unsigned long)pmd);
+}
+
+static inline void pmd_populate_kernel(struct mm_struct *mm, pmd_t *pmd,
+				       pte_t *pte)
+{
+	pmd_set(pmd, (unsigned long)pte);
+}
+
+static inline void pmd_populate(struct mm_struct *mm, pmd_t *pmd,
+				pgtable_t pte_page)
+{
+	pmd_set(pmd, (unsigned long)page_address(pte_page));
+}
+
+#define pmd_pgtable(pmd) pmd_page(pmd)
+
+static inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm,
+					  unsigned long address)
+{
+	return (pte_t *)__get_free_page(GFP_KERNEL | __GFP_REPEAT | __GFP_ZERO);
+}
+
+static inline pgtable_t pte_alloc_one(struct mm_struct *mm,
+				      unsigned long address)
+{
+	struct page *page;
+	pte_t *pte;
+
+	pte = pte_alloc_one_kernel(mm, address);
+	if (!pte)
+		return NULL;
+	page = virt_to_page(pte);
+	if (!pgtable_page_ctor(page)) {
+		__free_page(page);
+		return NULL;
+	}
+	return page;
+}
+
+static inline void pte_free_kernel(struct mm_struct *mm, pte_t *pte)
+{
+	free_page((unsigned long)pte);
+}
+
+static inline void pte_free(struct mm_struct *mm, pgtable_t ptepage)
+{
+	pgtable_page_dtor(ptepage);
+	__free_page(ptepage);
+}
+
+static inline void pgtable_free(void *table, unsigned index_size)
+{
+	if (!index_size)
+		free_page((unsigned long)table);
+	else {
+		BUG_ON(index_size > MAX_PGTABLE_INDEX_SIZE);
+		kmem_cache_free(PGT_CACHE(index_size), table);
+	}
+}
+
+#ifdef CONFIG_SMP
+static inline void pgtable_free_tlb(struct mmu_gather *tlb,
+				    void *table, int shift)
+{
+	unsigned long pgf = (unsigned long)table;
+	BUG_ON(shift > MAX_PGTABLE_INDEX_SIZE);
+	pgf |= shift;
+	tlb_remove_table(tlb, (void *)pgf);
+}
+
+static inline void __tlb_remove_table(void *_table)
+{
+	void *table = (void *)((unsigned long)_table & ~MAX_PGTABLE_INDEX_SIZE);
+	unsigned shift = (unsigned long)_table & MAX_PGTABLE_INDEX_SIZE;
+
+	pgtable_free(table, shift);
+}
+#else /* !CONFIG_SMP */
+static inline void pgtable_free_tlb(struct mmu_gather *tlb,
+				    void *table, int shift)
+{
+	pgtable_free(table, shift);
+}
+#endif /* CONFIG_SMP */
+
+static inline void __pte_free_tlb(struct mmu_gather *tlb, pgtable_t table,
+				  unsigned long address)
+{
+	tlb_flush_pgtable(tlb, address);
+	pgtable_page_dtor(table);
+	pgtable_free_tlb(tlb, page_address(table), 0);
+}
+
+#else /* if CONFIG_PPC_64K_PAGES */
+
+extern pte_t *page_table_alloc(struct mm_struct *, unsigned long, int);
+extern void page_table_free(struct mm_struct *, unsigned long *, int);
+extern void pgtable_free_tlb(struct mmu_gather *tlb, void *table, int shift);
+#ifdef CONFIG_SMP
+extern void __tlb_remove_table(void *_table);
+#endif
+
+#ifndef __PAGETABLE_PUD_FOLDED
+/* book3s 64 is 4 level page table */
+#define pgd_populate(MM, PGD, PUD)	pgd_set(PGD, PUD)
+static inline pud_t *pud_alloc_one(struct mm_struct *mm, unsigned long addr)
+{
+	return kmem_cache_alloc(PGT_CACHE(PUD_INDEX_SIZE),
+				GFP_KERNEL|__GFP_REPEAT);
+}
+
+static inline void pud_free(struct mm_struct *mm, pud_t *pud)
+{
+	kmem_cache_free(PGT_CACHE(PUD_INDEX_SIZE), pud);
+}
+#endif
+
+static inline void pud_populate(struct mm_struct *mm, pud_t *pud, pmd_t *pmd)
+{
+	pud_set(pud, (unsigned long)pmd);
+}
+
+static inline void pmd_populate_kernel(struct mm_struct *mm, pmd_t *pmd,
+				       pte_t *pte)
+{
+	pmd_set(pmd, (unsigned long)pte);
+}
+
+static inline void pmd_populate(struct mm_struct *mm, pmd_t *pmd,
+				pgtable_t pte_page)
+{
+	pmd_set(pmd, (unsigned long)pte_page);
+}
+
+static inline pgtable_t pmd_pgtable(pmd_t pmd)
+{
+	return (pgtable_t)(pmd_val(pmd) & ~PMD_MASKED_BITS);
+}
+
+static inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm,
+					  unsigned long address)
+{
+	return (pte_t *)page_table_alloc(mm, address, 1);
+}
+
+static inline pgtable_t pte_alloc_one(struct mm_struct *mm,
+					unsigned long address)
+{
+	return (pgtable_t)page_table_alloc(mm, address, 0);
+}
+
+static inline void pte_free_kernel(struct mm_struct *mm, pte_t *pte)
+{
+	page_table_free(mm, (unsigned long *)pte, 1);
+}
+
+static inline void pte_free(struct mm_struct *mm, pgtable_t ptepage)
+{
+	page_table_free(mm, (unsigned long *)ptepage, 0);
+}
+
+static inline void __pte_free_tlb(struct mmu_gather *tlb, pgtable_t table,
+				  unsigned long address)
+{
+	tlb_flush_pgtable(tlb, address);
+	pgtable_free_tlb(tlb, table, 0);
+}
+#endif /* CONFIG_PPC_64K_PAGES */
+
+static inline pmd_t *pmd_alloc_one(struct mm_struct *mm, unsigned long addr)
+{
+	return kmem_cache_alloc(PGT_CACHE(PMD_CACHE_INDEX),
+				GFP_KERNEL|__GFP_REPEAT);
+}
+
+static inline void pmd_free(struct mm_struct *mm, pmd_t *pmd)
+{
+	kmem_cache_free(PGT_CACHE(PMD_CACHE_INDEX), pmd);
+}
+
+#define __pmd_free_tlb(tlb, pmd, addr)		      \
+	pgtable_free_tlb(tlb, pmd, PMD_CACHE_INDEX)
+#ifndef __PAGETABLE_PUD_FOLDED
+#define __pud_free_tlb(tlb, pud, addr)		      \
+	pgtable_free_tlb(tlb, pud, PUD_INDEX_SIZE)
+
+#endif /* __PAGETABLE_PUD_FOLDED */
+
+#define check_pgt_cache()	do { } while (0)
+
+#endif /* _ASM_POWERPC_PGALLOC_64_H */
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
