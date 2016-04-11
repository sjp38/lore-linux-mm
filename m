Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id 1DB6F6B0260
	for <linux-mm@kvack.org>; Mon, 11 Apr 2016 07:23:26 -0400 (EDT)
Received: by mail-wm0-f47.google.com with SMTP id l6so141361531wml.1
        for <linux-mm@kvack.org>; Mon, 11 Apr 2016 04:23:26 -0700 (PDT)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [119.145.14.65])
        by mx.google.com with ESMTPS id j5si28296632wjz.127.2016.04.11.04.23.12
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 11 Apr 2016 04:23:24 -0700 (PDT)
Message-ID: <570B85B6.8000805@huawei.com>
Date: Mon, 11 Apr 2016 19:08:38 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/2] arm64: mm: make pfn always valid with flat memory
References: <1459844572-53069-1-git-send-email-puck.chen@hisilicon.com> <1459844572-53069-2-git-send-email-puck.chen@hisilicon.com>
In-Reply-To: <1459844572-53069-2-git-send-email-puck.chen@hisilicon.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chen Feng <puck.chen@hisilicon.com>
Cc: catalin.marinas@arm.com, will.deacon@arm.com, ard.biesheuvel@linaro.org, mark.rutland@arm.com, akpm@linux-foundation.org, robin.murphy@arm.com, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, mhocko@suse.com, kirill.shutemov@linux.intel.com, rientjes@google.com, linux-mm@kvack.org, dan.zhao@hisilicon.com, puck.chen@foxmail.com, suzhuangluan@hisilicon.com, linuxarm@huawei.com, saberlily.xia@hisilicon.com, oliver.fu@hisilicon.com, yudongbin@hislicon.com

On 2016/4/5 16:22, Chen Feng wrote:

> Make the pfn always valid when using flat memory.
> If the reserved memory is not align to memblock-size,
> there will be holes in zone.
> 
> This patch makes the memory in buddy always in the
> array of mem-map.
> 
> Signed-off-by: Chen Feng <puck.chen@hisilicon.com>
> Signed-off-by: Fu Jun <oliver.fu@hisilicon.com>
> ---
>  arch/arm64/mm/init.c | 7 ++++---
>  1 file changed, 4 insertions(+), 3 deletions(-)
> 
> diff --git a/arch/arm64/mm/init.c b/arch/arm64/mm/init.c
> index ea989d8..0e1d5b7 100644
> --- a/arch/arm64/mm/init.c
> +++ b/arch/arm64/mm/init.c
> @@ -306,7 +306,8 @@ static void __init free_unused_memmap(void)

How about let free_unused_memmap() support for CONFIG_SPARSEMEM_VMEMMAP?

Thanks,
Xishi Qiu

>  	struct memblock_region *reg;
>  
>  	for_each_memblock(memory, reg) {
> -		start = __phys_to_pfn(reg->base);
> +		start = round_down(__phys_to_pfn(reg->base),
> +				   MAX_ORDER_NR_PAGES);
>  
>  #ifdef CONFIG_SPARSEMEM
>  		/*
> @@ -327,8 +328,8 @@ static void __init free_unused_memmap(void)
>  		 * memmap entries are valid from the bank end aligned to
>  		 * MAX_ORDER_NR_PAGES.
>  		 */
> -		prev_end = ALIGN(__phys_to_pfn(reg->base + reg->size),
> -				 MAX_ORDER_NR_PAGES);
> +		prev_end = round_up(__phys_to_pfn(reg->base + reg->size),
> +				    MAX_ORDER_NR_PAGES);
>  	}
>  
>  #ifdef CONFIG_SPARSEMEM



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
