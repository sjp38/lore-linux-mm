Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id 6F5E56B003C
	for <linux-mm@kvack.org>; Thu,  4 Apr 2013 01:58:23 -0400 (EDT)
Received: from /spool/local
	by e28smtp04.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Thu, 4 Apr 2013 11:24:32 +0530
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id DCA14125804F
	for <linux-mm@kvack.org>; Thu,  4 Apr 2013 11:29:35 +0530 (IST)
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r345w9w765536066
	for <linux-mm@kvack.org>; Thu, 4 Apr 2013 11:28:09 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r345wDIt026462
	for <linux-mm@kvack.org>; Thu, 4 Apr 2013 05:58:14 GMT
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH -V5 05/25] powerpc: Move the pte free routines from common header
Date: Thu,  4 Apr 2013 11:27:43 +0530
Message-Id: <1365055083-31956-6-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1365055083-31956-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1365055083-31956-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: benh@kernel.crashing.org, paulus@samba.org
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

This patch moves the common code to 32/64 bit headers and also duplicate
4K_PAGES and 64K_PAGES section. We will later change the 64 bit 64K_PAGES
version to support smaller PTE fragments. The patch doesn't introduce
any functional changes.

Acked-by: Paul Mackerras <paulus@samba.org>
Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 arch/powerpc/include/asm/pgalloc-32.h |   45 ++++++++++
 arch/powerpc/include/asm/pgalloc-64.h |  157 ++++++++++++++++++++++++++++++---
 arch/powerpc/include/asm/pgalloc.h    |   46 +---------
 3 files changed, 189 insertions(+), 59 deletions(-)

diff --git a/arch/powerpc/include/asm/pgalloc-32.h b/arch/powerpc/include/asm/pgalloc-32.h
index 580cf73..27b2386 100644
--- a/arch/powerpc/include/asm/pgalloc-32.h
+++ b/arch/powerpc/include/asm/pgalloc-32.h
@@ -37,6 +37,17 @@ extern void pgd_free(struct mm_struct *mm, pgd_t *pgd);
 extern pte_t *pte_alloc_one_kernel(struct mm_struct *mm, unsigned long addr);
 extern pgtable_t pte_alloc_one(struct mm_struct *mm, unsigned long addr);
 
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
 static inline void pgtable_free(void *table, unsigned index_size)
 {
 	BUG_ON(index_size); /* 32-bit doesn't use this */
@@ -45,4 +56,38 @@ static inline void pgtable_free(void *table, unsigned index_size)
 
 #define check_pgt_cache()	do { } while (0)
 
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
+	struct page *page = page_address(table);
+
+	tlb_flush_pgtable(tlb, address);
+	pgtable_page_dtor(page);
+	pgtable_free_tlb(tlb, page, 0);
+}
 #endif /* _ASM_POWERPC_PGALLOC_32_H */
diff --git a/arch/powerpc/include/asm/pgalloc-64.h b/arch/powerpc/include/asm/pgalloc-64.h
index 292725c..cdbf555 100644
--- a/arch/powerpc/include/asm/pgalloc-64.h
+++ b/arch/powerpc/include/asm/pgalloc-64.h
@@ -72,8 +72,83 @@ static inline void pud_populate(struct mm_struct *mm, pud_t *pud, pmd_t *pmd)
 #define pmd_populate_kernel(mm, pmd, pte) pmd_set(pmd, (unsigned long)(pte))
 #define pmd_pgtable(pmd) pmd_page(pmd)
 
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
+	pgtable_page_ctor(page);
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
+	struct page *page = page_address(table);
+
+	tlb_flush_pgtable(tlb, address);
+	pgtable_page_dtor(page);
+	pgtable_free_tlb(tlb, page, 0);
+}
 
-#else /* CONFIG_PPC_64K_PAGES */
+#else /* if CONFIG_PPC_64K_PAGES */
 
 #define pud_populate(mm, pud, pmd)	pud_set(pud, (unsigned long)pmd)
 
@@ -83,31 +158,25 @@ static inline void pmd_populate_kernel(struct mm_struct *mm, pmd_t *pmd,
 	pmd_set(pmd, (unsigned long)pte);
 }
 
-#define pmd_populate(mm, pmd, pte_page) \
-	pmd_populate_kernel(mm, pmd, page_address(pte_page))
-#define pmd_pgtable(pmd) pmd_page(pmd)
-
-#endif /* CONFIG_PPC_64K_PAGES */
-
-static inline pmd_t *pmd_alloc_one(struct mm_struct *mm, unsigned long addr)
+static inline void pmd_populate(struct mm_struct *mm, pmd_t *pmd,
+				pgtable_t pte_page)
 {
-	return kmem_cache_alloc(PGT_CACHE(PMD_INDEX_SIZE),
-				GFP_KERNEL|__GFP_REPEAT);
+	pmd_populate_kernel(mm, pmd, page_address(pte_page));
 }
 
