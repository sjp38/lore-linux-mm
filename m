Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 97A096B025E
	for <linux-mm@kvack.org>; Wed, 28 Dec 2016 09:14:13 -0500 (EST)
Received: by mail-lf0-f72.google.com with SMTP id c13so127760199lfg.4
        for <linux-mm@kvack.org>; Wed, 28 Dec 2016 06:14:13 -0800 (PST)
Received: from mail-lf0-x22a.google.com (mail-lf0-x22a.google.com. [2a00:1450:4010:c07::22a])
        by mx.google.com with ESMTPS id 9si29100809lji.85.2016.12.28.06.14.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Dec 2016 06:14:11 -0800 (PST)
Received: by mail-lf0-x22a.google.com with SMTP id b14so204961102lfg.2
        for <linux-mm@kvack.org>; Wed, 28 Dec 2016 06:14:11 -0800 (PST)
From: Michal Nazarewicz <mina86@mina86.com>
Subject: Re: [PATCH] lib: bitmap: introduce bitmap_find_next_zero_area_and_size
In-Reply-To: <58634274.5060205@samsung.com>
References: <CGME20161226041809epcas5p1981244de55764c10f1a80d80346f3664@epcas5p1.samsung.com> <1482725891-10866-1-git-send-email-jaewon31.kim@samsung.com> <20161227100535.GB7662@dhcp22.suse.cz> <58634274.5060205@samsung.com>
Date: Wed, 28 Dec 2016 15:14:06 +0100
Message-ID: <xa1tk2ak6t01.fsf@mina86.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jaewon Kim <jaewon31.kim@samsung.com>, Michal Hocko <mhocko@kernel.org>
Cc: gregkh@linuxfoundation.org, akpm@linux-foundation.org, labbott@redhat.com, m.szyprowski@samsung.com, gregory.0xf0@gmail.com, laurent.pinchart@ideasonboard.com, akinobu.mita@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, jaewon31.kim@gmail.com

On Wed, Dec 28 2016, Jaewon Kim wrote:
> I did not add caller in this patch.
> I am using the patch in cma_alloc function like below to show
> available page status.
>
> +               printk("number of available pages: ");
> +               start =3D 0;
> +               for (;;) {
> +                       bitmap_no =3D bitmap_find_next_zero_area_and_size=
(cma->bitmap,
> +                                               cma->count, start, &nr);
> +                       if (bitmap_no >=3D cma->count)
> +                               break;
> +                       if (nr_total =3D=3D 0)
> +                               printk("%u", nr);
> +                       else
> +                               printk("+%u", nr);
> +                       nr_total +=3D nr;
> +                       start =3D bitmap_no + nr;
> +               }
> +               printk("=3D>%u pages, total: %lu pages\n", nr_total, cma-=
>count);

I would be happier should you find other existing places where this
function can be used.  With just one caller, I=E2=80=99m not convinced it is
worth it.

>>> Signed-off-by: Jaewon Kim <jaewon31.kim@samsung.com>

The code itself is good, so

Acked-by: Michal Nazarewicz <mina86@mina86.com>

and I=E2=80=99ll leave deciding whether it improves the kernel overall to
maintainers. ;)

>>> ---
>>>  include/linux/bitmap.h |  6 ++++++
>>>  lib/bitmap.c           | 25 +++++++++++++++++++++++++
>>>  2 files changed, 31 insertions(+)
>>>
>>> diff --git a/include/linux/bitmap.h b/include/linux/bitmap.h
>>> index 3b77588..b724a6c 100644
>>> --- a/include/linux/bitmap.h
>>> +++ b/include/linux/bitmap.h
>>> @@ -46,6 +46,7 @@
>>>   * bitmap_clear(dst, pos, nbits)		Clear specified bit area
>>>   * bitmap_find_next_zero_area(buf, len, pos, n, mask)	Find bit free ar=
ea
>>>   * bitmap_find_next_zero_area_off(buf, len, pos, n, mask)	as above
>>> + * bitmap_find_next_zero_area_and_size(buf, len, pos, n, mask)	Find bi=
t free area and its size
>>>   * bitmap_shift_right(dst, src, n, nbits)	*dst =3D *src >> n
>>>   * bitmap_shift_left(dst, src, n, nbits)	*dst =3D *src << n
>>>   * bitmap_remap(dst, src, old, new, nbits)	*dst =3D map(old, new)(src)
>>> @@ -123,6 +124,11 @@ extern unsigned long bitmap_find_next_zero_area_of=
f(unsigned long *map,
>>>  						    unsigned long align_mask,
>>>  						    unsigned long align_offset);
>>>=20=20
>>> +extern unsigned long bitmap_find_next_zero_area_and_size(unsigned long=
 *map,
>>> +							 unsigned long size,
>>> +							 unsigned long start,
>>> +							 unsigned int *nr);
>>> +
>>>  /**
>>>   * bitmap_find_next_zero_area - find a contiguous aligned zero area
>>>   * @map: The address to base the search on
>>> diff --git a/lib/bitmap.c b/lib/bitmap.c
>>> index 0b66f0e..d02817c 100644
>>> --- a/lib/bitmap.c
>>> +++ b/lib/bitmap.c
>>> @@ -332,6 +332,31 @@ unsigned long bitmap_find_next_zero_area_off(unsig=
ned long *map,
>>>  }
>>>  EXPORT_SYMBOL(bitmap_find_next_zero_area_off);
>>>=20=20
>>> +/**
>>> + * bitmap_find_next_zero_area_and_size - find a contiguous aligned zer=
o area
>>> + * @map: The address to base the search on
>>> + * @size: The bitmap size in bits
>>> + * @start: The bitnumber to start searching at
>>> + * @nr: The number of zeroed bits we've found
>>> + */
>>> +unsigned long bitmap_find_next_zero_area_and_size(unsigned long *map,
>>> +					     unsigned long size,
>>> +					     unsigned long start,
>>> +					     unsigned int *nr)
>>> +{
>>> +	unsigned long index, i;
>>> +
>>> +	*nr =3D 0;
>>> +	index =3D find_next_zero_bit(map, size, start);
>>> +
>>> +	if (index >=3D size)
>>> +		return index;

I would remove this check.  find_next_bit handles situation when index
=3D=3D size and without this early return, *nr is always set.

>>> +	i =3D find_next_bit(map, size, index);
>>> +	*nr =3D i - index;
>>> +	return index;
>>> +}
>>> +EXPORT_SYMBOL(bitmap_find_next_zero_area_and_size);
>>> +
>>>  /*
>>>   * Bitmap printing & parsing functions: first version by Nadia Yvette =
Chambers,
>>>   * second version by Paul Jackson, third by Joe Korty.
>>> --=20
>>> 1.9.1
>>>
>>> --
>>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>>> the body to majordomo@kvack.org.  For more info on Linux MM,
>>> see: http://www.linux-mm.org/ .
>>> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
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
