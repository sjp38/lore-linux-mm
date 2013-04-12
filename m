Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id 4DEB06B0006
	for <linux-mm@kvack.org>; Fri, 12 Apr 2013 00:01:44 -0400 (EDT)
Received: from /spool/local
	by e23smtp09.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dwg@au1.ibm.com>;
	Fri, 12 Apr 2013 13:52:46 +1000
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [9.190.234.120])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id 69F972CE8051
	for <linux-mm@kvack.org>; Fri, 12 Apr 2013 14:01:17 +1000 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r3C3lu8J28377198
	for <linux-mm@kvack.org>; Fri, 12 Apr 2013 13:47:57 +1000
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r3C41GmU010525
	for <linux-mm@kvack.org>; Fri, 12 Apr 2013 14:01:16 +1000
Date: Fri, 12 Apr 2013 14:01:32 +1000
From: David Gibson <dwg@au1.ibm.com>
Subject: Re: [PATCH -V5 20/25] powerpc/THP: Add code to handle HPTE faults
 for large pages
Message-ID: <20130412040132.GF5065@truffula.fritz.box>
References: <1365055083-31956-21-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="KJY2Ze80yH5MUxol"
Content-Disposition: inline
In-Reply-To: <1365055083-31956-21-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: benh@kernel.crashing.org, paulus@samba.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org

--KJY2Ze80yH5MUxol
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Apr 04, 2013 at 11:27:58AM +0530, Aneesh Kumar K.V wrote:
> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
>=20
> We now have pmd entries covering to 16MB range. To implement THP on power=
pc,
> we double the size of PMD. The second half is used to deposit the pgtable=
 (PTE page).
> We also use the depoisted PTE page for tracking the HPTE information. The=
 information
> include [ secondary group | 3 bit hidx | valid ]. We use one byte per eac=
h HPTE entry.
> With 16MB hugepage and 64K HPTE we need 256 entries and with 4K HPTE we n=
eed
> 4096 entries. Both will fit in a 4K PTE page.

This description is a duplicate of an earlier path.  Both are
innaccurate for the patches they are now attached to.

> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
> ---
>  arch/powerpc/include/asm/mmu-hash64.h    |    5 +
>  arch/powerpc/include/asm/pgtable-ppc64.h |   31 +----
>  arch/powerpc/kernel/io-workarounds.c     |    3 +-
>  arch/powerpc/kvm/book3s_64_mmu_hv.c      |    2 +-
>  arch/powerpc/kvm/book3s_hv_rm_mmu.c      |    4 +-
>  arch/powerpc/mm/Makefile                 |    1 +
>  arch/powerpc/mm/hash_utils_64.c          |   16 ++-
>  arch/powerpc/mm/hugepage-hash64.c        |  185 ++++++++++++++++++++++++=
++++++
>  arch/powerpc/mm/hugetlbpage.c            |   31 ++++-
>  arch/powerpc/mm/pgtable.c                |   38 ++++++
>  arch/powerpc/mm/tlb_hash64.c             |    5 +-
>  arch/powerpc/perf/callchain.c            |    2 +-
>  arch/powerpc/platforms/pseries/eeh.c     |    5 +-
>  13 files changed, 286 insertions(+), 42 deletions(-)
>  create mode 100644 arch/powerpc/mm/hugepage-hash64.c
>=20
> diff --git a/arch/powerpc/include/asm/mmu-hash64.h b/arch/powerpc/include=
/asm/mmu-hash64.h
> index e187254..a74a3de 100644
> --- a/arch/powerpc/include/asm/mmu-hash64.h
> +++ b/arch/powerpc/include/asm/mmu-hash64.h
> @@ -322,6 +322,11 @@ extern int hash_page(unsigned long ea, unsigned long=
 access, unsigned long trap)
