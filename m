Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f178.google.com (mail-ob0-f178.google.com [209.85.214.178])
	by kanga.kvack.org (Postfix) with ESMTP id 8CA546B0282
	for <linux-mm@kvack.org>; Mon, 19 Oct 2015 14:43:52 -0400 (EDT)
Received: by obbda8 with SMTP id da8so146824015obb.1
        for <linux-mm@kvack.org>; Mon, 19 Oct 2015 11:43:52 -0700 (PDT)
Received: from emea01-db3-obe.outbound.protection.outlook.com (mail-db3on0089.outbound.protection.outlook.com. [157.55.234.89])
        by mx.google.com with ESMTPS id n9si18027808oex.32.2015.10.19.11.43.50
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 19 Oct 2015 11:43:51 -0700 (PDT)
Subject: Re: [PATCH] arm64: Add support for PTE contiguous bit.
References: <1442340117-3964-1-git-send-email-dwoods@ezchip.com>
 <20150916140620.GA1856@linaro.org>
From: David Woods <dwoods@ezchip.com>
Message-ID: <562539CC.5090602@ezchip.com>
Date: Mon, 19 Oct 2015 14:43:24 -0400
MIME-Version: 1.0
In-Reply-To: <20150916140620.GA1856@linaro.org>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steve Capper <steve.capper@linaro.org>
Cc: Chris Metcalf <cmetcalf@ezchip.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Marc Zyngier <marc.zyngier@arm.com>, Hugh Dickins <hughd@google.com>, Mike Kravetz <mike.kravetz@oracle.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Andrew Morton <akpm@linux-foundation.org>, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org



On 09/16/2015 10:06 AM, Steve Capper wrote:
> Hi David,
> Some initial comments below.
>
> Cheers,
> -- Steve On Tue, Sep 15, 2015 at 02:01:57PM -0400, David Woods wrote:
>> >The arm64 MMU supports a Contiguous bit which is a hint that the TTE
>> >is one of a set of contiguous entries which can be cached in a single
>> >TLB entry.  Supporting this bit adds new intermediate huge page sizes.
>> >
>> >The set of huge page sizes available depends on the base page size.
>> >Without using contiguous pages the huge page sizes are as follows.
>> >
>> >  4KB:   2MB  1GB
>> >64KB: 512MB  4TB
>> >
>> >With 4KB pages, the contiguous bit groups together sets of 16 pages
>> >and with 64KB pages it groups sets of 32 pages.  This enables two new
>> >huge page sizes in each case, so that the full set of available sizes
>> >is as follows.
>> >
>> >  4KB:  64KB   2MB  32MB  1GB
>> >64KB:   2MB 512MB  16GB  4TB
>> >
>> >If the base page size is set to 64KB then 2MB pages are enabled by
>> >default.  It is possible in the future to make 2MB the default huge
>> >page size for both 4KB and 64KB pages.
>> >
>> >Signed-off-by: David Woods<dwoods@ezchip.com>
>> >Reviewed-by: Chris Metcalf<cmetcalf@ezchip.com>
>> >---
>> >  arch/arm64/Kconfig                     |   3 -
>> >  arch/arm64/include/asm/hugetlb.h       |   4 +
>> >  arch/arm64/include/asm/pgtable-hwdef.h |  15 +++
>> >  arch/arm64/include/asm/pgtable.h       |  30 +++++-
>> >  arch/arm64/mm/hugetlbpage.c            | 165 ++++++++++++++++++++++++++++++++-
>> >  5 files changed, 210 insertions(+), 7 deletions(-)
>> >
>> >
>> >diff --git a/arch/arm64/include/asm/pgtable-hwdef.h b/arch/arm64/include/asm/pgtable-hwdef.h
>> >index 24154b0..da73243 100644
>> >--- a/arch/arm64/include/asm/pgtable-hwdef.h
>> >+++ b/arch/arm64/include/asm/pgtable-hwdef.h
>> >@@ -55,6 +55,19 @@
>> >  #define SECTION_MASK		(~(SECTION_SIZE-1))
>> >  
>> >  /*
>> >+ * Contiguous large page definitions.
>> >+ */
>> >+#ifdef CONFIG_ARM64_64K_PAGES
>> >+#define	CONTIG_SHIFT		5
>> >+#define CONTIG_PAGES		32
>> >+#else
>> >+#define	CONTIG_SHIFT		4
>> >+#define CONTIG_PAGES		16
>> >+#endif
>> >+#define	CONTIG_PTE_SIZE		(CONTIG_PAGES * PAGE_SIZE)
>> >+#define	CONTIG_PTE_MASK		(~(CONTIG_PTE_SIZE - 1))
> Careful here, CONTIG_PAGES should really be CONTIG_PTES.
>
> If support is added for a 16KB granule case we are allowed:
> 128 x 16KB pages (ptes) to make a 2MB huge page, or
> 32 x 32MB blocks (pmds) to make a 1GB huge page.
>
> i.e we CONTIG_PTES != CONTIG_PMDs
>
> For 4KB or 64KB pages we are only allowed contiguous pte's so
> CONTIG_PMDS == 0 in these cases.


