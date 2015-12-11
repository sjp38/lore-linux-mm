Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f180.google.com (mail-ob0-f180.google.com [209.85.214.180])
	by kanga.kvack.org (Postfix) with ESMTP id B52116B0255
	for <linux-mm@kvack.org>; Fri, 11 Dec 2015 16:02:36 -0500 (EST)
Received: by obciw8 with SMTP id iw8so92343069obc.1
        for <linux-mm@kvack.org>; Fri, 11 Dec 2015 13:02:36 -0800 (PST)
Received: from EUR01-VE1-obe.outbound.protection.outlook.com (mail-ve1eur01on0055.outbound.protection.outlook.com. [104.47.1.55])
        by mx.google.com with ESMTPS id c124si18842381oia.13.2015.12.11.13.02.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 11 Dec 2015 13:02:35 -0800 (PST)
From: David Woods <dwoods@ezchip.com>
Subject: [PATCH v4] arm64: Add support for PTE contiguous bit.
Date: Fri, 11 Dec 2015 16:02:24 -0500
Message-ID: <1449867744-8130-1-git-send-email-dwoods@ezchip.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dwoods@ezchip.com
Cc: catalin.marinas@arm.com, will.deacon@arm.com, steve.capper@linaro.org, jeremy.linton@arm.com, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cmetcalf@ezchip.com

The arm64 MMU supports a Contiguous bit which is a hint that the TTE
is one of a set of contiguous entries which can be cached in a single
TLB entry.  Supporting this bit adds new intermediate huge page sizes.

The set of huge page sizes available depends on the base page size.
Without using contiguous pages the huge page sizes are as follows.

 4KB:   2MB  1GB
64KB: 512MB

With a 4KB granule, the contiguous bit groups together sets of 16 pages
and with a 64KB granule it groups sets of 32 pages.  This enables two new
huge page sizes in each case, so that the full set of available sizes
is as follows.

 4KB:  64KB   2MB  32MB  1GB
64KB:   2MB 512MB  16GB

If a 16KB granule is used then the contiguous bit groups 128 pages
at the PTE level and 32 pages at the PMD level.

If the base page size is set to 64KB then 2MB pages are enabled by
default.  It is possible in the future to make 2MB the default huge
page size for both 4KB and 64KB granules.

Signed-off-by: David Woods <dwoods@ezchip.com>
Reviewed-by: Chris Metcalf <cmetcalf@ezchip.com>
---

This version of the patch addresses all the comments I've received 
to date and is passing the libhugetlbfs tests.  Catalin, assuming 
there are no further comments, can this be considered for the arm64 
next tree?

 arch/arm64/Kconfig                     |   3 -
 arch/arm64/include/asm/hugetlb.h       |  44 ++----
 arch/arm64/include/asm/pgtable-hwdef.h |  18 ++-
 arch/arm64/include/asm/pgtable.h       |  10 +-
 arch/arm64/mm/hugetlbpage.c            | 267 ++++++++++++++++++++++++++++++++-
 include/linux/hugetlb.h                |   2 -
 6 files changed, 306 insertions(+), 38 deletions(-)

diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
index 4876459..ffa3c54 100644
--- a/arch/arm64/Kconfig
+++ b/arch/arm64/Kconfig
@@ -530,9 +530,6 @@ config HW_PERF_EVENTS
 config SYS_SUPPORTS_HUGETLBFS
 	def_bool y
 
-config ARCH_WANT_GENERAL_HUGETLB
-	def_bool y
-
 config ARCH_WANT_HUGE_PMD_SHARE
 	def_bool y if ARM64_4K_PAGES || (ARM64_16K_PAGES && !ARM64_VA_BITS_36)
 
diff --git a/arch/arm64/include/asm/hugetlb.h b/arch/arm64/include/asm/hugetlb.h
index bb4052e..bbc1e35 100644
--- a/arch/arm64/include/asm/hugetlb.h
+++ b/arch/arm64/include/asm/hugetlb.h
@@ -26,36 +26,7 @@ static inline pte_t huge_ptep_get(pte_t *ptep)
 	return *ptep;
 }
 
