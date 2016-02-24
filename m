Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f45.google.com (mail-qg0-f45.google.com [209.85.192.45])
	by kanga.kvack.org (Postfix) with ESMTP id D2C396B0256
	for <linux-mm@kvack.org>; Wed, 24 Feb 2016 18:28:58 -0500 (EST)
Received: by mail-qg0-f45.google.com with SMTP id y9so27908188qgd.3
        for <linux-mm@kvack.org>; Wed, 24 Feb 2016 15:28:58 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id s76si5153331qki.38.2016.02.24.15.28.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Feb 2016 15:28:58 -0800 (PST)
Message-ID: <1456356532.25322.9.camel@redhat.com>
Subject: Re: [PATCH] mm: limit direct reclaim for higher order allocations
From: Rik van Riel <riel@redhat.com>
Date: Wed, 24 Feb 2016 18:28:52 -0500
In-Reply-To: <20160224150231.7dac6dc8c7dd9078db83eea4@linux-foundation.org>
References: <20160224163850.3d7eb56c@annuminas.surriel.com>
	 <20160224150231.7dac6dc8c7dd9078db83eea4@linux-foundation.org>
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature";
	boundary="=-e+7MkiaizKrSo8UK0ULP"
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, hannes@cmpxchg.org, vbabka@suse.cz, mgorman@suse.de, linux-mm@kvack.org


--=-e+7MkiaizKrSo8UK0ULP
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2016-02-24 at 15:02 -0800, Andrew Morton wrote:
> On Wed, 24 Feb 2016 16:38:50 -0500 Rik van Riel <riel@redhat.com>
> wrote:
>=20
> > For multi page allocations smaller than PAGE_ALLOC_COSTLY_ORDER,
> > the kernel will do direct reclaim if compaction failed for any
> > reason. This worked fine when Linux systems had 128MB RAM, but
> > on my 24GB system I frequently see higher order allocations
> > free up over 3GB of memory, pushing all kinds of things into
> > swap, and slowing down applications.
>=20
> hm.=C2=A0=C2=A0Seems a pretty obvious flaw - why didn't we notice+fix it
> earlier?

I have heard complaints about suspicious pageout
behaviour before, but had not investigated it
until recently.

> > It would be much better to limit the amount of reclaim done,
> > rather than cause excessive pageout activity.
> >=20
> > When enough memory is free to do compaction for the highest order
> > allocation possible, bail out of the direct page reclaim code.
> >=20
> > On smaller systems, this may be enough to obtain contiguous
> > free memory areas to satisfy small allocations, continuing our
> > strategy of relying on luck occasionally. On larger systems,
> > relying on luck like that has not been working for years.
> >=20
>=20
> It would be nice to see some solid testing results on real-world
> workloads?

That's why I posted it. =C2=A0I suspect my workload
is not nearly as demanding as the workloads many
other people have, and this is the kind of thing
that wants some serious testing.

It might also make sense to carry it in -mm for
two full release cycles before sending it to Linus.

> (patch retained for linux-mm)
>=20
> > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > index fc62546096f9..8dd15d514761 100644
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -2584,20 +2584,17 @@ static bool shrink_zones(struct zonelist
> > *zonelist, struct scan_control *sc)
> > =C2=A0				continue;	/* Let kswapd
> > poll it */
> > =C2=A0
> > =C2=A0			/*
> > -			=C2=A0* If we already have plenty of memory
> > free for
> > -			=C2=A0* compaction in this zone, don't free any
> > more.
> > -			=C2=A0* Even though compaction is invoked for
> > any
> > -			=C2=A0* non-zero order, only frequent costly
> > order
> > -			=C2=A0* reclamation is disruptive enough to
> > become a
> > -			=C2=A0* noticeable problem, like transparent
> > huge
> > -			=C2=A0* page allocations.
> > +			=C2=A0* For higher order allocations, free
> > enough memory
> > +			=C2=A0* to be able to do compaction for the
> > largest possible
> > +			=C2=A0* allocation. On smaller systems, this
> > may be enough
> > +			=C2=A0* that smaller allocations can skip
> > compaction, if
> > +			=C2=A0* enough adjacent pages get freed.
> > =C2=A0			=C2=A0*/
> > -			if (IS_ENABLED(CONFIG_COMPACTION) &&
> > -			=C2=A0=C2=A0=C2=A0=C2=A0sc->order > PAGE_ALLOC_COSTLY_ORDER &&
> > +			if (IS_ENABLED(CONFIG_COMPACTION) && sc-
> > >order &&
> > =C2=A0			=C2=A0=C2=A0=C2=A0=C2=A0zonelist_zone_idx(z) <=3D
> > requested_highidx &&
> > -			=C2=A0=C2=A0=C2=A0=C2=A0compaction_ready(zone, sc->order)) {
> > +			=C2=A0=C2=A0=C2=A0=C2=A0compaction_ready(zone, MAX_ORDER)) {
> > =C2=A0				sc->compaction_ready =3D true;
> > -				continue;
> > +				return true;
> > =C2=A0			}
> > =C2=A0
> > =C2=A0			/*
--=20
All Rights Reversed.


--=-e+7MkiaizKrSo8UK0ULP
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQEcBAABAgAGBQJWzjy0AAoJEM553pKExN6D2zwH/3pe2FUyd0kszT2hwYZcoN1R
kSXcLtyo1ZotO48nx84cPQhVsXeyYRlA6AFlOgrMUzsezkMj9aqxrRnZn9Lpf7mM
ZsjBTbil3xnJlKLSajW7bGda5cFhgCpmfweELqPIbbdTICHN+kXGaux57SPhOC5Z
qvRE9Z3Jtp9/VM+1EZ2NhzqqNR+z3iBvGEj6jbJLOkcCVhrEFIIvEDUSdFcu/dSA
gYrgUcMGs1h6G8iobF1kzcFBqCfboocltYyTD8977+3y9tRqZ32km651Hne4lgi/
sdz+jSBeK5dRnAlKM+OtsE02wVP2og3IOcfRstLTQwGhkcMa4vAPfjoLfz0Y590=
=ucLa
-----END PGP SIGNATURE-----

--=-e+7MkiaizKrSo8UK0ULP--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
