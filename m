Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 037B16B0254
	for <linux-mm@kvack.org>; Fri, 20 Nov 2015 05:07:32 -0500 (EST)
Received: by pacdm15 with SMTP id dm15so112533247pac.3
        for <linux-mm@kvack.org>; Fri, 20 Nov 2015 02:07:31 -0800 (PST)
Received: from mail-pa0-x231.google.com (mail-pa0-x231.google.com. [2607:f8b0:400e:c03::231])
        by mx.google.com with ESMTPS id es4si10026092pac.153.2015.11.20.02.07.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Nov 2015 02:07:31 -0800 (PST)
Received: by padhx2 with SMTP id hx2so112543927pad.1
        for <linux-mm@kvack.org>; Fri, 20 Nov 2015 02:07:31 -0800 (PST)
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.0 \(3094\))
Subject: Re: [PATCH v3] arm64: Add support for PTE contiguous bit.
From: yalin wang <yalin.wang2010@gmail.com>
In-Reply-To: <1447952231-17631-1-git-send-email-dwoods@ezchip.com>
Date: Fri, 20 Nov 2015 18:07:21 +0800
Content-Transfer-Encoding: quoted-printable
Message-Id: <5D0C7112-063F-4116-9585-ADF4ADF97AAE@gmail.com>
References: <1447952231-17631-1-git-send-email-dwoods@ezchip.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Woods <dwoods@ezchip.com>
Cc: catalin.marinas@arm.com, will.deacon@arm.com, steve.capper@linaro.org, jeremy.linton@arm.com, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cmetcalf@ezchip.com


> On Nov 20, 2015, at 00:57, David Woods <dwoods@ezchip.com> wrote:
>=20
> The arm64 MMU supports a Contiguous bit which is a hint that the TTE
> is one of a set of contiguous entries which can be cached in a single
> TLB entry.  Supporting this bit adds new intermediate huge page sizes.
>=20
> The set of huge page sizes available depends on the base page size.
> Without using contiguous pages the huge page sizes are as follows.
>=20
> 4KB:   2MB  1GB
> 64KB: 512MB
>=20
> With a 4KB granule, the contiguous bit groups together sets of 16 =
pages
> and with a 64KB granule it groups sets of 32 pages.  This enables two =
new
> huge page sizes in each case, so that the full set of available sizes
> is as follows.
>=20
> 4KB:  64KB   2MB  32MB  1GB
> 64KB:   2MB 512MB  16GB
>=20
> If a 16KB granule is used then the contiguous bit groups 128 pages
> at the PTE level and 32 pages at the PMD level.
>=20
> If the base page size is set to 64KB then 2MB pages are enabled by
> default.  It is possible in the future to make 2MB the default huge
> page size for both 4KB and 64KB granules.
>=20
> Signed-off-by: David Woods <dwoods@ezchip.com>
> Reviewed-by: Chris Metcalf <cmetcalf@ezchip.com>
> ---
>=20
> This patch should resolve the comments on v2 and is now based on on =
the=20
> arm64 next tree which includes 16K granule support.  I've added =
definitions=20
> which should enable 2M and 1G huge page sizes with a 16K granule. =20
> Unfortunately, the A53 model we have does not support 16K so I don't=20=

