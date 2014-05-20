Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 229086B0035
	for <linux-mm@kvack.org>; Tue, 20 May 2014 14:22:13 -0400 (EDT)
Received: by mail-pd0-f177.google.com with SMTP id g10so548841pdj.36
        for <linux-mm@kvack.org>; Tue, 20 May 2014 11:22:12 -0700 (PDT)
Received: from mail-pd0-x230.google.com (mail-pd0-x230.google.com [2607:f8b0:400e:c02::230])
        by mx.google.com with ESMTPS id ih3si2870691pbc.92.2014.05.20.11.22.11
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 20 May 2014 11:22:12 -0700 (PDT)
Received: by mail-pd0-f176.google.com with SMTP id p10so554034pdj.21
        for <linux-mm@kvack.org>; Tue, 20 May 2014 11:22:11 -0700 (PDT)
From: Michal Nazarewicz <mina86@mina86.com>
Subject: Re: [RFC PATCH] arm: dma-mapping: fallback allocation for cma failure
In-Reply-To: <20140520065222.GB8315@js1304-P5Q-DELUXE>
References: <537AEEDB.2000001@lge.com> <20140520065222.GB8315@js1304-P5Q-DELUXE>
Date: Tue, 20 May 2014 08:22:03 -1000
Message-ID: <xa1t1tvo1fas.fsf@mina86.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="=-=-="
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Gioh Kim <gioh.kim@lge.com>
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Heesub Shin <heesub.shin@samsung.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, =?utf-8?B?7J206rG07Zi4?= <gunho.lee@lge.com>

--=-=-=
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On Mon, May 19 2014, Joonsoo Kim wrote:
> On Tue, May 20, 2014 at 02:57:47PM +0900, Gioh Kim wrote:
>>=20
>> Thanks for your advise, Michal Nazarewicz.
>>=20
>> Having discuss with Joonsoo, I'm adding fallback allocation after __allo=
c_from_contiguous().
>> The fallback allocation works if CMA kernel options is turned on but CMA=
 size is zero.
>
> Hello, Gioh.
>
> I also mentioned the case where devices have their specific cma_area.
> It means that this device needs memory with some contraint.
> Although I'm not familiar with DMA infrastructure, I think that
> we should handle this case.
>
> How about below patch?
>
> ------------>8----------------
> diff --git a/arch/arm/mm/dma-mapping.c b/arch/arm/mm/dma-mapping.c
> index 6b00be1..4023434 100644
> --- a/arch/arm/mm/dma-mapping.c
> +++ b/arch/arm/mm/dma-mapping.c
> @@ -379,7 +379,7 @@ static int __init atomic_pool_init(void)
>  	unsigned long *bitmap;
>  	struct page *page;
>  	struct page **pages;
> -	void *ptr;
> +	void *ptr =3D NULL;
>  	int bitmap_size =3D BITS_TO_LONGS(nr_pages) * sizeof(long);
>=20=20
>  	bitmap =3D kzalloc(bitmap_size, GFP_KERNEL);
> @@ -393,7 +393,8 @@ static int __init atomic_pool_init(void)
>  	if (IS_ENABLED(CONFIG_DMA_CMA))
>  		ptr =3D __alloc_from_contiguous(NULL, pool->size, prot, &page,
>  					      atomic_pool_init);
> -	else
> +
> +	if (!ptr)
>  		ptr =3D __alloc_remap_buffer(NULL, pool->size, gfp, prot, &page,
>  					   atomic_pool_init);
>  	if (ptr) {
> @@ -701,10 +702,22 @@ static void *__dma_alloc(struct device *dev, size_t=
 size, dma_addr_t *handle,
>  		addr =3D __alloc_simple_buffer(dev, size, gfp, &page);
>  	else if (!(gfp & __GFP_WAIT))
>  		addr =3D __alloc_from_pool(size, &page);
> -	else if (!IS_ENABLED(CONFIG_DMA_CMA))
> -		addr =3D __alloc_remap_buffer(dev, size, gfp, prot, &page, caller);
> -	else
> -		addr =3D __alloc_from_contiguous(dev, size, prot, &page, caller);
> +	else {
> +		if (IS_ENABLED(CONFIG_DMA_CMA)) {
> +			addr =3D __alloc_from_contiguous(dev, size, prot,
> +							&page, caller);
> +			/*
> +			 * Device specific cma_area means that
> +			 * this device needs memory with some contraint.
> +			 * So, we can't fall through general remap allocation.
> +			 */
> +			if (!addr && dev && dev->cma_area)
> +				return NULL;
> +		}
> +
> +		addr =3D __alloc_remap_buffer(dev, size, gfp, prot,
> +							&page, caller);
> +	}

__arm_dma_free will have to be changed to handle the fallback as well.
But perhaps Marek is right and there should be no fallback for regular
allocations?  Than again, non-CMA allocation should be performed at
least in the case of cma=3D0.

>=20=20
>  	if (addr)
>  		*handle =3D pfn_to_dma(dev, page_to_pfn(page));

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

iQIcBAEBAgAGBQJTe51LAAoJECBgQBJQdR/0B0MP/3Y/5qZHfrGJSRFSt1EptW/O
ouN3jfn5gmpA3EP1V9VDmNgZdndJSAsceEJjKCvLZDytWgeERIsvL66XqObiFexX
qCsZqRXar6ku2qoBNEleSdbj2EtOLJdvJeUE6GJGWBxHS2IWIh7WS69aM6kZlnnp
+APryGRj6fS9Qu9Zhh/85iN/QUCBK+zQCI57KXu5or5f1Q/gdLFhlviRTGQMcsdN
VgctGvfUTfuWvCaxhCNQPD51Zpl6f7AjsHC9VOaIjK7w1RgJE5uSzqkU2WL4mhys
0B5ug4zp5fZLCdb906bNgA7IgvX5mIIpT4TkPS0jvJr8x9fNKezPCpfOnYe79z6L
Ep7ASEVfd7lFOU53gRhKAqqD6DQ0IMndPNQT00cjMpoBLSSzOlifmqN+vgf3BEdU
8yh9fCNqH7iUOA56CyZodQdvmoSoR34W7vr1e0H3EUYQmkGUo3JT16u6nV6lit8o
yQ8uN5sMMndMs1BprTvQRKR6m8saITJ+Z/NPF7xm9WFEFM+6c1fi8T8fN8SNiOyX
oKnQ4mSpzvPqTI6ooC/6Oszv0dfDQX0dS2nVI6td6wBNrVozSWzyg62WMdRKDTOf
Re54LS30uK3BaCZ9UvmWgXmgVhZgv13clPcXr9l667of535XK1MBhDzN2Cc85Ow/
83X+iZlJYUrBXkH3hq+J
=oklM
-----END PGP SIGNATURE-----
--==-=-=--

--=-=-=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
