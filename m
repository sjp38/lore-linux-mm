Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx194.postini.com [74.125.245.194])
	by kanga.kvack.org (Postfix) with SMTP id 706276B0155
	for <linux-mm@kvack.org>; Wed,  1 May 2013 01:40:58 -0400 (EDT)
Received: from /spool/local
	by e23smtp01.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dwg@au1.ibm.com>;
	Wed, 1 May 2013 15:33:26 +1000
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [9.190.235.152])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id C8D8E2CE8052
	for <linux-mm@kvack.org>; Wed,  1 May 2013 15:40:50 +1000 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r415QvYV24576050
	for <linux-mm@kvack.org>; Wed, 1 May 2013 15:26:58 +1000
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r415em7i029595
	for <linux-mm@kvack.org>; Wed, 1 May 2013 15:40:48 +1000
Date: Wed, 1 May 2013 15:26:25 +1000
From: David Gibson <dwg@au1.ibm.com>
Subject: Re: [PATCH -V7 18/18] powerpc: Update tlbie/tlbiel as per ISA doc
Message-ID: <20130501052625.GC14106@truffula.fritz.box>
References: <1367177859-7893-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <1367177859-7893-19-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <20130430061522.GC20202@truffula.fritz.box>
 <87ppxc9bpf.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="hOcCNbCCxyk/YU74"
Content-Disposition: inline
In-Reply-To: <87ppxc9bpf.fsf@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: paulus@samba.org, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org

--hOcCNbCCxyk/YU74
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Apr 30, 2013 at 10:51:00PM +0530, Aneesh Kumar K.V wrote:
> David Gibson <dwg@au1.ibm.com> writes:
>=20
> > On Mon, Apr 29, 2013 at 01:07:39AM +0530, Aneesh Kumar K.V wrote:
> >> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
> >>=20
> >> Encode the actual page correctly in tlbie/tlbiel. This make sure we ha=
ndle
> >> multiple page size segment correctly.
> >
> > As mentioned in previous comments, this commit message needs to give
> > much more detail about what precisely the existing implementation is
> > doing wrong.
> >
> >>=20
> >> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
> >> ---
> >>  arch/powerpc/mm/hash_native_64.c | 32 ++++++++++++++++++++++++++++++--
> >>  1 file changed, 30 insertions(+), 2 deletions(-)
> >>=20
> >> diff --git a/arch/powerpc/mm/hash_native_64.c b/arch/powerpc/mm/hash_n=
ative_64.c
> >> index bb920ee..6a2aead 100644
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
> >>  		asm volatile(ASM_FTR_IFCLR("tlbie %0,0", PPC_TLBIE(%1,%0), %2)
> >>  			     : : "r" (va), "r"(0), "i" (CPU_FTR_ARCH_206)
> >>  			     : "memory");
> >> @@ -69,9 +72,20 @@ static inline void __tlbie(unsigned long vpn, int p=
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
> >> +			 * We don't need all the bits, but rest of the bits
> >> +			 * must be ignored by the processor.
> >> +			 * vpn cover upto 65 bits of va. (0...65) and we need
> >> +			 * 58..64 bits of va.
> >
> > I can't understand what this comment is saying.  Why do we need to do
> > something different in the psize !=3D apsize case?
> >
> >> +			 */
> >> +			va |=3D (vpn & 0xfe);
> >> +		}
>=20
> That is as per ISA doc. It says if base page size =3D=3D actual page size,
> (RB)56:62 must be zeros, which must be ignored by the processor.
> Otherwise it should be filled with the selected bits of VA as explained a=
bove.

What you've just said here makes much more sense than what's written
in the comment in the code.

> We only support MPSS with base page size =3D 64K and actual page size =3D=
 16MB.

Is that actually relevant to this code though?

--=20
David Gibson			| I'll have my music baroque, and my code
david AT gibson.dropbear.id.au	| minimalist, thank you.  NOT _the_ _other_
				| _way_ _around_!
http://www.ozlabs.org/~dgibson

--hOcCNbCCxyk/YU74
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iEYEARECAAYFAlGAp4EACgkQaILKxv3ab8ZslwCgjTvv0EUf16dc7CLRCR2UHLpw
6q0An3Uv0gmEmSRe2wR1NqpNyGN2AZYp
=LWrC
-----END PGP SIGNATURE-----

--hOcCNbCCxyk/YU74--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
