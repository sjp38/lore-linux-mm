Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id EFE9B6B0037
	for <linux-mm@kvack.org>; Sun, 28 Apr 2013 15:37:51 -0400 (EDT)
Received: from /spool/local
	by e28smtp04.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Mon, 29 Apr 2013 01:03:17 +0530
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id 85E4FE0058
	for <linux-mm@kvack.org>; Mon, 29 Apr 2013 01:09:54 +0530 (IST)
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r3SJbfHt11338194
	for <linux-mm@kvack.org>; Mon, 29 Apr 2013 01:07:41 +0530
Received: from d28av03.in.ibm.com (loopback [127.0.0.1])
	by d28av03.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r3SJbj7L003170
	for <linux-mm@kvack.org>; Mon, 29 Apr 2013 05:37:45 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH -V7 09/18] powerpc: Switch 16GB and 16MB explicit hugepages to a different page table format
Date: Mon, 29 Apr 2013 01:07:30 +0530
Message-Id: <1367177859-7893-10-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1367177859-7893-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1367177859-7893-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: benh@kernel.crashing.org, paulus@samba.org, dwg@au1.ibm.com, linux-mm@kvack.org
Cc: linuxppc-dev@lists.ozlabs.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

We will be switching PMD_SHIFT to 24 bits to facilitate THP impmenetation.
With PMD_SHIFT set to 24, we now have 16MB huge pages allocated at PGD level.
That means with 32 bit process we cannot allocate normal pages at
all, because we cover the entire address space with one pgd entry. Fix this
by switching to a new page table format for hugepages. With the new page table
format for 16GB and 16MB hugepages we won't allocate hugepage directory. Instead
we encode the PTE information directly at the directory level. This forces 16MB
hugepage at PMD level. This will also make the page take walk much simpler later
when we add the THP support.

With the new table format we have 4 cases for pgds and pmds:
(1) invalid (all zeroes)
(2) pointer to next table, as normal; bottom 6 bits == 0
(3) leaf pte for huge page, bottom two bits != 00
(4) hugepd pointer, bottom two bits == 00, next 4 bits indicate size of table

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 arch/powerpc/include/asm/page.h    |   2 +
 arch/powerpc/include/asm/pgtable.h |   2 +
 arch/powerpc/mm/gup.c              |  18 +++-
 arch/powerpc/mm/hugetlbpage.c      | 176 +++++++++++++++++++++++++++++++------
 4 files changed, 168 insertions(+), 30 deletions(-)

diff --git a/arch/powerpc/include/asm/page.h b/arch/powerpc/include/asm/page.h
index 652719c..711e83a 100644
--- a/arch/powerpc/include/asm/page.h
+++ b/arch/powerpc/include/asm/page.h
@@ -373,8 +373,10 @@ static inline int hugepd_ok(hugepd_t hpd)
 #endif
 
 #define is_hugepd(pdep)               (hugepd_ok(*((hugepd_t *)(pdep))))
+int pgd_huge(pgd_t pgd);
 #else /* CONFIG_HUGETLB_PAGE */
 #define is_hugepd(pdep)			0
+#define pgd_huge(pgd)			0
 #endif /* CONFIG_HUGETLB_PAGE */
 
 struct page;
diff --git a/arch/powerpc/include/asm/pgtable.h b/arch/powerpc/include/asm/pgtable.h
index 4b52726..7aeb955 100644
--- a/arch/powerpc/include/asm/pgtable.h
+++ b/arch/powerpc/include/asm/pgtable.h
@@ -218,6 +218,8 @@ extern void update_mmu_cache(struct vm_area_struct *, unsigned long, pte_t *);
 extern int gup_hugepd(hugepd_t *hugepd, unsigned pdshift, unsigned long addr,
 		      unsigned long end, int write, struct page **pages, int *nr);
 
+extern int gup_hugepte(pte_t *ptep, unsigned long sz, unsigned long addr,
+		       unsigned long end, int write, struct page **pages, int *nr);
 #endif /* __ASSEMBLY__ */
 
 #endif /* __KERNEL__ */
