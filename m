Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id 982716B004D
	for <linux-mm@kvack.org>; Wed, 21 Nov 2012 08:07:14 -0500 (EST)
Received: by mail-wi0-f173.google.com with SMTP id hm11so1504869wib.8
        for <linux-mm@kvack.org>; Wed, 21 Nov 2012 05:07:13 -0800 (PST)
From: Michal Nazarewicz <mina86@mina86.com>
Subject: Re: [PATCH] mm: cma: allocate pages from CMA if NR_FREE_PAGES approaches low water mark
In-Reply-To: <20121121010556.GD447@bbox>
References: <1352710782-25425-1-git-send-email-m.szyprowski@samsung.com> <20121120000137.GC447@bbox> <50AB987F.30002@samsung.com> <20121121010556.GD447@bbox>
Date: Wed, 21 Nov 2012 14:07:04 +0100
Message-ID: <xa1t7gpfgl53.fsf@mina86.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="=-=-="
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>, Marek Szyprowski <m.szyprowski@samsung.com>
Cc: linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, linux-kernel@vger.kernel.org, Kyungmin Park <kyungmin.park@samsung.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>

--=-=-=
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On Wed, Nov 21 2012, Minchan Kim wrote:
> So your concern is that too many free pages in MIGRATE_CMA when OOM happe=
ns
> is odd? It's natural with considering CMA design which kernel never fallb=
ack
> non-movable page allocation to CMA area. I guess it's not a your concern.
>
> Let's think below extreme cases.
>
> =3D Before =3D
>
> * 1000M DRAM system.
> * 400M kernel used pages.
> * 300M movable used pages.
> * 300M cma freed pages.
>
> 1. kernel want to request 400M non-movable memory, additionally.
> 2. VM start to reclaim 300M movable pages.
> 3. But it's not enough to meet 400M request.
> 4. go to OOM. (It's natural)
>
> =3D After(with your patch) =3D
>
> * 1000M DRAM system.
> * 400M kernel used pages.
> * 300M movable *freed* pages.
> * 300M cma used pages(by your patch, I simplified your concept)
>
> 1. kernel want to request 400M non-movable memory.
> 2. 300M movable freed pages isn't enough to meet 400M request.
> 3. Also, there is no point to reclaim CMA pages for non-movable allocatio=
n.
> 4. go to OOM. (It's natural)
>
> There is no difference between before and after in allocation POV.
> Let's think another example.
>
> =3D Before =3D
>
> * 1000M DRAM system.
> * 400M kernel used pages.
> * 300M movable used pages.
> * 300M cma freed pages.
>
> 1. kernel want to request 300M non-movable memory.
> 2. VM start to reclaim 300M movable pages.
> 3. It's enough to meet 300M request.
> 4. happy end
>
> =3D After(with your patch) =3D
>
> * 1000M DRAM system.
> * 400M kernel used pages.
> * 300M movable *freed* pages.
> * 300M cma used pages(by your patch, I simplified your concept)
>
> 1. kernel want to request 300M non-movable memory.
> 2. 300M movable freed pages is enough to meet 300M request.
> 3. happy end.
>
> There is no difference in allocation POV, too.

The difference thou is that before 30% of memory is wasted (ie. free),
whereas after all memory is used.  The main point of CMA is to make the
memory useful if devices are not using it.  Having it not allocated is
defeating that purpose.

--=20
Best regards,                                         _     _
.o. | Liege of Serenely Enlightened Majesty of      o' \,=3D./ `o
..o | Computer Science,  Micha=C5=82 =E2=80=9Cmina86=E2=80=9D Nazarewicz   =
 (o o)
ooo +----<email/xmpp: mpn@google.com>--------------ooO--(_)--Ooo--
--=-=-=
Content-Type: multipart/signed; boundary="==-=-=";
	micalg=pgp-sha1; protocol="application/pgp-signature"

--==-=-=
Content-Type: text/plain


--==-=-=
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBAgAGBQJQrNH5AAoJECBgQBJQdR/0HxIP/2enYW5oBYHD39pEIHzQq7zd
oYiUlYBNFFtrbqmplZ15ik+zPGvasFtkl2pvpurFcbRhfE0ZCo7D/MNkDKqMfxcH
nEIkIjkb/XRH2t8Fx5vcjAJgsFdJLGmuXjOD4TNnXiTJjj9i19Kj9ytOPneqoBEK
I2Evv6itOO1UISujo9/NKHlLFmIaCRDnqRp/wXYfqNytIog22BXB8OHcTRMIaD/Q
WKSeEKOkWpftLoOfQ8SW3FCQhOILlwgC5kFk9DpEqANwR8T3OY6O/VNR0Ef0i+Zq
VWerm0s1mne5tZvcmMkLaPjAnwIdRe9EIuFLIcP1nkTJd5Ujo1WTgkslFV+BenCI
hMx925+HJPR3CleKAgHcrOehwM5Sl2ZZLwKn89rWFO0xPzEyPIo1iaUZYygLL9Ip
pIGuhVq5pqxcqMIQ92qg8CHZdFPk3MXAWR+Iq4Q/6lDOQbHbUqwUV9YTs0yuC8wI
VUOEt6OMqvNqxTY+QuAt9D93kDHAPzC3V1tG2f81Lf8pX12YMleRapWycaztTdlr
9q8VpFIgeUgvZwLYu1uxIB5b7LRjalmmuuLPFR3vUSMOkWqzWcxdqE/ynrBBMB1Y
nXajqOWgZZdgLiTKekJF1RhpmTIPpJN4jtbeuw2pATTPbrxjMo6rDV4Ji2V5u0S9
JvU43xmWTd63QZxZqWKG
=YdG9
-----END PGP SIGNATURE-----
--==-=-=--

--=-=-=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
