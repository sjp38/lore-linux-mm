Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f52.google.com (mail-la0-f52.google.com [209.85.215.52])
	by kanga.kvack.org (Postfix) with ESMTP id 188C06B0075
	for <linux-mm@kvack.org>; Wed,  5 Nov 2014 16:57:40 -0500 (EST)
Received: by mail-la0-f52.google.com with SMTP id pv20so1498961lab.39
        for <linux-mm@kvack.org>; Wed, 05 Nov 2014 13:57:39 -0800 (PST)
Received: from mail-la0-x235.google.com (mail-la0-x235.google.com. [2a00:1450:4010:c03::235])
        by mx.google.com with ESMTPS id j6si8431865laa.71.2014.11.05.13.57.38
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 05 Nov 2014 13:57:38 -0800 (PST)
Received: by mail-la0-f53.google.com with SMTP id mc6so1480112lab.40
        for <linux-mm@kvack.org>; Wed, 05 Nov 2014 13:57:38 -0800 (PST)
From: Michal Nazarewicz <mina86@mina86.com>
Subject: Re: [PATCH 1/2] lib: bitmap: Added alignment offset for bitmap_find_next_zero_area()
In-Reply-To: <1415218078-10078-1-git-send-email-gregory.0xf0@gmail.com>
References: <1415218078-10078-1-git-send-email-gregory.0xf0@gmail.com>
Date: Wed, 05 Nov 2014 22:57:34 +0100
Message-ID: <xa1ty4rpwbsh.fsf@mina86.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gregory Fong <gregory.0xf0@gmail.com>, linux-mm@kvack.org
Cc: linux-arm-kernel@lists.infradead.org, f.fainelli@gmail.com, Michal Nazarewicz <m.nazarewicz@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Rasmus Villemoes <linux@rasmusvillemoes.dk>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Masanari Iida <standby24x7@gmail.com>, open list <linux-kernel@vger.kernel.org>

On Wed, Nov 05 2014, Gregory Fong wrote:
> From: Michal Nazarewicz <m.nazarewicz@samsung.com>

Please change to mina86@mina86.com.  My Samsung address is no longer
valid.  Ditto on signed-off-by line.

