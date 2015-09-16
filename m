Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f182.google.com (mail-ig0-f182.google.com [209.85.213.182])
	by kanga.kvack.org (Postfix) with ESMTP id F02406B0038
	for <linux-mm@kvack.org>; Wed, 16 Sep 2015 04:46:27 -0400 (EDT)
Received: by igcpb10 with SMTP id pb10so30926338igc.1
        for <linux-mm@kvack.org>; Wed, 16 Sep 2015 01:46:27 -0700 (PDT)
Received: from mail-io0-f181.google.com (mail-io0-f181.google.com. [209.85.223.181])
        by mx.google.com with ESMTPS id m5si2392016igr.59.2015.09.16.01.46.27
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Sep 2015 01:46:27 -0700 (PDT)
Received: by iofh134 with SMTP id h134so224467445iof.0
        for <linux-mm@kvack.org>; Wed, 16 Sep 2015 01:46:27 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1442340117-3964-1-git-send-email-dwoods@ezchip.com>
References: <1442340117-3964-1-git-send-email-dwoods@ezchip.com>
Date: Wed, 16 Sep 2015 09:46:26 +0100
Message-ID: <CAPvkgC1JYZRc5BEXFxmR927r1asLYZw=oAMyUDcGPAOfC2Yy-A@mail.gmail.com>
Subject: Re: [PATCH] arm64: Add support for PTE contiguous bit.
From: Steve Capper <steve.capper@linaro.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Woods <dwoods@ezchip.com>
Cc: Chris Metcalf <cmetcalf@ezchip.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Marc Zyngier <marc.zyngier@arm.com>, Hugh Dickins <hughd@google.com>, Mike Kravetz <mike.kravetz@oracle.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Suzuki K. Poulose" <suzuki.poulose@arm.com>

On 15 September 2015 at 19:01, David Woods <dwoods@ezchip.com> wrote:
> The arm64 MMU supports a Contiguous bit which is a hint that the TTE
> is one of a set of contiguous entries which can be cached in a single
> TLB entry.  Supporting this bit adds new intermediate huge page sizes.
>
> The set of huge page sizes available depends on the base page size.
> Without using contiguous pages the huge page sizes are as follows.
>
>  4KB:   2MB  1GB
> 64KB: 512MB  4TB

We just have 512MB for a 64KB granule.
As per [1] D4.2.6 - "The VMSAv8-64 translation table format" page D4-1668.

>
> With 4KB pages, the contiguous bit groups together sets of 16 pages
> and with 64KB pages it groups sets of 32 pages.  This enables two new
> huge page sizes in each case, so that the full set of available sizes
> is as follows.
>
>  4KB:  64KB   2MB  32MB  1GB
> 64KB:   2MB 512MB  16GB  4TB
>
> If the base page size is set to 64KB then 2MB pages are enabled by
> default.  It is possible in the future to make 2MB the default huge
> page size for both 4KB and 64KB pages.
>

Hi David,
Thanks for posting this, and apologies in advance for talking about
the ARM ARM[1]...

D4.4.2 "Other fields in the VMSAv8-64 translation table format
descriptors" (page D4-1715)
Only gives examples of the contiguous bit being used for level 3
descriptors (i.e. PTEs) when running with a 4KB and 64KB granule.

With a 16KB granule we *can* have a contiguous bit being used by level
2 descriptors (i.e. PMDs), so the pmd_contig logic could perhaps be
used in combination with Suzuki's 16KB PAGE_SIZE series at:
http://lists.infradead.org/pipermail/linux-arm-kernel/2015-September/370117.html

I will read through the rest of the patch and post more feedback

Cheers,
--
Steve

[1] - http://infocenter.arm.com/help/topic/com.arm.doc.ddi0487a.g/index.html




