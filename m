Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id 49BCF6B02C0
	for <linux-mm@kvack.org>; Fri,  3 May 2013 01:30:55 -0400 (EDT)
Received: from /spool/local
	by e23smtp07.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dwg@au1.ibm.com>;
	Fri, 3 May 2013 15:21:08 +1000
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [9.190.234.120])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id 2F9772CE804D
	for <linux-mm@kvack.org>; Fri,  3 May 2013 15:30:35 +1000 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r435GmiA21102838
	for <linux-mm@kvack.org>; Fri, 3 May 2013 15:16:49 +1000
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r435UXSN029217
	for <linux-mm@kvack.org>; Fri, 3 May 2013 15:30:33 +1000
Date: Fri, 3 May 2013 14:52:01 +1000
From: David Gibson <dwg@au1.ibm.com>
Subject: Re: [PATCH -V7 02/10] powerpc/THP: Implement transparent hugepages
 for ppc64
Message-ID: <20130503045201.GO13041@truffula.fritz.box>
References: <1367178711-8232-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <1367178711-8232-3-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="qcTtWMBd/uZDG7+Y"
Content-Disposition: inline
In-Reply-To: <1367178711-8232-3-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: benh@kernel.crashing.org, paulus@samba.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org

--qcTtWMBd/uZDG7+Y
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Apr 29, 2013 at 01:21:43AM +0530, Aneesh Kumar K.V wrote:
> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
>=20
> We now have pmd entries covering 16MB range and the PMD table double its =
original size.
> We use the second half of the PMD table to deposit the pgtable (PTE page).
> The depoisted PTE page is further used to track the HPTE information. The=
 information
> include [ secondary group | 3 bit hidx | valid ]. We use one byte per eac=
h HPTE entry.
> With 16MB hugepage and 64K HPTE we need 256 entries and with 4K HPTE we n=
eed
> 4096 entries. Both will fit in a 4K PTE page. On hugepage invalidate we n=
eed to walk
> the PTE page and invalidate all valid HPTEs.
>=20
> This patch implements necessary arch specific functions for THP support a=
nd also
> hugepage invalidate logic. These PMD related functions are intentionally =
kept
> similar to their PTE counter-part.
>=20
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
> ---
>  arch/powerpc/include/asm/page.h              |  11 +-
>  arch/powerpc/include/asm/pgtable-ppc64-64k.h |   3 +-
>  arch/powerpc/include/asm/pgtable-ppc64.h     | 259 +++++++++++++++++++++-
>  arch/powerpc/include/asm/pgtable.h           |   5 +
>  arch/powerpc/include/asm/pte-hash64-64k.h    |  17 ++
>  arch/powerpc/mm/pgtable_64.c                 | 318 +++++++++++++++++++++=
++++++
>  arch/powerpc/platforms/Kconfig.cputype       |   1 +
>  7 files changed, 611 insertions(+), 3 deletions(-)
>=20
> diff --git a/arch/powerpc/include/asm/page.h b/arch/powerpc/include/asm/p=
age.h
> index 988c812..cbf4be7 100644
> --- a/arch/powerpc/include/asm/page.h
> +++ b/arch/powerpc/include/asm/page.h
> @@ -37,8 +37,17 @@
>  #define PAGE_SIZE		(ASM_CONST(1) << PAGE_SHIFT)
> =20
>  #ifndef __ASSEMBLY__
> -#ifdef CONFIG_HUGETLB_PAGE
> +/*
> + * With hugetlbfs enabled we allow the HPAGE_SHIFT to run time
> + * configurable. But we enable THP only with 16MB hugepage.
> + * With only THP configured, we force hugepage size to 16MB.
> + * This should ensure that all subarchs that doesn't support
> + * THP continue to work fine with HPAGE_SHIFT usage.
> + */
> +#if defined(CONFIG_HUGETLB_PAGE)
>  extern unsigned int HPAGE_SHIFT;
> +#elif defined(CONFIG_TRANSPARENT_HUGEPAGE)
> +#define HPAGE_SHIFT PMD_SHIFT

As I said in comments on the first patch series, this messing around
with HPAGE_SHIFT for THP is missing the point.  On ppc HPAGE_SHIFT is
nothing more than the _default_ hugepage size for explicit hugepages.
THP should not be dependent on it in any way.

