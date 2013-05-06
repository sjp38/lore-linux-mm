Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id 5051A6B0122
	for <linux-mm@kvack.org>; Sun,  5 May 2013 21:46:21 -0400 (EDT)
Received: from /spool/local
	by e23smtp07.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dwg@au1.ibm.com>;
	Mon, 6 May 2013 11:36:24 +1000
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [9.190.235.21])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id 6A5CD2CE8051
	for <linux-mm@kvack.org>; Mon,  6 May 2013 11:46:11 +1000 (EST)
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r461k1bT12124228
	for <linux-mm@kvack.org>; Mon, 6 May 2013 11:46:04 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r461k8Uw016365
	for <linux-mm@kvack.org>; Mon, 6 May 2013 11:46:08 +1000
Date: Mon, 6 May 2013 11:28:16 +1000
From: David Gibson <dwg@au1.ibm.com>
Subject: Re: [PATCH -V7 02/10] powerpc/THP: Implement transparent hugepages
 for ppc64
Message-ID: <20130506012816.GB13041@truffula.fritz.box>
References: <1367178711-8232-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <1367178711-8232-3-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <20130503045201.GO13041@truffula.fritz.box>
 <87a9oa4kx0.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="uLm21ivgZj9Xvi41"
Content-Disposition: inline
In-Reply-To: <87a9oa4kx0.fsf@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: paulus@samba.org, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org

