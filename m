Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id 58BDA6B004D
	for <linux-mm@kvack.org>; Tue, 13 Nov 2012 05:16:25 -0500 (EST)
Received: by mail-ee0-f41.google.com with SMTP id c4so4813694eek.14
        for <linux-mm@kvack.org>; Tue, 13 Nov 2012 02:16:23 -0800 (PST)
From: Michal Nazarewicz <mina86@mina86.com>
Subject: Re: [PATCH v2] mm: cma: WARN if freed memory is still in use
In-Reply-To: <1352789271-18461-1-git-send-email-m.szyprowski@samsung.com>
References: <xa1t8va6zsad.fsf@mina86.com> <1352789271-18461-1-git-send-email-m.szyprowski@samsung.com>
Date: Tue, 13 Nov 2012 11:16:15 +0100
Message-ID: <xa1t1ufxx0y8.fsf@mina86.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="=-=-="
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, linux-kernel@vger.kernel.org
Cc: Kyungmin Park <kyungmin.park@samsung.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Minchan Kim <minchan@kernel.org>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>

--=-=-=
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On Tue, Nov 13 2012, Marek Szyprowski <m.szyprowski@samsung.com> wrote:
> Memory returned to free_contig_range() must have no other references. Let
> kernel to complain loudly if page reference count is not equal to 1.
>
> Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
> Reviewed-by: Kyungmin Park <kyungmin.park@samsung.com>
> CC: Michal Nazarewicz <mina86@mina86.com>

Acked-by: Michal Nazarewicz <mina86@mina86.com>

> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 022e4ed..290c2eb 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -5888,8 +5888,13 @@ done:
>=20=20
>  void free_contig_range(unsigned long pfn, unsigned nr_pages)
>  {
> -	for (; nr_pages--; ++pfn)
> -		__free_page(pfn_to_page(pfn));
> +	struct page *page =3D pfn_to_page(pfn);
> +	int count =3D 0;
> +	for (; nr_pages--; page++) {
> +		count +=3D page_count(page) !=3D 1;
> +		__free_page(page);
> +	}
> +	WARN(count !=3D 0, "%d pages are still in use!\n", count);
>  }
>  #endif

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

iQIcBAEBAgAGBQJQoh3vAAoJECBgQBJQdR/0SG4P/2CxtT06r7NeIycdwd6P2Dm/
038uolt5sSF4hrs1S7z6ydmsjek8Grh5DaTO1uZWWYnRjOdUyUqpTX00Un/btuUW
ET/PcK9IVHpYpliHeykCRzdMoyloISUXWs0Ahk2gz5HO6Gfq/W4FU4C3EWFee2xU
yXkPynaU/PAPvcmBCZmPlH2XzufOhzcj++F9Rve7YBaFaew/LiiZzV60YcxspaNB
S0hP7tYP+rMLayXUdoYcg0abFs9jZpcXVlKtmwtsvFHpYPVeUQknh0BWdLwv6FYG
voDJfNDgQglv/xhZct9TQ9ujmaL9Yeg2Hu+Dz8l3IPI+Mcfyy8wL9cSmpIA4TidT
POg4/wK90YPZGkzYuzBOZCHqKDjnNA1s+Y2ylTjwi8e1FClNNQwB2PYPxJggb3/G
aJWVCEDXmQPMv2xQQOd5kYSb+OC85RZ8rLpSokHRbLbPNuuf7U54zUQoTSY1QCRQ
1gAZPCZASkGW3wFxbqa0ilTvaNMCutVGFRP+cYwEIN/iEPPnNVb46jpk/QDuVtDj
Zq/p3NzJa10r4bb+1qXHBlMgN4JBaTS0r/hGKZj9J71WL/t0Iir/72vepWuol8uW
WqEH5vZokKBGrFQDUhnBqgcfC5icXvyWnqmvGFQ4IN1DJIFmmg8mcmtTeNVPk4J5
HuABAVTXP2aZQASs5e6e
=QYe1
-----END PGP SIGNATURE-----
--==-=-=--

--=-=-=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
