Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f53.google.com (mail-pb0-f53.google.com [209.85.160.53])
	by kanga.kvack.org (Postfix) with ESMTP id 0675C6B0036
	for <linux-mm@kvack.org>; Wed, 21 May 2014 16:11:48 -0400 (EDT)
Received: by mail-pb0-f53.google.com with SMTP id md12so1715235pbc.26
        for <linux-mm@kvack.org>; Wed, 21 May 2014 13:11:48 -0700 (PDT)
Received: from mail-pa0-x234.google.com (mail-pa0-x234.google.com [2607:f8b0:400e:c03::234])
        by mx.google.com with ESMTPS id vj3si7623290pbc.59.2014.05.21.13.11.47
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 21 May 2014 13:11:48 -0700 (PDT)
Received: by mail-pa0-f52.google.com with SMTP id fa1so1733897pad.11
        for <linux-mm@kvack.org>; Wed, 21 May 2014 13:11:47 -0700 (PDT)
From: Michal Nazarewicz <mina86@mina86.com>
Subject: Re: [RFC PATCH] arm: dma-mapping: fallback allocation for cma failure
In-Reply-To: <537C5EA3.20709@lge.com>
References: <537AEEDB.2000001@lge.com> <20140520065222.GB8315@js1304-P5Q-DELUXE> <xa1t1tvo1fas.fsf@mina86.com> <537C5EA3.20709@lge.com>
Date: Wed, 21 May 2014 10:11:43 -1000
Message-ID: <xa1td2f699j4.fsf@mina86.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gioh Kim <gioh.kim@lge.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Heesub Shin <heesub.shin@samsung.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, =?utf-8?B?7J206rG07Zi4?= <gunho.lee@lge.com>, 'Chanho Min' <chanho.min@lge.com>

On Wed, May 21 2014, Gioh Kim <gioh.kim@lge.com> wrote:
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

Some minor comments.  Also, I'd love for someone more experienced with
ARM to take a look at this as well.

> ---
>   arch/arm/mm/dma-mapping.c |   12 ++++++++----
>   1 file changed, 8 insertions(+), 4 deletions(-)
>
> diff --git a/arch/arm/mm/dma-mapping.c b/arch/arm/mm/dma-mapping.c
> index 18e98df..61f7b93 100644
> --- a/arch/arm/mm/dma-mapping.c
> +++ b/arch/arm/mm/dma-mapping.c
> @@ -379,7 +379,7 @@ static int __init atomic_pool_init(void)
>          unsigned long *bitmap;
>          struct page *page;
>          struct page **pages;
> -       void *ptr;
> +       void *ptr =3D NULL;

This is unnecessary any more.

>          int bitmap_size =3D BITS_TO_LONGS(nr_pages) * sizeof(long);
>
>          bitmap =3D kzalloc(bitmap_size, GFP_KERNEL);
> @@ -390,12 +390,13 @@ static int __init atomic_pool_init(void)
>          if (!pages)
>                  goto no_pages;
>
> -       if (IS_ENABLED(CONFIG_DMA_CMA))
> +       if (IS_ENABLED(CONFIG_DMA_CMA) && dma_contiguous_default_area)

+	if (dev_get_cma_area(NULL))

dev_get_cma_area returns NULL if !IS_ENABLED(CONFIG_DMA_CMA) so there's
no need to check it explicitly.  And with NULL argument,
deg_get_cma_area returns the default area.

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
> @@ -669,6 +670,7 @@ static void *__dma_alloc(struct device *dev, size_t s=
ize, dma_addr_t *handle,
>          u64 mask =3D get_coherent_dma_mask(dev);
>          struct page *page =3D NULL;
>          void *addr;
> +       struct cma *cma =3D dev_get_cma_area(dev);
>
>   #ifdef CONFIG_DMA_API_DEBUG
>          u64 limit =3D (mask + 1) & ~mask;
> @@ -701,7 +703,7 @@ static void *__dma_alloc(struct device *dev, size_t s=
ize, dma_addr_t *handle,
>                  addr =3D __alloc_simple_buffer(dev, size, gfp, &page);
>          else if (!(gfp & __GFP_WAIT))
>                  addr =3D __alloc_from_pool(size, &page);
> -       else if (!IS_ENABLED(CONFIG_DMA_CMA))
> +       else if (!IS_ENABLED(CONFIG_DMA_CMA) || !cma)

Like above, just do:

+	else if (!dev_get_cma_area(dev))

This will also allow to drop the =E2=80=9Ccma=E2=80=9D variable above.

>                  addr =3D __alloc_remap_buffer(dev, size, gfp, prot, &pag=
e, caller);
>          else
>                  addr =3D __alloc_from_contiguous(dev, size, prot, &page,=
 caller);
> @@ -780,6 +782,7 @@ static void __arm_dma_free(struct device *dev, size_t=
 size, void *cpu_addr,
>                             bool is_coherent)
>   {
>          struct page *page =3D pfn_to_page(dma_to_pfn(dev, handle));
> +       struct cma *cma =3D dev_get_cma_area(dev);
>
>          if (dma_release_from_coherent(dev, get_order(size), cpu_addr))
>                  return;
> @@ -790,7 +793,7 @@ static void __arm_dma_free(struct device *dev, size_t=
 size, void *cpu_addr,
>                  __dma_free_buffer(page, size);
>          } else if (__free_from_pool(cpu_addr, size)) {
>                  return;
> -       } else if (!IS_ENABLED(CONFIG_DMA_CMA)) {
> +       } else if (!IS_ENABLED(CONFIG_DMA_CMA) || !cma) {

Ditto.

>                  __dma_free_remap(cpu_addr, size);
>                  __dma_free_buffer(page, size);
>          } else {
> @@ -798,6 +801,7 @@ static void __arm_dma_free(struct device *dev, size_t=
 size, void *cpu_addr,
>                   * Non-atomic allocations cannot be freed with IRQs disa=
bled
>                   */
>                  WARN_ON(irqs_disabled());
> +

Unrelated change.

>                  __free_from_contiguous(dev, page, cpu_addr, size);
>          }
>   }
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
