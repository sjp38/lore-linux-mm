Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f44.google.com (mail-la0-f44.google.com [209.85.215.44])
	by kanga.kvack.org (Postfix) with ESMTP id 2C1ED6B0069
	for <linux-mm@kvack.org>; Thu, 23 Oct 2014 12:53:44 -0400 (EDT)
Received: by mail-la0-f44.google.com with SMTP id hs14so1225657lab.3
        for <linux-mm@kvack.org>; Thu, 23 Oct 2014 09:53:42 -0700 (PDT)
Received: from mail-la0-x22e.google.com (mail-la0-x22e.google.com. [2a00:1450:4010:c03::22e])
        by mx.google.com with ESMTPS id b9si3504254lbp.50.2014.10.23.09.53.41
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 23 Oct 2014 09:53:41 -0700 (PDT)
Received: by mail-la0-f46.google.com with SMTP id gi9so1201911lab.5
        for <linux-mm@kvack.org>; Thu, 23 Oct 2014 09:53:40 -0700 (PDT)
From: Michal Nazarewicz <mina86@mina86.com>
Subject: Re: [PATCH 1/4] mm: cma: Don't crash on allocation if CMA area can't be activated
In-Reply-To: <1414074828-4488-2-git-send-email-laurent.pinchart+renesas@ideasonboard.com>
References: <1414074828-4488-1-git-send-email-laurent.pinchart+renesas@ideasonboard.com> <1414074828-4488-2-git-send-email-laurent.pinchart+renesas@ideasonboard.com>
Date: Thu, 23 Oct 2014 18:53:36 +0200
Message-ID: <xa1tmw8mlobz.fsf@mina86.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Pinchart <laurent.pinchart+renesas@ideasonboard.com>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-sh@vger.kernel.org, Marek Szyprowski <m.szyprowski@samsung.com>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On Thu, Oct 23 2014, Laurent Pinchart wrote:
> If activation of the CMA area fails its mutex won't be initialized,
> leading to an oops at allocation time when trying to lock the mutex. Fix
> this by failing allocation if the area hasn't been successfully actived,
> and detect that condition by moving the CMA bitmap allocation after page
> block reservation completion.
>
> Signed-off-by: Laurent Pinchart <laurent.pinchart+renesas@ideasonboard.co=
m>

Cc: <stable@vger.kernel.org>  # v3.17
Acked-by: Michal Nazarewicz <mina86@mina86.com>

As a matter of fact, this is present in kernels earlier than 3.17 but in
the 3.17 the code has been moved from drivers/base/dma-contiguous.c to
mm/cma.c so this might require separate stable patch.  I can track this
and prepare a patch if you want.

> ---
>  mm/cma.c | 17 ++++++-----------
>  1 file changed, 6 insertions(+), 11 deletions(-)
>
> diff --git a/mm/cma.c b/mm/cma.c
> index 963bc4a..16c6650 100644
> --- a/mm/cma.c
> +++ b/mm/cma.c
> @@ -93,11 +93,6 @@ static int __init cma_activate_area(struct cma *cma)
>  	unsigned i =3D cma->count >> pageblock_order;
>  	struct zone *zone;
>=20=20
> -	cma->bitmap =3D kzalloc(bitmap_size, GFP_KERNEL);
> -
> -	if (!cma->bitmap)
> -		return -ENOMEM;
> -
>  	WARN_ON_ONCE(!pfn_valid(pfn));
>  	zone =3D page_zone(pfn_to_page(pfn));
>=20=20
> @@ -114,17 +109,17 @@ static int __init cma_activate_area(struct cma *cma)
>  			 * to be in the same zone.
>  			 */
>  			if (page_zone(pfn_to_page(pfn)) !=3D zone)
> -				goto err;
> +				return -EINVAL;
>  		}
>  		init_cma_reserved_pageblock(pfn_to_page(base_pfn));
>  	} while (--i);
>=20=20
> +	cma->bitmap =3D kzalloc(bitmap_size, GFP_KERNEL);
> +	if (!cma->bitmap)
> +		return -ENOMEM;
> +
>  	mutex_init(&cma->lock);
>  	return 0;
> -
> -err:
> -	kfree(cma->bitmap);
> -	return -EINVAL;
>  }
>=20=20
>  static int __init cma_init_reserved_areas(void)
> @@ -313,7 +308,7 @@ struct page *cma_alloc(struct cma *cma, int count, un=
signed int align)
>  	struct page *page =3D NULL;
>  	int ret;
>=20=20
> -	if (!cma || !cma->count)
> +	if (!cma || !cma->count || !cma->bitmap)
>  		return NULL;
>=20=20
>  	pr_debug("%s(cma %p, count %d, align %d)\n", __func__, (void *)cma,
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
