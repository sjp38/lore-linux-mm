Subject: Re: [PATCH] remove throttle_vm_writeout()
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <E1IdPla-0002Bd-00@dorka.pomaz.szeredi.hu>
References: <E1IdPla-0002Bd-00@dorka.pomaz.szeredi.hu>
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-Amxc9IGlRkWZlG6hXw8Z"
Date: Thu, 04 Oct 2007 14:40:26 +0200
Message-Id: <1191501626.22357.14.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: akpm@linux-foundation.org, wfg@mail.ustc.edu.cn, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

--=-Amxc9IGlRkWZlG6hXw8Z
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Thu, 2007-10-04 at 14:25 +0200, Miklos Szeredi wrote:
> This in preparation for the writable mmap patches for fuse.  I know it
> conflicts with
>=20
>   writeback-remove-unnecessary-wait-in-throttle_vm_writeout.patch
>=20
> but if this function is to be removed, it doesn't make much sense to
> fix it first ;)
> ---
>=20
> From: Miklos Szeredi <mszeredi@suse.cz>
>=20
> By relying on the global diry limits, this can cause a deadlock when
> devices are stacked.
>=20
> If the stacking is done through a fuse filesystem, the __GFP_FS,
> __GFP_IO tests won't help: the process doing the allocation doesn't
> have any special flag.
>=20
> So why exactly does this function exist?
>=20
> Direct reclaim does not _increase_ the number of dirty pages in the
> system, so rate limiting it seems somewhat pointless.
>=20
> There are two cases:
>=20
> 1) File backed pages -> file
>=20
>   dirty + writeback count remains constant
>=20
> 2) Anonymous pages -> swap
>=20
>   writeback count increases, dirty balancing will hold back file
>   writeback in favor of swap
>=20
> So the real question is: does case 2 need rate limiting, or is it OK
> to let the device queue fill with swap pages as fast as possible?

Because balance_dirty_pages() maintains:

 nr_dirty + nr_unstable + nr_writeback <=20
	total_dirty + nr_cpus * ratelimit_pages

throttle_vm_writeout() _should_ not deadlock on that, unless you're
caught in the error term: nr_cpus * ratelimit_pages.=20

Which can only happen when it is larger than 10% of dirty_thresh.

Which is even more unlikely since it doesn't account nr_dirty (as I
think it should).

As for 2), yes I think having a limit on the total number of pages in
flight is a good thing. But that said, there might be better ways to do
that.




--=-Amxc9IGlRkWZlG6hXw8Z
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQBHBN86XA2jU0ANEf4RApfyAJ4j/MDCCJWkc2l56S20+kKjmyCtMACfVsiY
upJqJpT07sVGM27he7qeKII=
=NvoT
-----END PGP SIGNATURE-----

--=-Amxc9IGlRkWZlG6hXw8Z--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
