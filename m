Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f52.google.com (mail-oi0-f52.google.com [209.85.218.52])
	by kanga.kvack.org (Postfix) with ESMTP id 1CDD56B0005
	for <linux-mm@kvack.org>; Thu,  7 Apr 2016 03:41:28 -0400 (EDT)
Received: by mail-oi0-f52.google.com with SMTP id p188so88801823oih.2
        for <linux-mm@kvack.org>; Thu, 07 Apr 2016 00:41:28 -0700 (PDT)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTP id h16si2345702oig.64.2016.04.07.00.41.25
        for <linux-mm@kvack.org>;
        Thu, 07 Apr 2016 00:41:27 -0700 (PDT)
Subject: Re: [PATCH 2/2] arm64: mm: make pfn always valid with flat memory
References: <1459844572-53069-1-git-send-email-puck.chen@hisilicon.com>
 <1459844572-53069-2-git-send-email-puck.chen@hisilicon.com>
From: Chen Feng <puck.chen@hisilicon.com>
Message-ID: <57060E97.7060101@hisilicon.com>
Date: Thu, 7 Apr 2016 15:39:03 +0800
MIME-Version: 1.0
In-Reply-To: <1459844572-53069-2-git-send-email-puck.chen@hisilicon.com>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: catalin.marinas@arm.com, will.deacon@arm.com, ard.biesheuvel@linaro.org, mark.rutland@arm.com, akpm@linux-foundation.org, robin.murphy@arm.com, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, mhocko@suse.com, kirill.shutemov@linux.intel.com, rientjes@google.com, linux-mm@kvack.org, mgorman@suse.de
Cc: puck.chen@foxmail.com, oliver.fu@hisilicon.com, linuxarm@huawei.com, dan.zhao@hisilicon.com, suzhuangluan@hisilicon.com, yudongbin@hislicon.com, albert.lubing@hisilicon.com, xuyiping@hisilicon.com, saberlily.xia@hisilicon.com

add Mel Gorman

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
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