>  #else
>  #define HPAGE_SHIFT PAGE_SHIFT
>  #endif
> diff --git a/arch/powerpc/include/asm/pgtable-ppc64-64k.h b/arch/powerpc/=
include/asm/pgtable-ppc64-64k.h
> index 45142d6..a56b82f 100644
> --- a/arch/powerpc/include/asm/pgtable-ppc64-64k.h
> +++ b/arch/powerpc/include/asm/pgtable-ppc64-64k.h
> @@ -33,7 +33,8 @@
>  #define PGDIR_MASK	(~(PGDIR_SIZE-1))
> =20
>  /* Bits to mask out from a PMD to get to the PTE page */
> -#define PMD_MASKED_BITS		0x1ff
> +/* PMDs point to PTE table fragments which are 4K aligned.  */
> +#define PMD_MASKED_BITS		0xfff

Hrm.  AFAICT this is related to the change in size of PTE tables, and
hence the page sharing stuff, so this belongs in the patch which
implements that, rather than the THP support itself.

>  /* Bits to mask out from a PGD/PUD to get to the PMD page */
>  #define PUD_MASKED_BITS		0x1ff
> =20
> diff --git a/arch/powerpc/include/asm/pgtable-ppc64.h b/arch/powerpc/incl=
ude/asm/pgtable-ppc64.h
> index ab84332..20133c1 100644
> --- a/arch/powerpc/include/asm/pgtable-ppc64.h
> +++ b/arch/powerpc/include/asm/pgtable-ppc64.h
> @@ -154,7 +154,7 @@
>  #define	pmd_present(pmd)	(pmd_val(pmd) !=3D 0)
>  #define	pmd_clear(pmdp)		(pmd_val(*(pmdp)) =3D 0)
>  #define pmd_page_vaddr(pmd)	(pmd_val(pmd) & ~PMD_MASKED_BITS)
> -#define pmd_page(pmd)		virt_to_page(pmd_page_vaddr(pmd))
> +extern struct page *pmd_page(pmd_t pmd);
> =20
>  #define pud_set(pudp, pudval)	(pud_val(*(pudp)) =3D (pudval))
>  #define pud_none(pud)		(!pud_val(pud))
> @@ -382,4 +382,261 @@ static inline pte_t *find_linux_pte_or_hugepte(pgd_=
t *pgdir, unsigned long ea,
> =20
>  #endif /* __ASSEMBLY__ */
> =20
> +#ifndef _PAGE_SPLITTING
> +/*
> + * THP pages can't be special. So use the _PAGE_SPECIAL
> + */
> +#define _PAGE_SPLITTING _PAGE_SPECIAL
> +#endif
> +
> +#ifndef _PAGE_THP_HUGE
> +/*
> + * We need to differentiate between explicit huge page and THP huge
> + * page, since THP huge page also need to track real subpage details
> + * We use the _PAGE_COMBO bits here as dummy for platform that doesn't
> + * support THP.
> + */
> +#define _PAGE_THP_HUGE  0x10000000

So if it's _PAGE_COMBO, use _PAGE_COMBO, instead of the actual number.

> +#endif
> +
> +/*
> + * PTE flags to conserve for HPTE identification for THP page.
> + */
> +#ifndef _PAGE_THP_HPTEFLAGS
> +#define _PAGE_THP_HPTEFLAGS	(_PAGE_BUSY | _PAGE_HASHPTE)

You have this definition both here and in pte-hash64-64k.h.  More
importantly including _PAGE_BUSY seems like an extremely bad idea -
did you mean _PAGE_THP_HUGE =3D=3D _PAGE_COMBO?

> +#endif
> +
> +#define HUGE_PAGE_SIZE		(ASM_CONST(1) << 24)
> +#define HUGE_PAGE_MASK		(~(HUGE_PAGE_SIZE - 1))

These constants should be named so its clear they're THP specific.
They should also be defined in terms of PMD_SHIFT, instead of
directly.

> +/*
> + * set of bits not changed in pmd_modify.
> + */
> +#define _HPAGE_CHG_MASK (PTE_RPN_MASK | _PAGE_THP_HPTEFLAGS | \
> +			 _PAGE_DIRTY | _PAGE_ACCESSED | _PAGE_THP_HUGE)
> +
> +#ifndef __ASSEMBLY__
> +extern void hpte_need_hugepage_flush(struct mm_struct *mm, unsigned long=
 addr,
> +				     pmd_t *pmdp);

This should maybe be called "hpge_do_hugepage_flush()".  The current
name suggests it returns a boolean, rather than performing the actual
flush.

