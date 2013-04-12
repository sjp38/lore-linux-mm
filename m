Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx108.postini.com [74.125.245.108])
	by kanga.kvack.org (Postfix) with SMTP id 577D16B0039
	for <linux-mm@kvack.org>; Thu, 11 Apr 2013 21:41:38 -0400 (EDT)
Received: from /spool/local
	by e23smtp03.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dwg@au1.ibm.com>;
	Fri, 12 Apr 2013 11:34:11 +1000
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [9.190.234.120])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id 773932CE804C
	for <linux-mm@kvack.org>; Fri, 12 Apr 2013 11:41:32 +1000 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r3C1SC5F29491368
	for <linux-mm@kvack.org>; Fri, 12 Apr 2013 11:28:12 +1000
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r3C1fVeL029860
	for <linux-mm@kvack.org>; Fri, 12 Apr 2013 11:41:32 +1000
Date: Fri, 12 Apr 2013 11:28:51 +1000
From: David Gibson <dwg@au1.ibm.com>
Subject: Re: [PATCH -V5 19/25] powerpc/THP: Differentiate THP PMD entries
 from HUGETLB PMD entries
Message-ID: <20130412012851.GC5065@truffula.fritz.box>
References: <1365055083-31956-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <1365055083-31956-20-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="YD3LsXFS42OYHhNZ"
Content-Disposition: inline
In-Reply-To: <1365055083-31956-20-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: benh@kernel.crashing.org, paulus@samba.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org

--YD3LsXFS42OYHhNZ
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Apr 04, 2013 at 11:27:57AM +0530, Aneesh Kumar K.V wrote:
> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
>=20
> HUGETLB clear the top bit of PMD entries and use that to indicate
> a HUGETLB page directory. Since we store pfns in PMDs for THP,
> we would have the top bit cleared by default. Add the top bit mask
> for THP PMD entries and clear that when we are looking for pmd_pfn.
>=20
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
> ---
>  arch/powerpc/include/asm/pgtable.h |   16 +++++++++++++---
>  arch/powerpc/mm/pgtable.c          |    5 ++++-
>  arch/powerpc/mm/pgtable_64.c       |    2 +-
>  3 files changed, 18 insertions(+), 5 deletions(-)
>=20
> diff --git a/arch/powerpc/include/asm/pgtable.h b/arch/powerpc/include/as=
m/pgtable.h
> index 9fbe2a7..9681de4 100644
> --- a/arch/powerpc/include/asm/pgtable.h
> +++ b/arch/powerpc/include/asm/pgtable.h
> @@ -31,7 +31,7 @@ struct mm_struct;
>  #define PMD_HUGE_SPLITTING	0x008
>  #define PMD_HUGE_SAO		0x010 /* strong Access order */
>  #define PMD_HUGE_HASHPTE	0x020
> -#define PMD_ISHUGE		0x040
> +#define _PMD_ISHUGE		0x040
>  #define PMD_HUGE_DIRTY		0x080 /* C: page changed */
>  #define PMD_HUGE_ACCESSED	0x100 /* R: page referenced */
>  #define PMD_HUGE_RW		0x200 /* software: user write access allowed */
> @@ -44,6 +44,14 @@ struct mm_struct;
>  #define PMD_HUGE_RPN_SHIFT	PTE_RPN_SHIFT
>  #define HUGE_PAGE_SIZE		(ASM_CONST(1) << 24)
>  #define HUGE_PAGE_MASK		(~(HUGE_PAGE_SIZE - 1))
> +/*
> + * HugeTLB looks at the top bit of the Linux page table entries to
> + * decide whether it is a huge page directory or not. Mark HUGE
> + * PMD to differentiate
> + */
> +#define PMD_HUGE_NOT_HUGETLB	(ASM_CONST(1) << 63)
> +#define PMD_ISHUGE		(_PMD_ISHUGE | PMD_HUGE_NOT_HUGETLB)

Having a define which looks like the name of a boolean flag, but is
two bits strikes me as a really bad idea.

This is one of the many confusions that comes with different pagetable
encodings for transparent and non-transparent hugepages.

