Subject: Re: [PATCH 3/7] swapin needs gfp_mask for loop on tmpfs
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <Pine.LNX.4.64.0710062139490.16223@blonde.wat.veritas.com>
References: <Pine.LNX.4.64.0710062130400.16223@blonde.wat.veritas.com>
	 <Pine.LNX.4.64.0710062139490.16223@blonde.wat.veritas.com>
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-We0y5pvgm73xs0opjDOu"
Date: Mon, 08 Oct 2007 15:52:59 +0200
Message-Id: <1191851579.20745.14.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <nickpiggin@yahoo.com.au>, Miklos Szeredi <miklos@szeredi.hu>, Fengguang Wu <wfg@mail.ustc.edu.cn>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--=-We0y5pvgm73xs0opjDOu
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Sat, 2007-10-06 at 21:43 +0100, Hugh Dickins wrote:
> Building in a filesystem on a loop device on a tmpfs file can hang when
> swapping, the loop thread caught in that infamous throttle_vm_writeout.
>=20
> In theory this is a long standing problem, which I've either never seen
> in practice, or long ago suppressed the recollection, after discounting
> my load and my tmpfs size as unrealistically high.  But now, with the
> new aops, it has become easy to hang on one machine.
>=20
> Loop used to grab_cache_page before the old prepare_write to tmpfs,
> which seems to have been enough to free up some memory for any swapin
> needed; but the new write_begin lets tmpfs find or allocate the page
> (much nicer, since grab_cache_page missed tmpfs pages in swapcache).
>=20
> When allocating a fresh page, tmpfs respects loop's mapping_gfp_mask,
> which has __GFP_IO|__GFP_FS stripped off, and throttle_vm_writeout is
> designed to break out when __GFP_IO or GFP_FS is unset; but when tmfps
> swaps in, read_swap_cache_async allocates with GFP_HIGHUSER_MOVABLE
> regardless of the mapping_gfp_mask - hence the hang.
>=20
> So, pass gfp_mask down the line from shmem_getpage to shmem_swapin
> to swapin_readahead to read_swap_cache_async to add_to_swap_cache.
>=20
> Signed-off-by: Hugh Dickins <hugh@veritas.com>

Acked-by: Peter Zijlstra <a.p.zijlstra@chello.nl>

--=-We0y5pvgm73xs0opjDOu
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQBHCjY7XA2jU0ANEf4RApVlAJ4yyPkTkxSF+tiOVyOdQgjE1iZ7hgCcCsgZ
GHbL4J2m8+j41h3yruWa94I=
=bE4L
-----END PGP SIGNATURE-----

--=-We0y5pvgm73xs0opjDOu--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