> have a way to test this.
>=20
> arch/arm64/Kconfig                     |   3 -
> arch/arm64/include/asm/hugetlb.h       |  44 ++----
> arch/arm64/include/asm/pgtable-hwdef.h |  18 ++-
> arch/arm64/include/asm/pgtable.h       |  10 +-
> arch/arm64/mm/hugetlbpage.c            | 267 =
++++++++++++++++++++++++++++++++-
> include/linux/hugetlb.h                |   2 -
> 6 files changed, 306 insertions(+), 38 deletions(-)
>=20
> diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
> index 40e1151..077bb7c 100644
> --- a/arch/arm64/Kconfig
> +++ b/arch/arm64/Kconfig
> @@ -480,9 +480,6 @@ config HW_PERF_EVENTS
> config SYS_SUPPORTS_HUGETLBFS
> 	def_bool y
>=20
> -config ARCH_WANT_GENERAL_HUGETLB
> -	def_bool y
> -
> config ARCH_WANT_HUGE_PMD_SHARE
> 	def_bool y if ARM64_4K_PAGES || (ARM64_16K_PAGES && =
!ARM64_VA_BITS_36)
>=20
> diff --git a/arch/arm64/include/asm/hugetlb.h =
b/arch/arm64/include/asm/hugetlb.h
> index bb4052e..bbc1e35 100644
> --- a/arch/arm64/include/asm/hugetlb.h
> +++ b/arch/arm64/include/asm/hugetlb.h
> @@ -26,36 +26,7 @@ static inline pte_t huge_ptep_get(pte_t *ptep)
> 	return *ptep;
> }
>=20
> -static inline void set_huge_pte_at(struct mm_struct *mm, unsigned =
long addr,
> -				   pte_t *ptep, pte_t pte)
> -{
> -	set_pte_at(mm, addr, ptep, pte);
> -}
> -
> -static inline void huge_ptep_clear_flush(struct vm_area_struct *vma,
> -					 unsigned long addr, pte_t =
*ptep)
> -{
> -	ptep_clear_flush(vma, addr, ptep);
> -}
> -
> -static inline void huge_ptep_set_wrprotect(struct mm_struct *mm,
> -					   unsigned long addr, pte_t =
*ptep)
> -{
> -	ptep_set_wrprotect(mm, addr, ptep);
> -}
>=20
> -static inline pte_t huge_ptep_get_and_clear(struct mm_struct *mm,
> -					    unsigned long addr, pte_t =
*ptep)
> -{
> -	return ptep_get_and_clear(mm, addr, ptep);
> -}
> -
> -static inline int huge_ptep_set_access_flags(struct vm_area_struct =
*vma,
> -					     unsigned long addr, pte_t =
*ptep,
> -					     pte_t pte, int dirty)
> -{
> -	return ptep_set_access_flags(vma, addr, ptep, pte, dirty);
> -}
>=20
> static inline void hugetlb_free_pgd_range(struct mmu_gather *tlb,
> 					  unsigned long addr, unsigned =
long end,
> @@ -97,4 +68,19 @@ static inline void arch_clear_hugepage_flags(struct =
page *page)
> 	clear_bit(PG_dcache_clean, &page->flags);
> }
>=20
> +extern pte_t arch_make_huge_pte(pte_t entry, struct vm_area_struct =
*vma,
> +				struct page *page, int writable);
> +#define arch_make_huge_pte arch_make_huge_pte
> +extern void set_huge_pte_at(struct mm_struct *mm, unsigned long addr,
> +			    pte_t *ptep, pte_t pte);
> +extern int huge_ptep_set_access_flags(struct vm_area_struct *vma,
> +				      unsigned long addr, pte_t *ptep,
> +				      pte_t pte, int dirty);
> +extern pte_t huge_ptep_get_and_clear(struct mm_struct *mm,
> +				     unsigned long addr, pte_t *ptep);
> +extern void huge_ptep_set_wrprotect(struct mm_struct *mm,
> +				    unsigned long addr, pte_t *ptep);
> +extern void huge_ptep_clear_flush(struct vm_area_struct *vma,
> +				  unsigned long addr, pte_t *ptep);
> +
> #endif /* __ASM_HUGETLB_H */
> diff --git a/arch/arm64/include/asm/pgtable-hwdef.h =
b/arch/arm64/include/asm/pgtable-hwdef.h
> index d6739e8..5c25b83 100644
> --- a/arch/arm64/include/asm/pgtable-hwdef.h
> +++ b/arch/arm64/include/asm/pgtable-hwdef.h
> @@ -90,7 +90,23 @@
> /*
>  * Contiguous page definitions.
>  */
> -#define CONT_PTES		(_AC(1, UL) << CONT_SHIFT)
> +#ifdef CONFIG_ARM64_64K_PAGES
> +#define CONT_PTE_SHIFT		5
> +#define CONT_PMD_SHIFT		5
> +#elif defined(CONFIG_ARM64_16K_PAGES)
> +#define CONT_PTE_SHIFT		7
> +#define CONT_PMD_SHIFT		5
> +#else
> +#define CONT_PTE_SHIFT		4
> +#define CONT_PMD_SHIFT		4
> +#endif
> +
> +#define CONT_PTES		(1 << CONT_PTE_SHIFT)
> +#define CONT_PTE_SIZE		(CONT_PTES * PAGE_SIZE)
> +#define CONT_PTE_MASK		(~(CONT_PTE_SIZE - 1))
> +#define CONT_PMDS		(1 << CONT_PMD_SHIFT)
> +#define CONT_PMD_SIZE		(CONT_PMDS * PMD_SIZE)
> +#define CONT_PMD_MASK		(~(CONT_PMD_SIZE - 1))
> /* the the numerical offset of the PTE within a range of CONT_PTES */
> #define CONT_RANGE_OFFSET(addr) (((addr)>>PAGE_SHIFT)&(CONT_PTES-1))
>=20
> diff --git a/arch/arm64/include/asm/pgtable.h =
b/arch/arm64/include/asm/pgtable.h
> index 1c99d56..d259332 100644
> --- a/arch/arm64/include/asm/pgtable.h
> +++ b/arch/arm64/include/asm/pgtable.h
> @@ -214,7 +214,8 @@ static inline pte_t pte_mkspecial(pte_t pte)
>=20
> static inline pte_t pte_mkcont(pte_t pte)
> {
> -	return set_pte_bit(pte, __pgprot(PTE_CONT));
> +	pte =3D set_pte_bit(pte, __pgprot(PTE_CONT));
> +	return set_pte_bit(pte, __pgprot(PTE_TYPE_PAGE));
> }
>=20
> static inline pte_t pte_mknoncont(pte_t pte)
> @@ -222,6 +223,11 @@ static inline pte_t pte_mknoncont(pte_t pte)
> 	return clear_pte_bit(pte, __pgprot(PTE_CONT));
> }
>=20
> +static inline pmd_t pmd_mkcont(pmd_t pmd)
> +{
> +	return __pmd(pmd_val(pmd) | PMD_SECT_CONT);
> +}
> +
> static inline void set_pte(pte_t *ptep, pte_t pte)
> {
> 	*ptep =3D pte;
> @@ -291,7 +297,7 @@ static inline void set_pte_at(struct mm_struct =
*mm, unsigned long addr,
> /*
>  * Hugetlb definitions.
>  */
> -#define HUGE_MAX_HSTATE		2
> +#define HUGE_MAX_HSTATE		4
> #define HPAGE_SHIFT		PMD_SHIFT
> #define HPAGE_SIZE		(_AC(1, UL) << HPAGE_SHIFT)
> #define HPAGE_MASK		(~(HPAGE_SIZE - 1))
> diff --git a/arch/arm64/mm/hugetlbpage.c b/arch/arm64/mm/hugetlbpage.c
> index 383b03f..1688445 100644
> --- a/arch/arm64/mm/hugetlbpage.c
> +++ b/arch/arm64/mm/hugetlbpage.c
> @@ -41,17 +41,282 @@ int pud_huge(pud_t pud)
> #endif
> }
>=20
> +static int find_num_contig(struct mm_struct *mm, unsigned long addr,
> +			   pte_t *ptep, pte_t pte, size_t *pgsize)
> +{
> +	pgd_t *pgd =3D pgd_offset(mm, addr);
> +	pud_t *pud;
> +	pmd_t *pmd;
> +
> +	if (!pte_cont(pte))
> +		return 1;
> +	if (!pgd_present(*pgd)) {
> +		VM_BUG_ON(!pgd_present(*pgd));
> +		return 1;
> +	}
> +	pud =3D pud_offset(pgd, addr);
> +	if (!pud_present(*pud)) {
> +		VM_BUG_ON(!pud_present(*pud));
> +		return 1;
> +	}
> +	pmd =3D pmd_offset(pud, addr);
> +	if (!pmd_present(*pmd)) {
> +		VM_BUG_ON(!pmd_present(*pmd));
> +		return 1;
> +	}
> +	if ((pte_t *)pmd =3D=3D ptep) {
> +		*pgsize =3D PMD_SIZE;
> +		return CONT_PMDS;
> +	}
> +	*pgsize =3D PAGE_SIZE;
> +	return CONT_PTES;
> +}
> +
> +void set_huge_pte_at(struct mm_struct *mm, unsigned long addr,
> +			    pte_t *ptep, pte_t pte)
> +{
> +	size_t pgsize;
> +	int i;
> +	int ncontig =3D find_num_contig(mm, addr, ptep, pte, &pgsize);
> +	unsigned long pfn;
> +	pgprot_t hugeprot;
> +
> +	if (ncontig =3D=3D 1) {
> +		set_pte_at(mm, addr, ptep, pte);
> +		return;
> +	}
> +
> +	pfn =3D pte_pfn(pte);
> +	hugeprot =3D __pgprot(pte_val(pfn_pte(pfn, 0) ^ pte_val(pte)));
is this should be pte_val(pfn_pte(pfn, 0)) ^ pte_val(pte)  ?

> +	for (i =3D 0; i < ncontig; i++) {
> +		pr_debug("%s: set pte %p to 0x%llx\n", __func__, ptep,
> +			 pfn_pte(pfn, hugeprot));
> +		set_pte_at(mm, addr, ptep, pfn_pte(pfn, hugeprot));
> +		ptep++;
> +		pfn +=3D pgsize >> PAGE_SHIFT;
> +		addr +=3D pgsize;
> +	}
> +}
>=20

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