>
> This commit adds a bitmap_find_next_zero_area_off() function which
> works like bitmap_find_next_zero_area() function expect it allows an
> offset to be specified when alignment is checked.  This lets caller
> request a bit such that its number plus the offset is aligned
> according to the mask.
>
> Signed-off-by: Michal Nazarewicz <m.nazarewicz@samsung.com>
> Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
> Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
> CC: Michal Nazarewicz <mina86@mina86.com>
> [gregory.0xf0@gmail.com: Retrieved from
> https://patchwork.linuxtv.org/patch/6254/ and updated documentation]
> Signed-off-by: Gregory Fong <gregory.0xf0@gmail.com>
> ---
>  include/linux/bitmap.h | 36 +++++++++++++++++++++++++++++++-----
>  lib/bitmap.c           | 24 +++++++++++++-----------
>  2 files changed, 44 insertions(+), 16 deletions(-)
>
> diff --git a/include/linux/bitmap.h b/include/linux/bitmap.h
> index e1c8d08..34e020c 100644
> --- a/include/linux/bitmap.h
> +++ b/include/linux/bitmap.h
> @@ -45,6 +45,7 @@
>   * bitmap_set(dst, pos, nbits)			Set specified bit area
>   * bitmap_clear(dst, pos, nbits)		Clear specified bit area
>   * bitmap_find_next_zero_area(buf, len, pos, n, mask)	Find bit free area
> + * bitmap_find_next_zero_area_off(buf, len, pos, n, mask)	as above
>   * bitmap_shift_right(dst, src, n, nbits)	*dst =3D *src >> n
>   * bitmap_shift_left(dst, src, n, nbits)	*dst =3D *src << n
>   * bitmap_remap(dst, src, old, new, nbits)	*dst =3D map(old, new)(src)
> @@ -114,11 +115,36 @@ extern int __bitmap_weight(const unsigned long *bit=
map, unsigned int nbits);
>=20=20
>  extern void bitmap_set(unsigned long *map, unsigned int start, int len);
>  extern void bitmap_clear(unsigned long *map, unsigned int start, int len=
);
> -extern unsigned long bitmap_find_next_zero_area(unsigned long *map,
> -					 unsigned long size,
> -					 unsigned long start,
> -					 unsigned int nr,
> -					 unsigned long align_mask);
> +
> +extern unsigned long bitmap_find_next_zero_area_off(unsigned long *map,
> +						    unsigned long size,
> +						    unsigned long start,
> +						    unsigned int nr,
> +						    unsigned long align_mask,
> +						    unsigned long align_offset);
> +
> +/**
> + * bitmap_find_next_zero_area - find a contiguous aligned zero area
> + * @map: The address to base the search on
> + * @size: The bitmap size in bits
> + * @start: The bitnumber to start searching at
> + * @nr: The number of zeroed bits we're looking for
> + * @align_mask: Alignment mask for zero area
> + *
> + * The @align_mask should be one less than a power of 2; the effect is t=
hat
> + * the bit offset of all zero areas this function finds is multiples of =
that
> + * power of 2. A @align_mask of 0 means no alignment is required.
> + */
> +static inline unsigned long
> +bitmap_find_next_zero_area(unsigned long *map,
> +			   unsigned long size,
> +			   unsigned long start,
> +			   unsigned int nr,
> +			   unsigned long align_mask)
> +{
> +	return bitmap_find_next_zero_area_off(map, size, start, nr,
> +					      align_mask, 0);
> +}
>=20=20
>  extern int bitmap_scnprintf(char *buf, unsigned int len,
>  			const unsigned long *src, int nbits);
> diff --git a/lib/bitmap.c b/lib/bitmap.c
> index b499ab6..969ae8f 100644
> --- a/lib/bitmap.c
> +++ b/lib/bitmap.c
> @@ -326,30 +326,32 @@ void bitmap_clear(unsigned long *map, unsigned int =
start, int len)
>  }
>  EXPORT_SYMBOL(bitmap_clear);
>=20=20
> -/*
> - * bitmap_find_next_zero_area - find a contiguous aligned zero area
> +/**
> + * bitmap_find_next_zero_area_off - find a contiguous aligned zero area
>   * @map: The address to base the search on
>   * @size: The bitmap size in bits
>   * @start: The bitnumber to start searching at
>   * @nr: The number of zeroed bits we're looking for
>   * @align_mask: Alignment mask for zero area
> + * @align_offset: Alignment offset for zero area.
>   *
>   * The @align_mask should be one less than a power of 2; the effect is t=
hat
> - * the bit offset of all zero areas this function finds is multiples of =
that
> - * power of 2. A @align_mask of 0 means no alignment is required.
> + * the bit offset of all zero areas this function finds plus @align_offs=
et
> + * is multiple of that power of 2.
>   */
> -unsigned long bitmap_find_next_zero_area(unsigned long *map,
> -					 unsigned long size,
> -					 unsigned long start,
> -					 unsigned int nr,
> -					 unsigned long align_mask)
> +unsigned long bitmap_find_next_zero_area_off(unsigned long *map,
> +					     unsigned long size,
> +					     unsigned long start,
> +					     unsigned int nr,
> +					     unsigned long align_mask,
> +					     unsigned long align_offset)
>  {
>  	unsigned long index, end, i;
>  again:
>  	index =3D find_next_zero_bit(map, size, start);
>=20=20
>  	/* Align allocation */
> -	index =3D __ALIGN_MASK(index, align_mask);
> +	index =3D __ALIGN_MASK(index + align_offset, align_mask) - align_offset;
>=20=20
>  	end =3D index + nr;
>  	if (end > size)
> @@ -361,7 +363,7 @@ again:
>  	}
>  	return index;
>  }
> -EXPORT_SYMBOL(bitmap_find_next_zero_area);
> +EXPORT_SYMBOL(bitmap_find_next_zero_area_off);
>=20=20
>  /*
>   * Bitmap printing & parsing functions: first version by Nadia Yvette Ch=
ambers,
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
