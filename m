Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f47.google.com (mail-la0-f47.google.com [209.85.215.47])
	by kanga.kvack.org (Postfix) with ESMTP id 42C9E6B0075
	for <linux-mm@kvack.org>; Wed,  5 Nov 2014 16:58:42 -0500 (EST)
Received: by mail-la0-f47.google.com with SMTP id gd6so1536039lab.34
        for <linux-mm@kvack.org>; Wed, 05 Nov 2014 13:58:41 -0800 (PST)
Received: from mail-lb0-x229.google.com (mail-lb0-x229.google.com. [2a00:1450:4010:c04::229])
        by mx.google.com with ESMTPS id ay3si8600163lbc.4.2014.11.05.13.58.41
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 05 Nov 2014 13:58:41 -0800 (PST)
Received: by mail-lb0-f169.google.com with SMTP id 10so1485918lbg.0
        for <linux-mm@kvack.org>; Wed, 05 Nov 2014 13:58:41 -0800 (PST)
From: Michal Nazarewicz <mina86@mina86.com>
Subject: Re: [PATCH 2/2] mm: cma: Align to physical address, not CMA region position
In-Reply-To: <1415218078-10078-2-git-send-email-gregory.0xf0@gmail.com>
References: <1415218078-10078-1-git-send-email-gregory.0xf0@gmail.com> <1415218078-10078-2-git-send-email-gregory.0xf0@gmail.com>
Date: Wed, 05 Nov 2014 22:58:37 +0100
Message-ID: <xa1tvbmtwbqq.fsf@mina86.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gregory Fong <gregory.0xf0@gmail.com>, linux-mm@kvack.org
Cc: linux-arm-kernel@lists.infradead.org, f.fainelli@gmail.com, Marek Szyprowski <m.szyprowski@samsung.com>, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Laurent Pinchart <laurent.pinchart+renesas@ideasonboard.com>, Laura Abbott <lauraa@codeaurora.org>, open list <linux-kernel@vger.kernel.org>

On Wed, Nov 05 2014, Gregory Fong wrote:
> The alignment in cma_alloc() was done w.r.t. the bitmap.  This is a
> problem when, for example:
>
> - a device requires 16M (order 12) alignment
> - the CMA region is not 16 M aligned
>
> In such a case, can result with the CMA region starting at, say,
> 0x2f800000 but any allocation you make from there will be aligned from
> there.  Requesting an allocation of 32 M with 16 M alignment will
> result in an allocation from 0x2f800000 to 0x31800000, which doesn't
> work very well if your strange device requires 16M alignment.
>
> Change to use bitmap_find_next_zero_area_off() to account for the
> difference in alignment at reserve-time and alloc-time.
>
> Cc: Michal Nazarewicz <mina86@mina86.com>

Acked-by: Michal Nazarewicz <mina86@mina86.com>

> Signed-off-by: Gregory Fong <gregory.0xf0@gmail.com>
> ---
>  mm/cma.c | 19 ++++++++++++++++---
>  1 file changed, 16 insertions(+), 3 deletions(-)
>
> diff --git a/mm/cma.c b/mm/cma.c
> index fde706e..0813599 100644
> --- a/mm/cma.c
> +++ b/mm/cma.c
> @@ -63,6 +63,17 @@ static unsigned long cma_bitmap_aligned_mask(struct cm=
a *cma, int align_order)
>  	return (1UL << (align_order - cma->order_per_bit)) - 1;
>  }
>=20=20
> +static unsigned long cma_bitmap_aligned_offset(struct cma *cma, int alig=
n_order)
> +{
> +	unsigned int alignment;
> +
> +	if (align_order <=3D cma->order_per_bit)
> +		return 0;
> +	alignment =3D 1UL << (align_order - cma->order_per_bit);
> +	return ALIGN(cma->base_pfn, alignment) -
> +		(cma->base_pfn >> cma->order_per_bit);
> +}
> +
>  static unsigned long cma_bitmap_maxno(struct cma *cma)
>  {
>  	return cma->count >> cma->order_per_bit;
> @@ -328,7 +339,7 @@ err:
>   */
>  struct page *cma_alloc(struct cma *cma, int count, unsigned int align)
>  {
> -	unsigned long mask, pfn, start =3D 0;
> +	unsigned long mask, offset, pfn, start =3D 0;
>  	unsigned long bitmap_maxno, bitmap_no, bitmap_count;
>  	struct page *page =3D NULL;
>  	int ret;
> @@ -343,13 +354,15 @@ struct page *cma_alloc(struct cma *cma, int count, =
unsigned int align)
>  		return NULL;
>=20=20
>  	mask =3D cma_bitmap_aligned_mask(cma, align);
> +	offset =3D cma_bitmap_aligned_offset(cma, align);
>  	bitmap_maxno =3D cma_bitmap_maxno(cma);
>  	bitmap_count =3D cma_bitmap_pages_to_bits(cma, count);
>=20=20
>  	for (;;) {
>  		mutex_lock(&cma->lock);
> -		bitmap_no =3D bitmap_find_next_zero_area(cma->bitmap,
> -				bitmap_maxno, start, bitmap_count, mask);
> +		bitmap_no =3D bitmap_find_next_zero_area_off(cma->bitmap,
> +				bitmap_maxno, start, bitmap_count, mask,
> +				offset);
>  		if (bitmap_no >=3D bitmap_maxno) {
>  			mutex_unlock(&cma->lock);
>  			break;
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
