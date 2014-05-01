Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f52.google.com (mail-ee0-f52.google.com [74.125.83.52])
	by kanga.kvack.org (Postfix) with ESMTP id ABC1E6B0036
	for <linux-mm@kvack.org>; Thu,  1 May 2014 09:09:03 -0400 (EDT)
Received: by mail-ee0-f52.google.com with SMTP id e53so2188398eek.25
        for <linux-mm@kvack.org>; Thu, 01 May 2014 06:09:02 -0700 (PDT)
Received: from mail-ee0-f53.google.com (mail-ee0-f53.google.com [74.125.83.53])
        by mx.google.com with ESMTPS id w48si34138895eel.86.2014.05.01.06.09.01
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 01 May 2014 06:09:02 -0700 (PDT)
Received: by mail-ee0-f53.google.com with SMTP id b15so1107191eek.12
        for <linux-mm@kvack.org>; Thu, 01 May 2014 06:09:01 -0700 (PDT)
From: Grant Likely <grant.likely@secretlab.ca>
Subject: Re: [PATCHv5 2/2] arm: Get rid of meminfo
In-Reply-To: <1396544698-15596-3-git-send-email-lauraa@codeaurora.org>
References: <1396544698-15596-1-git-send-email-lauraa@codeaurora.org>
	<1396544698-15596-3-git-send-email-lauraa@codeaurora.org>
Date: Thu, 01 May 2014 14:08:49 +0100
Message-Id: <20140501130849.C093DC409DA@trevor.secretlab.ca>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <lauraa@codeaurora.org>, Russell King <linux@arm.linux.org.uk>, David Brown <davidb@codeaurora.org>, Daniel Walker <dwalker@fifo99.com>, Jason Cooper <jason@lakedaemon.net>, Andrew Lunn <andrew@lunn.ch>, Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>, Eric Miao <eric.y.miao@gmail.com>, Haojian Zhuang <haojian.zhuang@gmail.com>, Ben Dooks <ben-linux@fluff.org>, Kukjin Kim <kgene.kim@samsung.com>, linux-arm-kernel@lists.infradead.org
Cc: linux-kernel@vger.kernel.org, linux-arm-msm@vger.kernel.org, Leif Lindholm <leif.lindholm@linaro.org>, Grygorii Strashko <grygorii.strashko@ti.com>, Catalin Marinas <catalin.marinas@arm.com>, Rob Herring <robherring2@gmail.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Will Deacon <will.deacon@arm.com>, Nicolas Pitre <nicolas.pitre@linaro.org>, Santosh Shilimkar <santosh.shilimkar@ti.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Courtney Cavin <courtney.cavin@sonymobile.com>, Marek Szyprowski <m.szyprowski@samsung.com>

On Thu,  3 Apr 2014 10:04:58 -0700, Laura Abbott <lauraa@codeaurora.org> wrote:
> memblock is now fully integrated into the kernel and is the prefered
> method for tracking memory. Rather than reinvent the wheel with
> meminfo, migrate to using memblock directly instead of meminfo as
> an intermediate.
> 
> Change-Id: I9d04e636f43bf939e13b4934dc23da0c076811d2
> Acked-by: Jason Cooper <jason@lakedaemon.net>
> Acked-by: Catalin Marinas <catalin.marinas@arm.com>
> Acked-by: Santosh Shilimkar <santosh.shilimkar@ti.com>
> Tested-by: Leif Lindholm <leif.lindholm@linaro.org>
> Signed-off-by: Laura Abbott <lauraa@codeaurora.org>

Tested-by: Grant Likely <grant.likely@linaro.org>

Tiny nit-picking comment below, but this patch looks really good.
What's the state on merging this?

> diff --git a/arch/arm/mm/init.c b/arch/arm/mm/init.c
> index 97c293e..40e14a1 100644
> --- a/arch/arm/mm/init.c
> +++ b/arch/arm/mm/init.c
> @@ -415,54 +400,53 @@ free_memmap(unsigned long start_pfn, unsigned long end_pfn)
>  /*
>   * The mem_map array can get very big.  Free the unused area of the memory map.
>   */
> -static void __init free_unused_memmap(struct meminfo *mi)
> +static void __init free_unused_memmap(void)
>  {
> -	unsigned long bank_start, prev_bank_end = 0;
> -	unsigned int i;
> +	unsigned long start, prev_end = 0;
> +	struct memblock_region *reg;
>  
>  	/*
>  	 * This relies on each bank being in address order.
>  	 * The banks are sorted previously in bootmem_init().
>  	 */
> -	for_each_bank(i, mi) {
> -		struct membank *bank = &mi->bank[i];
> -
> -		bank_start = bank_pfn_start(bank);
> +	for_each_memblock(memory, reg) {
> +		start = memblock_region_memory_base_pfn(reg);
>  
>  #ifdef CONFIG_SPARSEMEM
>  		/*
>  		 * Take care not to free memmap entries that don't exist
>  		 * due to SPARSEMEM sections which aren't present.
>  		 */
> -		bank_start = min(bank_start,
> -				 ALIGN(prev_bank_end, PAGES_PER_SECTION));
> +		start = min(start,
> +				 ALIGN(prev_end, PAGES_PER_SECTION));

Nit: The line doesn't need to be split anymore.

>  #else
>  		/*
>  		 * Align down here since the VM subsystem insists that the
>  		 * memmap entries are valid from the bank start aligned to
>  		 * MAX_ORDER_NR_PAGES.
>  		 */
> -		bank_start = round_down(bank_start, MAX_ORDER_NR_PAGES);
> +		start = round_down(start, MAX_ORDER_NR_PAGES);
>  #endif
>  		/*
>  		 * If we had a previous bank, and there is a space
>  		 * between the current bank and the previous, free it.
>  		 */
> -		if (prev_bank_end && prev_bank_end < bank_start)
> -			free_memmap(prev_bank_end, bank_start);
> +		if (prev_end && prev_end < start)
> +			free_memmap(prev_end, start);
>  
>  		/*
>  		 * Align up here since the VM subsystem insists that the
>  		 * memmap entries are valid from the bank end aligned to
>  		 * MAX_ORDER_NR_PAGES.
>  		 */
> -		prev_bank_end = ALIGN(bank_pfn_end(bank), MAX_ORDER_NR_PAGES);
> +		prev_end = ALIGN(memblock_region_memory_end_pfn(reg),
> +				 MAX_ORDER_NR_PAGES);
>  	}
>  
>  #ifdef CONFIG_SPARSEMEM
> -	if (!IS_ALIGNED(prev_bank_end, PAGES_PER_SECTION))
> -		free_memmap(prev_bank_end,
> -			    ALIGN(prev_bank_end, PAGES_PER_SECTION));
> +	if (!IS_ALIGNED(prev_end, PAGES_PER_SECTION))
> +		free_memmap(prev_end,
> +			    ALIGN(prev_end, PAGES_PER_SECTION));

Ditto

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
