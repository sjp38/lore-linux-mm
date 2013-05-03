Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id 55DA96B02AF
	for <linux-mm@kvack.org>; Fri,  3 May 2013 01:30:39 -0400 (EDT)
Received: from /spool/local
	by e23smtp03.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dwg@au1.ibm.com>;
	Fri, 3 May 2013 15:22:37 +1000
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [9.190.234.120])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id 2FEAB2BB0056
	for <linux-mm@kvack.org>; Fri,  3 May 2013 15:30:35 +1000 (EST)
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r435GmCm21823652
	for <linux-mm@kvack.org>; Fri, 3 May 2013 15:16:49 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r435UXe5020837
	for <linux-mm@kvack.org>; Fri, 3 May 2013 15:30:33 +1000
Date: Fri, 3 May 2013 14:56:24 +1000
From: David Gibson <dwg@au1.ibm.com>
Subject: Re: [PATCH -V7 05/10] powerpc: Replace find_linux_pte with
 find_linux_pte_or_hugepte
Message-ID: <20130503045624.GQ13041@truffula.fritz.box>
References: <1367178711-8232-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <1367178711-8232-6-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="DzFMwNuU1QL7hgxO"
Content-Disposition: inline
In-Reply-To: <1367178711-8232-6-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: benh@kernel.crashing.org, paulus@samba.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org

