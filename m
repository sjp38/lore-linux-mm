Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id E33A36B0292
	for <linux-mm@kvack.org>; Thu, 31 Aug 2017 05:07:24 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id q77so5509264wmd.9
        for <linux-mm@kvack.org>; Thu, 31 Aug 2017 02:07:24 -0700 (PDT)
Received: from atrey.karlin.mff.cuni.cz (atrey.karlin.mff.cuni.cz. [195.113.26.193])
        by mx.google.com with ESMTPS id r196si39281wmf.34.2017.08.31.02.07.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 31 Aug 2017 02:07:23 -0700 (PDT)
Date: Thu, 31 Aug 2017 11:07:22 +0200
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [RFC PATCH] treewide: remove GFP_TEMPORARY allocation flag
Message-ID: <20170831090722.GA12920@amd>
References: <20170728091904.14627-1-mhocko@kernel.org>
 <20170823175709.GA22743@xo-6d-61-c0.localdomain>
 <20170825063545.GA25498@dhcp22.suse.cz>
 <20170825072818.GA15494@amd>
 <20170825080442.GF25498@dhcp22.suse.cz>
 <20170825213936.GA13576@amd>
 <87pobjhssq.fsf@notabene.neil.brown.name>
 <20170828123657.GK17097@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="7JfCtLOvnd9MIVvH"
Content-Disposition: inline
In-Reply-To: <20170828123657.GK17097@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: NeilBrown <neilb@suse.com>, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Matthew Wilcox <willy@infradead.org>, Vlastimil Babka <vbabka@suse.cz>, Neil Brown <neilb@suse.de>, Theodore Ts'o <tytso@mit.edu>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>


--7JfCtLOvnd9MIVvH
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi!

> > > "This allocation is temporary. It lasts milliseconds, not hours."
> >=20
> > It isn't sufficient to give a rule for when GFP_TEMPORARY will be used,
> > you also need to explain (at least in general terms) how the information
> > will be used.  Also you need to give guidelines on whether the flag
> > should be set for allocation that will last seconds or minutes.
> >=20
> > If we have a flag that doesn't have a well defined meaning that actually
> > affects behavior, it will not be used consistently, and if we ever
> > change exactly how it behaves we can expect things to break.  So it is
> > better not to have a flag, than to have a poorly defined flag.
>=20
> Absolutely agreed!
>=20
> > My current thoughts is that the important criteria is not how long the
> > allocation will be used for, but whether it is reclaimable.  Allocations
> > that will only last 5 msecs are reclaimable by calling "usleep(5000)".
> > Other allocations might be reclaimable in other ways.  Allocations that
> > are not reclaimable may well be directed to a more restricted pool of
> > memory, and might be more likely to fail.  If we grew a strong
> > "reclaimable" concept, this 'temporary' concept that you want to hold on
> > to would become a burden.
>=20
> ... and here again. The whole motivation for the flag was to gather
> these objects together and reduce chances of internal fragmentation
> due to long lived objects mixed with short term ones. Without an
> explicit way to reclaim those objects or having a clear checkpoint to
> wait for it is not really helping us to reach desired outcome (less
> fragmented memory).

Really?

If you group allocations that last << 1 second, and ones that last >>
1 second, I'm pretty sure it reduces fragmentation... "reclaimable" or
not.

Fragmentation is just statistical property, so getting it "mostly
right" helps...
									Pavel
--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--7JfCtLOvnd9MIVvH
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlmn0coACgkQMOfwapXb+vKB3ACgsaMOYnU3F5LcM1YWol29ktOJ
bR0An1CuNVDysTgsCgtozbk6hV2a+EGh
=qqGb
-----END PGP SIGNATURE-----

--7JfCtLOvnd9MIVvH--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
