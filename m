Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f173.google.com (mail-ie0-f173.google.com [209.85.223.173])
	by kanga.kvack.org (Postfix) with ESMTP id D04F06B0038
	for <linux-mm@kvack.org>; Tue,  9 Dec 2014 17:50:41 -0500 (EST)
Received: by mail-ie0-f173.google.com with SMTP id y20so1551738ier.4
        for <linux-mm@kvack.org>; Tue, 09 Dec 2014 14:50:41 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id qo3si1966902igb.47.2014.12.09.14.50.40
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Dec 2014 14:50:40 -0800 (PST)
Date: Tue, 9 Dec 2014 14:50:38 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH V2] x86/mm: Fix zone ranges boot printout
Message-Id: <20141209145038.6253a2b99379bfb1255fa95e@linux-foundation.org>
In-Reply-To: <54866C18.1050203@huawei.com>
References: <54866C18.1050203@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: Ingo Molnar <mingo@kernel.org>, dave@sr71.net, Rik van Riel <riel@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, linux-tip-commits@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>

On Tue, 9 Dec 2014 11:27:20 +0800 Xishi Qiu <qiuxishi@huawei.com> wrote:

> Changelog:
> V2:
> 	-fix building warnings of min(...).
>
> ...
>
> --- a/arch/x86/mm/init.c
> +++ b/arch/x86/mm/init.c
> @@ -674,10 +674,12 @@ void __init zone_sizes_init(void)
>  	memset(max_zone_pfns, 0, sizeof(max_zone_pfns));
>  
>  #ifdef CONFIG_ZONE_DMA
> -	max_zone_pfns[ZONE_DMA]		= MAX_DMA_PFN;
> +	max_zone_pfns[ZONE_DMA]		= min_t(unsigned long,
> +						max_low_pfn, MAX_DMA_PFN);

MAX_DMA_PFN has type int.

>  #endif
>  #ifdef CONFIG_ZONE_DMA32
> -	max_zone_pfns[ZONE_DMA32]	= MAX_DMA32_PFN;
> +	max_zone_pfns[ZONE_DMA32]	= min_t(unsigned long,
> +						max_low_pfn, MAX_DMA32_PFN);

MAX_DMA32_PFN has type UL (I think?) so there's no need for min_t here.

>  #endif
>  	max_zone_pfns[ZONE_NORMAL]	= max_low_pfn;
>  #ifdef CONFIG_HIGHMEM


Let's try to get the types correct, rather than hacking around fixing
up fallout from earlier incorrect type choices?

What is the type of a pfn?  Unsigned long, generally, when we bother
thinking about it.

So how about we make MAX_DMA_PFN have type UL?  I assume that fixes the
warning?

If we do this, we should also be able to undo the min_t hackery in
arch/x86/kernel/e820.c:memblock_find_dma_reserve().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
