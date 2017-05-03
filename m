Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0ED866B0038
	for <linux-mm@kvack.org>; Wed,  3 May 2017 15:20:18 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id f96so8101534qki.14
        for <linux-mm@kvack.org>; Wed, 03 May 2017 12:20:18 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id d201si2788217qka.36.2017.05.03.12.20.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 May 2017 12:20:17 -0700 (PDT)
Message-ID: <1493839213.20270.17.camel@redhat.com>
Subject: Re: [PATCH][RFC] mm: make kswapd try harder to keep active pages in
 cache
From: Rik van Riel <riel@redhat.com>
Date: Wed, 03 May 2017 15:20:13 -0400
In-Reply-To: <20170503183814.GA11572@destiny>
References: <1493760444-18250-1-git-send-email-jbacik@fb.com>
	 <1493835888.20270.4.camel@redhat.com> <20170503183814.GA11572@destiny>
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-ZCBBCbpD/RK/nOU0KYWD"
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Josef Bacik <josef@toxicpanda.com>
Cc: linux-mm@kvack.org, hannes@cmpxchg.org, kernel-team@fb.com


--=-ZCBBCbpD/RK/nOU0KYWD
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2017-05-03 at 14:38 -0400, Josef Bacik wrote:
>=20
>=20
> > > +	if (nr_inactive > total_high_wmark && nr_inactive >
> > > nr_slab)
> > > +		skip_slab =3D true;
> >=20
> > I worry that this may be a little too aggressive,
> > and result in the slab cache growing much larger
> > than it should be on some systems.
> >=20
> > I wonder if it may make more sense to have the
> > aggressiveness of slab scanning depend on the
> > ratio of inactive to reclaimable slab pages, rather
> > than having a hard cut-off like this?
> > =C2=A0
>=20
> So I originally had a thing that kept track of the rate of change of
> inactive vs
> slab between kswapd runs, but this worked fine so I figured simpler
> was better.
> Keep in mind that we only skip slab the first loop through, so if we
> fail to
> free enough on the inactive list the first time through then we start
> evicting
> slab as well.=C2=A0=C2=A0The idea is (and my testing bore this out) that =
with
> the new size
> ratio way of shrinking slab we would sometimes be over zealous and
> evict slab
> that we were actively using, even though we had reclaimed plenty of
> pages from
> our inactive list to satisfy our sc->nr_to_reclaim.

My worry is that, since we try to keep the active to
inactive ratio about equal for file pages, many systems
could end up with equal amounts of active file pages,
inactive file pages, and reclaimable slab.

That could not be a gigantic waste of memory for many
workloads, but it could also exacerbate the "reclaim
slab objects forever without freeing any memory" problem
once we do need the memory for something else later on.

> I could probably change the ratio in the sc->inactive_only case to be
> based on
> the slab to inactive ratio and see how that turns out, I'll get that
> wired up
> and let you know how it goes.=C2=A0=C2=A0Thanks,

Looking forward to it.

I am glad to see this problem being attacked :)

--=20
All rights reversed
--=-ZCBBCbpD/RK/nOU0KYWD
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAABCAAGBQJZCi1tAAoJEM553pKExN6DyaYH/jCGWkK0Vd8ow3281lOUk1rB
1jlFshHX1DJjujVcYrem67spS9X752W+7d7YkbCt16kAQ3EVZOP7G+LzQn+ZpkLv
1RVfp3cDHUaoM7S8aosNNviBHJqFoq3suM4vO8dy27gekMPyhH4mj5hwAuZQav84
PpOfibuhJ60prEeKYd/rL+xdgQd2Xc42Iw0cT7Vk2D4KzVCdqXGz1xx63mnl9IrG
dGk48tcukiOuAncCNbobZfQKOlYdcIyIqD1r57PF+8pN7iV5R+0AR+529SYhbGDm
myLK9OV0yHMHdfH2VAGEI42s3vXEZ4Iww/iFvowWkPF4MkeDEmyK2nr31JTWe2s=
=ijpN
-----END PGP SIGNATURE-----

--=-ZCBBCbpD/RK/nOU0KYWD--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
