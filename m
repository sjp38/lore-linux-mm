Subject: Re: [RFC 0/3] Recursive reclaim (on __PF_MEMALLOC)
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <20070821002830.GB8414@wotan.suse.de>
References: <20070814142103.204771292@sgi.com>
	 <20070815122253.GA15268@wotan.suse.de> <1187183526.6114.45.camel@twins>
	 <20070816032921.GA32197@wotan.suse.de> <1187581894.6114.169.camel@twins>
	 <20070821002830.GB8414@wotan.suse.de>
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-ZNJWDQnY3kzIDRTM3ekU"
Date: Tue, 21 Aug 2007 17:29:27 +0200
Message-Id: <1187710167.6114.258.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, dkegel@google.com, David Miller <davem@davemloft.net>, Daniel Phillips <phillips@google.com>
List-ID: <linux-mm.kvack.org>

--=-ZNJWDQnY3kzIDRTM3ekU
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

[ now with CCs ]

On Tue, 2007-08-21 at 02:28 +0200, Nick Piggin wrote:

> I do of course. There is one thing to have a real lock deadlock
> in some core path, and another to have this memory deadlock in a
> known-to-be-dodgy configuration (Linus said last year that he didn't
> want to go out of our way to support this, right?)... But if you can
> solve it without impacting fastpaths etc. then I don't see any
> objection to it.

That has been my intention, getting the problem solved without touching
fast paths and with minimal changes to how things are currently done.

> I don't mean for correctness, but for throughput. If you're doing a
> lot of network operations right near the memory limit, then it could
> be possible that these deadlock paths get triggered relatively often.
> With Christoph's patches, I think it would tend to be less.

Christoph's patches all rely on file backed memory being predominant.
[ and to a certain degree fully ignore anonymous memory loads :-( ]

Whereas quite a few realistic loads strive to minimise these - I'll
again fall back to my MPI cluster example, they would want to use so
much anonymous memory to preform their calculations that everything
except the hot paths of code are present in memory. In these scenarios 1
MB of text would already be a lot.

> > > How are your deadlock patches going anyway? AFAIK they are mostly a n=
etwork
> > > issue and I haven't been keeping up with them for a while.=20
> >=20
> > They really do rely on some VM interaction too, network does not have
> > enough information to break out of the deadlock on its own.
>=20
> The thing I don't much like about your patches is the addition of more
> of these global reserve type things in the allocators. They kind of
> suck (not your code, just the concept of them in general -- ie. including
> the PF_MEMALLOC reserve). I'd like to eventually reach a model where
> reclaimable memory from a given subsystem is always backed by enough
> resources to be able to reclaim it. What stopped you from going that
> route with the network subsystem? (too much churn, or something
> fundamental?)

I'm wanting to keep the patches as non-intrusive as possible, exactly
because some people consider this a fringe functionality. Doing as you
say does sound like a noble goal, but would require massive overhauls.

Also, I'm not quite sure how this would apply to networking. It
generally doesn't have much reclaimable memory sitting around, and it
heavily relies on kmalloc so an alloc/free cycle accounting system would
quickly involve a lot of the things I'm already doing.

(also one advantage of keeping it all in the buddy allocator is that it
can more easily form larger order pages)

--=-ZNJWDQnY3kzIDRTM3ekU
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQBGywTXXA2jU0ANEf4RAppFAJ0V/mw9mDGzP+eCcHKqZudcAMOWRACbByj7
JZLUK76DwTil61gpPo6ommw=
=weiH
-----END PGP SIGNATURE-----

--=-ZNJWDQnY3kzIDRTM3ekU--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