--uLm21ivgZj9Xvi41
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sun, May 05, 2013 at 12:44:35AM +0530, Aneesh Kumar K.V wrote:
> David Gibson <dwg@au1.ibm.com> writes:
> > On Mon, Apr 29, 2013 at 01:21:43AM +0530, Aneesh Kumar K.V wrote:
> >> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
[snip]
> >> diff --git a/arch/powerpc/include/asm/pgtable-ppc64.h b/arch/powerpc/i=
nclude/asm/pgtable-ppc64.h
> >> index ab84332..20133c1 100644
> >> --- a/arch/powerpc/include/asm/pgtable-ppc64.h
> >> +++ b/arch/powerpc/include/asm/pgtable-ppc64.h
> >> @@ -154,7 +154,7 @@
> >>  #define	pmd_present(pmd)	(pmd_val(pmd) !=3D 0)
> >>  #define	pmd_clear(pmdp)		(pmd_val(*(pmdp)) =3D 0)
> >>  #define pmd_page_vaddr(pmd)	(pmd_val(pmd) & ~PMD_MASKED_BITS)
> >> -#define pmd_page(pmd)		virt_to_page(pmd_page_vaddr(pmd))
> >> +extern struct page *pmd_page(pmd_t pmd);
> >> =20
> >>  #define pud_set(pudp, pudval)	(pud_val(*(pudp)) =3D (pudval))
> >>  #define pud_none(pud)		(!pud_val(pud))
> >> @@ -382,4 +382,261 @@ static inline pte_t *find_linux_pte_or_hugepte(p=
gd_t *pgdir, unsigned long ea,
> >> =20
> >>  #endif /* __ASSEMBLY__ */
> >> =20
> >> +#ifndef _PAGE_SPLITTING
> >> +/*
> >> + * THP pages can't be special. So use the _PAGE_SPECIAL
> >> + */
> >> +#define _PAGE_SPLITTING _PAGE_SPECIAL
> >> +#endif
> >> +
> >> +#ifndef _PAGE_THP_HUGE
> >> +/*
> >> + * We need to differentiate between explicit huge page and THP huge
> >> + * page, since THP huge page also need to track real subpage details
> >> + * We use the _PAGE_COMBO bits here as dummy for platform that doesn't
> >> + * support THP.
> >> + */
> >> +#define _PAGE_THP_HUGE  0x10000000
> >
> > So if it's _PAGE_COMBO, use _PAGE_COMBO, instead of the actual number.
>=20
> We define _PAGE_THP_HUGE value in pte-hash64-64k.h. Now the functions
> below which depends on _PAGE_THP_HUGE are in pgtable-ppc64.h. The above
> #define takes care of compile errors on subarch that doesn't include
> pte-hash64-64k.h We really won't be using these functions at run time,
> because we will not find a transparent huge page on those subarchs.

Nonetheless, duplicated definitions really won't do.

[snip]
> >> +#endif
> >> +
> >> +#define HUGE_PAGE_SIZE		(ASM_CONST(1) << 24)
> >> +#define HUGE_PAGE_MASK		(~(HUGE_PAGE_SIZE - 1))
> >
> > These constants should be named so its clear they're THP specific.
> > They should also be defined in terms of PMD_SHIFT, instead of
> > directly.
>=20
> I was not able to use HPAGE_PMD_SIZE because we have that BUILD_BUG_ON
> when THP is not enabled. I will switch them to PMD_SIZE and PMD_MASK ?

That would be ok.  THP_PAGE_SIZE or something would also be fine.

[snip]
> >> +static inline unsigned long pmd_pfn(pmd_t pmd)
> >> +{
> >> +	/*
> >> +	 * Only called for hugepage pmd
> >> +	 */
> >> +	return pmd_val(pmd) >> PTE_RPN_SHIFT;
> >> +}
> >> +
> >> +/* We will enable it in the last patch */
> >> +#define has_transparent_hugepage() 0
> >> +#endif /* CONFIG_TRANSPARENT_HUGEPAGE */
> >> +
> >> +static inline int pmd_young(pmd_t pmd)
> >> +{
> >> +	return pmd_val(pmd) & _PAGE_ACCESSED;
> >> +}
> >
> > It would be clearer to define this function as well as various others
> > that operate on PMDs as PTEs to just cast the parameter and call the
> > corresponding pte_XXX(),
>=20
> I did what tile arch is done. How about=20
>=20
> +#define pmd_pte(pmd)		(pmd)
> +#define pte_pmd(pte)		(pte)
> +#define pmd_pfn(pmd)		pte_pfn(pmd_pte(pmd))
> +#define pmd_young(pmd)		pte_young(pmd_pte(pmd))
> +#define pmd_mkold(pmd)		pte_pmd(pte_mkold(pmd_pte(pmd)))
> +#define pmd_wrprotect(pmd)	pte_pmd(pte_wrprotect(pmd_pte(pmd)))
> +#define pmd_mkdirty(pmd)	pte_pmd(pte_mkdirty(pmd_pte(pmd)))
> +#define pmd_mkyoung(pmd)	pte_pmd(pte_mkyoung(pmd_pte(pmd)))
> +#define pmd_mkwrite(pmd)	pte_pmd(pte_mkwrite(pmd_pte(pmd)))

Probably better for pmd_pte() and pte_pmd() to be inlines, so you
preserve type checking (at least with STRICT_MM_TYPECHECKS), but
otherwise looks ok.

[snip]
> >> +/*
> >> + * We want to put the pgtable in pmd and use pgtable for tracking
> >> + * the base page size hptes
> >> + */
> >> +void pgtable_trans_huge_deposit(struct mm_struct *mm, pmd_t *pmdp,
> >> +				pgtable_t pgtable)
> >> +{
> >> +	unsigned long *pgtable_slot;
> >> +	assert_spin_locked(&mm->page_table_lock);
> >> +	/*
> >> +	 * we store the pgtable in the second half of PMD
> >> +	 */
> >> +	pgtable_slot =3D pmdp + PTRS_PER_PMD;
> >> +	*pgtable_slot =3D (unsigned long)pgtable;
> >
> > Why not just make pgtable_slot have type (pgtable_t *) and avoid the
> > case.
> >
>=20
> done. But we would have cast in the above line.=20

Sure.  But in fact the above line would need a cast anyway, if you
turned on STRICT_MM_TYPECHECKS.

--=20
David Gibson			| I'll have my music baroque, and my code
david AT gibson.dropbear.id.au	| minimalist, thank you.  NOT _the_ _other_
				| _way_ _around_!
http://www.ozlabs.org/~dgibson

--uLm21ivgZj9Xvi41
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iEYEARECAAYFAlGHBzAACgkQaILKxv3ab8ZtTwCePZ9zFXaBff4eCaXyySBS1HpN
yoYAn0YneY4bR5mD+rtbQ+3HCWJxI3m/
=c0DG
-----END PGP SIGNATURE-----

--uLm21ivgZj9Xvi41--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
