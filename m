Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f179.google.com (mail-ob0-f179.google.com [209.85.214.179])
	by kanga.kvack.org (Postfix) with ESMTP id 44AB5830C6
	for <linux-mm@kvack.org>; Mon,  8 Feb 2016 04:21:27 -0500 (EST)
Received: by mail-ob0-f179.google.com with SMTP id xk3so144728859obc.2
        for <linux-mm@kvack.org>; Mon, 08 Feb 2016 01:21:27 -0800 (PST)
Received: from e33.co.us.ibm.com (e33.co.us.ibm.com. [32.97.110.151])
        by mx.google.com with ESMTPS id rz2si15141744oec.5.2016.02.08.01.21.22
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 08 Feb 2016 01:21:22 -0800 (PST)
Received: from localhost
	by e33.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Mon, 8 Feb 2016 02:21:22 -0700
Received: from b03cxnp08025.gho.boulder.ibm.com (b03cxnp08025.gho.boulder.ibm.com [9.17.130.17])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id 051A51FF0046
	for <linux-mm@kvack.org>; Mon,  8 Feb 2016 02:09:30 -0700 (MST)
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by b03cxnp08025.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u189LK2I29425794
	for <linux-mm@kvack.org>; Mon, 8 Feb 2016 02:21:20 -0700
