Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 09CF46B0253
	for <linux-mm@kvack.org>; Fri,  3 Jun 2016 08:23:57 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id w64so8600378iow.1
        for <linux-mm@kvack.org>; Fri, 03 Jun 2016 05:23:57 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.136])
        by mx.google.com with ESMTPS id bm3si5575737pad.35.2016.06.03.05.23.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Jun 2016 05:23:56 -0700 (PDT)
Received: from mail.kernel.org (localhost [127.0.0.1])
	by mail.kernel.org (Postfix) with ESMTP id 6D9302026F
	for <linux-mm@kvack.org>; Fri,  3 Jun 2016 12:23:55 +0000 (UTC)
Received: from mail-yw0-f182.google.com (mail-yw0-f182.google.com [209.85.161.182])
	(using TLSv1.2 with cipher AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id BA35B2022D
	for <linux-mm@kvack.org>; Fri,  3 Jun 2016 12:23:53 +0000 (UTC)
Received: by mail-yw0-f182.google.com with SMTP id x189so78434025ywe.3
        for <linux-mm@kvack.org>; Fri, 03 Jun 2016 05:23:53 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1464150590-2703-1-git-send-email-jaewon31.kim@samsung.com>
References: <1464150590-2703-1-git-send-email-jaewon31.kim@samsung.com>
From: Rob Herring <robh+dt@kernel.org>
Date: Fri, 3 Jun 2016 07:23:33 -0500
Message-ID: <CAL_JsqJPDJi7n9_Wuam5-pd+9adOFGQo9cjQxuEngJDm486G7A@mail.gmail.com>
Subject: Re: [RESEND][PATCH] drivers: of: of_reserved_mem: fixup the CMA
 alignment not to affect dma-coherent
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jaewon Kim <jaewon31.kim@samsung.com>
Cc: r64343@freescale.com, Marek Szyprowski <m.szyprowski@samsung.com>, Grant Likely <grant.likely@linaro.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Jaewon Kim <jaewon31.kim@gmail.com>

On Tue, May 24, 2016 at 11:29 PM, Jaewon Kim <jaewon31.kim@samsung.com> wrote:
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

This won't actually compile as you add a bracket here, but no closing bracket...

I've fixed up and applied.

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
