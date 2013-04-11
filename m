Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id 77D3E6B0005
	for <linux-mm@kvack.org>; Thu, 11 Apr 2013 02:16:44 -0400 (EDT)
Received: from /spool/local
	by e23smtp09.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dwg@au1.ibm.com>;
	Thu, 11 Apr 2013 16:07:53 +1000
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [9.190.235.152])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id DE1072BB0023
	for <linux-mm@kvack.org>; Thu, 11 Apr 2013 16:16:37 +1000 (EST)
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r3B638r743384858
	for <linux-mm@kvack.org>; Thu, 11 Apr 2013 16:03:09 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r3B6GaeL026081
	for <linux-mm@kvack.org>; Thu, 11 Apr 2013 16:16:36 +1000
Date: Thu, 11 Apr 2013 16:16:30 +1000
From: David Gibson <dwg@au1.ibm.com>
Subject: Re: [PATCH -V5 13/25] powerpc: Update tlbie/tlbiel as per ISA doc
Message-ID: <20130411061630.GG8165@truffula.fritz.box>
References: <1365055083-31956-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <1365055083-31956-14-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <20130411033010.GV8165@truffula.fritz.box>
 <871uahod83.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="LNKrWK8T5LDJo+fl"
Content-Disposition: inline
In-Reply-To: <871uahod83.fsf@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: paulus@samba.org, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org

--LNKrWK8T5LDJo+fl
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Apr 11, 2013 at 10:50:12AM +0530, Aneesh Kumar K.V wrote:
> David Gibson <dwg@au1.ibm.com> writes:
>=20
> > On Thu, Apr 04, 2013 at 11:27:51AM +0530, Aneesh Kumar K.V wrote:
> >> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
> >>=20
> >> This make sure we handle multiple page size segment correctly.
> >
> > This needs a much more detailed message.  In what way was the existing
> > code not matching the ISA documentation?  What consequences did that
> > have?
>=20
> Mostly to make sure we use the right penc values in tlbie. I did test
> these changes on PowerNV.=20

A vague description like this is not adequate.  Your commit message
needs to explain what was wrong with the existing behaviour.

> >> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
> >> ---
> >>  arch/powerpc/mm/hash_native_64.c |   30 ++++++++++++++++++++++++++++--
> >>  1 file changed, 28 insertions(+), 2 deletions(-)
> >>=20
> >> diff --git a/arch/powerpc/mm/hash_native_64.c b/arch/powerpc/mm/hash_n=
ative_64.c
> >> index b461b2d..ac84fa6 100644
> >> --- a/arch/powerpc/mm/hash_native_64.c
> >> +++ b/arch/powerpc/mm/hash_native_64.c
> >> @@ -61,7 +61,10 @@ static inline void __tlbie(unsigned long vpn, int p=
size, int apsize, int ssize)
> >> =20
> >>  	switch (psize) {
> >>  	case MMU_PAGE_4K:
> >> +		/* clear out bits after (52) [0....52.....63] */
> >> +		va &=3D ~((1ul << (64 - 52)) - 1);
> >>  		va |=3D ssize << 8;
> >> +		va |=3D mmu_psize_defs[apsize].sllp << 6;
> >
> > sllp is the per-segment encoding, so it sure must be looked up via
> > psize, not apsize.
>=20
> as per ISA doc, for base page size 4K, RB[56:58] must be set to
> SLB[L|LP] encoded for the page size corresponding to the actual page
> size specified by the PTE that was used to create the the TLB entry to
> be invalidated.

Ok, I see.  Wow, our architecture is even more convoluted than I
thought.  This could really do with a comment, because this is a very
surprising aspect of the architecture.

> >
> >>  		asm volatile(ASM_FTR_IFCLR("tlbie %0,0", PPC_TLBIE(%1,%0), %2)
> >>  			     : : "r" (va), "r"(0), "i" (CPU_FTR_ARCH_206)
> >>  			     : "memory");
> >> @@ -69,9 +72,19 @@ static inline void __tlbie(unsigned long vpn, int p=
size, int apsize, int ssize)
> >>  	default:
> >>  		/* We need 14 to 14 + i bits of va */
> >>  		penc =3D mmu_psize_defs[psize].penc[apsize];
> >> -		va &=3D ~((1ul << mmu_psize_defs[psize].shift) - 1);
> >> +		va &=3D ~((1ul << mmu_psize_defs[apsize].shift) - 1);
> >>  		va |=3D penc << 12;
> >>  		va |=3D ssize << 8;
> >> +		/* Add AVAL part */
> >> +		if (psize !=3D apsize) {
> >> +			/*
> >> +			 * MPSS, 64K base page size and 16MB parge page size
> >> +			 * We don't need all the bits, but this seems to work.
> >> +			 * vpn cover upto 65 bits of va. (0...65) and we need
> >> +			 * 58..64 bits of va.
> >
> > "seems to work" is not a comment I like to see in core MMU code...
> >
>=20
> As per ISA spec, the "other bits" in RB[56:62] must be ignored by the
> processor. Hence I didn't bother to do zero it out. Since we only
> support one MPSS combination, we could easily zero out using 0xf0.=20

Then update the comment to clearly explain why what you're doing is
correct, not just say it "seems to work".

--=20
David Gibson			| I'll have my music baroque, and my code
david AT gibson.dropbear.id.au	| minimalist, thank you.  NOT _the_ _other_
				| _way_ _around_!
http://www.ozlabs.org/~dgibson

--LNKrWK8T5LDJo+fl
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iEYEARECAAYFAlFmVT4ACgkQaILKxv3ab8bCgQCePr0dAuSz3COrfRtIRRtIaSOL
S04AmgMpAe1ealt9mJBf/Q3dZADnRPii
=TxMv
-----END PGP SIGNATURE-----

--LNKrWK8T5LDJo+fl--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
