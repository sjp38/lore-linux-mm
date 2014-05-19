Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 04E676B0038
	for <linux-mm@kvack.org>; Mon, 19 May 2014 15:59:33 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id lj1so6250102pab.28
        for <linux-mm@kvack.org>; Mon, 19 May 2014 12:59:33 -0700 (PDT)
Received: from mail-pa0-x236.google.com (mail-pa0-x236.google.com [2607:f8b0:400e:c03::236])
        by mx.google.com with ESMTPS id yv2si20936517pac.23.2014.05.19.12.59.31
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 19 May 2014 12:59:31 -0700 (PDT)
Received: by mail-pa0-f54.google.com with SMTP id bj1so6188997pad.41
        for <linux-mm@kvack.org>; Mon, 19 May 2014 12:59:31 -0700 (PDT)
From: Michal Nazarewicz <mina86@mina86.com>
Subject: Re: [RFC][PATCH] CMA: drivers/base/Kconfig: restrict CMA size to non-zero value
In-Reply-To: <20140519055527.GA24099@js1304-P5Q-DELUXE>
References: <1399509144-8898-1-git-send-email-iamjoonsoo.kim@lge.com> <1399509144-8898-3-git-send-email-iamjoonsoo.kim@lge.com> <20140513030057.GC32092@bbox> <20140515015301.GA10116@js1304-P5Q-DELUXE> <5375C619.8010501@lge.com> <xa1tppjdfwif.fsf@mina86.com> <537962A0.4090600@lge.com> <20140519055527.GA24099@js1304-P5Q-DELUXE>
Date: Mon, 19 May 2014 09:59:22 -1000
Message-ID: <xa1td2f91qw5.fsf@mina86.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="=-=-="
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Gioh Kim <gioh.kim@lge.com>
Cc: Minchan Kim <minchan.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Laura Abbott <lauraa@codeaurora.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Heesub Shin <heesub.shin@samsung.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Marek Szyprowski <m.szyprowski@samsung.com>, =?utf-8?B?7J206rG07Zi4?= <gunho.lee@lge.com>, gurugio@gmail.com

--=-=-=
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On Sun, May 18 2014, Joonsoo Kim wrote:
> I think that this problem is originated from atomic_pool_init().
> If configured coherent_pool size is larger than default cma size,
> it can be failed even if this patch is applied.
>
> How about below patch?
> It uses fallback allocation if CMA is failed.

Yes, I thought about it, but __dma_alloc uses similar code:

	else if (!IS_ENABLED(CONFIG_DMA_CMA))
		addr =3D __alloc_remap_buffer(dev, size, gfp, prot, &page, caller);
	else
		addr =3D __alloc_from_contiguous(dev, size, prot, &page, caller);

so it probably needs to be changed as well.

> -----------------8<---------------------
> diff --git a/arch/arm/mm/dma-mapping.c b/arch/arm/mm/dma-mapping.c
> index 6b00be1..2909ab9 100644
> --- a/arch/arm/mm/dma-mapping.c
> +++ b/arch/arm/mm/dma-mapping.c
> @@ -379,7 +379,7 @@ static int __init atomic_pool_init(void)
>         unsigned long *bitmap;
>         struct page *page;
>         struct page **pages;
> -       void *ptr;
> +       void *ptr =3D NULL;
>         int bitmap_size =3D BITS_TO_LONGS(nr_pages) * sizeof(long);
>=20=20
>         bitmap =3D kzalloc(bitmap_size, GFP_KERNEL);
> @@ -393,7 +393,7 @@ static int __init atomic_pool_init(void)
>         if (IS_ENABLED(CONFIG_DMA_CMA))
>                 ptr =3D __alloc_from_contiguous(NULL, pool->size, prot, &=
page,
>                                               atomic_pool_init);
> -       else
> +       if (!ptr)
>                 ptr =3D __alloc_remap_buffer(NULL, pool->size, gfp, prot,=
 &page,
>                                            atomic_pool_init);
>         if (ptr) {
>

--=20
Best regards,                                         _     _
.o. | Liege of Serenely Enlightened Majesty of      o' \,=3D./ `o
..o | Computer Science,  Micha=C5=82 =E2=80=9Cmina86=E2=80=9D Nazarewicz   =
 (o o)
ooo +--<mpn@google.com>--<xmpp:mina86@jabber.org>--ooO--(_)--Ooo--

--=-=-=
Content-Type: multipart/signed; boundary="==-=-=";
	micalg=pgp-sha1; protocol="application/pgp-signature"

--==-=-=
Content-Type: text/plain


--==-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBAgAGBQJTemKaAAoJECBgQBJQdR/0o2UP/2G4b+KPDsHmMb6HsfXWyaPP
cm0tokTR/UKmMO68Pb6Wgsokt34/aS6KCHrVHqni7lxtuR0Zb28gdQaLcya2Lb0S
lhlaoEQcElAUfxTVLAUChlb4L6TZcf7dUOPN317rqepvOp7K98FNENqWhyK5hkSC
5H+SYCB+7rn3+4ApQ/xFL7XCoA7C85qsxnZEa35R/FMVI2zv70xcLIakiV/4XZ3W
eXBsHEj7X1ZRnIBAARA2VBzMaMMAhAUYzSRwTSP+gBqJ53M4bae7FX7Kml81U4ra
V3VtWt78hZ+fY3hljuIPFmICV6vRsbv7Opg2TQHbU5ekKf8Mr8Y+D8Xo/U6hugv+
SjdcC8+Edsa0m4bO6Blhz4GM5eHoX7cOxmyDxIPuGAPRZeiDdmTvduSzfvd6oDZ+
9QvSLi41co0SdSrOuSpc3gtqmIOkFZ3vhgycmZAXmbdI96rq29VB/deqFGaUorgw
X24ENPlMxH2Z/84KV3EAQM+pR2MHZIesxB/7hRbaHVRKCD/wZ1MrtCbg4RAPceSA
1Lyyzsr68yAlcteyA+HxLQAeGh2fwfJ8Bz6iIJR1pBFdeBUj+T6l+cgz8N1YM5HE
dnijLmb6u70SvMAAvhRd0EITICXTHhb2xlhXfiT+jwJfw6+iiYNK3jTP7HNNA7BW
UiWN72LDf6SF0tvtqSm/
=uOv/
-----END PGP SIGNATURE-----
--==-=-=--

--=-=-=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
