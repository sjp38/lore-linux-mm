Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f179.google.com (mail-ob0-f179.google.com [209.85.214.179])
	by kanga.kvack.org (Postfix) with ESMTP id 481AA830C6
	for <linux-mm@kvack.org>; Mon,  8 Feb 2016 04:21:05 -0500 (EST)
Received: by mail-ob0-f179.google.com with SMTP id is5so143988122obc.0
        for <linux-mm@kvack.org>; Mon, 08 Feb 2016 01:21:05 -0800 (PST)
Received: from e34.co.us.ibm.com (e34.co.us.ibm.com. [32.97.110.152])
        by mx.google.com with ESMTPS id o5si12411645oei.90.2016.02.08.01.21.04
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 08 Feb 2016 01:21:04 -0800 (PST)
Received: from localhost
	by e34.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Mon, 8 Feb 2016 02:21:03 -0700
Received: from b03cxnp07028.gho.boulder.ibm.com (b03cxnp07028.gho.boulder.ibm.com [9.17.130.15])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id 7E23A1FF0042
	for <linux-mm@kvack.org>; Mon,  8 Feb 2016 02:09:11 -0700 (MST)
Received: from d03av05.boulder.ibm.com (d03av05.boulder.ibm.com [9.17.195.85])
	by b03cxnp07028.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u189L1Y624707308
	for <linux-mm@kvack.org>; Mon, 8 Feb 2016 02:21:01 -0700
Received: from d03av05.boulder.ibm.com (localhost [127.0.0.1])
	by d03av05.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u189L06k023696
	for <linux-mm@kvack.org>; Mon, 8 Feb 2016 02:21:01 -0700
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH V2 03/29] powerpc/mm: Switch book3s 64 with 64K page size to 4 level page table
Date: Mon,  8 Feb 2016 14:50:15 +0530
Message-Id: <1454923241-6681-4-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1454923241-6681-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1454923241-6681-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

This is needed so that we can support both hash and radix page table
using single kernel. Radix kernel uses a 4 level table.

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 arch/powerpc/Kconfig                          |  1 +
 arch/powerpc/include/asm/book3s/64/hash-4k.h  | 33 +--------------------------
 arch/powerpc/include/asm/book3s/64/hash-64k.h | 20 +++++++++-------
 arch/powerpc/include/asm/book3s/64/hash.h     |  8 +++++++
 arch/powerpc/include/asm/book3s/64/pgtable.h  | 25 +++++++++++++++++++-
 arch/powerpc/include/asm/pgalloc-64.h         | 24 ++++++++++++++++---
 arch/powerpc/include/asm/pgtable-types.h      | 13 +++++++----
 arch/powerpc/mm/init_64.c                     | 21 ++++++++++++-----
 8 files changed, 90 insertions(+), 55 deletions(-)

diff --git a/arch/powerpc/Kconfig b/arch/powerpc/Kconfig
index 9faa18c4f3f7..599329332613 100644
--- a/arch/powerpc/Kconfig
+++ b/arch/powerpc/Kconfig
@@ -303,6 +303,7 @@ config ZONE_DMA32
 config PGTABLE_LEVELS
 	int
 	default 2 if !PPC64
+	default 4 if PPC_BOOK3S_64
 	default 3 if PPC_64K_PAGES
 	default 4
 
diff --git a/arch/powerpc/include/asm/book3s/64/hash-4k.h b/arch/powerpc/include/asm/book3s/64/hash-4k.h
index ea0414d6659e..c78f5928001b 100644
--- a/arch/powerpc/include/asm/book3s/64/hash-4k.h
+++ b/arch/powerpc/include/asm/book3s/64/hash-4k.h
@@ -57,39 +57,8 @@
 #define _PAGE_4K_PFN		0
 #ifndef __ASSEMBLY__
 /*
- * 4-level page tables related bits
+ * On all 4K setups, remap_4k_pfn() equates to remap_pfn_range()
  */
-
-#define pgd_none(pgd)		(!pgd_val(pgd))
-#define pgd_bad(pgd)		(pgd_val(pgd) == 0)
-#define pgd_present(pgd)	(pgd_val(pgd) != 0)
-#define pgd_page_vaddr(pgd)	(pgd_val(pgd) & ~PGD_MASKED_BITS)
-
-static inline void pgd_clear(pgd_t *pgdp)
-{
-	*pgdp = __pgd(0);
-}
-
-static inline pte_t pgd_pte(pgd_t pgd)
-{
-	return __pte(pgd_val(pgd));
-}
-
-static inline pgd_t pte_pgd(pte_t pte)
-{
-	return __pgd(pte_val(pte));
-}
-extern struct page *pgd_page(pgd_t pgd);
-
-#define pud_offset(pgdp, addr)	\
-  (((pud_t *) pgd_page_vaddr(*(pgdp))) + \
-    (((addr) >> PUD_SHIFT) & (PTRS_PER_PUD - 1)))
-
-#define pud_ERROR(e) \
-	pr_err("%s:%d: bad pud %08lx.\n", __FILE__, __LINE__, pud_val(e))
-
-/*
- * On all 4K setups, remap_4k_pfn() equates to remap_pfn_range() */
 #define remap_4k_pfn(vma, addr, pfn, prot)	\
 	remap_pfn_range((vma), (addr), (pfn), PAGE_SIZE, (prot))
 
