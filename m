Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id 6D62A6B0072
	for <linux-mm@kvack.org>; Thu, 25 Oct 2012 16:49:09 -0400 (EDT)
Date: Thu, 25 Oct 2012 23:49:59 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCH v4 10/10] thp: implement refcounting for huge zero page
Message-ID: <20121025204959.GA27251@otc-wbsnb-06>
References: <20121018164502.b32791e7.akpm@linux-foundation.org>
 <20121018235941.GA32397@shutemov.name>
 <20121023063532.GA15870@shutemov.name>
 <20121022234349.27f33f62.akpm@linux-foundation.org>
 <20121023070018.GA18381@otc-wbsnb-06>
 <20121023155915.7d5ef9d1.akpm@linux-foundation.org>
 <20121023233801.GA21591@shutemov.name>
 <20121024122253.5ecea992.akpm@linux-foundation.org>
 <20121024194552.GA24460@otc-wbsnb-06>
 <20121024132552.5f9a5f5b.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="C7zPtVaVf+AK4Oqc"
Content-Disposition: inline
In-Reply-To: <20121024132552.5f9a5f5b.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, "H. Peter Anvin" <hpa@linux.intel.com>, linux-kernel@vger.kernel.org


--C7zPtVaVf+AK4Oqc
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Oct 24, 2012 at 01:25:52PM -0700, Andrew Morton wrote:
> On Wed, 24 Oct 2012 22:45:52 +0300
> "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> wrote:
>=20
> > On Wed, Oct 24, 2012 at 12:22:53PM -0700, Andrew Morton wrote:
> > >=20
> > > I'm thinking that such a workload would be the above dd in parallel
> > > with a small app which touches the huge page and then exits, then gets
> > > executed again.  That "small app" sounds realistic to me.  Obviously
> > > one could exercise the zero page's refcount at higher frequency with a
> > > tight map/touch/unmap loop, but that sounds less realistic.  It's wor=
th
> > > trying that exercise as well though.
> > >=20
> > > Or do something else.  But we should try to probe this code's
> > > worst-case behaviour, get an understanding of its effects and then
> > > decide whether any such workload is realisic enough to worry about.
> >=20
> > Okay, I'll try few memory pressure scenarios.

A test program:

        while (1) {
                posix_memalign((void **)&p, 2 * MB, 2 * MB);
                assert(*p =3D=3D 0);
                free(p);
        }

With this code in background we have pretty good chance to have huge zero
page freeable (refcount =3D=3D 1) when shrinker callback called - roughly o=
ne
of two.

Pagecache hog (dd if=3Dhugefile of=3D/dev/null bs=3D1M) creates enough pres=
sure
to get shrinker callback called, but it was only asked about cache size
(nr_to_scan =3D=3D 0).
I was not able to get it called with nr_to_scan > 0 on this scenario, so
hzp never freed.

I also tried another scenario: usemem -n16 100M -r 1000. It creates real
memory pressure - no easy reclaimable memory. This time callback called
with nr_to_scan > 0 and we freed hzp. Under pressure we fails to allocate
hzp and code goes to fallback path as it supposed to.

Do I need to check any other scenario?

--=20
 Kirill A. Shutemov

--C7zPtVaVf+AK4Oqc
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJQiaX3AAoJEAd+omnVudOMlHYQAI7UBvsRBlttc1GBnjhUM7tM
fzYzIB7sni9A9DVdBK0y8dkRL5tuYch3Y4k+Pr7XBsckgzTWtgX5KZbB+0jxX6OU
GsZaggCqv0lSSVAcZaIT09/6a9CVq2GxbVm4rt0fjt38Y1QnTljf5drOkljgKLij
gB8eGzi4GiRoZHJvckIGcSnVr3gxxHa/YPycr3w4A0mVCRjPLvq1oPNUxoXXiq+u
lTOtkPCtJ8BskH5bk/ddsODFkVoZzpUKb2I5jts1n2o4fNxxOpB+Eise0/qInXTn
oVeE3tRFKIWFQ5uJjSwtyVJvrmyMbSPIBJH+iRyC0Q5Pvfcnk5aDEz1ArE60+kVj
tT51SdQYyNpbk40+BjqTxsgi3UoU3NXhNwZNisRYB4a/6ju4oXVA8Pugno4zptLD
7QqOip3b02zy0So/n//86sC7JG0lyCU3c4oM/GmF0KMlAWr+Gp3GiKNIiw9UvnXh
ng13xmsYU0WT4cr3i5aSc8fOWeAz9p4ebyYoadGyJL30ok6WHsDMPaIh4RE7S6uL
v/bIQy+nqzOKQ/r/U+bDvYqudpcf7Q5BpxUCTFBLSxLMGc+cnHaFp/6N5YkmXmhs
p4tHfha++PGHZLbmhoGV2P+DJT90ud1TRMdoPYjX3NGcfzWXM6zIuy+nYoHz7z8h
DiUetA+r06cMIIzrXvSN
=h0lA
-----END PGP SIGNATURE-----

--C7zPtVaVf+AK4Oqc--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