--DzFMwNuU1QL7hgxO
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Apr 29, 2013 at 01:21:46AM +0530, Aneesh Kumar K.V wrote:
> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
>=20
> Replace find_linux_pte with find_linux_pte_or_hugepte and explicitly
> document why we don't need to handle transparent hugepages at callsites.
>=20
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
> ---
>  arch/powerpc/include/asm/pgtable-ppc64.h | 24 ------------------------
>  arch/powerpc/kernel/io-workarounds.c     | 10 ++++++++--
>  arch/powerpc/kvm/book3s_hv_rm_mmu.c      |  2 +-
>  arch/powerpc/mm/hash_utils_64.c          |  8 +++++++-
>  arch/powerpc/mm/hugetlbpage.c            |  8 ++++++--
>  arch/powerpc/mm/tlb_hash64.c             |  7 ++++++-
>  arch/powerpc/platforms/pseries/eeh.c     |  7 ++++++-
>  7 files changed, 34 insertions(+), 32 deletions(-)
>=20
> diff --git a/arch/powerpc/include/asm/pgtable-ppc64.h b/arch/powerpc/incl=
ude/asm/pgtable-ppc64.h
> index f0effab..97fc839 100644
> --- a/arch/powerpc/include/asm/pgtable-ppc64.h
> +++ b/arch/powerpc/include/asm/pgtable-ppc64.h
> @@ -343,30 +343,6 @@ static inline void __ptep_set_access_flags(pte_t *pt=
ep, pte_t entry)
> =20
>  void pgtable_cache_add(unsigned shift, void (*ctor)(void *));
>  void pgtable_cache_init(void);
> -
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
>  pte_t *find_linux_pte_or_hugepte(pgd_t *pgdir, unsigned long ea,
>  				 unsigned *shift);
>  #endif /* __ASSEMBLY__ */
> diff --git a/arch/powerpc/kernel/io-workarounds.c b/arch/powerpc/kernel/i=
o-workarounds.c
> index 50e90b7..e5263ab 100644
> --- a/arch/powerpc/kernel/io-workarounds.c
> +++ b/arch/powerpc/kernel/io-workarounds.c
> @@ -55,6 +55,7 @@ static struct iowa_bus *iowa_pci_find(unsigned long vad=
dr, unsigned long paddr)
> =20
>  struct iowa_bus *iowa_mem_find_bus(const PCI_IO_ADDR addr)
>  {
> +	unsigned shift;
>  	struct iowa_bus *bus;
>  	int token;
> =20
> @@ -70,11 +71,16 @@ struct iowa_bus *iowa_mem_find_bus(const PCI_IO_ADDR =
addr)
>  		if (vaddr < PHB_IO_BASE || vaddr >=3D PHB_IO_END)
>  			return NULL;
> =20
> -		ptep =3D find_linux_pte(init_mm.pgd, vaddr);
> +		ptep =3D find_linux_pte_or_hugepte(init_mm.pgd, vaddr, &shift);
>  		if (ptep =3D=3D NULL)
>  			paddr =3D 0;
> -		else
> +		else {
> +			/*
> +			 * we don't have hugepages backing iomem
> +			 */
> +			BUG_ON(shift);
>  			paddr =3D pte_pfn(*ptep) << PAGE_SHIFT;
> +		}
>  		bus =3D iowa_pci_find(vaddr, paddr);
> =20
>  		if (bus =3D=3D NULL)
> diff --git a/arch/powerpc/kvm/book3s_hv_rm_mmu.c b/arch/powerpc/kvm/book3=
s_hv_rm_mmu.c
> index 19c93ba..8c345df 100644
> --- a/arch/powerpc/kvm/book3s_hv_rm_mmu.c
> +++ b/arch/powerpc/kvm/book3s_hv_rm_mmu.c
> @@ -27,7 +27,7 @@ static void *real_vmalloc_addr(void *x)
>  	unsigned long addr =3D (unsigned long) x;
>  	pte_t *p;
> =20
> -	p =3D find_linux_pte(swapper_pg_dir, addr);
> +	p =3D find_linux_pte_or_hugepte(swapper_pg_dir, addr, NULL);
>  	if (!p || !pte_present(*p))
>  		return NULL;
>  	/* assume we don't have huge pages in vmalloc space... */
> diff --git a/arch/powerpc/mm/hash_utils_64.c b/arch/powerpc/mm/hash_utils=
_64.c
> index d0eb6d4..e942ae9 100644
> --- a/arch/powerpc/mm/hash_utils_64.c
> +++ b/arch/powerpc/mm/hash_utils_64.c
> @@ -1131,6 +1131,7 @@ EXPORT_SYMBOL_GPL(hash_page);
>  void hash_preload(struct mm_struct *mm, unsigned long ea,
>  		  unsigned long access, unsigned long trap)
>  {
> +	int shift;
>  	unsigned long vsid;
>  	pgd_t *pgdir;
>  	pte_t *ptep;
> @@ -1152,10 +1153,15 @@ void hash_preload(struct mm_struct *mm, unsigned =
long ea,
>  	pgdir =3D mm->pgd;
>  	if (pgdir =3D=3D NULL)
>  		return;
> -	ptep =3D find_linux_pte(pgdir, ea);
> +	/*
> +	 * THP pages use update_mmu_cache_pmd. We don't do
> +	 * hash preload there. Hence can ignore THP here
> +	 */
> +	ptep =3D find_linux_pte_or_hugepte(pgdir, ea, &shift);
>  	if (!ptep)
>  		return;
> =20
> +	BUG_ON(shift);
>  #ifdef CONFIG_PPC_64K_PAGES
>  	/* If either _PAGE_4K_PFN or _PAGE_NO_CACHE is set (and we are on
>  	 * a 64K kernel), then we don't preload, hash_page() will take
> diff --git a/arch/powerpc/mm/hugetlbpage.c b/arch/powerpc/mm/hugetlbpage.c
> index 081c001..1154714 100644
> --- a/arch/powerpc/mm/hugetlbpage.c
> +++ b/arch/powerpc/mm/hugetlbpage.c
> @@ -105,6 +105,7 @@ int pgd_huge(pgd_t pgd)
> =20
>  pte_t *huge_pte_offset(struct mm_struct *mm, unsigned long addr)
>  {
> +	/* Only called for HugeTLB pages, hence can ignore THP */
>  	return find_linux_pte_or_hugepte(mm->pgd, addr, NULL);
>  }
> =20
> @@ -673,11 +674,14 @@ follow_huge_addr(struct mm_struct *mm, unsigned lon=
g address, int write)
>  	struct page *page;
>  	unsigned shift;
>  	unsigned long mask;
> -
> +	/*
> +	 * Transparent hugepages are handled by generic code. We can skip them
> +	 * here.
> +	 */
>  	ptep =3D find_linux_pte_or_hugepte(mm->pgd, address, &shift);
> =20
>  	/* Verify it is a huge page else bail. */
> -	if (!ptep || !shift)
> +	if (!ptep || !shift || pmd_trans_huge((pmd_t)*ptep))
>  		return ERR_PTR(-EINVAL);
> =20
>  	mask =3D (1UL << shift) - 1;
> diff --git a/arch/powerpc/mm/tlb_hash64.c b/arch/powerpc/mm/tlb_hash64.c
> index 023ec8a..56d9b85 100644
> --- a/arch/powerpc/mm/tlb_hash64.c
> +++ b/arch/powerpc/mm/tlb_hash64.c
> @@ -189,6 +189,7 @@ void tlb_flush(struct mmu_gather *tlb)
>  void __flush_hash_table_range(struct mm_struct *mm, unsigned long start,
>  			      unsigned long end)
>  {
> +	int shift;
>  	unsigned long flags;
> =20
>  	start =3D _ALIGN_DOWN(start, PAGE_SIZE);
> @@ -206,11 +207,15 @@ void __flush_hash_table_range(struct mm_struct *mm,=
 unsigned long start,
>  	local_irq_save(flags);
>  	arch_enter_lazy_mmu_mode();
>  	for (; start < end; start +=3D PAGE_SIZE) {
> -		pte_t *ptep =3D find_linux_pte(mm->pgd, start);
> +		pte_t *ptep =3D find_linux_pte_or_hugepte(mm->pgd, start, &shift);
>  		unsigned long pte;
> =20
>  		if (ptep =3D=3D NULL)
>  			continue;
> +		/*
> +		 * We won't find hugepages here, this is iomem.
> +		 */

Really?  Why?

> +		BUG_ON(shift);
>  		pte =3D pte_val(*ptep);
>  		if (!(pte & _PAGE_HASHPTE))
>  			continue;
> diff --git a/arch/powerpc/platforms/pseries/eeh.c b/arch/powerpc/platform=
s/pseries/eeh.c
> index 6b73d6c..d2e76d2 100644
> --- a/arch/powerpc/platforms/pseries/eeh.c
> +++ b/arch/powerpc/platforms/pseries/eeh.c
> @@ -258,12 +258,17 @@ void eeh_slot_error_detail(struct eeh_pe *pe, int s=
everity)
>   */
>  static inline unsigned long eeh_token_to_phys(unsigned long token)
>  {
> +	int shift;
>  	pte_t *ptep;
>  	unsigned long pa;
> =20
> -	ptep =3D find_linux_pte(init_mm.pgd, token);
> +	/*
> +	 * We won't find hugepages here, iomem
> +	 */
> +	ptep =3D find_linux_pte_or_hugepte(init_mm.pgd, token, &shift);
>  	if (!ptep)
>  		return token;
> +	BUG_ON(shift);
>  	pa =3D pte_pfn(*ptep) << PAGE_SHIFT;
> =20
>  	return pa | (token & (PAGE_SIZE-1));

--=20
David Gibson			| I'll have my music baroque, and my code
david AT gibson.dropbear.id.au	| minimalist, thank you.  NOT _the_ _other_
				| _way_ _around_!
http://www.ozlabs.org/~dgibson

--DzFMwNuU1QL7hgxO
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iEYEARECAAYFAlGDQ3gACgkQaILKxv3ab8aO4ACeNj3eoQmtbPR5+ya8PEMV94cU
wB0An2IR7xzNKcjGF9GmOvu4EAQp28J1
=O0hv
-----END PGP SIGNATURE-----

--DzFMwNuU1QL7hgxO--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