diff --git a/arch/powerpc/mm/gup.c b/arch/powerpc/mm/gup.c
index d7efdbf..4b921af 100644
--- a/arch/powerpc/mm/gup.c
+++ b/arch/powerpc/mm/gup.c
@@ -68,7 +68,11 @@ static int gup_pmd_range(pud_t pud, unsigned long addr, unsigned long end,
 		next = pmd_addr_end(addr, end);
 		if (pmd_none(pmd))
 			return 0;
-		if (is_hugepd(pmdp)) {
+		if (pmd_huge(pmd)) {
+			if (!gup_hugepte((pte_t *)pmdp, PMD_SIZE, addr, next,
+					 write, pages, nr))
+				return 0;
+		} else if (is_hugepd(pmdp)) {
 			if (!gup_hugepd((hugepd_t *)pmdp, PMD_SHIFT,
 					addr, next, write, pages, nr))
 				return 0;
@@ -92,7 +96,11 @@ static int gup_pud_range(pgd_t pgd, unsigned long addr, unsigned long end,
 		next = pud_addr_end(addr, end);
 		if (pud_none(pud))
 			return 0;
-		if (is_hugepd(pudp)) {
+		if (pud_huge(pud)) {
+			if (!gup_hugepte((pte_t *)pudp, PUD_SIZE, addr, next,
+					 write, pages, nr))
+				return 0;
+		} else if (is_hugepd(pudp)) {
 			if (!gup_hugepd((hugepd_t *)pudp, PUD_SHIFT,
 					addr, next, write, pages, nr))
 				return 0;
@@ -153,7 +161,11 @@ int get_user_pages_fast(unsigned long start, int nr_pages, int write,
 		next = pgd_addr_end(addr, end);
 		if (pgd_none(pgd))
 			goto slow;
-		if (is_hugepd(pgdp)) {
+		if (pgd_huge(pgd)) {
+			if (!gup_hugepte((pte_t *)pgdp, PGDIR_SIZE, addr, next,
+					 write, pages, &nr))
+				goto slow;
+		} else if (is_hugepd(pgdp)) {
 			if (!gup_hugepd((hugepd_t *)pgdp, PGDIR_SHIFT,
 					addr, next, write, pages, &nr))
 				goto slow;
diff --git a/arch/powerpc/mm/hugetlbpage.c b/arch/powerpc/mm/hugetlbpage.c
index b5f4a5f..fbe6be7 100644
--- a/arch/powerpc/mm/hugetlbpage.c
+++ b/arch/powerpc/mm/hugetlbpage.c
@@ -50,11 +50,69 @@ static unsigned nr_gpages;
 
 #define hugepd_none(hpd)	((hpd).pd == 0)
 
+#ifdef CONFIG_PPC_BOOK3S_64
+/*
+ * At this point we do the placement change only for BOOK3S 64. This would
+ * possibly work on other subarchs.
+ */
+
+/*
+ * We have PGD_INDEX_SIZ = 12 and PTE_INDEX_SIZE = 8, so that we can have
+ * 16GB hugepage pte in PGD and 16MB hugepage pte at PMD;
+ */
+int pmd_huge(pmd_t pmd)
+{
+	/*
+	 * leaf pte for huge page, bottom two bits != 00
+	 */
+	return ((pmd_val(pmd) & 0x3) != 0x0);
+}
+
+int pud_huge(pud_t pud)
+{
+	/*
+	 * leaf pte for huge page, bottom two bits != 00
+	 */
+	return ((pud_val(pud) & 0x3) != 0x0);
+}
+
+int pgd_huge(pgd_t pgd)
+{
+	/*
+	 * leaf pte for huge page, bottom two bits != 00
+	 */
+	return ((pgd_val(pgd) & 0x3) != 0x0);
+}
+#else
+int pmd_huge(pmd_t pmd)
+{
+	return 0;
+}
+
+int pud_huge(pud_t pud)
+{
+	return 0;
+}
+
+int pgd_huge(pgd_t pgd)
+{
+	return 0;
+}
+#endif
+
+/*
+ * We have 4 cases for pgds and pmds:
+ * (1) invalid (all zeroes)
+ * (2) pointer to next table, as normal; bottom 6 bits == 0
+ * (3) leaf pte for huge page, bottom two bits != 00
+ * (4) hugepd pointer, bottom two bits == 00, next 4 bits indicate size of table
+ */
 pte_t *find_linux_pte_or_hugepte(pgd_t *pgdir, unsigned long ea, unsigned *shift)
 {
 	pgd_t *pg;
 	pud_t *pu;
 	pmd_t *pm;
+	pte_t *ret_pte;
 	hugepd_t *hpdp = NULL;
 	unsigned pdshift = PGDIR_SHIFT;
 
@@ -62,30 +120,43 @@ pte_t *find_linux_pte_or_hugepte(pgd_t *pgdir, unsigned long ea, unsigned *shift
 		*shift = 0;
 
 	pg = pgdir + pgd_index(ea);
-	if (is_hugepd(pg)) {
+
+	if (pgd_huge(*pg)) {
+		ret_pte = (pte_t *) pg;
+		goto out;
+	} else if (is_hugepd(pg))
 		hpdp = (hugepd_t *)pg;
-	} else if (!pgd_none(*pg)) {
+	else if (!pgd_none(*pg)) {
 		pdshift = PUD_SHIFT;
 		pu = pud_offset(pg, ea);
-		if (is_hugepd(pu))
+
+		if (pud_huge(*pu)) {
+			ret_pte = (pte_t *) pu;
+			goto out;
+		} else if (is_hugepd(pu))
 			hpdp = (hugepd_t *)pu;
 		else if (!pud_none(*pu)) {
 			pdshift = PMD_SHIFT;
 			pm = pmd_offset(pu, ea);
-			if (is_hugepd(pm))
+
+			if (pmd_huge(*pm)) {
+				ret_pte = (pte_t *) pm;
+				goto out;
+			} else if (is_hugepd(pm))
 				hpdp = (hugepd_t *)pm;
-			else if (!pmd_none(*pm)) {
+			else if (!pmd_none(*pm))
 				return pte_offset_kernel(pm, ea);
-			}
 		}
 	}
-
 	if (!hpdp)
 		return NULL;
 
+	ret_pte = hugepte_offset(hpdp, ea, pdshift);
+	pdshift = hugepd_shift(*hpdp);
+out:
 	if (shift)
-		*shift = hugepd_shift(*hpdp);
-	return hugepte_offset(hpdp, ea, pdshift);
+		*shift = pdshift;
+	return ret_pte;
 }
 EXPORT_SYMBOL_GPL(find_linux_pte_or_hugepte);
 
@@ -165,6 +236,61 @@ static int __hugepte_alloc(struct mm_struct *mm, hugepd_t *hpdp,
 #define HUGEPD_PUD_SHIFT PMD_SHIFT
 #endif
 
+#ifdef CONFIG_PPC_BOOK3S_64
+/*
+ * At this point we do the placement change only for BOOK3S 64. This would
+ * possibly work on other subarchs.
+ */
+pte_t *huge_pte_alloc(struct mm_struct *mm, unsigned long addr, unsigned long sz)
+{
+	pgd_t *pg;
+	pud_t *pu;
+	pmd_t *pm;
+	hugepd_t *hpdp = NULL;
+	unsigned pshift = __ffs(sz);
+	unsigned pdshift = PGDIR_SHIFT;
+
+	addr &= ~(sz-1);
+	pg = pgd_offset(mm, addr);
+
+	if (pshift == PGDIR_SHIFT)
+		/* 16GB huge page */
+		return (pte_t *) pg;
+	else if (pshift > PUD_SHIFT)
+		/*
+		 * We need to use hugepd table
+		 */
+		hpdp = (hugepd_t *)pg;
+	else {
+		pdshift = PUD_SHIFT;
+		pu = pud_alloc(mm, pg, addr);
+		if (pshift == PUD_SHIFT)
+			return (pte_t *)pu;
+		else if (pshift > PMD_SHIFT)
+			hpdp = (hugepd_t *)pu;
+		else {
+			pdshift = PMD_SHIFT;
+			pm = pmd_alloc(mm, pu, addr);
+			if (pshift == PMD_SHIFT)
+				/* 16MB hugepage */
+				return (pte_t *)pm;
+			else
+				hpdp = (hugepd_t *)pm;
+		}
+	}
+	if (!hpdp)
+		return NULL;
+
+	BUG_ON(!hugepd_none(*hpdp) && !hugepd_ok(*hpdp));
+
+	if (hugepd_none(*hpdp) && __hugepte_alloc(mm, hpdp, addr, pdshift, pshift))
+		return NULL;
+
+	return hugepte_offset(hpdp, addr, pdshift);
+}
+
+#else
+
 pte_t *huge_pte_alloc(struct mm_struct *mm, unsigned long addr, unsigned long sz)
 {
 	pgd_t *pg;
@@ -202,6 +328,7 @@ pte_t *huge_pte_alloc(struct mm_struct *mm, unsigned long addr, unsigned long sz
 
 	return hugepte_offset(hpdp, addr, pdshift);
 }
+#endif
 
 #ifdef CONFIG_PPC_FSL_BOOK3E
 /* Build list of addresses of gigantic pages.  This function is used in early
@@ -465,7 +592,7 @@ static void hugetlb_free_pmd_range(struct mmu_gather *tlb, pud_t *pud,
 	do {
 		pmd = pmd_offset(pud, addr);
 		next = pmd_addr_end(addr, end);
-		if (pmd_none(*pmd))
+		if (pmd_none_or_clear_bad(pmd))
 			continue;
 #ifdef CONFIG_PPC_FSL_BOOK3E
 		/*
@@ -618,16 +745,6 @@ follow_huge_addr(struct mm_struct *mm, unsigned long address, int write)
 	return page;
 }
 
-int pmd_huge(pmd_t pmd)
-{
-	return 0;
-}
-
-int pud_huge(pud_t pud)
-{
-	return 0;
-}
-
 struct page *
 follow_huge_pmd(struct mm_struct *mm, unsigned long address,
 		pmd_t *pmd, int write)
@@ -636,8 +753,8 @@ follow_huge_pmd(struct mm_struct *mm, unsigned long address,
 	return NULL;
 }
 
-static noinline int gup_hugepte(pte_t *ptep, unsigned long sz, unsigned long addr,
-		       unsigned long end, int write, struct page **pages, int *nr)
+int gup_hugepte(pte_t *ptep, unsigned long sz, unsigned long addr,
+		unsigned long end, int write, struct page **pages, int *nr)
 {
 	unsigned long mask;
 	unsigned long pte_end;
@@ -873,11 +990,16 @@ static int __init hugetlbpage_init(void)
 			pdshift = PUD_SHIFT;
 		else
 			pdshift = PGDIR_SHIFT;
-
-		pgtable_cache_add(pdshift - shift, NULL);
-		if (!PGT_CACHE(pdshift - shift))
-			panic("hugetlbpage_init(): could not create "
-			      "pgtable cache for %d bit pagesize\n", shift);
+		/*
+		 * if we have pdshift and shift value same, we don't
+		 * use pgt cache for hugepd.
+		 */
+		if (pdshift != shift) {
+			pgtable_cache_add(pdshift - shift, NULL);
+			if (!PGT_CACHE(pdshift - shift))
+				panic("hugetlbpage_init(): could not create "
+				      "pgtable cache for %d bit pagesize\n", shift);
+		}
 	}
 
 	/* Set default large page size. Currently, we pick 16M or 1M
-- 
1.8.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