>  int __hash_page_huge(unsigned long ea, unsigned long access, unsigned lo=
ng vsid,
>  		     pte_t *ptep, unsigned long trap, int local, int ssize,
>  		     unsigned int shift, unsigned int mmu_psize);
> +#ifdef CONFIG_TRANSPARENT_HUGEPAGE
> +extern int __hash_page_thp(unsigned long ea, unsigned long access,
> +			   unsigned long vsid, pmd_t *pmdp, unsigned long trap,
> +			   int local, int ssize, unsigned int psize);
> +#endif
>  extern void hash_failure_debug(unsigned long ea, unsigned long access,
>  			       unsigned long vsid, unsigned long trap,
>  			       int ssize, int psize, int lpsize,
> diff --git a/arch/powerpc/include/asm/pgtable-ppc64.h b/arch/powerpc/incl=
ude/asm/pgtable-ppc64.h
> index d4e845c..9b81283 100644
> --- a/arch/powerpc/include/asm/pgtable-ppc64.h
> +++ b/arch/powerpc/include/asm/pgtable-ppc64.h
> @@ -345,39 +345,18 @@ static inline void __ptep_set_access_flags(pte_t *p=
tep, pte_t entry)
>  void pgtable_cache_add(unsigned shift, void (*ctor)(void *));
>  void pgtable_cache_init(void);
> =20
> -/*
> - * find_linux_pte returns the address of a linux pte for a given
> - * effective address and directory.  If not found, it returns zero.
> - */
> -static inline pte_t *find_linux_pte(pgd_t *pgdir, unsigned long ea)
> -{
> -	pgd_t *pg;
> -	pud_t *pu;
> -	pmd_t *pm;
> -	pte_t *pt =3D NULL;
> -
> -	pg =3D pgdir + pgd_index(ea);
> -	if (!pgd_none(*pg)) {
> -		pu =3D pud_offset(pg, ea);
> -		if (!pud_none(*pu)) {
> -			pm =3D pmd_offset(pu, ea);
> -			if (pmd_present(*pm))
> -				pt =3D pte_offset_kernel(pm, ea);
> -		}
> -	}
> -	return pt;
> -}
> -
> +pte_t *find_linux_pte(pgd_t *pgdir, unsigned long ea, unsigned int *thp);
>  #ifdef CONFIG_HUGETLB_PAGE
>  pte_t *find_linux_pte_or_hugepte(pgd_t *pgdir, unsigned long ea,
> -				 unsigned *shift);
> +				 unsigned *shift, unsigned int *hugepage);
>  #else
>  static inline pte_t *find_linux_pte_or_hugepte(pgd_t *pgdir, unsigned lo=
ng ea,
> -					       unsigned *shift)
> +					       unsigned *shift,
> +					       unsigned int *hugepage)
>  {
>  	if (shift)
>  		*shift =3D 0;
> -	return find_linux_pte(pgdir, ea);
> +	return find_linux_pte(pgdir, ea, hugepage);
>  }
>  #endif /* !CONFIG_HUGETLB_PAGE */
> =20
> diff --git a/arch/powerpc/kernel/io-workarounds.c b/arch/powerpc/kernel/i=
o-workarounds.c
> index 50e90b7..a9c904f 100644
> --- a/arch/powerpc/kernel/io-workarounds.c
> +++ b/arch/powerpc/kernel/io-workarounds.c
> @@ -70,7 +70,8 @@ struct iowa_bus *iowa_mem_find_bus(const PCI_IO_ADDR ad=
dr)
>  		if (vaddr < PHB_IO_BASE || vaddr >=3D PHB_IO_END)
>  			return NULL;
> =20
> -		ptep =3D find_linux_pte(init_mm.pgd, vaddr);
> +		/* we won't find hugepages here */

Explaining why might be a good idea.

