Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f170.google.com (mail-qk0-f170.google.com [209.85.220.170])
	by kanga.kvack.org (Postfix) with ESMTP id E44EC82F8A
	for <linux-mm@kvack.org>; Mon, 19 Oct 2015 16:09:34 -0400 (EDT)
Received: by qkfm62 with SMTP id m62so89375714qkf.1
        for <linux-mm@kvack.org>; Mon, 19 Oct 2015 13:09:34 -0700 (PDT)
Received: from emea01-am1-obe.outbound.protection.outlook.com (mail-am1on0062.outbound.protection.outlook.com. [157.56.112.62])
        by mx.google.com with ESMTPS id hc7si21516879wjc.53.2015.10.19.13.09.32
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 19 Oct 2015 13:09:33 -0700 (PDT)
From: David Woods <dwoods@ezchip.com>
Subject: [PATCH v2] arm64: Add support for PTE contiguous bit.
Date: Mon, 19 Oct 2015 16:09:09 -0400
Message-ID: <1445285349-13242-1-git-send-email-dwoods@ezchip.com>
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
 arch/arm64/Kconfig                     |   3 -
 arch/arm64/include/asm/hugetlb.h       |  30 ++---
 arch/arm64/include/asm/pgtable-hwdef.h |  20 ++++
 arch/arm64/include/asm/pgtable.h       |  33 +++++-
 arch/arm64/mm/hugetlbpage.c            | 211 ++++++++++++++++++++++++++++++++-
 5 files changed, 272 insertions(+), 25 deletions(-)

diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
index 07d1811..3aa151d 100644
--- a/arch/arm64/Kconfig
+++ b/arch/arm64/Kconfig
@@ -464,9 +464,6 @@ config HW_PERF_EVENTS
 config SYS_SUPPORTS_HUGETLBFS
 	def_bool y
 
-config ARCH_WANT_GENERAL_HUGETLB
-	def_bool y
-
 config ARCH_WANT_HUGE_PMD_SHARE
 	def_bool y if !ARM64_64K_PAGES
 
diff --git a/arch/arm64/include/asm/hugetlb.h b/arch/arm64/include/asm/hugetlb.h
index bb4052e..2b153a9 100644
--- a/arch/arm64/include/asm/hugetlb.h
+++ b/arch/arm64/include/asm/hugetlb.h
@@ -26,12 +26,6 @@ static inline pte_t huge_ptep_get(pte_t *ptep)
 	return *ptep;
 }
 
