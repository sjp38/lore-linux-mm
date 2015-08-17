Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id D690A6B0253
	for <linux-mm@kvack.org>; Mon, 17 Aug 2015 07:23:02 -0400 (EDT)
Received: by paccq16 with SMTP id cq16so63185753pac.1
        for <linux-mm@kvack.org>; Mon, 17 Aug 2015 04:23:02 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id fr12si15099324pdb.2.2015.08.17.04.23.01
        for <linux-mm@kvack.org>;
        Mon, 17 Aug 2015 04:23:01 -0700 (PDT)
Date: Mon, 17 Aug 2015 12:22:56 +0100
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH V3 2/3] arm64: support initrd outside kernel linear map
Message-ID: <20150817112256.GH1688@arm.com>
References: <1439758168-29427-1-git-send-email-msalter@redhat.com>
 <1439758168-29427-3-git-send-email-msalter@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1439758168-29427-3-git-send-email-msalter@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mark Salter <msalter@redhat.com>
Cc: Catalin Marinas <Catalin.Marinas@arm.com>, "x86@kernel.org" <x86@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Mark Rutland <Mark.Rutland@arm.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>

Hi Mark,

On Sun, Aug 16, 2015 at 09:49:27PM +0100, Mark Salter wrote:
> The use of mem= could leave part or all of the initrd outside of
> the kernel linear map. This will lead to an error when unpacking
> the initrd and a probable failure to boot. This patch catches that
> situation and relocates the initrd to be fully within the linear
> map.
> 
> Signed-off-by: Mark Salter <msalter@redhat.com>
> ---
>  arch/arm64/kernel/setup.c | 59 +++++++++++++++++++++++++++++++++++++++++++++++
>  1 file changed, 59 insertions(+)
> 
> diff --git a/arch/arm64/kernel/setup.c b/arch/arm64/kernel/setup.c
> index f3067d4..5f45fd9 100644
> --- a/arch/arm64/kernel/setup.c
> +++ b/arch/arm64/kernel/setup.c
> @@ -359,6 +359,64 @@ static void __init request_standard_resources(void)
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

Any particular reason to use the __* variants here?

> +	phys_addr_t ram_end = memblock_end_of_DRAM();
> +	phys_addr_t new_start;
> +	unsigned long size, to_free = 0;
> +	void *dest;
> +
> +	if (orig_end <= ram_end)
> +		return;
> +
> +	/* Note if any of original initrd will freeing below */

The comment doesn't make sense.

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
> +static inline void __init reserve_initrd(void)

relocate_initrd ?

Will

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