> +#ifdef CONFIG_TRANSPARENT_HUGEPAGE
> +extern pmd_t pfn_pmd(unsigned long pfn, pgprot_t pgprot);
> +extern pmd_t mk_pmd(struct page *page, pgprot_t pgprot);
> +extern pmd_t pmd_modify(pmd_t pmd, pgprot_t newprot);
> +extern void set_pmd_at(struct mm_struct *mm, unsigned long addr,
> +		       pmd_t *pmdp, pmd_t pmd);
> +extern void update_mmu_cache_pmd(struct vm_area_struct *vma, unsigned lo=
ng addr,
> +				 pmd_t *pmd);
> +
> +static inline int pmd_trans_huge(pmd_t pmd)
> +{
> +	/*
> +	 * leaf pte for huge page, bottom two bits !=3D 00
> +	 */
> +	return (pmd_val(pmd) & 0x3) && (pmd_val(pmd) & _PAGE_THP_HUGE);
> +}
> +
> +static inline int pmd_large(pmd_t pmd)
> +{
> +	/*
> +	 * leaf pte for huge page, bottom two bits !=3D 00
> +	 */
> +	if (pmd_trans_huge(pmd))
> +		return pmd_val(pmd) & _PAGE_PRESENT;
> +	return 0;
> +}
> +
> +static inline int pmd_trans_splitting(pmd_t pmd)
> +{
> +	if (pmd_trans_huge(pmd))
> +		return pmd_val(pmd) & _PAGE_SPLITTING;
> +	return 0;
> +}
> +
> +
> +static inline unsigned long pmd_pfn(pmd_t pmd)
> +{
> +	/*
> +	 * Only called for hugepage pmd
> +	 */
> +	return pmd_val(pmd) >> PTE_RPN_SHIFT;
> +}
> +
> +/* We will enable it in the last patch */
> +#define has_transparent_hugepage() 0
> +#endif /* CONFIG_TRANSPARENT_HUGEPAGE */
> +
> +static inline int pmd_young(pmd_t pmd)
> +{
> +	return pmd_val(pmd) & _PAGE_ACCESSED;
> +}

It would be clearer to define this function as well as various others
that operate on PMDs as PTEs to just cast the parameter and call the
corresponding pte_XXX(),

