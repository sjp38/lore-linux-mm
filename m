Date: Tue, 29 Jul 2008 19:58:20 +1000
From: Alex Samad <alex@samad.com.au>
Subject: Re: page swap allocation error/failure in 2.6.25
Message-ID: <20080729095820.GA14509@samad.com.au>
References: <20080725072015.GA17688@samad.com.au> <1216971601.7257.345.camel@twins> <20080727060701.GA7157@samad.com.au> <1217239487.6331.24.camel@twins> <20080729000618.GE1747@samad.com.au> <20080729091401.GB20774@csn.ul.ie>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="azLHFNyN32YCQGCU"
Content-Disposition: inline
In-Reply-To: <20080729091401.GB20774@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Peter Zijlstra <peterz@infradead.org>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

--azLHFNyN32YCQGCU
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Jul 29, 2008 at 10:14:01AM +0100, Mel Gorman wrote:
> On (29/07/08 10:06), Alex Samad didst pronounce:
> > On Mon, Jul 28, 2008 at 12:04:47PM +0200, Peter Zijlstra wrote:
> > > On Sun, 2008-07-27 at 16:07 +1000, Alex Samad wrote:
> > > > On Fri, Jul 25, 2008 at 09:40:01AM +0200, Peter Zijlstra wrote:
> > > > > On Fri, 2008-07-25 at 17:20 +1000, Alex Samad wrote:
> > > > > > Hi
> > > >=20
> > > > [snip]
> > > >=20
> > > > >=20
> > > > >=20
> > > > > Its harmless if it happens sporadically.=20
> > > > >=20
> > > > > Atomic order 2 allocations are just bound to go wrong under press=
ure.
> > > > can you point me to any doco that explains this ?
> > >=20
> > > An order 2 allocation means allocating 1<<2 or 4 physically contiguous
> > > pages. Atomic allocation means not being able to sleep.
> > >=20
> > > Now if the free page lists don't have any order 2 pages available due=
 to
> > > fragmentation there is currently nothing we can do about it.
> >=20
> > Strange cause I don't normal have a high swap usage, I have 2G ram and
> > 2G swap space. There is not that much memory being used squid, apache is
> > about it.
> >=20
>=20
> The problem is related to fragmentation. Look at /proc/buddinfo and
> you'll see how many pages are free at each order. Now, the system can
> deal with fragmentation to some extent but it requires the caller to be
> able to perform IO, enter the FS and sleep.
>=20
> An atomic allocation can do none of those. High-order atomic allocations
> are almost always due to a network card using a large MTU that cannot

I definitely use higher mtu on my network

> receive a packet into many page-sized buffers. Their requirement of
> high-order atomic allocations is fragile as a result.
>=20
> You *may* be able to "hide" this by increasing min_free_kbytes as this
> will wake kswapd earlier. If the waker of kswapd had requested a high-ord=
er
> buffer then kswapd will reclaim at that order as well. However, there are
> timing issues involved (e.g. the network receive needs to enter the path
> that wakes kswapd) and it could have been improved upon.
>=20
> > > I've been meaning to try and play with 'atomic' page migration to try
> > > and assemble a higher order page on demand with something like memory
> > > compaction.
> > >=20
> > > But its never managed to get high enough on the todo list..
> > >=20
>=20
> Same here. I prototyped memory compaction a while back and the feeling at
> the time was that it could be made atomic with a bit of work but I never =
got
> around to pushing it further. Part of this was my feeling that any attempt
> to make high-order atomic allocations more reliable would be frowned upon
> as encouraging bad behaviour from device driver authors.
>=20
> --=20
> Mel Gorman
> Part-time Phd Student                          Linux Technology Center
> University of Limerick                         IBM Dublin Software Lab
>=20

--=20
Disks travel in packs.

--azLHFNyN32YCQGCU
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAkiO6bkACgkQkZz88chpJ2P9tACeMUM4IKfdUr/odIeKRjEp3Zda
StsAoI/gffCmRGQ5TwJhdGFF/qghhwuL
=2UCb
-----END PGP SIGNATURE-----

--azLHFNyN32YCQGCU--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
