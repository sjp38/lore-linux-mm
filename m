Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx142.postini.com [74.125.245.142])
	by kanga.kvack.org (Postfix) with SMTP id A210F6B0299
	for <linux-mm@kvack.org>; Sun,  5 May 2013 05:18:12 -0400 (EDT)
Received: from /spool/local
	by e23smtp04.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dwg@au1.ibm.com>;
	Sun, 5 May 2013 19:05:47 +1000
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [9.190.235.152])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id 0F6CB2BB0050
	for <linux-mm@kvack.org>; Sun,  5 May 2013 19:18:06 +1000 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r45948An23986332
	for <linux-mm@kvack.org>; Sun, 5 May 2013 19:04:09 +1000
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r459I4ug029943
	for <linux-mm@kvack.org>; Sun, 5 May 2013 19:18:04 +1000
Date: Sun, 5 May 2013 18:59:13 +1000
From: David Gibson <dwg@au1.ibm.com>
Subject: Re: [PATCH -V7 08/10] powerpc/THP: Enable THP on PPC64
Message-ID: <20130505085913.GZ13041@truffula.fritz.box>
References: <1367178711-8232-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <1367178711-8232-9-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <20130503051528.GT13041@truffula.fritz.box>
 <87r4hn5274.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="5cXpu7evJfjLw2dJ"
Content-Disposition: inline
In-Reply-To: <87r4hn5274.fsf@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: paulus@samba.org, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org

--5cXpu7evJfjLw2dJ
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sat, May 04, 2013 at 12:19:03AM +0530, Aneesh Kumar K.V wrote:
> David Gibson <dwg@au1.ibm.com> writes:
>=20
> > On Mon, Apr 29, 2013 at 01:21:49AM +0530, Aneesh Kumar K.V wrote:
> >> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
> >>=20
> >> We enable only if the we support 16MB page size.
> >>=20
> >> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
> >> ---
> >>  arch/powerpc/include/asm/pgtable-ppc64.h |  3 +--
> >>  arch/powerpc/mm/pgtable_64.c             | 28 +++++++++++++++++++++++=
+++++
> >>  2 files changed, 29 insertions(+), 2 deletions(-)
> >>=20
> >> diff --git a/arch/powerpc/include/asm/pgtable-ppc64.h b/arch/powerpc/i=
nclude/asm/pgtable-ppc64.h
> >> index 97fc839..d65534b 100644
> >> --- a/arch/powerpc/include/asm/pgtable-ppc64.h
> >> +++ b/arch/powerpc/include/asm/pgtable-ppc64.h
> >> @@ -426,8 +426,7 @@ static inline unsigned long pmd_pfn(pmd_t pmd)
> >>  	return pmd_val(pmd) >> PTE_RPN_SHIFT;
> >>  }
> >> =20
> >> -/* We will enable it in the last patch */
> >> -#define has_transparent_hugepage() 0
> >> +extern int has_transparent_hugepage(void);
> >>  #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
> >> =20
> >>  static inline int pmd_young(pmd_t pmd)
> >> diff --git a/arch/powerpc/mm/pgtable_64.c b/arch/powerpc/mm/pgtable_64=
=2Ec
> >> index 54216c1..b742d6f 100644
> >> --- a/arch/powerpc/mm/pgtable_64.c
> >> +++ b/arch/powerpc/mm/pgtable_64.c
> >> @@ -754,6 +754,34 @@ void update_mmu_cache_pmd(struct vm_area_struct *=
vma, unsigned long addr,
> >>  	return;
> >>  }
> >> =20
> >> +int has_transparent_hugepage(void)
> >> +{
> >> +	if (!mmu_has_feature(MMU_FTR_16M_PAGE))
> >> +		return 0;
> >> +	/*
> >> +	 * We support THP only if HPAGE_SHIFT is 16MB.
> >> +	 */
> >> +	if (!HPAGE_SHIFT || (HPAGE_SHIFT !=3D mmu_psize_defs[MMU_PAGE_16M].s=
hift))
> >> +		return 0;
> >
> > Again, THP should not be dependent on the value of HPAGE_SHIFT.  Just
> > checking that mmu_psize_defsz[MMU_PAGE_16M].shift =3D=3D 24 should be
> > sufficient (i.e. that 16M hugepages are supported).
>=20
> done
>=20
> +	/*
> +	 * We support THP only if PMD_SIZE is 16MB.
> +	 */
> +	if (mmu_psize_defs[MMU_PAGE_16M].shift !=3D PMD_SHIFT)
> +		return 0;
> +	/*

Much better.

> >> +	/*
> >> +	 * We need to make sure that we support 16MB hugepage in a segement
> >> +	 * with base page size 64K or 4K. We only enable THP with a PAGE_SIZE
> >> +	 * of 64K.
> >> +	 */
> >> +	/*
> >> +	 * If we have 64K HPTE, we will be using that by default
> >> +	 */
> >> +	if (mmu_psize_defs[MMU_PAGE_64K].shift &&
> >> +	    (mmu_psize_defs[MMU_PAGE_64K].penc[MMU_PAGE_16M] =3D=3D -1))
> >> +		return 0;
> >> +	/*
> >> +	 * Ok we only have 4K HPTE
> >> +	 */
> >> +	if (mmu_psize_defs[MMU_PAGE_4K].penc[MMU_PAGE_16M] =3D=3D -1)
> >> +		return 0;
> >
> > Except you don't actually support THP on 4K base page size yet.
>=20
>=20
> That is 64K linux page size and 4K HPTE . We do support that.

Good point, sorry.

--=20
David Gibson			| I'll have my music baroque, and my code
david AT gibson.dropbear.id.au	| minimalist, thank you.  NOT _the_ _other_
				| _way_ _around_!
http://www.ozlabs.org/~dgibson

--5cXpu7evJfjLw2dJ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iEYEARECAAYFAlGGH2EACgkQaILKxv3ab8bnigCeKFI1fhVuTHSpWYl0L0zhgY74
a3oAn26zV3cmsZVCffyAd7y4u+Le7z2s
=tqZ7
-----END PGP SIGNATURE-----

--5cXpu7evJfjLw2dJ--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
