Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 7BFFD6B0192
	for <linux-mm@kvack.org>; Fri, 14 Oct 2011 00:33:28 -0400 (EDT)
Received: by gyf3 with SMTP id 3so755458gyf.14
        for <linux-mm@kvack.org>; Thu, 13 Oct 2011 21:33:26 -0700 (PDT)
Message-ID: <4E97BB8E.3060204@gmail.com>
Date: Fri, 14 Oct 2011 10:03:18 +0530
From: Subash Patel <subashrp@gmail.com>
MIME-Version: 1.0
Subject: Re: [Linaro-mm-sig] [PATCH 8/9] ARM: integrate CMA with DMA-mapping
 subsystem
References: <1317909290-29832-1-git-send-email-m.szyprowski@samsung.com> <1317909290-29832-10-git-send-email-m.szyprowski@samsung.com>
In-Reply-To: <1317909290-29832-10-git-send-email-m.szyprowski@samsung.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, Daniel Walker <dwalker@codeaurora.org>, Russell King <linux@arm.linux.org.uk>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Mel Gorman <mel@csn.ul.ie>, Chunsang Jeong <chunsang.jeong@linaro.org>, Michal Nazarewicz <mina86@mina86.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Jesse Barker <jesse.barker@linaro.org>, Kyungmin Park <kyungmin.park@samsung.com>, Ankita Garg <ankita@in.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Hi Marek,

As informed to you in private over IRC, below piece of code broke during 
booting EXYNOS4:SMDKV310 with ZONE_DMA enabled.


On 10/06/2011 07:24 PM, Marek Szyprowski wrote:
...
> diff --git a/arch/arm/mm/init.c b/arch/arm/mm/init.c
> index fbdd12e..9c27fbd 100644
> --- a/arch/arm/mm/init.c
> +++ b/arch/arm/mm/init.c
> @@ -21,6 +21,7 @@
>   #include<linux/gfp.h>
>   #include<linux/memblock.h>
>   #include<linux/sort.h>
> +#include<linux/dma-contiguous.h>
>
>   #include<asm/mach-types.h>
>   #include<asm/prom.h>
> @@ -371,6 +372,13 @@ void __init arm_memblock_init(struct meminfo *mi, struct machine_desc *mdesc)
>   	if (mdesc->reserve)
>   		mdesc->reserve();
>
> +	/* reserve memory for DMA contigouos allocations */
> +#ifdef CONFIG_ZONE_DMA
> +	dma_contiguous_reserve(PHYS_OFFSET + mdesc->dma_zone_size - 1);
> +#else
> +	dma_contiguous_reserve(0);
> +#endif
> +
>   	memblock_analyze();
>   	memblock_dump_all();
>   }
Regards,
Subash

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