> Signed-off-by: David Woods <dwoods@ezchip.com>
> Reviewed-by: Chris Metcalf <cmetcalf@ezchip.com>
> ---
>  arch/arm64/Kconfig                     |   3 -
>  arch/arm64/include/asm/hugetlb.h       |   4 +
>  arch/arm64/include/asm/pgtable-hwdef.h |  15 +++
>  arch/arm64/include/asm/pgtable.h       |  30 +++++-
>  arch/arm64/mm/hugetlbpage.c            | 165 ++++++++++++++++++++++++++++++++-
>  5 files changed, 210 insertions(+), 7 deletions(-)
>
> diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
> index 7d95663..8310e38 100644
> --- a/arch/arm64/Kconfig
> +++ b/arch/arm64/Kconfig
> @@ -447,9 +447,6 @@ config HW_PERF_EVENTS
>  config SYS_SUPPORTS_HUGETLBFS
>         def_bool y
>
> -config ARCH_WANT_GENERAL_HUGETLB
> -       def_bool y
> -
>  config ARCH_WANT_HUGE_PMD_SHARE
>         def_bool y if !ARM64_64K_PAGES
>
> diff --git a/arch/arm64/include/asm/hugetlb.h b/arch/arm64/include/asm/hugetlb.h
> index bb4052e..e5af553 100644
> --- a/arch/arm64/include/asm/hugetlb.h
> +++ b/arch/arm64/include/asm/hugetlb.h
> @@ -97,4 +97,8 @@ static inline void arch_clear_hugepage_flags(struct page *page)
>         clear_bit(PG_dcache_clean, &page->flags);
>  }
>
> +extern pte_t arch_make_huge_pte(pte_t entry, struct vm_area_struct *vma,
> +                               struct page *page, int writable);
> +#define arch_make_huge_pte arch_make_huge_pte
> +
>  #endif /* __ASM_HUGETLB_H */
> diff --git a/arch/arm64/include/asm/pgtable-hwdef.h b/arch/arm64/include/asm/pgtable-hwdef.h
> index 24154b0..da73243 100644
> --- a/arch/arm64/include/asm/pgtable-hwdef.h
> +++ b/arch/arm64/include/asm/pgtable-hwdef.h
> @@ -55,6 +55,19 @@
>  #define SECTION_MASK           (~(SECTION_SIZE-1))
>
>  /*
> + * Contiguous large page definitions.
> + */
> +#ifdef CONFIG_ARM64_64K_PAGES
> +#define        CONTIG_SHIFT            5
> +#define CONTIG_PAGES           32
> +#else
> +#define        CONTIG_SHIFT            4
> +#define CONTIG_PAGES           16
> +#endif
> +#define        CONTIG_PTE_SIZE         (CONTIG_PAGES * PAGE_SIZE)
> +#define        CONTIG_PTE_MASK         (~(CONTIG_PTE_SIZE - 1))
> +
> +/*
>   * Hardware page table definitions.
>   *
>   * Level 1 descriptor (PUD).
> @@ -83,6 +96,7 @@
>  #define PMD_SECT_S             (_AT(pmdval_t, 3) << 8)
>  #define PMD_SECT_AF            (_AT(pmdval_t, 1) << 10)
>  #define PMD_SECT_NG            (_AT(pmdval_t, 1) << 11)
> +#define PMD_SECT_CONTIG                (_AT(pmdval_t, 1) << 52)
>  #define PMD_SECT_PXN           (_AT(pmdval_t, 1) << 53)
>  #define PMD_SECT_UXN           (_AT(pmdval_t, 1) << 54)
>
> @@ -105,6 +119,7 @@
>  #define PTE_AF                 (_AT(pteval_t, 1) << 10)        /* Access Flag */
>  #define PTE_NG                 (_AT(pteval_t, 1) << 11)        /* nG */
>  #define PTE_DBM                        (_AT(pteval_t, 1) << 51)        /* Dirty Bit Management */
> +#define PTE_CONTIG             (_AT(pteval_t, 1) << 52)        /* Contiguous */
>  #define PTE_PXN                        (_AT(pteval_t, 1) << 53)        /* Privileged XN */
>  #define PTE_UXN                        (_AT(pteval_t, 1) << 54)        /* User XN */
>
> diff --git a/arch/arm64/include/asm/pgtable.h b/arch/arm64/include/asm/pgtable.h
> index 6900b2d9..df5ec64 100644
> --- a/arch/arm64/include/asm/pgtable.h
> +++ b/arch/arm64/include/asm/pgtable.h
> @@ -144,6 +144,7 @@ extern struct page *empty_zero_page;
>  #define pte_special(pte)       (!!(pte_val(pte) & PTE_SPECIAL))
>  #define pte_write(pte)         (!!(pte_val(pte) & PTE_WRITE))
>  #define pte_exec(pte)          (!(pte_val(pte) & PTE_UXN))
> +#define pte_contig(pte)                (!!(pte_val(pte) & PTE_CONTIG))
>
>  #ifdef CONFIG_ARM64_HW_AFDBM
>  #define pte_hw_dirty(pte)      (!(pte_val(pte) & PTE_RDONLY))
> @@ -206,6 +207,9 @@ static inline pte_t pte_mkspecial(pte_t pte)
>         return set_pte_bit(pte, __pgprot(PTE_SPECIAL));
>  }
>
> +extern pte_t pte_mkcontig(pte_t pte);
> +extern pmd_t pmd_mkcontig(pmd_t pmd);
> +
>  static inline void set_pte(pte_t *ptep, pte_t pte)
>  {
>         *ptep = pte;
> @@ -275,7 +279,7 @@ static inline void set_pte_at(struct mm_struct *mm, unsigned long addr,
>  /*
>   * Hugetlb definitions.
>   */
> -#define HUGE_MAX_HSTATE                2
> +#define HUGE_MAX_HSTATE                ((2 * CONFIG_PGTABLE_LEVELS) - 1)
>  #define HPAGE_SHIFT            PMD_SHIFT
>  #define HPAGE_SIZE             (_AC(1, UL) << HPAGE_SHIFT)
>  #define HPAGE_MASK             (~(HPAGE_SIZE - 1))
> @@ -372,7 +376,8 @@ extern pgprot_t phys_mem_access_prot(struct file *file, unsigned long pfn,
>  #define pmd_none(pmd)          (!pmd_val(pmd))
>  #define pmd_present(pmd)       (pmd_val(pmd))
>
> -#define pmd_bad(pmd)           (!(pmd_val(pmd) & 2))
> +#define pmd_bad(pmd)           (!(pmd_val(pmd) & \
> +                                  (PMD_TABLE_BIT | PMD_SECT_CONTIG)))
>
>  #define pmd_table(pmd)         ((pmd_val(pmd) & PMD_TYPE_MASK) == \
>                                  PMD_TYPE_TABLE)
> @@ -500,7 +505,8 @@ static inline pud_t *pud_offset(pgd_t *pgd, unsigned long addr)
>  static inline pte_t pte_modify(pte_t pte, pgprot_t newprot)
>  {
>         const pteval_t mask = PTE_USER | PTE_PXN | PTE_UXN | PTE_RDONLY |
> -                             PTE_PROT_NONE | PTE_WRITE | PTE_TYPE_MASK;
> +                             PTE_PROT_NONE | PTE_WRITE | PTE_TYPE_MASK |
> +                             PTE_CONTIG;
>         /* preserve the hardware dirty information */
>         if (pte_hw_dirty(pte))
>                 newprot |= PTE_DIRTY;
> @@ -513,6 +519,24 @@ static inline pmd_t pmd_modify(pmd_t pmd, pgprot_t newprot)
>         return pte_pmd(pte_modify(pmd_pte(pmd), newprot));
>  }
>
> +static inline pte_t pte_modify_pfn(pte_t pte, unsigned long newpfn)
> +{
> +       const pteval_t mask = PHYS_MASK & PAGE_MASK;
> +
> +       pte_val(pte) = pfn_pte(newpfn, (pte_val(pte) & ~mask));
> +       return pte;
> +}
> +
> +#if CONFIG_PGTABLE_LEVELS > 2
> +static inline pmd_t pmd_modify_pfn(pmd_t pmd, unsigned long newpfn)
> +{
> +       const pmdval_t mask = PHYS_MASK & PAGE_MASK;
> +
> +       pmd = pfn_pmd(newpfn, (pmd_val(pmd) & ~mask));
> +       return pmd;
> +}
> +#endif
> +
>  #ifdef CONFIG_ARM64_HW_AFDBM
>  /*
>   * Atomic pte/pmd modifications.
> diff --git a/arch/arm64/mm/hugetlbpage.c b/arch/arm64/mm/hugetlbpage.c
> index 383b03f..f5bbbbc 100644
> --- a/arch/arm64/mm/hugetlbpage.c
> +++ b/arch/arm64/mm/hugetlbpage.c
> @@ -41,6 +41,155 @@ int pud_huge(pud_t pud)
>  #endif
>  }
>
> +pte_t *huge_pte_alloc(struct mm_struct *mm,
> +                       unsigned long addr, unsigned long sz)
> +{
> +       pgd_t *pgd;
> +       pud_t *pud;
> +       pte_t *pte = NULL;
> +       int i;
> +
> +       pgd = pgd_offset(mm, addr);
> +       pud = pud_alloc(mm, pgd, addr);
> +       if (pud) {
> +               if (sz == PUD_SIZE) {
> +                       pte = (pte_t *)pud;
> +               } else if (sz == PMD_SIZE) {
> +#ifdef CONFIG_ARCH_WANT_HUGE_PMD_SHARE
> +                       if (pud_none(*pud))
> +                               pte = huge_pmd_share(mm, addr, pud);
> +                       else
> +#endif
> +                               pte = (pte_t *)pmd_alloc(mm, pud, addr);
> +               } else if (sz == (PAGE_SIZE * CONTIG_PAGES)) {
> +                       pmd_t *pmd = pmd_alloc(mm, pud, addr);
> +
> +                       WARN_ON(addr & (sz - 1));
> +                       pte = pte_alloc_map(mm, NULL, pmd, addr);
> +                       if (pte_present(*pte)) {
> +                               unsigned long pfn;
> +                               *pte = pte_mkcontig(*pte);
> +                               pfn = pte_pfn(*pte);
> +                               for (i = 0; i < CONTIG_PAGES; i++) {
> +                                       set_pte(&pte[i],
> +                                               pte_modify_pfn(*pte, pfn + i));
> +                               }
> +                       }
> +#if CONFIG_PGTABLE_LEVELS > 2
> +               } else if (sz == (PMD_SIZE * CONTIG_PAGES)) {
> +                       pmd_t *pmd;
> +
> +                       pmd = pmd_alloc(mm, pud, addr);
> +                       WARN_ON(addr & (sz - 1));
> +                       if (pmd && pmd_present(*pmd)) {
> +                               unsigned long pfn;
> +                               pmd_t pmdval;
> +
> +                               pmdval = *pmd = pmd_mkcontig(*pmd);
> +                               pfn = pmd_pfn(*pmd);
> +                               for (i = 0; i < CONTIG_PAGES; i++) {
> +                                       unsigned long newpfn = pfn +
> +                                               (i << (PMD_SHIFT - PAGE_SHIFT));
> +                                       if (!pmd_present(pmd[i]))
> +                                               atomic_long_inc(&mm->nr_ptes);
> +                                       set_pmd(&pmd[i],
> +                                               pmd_modify_pfn(pmdval, newpfn));
> +                               }
> +                       }
> +                       return pmd;
> +#endif
> +               }
> +       }
> +
> +       return pte;
> +}
> +
> +pte_t *huge_pte_offset(struct mm_struct *mm, unsigned long addr)
> +{
> +       pgd_t *pgd;
> +       pud_t *pud;
> +       pmd_t *pmd = NULL;
> +       pte_t *pte = NULL;
> +
> +       pgd = pgd_offset(mm, addr);
> +       if (pgd_present(*pgd)) {
> +               pud = pud_offset(pgd, addr);
> +               if (pud_present(*pud)) {
> +                       if (pud_huge(*pud))
> +                               return (pte_t *)pud;
> +                       pmd = pmd_offset(pud, addr);
> +                       if (pmd_present(*pmd)) {
> +                               if (pmd_huge(*pmd))
> +                                       return (pte_t *)pmd;
> +                               pte = pte_offset_kernel(pmd, addr);
> +                               if (pte_present(*pte) && pte_contig(*pte)) {
> +                                       pte = pte_offset_kernel(
> +                                               pmd, (addr & CONTIG_PTE_MASK));
> +                                       return pte;
> +                               }
> +                       }
> +               }
> +       }
> +       return (pte_t *) NULL;
> +}
> +
> +pte_t arch_make_huge_pte(pte_t entry, struct vm_area_struct *vma,
> +                        struct page *page, int writable)
> +{
> +       size_t pagesize = huge_page_size(hstate_vma(vma));
> +       pte_t nent = {0};
> +
> +       if (pagesize == PUD_SIZE || pagesize == PMD_SIZE)
> +               nent = entry;
> +       else if (pagesize == (PAGE_SIZE * CONTIG_PAGES))
> +               nent = pte_mkcontig(entry);
> +#if CONFIG_PGTABLE_LEVELS > 2
> +       else if (pagesize == (PMD_SIZE * CONTIG_PAGES) ||
> +                pagesize == (PUD_SIZE * CONTIG_PAGES))
> +               nent = pmd_mkcontig(entry);
> +#endif
> +       else {
> +               pr_warn("%s: unrecognized huge page size 0x%lx\n",
> +                      __func__, pagesize);
> +       }
> +       return nent;
> +}
> +
> +pte_t pte_mkcontig(pte_t pte)
> +{
> +       pte = set_pte_bit(pte, __pgprot(PTE_CONTIG));
> +       pte = set_pte_bit(pte, __pgprot(PTE_TYPE_PAGE));
> +       return pte;
> +}
> +
> +pmd_t pmd_mkcontig(pmd_t pmd)
> +{
> +       pmd = __pmd(pmd_val(pmd) | PMD_SECT_CONTIG);
> +       return pmd;
> +}
> +
> +struct page *follow_huge_pmd(struct mm_struct *mm, unsigned long address,
> +               pmd_t *pmd, int write)
> +{
> +       struct page *page;
> +
> +       page = pte_page(*(pte_t *)pmd);
> +       if (page)
> +               page += ((address & ~PMD_MASK) >> PAGE_SHIFT);
> +       return page;
> +}
> +
> +struct page *follow_huge_pud(struct mm_struct *mm, unsigned long address,
> +               pud_t *pud, int write)
> +{
> +       struct page *page;
> +
> +       page = pte_page(*(pte_t *)pud);
> +       if (page)
> +               page += ((address & ~PUD_MASK) >> PAGE_SHIFT);
> +       return page;
> +}
> +
>  static __init int setup_hugepagesz(char *opt)
>  {
>         unsigned long ps = memparse(opt, &opt);
> @@ -48,10 +197,24 @@ static __init int setup_hugepagesz(char *opt)
>                 hugetlb_add_hstate(PMD_SHIFT - PAGE_SHIFT);
>         } else if (ps == PUD_SIZE) {
>                 hugetlb_add_hstate(PUD_SHIFT - PAGE_SHIFT);
> +       } else if (ps == (PAGE_SIZE * CONTIG_PAGES)) {
> +               hugetlb_add_hstate(CONTIG_SHIFT);
> +       } else if (ps == (PMD_SIZE * CONTIG_PAGES)) {
> +               hugetlb_add_hstate((PMD_SHIFT + CONTIG_SHIFT) - PAGE_SHIFT);
>         } else {
> -               pr_err("hugepagesz: Unsupported page size %lu M\n", ps >> 20);
> +               pr_err("hugepagesz: Unsupported page size %lu K\n", ps >> 10);
>                 return 0;
>         }
>         return 1;
>  }
>  __setup("hugepagesz=", setup_hugepagesz);
> +
> +#ifdef CONFIG_ARM64_64K_PAGES
> +static __init int add_default_hugepagesz(void)
> +{
> +       if (size_to_hstate(CONTIG_PAGES * PAGE_SIZE) == NULL)
> +               hugetlb_add_hstate(CONTIG_SHIFT);
> +       return 0;
> +}
> +arch_initcall(add_default_hugepagesz);
> +#endif
> --
> 2.1.2
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
