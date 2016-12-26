Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1AE036B0038
	for <linux-mm@kvack.org>; Mon, 26 Dec 2016 16:09:47 -0500 (EST)
Received: by mail-lf0-f71.google.com with SMTP id y21so110947005lfa.0
        for <linux-mm@kvack.org>; Mon, 26 Dec 2016 13:09:47 -0800 (PST)
Received: from mail-lf0-x234.google.com (mail-lf0-x234.google.com. [2a00:1450:4010:c07::234])
        by mx.google.com with ESMTPS id z187si25480358lfa.420.2016.12.26.13.09.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Dec 2016 13:09:45 -0800 (PST)
Received: by mail-lf0-x234.google.com with SMTP id t196so178158861lff.3
        for <linux-mm@kvack.org>; Mon, 26 Dec 2016 13:09:45 -0800 (PST)
From: Michal Nazarewicz <mina86@mina86.com>
Subject: Re: [PATCH] lib: bitmap: introduce bitmap_find_next_zero_area_and_size
In-Reply-To: <1482725891-10866-1-git-send-email-jaewon31.kim@samsung.com>
References: <CGME20161226041809epcas5p1981244de55764c10f1a80d80346f3664@epcas5p1.samsung.com> <1482725891-10866-1-git-send-email-jaewon31.kim@samsung.com>
Date: Mon, 26 Dec 2016 22:09:40 +0100
Message-ID: <xa1tpokev1m3.fsf@mina86.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jaewon Kim <jaewon31.kim@samsung.com>, gregkh@linuxfoundation.org, akpm@linux-foundation.org
Cc: labbott@redhat.com, m.szyprowski@samsung.com, gregory.0xf0@gmail.com, laurent.pinchart@ideasonboard.com, akinobu.mita@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, jaewon31.kim@gmail.com

On Mon, Dec 26 2016, Jaewon Kim wrote:
> There was no bitmap API which returns both next zero index and size of ze=
ros
> from that index.

Is it really needed?  Does it noticeably simplifies callers?  Why can=E2=80=
=99t
caller get the size by themselves if they need it?

>
> This is helpful to look fragmentation. This is an test code to look size =
of zeros.
> Test result is '10+9+994=3D>1013 found of total: 1024'
>
> unsigned long search_idx, found_idx, nr_found_tot;
> unsigned long bitmap_max;
> unsigned int nr_found;
> unsigned long *bitmap;
>
> search_idx =3D nr_found_tot =3D 0;
> bitmap_max =3D 1024;
> bitmap =3D kzalloc(BITS_TO_LONGS(bitmap_max) * sizeof(long),
> 		 GFP_KERNEL);
>
> /* test bitmap_set offset, count */
> bitmap_set(bitmap, 10, 1);
> bitmap_set(bitmap, 20, 10);
>
> for (;;) {
> 	found_idx =3D bitmap_find_next_zero_area_and_size(bitmap,
> 				bitmap_max, search_idx, &nr_found);
> 	if (found_idx >=3D bitmap_max)
> 		break;
> 	if (nr_found_tot =3D=3D 0)
> 		printk("%u", nr_found);
> 	else
> 		printk("+%u", nr_found);
> 	nr_found_tot +=3D nr_found;
> 	search_idx =3D found_idx + nr_found;
> }
> printk("=3D>%lu found of total: %lu\n", nr_found_tot, bitmap_max);
>
> Signed-off-by: Jaewon Kim <jaewon31.kim@samsung.com>
> ---
>  include/linux/bitmap.h |  6 ++++++
>  lib/bitmap.c           | 25 +++++++++++++++++++++++++
>  2 files changed, 31 insertions(+)
>
> diff --git a/include/linux/bitmap.h b/include/linux/bitmap.h
> index 3b77588..b724a6c 100644
> --- a/include/linux/bitmap.h
> +++ b/include/linux/bitmap.h
> @@ -46,6 +46,7 @@
>   * bitmap_clear(dst, pos, nbits)		Clear specified bit area
>   * bitmap_find_next_zero_area(buf, len, pos, n, mask)	Find bit free area
>   * bitmap_find_next_zero_area_off(buf, len, pos, n, mask)	as above
> + * bitmap_find_next_zero_area_and_size(buf, len, pos, n, mask)	Find bit =
free area and its size
>   * bitmap_shift_right(dst, src, n, nbits)	*dst =3D *src >> n
>   * bitmap_shift_left(dst, src, n, nbits)	*dst =3D *src << n
>   * bitmap_remap(dst, src, old, new, nbits)	*dst =3D map(old, new)(src)
> @@ -123,6 +124,11 @@ extern unsigned long bitmap_find_next_zero_area_off(=
unsigned long *map,
>  						    unsigned long align_mask,
>  						    unsigned long align_offset);
>=20=20
> +extern unsigned long bitmap_find_next_zero_area_and_size(unsigned long *=
map,
> +							 unsigned long size,
> +							 unsigned long start,
> +							 unsigned int *nr);
> +
>  /**
>   * bitmap_find_next_zero_area - find a contiguous aligned zero area
>   * @map: The address to base the search on
> diff --git a/lib/bitmap.c b/lib/bitmap.c
> index 0b66f0e..d02817c 100644
> --- a/lib/bitmap.c
> +++ b/lib/bitmap.c
> @@ -332,6 +332,31 @@ unsigned long bitmap_find_next_zero_area_off(unsigne=
d long *map,
>  }
>  EXPORT_SYMBOL(bitmap_find_next_zero_area_off);
>=20=20
> +/**
> + * bitmap_find_next_zero_area_and_size - find a contiguous aligned zero =
area
> + * @map: The address to base the search on
> + * @size: The bitmap size in bits
> + * @start: The bitnumber to start searching at
> + * @nr: The number of zeroed bits we've found
> + */
> +unsigned long bitmap_find_next_zero_area_and_size(unsigned long *map,
> +					     unsigned long size,
> +					     unsigned long start,
> +					     unsigned int *nr)
> +{
> +	unsigned long index, i;
> +
> +	*nr =3D 0;
> +	index =3D find_next_zero_bit(map, size, start);
> +
> +	if (index >=3D size)
> +		return index;
> +	i =3D find_next_bit(map, size, index);
> +	*nr =3D i - index;
> +	return index;
> +}
> +EXPORT_SYMBOL(bitmap_find_next_zero_area_and_size);
> +
>  /*
>   * Bitmap printing & parsing functions: first version by Nadia Yvette Ch=
ambers,
>   * second version by Paul Jackson, third by Joe Korty.
> --=20
> 1.9.1
>

--=20
Best regards
=E3=83=9F=E3=83=8F=E3=82=A6 =E2=80=9C=F0=9D=93=B6=F0=9D=93=B2=F0=9D=93=B7=
=F0=9D=93=AA86=E2=80=9D =E3=83=8A=E3=82=B6=E3=83=AC=E3=83=B4=E3=82=A4=E3=83=
=84
=C2=ABIf at first you don=E2=80=99t succeed, give up skydiving=C2=BB

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
