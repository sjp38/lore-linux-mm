Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f175.google.com (mail-ob0-f175.google.com [209.85.214.175])
	by kanga.kvack.org (Postfix) with ESMTP id 99DA0830C6
	for <linux-mm@kvack.org>; Mon,  8 Feb 2016 04:21:21 -0500 (EST)
Received: by mail-ob0-f175.google.com with SMTP id xk3so144726375obc.2
        for <linux-mm@kvack.org>; Mon, 08 Feb 2016 01:21:21 -0800 (PST)
Received: from e37.co.us.ibm.com (e37.co.us.ibm.com. [32.97.110.158])
        by mx.google.com with ESMTPS id f3si15288713obr.60.2016.02.08.01.21.20
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 08 Feb 2016 01:21:20 -0800 (PST)
Received: from localhost
	by e37.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Mon, 8 Feb 2016 02:21:20 -0700
Received: from b03cxnp08028.gho.boulder.ibm.com (b03cxnp08028.gho.boulder.ibm.com [9.17.130.20])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id C71383E4003F
	for <linux-mm@kvack.org>; Mon,  8 Feb 2016 02:21:18 -0700 (MST)
Received: from d03av05.boulder.ibm.com (d03av05.boulder.ibm.com [9.17.195.85])
	by b03cxnp08028.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u189LIDY30146764
	for <linux-mm@kvack.org>; Mon, 8 Feb 2016 02:21:18 -0700
Received: from d03av05.boulder.ibm.com (localhost [127.0.0.1])
	by d03av05.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u189LGRF024726
	for <linux-mm@kvack.org>; Mon, 8 Feb 2016 02:21:17 -0700
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH V2 10/29] powerpc/mm: free_hugepd_range split to hash and nonhash
Date: Mon,  8 Feb 2016 14:50:22 +0530
Message-Id: <1454923241-6681-11-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1454923241-6681-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1454923241-6681-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

We strictly don't need to do this. But enables us to not depend on
pgtable_free_tlb for radix.

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 arch/powerpc/mm/hugetlbpage-book3e.c | 187 ++++++++++++++++++++++++++++++++++
 arch/powerpc/mm/hugetlbpage-hash64.c | 150 ++++++++++++++++++++++++++++
 arch/powerpc/mm/hugetlbpage.c        | 188 -----------------------------------
 3 files changed, 337 insertions(+), 188 deletions(-)

diff --git a/arch/powerpc/mm/hugetlbpage-book3e.c b/arch/powerpc/mm/hugetlbpage-book3e.c
index 4c43a104e35c..459d61855ff7 100644
--- a/arch/powerpc/mm/hugetlbpage-book3e.c
+++ b/arch/powerpc/mm/hugetlbpage-book3e.c
@@ -311,6 +311,193 @@ pte_t *huge_pte_alloc(struct mm_struct *mm, unsigned long addr, unsigned long sz
 	return hugepte_offset(*hpdp, addr, pdshift);
 }
 