diff --git a/arch/powerpc/include/asm/book3s/64/hash-64k.h b/arch/powerpc/include/asm/book3s/64/hash-64k.h
index 849bbec80f7b..5c9392b71a6b 100644
--- a/arch/powerpc/include/asm/book3s/64/hash-64k.h
+++ b/arch/powerpc/include/asm/book3s/64/hash-64k.h
@@ -1,15 +1,14 @@
 #ifndef _ASM_POWERPC_BOOK3S_64_HASH_64K_H
 #define _ASM_POWERPC_BOOK3S_64_HASH_64K_H
 
-#include <asm-generic/pgtable-nopud.h>
-
 #define PTE_INDEX_SIZE  8
-#define PMD_INDEX_SIZE  10
-#define PUD_INDEX_SIZE	0
+#define PMD_INDEX_SIZE  5
+#define PUD_INDEX_SIZE	5
 #define PGD_INDEX_SIZE  12
 
 #define PTRS_PER_PTE	(1 << PTE_INDEX_SIZE)
 #define PTRS_PER_PMD	(1 << PMD_INDEX_SIZE)
+#define PTRS_PER_PUD	(1 << PUD_INDEX_SIZE)
 #define PTRS_PER_PGD	(1 << PGD_INDEX_SIZE)
 
 /* With 4k base page size, hugepage PTEs go at the PMD level */
@@ -20,8 +19,13 @@
 #define PMD_SIZE	(1UL << PMD_SHIFT)
 #define PMD_MASK	(~(PMD_SIZE-1))
 
+/* PUD_SHIFT determines what a third-level page table entry can map */
+#define PUD_SHIFT	(PMD_SHIFT + PMD_INDEX_SIZE)
+#define PUD_SIZE	(1UL << PUD_SHIFT)
+#define PUD_MASK	(~(PUD_SIZE-1))
+
 /* PGDIR_SHIFT determines what a third-level page table entry can map */
-#define PGDIR_SHIFT	(PMD_SHIFT + PMD_INDEX_SIZE)
+#define PGDIR_SHIFT	(PUD_SHIFT + PUD_INDEX_SIZE)
 #define PGDIR_SIZE	(1UL << PGDIR_SHIFT)
 #define PGDIR_MASK	(~(PGDIR_SIZE-1))
 
@@ -61,6 +65,8 @@
 #define PMD_MASKED_BITS		(PTE_FRAG_SIZE - 1)
 /* Bits to mask out from a PGD/PUD to get to the PMD page */
 #define PUD_MASKED_BITS		0x1ff
+/* FIXME!! check this */
+#define PGD_MASKED_BITS		0
 
 #ifndef __ASSEMBLY__
 
@@ -130,11 +136,9 @@ extern bool __rpte_sub_valid(real_pte_t rpte, unsigned long index);
 #else
 #define PMD_TABLE_SIZE	(sizeof(pmd_t) << PMD_INDEX_SIZE)
 #endif
+#define PUD_TABLE_SIZE	(sizeof(pud_t) << PUD_INDEX_SIZE)
 #define PGD_TABLE_SIZE	(sizeof(pgd_t) << PGD_INDEX_SIZE)
 
