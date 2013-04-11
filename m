Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id 0B4C76B0027
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 21:52:34 -0400 (EDT)
Received: from /spool/local
	by e23smtp07.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dwg@au1.ibm.com>;
	Thu, 11 Apr 2013 11:43:27 +1000
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [9.190.235.152])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id A0C6B2BB0057
	for <linux-mm@kvack.org>; Thu, 11 Apr 2013 11:52:25 +1000 (EST)
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r3B1cuGQ35389498
	for <linux-mm@kvack.org>; Thu, 11 Apr 2013 11:38:57 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r3B1qNlZ029848
	for <linux-mm@kvack.org>; Thu, 11 Apr 2013 11:52:23 +1000
Date: Thu, 11 Apr 2013 11:28:08 +1000
From: David Gibson <dwg@au1.ibm.com>
Subject: Re: [PATCH -V5 08/25] powerpc: Decode the pte-lp-encoding bits
 correctly.
Message-ID: <20130411012808.GM8165@truffula.fritz.box>
References: <1365055083-31956-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <1365055083-31956-9-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <20130410071915.GI8165@truffula.fritz.box>
 <87li8qolej.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="N/GrjenRD+RJfyz+"
Content-Disposition: inline
In-Reply-To: <87li8qolej.fsf@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: paulus@samba.org, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org

