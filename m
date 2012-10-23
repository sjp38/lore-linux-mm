Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id 390E66B0062
	for <linux-mm@kvack.org>; Tue, 23 Oct 2012 02:59:30 -0400 (EDT)
Date: Tue, 23 Oct 2012 10:00:18 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCH v4 10/10] thp: implement refcounting for huge zero page
Message-ID: <20121023070018.GA18381@otc-wbsnb-06>
References: <1350280859-18801-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1350280859-18801-11-git-send-email-kirill.shutemov@linux.intel.com>
 <20121018164502.b32791e7.akpm@linux-foundation.org>
 <20121018235941.GA32397@shutemov.name>
 <20121023063532.GA15870@shutemov.name>
 <20121022234349.27f33f62.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="k1lZvvs/B4yU6o8G"
Content-Disposition: inline
In-Reply-To: <20121022234349.27f33f62.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, "H. Peter Anvin" <hpa@linux.intel.com>, linux-kernel@vger.kernel.org


--k1lZvvs/B4yU6o8G
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Oct 22, 2012 at 11:43:49PM -0700, Andrew Morton wrote:
> On Tue, 23 Oct 2012 09:35:32 +0300 "Kirill A. Shutemov" <kirill@shutemov.=
name> wrote:
>=20
> > On Fri, Oct 19, 2012 at 02:59:41AM +0300, Kirill A. Shutemov wrote:
> > > On Thu, Oct 18, 2012 at 04:45:02PM -0700, Andrew Morton wrote:
> > > > On Mon, 15 Oct 2012 09:00:59 +0300
> > > > "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> wrote:
> > > >=20
> > > > > H. Peter Anvin doesn't like huge zero page which sticks in memory=
 forever
> > > > > after the first allocation. Here's implementation of lockless ref=
counting
> > > > > for huge zero page.
> > > > >=20
> > > > > We have two basic primitives: {get,put}_huge_zero_page(). They
> > > > > manipulate reference counter.
> > > > >=20
> > > > > If counter is 0, get_huge_zero_page() allocates a new huge page a=
nd
> > > > > takes two references: one for caller and one for shrinker. We fre=
e the
> > > > > page only in shrinker callback if counter is 1 (only shrinker has=
 the
> > > > > reference).
> > > > >=20
> > > > > put_huge_zero_page() only decrements counter. Counter is never ze=
ro
> > > > > in put_huge_zero_page() since shrinker holds on reference.
> > > > >=20
> > > > > Freeing huge zero page in shrinker callback helps to avoid freque=
nt
> > > > > allocate-free.
> > > >=20
> > > > I'd like more details on this please.  The cost of freeing then
> > > > reinstantiating that page is tremendous, because it has to be zeroed
> > > > out again.  If there is any way at all in which the kernel can be m=
ade
> > > > to enter a high-frequency free/reinstantiate pattern then I expect =
the
> > > > effects would be quite bad.
> > > >=20
> > > > Do we have sufficient mechanisms in there to prevent this from
> > > > happening in all cases?  If so, what are they, because I'm not seei=
ng
> > > > them?
> > >=20
> > > We only free huge zero page in shrinker callback if nobody in the sys=
tem
> > > uses it. Never on put_huge_zero_page(). Shrinker runs only under memo=
ry
> > > pressure or if user asks (drop_caches).
> > > Do you think we need an additional protection mechanism?
> >=20
> > Andrew?
> >=20
>=20
> Well, how hard is it to trigger the bad behavior?  One can easily
> create a situation in which that page's refcount frequently switches
> from 0 to 1 and back again.  And one can easily create a situation in
> which the shrinkers are being called frequently.  Run both at the same
> time and what happens?

If the goal is to trigger bad behavior then:

1. read from an area where a huge page can be mapped to get huge zero page
   mapped. hzp is allocated here. refcounter =3D=3D 2.
2. write to the same page. refcounter =3D=3D 1.
3. echo 3 > /proc/sys/vm/drop_caches. refcounter =3D=3D 0 -> free the hzp.
4. goto 1.

But it's unrealistic. /proc/sys/vm/drop_caches is only root-accessible.
We can trigger shrinker only under memory pressure. But in this, most
likely we will get -ENOMEM on hzp allocation and will go to fallback path
(4k zero page).

I don't see a problem here.

--=20
 Kirill A. Shutemov

--k1lZvvs/B4yU6o8G
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJQhkCCAAoJEAd+omnVudOMwv8QAKq2fmH/x1IY2xDaJCtKDmUP
FnqRPz7CguHszBb1oRAk5xrJnKKZokB2ZlcLfxH+5HPPLW5iKf4988nbwMXMs9hd
tpV5O4UlD7DfMwzyIGZNWwo70Fghy2J05NnbIBaitpubpSUrMFAF8U8diB89JBRB
XB7SCVdiLuFLgP1zPRyRuxxwayBWNeqULREZX3E2fzOp0OkL+I0AfUdkC0MMWgco
Pf7lP8ZJ5StFnJrkRvUYFREa1qhdG3wMQFPJfZeUdJalGgQ5loLzwx8WP9yqz0ml
DckeR6q1X6tVivIYkRwgHOBIfTX1vzBfS1xiVI+AlPh61vta49FfDYAFl0AbEnrU
HuJjLvdN9AR5zl4HFkMbLB+sjA2+U3KTisCOEMaVyH7JpOd+1KxdEDQtmvwYAaQH
lyW1SQh9AGHib5pK1B3TwpmFJ2plaA4U9egFI1GCxnE0opcZLnIGyx6xAGeNSD6q
z3m0qsQWEsjAW0Zb7RzTn2wZ+zWGGdhDVbiUrpWkbFfH4kp+T7VjCM2m4ndVueur
6zw6XCUOKOIA7YfOpsn7Qtx4zPuBPFwIu4dUuB3n5VQ/do9DDkpO0fhhAFlFFqSk
+8L7y90kuRSDWgwhi7EunB0EPhOwpjex2REgI0grfYLn4yjmOmWMKhEi5opSgoyj
kj9M7V4jiPcmSipvXF7U
=/yWz
-----END PGP SIGNATURE-----

--k1lZvvs/B4yU6o8G--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
