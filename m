Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id 4D8196B003D
	for <linux-mm@kvack.org>; Thu, 11 Apr 2013 21:42:08 -0400 (EDT)
Received: from /spool/local
	by e23smtp08.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dwg@au1.ibm.com>;
	Fri, 12 Apr 2013 11:39:54 +1000
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [9.190.235.21])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id 748173578054
	for <linux-mm@kvack.org>; Fri, 12 Apr 2013 11:42:02 +1000 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r3C1fQuM4129176
	for <linux-mm@kvack.org>; Fri, 12 Apr 2013 11:41:27 +1000
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r3C1fVj9029867
	for <linux-mm@kvack.org>; Fri, 12 Apr 2013 11:41:32 +1000
Date: Fri, 12 Apr 2013 11:41:40 +1000
From: David Gibson <dwg@au1.ibm.com>
Subject: Re: [PATCH -V5 22/25] powerpc/THP: get_user_pages_fast changes
Message-ID: <20130412014140.GE5065@truffula.fritz.box>
References: <1365055083-31956-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <1365055083-31956-23-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="mR8QP4gmHujQHb1c"
Content-Disposition: inline
In-Reply-To: <1365055083-31956-23-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: benh@kernel.crashing.org, paulus@samba.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org

--mR8QP4gmHujQHb1c
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Apr 04, 2013 at 11:28:00AM +0530, Aneesh Kumar K.V wrote:
> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
>=20
> handle large pages for get_user_pages_fast. Also take care of large page =
splitting.
>=20
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
> ---
>  arch/powerpc/mm/gup.c |   84 +++++++++++++++++++++++++++++++++++++++++++=
++++--
>  1 file changed, 82 insertions(+), 2 deletions(-)
>=20
> diff --git a/arch/powerpc/mm/gup.c b/arch/powerpc/mm/gup.c
> index d7efdbf..835c1ae 100644
> --- a/arch/powerpc/mm/gup.c
> +++ b/arch/powerpc/mm/gup.c
> @@ -55,6 +55,72 @@ static noinline int gup_pte_range(pmd_t pmd, unsigned =
long addr,
>  	return 1;
>  }
> =20
> +#ifdef CONFIG_TRANSPARENT_HUGEPAGE
> +static inline int gup_huge_pmd(pmd_t *pmdp, unsigned long addr,
> +			       unsigned long end, int write,
> +			       struct page **pages, int *nr)
> +{
> +	int refs;
> +	pmd_t pmd;
> +	unsigned long mask;
> +	struct page *head, *page, *tail;
> +
> +	pmd =3D *pmdp;
> +	mask =3D PMD_HUGE_PRESENT | PMD_HUGE_USER;
> +	if (write)
> +		mask |=3D PMD_HUGE_RW;
> +
> +	if ((pmd_val(pmd) & mask) !=3D mask)
> +		return 0;
> +
> +	/* large pages are never "special" */
> +	VM_BUG_ON(!pfn_valid(pmd_pfn(pmd)));
> +
> +	refs =3D 0;
> +	head =3D pmd_page(pmd);
> +	page =3D head + ((addr & ~PMD_MASK) >> PAGE_SHIFT);
> +	tail =3D page;
> +	do {
> +		VM_BUG_ON(compound_head(page) !=3D head);
> +		pages[*nr] =3D page;
> +		(*nr)++;
> +		page++;
> +		refs++;
> +	} while (addr +=3D PAGE_SIZE, addr !=3D end);
> +
> +	if (!page_cache_add_speculative(head, refs)) {
> +		*nr -=3D refs;
> +		return 0;
> +	}
> +
> +	if (unlikely(pmd_val(pmd) !=3D pmd_val(*pmdp))) {
> +		*nr -=3D refs;
> +		while (refs--)
> +			put_page(head);
> +		return 0;
> +	}
> +	/*
> +	 * Any tail page need their mapcount reference taken before we
> +	 * return.
> +	 */
> +	while (refs--) {
> +		if (PageTail(tail))
> +			get_huge_page_tail(tail);
> +		tail++;

Is it safe to do this accounting this late?

> +	}
> +
> +	return 1;
> +}
> +#else
> +
> +static inline int gup_huge_pmd(pmd_t *pmdp, unsigned long addr,
> +			       unsigned long end, int write,
> +			       struct page **pages, int *nr)
> +{
> +	return 1;

Should be a BUG() here, since this should never be called if
!CONFIG_TRANSPARENT_HUGEPAGE.

> +}
> +#endif
> +
>  static int gup_pmd_range(pud_t pud, unsigned long addr, unsigned long en=
d,
>  		int write, struct page **pages, int *nr)
>  {
> @@ -66,9 +132,23 @@ static int gup_pmd_range(pud_t pud, unsigned long add=
r, unsigned long end,
>  		pmd_t pmd =3D *pmdp;
> =20
>  		next =3D pmd_addr_end(addr, end);
> -		if (pmd_none(pmd))
> +		/*
> +		 * The pmd_trans_splitting() check below explains why
> +		 * pmdp_splitting_flush has to flush the tlb, to stop
> +		 * this gup-fast code from running while we set the
> +		 * splitting bit in the pmd. Returning zero will take
> +		 * the slow path that will call wait_split_huge_page()
> +		 * if the pmd is still in splitting state. gup-fast
> +		 * can't because it has irq disabled and
> +		 * wait_split_huge_page() would never return as the
> +		 * tlb flush IPI wouldn't run.
> +		 */
> +		if (pmd_none(pmd) || pmd_trans_splitting(pmd))
>  			return 0;
> -		if (is_hugepd(pmdp)) {
> +		if (unlikely(pmd_large(pmd))) {
> +			if (!gup_huge_pmd(pmdp, addr, next, write, pages, nr))
> +				return 0;
> +		} else if (is_hugepd(pmdp)) {
>  			if (!gup_hugepd((hugepd_t *)pmdp, PMD_SHIFT,
>  					addr, next, write, pages, nr))
>  				return 0;

--=20
David Gibson			| I'll have my music baroque, and my code
david AT gibson.dropbear.id.au	| minimalist, thank you.  NOT _the_ _other_
				| _way_ _around_!
http://www.ozlabs.org/~dgibson

--mR8QP4gmHujQHb1c
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iEYEARECAAYFAlFnZlQACgkQaILKxv3ab8YKpQCaA4QUnA7KB1J7hV2r0uDxy3Uq
Qo0An3BFum+f9Lnj3RfQ8XpK0fd21iQz
=0DHn
-----END PGP SIGNATURE-----

--mR8QP4gmHujQHb1c--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