> +
> +static inline pmd_t pmd_mkhuge(pmd_t pmd)
> +{
> +	/* Do nothing, mk_pmd() does this part.  */
> +	return pmd;
> +}
> +
> +#define __HAVE_ARCH_PMD_WRITE
> +static inline int pmd_write(pmd_t pmd)
> +{
> +	return pmd_val(pmd) & _PAGE_RW;
> +}
> +
> +static inline pmd_t pmd_mkold(pmd_t pmd)
> +{
> +	pmd_val(pmd) &=3D ~_PAGE_ACCESSED;
> +	return pmd;
> +}
> +
> +static inline pmd_t pmd_wrprotect(pmd_t pmd)
> +{
> +	pmd_val(pmd) &=3D ~_PAGE_RW;
> +	return pmd;
> +}
> +
> +static inline pmd_t pmd_mkdirty(pmd_t pmd)
> +{
> +	pmd_val(pmd) |=3D _PAGE_DIRTY;
> +	return pmd;
> +}
> +
> +static inline pmd_t pmd_mkyoung(pmd_t pmd)
> +{
> +	pmd_val(pmd) |=3D _PAGE_ACCESSED;
> +	return pmd;
> +}
> +
> +static inline pmd_t pmd_mkwrite(pmd_t pmd)
> +{
> +	pmd_val(pmd) |=3D _PAGE_RW;
> +	return pmd;
> +}
> +
> +static inline pmd_t pmd_mknotpresent(pmd_t pmd)
> +{
> +	pmd_val(pmd) &=3D ~_PAGE_PRESENT;
> +	return pmd;
> +}
> +
> +static inline pmd_t pmd_mksplitting(pmd_t pmd)
> +{
> +	pmd_val(pmd) |=3D _PAGE_SPLITTING;
> +	return pmd;
> +}
> +
> +/*
> + * Set the dirty and/or accessed bits atomically in a linux hugepage PMD=
, this
> + * function doesn't need to flush the hash entry
> + */
> +static inline void __pmdp_set_access_flags(pmd_t *pmdp, pmd_t entry)
> +{
> +	unsigned long bits =3D pmd_val(entry) & (_PAGE_DIRTY |
> +					       _PAGE_ACCESSED |
> +					       _PAGE_RW | _PAGE_EXEC);
> +#ifdef PTE_ATOMIC_UPDATES
> +	unsigned long old, tmp;
> +
> +	__asm__ __volatile__(
> +	"1:	ldarx	%0,0,%4\n\
> +		andi.	%1,%0,%6\n\
> +		bne-	1b \n\
> +		or	%0,%3,%0\n\
> +		stdcx.	%0,0,%4\n\
> +		bne-	1b"
> +	:"=3D&r" (old), "=3D&r" (tmp), "=3Dm" (*pmdp)
> +	:"r" (bits), "r" (pmdp), "m" (*pmdp), "i" (_PAGE_BUSY)
> +	:"cc");
> +#else
> +	unsigned long old =3D pmd_val(*pmdp);
> +	*pmdp =3D __pmd(old | bits);
> +#endif

Using parameter casts on the corresponding pte_update() function would
be even more valuable for these more complex functions with asm.

> +}
> +
> +#define __HAVE_ARCH_PMD_SAME
> +static inline int pmd_same(pmd_t pmd_a, pmd_t pmd_b)
> +{
> +	return (((pmd_val(pmd_a) ^ pmd_val(pmd_b)) & ~_PAGE_THP_HPTEFLAGS) =3D=
=3D 0);

Here, specifically, the fact that PAGE_BUSY is in PAGE_THP_HPTEFLAGS
is likely to be bad.  If the page is busy, it's in the middle of
update so can't stably be considered the same as anything.

> +}
> +
> +#define __HAVE_ARCH_PMDP_SET_ACCESS_FLAGS
> +extern int pmdp_set_access_flags(struct vm_area_struct *vma,
> +				 unsigned long address, pmd_t *pmdp,
> +				 pmd_t entry, int dirty);
> +
> +static inline unsigned long pmd_hugepage_update(struct mm_struct *mm,
> +						unsigned long addr,
> +						pmd_t *pmdp, unsigned long clr)
> +{
> +#ifdef PTE_ATOMIC_UPDATES
> +	unsigned long old, tmp;
> +
> +	__asm__ __volatile__(
> +	"1:	ldarx	%0,0,%3\n\
> +		andi.	%1,%0,%6\n\
> +		bne-	1b \n\
> +		andc	%1,%0,%4 \n\
> +		stdcx.	%1,0,%3 \n\
> +		bne-	1b"
> +	: "=3D&r" (old), "=3D&r" (tmp), "=3Dm" (*pmdp)
> +	: "r" (pmdp), "r" (clr), "m" (*pmdp), "i" (_PAGE_BUSY)
> +	: "cc" );
> +#else
> +	unsigned long old =3D pmd_val(*pmdp);
> +	*pmdp =3D __pmd(old & ~clr);
> +#endif
> +
> +#ifdef CONFIG_PPC_STD_MMU_64

THP only works with the standard hash MMU, so this #if seems a bit
pointless.

> +	if (old & _PAGE_HASHPTE)
> +		hpte_need_hugepage_flush(mm, addr, pmdp);
> +#endif
> +	return old;
> +}
> +
> +static inline int __pmdp_test_and_clear_young(struct mm_struct *mm,
> +					      unsigned long addr, pmd_t *pmdp)
> +{
> +	unsigned long old;
> +
> +	if ((pmd_val(*pmdp) & (_PAGE_ACCESSED | _PAGE_HASHPTE)) =3D=3D 0)
> +		return 0;
> +	old =3D pmd_hugepage_update(mm, addr, pmdp, _PAGE_ACCESSED);
> +	return ((old & _PAGE_ACCESSED) !=3D 0);
> +}
> +
> +#define __HAVE_ARCH_PMDP_TEST_AND_CLEAR_YOUNG
> +extern int pmdp_test_and_clear_young(struct vm_area_struct *vma,
> +				     unsigned long address, pmd_t *pmdp);
> +#define __HAVE_ARCH_PMDP_CLEAR_YOUNG_FLUSH
> +extern int pmdp_clear_flush_young(struct vm_area_struct *vma,
> +				  unsigned long address, pmd_t *pmdp);
> +
> +#define __HAVE_ARCH_PMDP_GET_AND_CLEAR
> +extern pmd_t pmdp_get_and_clear(struct mm_struct *mm,
> +				unsigned long addr, pmd_t *pmdp);
> +
> +#define __HAVE_ARCH_PMDP_SET_WRPROTECT

Now that the PTE format is the same at bottom or PMD level, do you
still need this?

> +static inline void pmdp_set_wrprotect(struct mm_struct *mm, unsigned lon=
g addr,
> +				      pmd_t *pmdp)
> +{
> +
> +	if ((pmd_val(*pmdp) & _PAGE_RW) =3D=3D 0)
> +		return;
> +
> +	pmd_hugepage_update(mm, addr, pmdp, _PAGE_RW);
> +}
> +
> +#define __HAVE_ARCH_PMDP_SPLITTING_FLUSH
> +extern void pmdp_splitting_flush(struct vm_area_struct *vma,
> +				 unsigned long address, pmd_t *pmdp);
> +
> +#define __HAVE_ARCH_PGTABLE_DEPOSIT
> +extern void pgtable_trans_huge_deposit(struct mm_struct *mm, pmd_t *pmdp,
> +				       pgtable_t pgtable);
> +#define __HAVE_ARCH_PGTABLE_WITHDRAW
> +extern pgtable_t pgtable_trans_huge_withdraw(struct mm_struct *mm, pmd_t=
 *pmdp);
