Subject: Re: [PATCH] remove throttle_vm_writeout()
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <20071004174851.b34a3220.akpm@linux-foundation.org>
References: <E1IdPla-0002Bd-00@dorka.pomaz.szeredi.hu>
	 <20071004145640.18ced770.akpm@linux-foundation.org>
	 <E1IdZLg-0002Wr-00@dorka.pomaz.szeredi.hu>
	 <20071004160941.e0c0c7e5.akpm@linux-foundation.org>
	 <E1Ida56-0002Zz-00@dorka.pomaz.szeredi.hu>
	 <20071004164801.d8478727.akpm@linux-foundation.org>
	 <E1Idanu-0002c1-00@dorka.pomaz.szeredi.hu>
	 <20071004174851.b34a3220.akpm@linux-foundation.org>
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-6oS6M+9uL26TZ1uFlcP6"
Date: Fri, 05 Oct 2007 10:22:00 +0200
Message-Id: <1191572520.22357.42.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Miklos Szeredi <miklos@szeredi.hu>, wfg@mail.ustc.edu.cn, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

--=-6oS6M+9uL26TZ1uFlcP6
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Thu, 2007-10-04 at 17:48 -0700, Andrew Morton wrote:
> On Fri, 05 Oct 2007 02:12:30 +0200 Miklos Szeredi <miklos@szeredi.hu> wro=
te:
>=20
> > >=20
> > > I don't think I understand that.  Sure, it _shouldn't_ be a problem. =
 But it
> > > _is_.  That's what we're trying to fix, isn't it?
> >=20
> > The problem, I believe is in the memory allocation code, not in fuse.
>=20
> fuse is trying to do something which page reclaim was not designed for.=20
> Stuff broke.
>=20
> > In the example, memory allocation may be blocking indefinitely,
> > because we have 4MB under writeback, even though 28MB can still be
> > made available.  And that _should_ be fixable.
>=20
> Well yes.  But we need to work out how, without re-breaking the thing whi=
ch
> throttle_vm_writeout() fixed.

I'm thinking the really_congested thing will also fix this. By only
allowing a limited amount of extra writeback.

> > > > So the only thing the kernel should be careful about, is not to blo=
ck
> > > > on an allocation if not strictly necessary.
> > > >=20
> > > > Actually a trivial fix for this problem could be to just tweak the
> > > > thresholds, so to make the above scenario impossible.  Although I'm
> > > > still not convinced, this patch is perfect, because the dirty
> > > > threshold can actually change in time...
> > > >=20
> > > > Index: linux/mm/page-writeback.c
> > > > =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> > > > --- linux.orig/mm/page-writeback.c      2007-10-05 00:31:01.0000000=
00 +0200
> > > > +++ linux/mm/page-writeback.c   2007-10-05 00:50:11.000000000 +0200
> > > > @@ -515,6 +515,12 @@ void throttle_vm_writeout(gfp_t gfp_mask
> > > >          for ( ; ; ) {
> > > >                 get_dirty_limits(&background_thresh, &dirty_thresh,=
 NULL, NULL);
> > > >=20
> > > > +               /*
> > > > +                * Make sure the theshold is over the hard limit of
> > > > +                * dirty_thresh + ratelimit_pages * nr_cpus
> > > > +                */
> > > > +               dirty_thresh +=3D ratelimit_pages * num_online_cpus=
();
> > > > +
> > > >                  /*
> > > >                   * Boost the allowable dirty threshold a bit for p=
age
> > > >                   * allocators so they don't get DoS'ed by heavy wr=
iters
> > >=20
> > > I can probably kind of guess what you're trying to do here.  But if
> > > ratelimit_pages * num_online_cpus() exceeds the size of the offending=
 zone
> > > then things might go bad.
> >=20
> > I think the admin can do quite a bit of other damage, by setting
> > dirty_ratio too high.
> >=20
> > Maybe this writeback throttling should just have a fixed limit of 80%
> > ZONE_NORMAL, and limit dirty_ratio to something like 50%.
>=20
> Bear in mind that the same problem will occur for the 16MB ZONE_DMA, and
> we cannot limit the system-wide dirty-memory threshold to 12MB.
>=20
> iow, throttle_vm_writeout() needs to become zone-aware.  Then it only
> throttles when, say, 80% of ZONE_FOO is under writeback.

As it stand 110% of dirty limit can already be larger than say zone_dma
(and likely is), so that is not a new bug - and I don't think its the
thing Miklos runs into.

The problem Miklos is seeing (and I, just in a different form), is that
throttle_vm_writeout() gets stuck because balance_dirty_pages() gets
called once every ratelimit_pages (per cpu). So we can have nr_cpus *
ratelimit_pages extra.....

/me thinks

ok I confused myself.

by calling balance_dirty_pages() once every ratelimit_pages (per cpu)
allows for nr_cpus() * ratelimit_pages extra _dirty_ pages. But
balance_dirty_pages() will make it:
  nr_dirty + nr_unstable + nr_writeback < thresh

So even if it writes out all of the dirty pages, we still have:
  nr_unstable + nr_writeback < thresh

So at any one time nr_writeback should not exceed thresh. But it does!?

So how do we end up with more writeback pages than that? should we teach
pdflush about these limits as well?


--=-6oS6M+9uL26TZ1uFlcP6
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQBHBfQoXA2jU0ANEf4RAgH3AJ9W8rW+XbMwK+ApE9ulHQoko6mxSQCfRHFx
E//k3DEjs1T9sfljzo3AMUY=
=77SU
-----END PGP SIGNATURE-----

--=-6oS6M+9uL26TZ1uFlcP6--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
