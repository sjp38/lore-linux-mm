Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f179.google.com (mail-lb0-f179.google.com [209.85.217.179])
	by kanga.kvack.org (Postfix) with ESMTP id 0FB126B0038
	for <linux-mm@kvack.org>; Tue,  8 Dec 2015 07:12:52 -0500 (EST)
Received: by lbblt2 with SMTP id lt2so9913002lbb.3
        for <linux-mm@kvack.org>; Tue, 08 Dec 2015 04:12:51 -0800 (PST)
Received: from mail-lb0-x22c.google.com (mail-lb0-x22c.google.com. [2a00:1450:4010:c04::22c])
        by mx.google.com with ESMTPS id 40si1534818lfq.17.2015.12.08.04.12.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Dec 2015 04:12:50 -0800 (PST)
Received: by lbbcs9 with SMTP id cs9so9888135lbb.1
        for <linux-mm@kvack.org>; Tue, 08 Dec 2015 04:12:50 -0800 (PST)
Subject: Re: [PATCH] MIPS: Fix DMA contiguous allocation
References: <1449569930-2118-1-git-send-email-qais.yousef@imgtec.com>
From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Message-ID: <5666C941.20209@cogentembedded.com>
Date: Tue, 8 Dec 2015 15:12:49 +0300
MIME-Version: 1.0
In-Reply-To: <1449569930-2118-1-git-send-email-qais.yousef@imgtec.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Qais Yousef <qais.yousef@imgtec.com>, linux-mips@linux-mips.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, ralf@linux-mips.org, akpm@linux-foundation.org, mgorman@techsingularity.net

On 12/8/2015 1:18 PM, Qais Yousef wrote:

> Recent changes to how GFP_ATOMIC is defined seems to have broken the condition
> to use mips_alloc_from_contiguous() in mips_dma_alloc_coherent().
>
> I couldn't bottom out the exact change but I think it's this one
>
> d0164adc89f6 (mm, page_alloc: distinguish between being unable to sleep,
> unwilling to sleep and avoiding waking kswapd)
>
>  From what I see GFP_ATOMIC has multiple bits set and the check for !(gfp
> & GFP_ATOMIC) isn't enough. To verify if the flag is atomic we need to make
> sure that (gfp & GFP_ATOMIC) == GFP_ATOMIC to verify that all bits rquired to

    Required.

> satisfy GFP_ATOMIC condition are set.
>
> Signed-off-by: Qais Yousef <qais.yousef@imgtec.com>
> ---
>   arch/mips/mm/dma-default.c | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/arch/mips/mm/dma-default.c b/arch/mips/mm/dma-default.c
> index d8117be729a2..d6b8a1445a3a 100644
> --- a/arch/mips/mm/dma-default.c
> +++ b/arch/mips/mm/dma-default.c
> @@ -145,7 +145,7 @@ static void *mips_dma_alloc_coherent(struct device *dev, size_t size,
>
>   	gfp = massage_gfp_flags(dev, gfp);
>
> -	if (IS_ENABLED(CONFIG_DMA_CMA) && !(gfp & GFP_ATOMIC))
> +	if (IS_ENABLED(CONFIG_DMA_CMA) && ((gfp & GFP_ATOMIC) != GFP_ATOMIC))

    () around != not necessary.

[...]

MBR, Sergei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
