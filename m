Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f174.google.com (mail-ob0-f174.google.com [209.85.214.174])
	by kanga.kvack.org (Postfix) with ESMTP id 792BA830C6
	for <linux-mm@kvack.org>; Mon,  8 Feb 2016 04:21:54 -0500 (EST)
Received: by mail-ob0-f174.google.com with SMTP id wb13so146224880obb.1
        for <linux-mm@kvack.org>; Mon, 08 Feb 2016 01:21:54 -0800 (PST)
Received: from e32.co.us.ibm.com (e32.co.us.ibm.com. [32.97.110.150])
        by mx.google.com with ESMTPS id pr2si15230017oeb.0.2016.02.08.01.21.53
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 08 Feb 2016 01:21:53 -0800 (PST)
Received: from localhost
	by e32.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Mon, 8 Feb 2016 02:21:53 -0700
Received: from b01cxnp22033.gho.pok.ibm.com (b01cxnp22033.gho.pok.ibm.com [9.57.198.23])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id A05B71FF0041
	for <linux-mm@kvack.org>; Mon,  8 Feb 2016 02:10:00 -0700 (MST)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by b01cxnp22033.gho.pok.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u189Lod433751126
	for <linux-mm@kvack.org>; Mon, 8 Feb 2016 09:21:50 GMT
