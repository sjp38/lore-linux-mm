Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f46.google.com (mail-wg0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id 8EAC16B006E
	for <linux-mm@kvack.org>; Tue, 24 Feb 2015 16:10:33 -0500 (EST)
Received: by wggy19 with SMTP id y19so7978914wgg.13
        for <linux-mm@kvack.org>; Tue, 24 Feb 2015 13:10:33 -0800 (PST)
Received: from mail-wi0-x234.google.com (mail-wi0-x234.google.com. [2a00:1450:400c:c05::234])
        by mx.google.com with ESMTPS id p8si69491207wjy.134.2015.02.24.13.10.31
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Feb 2015 13:10:32 -0800 (PST)
Received: by mail-wi0-f180.google.com with SMTP id h11so467589wiw.1
        for <linux-mm@kvack.org>; Tue, 24 Feb 2015 13:10:31 -0800 (PST)
From: Michal Nazarewicz <mina86@mina86.com>
Subject: Re: [PATCH] mm: cma: fix CMA aligned offset calculation
In-Reply-To: <1424807759-23311-1-git-send-email-dpetigara@broadcom.com>
References: <1424807759-23311-1-git-send-email-dpetigara@broadcom.com>
Date: Tue, 24 Feb 2015 22:10:28 +0100
Message-ID: <xa1twq37ow1n.fsf@mina86.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Danesh Petigara <dpetigara@broadcom.com>, akpm@linux-foundation.org
Cc: m.szyprowski@samsung.com, iamjoonsoo.kim@lge.com, aneesh.kumar@linux.vnet.ibm.com, laurent.pinchart+renesas@ideasonboard.com, gregory.0xf0@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, stable@vger.kernel.org

On Tue, Feb 24 2015, Danesh Petigara <dpetigara@broadcom.com> wrote:
> The CMA aligned offset calculation is incorrect for
> non-zero order_per_bit values.
>
> For example, if cma->order_per_bit=3D1, cma->base_pfn=3D
> 0x2f800000 and align_order=3D12, the function returns
> a value of 0x17c00 instead of 0x400.
>
> This patch fixes the CMA aligned offset calculation.
>
> Cc: stable@vger.kernel.org
> Signed-off-by: Danesh Petigara <dpetigara@broadcom.com>
> Reviewed-by: Gregory Fong <gregory.0xf0@gmail.com>

Acked-by: Michal Nazarewicz <mina86@mina86.com>

> ---
>  mm/cma.c | 10 +++++++---
>  1 file changed, 7 insertions(+), 3 deletions(-)
>
> diff --git a/mm/cma.c b/mm/cma.c
> index 75016fd..58f37bd 100644
> --- a/mm/cma.c
> +++ b/mm/cma.c
> @@ -70,9 +70,13 @@ static unsigned long cma_bitmap_aligned_offset(struct =
cma *cma, int align_order)
>=20=20
>  	if (align_order <=3D cma->order_per_bit)
>  		return 0;
> -	alignment =3D 1UL << (align_order - cma->order_per_bit);
> -	return ALIGN(cma->base_pfn, alignment) -
> -		(cma->base_pfn >> cma->order_per_bit);
> +
> +	/*
> +	 * Find a PFN aligned to the specified order and return
> +	 * an offset represented in order_per_bits.
> +	 */

It probably makes sense to move this comment outside of the function as
function documentation.

> +	return (ALIGN(cma->base_pfn, (1UL << align_order))
> +		- cma->base_pfn) >> cma->order_per_bit;
>  }
>=20=20
>  static unsigned long cma_bitmap_maxno(struct cma *cma)
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