-static inline void set_huge_pte_at(struct mm_struct *mm, unsigned long addr,
-				   pte_t *ptep, pte_t pte)
-{
-	set_pte_at(mm, addr, ptep, pte);
-}
-
 static inline void huge_ptep_clear_flush(struct vm_area_struct *vma,
 					 unsigned long addr, pte_t *ptep)
 {
@@ -44,19 +38,6 @@ static inline void huge_ptep_set_wrprotect(struct mm_struct *mm,
 	ptep_set_wrprotect(mm, addr, ptep);
 }
 
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
-
 static inline void hugetlb_free_pgd_range(struct mmu_gather *tlb,
 					  unsigned long addr, unsigned long end,
 					  unsigned long floor,
@@ -97,4 +78,15 @@ static inline void arch_clear_hugepage_flags(struct page *page)
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
+
 #endif /* __ASM_HUGETLB_H */
diff --git a/arch/arm64/include/asm/pgtable-hwdef.h b/arch/arm64/include/asm/pgtable-hwdef.h
index 24154b0..1b921a5 100644
--- a/arch/arm64/include/asm/pgtable-hwdef.h
+++ b/arch/arm64/include/asm/pgtable-hwdef.h
@@ -55,6 +55,24 @@
 #define SECTION_MASK		(~(SECTION_SIZE-1))
 
 /*
+ * Contiguous page definitions.
+ */
+#ifdef CONFIG_ARM64_64K_PAGES
+#define CONT_PTE_SHIFT		5
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
+
+/*
  * Hardware page table definitions.
  *
  * Level 1 descriptor (PUD).
@@ -83,6 +101,7 @@
 #define PMD_SECT_S		(_AT(pmdval_t, 3) << 8)
 #define PMD_SECT_AF		(_AT(pmdval_t, 1) << 10)
 #define PMD_SECT_NG		(_AT(pmdval_t, 1) << 11)
+#define PMD_SECT_CONT		(_AT(pmdval_t, 1) << 52)
 #define PMD_SECT_PXN		(_AT(pmdval_t, 1) << 53)
 #define PMD_SECT_UXN		(_AT(pmdval_t, 1) << 54)
 
@@ -105,6 +124,7 @@
 #define PTE_AF			(_AT(pteval_t, 1) << 10)	/* Access Flag */
 #define PTE_NG			(_AT(pteval_t, 1) << 11)	/* nG */
 #define PTE_DBM			(_AT(pteval_t, 1) << 51)	/* Dirty Bit Management */
+#define PTE_CONT		(_AT(pteval_t, 1) << 52)	/* Contiguous */
 #define PTE_PXN			(_AT(pteval_t, 1) << 53)	/* Privileged XN */
 #define PTE_UXN			(_AT(pteval_t, 1) << 54)	/* User XN */
 
diff --git a/arch/arm64/include/asm/pgtable.h b/arch/arm64/include/asm/pgtable.h
index 26b0666..cf079a1 100644
--- a/arch/arm64/include/asm/pgtable.h
+++ b/arch/arm64/include/asm/pgtable.h
@@ -140,6 +140,7 @@ extern struct page *empty_zero_page;
 #define pte_special(pte)	(!!(pte_val(pte) & PTE_SPECIAL))
 #define pte_write(pte)		(!!(pte_val(pte) & PTE_WRITE))
 #define pte_exec(pte)		(!(pte_val(pte) & PTE_UXN))
+#define pte_cont(pte)		(!!(pte_val(pte) & PTE_CONT))
 
 #ifdef CONFIG_ARM64_HW_AFDBM
 #define pte_hw_dirty(pte)	(pte_write(pte) && !(pte_val(pte) & PTE_RDONLY))
@@ -202,6 +203,18 @@ static inline pte_t pte_mkspecial(pte_t pte)
 	return set_pte_bit(pte, __pgprot(PTE_SPECIAL));
 }
 
+static inline pte_t pte_mkcont(pte_t pte)
+{
+	pte = set_pte_bit(pte, __pgprot(PTE_CONT));
+	return set_pte_bit(pte, __pgprot(PTE_TYPE_PAGE));
+	return pte;
+}
+
+static inline pmd_t pmd_mkcont(pmd_t pmd)
+{
+	return __pmd(pmd_val(pmd) | PMD_SECT_CONT);
+}
+
 static inline void set_pte(pte_t *ptep, pte_t pte)
 {
 	*ptep = pte;
@@ -271,7 +284,7 @@ static inline void set_pte_at(struct mm_struct *mm, unsigned long addr,
 /*
  * Hugetlb definitions.
  */
-#define HUGE_MAX_HSTATE		2
+#define HUGE_MAX_HSTATE		((2 * CONFIG_PGTABLE_LEVELS) - 1)
 #define HPAGE_SHIFT		PMD_SHIFT
 #define HPAGE_SIZE		(_AC(1, UL) << HPAGE_SHIFT)
 #define HPAGE_MASK		(~(HPAGE_SIZE - 1))
@@ -496,7 +509,7 @@ static inline pud_t *pud_offset(pgd_t *pgd, unsigned long addr)
 static inline pte_t pte_modify(pte_t pte, pgprot_t newprot)
 {
 	const pteval_t mask = PTE_USER | PTE_PXN | PTE_UXN | PTE_RDONLY |
-			      PTE_PROT_NONE | PTE_VALID | PTE_WRITE;
+			      PTE_PROT_NONE | PTE_VALID | PTE_WRITE | PTE_CONT;
 	/* preserve the hardware dirty information */
 	if (pte_hw_dirty(pte))
 		pte = pte_mkdirty(pte);
@@ -509,6 +522,22 @@ static inline pmd_t pmd_modify(pmd_t pmd, pgprot_t newprot)
 	return pte_pmd(pte_modify(pmd_pte(pmd), newprot));
 }
 
+static inline pte_t pte_modify_pfn(pte_t pte, unsigned long newpfn)
+{
+	const pteval_t mask = PHYS_MASK & PAGE_MASK;
+
+	pte_val(pte) = pfn_pte(newpfn, (pte_val(pte) & ~mask));
+	return pte;
+}
+
+static inline pmd_t pmd_modify_pfn(pmd_t pmd, unsigned long newpfn)
+{
+	const pmdval_t mask = PHYS_MASK & PAGE_MASK;
+
+	pmd = pfn_pmd(newpfn, (pmd_val(pmd) & ~mask));
+	return pmd;
+}
+
 #ifdef CONFIG_ARM64_HW_AFDBM
 /*
  * Atomic pte/pmd modifications.
diff --git a/arch/arm64/mm/hugetlbpage.c b/arch/arm64/mm/hugetlbpage.c
index 383b03f..20fd34c 100644
--- a/arch/arm64/mm/hugetlbpage.c
+++ b/arch/arm64/mm/hugetlbpage.c
@@ -41,6 +41,201 @@ int pud_huge(pud_t pud)
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
+
+	pud = pud_offset(pgd, addr);
+	pmd = pmd_offset(pud, addr);
+	if ((pte_t *)pmd == ptep) {
+		*pgsize = PMD_SIZE;
+		return CONT_PMDS;
+	}
+	*pgsize = PAGE_SIZE;
+	return CONT_PTES;
+}
+
+extern void set_huge_pte_at(struct mm_struct *mm, unsigned long addr,
+			    pte_t *ptep, pte_t pte)
+{
+	size_t pgsize;
+	int ncontig = find_num_contig(mm, addr, ptep, pte, &pgsize);
+
+	if (ncontig == 1) {
+		set_pte_at(mm, addr, ptep, pte);
+	} else {
+		int i;
+		unsigned long pfn = pte_pfn(pte);
+		pgprot_t hugeprot =
+			__pgprot(pte_val(pfn_pte(pfn, 0) ^ pte_val(pte)));
+		for (i = 0; i < ncontig; i++) {
+			pr_debug("%s: set pte %p to 0x%llx\n", __func__, ptep,
+				 pfn_pte(pfn, hugeprot));
+			set_pte_at(mm, addr, ptep, pfn_pte(pfn, hugeprot));
+			ptep++;
+			pfn += pgsize / PAGE_SIZE;
+			addr += pgsize;
+		}
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
+	if (pud) {
+		if (sz == PUD_SIZE) {
+			pte = (pte_t *)pud;
+		} else if (sz == (PAGE_SIZE * CONT_PTES)) {
+			pmd_t *pmd = pmd_alloc(mm, pud, addr);
+
+			WARN_ON(addr & (sz - 1));
+			pte = pte_alloc_map(mm, NULL, pmd, addr);
+		} else if (sz == PMD_SIZE) {
+#ifdef CONFIG_ARCH_WANT_HUGE_PMD_SHARE
+			if (pud_none(*pud))
+				pte = huge_pmd_share(mm, addr, pud);
+			else
+#endif
+				pte = (pte_t *)pmd_alloc(mm, pud, addr);
+		} else if (sz == (PMD_SIZE * CONT_PMDS)) {
+			pmd_t *pmd;
+
+			pmd = pmd_alloc(mm, pud, addr);
+			WARN_ON(addr & (sz - 1));
+			return (pte_t *)pmd;
+		}
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
+	if (pgd_present(*pgd)) {
+		pud = pud_offset(pgd, addr);
+		if (pud_present(*pud)) {
+			if (pud_huge(*pud))
+				return (pte_t *)pud;
+			pmd = pmd_offset(pud, addr);
+			if (pmd_present(*pmd)) {
+				if (pte_cont(pmd_pte(*pmd))) {
+					pmd = pmd_offset(
+						pud, (addr & CONT_PMD_MASK));
+					return (pte_t *)pmd;
+				}
+				if (pmd_huge(*pmd))
+					return (pte_t *)pmd;
+				pte = pte_offset_kernel(pmd, addr);
+				if (pte_present(*pte) && pte_cont(*pte)) {
+					pte = pte_offset_kernel(
+						pmd, (addr & CONT_PTE_MASK));
+				}
+				return pte;
+			}
+		}
+	}
+	return (pte_t *) NULL;
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
+		       __func__, pagesize);
+	}
+	return entry;
+}
+
+extern pte_t huge_ptep_get_and_clear(struct mm_struct *mm,
+				     unsigned long addr, pte_t *ptep)
+{
+	pte_t pte = {0};
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
+			if (pte_dirty(ptep_get_and_clear(mm, addr, ++cpte)))
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
+			pfn += pgsize / PAGE_SIZE;
+		}
+		return changed;
+	} else {
+		return ptep_set_access_flags(vma, addr, ptep, pte, dirty);
+	}
+}
+
+
 static __init int setup_hugepagesz(char *opt)
 {
 	unsigned long ps = memparse(opt, &opt);
@@ -48,10 +243,24 @@ static __init int setup_hugepagesz(char *opt)
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
-- 
2.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
