Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 85F616B0036
	for <linux-mm@kvack.org>; Wed, 21 May 2014 23:22:50 -0400 (EDT)
Received: by mail-pa0-f45.google.com with SMTP id ey11so2029303pad.18
        for <linux-mm@kvack.org>; Wed, 21 May 2014 20:22:50 -0700 (PDT)
Received: from mail-pa0-x231.google.com (mail-pa0-x231.google.com [2607:f8b0:400e:c03::231])
        by mx.google.com with ESMTPS id pp9si8732604pbc.23.2014.05.21.20.22.49
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 21 May 2014 20:22:49 -0700 (PDT)
Received: by mail-pa0-f49.google.com with SMTP id lj1so2020464pab.36
        for <linux-mm@kvack.org>; Wed, 21 May 2014 20:22:49 -0700 (PDT)
From: Michal Nazarewicz <mina86@mina86.com>
Subject: Re: [RFC PATCH] arm: dma-mapping: fallback allocation for cma failure
In-Reply-To: <537D4CBB.80305@lge.com>
References: <537AEEDB.2000001@lge.com> <20140520065222.GB8315@js1304-P5Q-DELUXE> <xa1t1tvo1fas.fsf@mina86.com> <537C5EA3.20709@lge.com> <xa1td2f699j4.fsf@mina86.com> <537D4CBB.80305@lge.com>
Date: Wed, 21 May 2014 17:22:44 -1000
Message-ID: <xa1tmweajy4b.fsf@mina86.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gioh Kim <gioh.kim@lge.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Heesub Shin <heesub.shin@samsung.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, =?utf-8?B?7J206rG07Zi4?= <gunho.lee@lge.com>, 'Chanho Min' <chanho.min@lge.com>

On Thu, May 22 2014, Gioh Kim <gioh.kim@lge.com> wrote:
> I appreciate your comments.
> The previous patch was ugly. But now it's beautiful! Just 3 lines!
>
> I'm not familiar with kernel patch process.
> Can I have your name at Signed-off-by: line?
> What tag do I have to write your name in?

My Signed-off-by line does not apply in this case.
Documentation/SubmittingPatches describes what Signed-off-by means.

I've added Acked-by below.  You may want to resend this patch using
=E2=80=9Cgit-send-email=E2=80=9D.

> --------------------------------- 8< ------------------------------------=
----------
>  From 135c986cfaa5a7291519308b3d47e58bf9f5af25 Mon Sep 17 00:00:00 2001
> From: Gioh Kim <gioh.kim@lge.com>
> Date: Tue, 20 May 2014 14:16:20 +0900
> Subject: [PATCH] arm: dma-mapping: add checking cma area initialized
>
> If CMA is turned on and CMA size is set to zero, kernel should
> behave as if CMA was not enabled at compile time.
> Every dma allocation should check existence of cma area
> before requesting memory.
>
> Signed-off-by: Gioh Kim <gioh.kim@lge.com>
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Acked-by: Michal Nazarewicz <mina86@mina86.com>

But like before, if someone with more ARM knowledge could take a look at
it, it would be awesome.

> ---
>   arch/arm/mm/dma-mapping.c |    7 ++++---
>   1 file changed, 4 insertions(+), 3 deletions(-)
>
> diff --git a/arch/arm/mm/dma-mapping.c b/arch/arm/mm/dma-mapping.c
> index 18e98df..9173a13 100644
> --- a/arch/arm/mm/dma-mapping.c
> +++ b/arch/arm/mm/dma-mapping.c
> @@ -390,12 +390,13 @@ static int __init atomic_pool_init(void)
>          if (!pages)
>                  goto no_pages;
>
> -       if (IS_ENABLED(CONFIG_DMA_CMA))
> +       if (dev_get_cma_area(NULL))
>                  ptr =3D __alloc_from_contiguous(NULL, pool->size, prot, =
&page,
>                                                atomic_pool_init);
>          else
>                  ptr =3D __alloc_remap_buffer(NULL, pool->size, gfp, prot=
, &page,
>                                             atomic_pool_init);
> +
>          if (ptr) {
>                  int i;
>
> @@ -701,7 +702,7 @@ static void *__dma_alloc(struct device *dev, size_t s=
ize, dma_addr_t *handle,
>                  addr =3D __alloc_simple_buffer(dev, size, gfp, &page);
>          else if (!(gfp & __GFP_WAIT))
>                  addr =3D __alloc_from_pool(size, &page);
> -       else if (!IS_ENABLED(CONFIG_DMA_CMA))
> +       else if (!dev_get_cma_area(dev))
>                  addr =3D __alloc_remap_buffer(dev, size, gfp, prot, &pag=
e, caller);
>          else
>                  addr =3D __alloc_from_contiguous(dev, size, prot, &page,=
 caller);
> @@ -790,7 +791,7 @@ static void __arm_dma_free(struct device *dev, size_t=
 size, void *cpu_addr,
>                  __dma_free_buffer(page, size);
>          } else if (__free_from_pool(cpu_addr, size)) {
>                  return;
> -       } else if (!IS_ENABLED(CONFIG_DMA_CMA)) {
> +       } else if (!dev_get_cma_area(dev)) {
>                  __dma_free_remap(cpu_addr, size);
>                  __dma_free_buffer(page, size);
>          } else {
> --
> 1.7.9.5

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