> +
> +#define __HAVE_ARCH_PMDP_INVALIDATE
> +extern void pmdp_invalidate(struct vm_area_struct *vma, unsigned long ad=
dress,
> +			    pmd_t *pmdp);
> +#endif /* __ASSEMBLY__ */
>  #endif /* _ASM_POWERPC_PGTABLE_PPC64_H_ */
> diff --git a/arch/powerpc/include/asm/pgtable.h b/arch/powerpc/include/as=
m/pgtable.h
> index 7aeb955..283198e 100644
> --- a/arch/powerpc/include/asm/pgtable.h
> +++ b/arch/powerpc/include/asm/pgtable.h
> @@ -222,5 +222,10 @@ extern int gup_hugepte(pte_t *ptep, unsigned long sz=
, unsigned long addr,
>  		       unsigned long end, int write, struct page **pages, int *nr);
>  #endif /* __ASSEMBLY__ */
> =20
> +#ifndef CONFIG_TRANSPARENT_HUGEPAGE
> +#define pmd_large(pmd)		0
> +#define has_transparent_hugepage() 0
> +#endif
> +
>  #endif /* __KERNEL__ */
>  #endif /* _ASM_POWERPC_PGTABLE_H */
> diff --git a/arch/powerpc/include/asm/pte-hash64-64k.h b/arch/powerpc/inc=
lude/asm/pte-hash64-64k.h
> index 3e13e23..6be70be 100644
> --- a/arch/powerpc/include/asm/pte-hash64-64k.h
> +++ b/arch/powerpc/include/asm/pte-hash64-64k.h
> @@ -38,6 +38,23 @@
>   */
>  #define PTE_RPN_SHIFT	(30)
> =20
> +/*
> + * THP pages can't be special. So use the _PAGE_SPECIAL
> + */
> +#define _PAGE_SPLITTING _PAGE_SPECIAL
> +
> +/*
> + * PTE flags to conserve for HPTE identification for THP page.
> + * We drop _PAGE_COMBO here, because we overload that with _PAGE_TH_HUGE.
> + */
> +#define _PAGE_THP_HPTEFLAGS	(_PAGE_BUSY | _PAGE_HASHPTE)
> +
> +/*
> + * We need to differentiate between explicit huge page and THP huge
> + * page, since THP huge page also need to track real subpage details
> + */
> +#define _PAGE_THP_HUGE  _PAGE_COMBO

All 3 of these definitions also appeared elsewhere.

> +
>  #ifndef __ASSEMBLY__
> =20
>  /*
> diff --git a/arch/powerpc/mm/pgtable_64.c b/arch/powerpc/mm/pgtable_64.c
> index a854096..54216c1 100644
> --- a/arch/powerpc/mm/pgtable_64.c
> +++ b/arch/powerpc/mm/pgtable_64.c
> @@ -338,6 +338,19 @@ EXPORT_SYMBOL(iounmap);
>  EXPORT_SYMBOL(__iounmap);
>  EXPORT_SYMBOL(__iounmap_at);
> =20
> +/*
> + * For hugepage we have pfn in the pmd, we use PTE_RPN_SHIFT bits for fl=
ags
> + * For PTE page, we have a PTE_FRAG_SIZE (4K) aligned virtual address.
> + */
> +struct page *pmd_page(pmd_t pmd)
> +{
> +#ifdef CONFIG_TRANSPARENT_HUGEPAGE
> +	if (pmd_trans_huge(pmd))
> +		return pfn_to_page(pmd_pfn(pmd));

In this case you should be able to define this in terms of pte_pfn().

> +#endif
> +	return virt_to_page(pmd_page_vaddr(pmd));
> +}
> +
>  #ifdef CONFIG_PPC_64K_PAGES
>  static pte_t *get_from_cache(struct mm_struct *mm)
>  {
> @@ -455,3 +468,308 @@ void pgtable_free_tlb(struct mmu_gather *tlb, void =
*table, int shift)
>  }
>  #endif
>  #endif /* CONFIG_PPC_64K_PAGES */
> +
> +#ifdef CONFIG_TRANSPARENT_HUGEPAGE
> +static pmd_t set_hugepage_access_flags_filter(pmd_t pmd,
> +					      struct vm_area_struct *vma,
> +					      int dirty)
> +{
> +	return pmd;
> +}

This identity function is only used immediately before.  Why does it
exist?

