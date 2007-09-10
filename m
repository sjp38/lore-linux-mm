Subject: Re: [RFC 0/3] Recursive reclaim (on __PF_MEMALLOC)
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <Pine.LNX.4.64.0709101318160.25407@schroedinger.engr.sgi.com>
References: <20070814142103.204771292@sgi.com>
	 <200709050220.53801.phillips@phunq.net>
	 <Pine.LNX.4.64.0709050334020.8127@schroedinger.engr.sgi.com>
	 <200709050916.04477.phillips@phunq.net>
	 <Pine.LNX.4.64.0709101220001.24735@schroedinger.engr.sgi.com>
	 <1189454145.21778.48.camel@twins>
	 <Pine.LNX.4.64.0709101318160.25407@schroedinger.engr.sgi.com>
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-dYdtcNtcAcP48rMZdHHn"
Date: Mon, 10 Sep 2007 22:48:06 +0200
Message-Id: <1189457286.21778.68.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Daniel Phillips <phillips@phunq.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, dkegel@google.com, David Miller <davem@davemloft.net>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

--=-dYdtcNtcAcP48rMZdHHn
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Mon, 2007-09-10 at 13:22 -0700, Christoph Lameter wrote:
> On Mon, 10 Sep 2007, Peter Zijlstra wrote:
>=20
> > On Mon, 2007-09-10 at 12:25 -0700, Christoph Lameter wrote:
> >=20
> > > Of course boundless allocations from interrupt / reclaim context will=
=20
> > > ultimately crash the system. To fix that you need to stop the network=
ing=20
> > > layer from performing these.
> >=20
> > Trouble is, I don't only need a network layer to not endlessly consume
> > memory, I need it to 'fully' function so that we can receive the
> > writeout completion.
>=20
> You need to drop packets after having inspected them right? Why wont=20
> dropping packets after a certain amount of memory has been allocated work=
?=20
> What is so difficult about that?

That puts the burden of tracking skb allocations and all that on the
fast path.

The 'simplicity' of my current approach is that we only start
bean-counting (and incur the overhead thereof) once we need it.

> > or
> >=20
> >   - have a global reserve and selectively serves sockets
> >     (what I've been doing)
>=20
> That is a scalability problem on large systems! Global means global=20
> serialization, cacheline bouncing and possibly livelocks. If we get into=20
> this global shortage then all cpus may end up taking the same locks=20
> cycling thought the same allocation paths.

Dude, breathe, these boxens of yours will never swap over network simply
because you never configure swap.=20

And, _no_, it does not necessarily mean global serialisation. By simply
saying there must be N pages available I say nothing about on which node
they should be available, and the way the watermarks work they will be
evenly distributed over the appropriate zones.

> > So, if you will, you can view my approach as a reserve per socket, wher=
e
> > most sockets get a reserve of 0 and a few (those serving the VM) !0.
>=20
> Well it looks like you know how to do it. Why not implement it?

/me confused, I already have!

If you talk about the IRIX model, I'm very hestitant to do that simply
because that would incur the bean-counting overhead on the normal case
and that will greatly upset the network people - nor would that mean
that I don't need this stricter PF_MEMALLOC behaviour.

--=-dYdtcNtcAcP48rMZdHHn
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQBG5a2GXA2jU0ANEf4RAiMMAJ9ghHZzRhBnubU1XCju63ZZU7exDACbBiTC
WYvMQoPAfvLTQiB5tAA1F3Y=
=poOK
-----END PGP SIGNATURE-----

--=-dYdtcNtcAcP48rMZdHHn--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
