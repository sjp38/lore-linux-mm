Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id 4626D6B00B7
	for <linux-mm@kvack.org>; Tue, 30 Apr 2013 02:16:34 -0400 (EDT)
Received: from /spool/local
	by e23smtp02.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dwg@au1.ibm.com>;
	Tue, 30 Apr 2013 16:08:28 +1000
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [9.190.234.120])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id 4C92A2CE8051
	for <linux-mm@kvack.org>; Tue, 30 Apr 2013 16:16:28 +1000 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r3U62j1o20971542
	for <linux-mm@kvack.org>; Tue, 30 Apr 2013 16:02:46 +1000
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r3U6GQv9017256
	for <linux-mm@kvack.org>; Tue, 30 Apr 2013 16:16:27 +1000
Date: Tue, 30 Apr 2013 16:15:22 +1000
From: David Gibson <dwg@au1.ibm.com>
Subject: Re: [PATCH -V7 18/18] powerpc: Update tlbie/tlbiel as per ISA doc
Message-ID: <20130430061522.GC20202@truffula.fritz.box>
References: <1367177859-7893-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <1367177859-7893-19-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="vN1VrOpIkjMGbM/7"
Content-Disposition: inline
In-Reply-To: <1367177859-7893-19-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: benh@kernel.crashing.org, paulus@samba.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org

--vN1VrOpIkjMGbM/7
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Apr 29, 2013 at 01:07:39AM +0530, Aneesh Kumar K.V wrote:
> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
>=20
> Encode the actual page correctly in tlbie/tlbiel. This make sure we handle
> multiple page size segment correctly.

As mentioned in previous comments, this commit message needs to give
much more detail about what precisely the existing implementation is
doing wrong.

>=20
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
> ---
>  arch/powerpc/mm/hash_native_64.c | 32 ++++++++++++++++++++++++++++++--
>  1 file changed, 30 insertions(+), 2 deletions(-)
>=20
> diff --git a/arch/powerpc/mm/hash_native_64.c b/arch/powerpc/mm/hash_nati=
ve_64.c
> index bb920ee..6a2aead 100644
> --- a/arch/powerpc/mm/hash_native_64.c
> +++ b/arch/powerpc/mm/hash_native_64.c
> @@ -61,7 +61,10 @@ static inline void __tlbie(unsigned long vpn, int psiz=
e, int apsize, int ssize)
> =20
>  	switch (psize) {
>  	case MMU_PAGE_4K:
> +		/* clear out bits after (52) [0....52.....63] */
> +		va &=3D ~((1ul << (64 - 52)) - 1);
>  		va |=3D ssize << 8;
> +		va |=3D mmu_psize_defs[apsize].sllp << 6;
>  		asm volatile(ASM_FTR_IFCLR("tlbie %0,0", PPC_TLBIE(%1,%0), %2)
>  			     : : "r" (va), "r"(0), "i" (CPU_FTR_ARCH_206)
>  			     : "memory");
> @@ -69,9 +72,20 @@ static inline void __tlbie(unsigned long vpn, int psiz=
e, int apsize, int ssize)
>  	default:
>  		/* We need 14 to 14 + i bits of va */
>  		penc =3D mmu_psize_defs[psize].penc[apsize];
> -		va &=3D ~((1ul << mmu_psize_defs[psize].shift) - 1);
> +		va &=3D ~((1ul << mmu_psize_defs[apsize].shift) - 1);
>  		va |=3D penc << 12;
>  		va |=3D ssize << 8;
> +		/* Add AVAL part */
> +		if (psize !=3D apsize) {
> +			/*
> +			 * MPSS, 64K base page size and 16MB parge page size
> +			 * We don't need all the bits, but rest of the bits
> +			 * must be ignored by the processor.
> +			 * vpn cover upto 65 bits of va. (0...65) and we need
> +			 * 58..64 bits of va.

I can't understand what this comment is saying.  Why do we need to do
something different in the psize !=3D apsize case?

> +			 */
> +			va |=3D (vpn & 0xfe);
> +		}
>  		va |=3D 1; /* L */
>  		asm volatile(ASM_FTR_IFCLR("tlbie %0,1", PPC_TLBIE(%1,%0), %2)
>  			     : : "r" (va), "r"(0), "i" (CPU_FTR_ARCH_206)
> @@ -96,16 +110,30 @@ static inline void __tlbiel(unsigned long vpn, int p=
size, int apsize, int ssize)
> =20
>  	switch (psize) {
>  	case MMU_PAGE_4K:
> +		/* clear out bits after(52) [0....52.....63] */
> +		va &=3D ~((1ul << (64 - 52)) - 1);
>  		va |=3D ssize << 8;
> +		va |=3D mmu_psize_defs[apsize].sllp << 6;
>  		asm volatile(".long 0x7c000224 | (%0 << 11) | (0 << 21)"
>  			     : : "r"(va) : "memory");
>  		break;
>  	default:
>  		/* We need 14 to 14 + i bits of va */
>  		penc =3D mmu_psize_defs[psize].penc[apsize];
> -		va &=3D ~((1ul << mmu_psize_defs[psize].shift) - 1);
> +		va &=3D ~((1ul << mmu_psize_defs[apsize].shift) - 1);
>  		va |=3D penc << 12;
>  		va |=3D ssize << 8;
> +		/* Add AVAL part */
> +		if (psize !=3D apsize) {
> +			/*
> +			 * MPSS, 64K base page size and 16MB parge page size
> +			 * We don't need all the bits, but rest of the bits
> +			 * must be ignored by the processor.
> +			 * vpn cover upto 65 bits of va. (0...65) and we need
> +			 * 58..64 bits of va.
> +			 */
> +			va |=3D (vpn & 0xfe);
> +		}
>  		va |=3D 1; /* L */
>  		asm volatile(".long 0x7c000224 | (%0 << 11) | (1 << 21)"
>  			     : : "r"(va) : "memory");

--=20
David Gibson			| I'll have my music baroque, and my code
david AT gibson.dropbear.id.au	| minimalist, thank you.  NOT _the_ _other_
				| _way_ _around_!
http://www.ozlabs.org/~dgibson

--vN1VrOpIkjMGbM/7
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iEYEARECAAYFAlF/YXoACgkQaILKxv3ab8ZJBwCdEhSx8pePCwBfJyX5afCvNilM
W/4AnikztbPsMnVYWf8vhKoSgT18VCYn
=synR
-----END PGP SIGNATURE-----

--vN1VrOpIkjMGbM/7--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