-#define pgd_pte(pgd)	(pud_pte(((pud_t){ pgd })))
-#define pte_pgd(pte)	((pgd_t)pte_pud(pte))
-
 #ifdef CONFIG_HUGETLB_PAGE
 /*
  * We have PGD_INDEX_SIZ = 12 and PTE_INDEX_SIZE = 8, so that we can have
diff --git a/arch/powerpc/include/asm/book3s/64/hash.h b/arch/powerpc/include/asm/book3s/64/hash.h
index 8d1c8162f0c1..6aae0b0b649b 100644
--- a/arch/powerpc/include/asm/book3s/64/hash.h
+++ b/arch/powerpc/include/asm/book3s/64/hash.h
@@ -232,6 +232,7 @@
 #define pud_page_vaddr(pud)	(pud_val(pud) & ~PUD_MASKED_BITS)
 
 #define pgd_index(address) (((address) >> (PGDIR_SHIFT)) & (PTRS_PER_PGD - 1))
+#define pud_index(address) (((address) >> (PUD_SHIFT)) & (PTRS_PER_PUD - 1))
 #define pmd_index(address) (((address) >> (PMD_SHIFT)) & (PTRS_PER_PMD - 1))
 #define pte_index(address) (((address) >> (PAGE_SHIFT)) & (PTRS_PER_PTE - 1))
 
@@ -360,8 +361,15 @@ static inline void __ptep_set_access_flags(pte_t *ptep, pte_t entry)
 	:"cc");
 }
 
+static inline int pgd_bad(pgd_t pgd)
+{
+	return (pgd_val(pgd) == 0);
+}
+
 #define __HAVE_ARCH_PTE_SAME
 #define pte_same(A,B)	(((pte_val(A) ^ pte_val(B)) & ~_PAGE_HPTEFLAGS) == 0)
+#define pgd_page_vaddr(pgd)	(pgd_val(pgd) & ~PGD_MASKED_BITS)
+
 
 /* Generic accessors to PTE bits */
 static inline int pte_write(pte_t pte)		{ return !!(pte_val(pte) & _PAGE_RW);}
diff --git a/arch/powerpc/include/asm/book3s/64/pgtable.h b/arch/powerpc/include/asm/book3s/64/pgtable.h
index 682958f85052..ca73ed59131f 100644
--- a/arch/powerpc/include/asm/book3s/64/pgtable.h
+++ b/arch/powerpc/include/asm/book3s/64/pgtable.h
@@ -106,6 +106,26 @@ static inline void pgd_set(pgd_t *pgdp, unsigned long val)
 	*pgdp = __pgd(val);
 }
 
+static inline void pgd_clear(pgd_t *pgdp)
+{
+	*pgdp = __pgd(0);
+}
+
+#define pgd_none(pgd)		(!pgd_val(pgd))
+#define pgd_present(pgd)	(!pgd_none(pgd))
+
+static inline pte_t pgd_pte(pgd_t pgd)
+{
+	return __pte(pgd_val(pgd));
+}
+
+static inline pgd_t pte_pgd(pte_t pte)
+{
+	return __pgd(pte_val(pte));
+}
+
+extern struct page *pgd_page(pgd_t pgd);
+
 /*
  * Find an entry in a page-table-directory.  We combine the address region
  * (the high order N bits) and the pgd portion of the address.
@@ -113,9 +133,10 @@ static inline void pgd_set(pgd_t *pgdp, unsigned long val)
 
 #define pgd_offset(mm, address)	 ((mm)->pgd + pgd_index(address))
 
+#define pud_offset(pgdp, addr)	\
+	(((pud_t *) pgd_page_vaddr(*(pgdp))) + pud_index(addr))
 #define pmd_offset(pudp,addr) \
 	(((pmd_t *) pud_page_vaddr(*(pudp))) + pmd_index(addr))
-
 #define pte_offset_kernel(dir,addr) \
 	(((pte_t *) pmd_page_vaddr(*(dir))) + pte_index(addr))
 
@@ -130,6 +151,8 @@ static inline void pgd_set(pgd_t *pgdp, unsigned long val)
 	pr_err("%s:%d: bad pte %08lx.\n", __FILE__, __LINE__, pte_val(e))
 #define pmd_ERROR(e) \
 	pr_err("%s:%d: bad pmd %08lx.\n", __FILE__, __LINE__, pmd_val(e))
+#define pud_ERROR(e) \
+	pr_err("%s:%d: bad pud %08lx.\n", __FILE__, __LINE__, pud_val(e))
 #define pgd_ERROR(e) \
 	pr_err("%s:%d: bad pgd %08lx.\n", __FILE__, __LINE__, pgd_val(e))
 
diff --git a/arch/powerpc/include/asm/pgalloc-64.h b/arch/powerpc/include/asm/pgalloc-64.h
index 69ef28a81733..014489a619d0 100644
--- a/arch/powerpc/include/asm/pgalloc-64.h
+++ b/arch/powerpc/include/asm/pgalloc-64.h
@@ -171,7 +171,25 @@ extern void pgtable_free_tlb(struct mmu_gather *tlb, void *table, int shift);
 extern void __tlb_remove_table(void *_table);
 #endif
 
-#define pud_populate(mm, pud, pmd)	pud_set(pud, (unsigned long)pmd)
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
 
 static inline void pmd_populate_kernel(struct mm_struct *mm, pmd_t *pmd,
 				       pte_t *pte)
@@ -233,11 +251,11 @@ static inline void pmd_free(struct mm_struct *mm, pmd_t *pmd)
 
 #define __pmd_free_tlb(tlb, pmd, addr)		      \
 	pgtable_free_tlb(tlb, pmd, PMD_CACHE_INDEX)
-#ifndef CONFIG_PPC_64K_PAGES
+#ifndef __PAGETABLE_PUD_FOLDED
 #define __pud_free_tlb(tlb, pud, addr)		      \
 	pgtable_free_tlb(tlb, pud, PUD_INDEX_SIZE)
 
-#endif /* CONFIG_PPC_64K_PAGES */
+#endif /* __PAGETABLE_PUD_FOLDED */
 
 #define check_pgt_cache()	do { } while (0)
 