Received: from d03av01.boulder.ibm.com (localhost [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u189LI4k028486
	for <linux-mm@kvack.org>; Mon, 8 Feb 2016 02:21:19 -0700
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH V2 12/29] powerpc/mm: Move hash64 specific defintions to seperate header
Date: Mon,  8 Feb 2016 14:50:24 +0530
Message-Id: <1454923241-6681-13-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1454923241-6681-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1454923241-6681-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

Also split pgalloc 64k and 4k headers

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 .../include/asm/book3s/64/pgalloc-hash-4k.h        |  92 ++++++++++
 .../include/asm/book3s/64/pgalloc-hash-64k.h       |  51 ++++++
 arch/powerpc/include/asm/book3s/64/pgalloc-hash.h  |  59 ++++++
 arch/powerpc/include/asm/book3s/64/pgalloc.h       | 199 +--------------------
 4 files changed, 210 insertions(+), 191 deletions(-)
 create mode 100644 arch/powerpc/include/asm/book3s/64/pgalloc-hash-4k.h
 create mode 100644 arch/powerpc/include/asm/book3s/64/pgalloc-hash-64k.h
 create mode 100644 arch/powerpc/include/asm/book3s/64/pgalloc-hash.h

diff --git a/arch/powerpc/include/asm/book3s/64/pgalloc-hash-4k.h b/arch/powerpc/include/asm/book3s/64/pgalloc-hash-4k.h
new file mode 100644
index 000000000000..d1d67e585ad4
--- /dev/null
+++ b/arch/powerpc/include/asm/book3s/64/pgalloc-hash-4k.h
@@ -0,0 +1,92 @@
+#ifndef _ASM_POWERPC_BOOK3S_64_PGALLOC_HASH_4K_H
+#define _ASM_POWERPC_BOOK3S_64_PGALLOC_HASH_4K_H
+
+static inline void pmd_populate(struct mm_struct *mm, pmd_t *pmd,
+				pgtable_t pte_page)
+{
+	pmd_set(pmd, (unsigned long)page_address(pte_page));
+}
+
+static inline pgtable_t pmd_pgtable(pmd_t pmd)
+{
+	return pmd_page(pmd);
+}
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
+#endif /* _ASM_POWERPC_BOOK3S_64_PGALLOC_HASH_4K_H */
diff --git a/arch/powerpc/include/asm/book3s/64/pgalloc-hash-64k.h b/arch/powerpc/include/asm/book3s/64/pgalloc-hash-64k.h
new file mode 100644
index 000000000000..e2dab4f64316
--- /dev/null
+++ b/arch/powerpc/include/asm/book3s/64/pgalloc-hash-64k.h
@@ -0,0 +1,51 @@
+#ifndef _ASM_POWERPC_BOOK3S_64_PGALLOC_HASH_64K_H
+#define _ASM_POWERPC_BOOK3S_64_PGALLOC_HASH_64K_H
+
+extern pte_t *page_table_alloc(struct mm_struct *, unsigned long, int);
+extern void page_table_free(struct mm_struct *, unsigned long *, int);
+extern void pgtable_free_tlb(struct mmu_gather *tlb, void *table, int shift);
+#ifdef CONFIG_SMP
+extern void __tlb_remove_table(void *_table);
+#endif
+
+static inline void pmd_populate(struct mm_struct *mm, pmd_t *pmd,
+				pgtable_t pte_page)
+{
+	pmd_set(pmd, (unsigned long)pte_page);
+}
+
+static inline pgtable_t pmd_pgtable(pmd_t pmd)
+{
+	return (pgtable_t)pmd_page_vaddr(pmd);
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
+
+#endif /* _ASM_POWERPC_BOOK3S_64_PGALLOC_HASH_64K_H */
diff --git a/arch/powerpc/include/asm/book3s/64/pgalloc-hash.h b/arch/powerpc/include/asm/book3s/64/pgalloc-hash.h
new file mode 100644
index 000000000000..96f90c7e806f
--- /dev/null
+++ b/arch/powerpc/include/asm/book3s/64/pgalloc-hash.h
@@ -0,0 +1,59 @@
+#ifndef _ASM_POWERPC_BOOK3S_64_PGALLOC_HASH_H
+#define _ASM_POWERPC_BOOK3S_64_PGALLOC_HASH_H
+
+/*
+ * FIXME!!
+ * Between 4K and 64K pages, we differ in what is stored in pmd. ie.
+ * typedef pte_t *pgtable_t; -> 64K
+ * typedef struct page *pgtable_t; -> 4k
+ */
+#ifdef CONFIG_PPC_64K_PAGES
+#include <asm/book3s/64/pgalloc-hash-64k.h>
+#else
+#include <asm/book3s/64/pgalloc-hash-4k.h>
+#endif
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
+static inline void __pmd_free_tlb(struct mmu_gather *tlb, pmd_t *pmd,
+				unsigned long address)
+{
+	return pgtable_free_tlb(tlb, pmd, PMD_CACHE_INDEX);
+}
+
+static inline void __pud_free_tlb(struct mmu_gather *tlb, pud_t *pud,
+				unsigned long address)
+{
+	pgtable_free_tlb(tlb, pud, PUD_INDEX_SIZE);
+}
+#endif /* _ASM_POWERPC_BOOK3S_64_PGALLOC_HASH_H */
diff --git a/arch/powerpc/include/asm/book3s/64/pgalloc.h b/arch/powerpc/include/asm/book3s/64/pgalloc.h
index 23b0dd07f9ae..ff3c0e36fe3d 100644
--- a/arch/powerpc/include/asm/book3s/64/pgalloc.h
+++ b/arch/powerpc/include/asm/book3s/64/pgalloc.h
@@ -18,6 +18,11 @@ struct vmemmap_backing {
 };
 extern struct vmemmap_backing *vmemmap_list;
 
+static inline void check_pgt_cache(void)
+{
+
+}
+
 /*
  * Functions that deal with pagetables that could be at any level of
  * the table need to be passed an "index_size" so they know how to
@@ -41,32 +46,11 @@ extern struct kmem_cache *pgtable_cache[];
 			pgtable_cache[(shift) - 1];	\
 		})
 
-static inline pgd_t *pgd_alloc(struct mm_struct *mm)
-{
-	return kmem_cache_alloc(PGT_CACHE(PGD_INDEX_SIZE), GFP_KERNEL);
-}
-
-static inline void pgd_free(struct mm_struct *mm, pgd_t *pgd)
-{
-	kmem_cache_free(PGT_CACHE(PGD_INDEX_SIZE), pgd);
-}
-
 static inline void pgd_populate(struct mm_struct *mm, pgd_t *pgd, pud_t *pud)
 {
 	pgd_set(pgd, (unsigned long)pud);
 }
 
-static inline pud_t *pud_alloc_one(struct mm_struct *mm, unsigned long addr)
-{
-	return kmem_cache_alloc(PGT_CACHE(PUD_INDEX_SIZE),
-				GFP_KERNEL|__GFP_REPEAT);
-}
-
-static inline void pud_free(struct mm_struct *mm, pud_t *pud)
-{
-	kmem_cache_free(PGT_CACHE(PUD_INDEX_SIZE), pud);
-}
-
 static inline void pud_populate(struct mm_struct *mm, pud_t *pud, pmd_t *pmd)
 {
 	pud_set(pud, (unsigned long)pmd);
@@ -78,175 +62,8 @@ static inline void pmd_populate_kernel(struct mm_struct *mm, pmd_t *pmd,
 	pmd_set(pmd, (unsigned long)pte);
 }
 
-/*
- * FIXME!!
- * Between 4K and 64K pages, we differ in what is stored in pmd. ie.
- * typedef pte_t *pgtable_t; -> 64K
- * typedef struct page *pgtable_t; -> 4k
- */
-#ifndef CONFIG_PPC_64K_PAGES
-
-static inline void pmd_populate(struct mm_struct *mm, pmd_t *pmd,
-				pgtable_t pte_page)
-{
-	pmd_set(pmd, (unsigned long)page_address(pte_page));
-}
-
-static inline pgtable_t pmd_pgtable(pmd_t pmd)
-{
-	return pmd_page(pmd);
-}
-
-static inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm,
-					  unsigned long address)
-{
-	return (pte_t *)__get_free_page(GFP_KERNEL | __GFP_REPEAT | __GFP_ZERO);
-}
-
-static inline pgtable_t pte_alloc_one(struct mm_struct *mm,
-				      unsigned long address)
-{
-	struct page *page;
-	pte_t *pte;
-
-	pte = pte_alloc_one_kernel(mm, address);
-	if (!pte)
-		return NULL;
-	page = virt_to_page(pte);
-	if (!pgtable_page_ctor(page)) {
-		__free_page(page);
-		return NULL;
-	}
-	return page;
-}
-
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
-static inline void pgtable_free(void *table, unsigned index_size)
-{
-	if (!index_size)
-		free_page((unsigned long)table);
-	else {
-		BUG_ON(index_size > MAX_PGTABLE_INDEX_SIZE);
-		kmem_cache_free(PGT_CACHE(index_size), table);
-	}
-}
-
-#ifdef CONFIG_SMP
-static inline void pgtable_free_tlb(struct mmu_gather *tlb,
-				    void *table, int shift)
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
-#else /* !CONFIG_SMP */
-static inline void pgtable_free_tlb(struct mmu_gather *tlb,
-				    void *table, int shift)
-{
-	pgtable_free(table, shift);
-}
-#endif /* CONFIG_SMP */
-
-static inline void __pte_free_tlb(struct mmu_gather *tlb, pgtable_t table,
-				  unsigned long address)
-{
-	tlb_flush_pgtable(tlb, address);
-	pgtable_page_dtor(table);
-	pgtable_free_tlb(tlb, page_address(table), 0);
-}
-
-#else /* if CONFIG_PPC_64K_PAGES */
-
-extern pte_t *page_table_alloc(struct mm_struct *, unsigned long, int);
-extern void page_table_free(struct mm_struct *, unsigned long *, int);
-extern void pgtable_free_tlb(struct mmu_gather *tlb, void *table, int shift);
-#ifdef CONFIG_SMP
-extern void __tlb_remove_table(void *_table);
+#ifdef CONFIG_PPC_STD_MMU_64
+#include <asm/book3s/64/pgalloc-hash.h>
 #endif
 
-static inline void pmd_populate(struct mm_struct *mm, pmd_t *pmd,
-				pgtable_t pte_page)
-{
-	pmd_set(pmd, (unsigned long)pte_page);
-}
-
-static inline pgtable_t pmd_pgtable(pmd_t pmd)
-{
-	return (pgtable_t)pmd_page_vaddr(pmd);
-}
-
-static inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm,
-					  unsigned long address)
-{
-	return (pte_t *)page_table_alloc(mm, address, 1);
-}
-
-static inline pgtable_t pte_alloc_one(struct mm_struct *mm,
-					unsigned long address)
-{
-	return (pgtable_t)page_table_alloc(mm, address, 0);
-}
-
-static inline void pte_free_kernel(struct mm_struct *mm, pte_t *pte)
-{
-	page_table_free(mm, (unsigned long *)pte, 1);
-}
-
-static inline void pte_free(struct mm_struct *mm, pgtable_t ptepage)
-{
-	page_table_free(mm, (unsigned long *)ptepage, 0);
-}
-
-static inline void __pte_free_tlb(struct mmu_gather *tlb, pgtable_t table,
-				  unsigned long address)
-{
-	tlb_flush_pgtable(tlb, address);
-	pgtable_free_tlb(tlb, table, 0);
-}
-#endif /* CONFIG_PPC_64K_PAGES */
-
-static inline pmd_t *pmd_alloc_one(struct mm_struct *mm, unsigned long addr)
-{
-	return kmem_cache_alloc(PGT_CACHE(PMD_CACHE_INDEX),
-				GFP_KERNEL|__GFP_REPEAT);
-}
-
-static inline void pmd_free(struct mm_struct *mm, pmd_t *pmd)
-{
-	kmem_cache_free(PGT_CACHE(PMD_CACHE_INDEX), pmd);
-}
-
-static inline void __pmd_free_tlb(struct mmu_gather *tlb, pmd_t *pmd,
-                                  unsigned long address)
-{
-        return pgtable_free_tlb(tlb, pmd, PMD_CACHE_INDEX);
-}
-
-static inline void __pud_free_tlb(struct mmu_gather *tlb, pud_t *pud,
-                                  unsigned long address)
-{
-        pgtable_free_tlb(tlb, pud, PUD_INDEX_SIZE);
-}
-
-#define check_pgt_cache()	do { } while (0)
-
-#endif /* _ASM_POWERPC_BOOK3S_64_PGALLOC_H */
+#endif /* __ASM_POWERPC_BOOK3S_64_PGALLOC_H */
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
