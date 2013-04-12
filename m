Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id 229EF6B003B
	for <linux-mm@kvack.org>; Thu, 11 Apr 2013 21:42:08 -0400 (EDT)
Received: from /spool/local
	by e23smtp07.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dwg@au1.ibm.com>;
	Fri, 12 Apr 2013 11:33:03 +1000
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [9.190.235.152])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id 9192B3578057
	for <linux-mm@kvack.org>; Fri, 12 Apr 2013 11:42:02 +1000 (EST)
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r3C1S3nv5570790
	for <linux-mm@kvack.org>; Fri, 12 Apr 2013 11:28:03 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r3C1fWEp014460
	for <linux-mm@kvack.org>; Fri, 12 Apr 2013 11:41:32 +1000
Date: Fri, 12 Apr 2013 11:34:49 +1000
From: David Gibson <dwg@au1.ibm.com>
Subject: Re: [PATCH -V5 21/25] powerpc: Handle hugepage in perf callchain
Message-ID: <20130412013449.GD5065@truffula.fritz.box>
References: <1365055083-31956-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <1365055083-31956-22-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="Xm/fll+QQv+hsKip"
Content-Disposition: inline
In-Reply-To: <1365055083-31956-22-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: benh@kernel.crashing.org, paulus@samba.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org

--Xm/fll+QQv+hsKip
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Apr 04, 2013 at 11:27:59AM +0530, Aneesh Kumar K.V wrote:
> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
>=20
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
> ---
>  arch/powerpc/perf/callchain.c |   32 +++++++++++++++++++++-----------
>  1 file changed, 21 insertions(+), 11 deletions(-)
>=20
> diff --git a/arch/powerpc/perf/callchain.c b/arch/powerpc/perf/callchain.c
> index 578cac7..99262ce 100644
> --- a/arch/powerpc/perf/callchain.c
> +++ b/arch/powerpc/perf/callchain.c
> @@ -115,7 +115,7 @@ static int read_user_stack_slow(void __user *ptr, voi=
d *ret, int nb)
>  {
>  	pgd_t *pgdir;
>  	pte_t *ptep, pte;
> -	unsigned shift;
> +	unsigned shift, hugepage;
>  	unsigned long addr =3D (unsigned long) ptr;
>  	unsigned long offset;
>  	unsigned long pfn;
> @@ -125,20 +125,30 @@ static int read_user_stack_slow(void __user *ptr, v=
oid *ret, int nb)
>  	if (!pgdir)
>  		return -EFAULT;
> =20
> -	ptep =3D find_linux_pte_or_hugepte(pgdir, addr, &shift, NULL);
> +	ptep =3D find_linux_pte_or_hugepte(pgdir, addr, &shift, &hugepage);

So, this patch pretty much demonstrates that your earlier patch adding
the optional hugepage argument and making the existing callers pass
NULL was broken.

Any code which calls this function and doesn't use and handle the
hugepage return value is horribly broken, so permitting the hugepage
parameter to be optional is itself broken.

I think instead you need to have an early patch that replaces
find_linux_pte_or_hugepte with a new, more abstracted interface, so
that code using it will remain correct when hugepage PMDs become
possible.

>  	if (!shift)
>  		shift =3D PAGE_SHIFT;
> =20
> -	/* align address to page boundary */
> -	offset =3D addr & ((1UL << shift) - 1);
> -	addr -=3D offset;
> -
> -	if (ptep =3D=3D NULL)
> -		return -EFAULT;
> -	pte =3D *ptep;
> -	if (!pte_present(pte) || !(pte_val(pte) & _PAGE_USER))
> +	if (!ptep)
>  		return -EFAULT;
> -	pfn =3D pte_pfn(pte);
> +
> +	if (hugepage) {
> +		pmd_t pmd =3D *(pmd_t *)ptep;
> +		shift =3D mmu_psize_defs[MMU_PAGE_16M].shift;
> +		offset =3D addr & ((1UL << shift) - 1);
> +
> +		if (!pmd_large(pmd) || !(pmd_val(pmd) & PMD_HUGE_USER))
> +			return -EFAULT;
> +		pfn =3D pmd_pfn(pmd);
> +	} else {
> +		offset =3D addr & ((1UL << shift) - 1);
> +
> +		pte =3D *ptep;
> +		if (!pte_present(pte) || !(pte_val(pte) & _PAGE_USER))
> +			return -EFAULT;
> +		pfn =3D pte_pfn(pte);
> +	}
> +
>  	if (!page_is_ram(pfn))
>  		return -EFAULT;
> =20

--=20
David Gibson			| I'll have my music baroque, and my code
david AT gibson.dropbear.id.au	| minimalist, thank you.  NOT _the_ _other_
				| _way_ _around_!
http://www.ozlabs.org/~dgibson

--Xm/fll+QQv+hsKip
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iEYEARECAAYFAlFnZLkACgkQaILKxv3ab8abqgCfdGprCjTIMD80/hgwnlly1cDm
7tcAn1mHgSnU7gUDibcsloSk8MTqtbze
=MG90
-----END PGP SIGNATURE-----

--Xm/fll+QQv+hsKip--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