Received: from d01av04.pok.ibm.com (localhost [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u189LnJB018610
	for <linux-mm@kvack.org>; Mon, 8 Feb 2016 04:21:50 -0500
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH V2 27/29] powerpc/mm: Hash linux abstraction for page table allocator
Date: Mon,  8 Feb 2016 14:50:39 +0530
Message-Id: <1454923241-6681-28-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1454923241-6681-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1454923241-6681-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 .../include/asm/book3s/64/pgalloc-hash-4k.h        |  26 ++---
 .../include/asm/book3s/64/pgalloc-hash-64k.h       |  23 ++--
 arch/powerpc/include/asm/book3s/64/pgalloc-hash.h  |  36 +++++--
 arch/powerpc/include/asm/book3s/64/pgalloc.h       | 118 +++++++++++++++++----
 4 files changed, 148 insertions(+), 55 deletions(-)

diff --git a/arch/powerpc/include/asm/book3s/64/pgalloc-hash-4k.h b/arch/powerpc/include/asm/book3s/64/pgalloc-hash-4k.h
index d1d67e585ad4..ae6480e2111b 100644
--- a/arch/powerpc/include/asm/book3s/64/pgalloc-hash-4k.h
+++ b/arch/powerpc/include/asm/book3s/64/pgalloc-hash-4k.h
@@ -1,30 +1,30 @@
 #ifndef _ASM_POWERPC_BOOK3S_64_PGALLOC_HASH_4K_H
 #define _ASM_POWERPC_BOOK3S_64_PGALLOC_HASH_4K_H
 
-static inline void pmd_populate(struct mm_struct *mm, pmd_t *pmd,
+static inline void hlpmd_populate(struct mm_struct *mm, pmd_t *pmd,
 				pgtable_t pte_page)
 {
 	pmd_set(pmd, (unsigned long)page_address(pte_page));
 }
 
-static inline pgtable_t pmd_pgtable(pmd_t pmd)
+static inline pgtable_t hlpmd_pgtable(pmd_t pmd)
 {
 	return pmd_page(pmd);
 }
 
-static inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm,
-					  unsigned long address)
+static inline pte_t *hlpte_alloc_one_kernel(struct mm_struct *mm,
+					    unsigned long address)
 {
 	return (pte_t *)__get_free_page(GFP_KERNEL | __GFP_REPEAT | __GFP_ZERO);
 }
 
-static inline pgtable_t pte_alloc_one(struct mm_struct *mm,
-				      unsigned long address)
+static inline pgtable_t hlpte_alloc_one(struct mm_struct *mm,
+					unsigned long address)
 {
 	struct page *page;
 	pte_t *pte;
 
-	pte = pte_alloc_one_kernel(mm, address);
+	pte = hlpte_alloc_one_kernel(mm, address);
 	if (!pte)
 		return NULL;
 	page = virt_to_page(pte);
@@ -35,12 +35,12 @@ static inline pgtable_t pte_alloc_one(struct mm_struct *mm,
 	return page;
 }
 
-static inline void pte_free_kernel(struct mm_struct *mm, pte_t *pte)
+static inline void hlpte_free_kernel(struct mm_struct *mm, pte_t *pte)
 {
 	free_page((unsigned long)pte);
 }
 
-static inline void pte_free(struct mm_struct *mm, pgtable_t ptepage)
+static inline void hlpte_free(struct mm_struct *mm, pgtable_t ptepage)
 {
 	pgtable_page_dtor(ptepage);
 	__free_page(ptepage);
@@ -58,7 +58,7 @@ static inline void pgtable_free(void *table, unsigned index_size)
 
 #ifdef CONFIG_SMP
 static inline void pgtable_free_tlb(struct mmu_gather *tlb,
-				    void *table, int shift)
+				      void *table, int shift)
 {
 	unsigned long pgf = (unsigned long)table;
 	BUG_ON(shift > MAX_PGTABLE_INDEX_SIZE);
@@ -75,14 +75,14 @@ static inline void __tlb_remove_table(void *_table)
 }
 #else /* !CONFIG_SMP */
 static inline void pgtable_free_tlb(struct mmu_gather *tlb,
-				    void *table, int shift)
+				      void *table, int shift)
 {
 	pgtable_free(table, shift);
 }
 #endif /* CONFIG_SMP */
 
-static inline void __pte_free_tlb(struct mmu_gather *tlb, pgtable_t table,
-				  unsigned long address)
+static inline void __hlpte_free_tlb(struct mmu_gather *tlb, pgtable_t table,
+				    unsigned long address)
 {
 	tlb_flush_pgtable(tlb, address);
 	pgtable_page_dtor(table);
diff --git a/arch/powerpc/include/asm/book3s/64/pgalloc-hash-64k.h b/arch/powerpc/include/asm/book3s/64/pgalloc-hash-64k.h
index e2dab4f64316..cb382773397f 100644
--- a/arch/powerpc/include/asm/book3s/64/pgalloc-hash-64k.h
+++ b/arch/powerpc/include/asm/book3s/64/pgalloc-hash-64k.h
@@ -4,45 +4,42 @@
 extern pte_t *page_table_alloc(struct mm_struct *, unsigned long, int);
 extern void page_table_free(struct mm_struct *, unsigned long *, int);
 extern void pgtable_free_tlb(struct mmu_gather *tlb, void *table, int shift);
-#ifdef CONFIG_SMP
-extern void __tlb_remove_table(void *_table);
-#endif
 
-static inline void pmd_populate(struct mm_struct *mm, pmd_t *pmd,
-				pgtable_t pte_page)
+static inline void hlpmd_populate(struct mm_struct *mm, pmd_t *pmd,
+				  pgtable_t pte_page)
 {
 	pmd_set(pmd, (unsigned long)pte_page);
 }
 
-static inline pgtable_t pmd_pgtable(pmd_t pmd)
+static inline pgtable_t hlpmd_pgtable(pmd_t pmd)
 {
 	return (pgtable_t)pmd_page_vaddr(pmd);
 }
 
-static inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm,
-					  unsigned long address)
+static inline pte_t *hlpte_alloc_one_kernel(struct mm_struct *mm,
+					    unsigned long address)
 {
 	return (pte_t *)page_table_alloc(mm, address, 1);
 }
 
-static inline pgtable_t pte_alloc_one(struct mm_struct *mm,
+static inline pgtable_t hlpte_alloc_one(struct mm_struct *mm,
 					unsigned long address)
 {
 	return (pgtable_t)page_table_alloc(mm, address, 0);
 }
 
-static inline void pte_free_kernel(struct mm_struct *mm, pte_t *pte)
+static inline void hlpte_free_kernel(struct mm_struct *mm, pte_t *pte)
 {
 	page_table_free(mm, (unsigned long *)pte, 1);
 }
 
-static inline void pte_free(struct mm_struct *mm, pgtable_t ptepage)
+static inline void hlpte_free(struct mm_struct *mm, pgtable_t ptepage)
 {
 	page_table_free(mm, (unsigned long *)ptepage, 0);
 }
 
-static inline void __pte_free_tlb(struct mmu_gather *tlb, pgtable_t table,
-				  unsigned long address)
+static inline void __hlpte_free_tlb(struct mmu_gather *tlb, pgtable_t table,
+				    unsigned long address)
 {
 	tlb_flush_pgtable(tlb, address);
 	pgtable_free_tlb(tlb, table, 0);
diff --git a/arch/powerpc/include/asm/book3s/64/pgalloc-hash.h b/arch/powerpc/include/asm/book3s/64/pgalloc-hash.h
index 1dcfe7b75f06..7c5bdc558786 100644
--- a/arch/powerpc/include/asm/book3s/64/pgalloc-hash.h
+++ b/arch/powerpc/include/asm/book3s/64/pgalloc-hash.h
@@ -13,46 +13,62 @@
 #include <asm/book3s/64/pgalloc-hash-4k.h>
 #endif
 
-static inline pgd_t *pgd_alloc(struct mm_struct *mm)
+static inline pgd_t *hlpgd_alloc(struct mm_struct *mm)
 {
 	return kmem_cache_alloc(PGT_CACHE(H_PGD_INDEX_SIZE), GFP_KERNEL);
 }
 
-static inline void pgd_free(struct mm_struct *mm, pgd_t *pgd)
+static inline void hlpgd_populate(struct mm_struct *mm, pgd_t *pgd, pud_t *pud)
+{
+	*pgd = __pgd((unsigned long)pud);
+}
+
+static inline void hlpgd_free(struct mm_struct *mm, pgd_t *pgd)
 {
 	kmem_cache_free(PGT_CACHE(H_PGD_INDEX_SIZE), pgd);
 }
 
-static inline pud_t *pud_alloc_one(struct mm_struct *mm, unsigned long addr)
+static inline pud_t *hlpud_alloc_one(struct mm_struct *mm, unsigned long addr)
 {
 	return kmem_cache_alloc(PGT_CACHE(H_PUD_INDEX_SIZE),
 				GFP_KERNEL|__GFP_REPEAT);
 }
 
-static inline void pud_free(struct mm_struct *mm, pud_t *pud)
+static inline void hlpud_populate(struct mm_struct *mm, pud_t *pud, pmd_t *pmd)
+{
+	*pud = __pud((unsigned long)pmd);
+}
+
+static inline void hlpud_free(struct mm_struct *mm, pud_t *pud)
 {
 	kmem_cache_free(PGT_CACHE(H_PUD_INDEX_SIZE), pud);
 }
 
-static inline pmd_t *pmd_alloc_one(struct mm_struct *mm, unsigned long addr)
+static inline pmd_t *hlpmd_alloc_one(struct mm_struct *mm, unsigned long addr)
 {
 	return kmem_cache_alloc(PGT_CACHE(H_PMD_CACHE_INDEX),
 				GFP_KERNEL|__GFP_REPEAT);
 }
 
-static inline void pmd_free(struct mm_struct *mm, pmd_t *pmd)
+static inline void hlpmd_populate_kernel(struct mm_struct *mm, pmd_t *pmd,
+					 pte_t *pte)
+{
+	*pmd = __pmd((unsigned long)pte);
+}
+
+static inline void hlpmd_free(struct mm_struct *mm, pmd_t *pmd)
 {
 	kmem_cache_free(PGT_CACHE(H_PMD_CACHE_INDEX), pmd);
 }
 
-static inline void __pmd_free_tlb(struct mmu_gather *tlb, pmd_t *pmd,
-				unsigned long address)
+static inline void __hlpmd_free_tlb(struct mmu_gather *tlb, pmd_t *pmd,
+				    unsigned long address)
 {
 	return pgtable_free_tlb(tlb, pmd, H_PMD_CACHE_INDEX);
 }
 
-static inline void __pud_free_tlb(struct mmu_gather *tlb, pud_t *pud,
-				unsigned long address)
+static inline void __hlpud_free_tlb(struct mmu_gather *tlb, pud_t *pud,
+				    unsigned long address)
 {
 	pgtable_free_tlb(tlb, pud, H_PUD_INDEX_SIZE);
 }
diff --git a/arch/powerpc/include/asm/book3s/64/pgalloc.h b/arch/powerpc/include/asm/book3s/64/pgalloc.h
index fa2ddda14b3d..c16d5ad414b8 100644
--- a/arch/powerpc/include/asm/book3s/64/pgalloc.h
+++ b/arch/powerpc/include/asm/book3s/64/pgalloc.h
@@ -11,18 +11,6 @@
 #include <linux/cpumask.h>
 #include <linux/percpu.h>
 
-struct vmemmap_backing {
-	struct vmemmap_backing *list;
-	unsigned long phys;
-	unsigned long virt_addr;
-};
-extern struct vmemmap_backing *vmemmap_list;
-
-static inline void check_pgt_cache(void)
-{
-
-}
-
 /*
  * Functions that deal with pagetables that could be at any level of
  * the table need to be passed an "index_size" so they know how to
@@ -46,26 +34,37 @@ extern struct kmem_cache *pgtable_cache[];
 			pgtable_cache[(shift) - 1];	\
 		})
 
+#include <asm/book3s/64/pgalloc-hash.h>
+
+struct vmemmap_backing {
+	struct vmemmap_backing *list;
+	unsigned long phys;
+	unsigned long virt_addr;
+};
+extern struct vmemmap_backing *vmemmap_list;
+extern void __tlb_remove_table(void *table);
+
+static inline void check_pgt_cache(void)
+{
+
+}
+
 static inline void pgd_populate(struct mm_struct *mm, pgd_t *pgd, pud_t *pud)
 {
-	pgd_set(pgd, (unsigned long)pud);
+	return hlpgd_populate(mm, pgd, pud);
 }
 
 static inline void pud_populate(struct mm_struct *mm, pud_t *pud, pmd_t *pmd)
 {
-	pud_set(pud, (unsigned long)pmd);
+	return hlpud_populate(mm, pud, pmd);
 }
 
 static inline void pmd_populate_kernel(struct mm_struct *mm, pmd_t *pmd,
 				       pte_t *pte)
 {
-	pmd_set(pmd, (unsigned long)pte);
+	hlpmd_populate_kernel(mm, pmd, pte);
 }
 
-#ifdef CONFIG_PPC_STD_MMU_64
-#include <asm/book3s/64/pgalloc-hash.h>
-#endif
-
 #ifdef CONFIG_HUGETLB_PAGE
 static inline void hugetlb_free_pgd_range(struct mmu_gather *tlb, unsigned long addr,
 					  unsigned long end, unsigned long floor,
@@ -75,4 +74,85 @@ static inline void hugetlb_free_pgd_range(struct mmu_gather *tlb, unsigned long
 }
 #endif
 
+static inline pgd_t *pgd_alloc(struct mm_struct *mm)
+{
+	return hlpgd_alloc(mm);
+}
+
+static inline void pgd_free(struct mm_struct *mm, pgd_t *pgd)
+{
+	return hlpgd_free(mm, pgd);
+}
+
+static inline pud_t *pud_alloc_one(struct mm_struct *mm, unsigned long addr)
+{
+	return hlpud_alloc_one(mm, addr);
+}
+
+static inline void pud_free(struct mm_struct *mm, pud_t *pud)
+{
+	return hlpud_free(mm, pud);
+}
+
+static inline pmd_t *pmd_alloc_one(struct mm_struct *mm, unsigned long addr)
+{
+	return hlpmd_alloc_one(mm, addr);
+}
+
+static inline void pmd_free(struct mm_struct *mm, pmd_t *pmd)
+{
+	return hlpmd_free(mm, pmd);
+}
+
+static inline void __pmd_free_tlb(struct mmu_gather *tlb, pmd_t *pmd,
+				  unsigned long address)
+{
+	return __hlpmd_free_tlb(tlb, pmd, address);
+}
+
+static inline void __pud_free_tlb(struct mmu_gather *tlb, pud_t *pud,
+				  unsigned long address)
+{
+	return __hlpud_free_tlb(tlb, pud, address);
+}
+
+static inline void pmd_populate(struct mm_struct *mm, pmd_t *pmd,
+				pgtable_t pte_page)
+{
+	return hlpmd_populate(mm, pmd, pte_page);
+}
+
+static inline pgtable_t pmd_pgtable(pmd_t pmd)
+{
+	return hlpmd_pgtable(pmd);
+}
+
+static inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm,
+					  unsigned long address)
+{
+	return hlpte_alloc_one_kernel(mm, address);
+}
+
+static inline pgtable_t pte_alloc_one(struct mm_struct *mm,
+				      unsigned long address)
+{
+	return hlpte_alloc_one(mm, address);
+}
+
+static inline void pte_free_kernel(struct mm_struct *mm, pte_t *pte)
+{
+	return hlpte_free_kernel(mm, pte);
+}
+
+static inline void pte_free(struct mm_struct *mm, pgtable_t ptepage)
+{
+	return hlpte_free(mm, ptepage);
+}
+
+static inline void __pte_free_tlb(struct mmu_gather *tlb, pgtable_t table,
+				  unsigned long address)
+{
+	return __hlpte_free_tlb(tlb, table, address);
+}
+
 #endif /* __ASM_POWERPC_BOOK3S_64_PGALLOC_H */
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
