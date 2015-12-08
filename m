Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id 537276B0254
	for <linux-mm@kvack.org>; Tue,  8 Dec 2015 17:19:42 -0500 (EST)
Received: by wmec201 with SMTP id c201so233126609wme.0
        for <linux-mm@kvack.org>; Tue, 08 Dec 2015 14:19:42 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id j62si7823980wmd.65.2015.12.08.14.19.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Dec 2015 14:19:41 -0800 (PST)
Date: Tue, 8 Dec 2015 14:19:39 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] MIPS: Fix DMA contiguous allocation
Message-Id: <20151208141939.d0edbb72b3c15844c5ac25ea@linux-foundation.org>
In-Reply-To: <1449569930-2118-1-git-send-email-qais.yousef@imgtec.com>
References: <1449569930-2118-1-git-send-email-qais.yousef@imgtec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Qais Yousef <qais.yousef@imgtec.com>
Cc: linux-mips@linux-mips.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, ralf@linux-mips.org, mgorman@techsingularity.net

On Tue, 8 Dec 2015 10:18:50 +0000 Qais Yousef <qais.yousef@imgtec.com> wrote:

> Recent changes to how GFP_ATOMIC is defined seems to have broken the condition
> to use mips_alloc_from_contiguous() in mips_dma_alloc_coherent().
> 
> I couldn't bottom out the exact change but I think it's this one
> 
> d0164adc89f6 (mm, page_alloc: distinguish between being unable to sleep,
> unwilling to sleep and avoiding waking kswapd)
> 
> >From what I see GFP_ATOMIC has multiple bits set and the check for !(gfp
> & GFP_ATOMIC) isn't enough. To verify if the flag is atomic we need to make
> sure that (gfp & GFP_ATOMIC) == GFP_ATOMIC to verify that all bits rquired to
> satisfy GFP_ATOMIC condition are set.
> 
> ...
>
> --- a/arch/mips/mm/dma-default.c
> +++ b/arch/mips/mm/dma-default.c
> @@ -145,7 +145,7 @@ static void *mips_dma_alloc_coherent(struct device *dev, size_t size,
>  
>  	gfp = massage_gfp_flags(dev, gfp);
>  
> -	if (IS_ENABLED(CONFIG_DMA_CMA) && !(gfp & GFP_ATOMIC))
> +	if (IS_ENABLED(CONFIG_DMA_CMA) && ((gfp & GFP_ATOMIC) != GFP_ATOMIC))
>  		page = dma_alloc_from_contiguous(dev,
>  					count, get_order(size));
>  	if (!page)

hm.  It seems that the code is asking "can I do a potentially-sleeping
memory allocation"?

The way to do that under the new regime is

	if (IS_ENABLED(CONFIG_DMA_CMA) && gfpflags_allow_blocking(gfp))

Mel, can you please confirm?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