--N/GrjenRD+RJfyz+
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Apr 10, 2013 at 01:41:16PM +0530, Aneesh Kumar K.V wrote:
> David Gibson <dwg@au1.ibm.com> writes:
>=20
> > On Thu, Apr 04, 2013 at 11:27:46AM +0530, Aneesh Kumar K.V wrote:
> >> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
> >>=20
> >> We look at both the segment base page size and actual page size and st=
ore
> >> the pte-lp-encodings in an array per base page size.
> >>=20
> >> We also update all relevant functions to take actual page size argument
> >> so that we can use the correct PTE LP encoding in HPTE. This should al=
so
> >> get the basic Multiple Page Size per Segment (MPSS) support. This is n=
eeded
> >> to enable THP on ppc64.
> >>=20
>=20
> ....
>=20
> >> +static inline int hpte_actual_psize(struct hash_pte *hptep, int psize)
> >> +{
> >> +	int i, shift;
> >> +	unsigned int mask;
> >> +	/* Look at the 8 bit LP value */
> >> +	unsigned int lp =3D (hptep->r >> LP_SHIFT) & ((1 << LP_BITS) - 1);
> >> +
> >> +	if (!(hptep->v & HPTE_V_VALID))
> >> +		return -1;
> >
> > Folding the validity check into the size check seems confusing to me.
>=20
> We do end up with invalid hpte with which we call
> hpte_actual_psize. So that check is needed. I can either move to caller,
> but then i will have to replicate it in all the call sites.
>=20
>=20
> >> +	/* First check if it is large page */
> >> +	if (!(hptep->v & HPTE_V_LARGE))
> >> +		return MMU_PAGE_4K;
> >> +
> >> +	/* start from 1 ignoring MMU_PAGE_4K */
> >> +	for (i =3D 1; i < MMU_PAGE_COUNT; i++) {
> >> +		/* valid entries have a shift value */
> >> +		if (!mmu_psize_defs[i].shift)
> >> +			continue;
> >
> > Isn't this check redundant with the one below?
>=20
> Yes. I guess we can safely assume that if penc is valid then we do
> support that specific large page.
>=20
> I will drop this and keep the penc check. That is more correct check
>=20
> >> +		/* invalid penc */
> >> +		if (mmu_psize_defs[psize].penc[i] =3D=3D -1)
> >> +			continue;
> >> +		/*
> >> +		 * encoding bits per actual page size
> >> +		 *        PTE LP     actual page size
> >> +		 *    rrrr rrrz		>=3D8KB
> >> +		 *    rrrr rrzz		>=3D16KB
> >> +		 *    rrrr rzzz		>=3D32KB
> >> +		 *    rrrr zzzz		>=3D64KB
> >> +		 * .......
> >> +		 */
> >> +		shift =3D mmu_psize_defs[i].shift - LP_SHIFT;
> >> +		if (shift > LP_BITS)
> >> +			shift =3D LP_BITS;
> >> +		mask =3D (1 << shift) - 1;
> >> +		if ((lp & mask) =3D=3D mmu_psize_defs[psize].penc[i])
> >> +			return i;
> >> +	}
> >
> > Shouldn't we have a BUG() or something here.  If we get here we've
> > somehow created a PTE with LP bits we can't interpret, yes?
>=20
> I don't know. Is BUG() the right thing to do ?=20

Well, it's a situation that should never occur, and it's not clear
what we can do to fix it if it does, so, yeah, I think BUG() is appropriate.

> >> +	return -1;
> >> +}
> >> +
> >>  static long native_hpte_updatepp(unsigned long slot, unsigned long ne=
wpp,
> >>  				 unsigned long vpn, int psize, int ssize,
> >>  				 int local)
> >> @@ -251,6 +294,7 @@ static long native_hpte_updatepp(unsigned long slo=
t, unsigned long newpp,
> >>  	struct hash_pte *hptep =3D htab_address + slot;
> >>  	unsigned long hpte_v, want_v;
> >>  	int ret =3D 0;
> >> +	int actual_psize;
> >> =20
> >>  	want_v =3D hpte_encode_avpn(vpn, psize, ssize);
> >> =20
> >> @@ -260,9 +304,13 @@ static long native_hpte_updatepp(unsigned long sl=
ot, unsigned long newpp,
> >>  	native_lock_hpte(hptep);
> >> =20
> >>  	hpte_v =3D hptep->v;
> >> -
> >> +	actual_psize =3D hpte_actual_psize(hptep, psize);
> >> +	if (actual_psize < 0) {
> >> +		native_unlock_hpte(hptep);
> >> +		return -1;
> >> +	}
> >
> > Wouldn't it make more sense to only do the psize lookup once you've
> > found a matching hpte?
>=20
> But we need to do psize lookup even if V_COMPARE fail, because we want
> to do tlbie in both the case.

Ah, yes.  Sorry, misunderstood what this code was doing.

[snip]
> >> @@ -388,19 +444,26 @@ static void hpte_decode(struct hash_pte *hpte, u=
nsigned long slot,
> >>  		penc =3D LP_MASK(i+1) >> LP_SHIFT;
> >>  		for (size =3D 0; size < MMU_PAGE_COUNT; size++) {
> >
> >> =20
> >> -			/* 4K pages are not represented by LP */
> >> -			if (size =3D=3D MMU_PAGE_4K)
> >> -				continue;
> >> -
> >>  			/* valid entries have a shift value */
> >>  			if (!mmu_psize_defs[size].shift)
> >>  				continue;
> >> +			for (a_size =3D 0; a_size < MMU_PAGE_COUNT; a_size++) {
> >
> > Can't you resize hpte_actual_psize() here instead of recoding the
> > lookup?
>=20
> I thought about that, but re-coding avoided some repeated check. But
> then, if I follow your review comments of avoiding hpte valid check etc, =
may
> be I can reuse the hpte_actual_psize. Will try this.=20

hpte_decode() is only used in the kexec() path so some repeated simple
tests don't really matter.

--=20
David Gibson			| I'll have my music baroque, and my code
david AT gibson.dropbear.id.au	| minimalist, thank you.  NOT _the_ _other_
				| _way_ _around_!
http://www.ozlabs.org/~dgibson

--N/GrjenRD+RJfyz+
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iEYEARECAAYFAlFmEagACgkQaILKxv3ab8bQegCeNVB695ZY4PcgCYeheBcxOTA4
GjEAn306yQs13Ssvau/ZACNVJs3UsUFf
=QTTx
-----END PGP SIGNATURE-----

--N/GrjenRD+RJfyz+--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