Steve,

Thanks for pointing this out.  I changed it to allow for different
values for CONT_PTES and CONT_PMDS.  As you say, that should
make it easier to merge with the 16K granule support.

>> >+
>> >+/*
>> >   * Hardware page table definitions.
>> >   *
>> >   * Level 1 descriptor (PUD).
>> >@@ -83,6 +96,7 @@
>> >  #define PMD_SECT_S		(_AT(pmdval_t, 3) << 8)
>> >  #define PMD_SECT_AF		(_AT(pmdval_t, 1) << 10)
>> >  #define PMD_SECT_NG		(_AT(pmdval_t, 1) << 11)
>> >+#define PMD_SECT_CONTIG		(_AT(pmdval_t, 1) << 52)
>> >  #define PMD_SECT_PXN		(_AT(pmdval_t, 1) << 53)
>> >  #define PMD_SECT_UXN		(_AT(pmdval_t, 1) << 54)
>> >  
>> >@@ -105,6 +119,7 @@
>> >  #define PTE_AF			(_AT(pteval_t, 1) << 10)	/* Access Flag */
>> >  #define PTE_NG			(_AT(pteval_t, 1) << 11)	/* nG */
>> >  #define PTE_DBM			(_AT(pteval_t, 1) << 51)	/* Dirty Bit Management */
>> >+#define PTE_CONTIG		(_AT(pteval_t, 1) << 52)	/* Contiguous */
>> >  #define PTE_PXN			(_AT(pteval_t, 1) << 53)	/* Privileged XN */
>> >  #define PTE_UXN			(_AT(pteval_t, 1) << 54)	/* User XN */
>> >  
>> >diff --git a/arch/arm64/include/asm/pgtable.h b/arch/arm64/include/asm/pgtable.h
>> >index 6900b2d9..df5ec64 100644
>> >--- a/arch/arm64/include/asm/pgtable.h
>> >+++ b/arch/arm64/include/asm/pgtable.h
>> >@@ -144,6 +144,7 @@ extern struct page *empty_zero_page;
>> >  #define pte_special(pte)	(!!(pte_val(pte) & PTE_SPECIAL))
>> >  #define pte_write(pte)		(!!(pte_val(pte) & PTE_WRITE))
>> >  #define pte_exec(pte)		(!(pte_val(pte) & PTE_UXN))
>> >+#define pte_contig(pte)		(!!(pte_val(pte) & PTE_CONTIG))
>> >  
>> >  #ifdef CONFIG_ARM64_HW_AFDBM
>> >  #define pte_hw_dirty(pte)	(!(pte_val(pte) & PTE_RDONLY))
>> >@@ -206,6 +207,9 @@ static inline pte_t pte_mkspecial(pte_t pte)
>> >  	return set_pte_bit(pte, __pgprot(PTE_SPECIAL));
>> >  }
>> >  
>> >+extern pte_t pte_mkcontig(pte_t pte);
>> >+extern pmd_t pmd_mkcontig(pmd_t pmd);
>> >+
>> >  static inline void set_pte(pte_t *ptep, pte_t pte)
>> >  {
>> >  	*ptep = pte;
>> >@@ -275,7 +279,7 @@ static inline void set_pte_at(struct mm_struct *mm, unsigned long addr,
>> >  /*
>> >   * Hugetlb definitions.
>> >   */
>> >-#define HUGE_MAX_HSTATE		2
>> >+#define HUGE_MAX_HSTATE		((2 * CONFIG_PGTABLE_LEVELS) - 1)
>> >  #define HPAGE_SHIFT		PMD_SHIFT
>> >  #define HPAGE_SIZE		(_AC(1, UL) << HPAGE_SHIFT)
>> >  #define HPAGE_MASK		(~(HPAGE_SIZE - 1))
>> >@@ -372,7 +376,8 @@ extern pgprot_t phys_mem_access_prot(struct file *file, unsigned long pfn,
>> >  #define pmd_none(pmd)		(!pmd_val(pmd))
>> >  #define pmd_present(pmd)	(pmd_val(pmd))
>> >  
>> >-#define pmd_bad(pmd)		(!(pmd_val(pmd) & 2))
>> >+#define pmd_bad(pmd)		(!(pmd_val(pmd) & \
>> >+				   (PMD_TABLE_BIT | PMD_SECT_CONTIG)))
> I'm not sure about this. A contiguous pmd (which will be a block descriptor)
> will no longer be bad?

Right, this was not correct.  The problem was that on process exit,
it was only clearing the first PTE in each contiguous block.  The other
15 (or 31) would still be non-zero and get reported as "bad" on the
console.  Fixing huge_ptep_get_and_clear() solved that problem and
made this hack to pmd_bad() unnecessary.

>
>> >  
>> >  #define pmd_table(pmd)		((pmd_val(pmd) & PMD_TYPE_MASK) == \
>> >  				 PMD_TYPE_TABLE)
>> >@@ -500,7 +505,8 @@ static inline pud_t *pud_offset(pgd_t *pgd, unsigned long addr)
>> >  static inline pte_t pte_modify(pte_t pte, pgprot_t newprot)
>> >  {
>> >  	const pteval_t mask = PTE_USER | PTE_PXN | PTE_UXN | PTE_RDONLY |
>> >-			      PTE_PROT_NONE | PTE_WRITE | PTE_TYPE_MASK;
>> >+			      PTE_PROT_NONE | PTE_WRITE | PTE_TYPE_MASK |
>> >+			      PTE_CONTIG;
>> >  	/* preserve the hardware dirty information */
>> >  	if (pte_hw_dirty(pte))
>> >  		newprot |= PTE_DIRTY;
>> >@@ -513,6 +519,24 @@ static inline pmd_t pmd_modify(pmd_t pmd, pgprot_t newprot)
>> >  	return pte_pmd(pte_modify(pmd_pte(pmd), newprot));
>> >  }
>> >  
>> >+static inline pte_t pte_modify_pfn(pte_t pte, unsigned long newpfn)
>> >+{
>> >+	const pteval_t mask = PHYS_MASK & PAGE_MASK;
>> >+
>> >+	pte_val(pte) = pfn_pte(newpfn, (pte_val(pte) & ~mask));
>> >+	return pte;
>> >+}
>> >+
>> >+#if CONFIG_PGTABLE_LEVELS > 2
>> >+static inline pmd_t pmd_modify_pfn(pmd_t pmd, unsigned long newpfn)
>> >+{
>> >+	const pmdval_t mask = PHYS_MASK & PAGE_MASK;
>> >+
>> >+	pmd = pfn_pmd(newpfn, (pmd_val(pmd) & ~mask));
>> >+	return pmd;
>> >+}
>> >+#endif
> We can probably get rid of these two functions, please see below.

