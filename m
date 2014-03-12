Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f180.google.com (mail-we0-f180.google.com [74.125.82.180])
	by kanga.kvack.org (Postfix) with ESMTP id C4C646B00AD
	for <linux-mm@kvack.org>; Wed, 12 Mar 2014 10:45:23 -0400 (EDT)
Received: by mail-we0-f180.google.com with SMTP id p61so11271725wes.25
        for <linux-mm@kvack.org>; Wed, 12 Mar 2014 07:45:23 -0700 (PDT)
Received: from pandora.arm.linux.org.uk (pandora.arm.linux.org.uk. [2001:4d48:ad52:3201:214:fdff:fe10:1be6])
        by mx.google.com with ESMTPS id eu5si4115248wib.86.2014.03.12.07.45.20
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 12 Mar 2014 07:45:21 -0700 (PDT)
Date: Wed, 12 Mar 2014 14:44:52 +0000
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCHv4 2/2] arm: Get rid of meminfo
Message-ID: <20140312144452.GJ21483@n2100.arm.linux.org.uk>
References: <1392761733-32628-1-git-send-email-lauraa@codeaurora.org> <1392761733-32628-3-git-send-email-lauraa@codeaurora.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1392761733-32628-3-git-send-email-lauraa@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <lauraa@codeaurora.org>
Cc: David Brown <davidb@codeaurora.org>, Daniel Walker <dwalker@fifo99.com>, Jason Cooper <jason@lakedaemon.net>, Andrew Lunn <andrew@lunn.ch>, Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>, Eric Miao <eric.y.miao@gmail.com>, Haojian Zhuang <haojian.zhuang@gmail.com>, Ben Dooks <ben-linux@fluff.org>, Kukjin Kim <kgene.kim@samsung.com>, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-arm-msm@vger.kernel.org, Leif Lindholm <leif.lindholm@linaro.org>, Grygorii Strashko <grygorii.strashko@ti.com>, Catalin Marinas <catalin.marinas@arm.com>, Rob Herring <robherring2@gmail.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Will Deacon <will.deacon@arm.com>, Nicolas Pitre <nicolas.pitre@linaro.org>, Santosh Shilimkar <santosh.shilimkar@ti.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Courtney Cavin <courtney.cavin@sonymobile.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Grant Likely <grant.likely@secretlab.ca>