+extern void hugepd_free(struct mmu_gather *tlb, void *hugepte);
+static void free_hugepd_range(struct mmu_gather *tlb, hugepd_t *hpdp, int pdshift,
+			      unsigned long start, unsigned long end,
+			      unsigned long floor, unsigned long ceiling)
+{
+	pte_t *hugepte = hugepd_page(*hpdp);
+	int i;
+
+	unsigned long pdmask = ~((1UL << pdshift) - 1);
+	unsigned int num_hugepd = 1;
+
+#ifdef CONFIG_PPC_FSL_BOOK3E
+	/* Note: On fsl the hpdp may be the first of several */
+	num_hugepd = (1 << (hugepd_shift(*hpdp) - pdshift));
+#else
+	unsigned int shift = hugepd_shift(*hpdp);
+#endif
+
+	start &= pdmask;
+	if (start < floor)
+		return;
+	if (ceiling) {
+		ceiling &= pdmask;
+		if (! ceiling)
+			return;
+	}
+	if (end - 1 > ceiling - 1)
+		return;
+
+	for (i = 0; i < num_hugepd; i++, hpdp++)
+		hpdp->pd = 0;
+
+#ifdef CONFIG_PPC_FSL_BOOK3E
+	hugepd_free(tlb, hugepte);
+#else
+	pgtable_free_tlb(tlb, hugepte, pdshift - shift);
+#endif
+}
+
+static void hugetlb_free_pmd_range(struct mmu_gather *tlb, pud_t *pud,
+				   unsigned long addr, unsigned long end,
+				   unsigned long floor, unsigned long ceiling)
+{
+	pmd_t *pmd;
+	unsigned long next;
+	unsigned long start;
+
+	start = addr;
+	do {
+		pmd = pmd_offset(pud, addr);
+		next = pmd_addr_end(addr, end);
+		if (!is_hugepd(__hugepd(pmd_val(*pmd)))) {
+			/*
+			 * if it is not hugepd pointer, we should already find
+			 * it cleared.
+			 */
+			WARN_ON(!pmd_none_or_clear_bad(pmd));
+			continue;
+		}
+#ifdef CONFIG_PPC_FSL_BOOK3E
+		/*
+		 * Increment next by the size of the huge mapping since
+		 * there may be more than one entry at this level for a
+		 * single hugepage, but all of them point to
+		 * the same kmem cache that holds the hugepte.
+		 */
+		next = addr + (1 << hugepd_shift(*(hugepd_t *)pmd));
+#endif
+		free_hugepd_range(tlb, (hugepd_t *)pmd, PMD_SHIFT,
+				  addr, next, floor, ceiling);
+	} while (addr = next, addr != end);
+
+	start &= PUD_MASK;
+	if (start < floor)
+		return;
+	if (ceiling) {
+		ceiling &= PUD_MASK;
+		if (!ceiling)
+			return;
+	}
+	if (end - 1 > ceiling - 1)
+		return;
+
+	pmd = pmd_offset(pud, start);
+	pud_clear(pud);
+	pmd_free_tlb(tlb, pmd, start);
+	mm_dec_nr_pmds(tlb->mm);
+}
+
+static void hugetlb_free_pud_range(struct mmu_gather *tlb, pgd_t *pgd,
+				   unsigned long addr, unsigned long end,
+				   unsigned long floor, unsigned long ceiling)
+{
+	pud_t *pud;
+	unsigned long next;
+	unsigned long start;
+
+	start = addr;
+	do {
+		pud = pud_offset(pgd, addr);
+		next = pud_addr_end(addr, end);
+		if (!is_hugepd(__hugepd(pud_val(*pud)))) {
+			if (pud_none_or_clear_bad(pud))
+				continue;
+			hugetlb_free_pmd_range(tlb, pud, addr, next, floor,
+					       ceiling);
+		} else {
+#ifdef CONFIG_PPC_FSL_BOOK3E
+			/*
+			 * Increment next by the size of the huge mapping since
+			 * there may be more than one entry at this level for a
+			 * single hugepage, but all of them point to
+			 * the same kmem cache that holds the hugepte.
+			 */
+			next = addr + (1 << hugepd_shift(*(hugepd_t *)pud));
+#endif
+			free_hugepd_range(tlb, (hugepd_t *)pud, PUD_SHIFT,
+					  addr, next, floor, ceiling);
+		}
+	} while (addr = next, addr != end);
+
+	start &= PGDIR_MASK;
+	if (start < floor)
+		return;
+	if (ceiling) {
+		ceiling &= PGDIR_MASK;
+		if (!ceiling)
+			return;
+	}
+	if (end - 1 > ceiling - 1)
+		return;
+
+	pud = pud_offset(pgd, start);
+	pgd_clear(pgd);
+	pud_free_tlb(tlb, pud, start);
+}
+
+/*
+ * This function frees user-level page tables of a process.
+ */
+void hugetlb_free_pgd_range(struct mmu_gather *tlb,
+			    unsigned long addr, unsigned long end,
+			    unsigned long floor, unsigned long ceiling)
+{
+	pgd_t *pgd;
+	unsigned long next;
+
+	/*
+	 * Because there are a number of different possible pagetable
+	 * layouts for hugepage ranges, we limit knowledge of how
+	 * things should be laid out to the allocation path
+	 * (huge_pte_alloc(), above).  Everything else works out the
+	 * structure as it goes from information in the hugepd
+	 * pointers.  That means that we can't here use the
+	 * optimization used in the normal page free_pgd_range(), of
+	 * checking whether we're actually covering a large enough
+	 * range to have to do anything at the top level of the walk
+	 * instead of at the bottom.
+	 *
+	 * To make sense of this, you should probably go read the big
+	 * block comment at the top of the normal free_pgd_range(),
+	 * too.
+	 */
+
+	do {
+		next = pgd_addr_end(addr, end);
+		pgd = pgd_offset(tlb->mm, addr);
+		if (!is_hugepd(__hugepd(pgd_val(*pgd)))) {
+			if (pgd_none_or_clear_bad(pgd))
+				continue;
+			hugetlb_free_pud_range(tlb, pgd, addr, next, floor, ceiling);
+		} else {
+#ifdef CONFIG_PPC_FSL_BOOK3E
+			/*
+			 * Increment next by the size of the huge mapping since
+			 * there may be more than one entry at the pgd level
+			 * for a single hugepage, but all of them point to the
+			 * same kmem cache that holds the hugepte.
+			 */
+			next = addr + (1 << hugepd_shift(*(hugepd_t *)pgd));
+#endif
+			free_hugepd_range(tlb, (hugepd_t *)pgd, PGDIR_SHIFT,
+					  addr, next, floor, ceiling);
+		}
+	} while (addr = next, addr != end);
+}
+
 #ifdef CONFIG_PPC_FSL_BOOK3E
 /* Build list of addresses of gigantic pages.  This function is used in early
  * boot before the buddy allocator is setup.
diff --git a/arch/powerpc/mm/hugetlbpage-hash64.c b/arch/powerpc/mm/hugetlbpage-hash64.c
index 9e457c83626b..068ac0e8d07d 100644
--- a/arch/powerpc/mm/hugetlbpage-hash64.c
+++ b/arch/powerpc/mm/hugetlbpage-hash64.c
@@ -13,6 +13,7 @@
 #include <asm/pgalloc.h>
 #include <asm/cacheflush.h>
 #include <asm/machdep.h>
+#include <asm/tlb.h>
 
 /*
  * Tracks gpages after the device tree is scanned and before the
@@ -223,6 +224,155 @@ pte_t *huge_pte_alloc(struct mm_struct *mm, unsigned long addr, unsigned long sz
 	return hugepte_offset(*hpdp, addr, pdshift);
 }
 
+static void free_hugepd_range(struct mmu_gather *tlb, hugepd_t *hpdp, int pdshift,
+			      unsigned long start, unsigned long end,
+			      unsigned long floor, unsigned long ceiling)
+{
+
+	int i;
+	pte_t *hugepte = hugepd_page(*hpdp);
+	unsigned long pdmask = ~((1UL << pdshift) - 1);
+	unsigned int num_hugepd = 1;
+	unsigned int shift = hugepd_shift(*hpdp);
+
+	start &= pdmask;
+	if (start < floor)
+		return;
+	if (ceiling) {
+		ceiling &= pdmask;
+		if (! ceiling)
+			return;
+	}
+	if (end - 1 > ceiling - 1)
+		return;
+
+	for (i = 0; i < num_hugepd; i++, hpdp++)
+		hpdp->pd = 0;
+
+	pgtable_free_tlb(tlb, hugepte, pdshift - shift);
+}
+
+static void hugetlb_free_pmd_range(struct mmu_gather *tlb, pud_t *pud,
+				   unsigned long addr, unsigned long end,
+				   unsigned long floor, unsigned long ceiling)
+{
+	pmd_t *pmd;
+	unsigned long next;
+	unsigned long start;
+
+	start = addr;
+	do {
+		pmd = pmd_offset(pud, addr);
+		next = pmd_addr_end(addr, end);
+		if (!is_hugepd(__hugepd(pmd_val(*pmd)))) {
+			/*
+			 * if it is not hugepd pointer, we should already find
+			 * it cleared.
+			 */
+			WARN_ON(!pmd_none_or_clear_bad(pmd));
+			continue;
+		}
+		free_hugepd_range(tlb, (hugepd_t *)pmd, PMD_SHIFT,
+				  addr, next, floor, ceiling);
+	} while (addr = next, addr != end);
+
+	start &= PUD_MASK;
+	if (start < floor)
+		return;
+	if (ceiling) {
+		ceiling &= PUD_MASK;
+		if (!ceiling)
+			return;
+	}
+	if (end - 1 > ceiling - 1)
+		return;
+
+	pmd = pmd_offset(pud, start);
+	pud_clear(pud);
+	pmd_free_tlb(tlb, pmd, start);
+	mm_dec_nr_pmds(tlb->mm);
+}
+
+static void hugetlb_free_pud_range(struct mmu_gather *tlb, pgd_t *pgd,
+				   unsigned long addr, unsigned long end,
+				   unsigned long floor, unsigned long ceiling)
+{
+	pud_t *pud;
+	unsigned long next;
+	unsigned long start;
+
+	start = addr;
+	do {
+		pud = pud_offset(pgd, addr);
+		next = pud_addr_end(addr, end);
+		if (!is_hugepd(__hugepd(pud_val(*pud)))) {
+			if (pud_none_or_clear_bad(pud))
+				continue;
+			hugetlb_free_pmd_range(tlb, pud, addr, next, floor,
+					       ceiling);
+		} else {
+			free_hugepd_range(tlb, (hugepd_t *)pud, PUD_SHIFT,
+					  addr, next, floor, ceiling);
+		}
+	} while (addr = next, addr != end);
+
+	start &= PGDIR_MASK;
+	if (start < floor)
+		return;
+	if (ceiling) {
+		ceiling &= PGDIR_MASK;
+		if (!ceiling)
+			return;
+	}
+	if (end - 1 > ceiling - 1)
+		return;
+
+	pud = pud_offset(pgd, start);
+	pgd_clear(pgd);
+	pud_free_tlb(tlb, pud, start);
+}
+
+/*
+ * This function frees user-level page tables of a process.
+ */
+void hugetlb_free_pgd_range(struct mmu_gather *tlb,
+			    unsigned long addr, unsigned long end,
+			    unsigned long floor, unsigned long ceiling)
+{
+	pgd_t *pgd;
+	unsigned long next;
+
+	/*
+	 * Because there are a number of different possible pagetable
+	 * layouts for hugepage ranges, we limit knowledge of how
+	 * things should be laid out to the allocation path
+	 * (huge_pte_alloc(), above).  Everything else works out the
+	 * structure as it goes from information in the hugepd
+	 * pointers.  That means that we can't here use the
+	 * optimization used in the normal page free_pgd_range(), of
+	 * checking whether we're actually covering a large enough
+	 * range to have to do anything at the top level of the walk
+	 * instead of at the bottom.
+	 *
+	 * To make sense of this, you should probably go read the big
+	 * block comment at the top of the normal free_pgd_range(),
+	 * too.
+	 */
+
+	do {
+		next = pgd_addr_end(addr, end);
+		pgd = pgd_offset(tlb->mm, addr);
+		if (!is_hugepd(__hugepd(pgd_val(*pgd)))) {
+			if (pgd_none_or_clear_bad(pgd))
+				continue;
+			hugetlb_free_pud_range(tlb, pgd, addr, next, floor, ceiling);
+		} else {
+			free_hugepd_range(tlb, (hugepd_t *)pgd, PGDIR_SHIFT,
+					  addr, next, floor, ceiling);
+		}
+	} while (addr = next, addr != end);
+}
+
 
 /* Build list of addresses of gigantic pages.  This function is used in early
  * boot before the buddy allocator is setup.
diff --git a/arch/powerpc/mm/hugetlbpage.c b/arch/powerpc/mm/hugetlbpage.c
index c94502899e94..26fb814f289f 100644
--- a/arch/powerpc/mm/hugetlbpage.c
+++ b/arch/powerpc/mm/hugetlbpage.c
@@ -37,194 +37,6 @@ pte_t *huge_pte_offset(struct mm_struct *mm, unsigned long addr)
 	return __find_linux_pte_or_hugepte(mm->pgd, addr, NULL, NULL);
 }
 
-
-extern void hugepd_free(struct mmu_gather *tlb, void *hugepte);
-static void free_hugepd_range(struct mmu_gather *tlb, hugepd_t *hpdp, int pdshift,
-			      unsigned long start, unsigned long end,
-			      unsigned long floor, unsigned long ceiling)
-{
-	pte_t *hugepte = hugepd_page(*hpdp);
-	int i;
-
-	unsigned long pdmask = ~((1UL << pdshift) - 1);
-	unsigned int num_hugepd = 1;
-
-#ifdef CONFIG_PPC_FSL_BOOK3E
-	/* Note: On fsl the hpdp may be the first of several */
-	num_hugepd = (1 << (hugepd_shift(*hpdp) - pdshift));
-#else
-	unsigned int shift = hugepd_shift(*hpdp);
-#endif
-
-	start &= pdmask;
-	if (start < floor)
-		return;
-	if (ceiling) {
-		ceiling &= pdmask;
-		if (! ceiling)
-			return;
-	}
-	if (end - 1 > ceiling - 1)
-		return;
-
-	for (i = 0; i < num_hugepd; i++, hpdp++)
-		hpdp->pd = 0;
-
-#ifdef CONFIG_PPC_FSL_BOOK3E
-	hugepd_free(tlb, hugepte);
-#else
-	pgtable_free_tlb(tlb, hugepte, pdshift - shift);
-#endif
-}
-
-static void hugetlb_free_pmd_range(struct mmu_gather *tlb, pud_t *pud,
-				   unsigned long addr, unsigned long end,
-				   unsigned long floor, unsigned long ceiling)
-{
-	pmd_t *pmd;
-	unsigned long next;
-	unsigned long start;
-
-	start = addr;
-	do {
-		pmd = pmd_offset(pud, addr);
-		next = pmd_addr_end(addr, end);
-		if (!is_hugepd(__hugepd(pmd_val(*pmd)))) {
-			/*
-			 * if it is not hugepd pointer, we should already find
-			 * it cleared.
-			 */
-			WARN_ON(!pmd_none_or_clear_bad(pmd));
-			continue;
-		}
-#ifdef CONFIG_PPC_FSL_BOOK3E
-		/*
-		 * Increment next by the size of the huge mapping since
-		 * there may be more than one entry at this level for a
-		 * single hugepage, but all of them point to
-		 * the same kmem cache that holds the hugepte.
-		 */
-		next = addr + (1 << hugepd_shift(*(hugepd_t *)pmd));
-#endif
-		free_hugepd_range(tlb, (hugepd_t *)pmd, PMD_SHIFT,
-				  addr, next, floor, ceiling);
-	} while (addr = next, addr != end);
-
-	start &= PUD_MASK;
-	if (start < floor)
-		return;
-	if (ceiling) {
-		ceiling &= PUD_MASK;
-		if (!ceiling)
-			return;
-	}
-	if (end - 1 > ceiling - 1)
-		return;
-
-	pmd = pmd_offset(pud, start);
-	pud_clear(pud);
-	pmd_free_tlb(tlb, pmd, start);
-	mm_dec_nr_pmds(tlb->mm);
-}
-
-static void hugetlb_free_pud_range(struct mmu_gather *tlb, pgd_t *pgd,
-				   unsigned long addr, unsigned long end,
-				   unsigned long floor, unsigned long ceiling)
-{
-	pud_t *pud;
-	unsigned long next;
-	unsigned long start;
-
-	start = addr;
-	do {
-		pud = pud_offset(pgd, addr);
-		next = pud_addr_end(addr, end);
-		if (!is_hugepd(__hugepd(pud_val(*pud)))) {
-			if (pud_none_or_clear_bad(pud))
-				continue;
-			hugetlb_free_pmd_range(tlb, pud, addr, next, floor,
-					       ceiling);
-		} else {
-#ifdef CONFIG_PPC_FSL_BOOK3E
-			/*
-			 * Increment next by the size of the huge mapping since
-			 * there may be more than one entry at this level for a
-			 * single hugepage, but all of them point to
-			 * the same kmem cache that holds the hugepte.
-			 */
-			next = addr + (1 << hugepd_shift(*(hugepd_t *)pud));
-#endif
-			free_hugepd_range(tlb, (hugepd_t *)pud, PUD_SHIFT,
-					  addr, next, floor, ceiling);
-		}
-	} while (addr = next, addr != end);
-
-	start &= PGDIR_MASK;
-	if (start < floor)
-		return;
-	if (ceiling) {
-		ceiling &= PGDIR_MASK;
-		if (!ceiling)
-			return;
-	}
-	if (end - 1 > ceiling - 1)
-		return;
-
-	pud = pud_offset(pgd, start);
-	pgd_clear(pgd);
-	pud_free_tlb(tlb, pud, start);
-}
-
-/*
- * This function frees user-level page tables of a process.
- */
-void hugetlb_free_pgd_range(struct mmu_gather *tlb,
-			    unsigned long addr, unsigned long end,
-			    unsigned long floor, unsigned long ceiling)
-{
-	pgd_t *pgd;
-	unsigned long next;
-
-	/*
-	 * Because there are a number of different possible pagetable
-	 * layouts for hugepage ranges, we limit knowledge of how
-	 * things should be laid out to the allocation path
-	 * (huge_pte_alloc(), above).  Everything else works out the
-	 * structure as it goes from information in the hugepd
-	 * pointers.  That means that we can't here use the
-	 * optimization used in the normal page free_pgd_range(), of
-	 * checking whether we're actually covering a large enough
-	 * range to have to do anything at the top level of the walk
-	 * instead of at the bottom.
-	 *
-	 * To make sense of this, you should probably go read the big
-	 * block comment at the top of the normal free_pgd_range(),
-	 * too.
-	 */
-
-	do {
-		next = pgd_addr_end(addr, end);
-		pgd = pgd_offset(tlb->mm, addr);
-		if (!is_hugepd(__hugepd(pgd_val(*pgd)))) {
-			if (pgd_none_or_clear_bad(pgd))
-				continue;
-			hugetlb_free_pud_range(tlb, pgd, addr, next, floor, ceiling);
-		} else {
-#ifdef CONFIG_PPC_FSL_BOOK3E
-			/*
-			 * Increment next by the size of the huge mapping since
-			 * there may be more than one entry at the pgd level
-			 * for a single hugepage, but all of them point to the
-			 * same kmem cache that holds the hugepte.
-			 */
-			next = addr + (1 << hugepd_shift(*(hugepd_t *)pgd));
-#endif
-			free_hugepd_range(tlb, (hugepd_t *)pgd, PGDIR_SHIFT,
-					  addr, next, floor, ceiling);
-		}
-	} while (addr = next, addr != end);
-}
-
 /*
  * We are holding mmap_sem, so a parallel huge page collapse cannot run.
  * To prevent hugepage split, disable irq.
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