Ok, I've changed it as you suggested.

> >diff --git a/arch/arm64/mm/hugetlbpage.c b/arch/arm64/mm/hugetlbpage.c
> >index 383b03f..f5bbbbc 100644
> >--- a/arch/arm64/mm/hugetlbpage.c
> >+++ b/arch/arm64/mm/hugetlbpage.c
> >@@ -41,6 +41,155 @@ int pud_huge(pud_t pud)
> >  #endif
> >  }
> >  
> >+pte_t *huge_pte_alloc(struct mm_struct *mm,
> >+			unsigned long addr, unsigned long sz)
> >+{
> >+	pgd_t *pgd;
> >+	pud_t *pud;
> >+	pte_t *pte = NULL;
> >+	int i;
> >+
> >+	pgd = pgd_offset(mm, addr);
> >+	pud = pud_alloc(mm, pgd, addr);
> >+	if (pud) {
> >+		if (sz == PUD_SIZE) {
> >+			pte = (pte_t *)pud;
> >+		} else if (sz == PMD_SIZE) {
> >+#ifdef CONFIG_ARCH_WANT_HUGE_PMD_SHARE
> >+			if (pud_none(*pud))
> >+				pte = huge_pmd_share(mm, addr, pud);
> >+			else
> >+#endif
> >+				pte = (pte_t *)pmd_alloc(mm, pud, addr);
> >+		} else if (sz == (PAGE_SIZE * CONTIG_PAGES)) {
> >+			pmd_t *pmd = pmd_alloc(mm, pud, addr);
> >+
> >+			WARN_ON(addr & (sz - 1));
> >+			pte = pte_alloc_map(mm, NULL, pmd, addr);
> >+			if (pte_present(*pte)) {
> >+				unsigned long pfn;
> >+				*pte = pte_mkcontig(*pte);
> >+				pfn = pte_pfn(*pte);
> >+				for (i = 0; i < CONTIG_PAGES; i++) {
> >+					set_pte(&pte[i],
> >+						pte_modify_pfn(*pte, pfn + i));
> >+				}
> >+			}
> >+#if CONFIG_PGTABLE_LEVELS > 2
> >+		} else if (sz == (PMD_SIZE * CONTIG_PAGES)) {
> >+			pmd_t *pmd;
> >+
> >+			pmd = pmd_alloc(mm, pud, addr);
> >+			WARN_ON(addr & (sz - 1));
> >+			if (pmd && pmd_present(*pmd)) {
> >+				unsigned long pfn;
> >+				pmd_t pmdval;
> >+
> >+				pmdval = *pmd = pmd_mkcontig(*pmd);
> >+				pfn = pmd_pfn(*pmd);
> >+				for (i = 0; i < CONTIG_PAGES; i++) {
> >+					unsigned long newpfn = pfn +
> >+						(i << (PMD_SHIFT - PAGE_SHIFT));
> >+					if (!pmd_present(pmd[i]))
> >+						atomic_long_inc(&mm->nr_ptes);
> >+					set_pmd(&pmd[i],
> >+						pmd_modify_pfn(pmdval, newpfn));
> >+				}
> >+			}
> >+			return pmd;
> >+#endif
> >+		}
> >+	}
> >+
> >+	return pte;
> >+}
> Why are we writing pte's/pmd's in the huge_pte_alloc function?
> What happened to set_huge_pte_at?
>
> Also, rather than call pte_modify_pfn, I would recommend something like:
>
> 	int loop;
> 	unsigned long pfn = pte_pfn(pte);
> 	pgprot_t hugeprot = __pgprot(pte_val(pfn_pte(pfn, 0) ^ pte_val(pte)));
>
> 	for (loop = 0; loop < CONTIG_PTES; loop++) {
> 		set_pte_at(mm, addr, ptep++, pfn_pte(pfn++, hugeprot));
> 		addr += PAGE_SIZE;
> 	}
>
> i.e. extract a pgprot_t and combine with the pfn in the loop rather than
> calling out.

