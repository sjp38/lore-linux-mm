Subject: Re: [PATCH 00/33] Swap over NFS -v14
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <47287220.8050804@garzik.org>
References: <20071030160401.296770000@chello.nl>
	 <200710311426.33223.nickpiggin@yahoo.com.au>
	 <1193830033.27652.159.camel@twins>  <47287220.8050804@garzik.org>
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-OaD2syMtsbYlyGKvRGaF"
Date: Wed, 31 Oct 2007 13:56:53 +0100
Message-Id: <1193835413.27652.205.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jeff Garzik <jeff@garzik.org>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, trond.myklebust@fys.uio.no
List-ID: <linux-mm.kvack.org>

--=-OaD2syMtsbYlyGKvRGaF
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, 2007-10-31 at 08:16 -0400, Jeff Garzik wrote:
> Thoughts:
>=20
> 1) I absolutely agree that NFS is far more prominent and useful than any=20
> network block device, at the present time.
>=20
>=20
> 2) Nonetheless, swap over NFS is a pretty rare case.  I view this work=20
> as interesting, but I really don't see a huge need, for swapping over=20
> NBD or swapping over NFS.  I tend to think swapping to a remote resource=20
> starts to approach "migration" rather than merely swapping.  Yes, we can=20
> do it...  but given the lack of burning need one must examine the price.

There is a large corporate demand for this, which is why I'm doing this.

The typical usage scenarios are:
 - cluster/blades, where having local disks is a cost issue (maintenance
   of failures, heat, etc)
 - virtualisation, where dumping the storage on a networked storage unit
   makes for trivial migration and what not..

But please, people who want this (I'm sure some of you are reading) do
speak up. I'm just the motivated corporate drone implementing the
feature :-)

> 3) You note
> > Swap over network has the problem that the network subsystem does not u=
se fixed
> > sized allocations, but heavily relies on kmalloc(). This makes mempools
> > unusable.
>=20
> True, but IMO there are mitigating factors that should be researched and=20
> taken into account:
>=20
> a) To give you some net driver background/history, most mainstream net=20
> drivers were coded to allocate RX skbs of size 1538, under the theory=20
> that they would all be allocating out of the same underlying slab cache.=20
>   It would not be difficult to update a great many of the [non-jumbo]=20
> cases to create a fixed size allocation pattern.

One issue that comes to mind is how to ensure we'd still overflow the
IP-reassembly buffers. Currently those are managed on the number of
bytes present, not the number of fragments.

One of the goals of my approach was to not rewrite the network subsystem
to accomodate this feature (and I hope I succeeded).

> b) Spare-time experiments and anecdotal evidence points to RX and TX skb=20
> recycling as a potentially valuable area of research.  If you are able=20
> to do something like that, then memory suddenly becomes a lot more=20
> bounded and predictable.
>=20
>=20
> So my gut feeling is that taking a hard look at how net drivers function=20
> in the field should give you a lot of good ideas that approach the=20
> shared goal of making network memory allocations more predictable and=20
> bounded.

Note that being bounded only comes from dropping most packets before
trying them to a socket. That is the crucial part of the RX path, to
receive all packets from the NIC (regardless their size) but to not pass
them on to the network stack - unless they belong to a 'special' socket
that promises undelayed processing.

Thanks for these ideas, I'll look into them.

--=-OaD2syMtsbYlyGKvRGaF
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQBHKHuUXA2jU0ANEf4RAsnqAJ94v8DkPq//f0k6nSWC+d/NSdChTQCfbO5f
R59KUmW5WUpH2o9WuhYgn9I=
=263P
-----END PGP SIGNATURE-----

--=-OaD2syMtsbYlyGKvRGaF--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