-static inline void set_huge_pte_at(struct mm_struct *mm, unsigned long addr,
-				   pte_t *ptep, pte_t pte)
-{
-	set_pte_at(mm, addr, ptep, pte);
-}
-
-static inline void huge_ptep_clear_flush(struct vm_area_struct *vma,
-					 unsigned long addr, pte_t *ptep)
-{
-	ptep_clear_flush(vma, addr, ptep);
-}
-
-static inline void huge_ptep_set_wrprotect(struct mm_struct *mm,
-					   unsigned long addr, pte_t *ptep)
-{
-	ptep_set_wrprotect(mm, addr, ptep);
-}
 
-static inline pte_t huge_ptep_get_and_clear(struct mm_struct *mm,
-					    unsigned long addr, pte_t *ptep)
-{
-	return ptep_get_and_clear(mm, addr, ptep);
-}
-
-static inline int huge_ptep_set_access_flags(struct vm_area_struct *vma,
-					     unsigned long addr, pte_t *ptep,
-					     pte_t pte, int dirty)
-{
-	return ptep_set_access_flags(vma, addr, ptep, pte, dirty);
-}
 
 static inline void hugetlb_free_pgd_range(struct mmu_gather *tlb,
 					  unsigned long addr, unsigned long end,
@@ -97,4 +68,19 @@ static inline void arch_clear_hugepage_flags(struct page *page)
 	clear_bit(PG_dcache_clean, &page->flags);
 }
 
+extern pte_t arch_make_huge_pte(pte_t entry, struct vm_area_struct *vma,
+				struct page *page, int writable);
+#define arch_make_huge_pte arch_make_huge_pte
+extern void set_huge_pte_at(struct mm_struct *mm, unsigned long addr,
+			    pte_t *ptep, pte_t pte);
+extern int huge_ptep_set_access_flags(struct vm_area_struct *vma,
+				      unsigned long addr, pte_t *ptep,
+				      pte_t pte, int dirty);
+extern pte_t huge_ptep_get_and_clear(struct mm_struct *mm,
+				     unsigned long addr, pte_t *ptep);
+extern void huge_ptep_set_wrprotect(struct mm_struct *mm,
+				    unsigned long addr, pte_t *ptep);
+extern void huge_ptep_clear_flush(struct vm_area_struct *vma,
+				  unsigned long addr, pte_t *ptep);
+
 #endif /* __ASM_HUGETLB_H */
diff --git a/arch/arm64/include/asm/pgtable-hwdef.h b/arch/arm64/include/asm/pgtable-hwdef.h
index d6739e8..5c25b83 100644
--- a/arch/arm64/include/asm/pgtable-hwdef.h
+++ b/arch/arm64/include/asm/pgtable-hwdef.h
@@ -90,7 +90,23 @@
 /*
  * Contiguous page definitions.
  */
-#define CONT_PTES		(_AC(1, UL) << CONT_SHIFT)
+#ifdef CONFIG_ARM64_64K_PAGES
+#define CONT_PTE_SHIFT		5
+#define CONT_PMD_SHIFT		5
+#elif defined(CONFIG_ARM64_16K_PAGES)
+#define CONT_PTE_SHIFT		7
+#define CONT_PMD_SHIFT		5
+#else
+#define CONT_PTE_SHIFT		4
+#define CONT_PMD_SHIFT		4
+#endif
+
+#define CONT_PTES		(1 << CONT_PTE_SHIFT)
+#define CONT_PTE_SIZE		(CONT_PTES * PAGE_SIZE)
+#define CONT_PTE_MASK		(~(CONT_PTE_SIZE - 1))
+#define CONT_PMDS		(1 << CONT_PMD_SHIFT)
+#define CONT_PMD_SIZE		(CONT_PMDS * PMD_SIZE)
+#define CONT_PMD_MASK		(~(CONT_PMD_SIZE - 1))
 /* the the numerical offset of the PTE within a range of CONT_PTES */
 #define CONT_RANGE_OFFSET(addr) (((addr)>>PAGE_SHIFT)&(CONT_PTES-1))
 
diff --git a/arch/arm64/include/asm/pgtable.h b/arch/arm64/include/asm/pgtable.h
index 450b355..35a318c 100644
--- a/arch/arm64/include/asm/pgtable.h
+++ b/arch/arm64/include/asm/pgtable.h
@@ -227,7 +227,8 @@ static inline pte_t pte_mkspecial(pte_t pte)
 
 static inline pte_t pte_mkcont(pte_t pte)
 {
-	return set_pte_bit(pte, __pgprot(PTE_CONT));
+	pte = set_pte_bit(pte, __pgprot(PTE_CONT));
+	return set_pte_bit(pte, __pgprot(PTE_TYPE_PAGE));
 }
 
 static inline pte_t pte_mknoncont(pte_t pte)
