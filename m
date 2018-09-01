Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id C2FEF6B59F6
	for <linux-mm@kvack.org>; Fri, 31 Aug 2018 21:27:10 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id u45-v6so16591485qte.12
        for <linux-mm@kvack.org>; Fri, 31 Aug 2018 18:27:10 -0700 (PDT)
Received: from shelob.surriel.com (shelob.surriel.com. [96.67.55.147])
        by mx.google.com with ESMTPS id y6-v6si3349715qvb.91.2018.08.31.18.27.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 31 Aug 2018 18:27:10 -0700 (PDT)
Message-ID: <68c883be3b4562970cef76c574e2e345e0d514e6.camel@surriel.com>
Subject: Re: [PATCH] mm: slowly shrink slabs with a relatively small number
 of objects
From: Rik van Riel <riel@surriel.com>
Date: Fri, 31 Aug 2018 21:27:03 -0400
In-Reply-To: <20180831213138.GA9159@tower.DHCP.thefacebook.com>
References: <20180831203450.2536-1-guro@fb.com>
	 <3b05579f964cca1d44551913f1a9ee79d96f198e.camel@surriel.com>
	 <20180831213138.GA9159@tower.DHCP.thefacebook.com>
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-3/ubquztSqUU4YdQHWI2"
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com, Josef Bacik <jbacik@fb.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>


--=-3/ubquztSqUU4YdQHWI2
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2018-08-31 at 14:31 -0700, Roman Gushchin wrote:
> On Fri, Aug 31, 2018 at 05:15:39PM -0400, Rik van Riel wrote:
> > On Fri, 2018-08-31 at 13:34 -0700, Roman Gushchin wrote:
> >=20
> > > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > > index fa2c150ab7b9..c910cf6bf606 100644
> > > --- a/mm/vmscan.c
> > > +++ b/mm/vmscan.c
> > > @@ -476,6 +476,10 @@ static unsigned long do_shrink_slab(struct
> > > shrink_control *shrinkctl,
> > >  	delta =3D freeable >> priority;
> > >  	delta *=3D 4;
> > >  	do_div(delta, shrinker->seeks);
> > > +
> > > +	if (delta =3D=3D 0 && freeable > 0)
> > > +		delta =3D min(freeable, batch_size);
> > > +
> > >  	total_scan +=3D delta;
> > >  	if (total_scan < 0) {
> > >  		pr_err("shrink_slab: %pF negative objects to delete
> > > nr=3D%ld\n",
> >=20
> > I agree that we need to shrink slabs with fewer than
> > 4096 objects, but do we want to put more pressure on
> > a slab the moment it drops below 4096 than we applied
> > when it had just over 4096 objects on it?
> >=20
> > With this patch, a slab with 5000 objects on it will
> > get 1 item scanned, while a slab with 4000 objects on
> > it will see shrinker->batch or SHRINK_BATCH objects
> > scanned every time.
> >=20
> > I don't know if this would cause any issues, just
> > something to ponder.
>=20
> Hm, fair enough. So, basically we can always do
>=20
>     delta =3D max(delta, min(freeable, batch_size));
>=20
> Does it look better?

Yeah, that looks fine to me.

That will read to small cgroups having small caches
reclaimed relatively more quickly than large caches
getting reclaimed, but small caches should also be
faster to refill once they are needed again, so it
is probably fine.

--=20
All Rights Reversed.

--=-3/ubquztSqUU4YdQHWI2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----

iQEzBAABCAAdFiEEKR73pCCtJ5Xj3yADznnekoTE3oMFAluJ6ucACgkQznnekoTE
3oPKyQf+MxHOnVs6t4PZLXi0UsLb/iVrpKqFJmOeMFpXlBV9SL+JtNNRynMahji6
Jf2R4XiQ+l83xdynzaawtTXfPb5bUSkyYXqpgXSYkul7whLIJqVvD7PmN77BLugs
siPBZp/rfoOJHCae7wazEJb3f3xa0420d5EViVTHLrTGnRJS9raWAFtGJr8wR+dK
c5PMVPSOJAFgAKwDb00SUSj/DiMa9hgZsp0joVxxr+ofkpabFIr3/5JOcyuaZLo7
3Mw6J9hgCML5LZA3WzBEdsAQormFOG2JZZvNW/ipbIMXJpyapSVKlZ9qCwH6IIt9
MoxJLSKdtF/0N5cih5kR9xUwDR23yQ==
=ogZz
-----END PGP SIGNATURE-----

--=-3/ubquztSqUU4YdQHWI2--
