Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4820B6B0005
	for <linux-mm@kvack.org>; Tue, 31 May 2016 07:53:57 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id r64so302446945oie.1
        for <linux-mm@kvack.org>; Tue, 31 May 2016 04:53:57 -0700 (PDT)
Received: from mail-it0-x242.google.com (mail-it0-x242.google.com. [2607:f8b0:4001:c0b::242])
        by mx.google.com with ESMTPS id 77si44404851ioj.47.2016.05.31.04.53.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 31 May 2016 04:53:56 -0700 (PDT)
Received: by mail-it0-x242.google.com with SMTP id z123so9189682itg.2
        for <linux-mm@kvack.org>; Tue, 31 May 2016 04:53:56 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1464150590-2703-1-git-send-email-jaewon31.kim@samsung.com>
References: <1464150590-2703-1-git-send-email-jaewon31.kim@samsung.com>
Date: Tue, 31 May 2016 19:53:56 +0800
Message-ID: <CAB4PhKfOTBGRgYN+j+RHEKvML4E+ZQuEsqc3_=QYw+XpQePEww@mail.gmail.com>
Subject: Re: [RESEND][PATCH] drivers: of: of_reserved_mem: fixup the CMA
 alignment not to affect dma-coherent
From: Jason Liu <liu.h.jason@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jaewon Kim <jaewon31.kim@samsung.com>
Cc: robh+dt@kernel.org, Jason Liu <r64343@freescale.com>, m.szyprowski@samsung.com, Grant Likely <grant.likely@linaro.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, jaewon31.kim@gmail.com

2016-05-25 12:29 GMT+08:00 Jaewon Kim <jaewon31.kim@samsung.com>:
> From: Jaewon <jaewon31.kim@samsung.com>
>
> There was an alignment mismatch issue for CMA and it was fixed by
> commit 1cc8e3458b51 ("drivers: of: of_reserved_mem: fixup the alignment with CMA setup").
> However the way of the commit considers not only dma-contiguous(CMA) but also
> dma-coherent which has no that requirement.
>
> This patch checks more to distinguish dma-contiguous(CMA) from dma-coherent.
>
> Signed-off-by: Jaewon Kim <jaewon31.kim@samsung.com>
> ---
>  drivers/of/of_reserved_mem.c | 5 ++++-
>  1 file changed, 4 insertions(+), 1 deletion(-)
>

Acked-by: Jason Liu <r64343@freescale.com>


Jason Liu

> diff --git a/drivers/of/of_reserved_mem.c b/drivers/of/of_reserved_mem.c
> index ed01c01..45b873e 100644
> --- a/drivers/of/of_reserved_mem.c
> +++ b/drivers/of/of_reserved_mem.c
> @@ -127,7 +127,10 @@ static int __init __reserved_mem_alloc_size(unsigned long node,
>         }
>
>         /* Need adjust the alignment to satisfy the CMA requirement */
> -       if (IS_ENABLED(CONFIG_CMA) && of_flat_dt_is_compatible(node, "shared-dma-pool"))
> +       if (IS_ENABLED(CONFIG_CMA)
> +           && of_flat_dt_is_compatible(node, "shared-dma-pool")
> +           && of_get_flat_dt_prop(node, "reusable", NULL)
> +           && !of_get_flat_dt_prop(node, "no-map", NULL)) {
>                 align = max(align, (phys_addr_t)PAGE_SIZE << max(MAX_ORDER - 1, pageblock_order));
>
>         prop = of_get_flat_dt_prop(node, "alloc-ranges", &len);
> --
> 1.9.1
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
