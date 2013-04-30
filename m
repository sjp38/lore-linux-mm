Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id 8548D6B00B1
	for <linux-mm@kvack.org>; Tue, 30 Apr 2013 01:01:11 -0400 (EDT)
Received: from /spool/local
	by e23smtp01.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dwg@au1.ibm.com>;
	Tue, 30 Apr 2013 14:53:41 +1000
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [9.190.235.152])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id 46EA72CE804A
	for <linux-mm@kvack.org>; Tue, 30 Apr 2013 15:01:04 +1000 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r3U4lDgl15794178
	for <linux-mm@kvack.org>; Tue, 30 Apr 2013 14:47:13 +1000
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r3U513t1027329
	for <linux-mm@kvack.org>; Tue, 30 Apr 2013 15:01:03 +1000
Date: Tue, 30 Apr 2013 15:01:01 +1000
From: David Gibson <dwg@au1.ibm.com>
Subject: Re: [PATCH -V7 01/18] mm/THP: HPAGE_SHIFT is not a #define on some
 arch
Message-ID: <20130430050101.GY20202@truffula.fritz.box>
References: <1367177859-7893-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <1367177859-7893-2-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <20130430022149.GU20202@truffula.fritz.box>
 <871u9sfzvy.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="huLXOlJ1ghGp/P5+"
Content-Disposition: inline
In-Reply-To: <871u9sfzvy.fsf@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: paulus@samba.org, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org

--huLXOlJ1ghGp/P5+
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Apr 30, 2013 at 09:12:09AM +0530, Aneesh Kumar K.V wrote:
> David Gibson <dwg@au1.ibm.com> writes:
>=20
> > On Mon, Apr 29, 2013 at 01:07:22AM +0530, Aneesh Kumar K.V wrote:
> >> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
> >>=20
> >> On archs like powerpc that support different hugepage sizes, HPAGE_SHI=
FT
> >> and other derived values like HPAGE_PMD_ORDER are not constants. So mo=
ve
> >> that to hugepage_init
> >
> > These seems to miss the point.  Those variables may be defined in
> > terms of HPAGE_SHIFT right now, but that is of itself kind of broken.
> > The transparent hugepage mechanism only works if the hugepage size is
> > equal to the PMD size - and PMD_SHIFT remains a compile time constant.
> >
> > There's no reason having transparent hugepage should force the PMD
> > size of hugepage to be the default for other purposes - it should be
> > possible to do THP as long as PMD-sized is a possible hugepage size.
> >
>=20
> THP code does
>=20
> #define HPAGE_PMD_SHIFT HPAGE_SHIFT
> #define HPAGE_PMD_MASK HPAGE_MASK
> #define HPAGE_PMD_SIZE HPAGE_SIZE
>=20
> I had two options, one to move all those in terms of PMD_SHIFT

This is a much better option that you've taken now, and really
shouldn't be that hard.  The THP code is much more strongly tied to
the fact that it is a PMD than the fact that it's the same size as
explicit huge pages.

> or switch
> ppc64 to not use HPAGE_SHIFT the way it use now. Both would involve large
> code changes. Hence I end up moving some of the checks to runtime
> checks. Actual HPAGE_SHIFT =3D=3D PMD_SHIFT check happens in the has_tran=
sparent_hugepage()=20
>=20
> https://lists.ozlabs.org/pipermail/linuxppc-dev/2013-April/106002.html

And my other point is that this is also wrong.  All you should need to
check is that HPAGE_PMD_SHIFT (=3D=3D PMD_SHIFT) is a supported hugepage
size, not that it is equal to HPAGE_SHIFT the default explicit
hugepage size.

> IMHO what the patch is checking is that, HPAGE_SHIFT
> value is not resulting in a page order higher than MAX_ORDER.=20

Which you don't actually care about in THP - you only care that
HPAGE_PMD_SHIFT doesn't exceed MAX_ORDER.

> Related to Reviewed-by: that came from V5 patchset=20
> https://lists.ozlabs.org/pipermail/linuxppc-dev/2013-April/105299.html
>=20
> Your review suggestion to move that runtime check back to macro happened
> in V6. I missed dropping reviewed-by after that.=20

Ok.

--=20
David Gibson			| I'll have my music baroque, and my code
david AT gibson.dropbear.id.au	| minimalist, thank you.  NOT _the_ _other_
				| _way_ _around_!
http://www.ozlabs.org/~dgibson

--huLXOlJ1ghGp/P5+
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iEYEARECAAYFAlF/UA0ACgkQaILKxv3ab8YxFQCeNDpny3+gOInRujTTJeYeJRKD
TpMAn0n99ARS/CrXHW0f7y6bG21QzS5u
=qfnj
-----END PGP SIGNATURE-----

--huLXOlJ1ghGp/P5+--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