-static inline void pmd_free(struct mm_struct *mm, pmd_t *pmd)
+static inline pgtable_t pmd_pgtable(pmd_t pmd)
 {
-	kmem_cache_free(PGT_CACHE(PMD_INDEX_SIZE), pmd);
+	return pmd_page(pmd);
 }
 
 static inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm,
 					  unsigned long address)
 {
-        return (pte_t *)__get_free_page(GFP_KERNEL | __GFP_REPEAT | __GFP_ZERO);
+	return (pte_t *)__get_free_page(GFP_KERNEL | __GFP_REPEAT | __GFP_ZERO);
 }
 
 static inline pgtable_t pte_alloc_one(struct mm_struct *mm,
-					unsigned long address)
+				      unsigned long address)
 {
 	struct page *page;
 	pte_t *pte;
@@ -120,6 +189,17 @@ static inline pgtable_t pte_alloc_one(struct mm_struct *mm,
 	return page;
 }
 
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
 static inline void pgtable_free(void *table, unsigned index_size)
 {
 	if (!index_size)
@@ -130,6 +210,55 @@ static inline void pgtable_free(void *table, unsigned index_size)
 	}
 }
 
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
+	struct page *page = page_address(table);
+
+	tlb_flush_pgtable(tlb, address);
+	pgtable_page_dtor(page);
+	pgtable_free_tlb(tlb, page, 0);
+}
+
+#endif /* CONFIG_PPC_64K_PAGES */
+
+static inline pmd_t *pmd_alloc_one(struct mm_struct *mm, unsigned long addr)
+{
+	return kmem_cache_alloc(PGT_CACHE(PMD_INDEX_SIZE),
+				GFP_KERNEL|__GFP_REPEAT);
+}
+
+static inline void pmd_free(struct mm_struct *mm, pmd_t *pmd)
+{
+	kmem_cache_free(PGT_CACHE(PMD_INDEX_SIZE), pmd);
+}
+
+
 #define __pmd_free_tlb(tlb, pmd, addr)		      \
 	pgtable_free_tlb(tlb, pmd, PMD_INDEX_SIZE)
 #ifndef CONFIG_PPC_64K_PAGES
diff --git a/arch/powerpc/include/asm/pgalloc.h b/arch/powerpc/include/asm/pgalloc.h
index bf301ac..e9a9f60 100644
--- a/arch/powerpc/include/asm/pgalloc.h
+++ b/arch/powerpc/include/asm/pgalloc.h
@@ -3,6 +3,7 @@
 #ifdef __KERNEL__
 
 #include <linux/mm.h>
+#include <asm-generic/tlb.h>
 
 #ifdef CONFIG_PPC_BOOK3E
 extern void tlb_flush_pgtable(struct mmu_gather *tlb, unsigned long address);
@@ -13,56 +14,11 @@ static inline void tlb_flush_pgtable(struct mmu_gather *tlb,
 }
 #endif /* !CONFIG_PPC_BOOK3E */
 
-static inline void pte_free_kernel(struct mm_struct *mm, pte_t *pte)
-{
-	free_page((unsigned long)pte);
-}
-
-static inline void pte_free(struct mm_struct *mm, pgtable_t ptepage)
-{
-	pgtable_page_dtor(ptepage);
-	__free_page(ptepage);
-}
-
 #ifdef CONFIG_PPC64
 #include <asm/pgalloc-64.h>
 #else
 #include <asm/pgalloc-32.h>
 #endif
 
-#ifdef CONFIG_SMP
-struct mmu_gather;
-extern void tlb_remove_table(struct mmu_gather *, void *);
-
-static inline void pgtable_free_tlb(struct mmu_gather *tlb, void *table, int shift)
-{
-	unsigned long pgf = (unsigned long)table;
-	BUG_ON(shift > MAX_PGTABLE_INDEX_SIZE);
-	pgf |= shift;
-	tlb_remove_table(tlb, (void *)pgf);
-}
-
-static inline void __tlb_remove_table(void *_table)
-{
-	void *table = (void *)((unsigned long)_table & ~MAX_PGTABLE_INDEX_SIZE);
-	unsigned shift = (unsigned long)_table & MAX_PGTABLE_INDEX_SIZE;
-
-	pgtable_free(table, shift);
-}
-#else /* CONFIG_SMP */
-static inline void pgtable_free_tlb(struct mmu_gather *tlb, void *table, unsigned shift)
-{
-	pgtable_free(table, shift);
-}
-#endif /* !CONFIG_SMP */
-
-static inline void __pte_free_tlb(struct mmu_gather *tlb, struct page *ptepage,
-				  unsigned long address)
-{
-	tlb_flush_pgtable(tlb, address);
-	pgtable_page_dtor(ptepage);
-	pgtable_free_tlb(tlb, page_address(ptepage), 0);
-}
-
 #endif /* __KERNEL__ */
 #endif /* _ASM_POWERPC_PGALLOC_H */
-- 
1.7.10

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
