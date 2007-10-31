Subject: Re: [PATCH 03/33] mm: slub: add knowledge of reserve pages
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <200710312146.03351.nickpiggin@yahoo.com.au>
References: <20071030160401.296770000@chello.nl>
	 <200710311437.28630.nickpiggin@yahoo.com.au>
	 <1193827358.27652.126.camel@twins>
	 <200710312146.03351.nickpiggin@yahoo.com.au>
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-e2VI6o49+LBHhnTdwH6G"
Date: Wed, 31 Oct 2007 13:17:52 +0100
Message-Id: <1193833072.27652.167.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, trond.myklebust@fys.uio.no
List-ID: <linux-mm.kvack.org>

--=-e2VI6o49+LBHhnTdwH6G
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, 2007-10-31 at 21:46 +1100, Nick Piggin wrote:
> On Wednesday 31 October 2007 21:42, Peter Zijlstra wrote:
> > On Wed, 2007-10-31 at 14:37 +1100, Nick Piggin wrote:
> > > On Wednesday 31 October 2007 03:04, Peter Zijlstra wrote:
> > > > Restrict objects from reserve slabs (ALLOC_NO_WATERMARKS) to alloca=
tion
> > > > contexts that are entitled to it.
> > > >
> > > > Care is taken to only touch the SLUB slow path.
> > > >
> > > > This is done to ensure reserve pages don't leak out and get consume=
d.
> > >
> > > I think this is generally a good idea (to prevent slab allocators
> > > from stealing reserve). However I naively think the implementation
> > > is a bit overengineered and thus has a few holes.
> > >
> > > Humour me, what was the problem with failing the slab allocation
> > > (actually, not fail but just call into the page allocator to do
> > > correct waiting  / reclaim) in the slowpath if the process fails the
> > > watermark checks?
> >
> > Ah, we actually need slabs below the watermarks.
>=20
> Right, I'd still allow those guys to allocate slabs. Provided they
> have the right allocation context, right?
>=20
>=20
> > Its just that once I=20
> > allocated those slabs using __GFP_MEMALLOC/PF_MEMALLOC I don't want
> > allocation contexts that do not have rights to those pages to walk off
> > with objects.
>=20
> And I'd prevent these ones from doing so.
>=20
> Without keeping track of "reserve" pages, which doesn't feel
> too clean.

The problem with that is that once a slab was allocated with the right
allocation context, anybody can get objects from these slabs.


low memory, and empty slab:

task A                        task B

kmem_cache_alloc() =3D NULL

                              current->flags |=3D PF_MEMALLOC
                              kmem_cache_alloc() =3D obj
                              (slab !=3D NULL)

kmem_cache_alloc() =3D obj
kmem_cache_alloc() =3D obj
kmem_cache_alloc() =3D obj


And now task A, who doesn't have the right permissions walks
away with all our reserve memory.

So we either reserve a page per object, which for 32 byte objects is a
large waste, or we stop anybody who doesn't have the right permissions
from obtaining objects. I took the latter approach.


--=-e2VI6o49+LBHhnTdwH6G
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQBHKHJwXA2jU0ANEf4RAi25AJ9u+31qjdHGk55nk3eaiqMPKkO9ywCeKPzr
by9zgemtfC3t8u8Mc8uwX2k=
=88Nf
-----END PGP SIGNATURE-----

--=-e2VI6o49+LBHhnTdwH6G--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