I agree, it's better this way.  I moved all this stuff out of 
huge_pte_alloc()
and into set_huge_pte_at().

>> >+}
>> >+
>> >+pte_t pte_mkcontig(pte_t pte)
>> >+{
>> >+	pte = set_pte_bit(pte, __pgprot(PTE_CONTIG));
>> >+	pte = set_pte_bit(pte, __pgprot(PTE_TYPE_PAGE));
>> >+	return pte;
>> >+}
>> >+
>> >+pmd_t pmd_mkcontig(pmd_t pmd)
>> >+{
>> >+	pmd = __pmd(pmd_val(pmd) | PMD_SECT_CONTIG);
>> >+	return pmd;
>> >+}
> Can these be folded into arch_make_huge_pte?

I left these as separate functions but made them inline in pgtable.h
to follow Jeremy Linton's patch for the kernel linear mappings.

>
>> >+
>> >+struct page *follow_huge_pmd(struct mm_struct *mm, unsigned long address,
>> >+		pmd_t *pmd, int write)
>> >+{
>> >+	struct page *page;
>> >+
>> >+	page = pte_page(*(pte_t *)pmd);
>> >+	if (page)
>> >+		page += ((address & ~PMD_MASK) >> PAGE_SHIFT);
>> >+	return page;
>> >+}
> Do we need to think about contiguous pmd's here?
> It may be worth implementing follow_huge_addr?

It turned out to be unnecessary to override follow_huge_pmd/pud.

-Dave



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
