Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f179.google.com (mail-lb0-f179.google.com [209.85.217.179])
	by kanga.kvack.org (Postfix) with ESMTP id 06F2A6B0069
	for <linux-mm@kvack.org>; Thu, 23 Oct 2014 12:55:26 -0400 (EDT)
Received: by mail-lb0-f179.google.com with SMTP id l4so1170346lbv.24
        for <linux-mm@kvack.org>; Thu, 23 Oct 2014 09:55:26 -0700 (PDT)
Received: from mail-lb0-x22a.google.com (mail-lb0-x22a.google.com. [2a00:1450:4010:c04::22a])
        by mx.google.com with ESMTPS id ay3si3562223lbc.4.2014.10.23.09.55.25
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 23 Oct 2014 09:55:25 -0700 (PDT)
Received: by mail-lb0-f170.google.com with SMTP id u10so1430166lbd.1
        for <linux-mm@kvack.org>; Thu, 23 Oct 2014 09:55:24 -0700 (PDT)
From: Michal Nazarewicz <mina86@mina86.com>
Subject: Re: [PATCH 2/4] mm: cma: Always consider a 0 base address reservation as dynamic
In-Reply-To: <1414074828-4488-3-git-send-email-laurent.pinchart+renesas@ideasonboard.com>
References: <1414074828-4488-1-git-send-email-laurent.pinchart+renesas@ideasonboard.com> <1414074828-4488-3-git-send-email-laurent.pinchart+renesas@ideasonboard.com>
Date: Thu, 23 Oct 2014 18:55:20 +0200
Message-ID: <xa1tk33qlo93.fsf@mina86.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Pinchart <laurent.pinchart+renesas@ideasonboard.com>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-sh@vger.kernel.org, Marek Szyprowski <m.szyprowski@samsung.com>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On Thu, Oct 23 2014, Laurent Pinchart wrote:
> The fixed parameter to cma_declare_contiguous() tells the function
> whether the given base address must be honoured or should be considered
> as a hint only. The API considers a zero base address as meaning any
> base address, which must never be considered as a fixed value.
>
> Part of the implementation correctly checks both fixed and base !=3D 0,
> but two locations check the fixed value only. Set fixed to false when
> base is 0 to fix that and simplify the code.
>
> Signed-off-by: Laurent Pinchart
> <laurent.pinchart+renesas@ideasonboard.com>

Acked-by: Michal Nazarewicz <mina86@mina86.com>

And like before, this should also probably also go to stable.

> ---
>  mm/cma.c | 5 ++++-
>  1 file changed, 4 insertions(+), 1 deletion(-)
>
> diff --git a/mm/cma.c b/mm/cma.c
> index 16c6650..6b14346 100644
> --- a/mm/cma.c
> +++ b/mm/cma.c
> @@ -239,6 +239,9 @@ int __init cma_declare_contiguous(phys_addr_t base,
>  	size =3D ALIGN(size, alignment);
>  	limit &=3D ~(alignment - 1);
>=20=20
> +	if (!base)
> +		fixed =3D false;
> +
>  	/* size should be aligned with order_per_bit */
>  	if (!IS_ALIGNED(size >> PAGE_SHIFT, 1 << order_per_bit))
>  		return -EINVAL;
> @@ -262,7 +265,7 @@ int __init cma_declare_contiguous(phys_addr_t base,
>  	}
>=20=20
>  	/* Reserve memory */
> -	if (base && fixed) {
> +	if (fixed) {
>  		if (memblock_is_region_reserved(base, size) ||
>  		    memblock_reserve(base, size) < 0) {
>  			ret =3D -EBUSY;
> --=20
> 2.0.4
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