Hrm.  So your original patch was horribly broken in that your hugepage
PMDs didn't have the top bit set, and so would be confused with hugepd
pointers.  Now you're patching it up by forcing the top bit to 1 for
hugepage PMDs.  Confusing way of going about it.

> +#define PMD_HUGE_PROTBITS	(0xfff | PMD_HUGE_NOT_HUGETLB)
> =20
>  #ifndef __ASSEMBLY__
>  extern void hpte_need_hugepage_flush(struct mm_struct *mm, unsigned long=
 addr,
> @@ -70,8 +78,9 @@ static inline int pmd_trans_splitting(pmd_t pmd)
> =20
>  static inline int pmd_trans_huge(pmd_t pmd)
>  {
> -	return pmd_val(pmd) & PMD_ISHUGE;
> +	return ((pmd_val(pmd) & PMD_ISHUGE) =3D=3D  PMD_ISHUGE);



>  }
> +
>  /* We will enable it in the last patch */
>  #define has_transparent_hugepage() 0
>  #else
> @@ -84,7 +93,8 @@ static inline unsigned long pmd_pfn(pmd_t pmd)
>  	/*
>  	 * Only called for hugepage pmd
>  	 */
> -	return pmd_val(pmd) >> PMD_HUGE_RPN_SHIFT;
> +	unsigned long val =3D pmd_val(pmd) & ~PMD_HUGE_PROTBITS;
> +	return val  >> PMD_HUGE_RPN_SHIFT;
>  }
> =20
>  static inline int pmd_young(pmd_t pmd)
> diff --git a/arch/powerpc/mm/pgtable.c b/arch/powerpc/mm/pgtable.c
> index 9f33780..cf3ca8e 100644
> --- a/arch/powerpc/mm/pgtable.c
> +++ b/arch/powerpc/mm/pgtable.c
> @@ -517,7 +517,10 @@ static pmd_t pmd_set_protbits(pmd_t pmd, pgprot_t pg=
prot)
>  pmd_t pfn_pmd(unsigned long pfn, pgprot_t pgprot)
>  {
>  	pmd_t pmd;
> -
> +	/*
> +	 * We cannot support that many PFNs
> +	 */
> +	VM_BUG_ON(pfn & PMD_HUGE_NOT_HUGETLB);
>  	pmd_val(pmd) =3D pfn << PMD_HUGE_RPN_SHIFT;
>  	pmd_val(pmd) |=3D PMD_ISHUGE;
>  	pmd =3D pmd_set_protbits(pmd, pgprot);
> diff --git a/arch/powerpc/mm/pgtable_64.c b/arch/powerpc/mm/pgtable_64.c
> index 6fc3488..cd53020 100644
> --- a/arch/powerpc/mm/pgtable_64.c
> +++ b/arch/powerpc/mm/pgtable_64.c
> @@ -345,7 +345,7 @@ EXPORT_SYMBOL(__iounmap_at);
>  struct page *pmd_page(pmd_t pmd)
>  {
>  #ifdef CONFIG_TRANSPARENT_HUGEPAGE
> -	if (pmd_val(pmd) & PMD_ISHUGE)
> +	if ((pmd_val(pmd) & PMD_ISHUGE) =3D=3D PMD_ISHUGE)
>  		return pfn_to_page(pmd_pfn(pmd));
>  #endif
>  	return virt_to_page(pmd_page_vaddr(pmd));

--=20
David Gibson			| I'll have my music baroque, and my code
david AT gibson.dropbear.id.au	| minimalist, thank you.  NOT _the_ _other_
				| _way_ _around_!
http://www.ozlabs.org/~dgibson

--YD3LsXFS42OYHhNZ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iEYEARECAAYFAlFnY1MACgkQaILKxv3ab8ZY6QCfbK3gGDifFEiVLZd03RkQy0tc
MRoAn3JkCFGeRal/Wf0GrVLBvE7kR10K
=mK+2
-----END PGP SIGNATURE-----

--YD3LsXFS42OYHhNZ--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