> +/*
> + * This is called when relaxing access to a hugepage. It's also called i=
n the page
> + * fault path when we don't hit any of the major fault cases, ie, a minor
> + * update of _PAGE_ACCESSED, _PAGE_DIRTY, etc... The generic code will h=
ave
> + * handled those two for us, we additionally deal with missing execute
> + * permission here on some processors
> + */
> +int pmdp_set_access_flags(struct vm_area_struct *vma, unsigned long addr=
ess,
> +			  pmd_t *pmdp, pmd_t entry, int dirty)
> +{
> +	int changed;
> +	entry =3D set_hugepage_access_flags_filter(entry, vma, dirty);
> +	changed =3D !pmd_same(*(pmdp), entry);
> +	if (changed) {
> +		__pmdp_set_access_flags(pmdp, entry);
> +		/*
> +		 * Since we are not supporting SW TLB systems, we don't
> +		 * have any thing similar to flush_tlb_page_nohash()
> +		 */
> +	}
> +	return changed;
> +}
> +
> +int pmdp_test_and_clear_young(struct vm_area_struct *vma,
> +			      unsigned long address, pmd_t *pmdp)
> +{
> +	return __pmdp_test_and_clear_young(vma->vm_mm, address, pmdp);
> +}
> +
> +/*
> + * We currently remove entries from the hashtable regardless of whether
> + * the entry was young or dirty. The generic routines only flush if the
> + * entry was young or dirty which is not good enough.
> + *
> + * We should be more intelligent about this but for the moment we overri=
de
> + * these functions and force a tlb flush unconditionally
> + */
> +int pmdp_clear_flush_young(struct vm_area_struct *vma,
> +				  unsigned long address, pmd_t *pmdp)
> +{
> +	return __pmdp_test_and_clear_young(vma->vm_mm, address, pmdp);
> +}
> +
> +/*
> + * We mark the pmd splitting and invalidate all the hpte
> + * entries for this hugepage.
> + */
> +void pmdp_splitting_flush(struct vm_area_struct *vma,
> +			  unsigned long address, pmd_t *pmdp)
> +{
> +	unsigned long old, tmp;
> +
> +	VM_BUG_ON(address & ~HPAGE_PMD_MASK);
> +#ifdef PTE_ATOMIC_UPDATES
> +
> +	__asm__ __volatile__(
> +	"1:	ldarx	%0,0,%3\n\
> +		andi.	%1,%0,%6\n\
> +		bne-	1b \n\
> +		ori	%1,%0,%4 \n\
> +		stdcx.	%1,0,%3 \n\
> +		bne-	1b"
> +	: "=3D&r" (old), "=3D&r" (tmp), "=3Dm" (*pmdp)
> +	: "r" (pmdp), "i" (_PAGE_SPLITTING), "m" (*pmdp), "i" (_PAGE_BUSY)
> +	: "cc" );
> +#else
> +	old =3D pmd_val(*pmdp);
> +	*pmdp =3D __pmd(old | _PAGE_SPLITTING);
> +#endif
> +	/*
> +	 * If we didn't had the splitting flag set, go and flush the
> +	 * HPTE entries and serialize against gup fast.
> +	 */
> +	if (!(old & _PAGE_SPLITTING)) {
> +#ifdef CONFIG_PPC_STD_MMU_64
> +		/* We need to flush the hpte */
> +		if (old & _PAGE_HASHPTE)
> +			hpte_need_hugepage_flush(vma->vm_mm, address, pmdp);
> +#endif
> +		/* need tlb flush only to serialize against gup-fast */
> +		flush_tlb_range(vma, address, address + HPAGE_PMD_SIZE);
> +	}
> +}
> +
> +/*
> + * We want to put the pgtable in pmd and use pgtable for tracking
> + * the base page size hptes
> + */
> +void pgtable_trans_huge_deposit(struct mm_struct *mm, pmd_t *pmdp,
> +				pgtable_t pgtable)
> +{
> +	unsigned long *pgtable_slot;
> +	assert_spin_locked(&mm->page_table_lock);
> +	/*
> +	 * we store the pgtable in the second half of PMD
> +	 */
> +	pgtable_slot =3D pmdp + PTRS_PER_PMD;
> +	*pgtable_slot =3D (unsigned long)pgtable;

Why not just make pgtable_slot have type (pgtable_t *) and avoid the
case.

> +}
> +
> +pgtable_t pgtable_trans_huge_withdraw(struct mm_struct *mm, pmd_t *pmdp)
> +{
> +	pgtable_t pgtable;
> +	unsigned long *pgtable_slot;
> +
> +	assert_spin_locked(&mm->page_table_lock);
> +	pgtable_slot =3D pmdp + PTRS_PER_PMD;
> +	pgtable =3D (pgtable_t) *pgtable_slot;
> +	/*
> +	 * We store HPTE information in the deposited PTE fragment.
> +	 * zero out the content on withdraw.
> +	 */
> +	memset(pgtable, 0, PTE_FRAG_SIZE);
> +	return pgtable;
> +}
> +
> +/*
> + * Since we are looking at latest ppc64, we don't need to worry about
> + * i/d cache coherency on exec fault
> + */
> +static pmd_t set_pmd_filter(pmd_t pmd, unsigned long addr)
> +{
> +	pmd =3D __pmd(pmd_val(pmd) & ~_PAGE_THP_HPTEFLAGS);
> +	return pmd;
> +}
> +
> +/*
> + * We can make it less convoluted than __set_pte_at, because
> + * we can ignore lot of hardware here, because this is only for
> + * MPSS
> + */
> +static inline void __set_pmd_at(struct mm_struct *mm, unsigned long addr,
> +				pmd_t *pmdp, pmd_t pmd, int percpu)
> +{
> +	/*
> +	 * There is nothing in hash page table now, so nothing to
> +	 * invalidate, set_pte_at is used for adding new entry.
> +	 * For updating we should use update_hugepage_pmd()
> +	 */
> +	*pmdp =3D pmd;
> +}

