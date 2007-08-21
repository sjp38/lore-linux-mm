Subject: Re: [RFC 2/9] Use NOMEMALLOC reclaim to allow reclaim if
	PF_MEMALLOC is set
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <20070821003922.GD8414@wotan.suse.de>
References: <20070814153021.446917377@sgi.com>
	 <20070814153501.305923060@sgi.com> <20070818071035.GA4667@ucw.cz>
	 <Pine.LNX.4.64.0708201158270.28863@schroedinger.engr.sgi.com>
	 <1187641056.5337.32.camel@lappy>
	 <Pine.LNX.4.64.0708201323590.30053@schroedinger.engr.sgi.com>
	 <1187644449.5337.48.camel@lappy>  <20070821003922.GD8414@wotan.suse.de>
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-18h/PPWt7ZVLALby2nSG"
Date: Tue, 21 Aug 2007 16:07:15 +0200
Message-Id: <1187705235.6114.247.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Christoph Lameter <clameter@sgi.com>, Pavel Machek <pavel@ucw.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, dkegel@google.com, David Miller <davem@davemloft.net>
List-ID: <linux-mm.kvack.org>

--=-18h/PPWt7ZVLALby2nSG
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Tue, 2007-08-21 at 02:39 +0200, Nick Piggin wrote:
> On Mon, Aug 20, 2007 at 11:14:08PM +0200, Peter Zijlstra wrote:
> > On Mon, 2007-08-20 at 13:27 -0700, Christoph Lameter wrote:
> > > On Mon, 20 Aug 2007, Peter Zijlstra wrote:
> > >=20
> > > > > Plus the same issue can happen today. Writes are usually not comp=
leted=20
> > > > > during reclaim. If the writes are sufficiently deferred then you =
have the=20
> > > > > same issue now.
> > > >=20
> > > > Once we have initiated (disk) writeout we do not need more memory t=
o
> > > > complete it, all we need to do is wait for the completion interrupt=
.
> > >=20
> > > We cannot reclaim the page as long as the I/O is not complete. If you=
=20
> > > have too many anonymous pages and the rest of memory is dirty then yo=
u can=20
> > > get into OOM scenarios even without this patch.
> >=20
> > As long as the reserve is large enough to completely initialize writeou=
t
> > of a single page we can make progress. Once writeout is initialized the
> > completion interrupt is guaranteed to happen (assuming working
> > hardware).
>=20
> Although interestingly, we are not guaranteed to have enough memory to
> completely initialise writeout of a single page.

Yes, that is due to the unbounded nature of direct reclaim, no?

I've been meaning to write some patches to address this problem in a way
that does not introduce the hard wall Linus objects to. If only I had
this extra day in the week :-/

And then there is the deadlock in add_to_swap() that I still have to
look into, I hope it can eventually be solved using reserve based
allocation.

> The buffer layer doesn't require disk blocks to be allocated at page
> dirty-time. Allocating disk blocks can require complex filesystem operati=
ons
> and readin of buffer cache pages. The buffer_head structures themselves m=
ay
> not even be present and must be allocated :P
>=20
> In _practice_, this isn't such a problem because we have dirty limits, an=
d
> we're almost guaranteed to have some clean pages to be reclaimed. In this
> same way, networked filesystems are not a problem in practice. However
> network swap, because there is no dirty limits on swap, can actually see
> the deadlock problems.

The main problem with networked swap is not so much sending out the
pages (this has similar problems like the filesystems but is all bounded
in its memory use).

The biggest issue is receiving the completion notification. Network
needs to fall back to a state where it does not blindly consumes memory
or drops _all_ packets. An intermediate state is required, one where we
can receive and inspect incoming packets but commit to very few.

In order to create such a network state and for it to be stable, a
certain amount of memory needs to be available and an external trigger
is needed to enter and leave this state - currently provided by there
being more memory available than needed or not.

--=-18h/PPWt7ZVLALby2nSG
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQBGyvGTXA2jU0ANEf4RAq+5AKCKs7gOO2qT8B/1iqYEfOUez2lZ4ACeK0Gu
Oe9GQ9PeTt/r1i7diyS/7hU=
=nnsp
-----END PGP SIGNATURE-----

--=-18h/PPWt7ZVLALby2nSG--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