diff --git a/arch/powerpc/include/asm/pgtable-types.h b/arch/powerpc/include/asm/pgtable-types.h
index 71487e1ca638..43140f8b0592 100644
--- a/arch/powerpc/include/asm/pgtable-types.h
+++ b/arch/powerpc/include/asm/pgtable-types.h
@@ -21,15 +21,18 @@ static inline unsigned long pmd_val(pmd_t x)
 	return x.pmd;
 }
 
-/* PUD level exusts only on 4k pages */
-#ifndef CONFIG_PPC_64K_PAGES
+/*
+ * 64 bit hash always use 4 level table. Everybody else use 4 level
+ * only for 4K page size.
+ */
+#if defined(CONFIG_PPC_BOOK3S_64) || !defined(CONFIG_PPC_64K_PAGES)
 typedef struct { unsigned long pud; } pud_t;
 #define __pud(x)	((pud_t) { (x) })
 static inline unsigned long pud_val(pud_t x)
 {
 	return x.pud;
 }
-#endif /* !CONFIG_PPC_64K_PAGES */
+#endif /* CONFIG_PPC_BOOK3S_64 || !CONFIG_PPC_64K_PAGES */
 #endif /* CONFIG_PPC64 */
 
 /* PGD level */
@@ -66,14 +69,14 @@ static inline unsigned long pmd_val(pmd_t pmd)
 	return pmd;
 }
 
-#ifndef CONFIG_PPC_64K_PAGES
+#if defined(CONFIG_PPC_BOOK3S_64) || !defined(CONFIG_PPC_64K_PAGES)
 typedef unsigned long pud_t;
 #define __pud(x)	(x)
 static inline unsigned long pud_val(pud_t pud)
 {
 	return pud;
 }
-#endif /* !CONFIG_PPC_64K_PAGES */
+#endif /* CONFIG_PPC_BOOK3S_64 || !CONFIG_PPC_64K_PAGES */
 #endif /* CONFIG_PPC64 */
 
 typedef unsigned long pgd_t;
diff --git a/arch/powerpc/mm/init_64.c b/arch/powerpc/mm/init_64.c
index 379a6a90644b..8ce1ec24d573 100644
--- a/arch/powerpc/mm/init_64.c
+++ b/arch/powerpc/mm/init_64.c
@@ -85,6 +85,11 @@ static void pgd_ctor(void *addr)
 	memset(addr, 0, PGD_TABLE_SIZE);
 }
 
+static void pud_ctor(void *addr)
+{
+	memset(addr, 0, PUD_TABLE_SIZE);
+}
+
 static void pmd_ctor(void *addr)
 {
 	memset(addr, 0, PMD_TABLE_SIZE);
@@ -138,14 +143,18 @@ void pgtable_cache_init(void)
 {
 	pgtable_cache_add(PGD_INDEX_SIZE, pgd_ctor);
 	pgtable_cache_add(PMD_CACHE_INDEX, pmd_ctor);
+	/*
+	 * In all current configs, when the PUD index exists it's the
+	 * same size as either the pgd or pmd index except with THP enabled
+	 * on book3s 64
+	 */
+	if (PUD_INDEX_SIZE && !PGT_CACHE(PUD_INDEX_SIZE))
+		pgtable_cache_add(PUD_INDEX_SIZE, pud_ctor);
+
 	if (!PGT_CACHE(PGD_INDEX_SIZE) || !PGT_CACHE(PMD_CACHE_INDEX))
 		panic("Couldn't allocate pgtable caches");
-	/* In all current configs, when the PUD index exists it's the
-	 * same size as either the pgd or pmd index.  Verify that the
-	 * initialization above has also created a PUD cache.  This
-	 * will need re-examiniation if we add new possibilities for
-	 * the pagetable layout. */
-	BUG_ON(PUD_INDEX_SIZE && !PGT_CACHE(PUD_INDEX_SIZE));
+	if (PUD_INDEX_SIZE && !PGT_CACHE(PUD_INDEX_SIZE))
+		panic("Couldn't allocate pud pgtable caches");
 }
 
 #ifdef CONFIG_SPARSEMEM_VMEMMAP
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
