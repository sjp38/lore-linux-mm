Subject: Re: [RFC 2/9] Use NOMEMALLOC reclaim to allow reclaim if
	PF_MEMALLOC is set
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <18125.23918.550443.628936@gargle.gargle.HOWL>
References: <20070814153021.446917377@sgi.com>
	 <20070814153501.305923060@sgi.com> <20070818071035.GA4667@ucw.cz>
	 <Pine.LNX.4.64.0708201158270.28863@schroedinger.engr.sgi.com>
	 <1187641056.5337.32.camel@lappy>
	 <Pine.LNX.4.64.0708201323590.30053@schroedinger.engr.sgi.com>
	 <1187644449.5337.48.camel@lappy> <20070821003922.GD8414@wotan.suse.de>
	 <1187705235.6114.247.camel@twins> <20070823033826.GE18788@wotan.suse.de>
	 <1187861208.6114.342.camel@twins>
	 <18125.23918.550443.628936@gargle.gargle.HOWL>
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-f3sJQeQ7c8X6YWa59VwU"
Date: Thu, 23 Aug 2007 15:58:57 +0200
Message-Id: <1187877537.6114.398.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nikita Danilov <nikita@clusterfs.com>
Cc: Nick Piggin <npiggin@suse.de>, Christoph Lameter <clameter@sgi.com>, Pavel Machek <pavel@ucw.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, dkegel@google.com, David Miller <davem@davemloft.net>
List-ID: <linux-mm.kvack.org>

--=-f3sJQeQ7c8X6YWa59VwU
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Thu, 2007-08-23 at 14:11 +0400, Nikita Danilov wrote:
> Peter Zijlstra writes:
>=20
> [...]
>=20
>  > My idea is to extend kswapd, run cpus_per_node instances of kswapd per
>  > node for each of GFP_KERNEL, GFP_NOFS, GFP_NOIO. (basically 3 kswapds
>  > per cpu)
>  >=20
>  > whenever we would hit direct reclaim, add ourselves to a special
>  > waitqueue corresponding to the type of GFP and kick all the
>  > corresponding kswapds.
>=20
> There are two standard objections to this:
>=20
>     - direct reclaim was introduced to reduce memory allocation latency,
>       and going to scheduler kills this. But more importantly,

The part you snipped:

> > Here is were the 'special' part of the waitqueue comes into order.
> >=20
> > Instead of freeing pages to the page allocator, these kswapds would han=
d
> > out pages to the waiting processes in a round robin fashion. Only if
> > there are no more waiting processes left, would the page go to the budd=
y
> > system.

should deal with that, it allows processes to quickly get some memory.

>     - it might so happen that _all_ per-cpu kswapd instances are
>       blocked, e.g., waiting for IO on indirect blocks, or queue
>       congestion. In that case whole system stops waiting for IO to
>       complete. In the direct reclaim case, other threads can continue
>       zone scanning.

By running separate GFP_KERNEL, GFP_NOFS and GFP_NOIO kswapds this
should not occur. Much like it now does not occur.

This approach would make it work pretty much like it does now. But
instead of letting each separate context run into reclaim we then have a
fixed set of reclaim contexts which evenly distribute their resulting
free pages.

The possible down sides are:

 - more schedule()s, but I don't think these will matter when we're that
deep into reclaim
 - less concurrency - but I hope 1 set per cpu is enough, we could up
this if it turns out to really help.

--=-f3sJQeQ7c8X6YWa59VwU
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQBGzZKhXA2jU0ANEf4RAoxTAKCF5/2RtQPc6PJRtxtyZ8dWP0HYyACeJeAN
D27wV5r+kz2Xvk9OGtLJuh4=
=wYrF
-----END PGP SIGNATURE-----

--=-f3sJQeQ7c8X6YWa59VwU--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