Again you should be able to define this in terms of the set_pte_at()
functions.

> +/*
> + * set a new huge pmd. We should not be called for updating
> + * an existing pmd entry. That should go via pmd_hugepage_update.
> + */
> +void set_pmd_at(struct mm_struct *mm, unsigned long addr,
> +		pmd_t *pmdp, pmd_t pmd)
> +{
> +	/*
> +	 * Note: mm->context.id might not yet have been assigned as
> +	 * this context might not have been activated yet when this
> +	 * is called.

And the relevance of this comment here is...?

> +	 */
> +	pmd =3D set_pmd_filter(pmd, addr);
> +
> +	__set_pmd_at(mm, addr, pmdp, pmd, 0);
> +
> +}
> +
> +void pmdp_invalidate(struct vm_area_struct *vma, unsigned long address,
> +		     pmd_t *pmdp)
> +{
> +	pmd_hugepage_update(vma->vm_mm, address, pmdp, _PAGE_PRESENT);
> +	flush_tlb_range(vma, address, address + HPAGE_PMD_SIZE);
> +}
> +
> +/*
> + * A linux hugepage PMD was changed and the corresponding hash table ent=
ries
> + * neesd to be flushed.
> + *
> + * The linux hugepage PMD now include the pmd entries followed by the ad=
dress
> + * to the stashed pgtable_t. The stashed pgtable_t contains the hpte bit=
s.
> + * [ secondary group | 3 bit hidx | valid ]. We use one byte per each HP=
TE entry.
> + * With 16MB hugepage and 64K HPTE we need 256 entries and with 4K HPTE =
we need
> + * 4096 entries. Both will fit in a 4K pgtable_t.
> + */
> +void hpte_need_hugepage_flush(struct mm_struct *mm, unsigned long addr,
> +			      pmd_t *pmdp)
> +{
> +	int ssize, i;
> +	unsigned long s_addr;
> +	unsigned int psize, valid;
> +	unsigned char *hpte_slot_array;
> +	unsigned long hidx, vpn, vsid, hash, shift, slot;
> +
> +	/*
> +	 * Flush all the hptes mapping this hugepage
> +	 */
> +	s_addr =3D addr & HUGE_PAGE_MASK;
> +	/*
> +	 * The hpte hindex are stored in the pgtable whose address is in the
> +	 * second half of the PMD
> +	 */
> +	hpte_slot_array =3D *(char **)(pmdp + PTRS_PER_PMD);
> +
> +	/* get the base page size */
> +	psize =3D get_slice_psize(mm, s_addr);
> +	shift =3D mmu_psize_defs[psize].shift;
> +
> +	for (i =3D 0; i < (HUGE_PAGE_SIZE >> shift); i++) {
> +		/*
> +		 * 8 bits per each hpte entries
> +		 * 000| [ secondary group (one bit) | hidx (3 bits) | valid bit]
> +		 */
> +		valid =3D hpte_slot_array[i] & 0x1;
> +		if (!valid)
> +			continue;
> +		hidx =3D  hpte_slot_array[i]  >> 1;
> +
> +		/* get the vpn */
> +		addr =3D s_addr + (i * (1ul << shift));
> +		if (!is_kernel_addr(addr)) {
> +			ssize =3D user_segment_size(addr);
> +			vsid =3D get_vsid(mm->context.id, addr, ssize);
> +			WARN_ON(vsid =3D=3D 0);
> +		} else {
> +			vsid =3D get_kernel_vsid(addr, mmu_kernel_ssize);
> +			ssize =3D mmu_kernel_ssize;
> +		}
> +
> +		vpn =3D hpt_vpn(addr, vsid, ssize);
> +		hash =3D hpt_hash(vpn, shift, ssize);
> +		if (hidx & _PTEIDX_SECONDARY)
> +			hash =3D ~hash;
> +
> +		slot =3D (hash & htab_hash_mask) * HPTES_PER_GROUP;
> +		slot +=3D hidx & _PTEIDX_GROUP_IX;
> +		ppc_md.hpte_invalidate(slot, vpn, psize, ssize, 0);
> +	}
> +}
> +
> +static pmd_t pmd_set_protbits(pmd_t pmd, pgprot_t pgprot)
> +{
> +	pmd_val(pmd) |=3D pgprot_val(pgprot);
> +	return pmd;
> +}
> +
> +pmd_t pfn_pmd(unsigned long pfn, pgprot_t pgprot)
> +{
> +	pmd_t pmd;
> +	/*
> +	 * For a valid pte, we would have _PAGE_PRESENT or _PAGE_FILE always
> +	 * set. We use this to check THP page at pmd level.
> +	 * leaf pte for huge page, bottom two bits !=3D 00
> +	 */
> +	pmd_val(pmd) =3D pfn << PTE_RPN_SHIFT;
> +	pmd_val(pmd) |=3D _PAGE_THP_HUGE;
> +	pmd =3D pmd_set_protbits(pmd, pgprot);
> +	return pmd;
> +}
> +
> +pmd_t mk_pmd(struct page *page, pgprot_t pgprot)
> +{
> +	return pfn_pmd(page_to_pfn(page), pgprot);
> +}
> +
> +pmd_t pmd_modify(pmd_t pmd, pgprot_t newprot)
> +{
> +
> +	pmd_val(pmd) &=3D _HPAGE_CHG_MASK;
> +	pmd =3D pmd_set_protbits(pmd, newprot);
> +	return pmd;
> +}
> +
> +/*
> + * This is called at the end of handling a user page fault, when the
> + * fault has been handled by updating a HUGE PMD entry in the linux page=
 tables.
> + * We use it to preload an HPTE into the hash table corresponding to
> + * the updated linux HUGE PMD entry.
> + */
> +void update_mmu_cache_pmd(struct vm_area_struct *vma, unsigned long addr,
> +			  pmd_t *pmd)
> +{
> +	return;
> +}
> +
> +#endif /* CONFIG_TRANSPARENT_HUGEPAGE */
> +
> +pmd_t pmdp_get_and_clear(struct mm_struct *mm,
> +			 unsigned long addr, pmd_t *pmdp)
> +{
> +	pmd_t old_pmd;
> +	unsigned long old;
> +	/*
> +	 * khugepaged calls this for normal pmd also
> +	 */
> +	if (pmd_trans_huge(*pmdp)) {
> +		old =3D pmd_hugepage_update(mm, addr, pmdp, ~0UL);
> +		old_pmd =3D __pmd(old);
> +	} else {
> +		old_pmd =3D *pmdp;
> +		pmd_clear(pmdp);
> +	}
> +	return old_pmd;
> +}
> diff --git a/arch/powerpc/platforms/Kconfig.cputype b/arch/powerpc/platfo=
rms/Kconfig.cputype
> index 18e3b76..a526144 100644
> --- a/arch/powerpc/platforms/Kconfig.cputype
> +++ b/arch/powerpc/platforms/Kconfig.cputype
> @@ -71,6 +71,7 @@ config PPC_BOOK3S_64
>  	select PPC_FPU
>  	select PPC_HAVE_PMU_SUPPORT
>  	select SYS_SUPPORTS_HUGETLBFS
> +	select HAVE_ARCH_TRANSPARENT_HUGEPAGE if PPC_64K_PAGES
> =20
>  config PPC_BOOK3E_64
>  	bool "Embedded processors"

--=20
David Gibson			| I'll have my music baroque, and my code
david AT gibson.dropbear.id.au	| minimalist, thank you.  NOT _the_ _other_
				| _way_ _around_!
http://www.ozlabs.org/~dgibson

--qcTtWMBd/uZDG7+Y
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iEYEARECAAYFAlGDQnEACgkQaILKxv3ab8aPcQCdEB3IeYxhTVJ9nR7Fu5q9wS89
QrAAn341ylLQU90hX99TDi29RjfnZI4U
=te3S
-----END PGP SIGNATURE-----

--qcTtWMBd/uZDG7+Y--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
