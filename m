Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id A9B336B0005
	for <linux-mm@kvack.org>; Thu, 11 Apr 2013 03:11:24 -0400 (EDT)
Received: from /spool/local
	by e23smtp09.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dwg@au1.ibm.com>;
	Thu, 11 Apr 2013 17:02:33 +1000
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [9.190.235.152])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id 554EF3578051
	for <linux-mm@kvack.org>; Thu, 11 Apr 2013 17:11:18 +1000 (EST)
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r3B6vJ4R62455822
	for <linux-mm@kvack.org>; Thu, 11 Apr 2013 16:57:20 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r3B7Ak64000841
	for <linux-mm@kvack.org>; Thu, 11 Apr 2013 17:10:46 +1000
Date: Thu, 11 Apr 2013 17:10:43 +1000
From: David Gibson <dwg@au1.ibm.com>
Subject: Re: [PATCH -V5 04/25] powerpc: Reduce the PTE_INDEX_SIZE
Message-ID: <20130411071043.GJ8165@truffula.fritz.box>
References: <1365055083-31956-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <1365055083-31956-5-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="ljn2+zwPkKedfiv/"
Content-Disposition: inline
In-Reply-To: <1365055083-31956-5-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: benh@kernel.crashing.org, paulus@samba.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org

--ljn2+zwPkKedfiv/
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Apr 04, 2013 at 11:27:42AM +0530, Aneesh Kumar K.V wrote:
> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
>=20
> This make one PMD cover 16MB range. That helps in easier implementation o=
f THP
> on power. THP core code make use of one pmd entry to track the hugepage a=
nd
> the range mapped by a single pmd entry should be equal to the hugepage si=
ze
> supported by the hardware.
>=20
> Acked-by: Paul Mackerras <paulus@samba.org>
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
> ---
>  arch/powerpc/include/asm/pgtable-ppc64-64k.h |    4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
>=20
> diff --git a/arch/powerpc/include/asm/pgtable-ppc64-64k.h b/arch/powerpc/=
include/asm/pgtable-ppc64-64k.h
> index be4e287..3c529b4 100644
> --- a/arch/powerpc/include/asm/pgtable-ppc64-64k.h
> +++ b/arch/powerpc/include/asm/pgtable-ppc64-64k.h
> @@ -4,10 +4,10 @@
>  #include <asm-generic/pgtable-nopud.h>
> =20
> =20
> -#define PTE_INDEX_SIZE  12
> +#define PTE_INDEX_SIZE  8
>  #define PMD_INDEX_SIZE  12
>  #define PUD_INDEX_SIZE	0
> -#define PGD_INDEX_SIZE  6
> +#define PGD_INDEX_SIZE  10
> =20
>  #ifndef __ASSEMBLY__
>  #define PTE_TABLE_SIZE	(sizeof(real_pte_t) << PTE_INDEX_SIZE)

Actually, I've realised there's a much more serious problem here.
This patch as is will break existing hugpage support.  With the
previous numbers we had pagetable levels covering 256M and 1TB.  That
meant that at whichever level we split off a hugepd, it would line up
with the slice/segment boundaries.  Now it won't, and that means that
(explicitly) mapping hugepages and normal pages with correctly
constructed alignments will lead to the normal page fault paths
attempting to walk down hugepds or vice versa which will cause
crashes.

In fact.. with the new boundaries, we will attempt to put explicit 16M
hugepages in a hugepd of 4096 entries covering a total of 64G.  Which
means any attempt to use explicit hugepages in a 32-bit process will
blow up horribly.

The obvious solution is to make explicit hugepages also use your new
hugepage encoding, as a PMD entry pointing directly to the page data.
That's also a good idea, to avoid yet more variants on the pagetable
encoding.  But this conversion of the explicit hugepage code really
needs to be done before attempting to implement THP.

--=20
David Gibson			| I'll have my music baroque, and my code
david AT gibson.dropbear.id.au	| minimalist, thank you.  NOT _the_ _other_
				| _way_ _around_!
http://www.ozlabs.org/~dgibson

--ljn2+zwPkKedfiv/
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iEYEARECAAYFAlFmYfMACgkQaILKxv3ab8YdiACdEs26LCa1d2eMGCE5HZDMI++0
UccAnjd4r2ll2/eTd7WwQjnxnf1PtJNx
=98PO
-----END PGP SIGNATURE-----

--ljn2+zwPkKedfiv/--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