> +		ptep =3D find_linux_pte(init_mm.pgd, vaddr, NULL);
>  		if (ptep =3D=3D NULL)
>  			paddr =3D 0;
>  		else
> diff --git a/arch/powerpc/kvm/book3s_64_mmu_hv.c b/arch/powerpc/kvm/book3=
s_64_mmu_hv.c
> index 8cc18ab..4f2a7dc 100644
> --- a/arch/powerpc/kvm/book3s_64_mmu_hv.c
> +++ b/arch/powerpc/kvm/book3s_64_mmu_hv.c
> @@ -683,7 +683,7 @@ int kvmppc_book3s_hv_page_fault(struct kvm_run *run, =
struct kvm_vcpu *vcpu,
>  			 */
>  			rcu_read_lock_sched();
>  			ptep =3D find_linux_pte_or_hugepte(current->mm->pgd,
> -							 hva, NULL);
> +							 hva, NULL, NULL);
>  			if (ptep && pte_present(*ptep)) {
>  				pte =3D kvmppc_read_update_linux_pte(ptep, 1);
>  				if (pte_write(pte))
> diff --git a/arch/powerpc/kvm/book3s_hv_rm_mmu.c b/arch/powerpc/kvm/book3=
s_hv_rm_mmu.c
> index 19c93ba..7c8e1ed 100644
> --- a/arch/powerpc/kvm/book3s_hv_rm_mmu.c
> +++ b/arch/powerpc/kvm/book3s_hv_rm_mmu.c
> @@ -27,7 +27,7 @@ static void *real_vmalloc_addr(void *x)
>  	unsigned long addr =3D (unsigned long) x;
>  	pte_t *p;
> =20
> -	p =3D find_linux_pte(swapper_pg_dir, addr);
> +	p =3D find_linux_pte(swapper_pg_dir, addr, NULL);

And this one.

>  	if (!p || !pte_present(*p))
>  		return NULL;
>  	/* assume we don't have huge pages in vmalloc space... */
> @@ -152,7 +152,7 @@ static pte_t lookup_linux_pte(pgd_t *pgdir, unsigned =
long hva,
>  	unsigned long ps =3D *pte_sizep;
>  	unsigned int shift;
> =20
> -	ptep =3D find_linux_pte_or_hugepte(pgdir, hva, &shift);
> +	ptep =3D find_linux_pte_or_hugepte(pgdir, hva, &shift, NULL);
>  	if (!ptep)
>  		return __pte(0);
>  	if (shift)
> diff --git a/arch/powerpc/mm/Makefile b/arch/powerpc/mm/Makefile
> index 3787b61..997deb4 100644
> --- a/arch/powerpc/mm/Makefile
> +++ b/arch/powerpc/mm/Makefile
> @@ -33,6 +33,7 @@ obj-y				+=3D hugetlbpage.o
>  obj-$(CONFIG_PPC_STD_MMU_64)	+=3D hugetlbpage-hash64.o
>  obj-$(CONFIG_PPC_BOOK3E_MMU)	+=3D hugetlbpage-book3e.o
>  endif
> +obj-$(CONFIG_TRANSPARENT_HUGEPAGE) +=3D hugepage-hash64.o
>  obj-$(CONFIG_PPC_SUBPAGE_PROT)	+=3D subpage-prot.o
>  obj-$(CONFIG_NOT_COHERENT_CACHE) +=3D dma-noncoherent.o
>  obj-$(CONFIG_HIGHMEM)		+=3D highmem.o
> diff --git a/arch/powerpc/mm/hash_utils_64.c b/arch/powerpc/mm/hash_utils=
_64.c
> index 1f2ebbd..cd3ecd8 100644
> --- a/arch/powerpc/mm/hash_utils_64.c
> +++ b/arch/powerpc/mm/hash_utils_64.c
> @@ -955,7 +955,7 @@ int hash_page(unsigned long ea, unsigned long access,=
 unsigned long trap)
>  	unsigned long vsid;
>  	struct mm_struct *mm;
>  	pte_t *ptep;
> -	unsigned hugeshift;
> +	unsigned hugeshift, hugepage;
>  	const struct cpumask *tmp;
>  	int rc, user_region =3D 0, local =3D 0;
>  	int psize, ssize;
> @@ -1021,7 +1021,7 @@ int hash_page(unsigned long ea, unsigned long acces=
s, unsigned long trap)
>  #endif /* CONFIG_PPC_64K_PAGES */
> =20
>  	/* Get PTE and page size from page tables */
> -	ptep =3D find_linux_pte_or_hugepte(pgdir, ea, &hugeshift);
> +	ptep =3D find_linux_pte_or_hugepte(pgdir, ea, &hugeshift, &hugepage);
>  	if (ptep =3D=3D NULL || !pte_present(*ptep)) {

And so's this, since you don't check the hugepage return before
calling pte_present().

>  		DBG_LOW(" no PTE !\n");
>  		return 1;
> @@ -1044,6 +1044,12 @@ int hash_page(unsigned long ea, unsigned long acce=
ss, unsigned long trap)
>  					ssize, hugeshift, psize);
>  #endif /* CONFIG_HUGETLB_PAGE */
> =20
> +#ifdef CONFIG_TRANSPARENT_HUGEPAGE
> +	if (hugepage)
> +		return __hash_page_thp(ea, access, vsid, (pmd_t *)ptep,
> +				       trap, local, ssize, psize);
> +#endif
> +
>  #ifndef CONFIG_PPC_64K_PAGES
>  	DBG_LOW(" i-pte: %016lx\n", pte_val(*ptep));
>  #else
> @@ -1149,7 +1155,11 @@ void hash_preload(struct mm_struct *mm, unsigned l=
ong ea,
>  	pgdir =3D mm->pgd;
>  	if (pgdir =3D=3D NULL)
>  		return;
> -	ptep =3D find_linux_pte(pgdir, ea);
> +	/*
> +	 * We haven't implemented update_mmu_cache_pmd yet. We get called
> +	 * only for non hugepages. Hence can ignore THP here

Uh.. why?  By definition THP will occur in non-hugepage areas.

> +	 */
> +	ptep =3D find_linux_pte(pgdir, ea, NULL);
>  	if (!ptep)
>  		return;
> =20
> diff --git a/arch/powerpc/mm/hugepage-hash64.c b/arch/powerpc/mm/hugepage=
-hash64.c
> new file mode 100644
> index 0000000..3f6140d
> --- /dev/null
> +++ b/arch/powerpc/mm/hugepage-hash64.c
> @@ -0,0 +1,185 @@
> +/*
> + * Copyright IBM Corporation, 2013
> + * Author Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
> + *
> + * This program is free software; you can redistribute it and/or modify =
it
> + * under the terms of version 2.1 of the GNU Lesser General Public Licen=
se
> + * as published by the Free Software Foundation.
> + *
> + * This program is distributed in the hope that it would be useful, but
> + * WITHOUT ANY WARRANTY; without even the implied warranty of
> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
> + *
> + */
> +
> +/*
> + * PPC64 THP Support for hash based MMUs
> + */
> +#include <linux/mm.h>
> +#include <asm/machdep.h>
> +
> +/*
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
> +int __hash_page_thp(unsigned long ea, unsigned long access, unsigned lon=
g vsid,
> +		    pmd_t *pmdp, unsigned long trap, int local, int ssize,
> +		    unsigned int psize)
> +{
> +	unsigned int index, valid;
> +	unsigned char *hpte_slot_array;
> +	unsigned long rflags, pa, hidx;
> +	unsigned long old_pmd, new_pmd;
> +	int ret, lpsize =3D MMU_PAGE_16M;
> +	unsigned long vpn, hash, shift, slot;
> +
> +	/*
> +	 * atomically mark the linux large page PMD busy and dirty
> +	 */
> +	do {
> +		old_pmd =3D pmd_val(*pmdp);
> +		/* If PMD busy, retry the access */
> +		if (unlikely(old_pmd & PMD_HUGE_BUSY))
> +			return 0;
> +		/* If PMD permissions don't match, take page fault */
> +		if (unlikely(access & ~old_pmd))
> +			return 1;
> +		/*
> +		 * Try to lock the PTE, add ACCESSED and DIRTY if it was
> +		 * a write access
> +		 */
> +		new_pmd =3D old_pmd | PMD_HUGE_BUSY | PMD_HUGE_ACCESSED;
> +		if (access & _PAGE_RW)
> +			new_pmd |=3D PMD_HUGE_DIRTY;
> +	} while (old_pmd !=3D __cmpxchg_u64((unsigned long *)pmdp,
> +					  old_pmd, new_pmd));
> +	/*
> +	 * PP bits. PMD_HUGE_USER is already PP bit 0x2, so we only
> +	 * need to add in 0x1 if it's a read-only user page
> +	 */
> +	rflags =3D new_pmd & PMD_HUGE_USER;
> +	if ((new_pmd & PMD_HUGE_USER) && !((new_pmd & PMD_HUGE_RW) &&
> +					   (new_pmd & PMD_HUGE_DIRTY)))
> +		rflags |=3D 0x1;
> +	/*
> +	 * PMD_HUGE_EXEC -> HW_NO_EXEC since it's inverted
> +	 */
> +	rflags |=3D ((new_pmd & PMD_HUGE_EXEC) ? 0 : HPTE_R_N);
> +
> +#if 0 /* FIXME!! */
> +	if (!cpu_has_feature(CPU_FTR_COHERENT_ICACHE)) {
> +
> +		/*
> +		 * No CPU has hugepages but lacks no execute, so we
> +		 * don't need to worry about that case
> +		 */
> +		rflags =3D hash_page_do_lazy_icache(rflags, __pte(old_pte), trap);
> +	}
> +#endif
> +	/*
> +	 * Find the slot index details for this ea, using base page size.
> +	 */
> +	shift =3D mmu_psize_defs[psize].shift;
> +	index =3D (ea & (HUGE_PAGE_SIZE - 1)) >> shift;
> +	BUG_ON(index > 4096);

That needs to be >=3D, not >.  Also you should probably use the existing
#defines to derive this rather than hard coding 4096.

> +
> +	vpn =3D hpt_vpn(ea, vsid, ssize);
> +	hash =3D hpt_hash(vpn, shift, ssize);
> +	/*
> +	 * The hpte hindex are stored in the pgtable whose address is in the
> +	 * second half of the PMD
> +	 */
> +	hpte_slot_array =3D *(char **)(pmdp + PTRS_PER_PMD);

Hrm.  I gather the contents of the extra pgtable is protected by the
PTE's busy bit.  But what synchronization is necessary for the pgtable
pointer - are there any possible races with the hugepage being split?

> +	valid =3D hpte_slot_array[index]  & 0x1;
> +	if (unlikely(valid)) {

Why is valid unlikely?  I think you'd be better off leaving this to
the CPU's dynamic branch prediction.

> +		/* update the hpte bits */
> +		hidx =3D  hpte_slot_array[index]  >> 1;
> +		if (hidx & _PTEIDX_SECONDARY)
> +			hash =3D ~hash;
> +		slot =3D (hash & htab_hash_mask) * HPTES_PER_GROUP;
> +		slot +=3D hidx & _PTEIDX_GROUP_IX;
> +
> +		ret =3D ppc_md.hpte_updatepp(slot, rflags, vpn,
> +					   psize, ssize, local);
> +		/*
> +		 * We failed to update, try to insert a new entry.
> +		 */
> +		if (ret =3D=3D -1) {
> +			/*
> +			 * large pte is marked busy, so we can be sure
> +			 * nobody is looking at hpte_slot_array. hence we can
> +			 * safely update this here.
> +			 */
> +			hpte_slot_array[index] =3D 0;
> +			valid =3D 0;
> +		}
> +	}
> +
> +	if (likely(!valid)) {
> +		unsigned long hpte_group;
> +
> +		/* insert new entry */
> +		pa =3D pmd_pfn(__pmd(old_pmd)) << PAGE_SHIFT;
> +repeat:
> +		hpte_group =3D ((hash & htab_hash_mask) * HPTES_PER_GROUP) & ~0x7UL;
> +
> +		/* clear the busy bits and set the hash pte bits */
> +		new_pmd =3D (new_pmd & ~PMD_HUGE_HPTEFLAGS) | PMD_HUGE_HASHPTE;
> +
> +		/*
> +		 * WIMG bits.
> +		 * We always have _PAGE_COHERENT enabled for system RAM
> +		 */
> +		rflags |=3D _PAGE_COHERENT;
> +
> +		if (new_pmd & PMD_HUGE_SAO)
> +			rflags |=3D _PAGE_SAO;
> +
> +		/* Insert into the hash table, primary slot */
> +		slot =3D ppc_md.hpte_insert(hpte_group, vpn, pa, rflags, 0,
> +					  psize, lpsize, ssize);
> +		/*
> +		 * Primary is full, try the secondary
> +		 */
> +		if (unlikely(slot =3D=3D -1)) {
> +			hpte_group =3D ((~hash & htab_hash_mask) *
> +				      HPTES_PER_GROUP) & ~0x7UL;
> +			slot =3D ppc_md.hpte_insert(hpte_group, vpn, pa,
> +						  rflags, HPTE_V_SECONDARY,
> +						  psize, lpsize, ssize);
> +			if (slot =3D=3D -1) {
> +				if (mftb() & 0x1)
> +					hpte_group =3D ((hash & htab_hash_mask) *
> +						      HPTES_PER_GROUP) & ~0x7UL;
> +
> +				ppc_md.hpte_remove(hpte_group);
> +				goto repeat;
> +			}
> +		}
> +		/*
> +		 * Hypervisor failure. Restore old pmd and return -1
> +		 * similar to __hash_page_*
> +		 */
> +		if (unlikely(slot =3D=3D -2)) {
> +			*pmdp =3D __pmd(old_pmd);
> +			hash_failure_debug(ea, access, vsid, trap, ssize,
> +					   psize, lpsize, old_pmd);
> +			return -1;
> +		}
> +		/*
> +		 * large pte is marked busy, so we can be sure
> +		 * nobody is looking at hpte_slot_array. hence we can
> +		 * safely update this here.
> +		 */
> +		hpte_slot_array[index] =3D slot << 1 | 0x1;
> +	}
> +	/*
> +	 * No need to use ldarx/stdcx here
> +	 */
> +	*pmdp =3D __pmd(new_pmd & ~PMD_HUGE_BUSY);
> +	return 0;
> +}
> diff --git a/arch/powerpc/mm/hugetlbpage.c b/arch/powerpc/mm/hugetlbpage.c
> index 1a6de0a..7f11fa0 100644
> --- a/arch/powerpc/mm/hugetlbpage.c
> +++ b/arch/powerpc/mm/hugetlbpage.c
> @@ -67,7 +67,8 @@ static inline unsigned int mmu_psize_to_shift(unsigned =
int mmu_psize)
> =20
>  #define hugepd_none(hpd)	((hpd).pd =3D=3D 0)
> =20
> -pte_t *find_linux_pte_or_hugepte(pgd_t *pgdir, unsigned long ea, unsigne=
d *shift)
> +pte_t *find_linux_pte_or_hugepte(pgd_t *pgdir, unsigned long ea,
> +				 unsigned *shift, unsigned int *hugepage)
>  {
>  	pgd_t *pg;
>  	pud_t *pu;
> @@ -77,6 +78,8 @@ pte_t *find_linux_pte_or_hugepte(pgd_t *pgdir, unsigned=
 long ea, unsigned *shift
> =20
>  	if (shift)
>  		*shift =3D 0;
> +	if (hugepage)
> +		*hugepage =3D 0;
>  	pg =3D pgdir + pgd_index(ea);
>  	if (is_hugepd(pg)) {
> @@ -91,12 +94,24 @@ pte_t *find_linux_pte_or_hugepte(pgd_t *pgdir, unsign=
ed long ea, unsigned *shift
>  			pm =3D pmd_offset(pu, ea);
>  			if (is_hugepd(pm))
>  				hpdp =3D (hugepd_t *)pm;
> -			else if (!pmd_none(*pm)) {
> +			else if (pmd_large(*pm)) {
> +				/* THP page */
> +				if (hugepage) {
> +					*hugepage =3D 1;
> +					/*
> +					 * This should be ok, except for few
> +					 * flags. Most of the pte and hugepage
> +					 * pmd bits overlap. We don't use the
> +					 * returned value as pte_t in the caller.
> +					 */
> +					return (pte_t *)pm;
> +				} else
> +					return NULL;

Ah, so this is what prevents callers who don't supply the hugepage
parameter from being horribly broken.  Hrm.  Seems dangeously subtle
to me.

The parameter name is also really misleading since it's only for
transparent hugepages, not any hugepage.

> +			} else if (!pmd_none(*pm)) {
>  				return pte_offset_kernel(pm, ea);
>  			}
>  		}
>  	}
> -
>  	if (!hpdp)
>  		return NULL;
> =20
> @@ -108,7 +123,8 @@ EXPORT_SYMBOL_GPL(find_linux_pte_or_hugepte);
> =20
>  pte_t *huge_pte_offset(struct mm_struct *mm, unsigned long addr)
>  {
> -	return find_linux_pte_or_hugepte(mm->pgd, addr, NULL);
> +	/* Only called for HugeTLB pages, hence can ignore THP */
> +	return find_linux_pte_or_hugepte(mm->pgd, addr, NULL, NULL);
>  }
> =20
>  static int __hugepte_alloc(struct mm_struct *mm, hugepd_t *hpdp,
> @@ -613,8 +629,11 @@ follow_huge_addr(struct mm_struct *mm, unsigned long=
 address, int write)
>  	struct page *page;
>  	unsigned shift;
>  	unsigned long mask;
> -
> -	ptep =3D find_linux_pte_or_hugepte(mm->pgd, address, &shift);
> +	/*
> +	 * Transparent hugepages are handled by generic code. We can skip them
> +	 * here.
> +	 */
> +	ptep =3D find_linux_pte_or_hugepte(mm->pgd, address, &shift, NULL);
> =20
>  	/* Verify it is a huge page else bail. */
>  	if (!ptep || !shift)
> diff --git a/arch/powerpc/mm/pgtable.c b/arch/powerpc/mm/pgtable.c
> index cf3ca8e..fbff062 100644
> --- a/arch/powerpc/mm/pgtable.c
> +++ b/arch/powerpc/mm/pgtable.c
> @@ -557,3 +557,41 @@ void update_mmu_cache_pmd(struct vm_area_struct *vma=
, unsigned long addr,
>  }
> =20
>  #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
> +
> +/*
> + * find_linux_pte returns the address of a linux pte for a given
> + * effective address and directory.  If not found, it returns zero.
> + */
> +pte_t *find_linux_pte(pgd_t *pgdir, unsigned long ea, unsigned int *huge=
page)
> +{
> +	pgd_t *pg;
> +	pud_t *pu;
> +	pmd_t *pm;
> +	pte_t *pt =3D NULL;
> +
> +	if (hugepage)
> +		*hugepage =3D 0;
> +	pg =3D pgdir + pgd_index(ea);
> +	if (!pgd_none(*pg)) {
> +		pu =3D pud_offset(pg, ea);
> +		if (!pud_none(*pu)) {
> +			pm =3D pmd_offset(pu, ea);
> +			if (pmd_large(*pm)) {
> +				/* THP page */
> +				if (hugepage) {
> +					*hugepage =3D 1;
> +					/*
> +					 * This should be ok, except for few
> +					 * flags. Most of the pte and hugepage
> +					 * pmd bits overlap. We don't use the
> +					 * returned value as pte_t in the caller.
> +					 */
> +					return (pte_t *)pm;
> +				} else
> +					return NULL;
> +			} else if (pmd_present(*pm))
> +				pt =3D pte_offset_kernel(pm, ea);
> +		}
> +	}
> +	return pt;
> +}
> diff --git a/arch/powerpc/mm/tlb_hash64.c b/arch/powerpc/mm/tlb_hash64.c
> index 023ec8a..be0066f 100644
> --- a/arch/powerpc/mm/tlb_hash64.c
> +++ b/arch/powerpc/mm/tlb_hash64.c
> @@ -206,7 +206,10 @@ void __flush_hash_table_range(struct mm_struct *mm, =
unsigned long start,
>  	local_irq_save(flags);
>  	arch_enter_lazy_mmu_mode();
>  	for (; start < end; start +=3D PAGE_SIZE) {
> -		pte_t *ptep =3D find_linux_pte(mm->pgd, start);
> +		/*
> +		 * We won't find hugepages here.
> +		 */
> +		pte_t *ptep =3D find_linux_pte(mm->pgd, start, NULL);
>  		unsigned long pte;
> =20
>  		if (ptep =3D=3D NULL)
> diff --git a/arch/powerpc/perf/callchain.c b/arch/powerpc/perf/callchain.c
> index 74d1e78..578cac7 100644
> --- a/arch/powerpc/perf/callchain.c
> +++ b/arch/powerpc/perf/callchain.c
> @@ -125,7 +125,7 @@ static int read_user_stack_slow(void __user *ptr, voi=
d *ret, int nb)
>  	if (!pgdir)
>  		return -EFAULT;
> =20
> -	ptep =3D find_linux_pte_or_hugepte(pgdir, addr, &shift);
> +	ptep =3D find_linux_pte_or_hugepte(pgdir, addr, &shift, NULL);
>  	if (!shift)
>  		shift =3D PAGE_SHIFT;
> =20
> diff --git a/arch/powerpc/platforms/pseries/eeh.c b/arch/powerpc/platform=
s/pseries/eeh.c
> index 9a04322..44c931a 100644
> --- a/arch/powerpc/platforms/pseries/eeh.c
> +++ b/arch/powerpc/platforms/pseries/eeh.c
> @@ -261,7 +261,10 @@ static inline unsigned long eeh_token_to_phys(unsign=
ed long token)
>  	pte_t *ptep;
>  	unsigned long pa;
> =20
> -	ptep =3D find_linux_pte(init_mm.pgd, token);
> +	/*
> +	 * We won't find hugepages here
> +	 */
> +	ptep =3D find_linux_pte(init_mm.pgd, token, NULL);
>  	if (!ptep)
>  		return token;
>  	pa =3D pte_pfn(*ptep) << PAGE_SHIFT;

--=20
David Gibson			| I'll have my music baroque, and my code
david AT gibson.dropbear.id.au	| minimalist, thank you.  NOT _the_ _other_
				| _way_ _around_!
http://www.ozlabs.org/~dgibson

--KJY2Ze80yH5MUxol
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iEYEARECAAYFAlFnhxwACgkQaILKxv3ab8ZhxACgixmxYtpvuvHvjpP+KzKGl48L
DOUAnR1Lr1FXtf3RyO4PzWytRxUk1eNS
=82VY
-----END PGP SIGNATURE-----

--KJY2Ze80yH5MUxol--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
