Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f53.google.com (mail-wg0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id 48309280267
	for <linux-mm@kvack.org>; Wed, 15 Jul 2015 08:03:37 -0400 (EDT)
Received: by wgmn9 with SMTP id n9so31821406wgm.0
        for <linux-mm@kvack.org>; Wed, 15 Jul 2015 05:03:36 -0700 (PDT)
Received: from mail-wi0-x22d.google.com (mail-wi0-x22d.google.com. [2a00:1450:400c:c05::22d])
        by mx.google.com with ESMTPS id d2si7503406wjw.157.2015.07.15.05.03.35
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Jul 2015 05:03:35 -0700 (PDT)
Received: by wibud3 with SMTP id ud3so166548wib.1
        for <linux-mm@kvack.org>; Wed, 15 Jul 2015 05:03:34 -0700 (PDT)
From: Michal Nazarewicz <mina86@mina86.com>
Subject: Re: [PATCH 2/2] mm/cma_debug: correct size input to bitmap function
In-Reply-To: <1436942129-18020-2-git-send-email-iamjoonsoo.kim@lge.com>
References: <1436942129-18020-1-git-send-email-iamjoonsoo.kim@lge.com> <1436942129-18020-2-git-send-email-iamjoonsoo.kim@lge.com>
Date: Wed, 15 Jul 2015 14:03:32 +0200
Message-ID: <xa1t1tg9fx0r.fsf@mina86.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Sasha Levin <sasha.levin@oracle.com>, Stefan Strogin <stefan.strogin@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On Wed, Jul 15 2015, Joonsoo Kim wrote:
> In CMA, 1 bit in bitmap means 1 << order_per_bits pages so
> size of bitmap is cma->count >> order_per_bits rather than
> just cma->count. This patch fixes it.
>
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Acked-by: Michal Nazarewicz <mina86@mina86.com>

> ---
>  mm/cma_debug.c | 7 ++++---
>  1 file changed, 4 insertions(+), 3 deletions(-)
>
> diff --git a/mm/cma_debug.c b/mm/cma_debug.c
> index 22190a7..f8e4b60 100644
> --- a/mm/cma_debug.c
> +++ b/mm/cma_debug.c
> @@ -39,7 +39,7 @@ static int cma_used_get(void *data, u64 *val)
>=20=20
>  	mutex_lock(&cma->lock);
>  	/* pages counter is smaller than sizeof(int) */
> -	used =3D bitmap_weight(cma->bitmap, (int)cma->count);
> +	used =3D bitmap_weight(cma->bitmap, (int)cma_bitmap_maxno(cma));
>  	mutex_unlock(&cma->lock);
>  	*val =3D (u64)used << cma->order_per_bit;
>=20=20
> @@ -52,13 +52,14 @@ static int cma_maxchunk_get(void *data, u64 *val)
>  	struct cma *cma =3D data;
>  	unsigned long maxchunk =3D 0;
>  	unsigned long start, end =3D 0;
> +	unsigned long bitmap_maxno =3D cma_bitmap_maxno(cma);
>=20=20
>  	mutex_lock(&cma->lock);
>  	for (;;) {
> -		start =3D find_next_zero_bit(cma->bitmap, cma->count, end);
> +		start =3D find_next_zero_bit(cma->bitmap, bitmap_maxno, end);
>  		if (start >=3D cma->count)
>  			break;
> -		end =3D find_next_bit(cma->bitmap, cma->count, start);
> +		end =3D find_next_bit(cma->bitmap, bitmap_maxno, start);
>  		maxchunk =3D max(end - start, maxchunk);
>  	}
>  	mutex_unlock(&cma->lock);
> --=20
> 1.9.1
>

--=20
Best regards,                                         _     _
.o. | Liege of Serenely Enlightened Majesty of      o' \,=3D./ `o
..o | Computer Science,  Micha=C5=82 =E2=80=9Cmina86=E2=80=9D Nazarewicz   =
 (o o)
ooo +--<mpn@google.com>--<xmpp:mina86@jabber.org>--ooO--(_)--Ooo--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