On Tue, Feb 18, 2014 at 02:15:33PM -0800, Laura Abbott wrote:
> diff --git a/arch/arm/mm/mmu.c b/arch/arm/mm/mmu.c
> index b68c6b2..c3ae96c 100644
> --- a/arch/arm/mm/mmu.c
> +++ b/arch/arm/mm/mmu.c
> @@ -1061,74 +1061,44 @@ phys_addr_t arm_lowmem_limit __initdata = 0;
>  void __init sanity_check_meminfo(void)
>  {
>  	phys_addr_t memblock_limit = 0;
> -	int i, j, highmem = 0;
> +	int highmem = 0;
>  	phys_addr_t vmalloc_limit = __pa(vmalloc_min - 1) + 1;
> +	struct memblock_region *reg;
>  
> -	for (i = 0, j = 0; i < meminfo.nr_banks; i++) {
> -		struct membank *bank = &meminfo.bank[j];
> -		phys_addr_t size_limit;
> -
> -		*bank = meminfo.bank[i];
> -		size_limit = bank->size;
> +	for_each_memblock(memory, reg) {
> +		phys_addr_t block_start = reg->base;
> +		phys_addr_t block_end = reg->base + reg->size;
> +		phys_addr_t size_limit = reg->size;
>  
> -		if (bank->start >= vmalloc_limit)
> +		if (reg->base >= vmalloc_limit)
>  			highmem = 1;
>  		else
> -			size_limit = vmalloc_limit - bank->start;
> +			size_limit = vmalloc_limit - reg->base;
>  
> -		bank->highmem = highmem;
>  
> -#ifdef CONFIG_HIGHMEM
> -		/*
> -		 * Split those memory banks which are partially overlapping
> -		 * the vmalloc area greatly simplifying things later.
> -		 */
> -		if (!highmem && bank->size > size_limit) {
> -			if (meminfo.nr_banks >= NR_BANKS) {
> -				printk(KERN_CRIT "NR_BANKS too low, "
> -						 "ignoring high memory\n");
> -			} else {
> -				memmove(bank + 1, bank,
> -					(meminfo.nr_banks - i) * sizeof(*bank));
> -				meminfo.nr_banks++;
> -				i++;
> -				bank[1].size -= size_limit;
> -				bank[1].start = vmalloc_limit;
> -				bank[1].highmem = highmem = 1;
> -				j++;
> +		if (!IS_ENABLED(CONFIG_HIGHMEM) || cache_is_vipt_aliasing()) {
> +
> +			if (highmem) {
> +				pr_notice("Ignoring RAM at %pa-%pa (!CONFIG_HIGHMEM)\n",
> +					&block_start, &block_end);
> +				memblock_remove(reg->base, reg->size);
> +				continue;
>  			}
> -			bank->size = size_limit;
> -		}
> -#else
> -		/*
> -		 * Highmem banks not allowed with !CONFIG_HIGHMEM.
> -		 */
> -		if (highmem) {
> -			printk(KERN_NOTICE "Ignoring RAM at %.8llx-%.8llx "
> -			       "(!CONFIG_HIGHMEM).\n",
> -			       (unsigned long long)bank->start,
> -			       (unsigned long long)bank->start + bank->size - 1);
> -			continue;
> -		}
>  
> -		/*
> -		 * Check whether this memory bank would partially overlap
> -		 * the vmalloc area.
> -		 */
> -		if (bank->size > size_limit) {
> -			printk(KERN_NOTICE "Truncating RAM at %.8llx-%.8llx "
> -			       "to -%.8llx (vmalloc region overlap).\n",
> -			       (unsigned long long)bank->start,
> -			       (unsigned long long)bank->start + bank->size - 1,
> -			       (unsigned long long)bank->start + size_limit - 1);
> -			bank->size = size_limit;
> +			if (reg->size > size_limit) {
> +				phys_addr_t overlap_size = reg->size - size_limit;
> +
> +				pr_notice("Truncating RAM at %pa-%pa to -%pa",
> +				      &block_start, &block_end, &vmalloc_limit);
> +				memblock_remove(vmalloc_limit, overlap_size);
> +				block_end = vmalloc_limit;
> +			}
>  		}
> -#endif
> -		if (!bank->highmem) {
> -			phys_addr_t bank_end = bank->start + bank->size;
>  
> -			if (bank_end > arm_lowmem_limit)
> -				arm_lowmem_limit = bank_end;
> +		if (!highmem) {
> +			if (block_end > arm_lowmem_limit)
> +				arm_lowmem_limit = block_end;
> +
>  
>  			/*
>  			 * Find the first non-section-aligned page, and point
> @@ -1144,35 +1114,16 @@ void __init sanity_check_meminfo(void)
>  			 * occurs before any free memory is mapped.
>  			 */
>  			if (!memblock_limit) {
> -				if (!IS_ALIGNED(bank->start, SECTION_SIZE))
> -					memblock_limit = bank->start;
> -				else if (!IS_ALIGNED(bank_end, SECTION_SIZE))
> -					memblock_limit = bank_end;
> +				if (!IS_ALIGNED(block_start, SECTION_SIZE))
> +					memblock_limit = block_start;
> +				else if (!IS_ALIGNED(block_end, SECTION_SIZE))
> +					memblock_limit = block_end;
>  			}
> -		}
> -		j++;
> -	}
> -#ifdef CONFIG_HIGHMEM
> -	if (highmem) {
> -		const char *reason = NULL;
>  
> -		if (cache_is_vipt_aliasing()) {
> -			/*
> -			 * Interactions between kmap and other mappings
> -			 * make highmem support with aliasing VIPT caches
> -			 * rather difficult.
> -			 */
> -			reason = "with VIPT aliasing cache";
> -		}
> -		if (reason) {
> -			printk(KERN_CRIT "HIGHMEM is not supported %s, ignoring high memory\n",
> -				reason);
> -			while (j > 0 && meminfo.bank[j - 1].highmem)
> -				j--;
>  		}
> +
>  	}
> -#endif
> -	meminfo.nr_banks = j;
> +

Adding here:
	if (arm_lowmem_limit > vmalloc_limit)
		arm_lowmem_limit = vmalloc_limit;

fixes the booting problems, because we now properly calculate the end of
lowmem rather than letting it overflow - previously, the code would set
the end of lowmem to be the end of the first memblock which is quite
obviously wrong when you could have any size of memory in that block.

BTW, for a v4 patch, please clean up the excess blank lines in this
patch.

Thanks.

-- 
FTTC broadband for 0.8mile line: now at 9.7Mbps down 460kbps up... slowly
improving, and getting towards what was expected from it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
