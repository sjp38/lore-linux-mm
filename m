Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f44.google.com (mail-qg0-f44.google.com [209.85.192.44])
	by kanga.kvack.org (Postfix) with ESMTP id 6F6626B0253
	for <linux-mm@kvack.org>; Tue, 18 Aug 2015 04:56:32 -0400 (EDT)
Received: by qgj62 with SMTP id 62so112251806qgj.2
        for <linux-mm@kvack.org>; Tue, 18 Aug 2015 01:56:32 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id p71si30232792qkh.27.2015.08.18.01.56.31
        for <linux-mm@kvack.org>;
        Tue, 18 Aug 2015 01:56:31 -0700 (PDT)
Date: Tue, 18 Aug 2015 09:56:26 +0100
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH V4 2/3] arm64: support initrd outside kernel linear map
Message-ID: <20150818085626.GD10301@arm.com>
References: <1439830867-14935-1-git-send-email-msalter@redhat.com>
 <1439830867-14935-3-git-send-email-msalter@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1439830867-14935-3-git-send-email-msalter@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mark Salter <msalter@redhat.com>
Cc: Catalin Marinas <Catalin.Marinas@arm.com>, "x86@kernel.org" <x86@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Mark Rutland <Mark.Rutland@arm.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>

On Mon, Aug 17, 2015 at 06:01:06PM +0100, Mark Salter wrote:
> The use of mem= could leave part or all of the initrd outside of
> the kernel linear map. This will lead to an error when unpacking
> the initrd and a probable failure to boot. This patch catches that
> situation and relocates the initrd to be fully within the linear
> map.
> 
> Signed-off-by: Mark Salter <msalter@redhat.com>
> ---
>  arch/arm64/kernel/setup.c | 62 +++++++++++++++++++++++++++++++++++++++++++++++
>  1 file changed, 62 insertions(+)

Looks good to me:

  Acked-by: Will Deacon <will.deacon@arm.com>

This series should replace the version that Andrew has currently got in
linux-next.

Will

> diff --git a/arch/arm64/kernel/setup.c b/arch/arm64/kernel/setup.c
> index f3067d4..40a894e 100644
> --- a/arch/arm64/kernel/setup.c
> +++ b/arch/arm64/kernel/setup.c
> @@ -359,6 +359,67 @@ static void __init request_standard_resources(void)
>  	}
>  }
>  
> +#ifdef CONFIG_BLK_DEV_INITRD
> +/*
> + * Relocate initrd if it is not completely within the linear mapping.
> + * This would be the case if mem= cuts out all or part of it.
> + */
> +static void __init relocate_initrd(void)
> +{
> +	phys_addr_t orig_start = __virt_to_phys(initrd_start);
> +	phys_addr_t orig_end = __virt_to_phys(initrd_end);
> +	phys_addr_t ram_end = memblock_end_of_DRAM();
> +	phys_addr_t new_start;
> +	unsigned long size, to_free = 0;
> +	void *dest;
> +
> +	if (orig_end <= ram_end)
> +		return;
> +
> +	/*
> +	 * Any of the original initrd which overlaps the linear map should
> +	 * be freed after relocating.
> +	 */
> +	if (orig_start < ram_end)
> +		to_free = ram_end - orig_start;
> +
> +	size = orig_end - orig_start;
> +
> +	/* initrd needs to be relocated completely inside linear mapping */
> +	new_start = memblock_find_in_range(0, PFN_PHYS(max_pfn),
> +					   size, PAGE_SIZE);
> +	if (!new_start)
> +		panic("Cannot relocate initrd of size %ld\n", size);
> +	memblock_reserve(new_start, size);
> +
> +	initrd_start = __phys_to_virt(new_start);
> +	initrd_end   = initrd_start + size;
> +
> +	pr_info("Moving initrd from [%llx-%llx] to [%llx-%llx]\n",
> +		orig_start, orig_start + size - 1,
> +		new_start, new_start + size - 1);
> +
> +	dest = (void *)initrd_start;
> +
> +	if (to_free) {
> +		memcpy(dest, (void *)__phys_to_virt(orig_start), to_free);
> +		dest += to_free;
> +	}
> +
> +	copy_from_early_mem(dest, orig_start + to_free, size - to_free);
> +
> +	if (to_free) {
> +		pr_info("Freeing original RAMDISK from [%llx-%llx]\n",
> +			orig_start, orig_start + to_free - 1);
> +		memblock_free(orig_start, to_free);
> +	}
> +}
> +#else
> +static inline void __init relocate_initrd(void)
> +{
> +}
> +#endif
> +
>  u64 __cpu_logical_map[NR_CPUS] = { [0 ... NR_CPUS-1] = INVALID_HWID };
>  
>  void __init setup_arch(char **cmdline_p)
> @@ -392,6 +453,7 @@ void __init setup_arch(char **cmdline_p)
>  	acpi_boot_table_init();
>  
>  	paging_init();
> +	relocate_initrd();
>  	request_standard_resources();
>  
>  	early_ioremap_reset();
> -- 
> 2.4.3
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