@@ -235,6 +236,11 @@ static inline pte_t pte_mknoncont(pte_t pte)
 	return clear_pte_bit(pte, __pgprot(PTE_CONT));
 }
 
+static inline pmd_t pmd_mkcont(pmd_t pmd)
+{
+	return __pmd(pmd_val(pmd) | PMD_SECT_CONT);
+}
+
 static inline void set_pte(pte_t *ptep, pte_t pte)
 {
 	*ptep = pte;
@@ -304,7 +310,7 @@ static inline void set_pte_at(struct mm_struct *mm, unsigned long addr,
 /*
  * Hugetlb definitions.
  */
-#define HUGE_MAX_HSTATE		2
+#define HUGE_MAX_HSTATE		4
 #define HPAGE_SHIFT		PMD_SHIFT
 #define HPAGE_SIZE		(_AC(1, UL) << HPAGE_SHIFT)
 #define HPAGE_MASK		(~(HPAGE_SIZE - 1))
diff --git a/arch/arm64/mm/hugetlbpage.c b/arch/arm64/mm/hugetlbpage.c
index 383b03f..39a5e67 100644
--- a/arch/arm64/mm/hugetlbpage.c
+++ b/arch/arm64/mm/hugetlbpage.c
@@ -41,17 +41,282 @@ int pud_huge(pud_t pud)
 #endif
 }
 
+static int find_num_contig(struct mm_struct *mm, unsigned long addr,
+			   pte_t *ptep, pte_t pte, size_t *pgsize)
+{
+	pgd_t *pgd = pgd_offset(mm, addr);
+	pud_t *pud;
+	pmd_t *pmd;
+
+	if (!pte_cont(pte))
+		return 1;
+	if (!pgd_present(*pgd)) {
+		VM_BUG_ON(!pgd_present(*pgd));
+		return 1;
+	}
+	pud = pud_offset(pgd, addr);
+	if (!pud_present(*pud)) {
+		VM_BUG_ON(!pud_present(*pud));
+		return 1;
+	}
+	pmd = pmd_offset(pud, addr);
+	if (!pmd_present(*pmd)) {
+		VM_BUG_ON(!pmd_present(*pmd));
+		return 1;
+	}
+	if ((pte_t *)pmd == ptep) {
+		*pgsize = PMD_SIZE;
+		return CONT_PMDS;
+	}
+	*pgsize = PAGE_SIZE;
+	return CONT_PTES;
+}
+
+void set_huge_pte_at(struct mm_struct *mm, unsigned long addr,
+			    pte_t *ptep, pte_t pte)
+{
+	size_t pgsize;
+	int i;
+	int ncontig = find_num_contig(mm, addr, ptep, pte, &pgsize);
+	unsigned long pfn;
+	pgprot_t hugeprot;
+
+	if (ncontig == 1) {
+		set_pte_at(mm, addr, ptep, pte);
+		return;
+	}
+
+	pfn = pte_pfn(pte);
+	hugeprot = __pgprot(pte_val(pfn_pte(pfn, 0)) ^ pte_val(pte));
+	for (i = 0; i < ncontig; i++) {
+		pr_debug("%s: set pte %p to 0x%llx\n", __func__, ptep,
+			 pfn_pte(pfn, hugeprot));
+		set_pte_at(mm, addr, ptep, pfn_pte(pfn, hugeprot));
+		ptep++;
+		pfn += pgsize >> PAGE_SHIFT;
+		addr += pgsize;
+	}
+}
+
+pte_t *huge_pte_alloc(struct mm_struct *mm,
+		      unsigned long addr, unsigned long sz)
+{
+	pgd_t *pgd;
+	pud_t *pud;
+	pte_t *pte = NULL;
+
+	pr_debug("%s: addr:0x%lx sz:0x%lx\n", __func__, addr, sz);
+	pgd = pgd_offset(mm, addr);
+	pud = pud_alloc(mm, pgd, addr);
+	if (!pud)
+		return NULL;
+
+	if (sz == PUD_SIZE) {
+		pte = (pte_t *)pud;
+	} else if (sz == (PAGE_SIZE * CONT_PTES)) {
+		pmd_t *pmd = pmd_alloc(mm, pud, addr);
+
+		WARN_ON(addr & (sz - 1));
+		pte = pte_alloc_map(mm, NULL, pmd, addr);
+	} else if (sz == PMD_SIZE) {
+		if (IS_ENABLED(CONFIG_ARCH_WANT_HUGE_PMD_SHARE) &&
+		    pud_none(*pud))
+			pte = huge_pmd_share(mm, addr, pud);
+		else
+			pte = (pte_t *)pmd_alloc(mm, pud, addr);
+	} else if (sz == (PMD_SIZE * CONT_PMDS)) {
+		pmd_t *pmd;
+
+		pmd = pmd_alloc(mm, pud, addr);
+		WARN_ON(addr & (sz - 1));
+		return (pte_t *)pmd;
+	}
+
+	pr_debug("%s: addr:0x%lx sz:0x%lx ret pte=%p/0x%llx\n", __func__, addr,
+	       sz, pte, pte_val(*pte));
+	return pte;
+}
+
+pte_t *huge_pte_offset(struct mm_struct *mm, unsigned long addr)
+{
+	pgd_t *pgd;
+	pud_t *pud;
+	pmd_t *pmd = NULL;
+	pte_t *pte = NULL;
+
+	pgd = pgd_offset(mm, addr);
+	pr_debug("%s: addr:0x%lx pgd:%p\n", __func__, addr, pgd);
+	if (!pgd_present(*pgd))
+		return NULL;
+	pud = pud_offset(pgd, addr);
+	if (!pud_present(*pud))
+		return NULL;
+
+	if (pud_huge(*pud))
+		return (pte_t *)pud;
+	pmd = pmd_offset(pud, addr);
+	if (!pmd_present(*pmd))
+		return NULL;
+
+	if (pte_cont(pmd_pte(*pmd))) {
+		pmd = pmd_offset(
+			pud, (addr & CONT_PMD_MASK));
+		return (pte_t *)pmd;
+	}
+	if (pmd_huge(*pmd))
+		return (pte_t *)pmd;
+	pte = pte_offset_kernel(pmd, addr);
+	if (pte_present(*pte) && pte_cont(*pte)) {
+		pte = pte_offset_kernel(
+			pmd, (addr & CONT_PTE_MASK));
+	}
+	return pte;
+}
+
+pte_t arch_make_huge_pte(pte_t entry, struct vm_area_struct *vma,
+			 struct page *page, int writable)
+{
+	size_t pagesize = huge_page_size(hstate_vma(vma));
+
+	if (pagesize == CONT_PTE_SIZE) {
+		entry = pte_mkcont(entry);
+	} else if (pagesize == CONT_PMD_SIZE) {
+		entry = pmd_pte(pmd_mkcont(pte_pmd(entry)));
+	} else if (pagesize != PUD_SIZE && pagesize != PMD_SIZE) {
+		pr_warn("%s: unrecognized huge page size 0x%lx\n",
+			__func__, pagesize);
+	}
+	return entry;
+}
+
+pte_t huge_ptep_get_and_clear(struct mm_struct *mm,
+			      unsigned long addr, pte_t *ptep)
+{
+	pte_t pte;
+
+	if (pte_cont(*ptep)) {
+		int ncontig, i;
+		size_t pgsize;
+		pte_t *cpte;
+		bool is_dirty = false;
+
+		cpte = huge_pte_offset(mm, addr);
+		ncontig = find_num_contig(mm, addr, cpte,
+					  pte_val(*cpte), &pgsize);
+		/* save the 1st pte to return */
+		pte = ptep_get_and_clear(mm, addr, cpte);
+		for (i = 1; i < ncontig; ++i) {
+			/*
+			 * If HW_AFDBM is enabled, then the HW could
+			 * turn on the dirty bit for any of the page
+			 * in the set, so check them all.
+			 */
+			++cpte;
+			if (pte_dirty(ptep_get_and_clear(mm, addr, cpte)))
+				is_dirty = true;
+		}
+		if (is_dirty)
+			return pte_mkdirty(pte);
+		else
+			return pte;
+	} else {
+		return ptep_get_and_clear(mm, addr, ptep);
+	}
+}
+
+int huge_ptep_set_access_flags(struct vm_area_struct *vma,
+			       unsigned long addr, pte_t *ptep,
+			       pte_t pte, int dirty)
+{
+	pte_t *cpte;
+
+	if (pte_cont(pte)) {
+		int ncontig, i, changed = 0;
+		size_t pgsize = 0;
+		unsigned long pfn = pte_pfn(pte);
+		/* Select all bits except the pfn */
+		pgprot_t hugeprot =
+			__pgprot(pte_val(pfn_pte(pfn, 0) ^ pte_val(pte)));
+
+		cpte = huge_pte_offset(vma->vm_mm, addr);
+		pfn = pte_pfn(*cpte);
+		ncontig = find_num_contig(vma->vm_mm, addr, cpte,
+					  pte_val(*cpte), &pgsize);
+		for (i = 0; i < ncontig; ++i, ++cpte) {
+			changed = ptep_set_access_flags(vma, addr, cpte,
+							pfn_pte(pfn,
+								hugeprot),
+							dirty);
+			pfn += pgsize >> PAGE_SHIFT;
+		}
+		return changed;
+	} else {
+		return ptep_set_access_flags(vma, addr, ptep, pte, dirty);
+	}
+}
+
+void huge_ptep_set_wrprotect(struct mm_struct *mm,
+			     unsigned long addr, pte_t *ptep)
+{
+	if (pte_cont(*ptep)) {
+		int ncontig, i;
+		pte_t *cpte;
+		size_t pgsize = 0;
+
+		cpte = huge_pte_offset(mm, addr);
+		ncontig = find_num_contig(mm, addr, cpte,
+					  pte_val(*cpte), &pgsize);
+		for (i = 0; i < ncontig; ++i, ++cpte)
+			ptep_set_wrprotect(mm, addr, cpte);
+	} else {
+		ptep_set_wrprotect(mm, addr, ptep);
+	}
+}
+
+void huge_ptep_clear_flush(struct vm_area_struct *vma,
+			   unsigned long addr, pte_t *ptep)
+{
+	if (pte_cont(*ptep)) {
+		int ncontig, i;
+		pte_t *cpte;
+		size_t pgsize = 0;
+
+		cpte = huge_pte_offset(vma->vm_mm, addr);
+		ncontig = find_num_contig(vma->vm_mm, addr, cpte,
+					  pte_val(*cpte), &pgsize);
+		for (i = 0; i < ncontig; ++i, ++cpte)
+			ptep_clear_flush(vma, addr, cpte);
+	} else {
+		ptep_clear_flush(vma, addr, ptep);
+	}
+}
+
 static __init int setup_hugepagesz(char *opt)
 {
 	unsigned long ps = memparse(opt, &opt);
+
 	if (ps == PMD_SIZE) {
 		hugetlb_add_hstate(PMD_SHIFT - PAGE_SHIFT);
 	} else if (ps == PUD_SIZE) {
 		hugetlb_add_hstate(PUD_SHIFT - PAGE_SHIFT);
+	} else if (ps == (PAGE_SIZE * CONT_PTES)) {
+		hugetlb_add_hstate(CONT_PTE_SHIFT);
+	} else if (ps == (PMD_SIZE * CONT_PMDS)) {
+		hugetlb_add_hstate((PMD_SHIFT + CONT_PMD_SHIFT) - PAGE_SHIFT);
 	} else {
-		pr_err("hugepagesz: Unsupported page size %lu M\n", ps >> 20);
+		pr_err("hugepagesz: Unsupported page size %lu K\n", ps >> 10);
 		return 0;
 	}
 	return 1;
 }
 __setup("hugepagesz=", setup_hugepagesz);
+
+#ifdef CONFIG_ARM64_64K_PAGES
+static __init int add_default_hugepagesz(void)
+{
+	if (size_to_hstate(CONT_PTES * PAGE_SIZE) == NULL)
+		hugetlb_add_hstate(CONT_PMD_SHIFT);
+	return 0;
+}
+arch_initcall(add_default_hugepagesz);
+#endif
diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index 685c262..b0eb064 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -96,9 +96,7 @@ u32 hugetlb_fault_mutex_hash(struct hstate *h, struct mm_struct *mm,
 				struct address_space *mapping,
 				pgoff_t idx, unsigned long address);
 
-#ifdef CONFIG_ARCH_WANT_HUGE_PMD_SHARE
 pte_t *huge_pmd_share(struct mm_struct *mm, unsigned long addr, pud_t *pud);
-#endif
 
 extern int hugepages_treat_as_movable;
 extern int sysctl_hugetlb_shm_group;
-- 
2.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
