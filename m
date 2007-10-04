Subject: Re: [PATCH] remove throttle_vm_writeout()
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <E1IdQJn-0002Cv-00@dorka.pomaz.szeredi.hu>
References: <E1IdPla-0002Bd-00@dorka.pomaz.szeredi.hu>
	 <1191501626.22357.14.camel@twins>
	 <E1IdQJn-0002Cv-00@dorka.pomaz.szeredi.hu>
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-HppdqYQtzHlB5vgAYEzA"
Date: Thu, 04 Oct 2007 15:23:06 +0200
Message-Id: <1191504186.22357.20.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: akpm@linux-foundation.org, wfg@mail.ustc.edu.cn, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

--=-HppdqYQtzHlB5vgAYEzA
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Thu, 2007-10-04 at 15:00 +0200, Miklos Szeredi wrote:
> > > 1) File backed pages -> file
> > >=20
> > >   dirty + writeback count remains constant
> > >=20
> > > 2) Anonymous pages -> swap
> > >=20
> > >   writeback count increases, dirty balancing will hold back file
> > >   writeback in favor of swap
> > >=20
> > > So the real question is: does case 2 need rate limiting, or is it OK
> > > to let the device queue fill with swap pages as fast as possible?
> >=20
> > > Because balance_dirty_pages() maintains:
> >=20
> >  nr_dirty + nr_unstable + nr_writeback <=20
> > 	total_dirty + nr_cpus * ratelimit_pages
> >=20
> > throttle_vm_writeout() _should_ not deadlock on that, unless you're
> > caught in the error term: nr_cpus * ratelimit_pages.=20
>=20
> And it does get caught on that in small memory machines.  This
> deadlock is easily reproducable on a 32MB UML instance. =20

Ah, yes, for those that is indeed easily doable.

> I haven't yet
> tested with the per-bdi patches, but I don't think they make a
> difference in this case.

Correct, they would not.

> > Which can only happen when it is larger than 10% of dirty_thresh.
> >=20
> > Which is even more unlikely since it doesn't account nr_dirty (as I
> > think it should).
>=20
> I think nr_dirty is totally irrelevant.  Since we don't care about
> case 1), and in case 2) nr_dirty doesn't play any role.

Ah, but its correct to have since we compare against dirty_thresh, which
is defined to be a unit of nr_dirty + nr_unstable + nr_writeback. if we
take one of these out, then we get an undefined amount of space extra.

> > As for 2), yes I think having a limit on the total number of pages in
> > flight is a good thing.
>=20
> Why?

for my swapping over network thingies I need to put a bound on the
amount of outgoing traffic in flight because that bounds the amount of
memory consumed by the sending side.

> > But that said, there might be better ways to do that.
>=20
> Sure, if we do need to globally limit the number of under-writeback
> pages, then I think we need to do it independently of the dirty
> accounting.

It need not be global, it could be per BDI as well, but yes.

--=-HppdqYQtzHlB5vgAYEzA
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQBHBOk6XA2jU0ANEf4RApl8AJ9C/eWB3ayb6TaGbL+LI9t0+xAAEACfbmQN
xUJIq15tOszTzMMLtLRUQuY=
=qogb
-----END PGP SIGNATURE-----

--=-HppdqYQtzHlB5vgAYEzA--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
