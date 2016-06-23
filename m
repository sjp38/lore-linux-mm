Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id B52546B025E
	for <linux-mm@kvack.org>; Thu, 23 Jun 2016 08:42:36 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id ao6so140191540pac.2
        for <linux-mm@kvack.org>; Thu, 23 Jun 2016 05:42:36 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id n17si6721166pfi.210.2016.06.23.05.42.35
        for <linux-mm@kvack.org>;
        Thu, 23 Jun 2016 05:42:35 -0700 (PDT)
Date: Thu, 23 Jun 2016 13:42:30 +0100
From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: [PATCH 2/2] arm64:acpi Fix the acpi alignment exeception when
 'mem=' specified
Message-ID: <20160623124229.GD8836@leverpostej>
References: <1466681415-8058-1-git-send-email-dennis.chen@arm.com>
 <1466681415-8058-2-git-send-email-dennis.chen@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1466681415-8058-2-git-send-email-dennis.chen@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dennis Chen <dennis.chen@arm.com>
Cc: linux-arm-kernel@lists.infradead.org, nd@arm.com, Catalin Marinas <catalin.marinas@arm.com>, Steve Capper <steve.capper@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Will Deacon <will.deacon@arm.com>, "Rafael J . Wysocki" <rafael.j.wysocki@intel.com>, Matt Fleming <matt@codeblueprint.co.uk>, linux-mm@kvack.org, linux-acpi@vger.kernel.org, linux-efi@vger.kernel.org

On Thu, Jun 23, 2016 at 07:30:15PM +0800, Dennis Chen wrote:
> This is a rework patch based on [1]. According to the proposal from
> Mark Rutland, when applying the system memory limit through 'mem=x'
> kernel command line, don't remove the rest memory regions above the
> limit from the memblock, instead marking them as MEMBLOCK_NOMAP region,
> which will preserve the ability to identify regions as normal memory
> while not using them for allocation and the linear map.
> 
> Without this patch, the ACPI core will map those acpi data regions(if
> they are above the limit) as device type memory, which will result in
> the alignment exception when ACPI core parses the AML data stream 
> since the parsing will produce some non-alignment accesses.
>
> [1]:http://lists.infradead.org/pipermail/linux-arm-kernel/2016-June/438443.html

Please rewrite the message to be standalone (i.e. so peopel can read
this without having to folow the link).

Explain why using mem= makes ACPI think regions should be mapped as
Device memory, the problems this causes for ACPICA, then cover why we
want to nomap the region.

> Signed-off-by: Dennis Chen <dennis.chen@arm.com>
> Cc: Catalin Marinas <catalin.marinas@arm.com>
> Cc: Steve Capper <steve.capper@arm.com>
> Cc: Ard Biesheuvel <ard.biesheuvel@linaro.org>
> Cc: Will Deacon <will.deacon@arm.com>
> Cc: Mark Rutland <mark.rutland@arm.com>
> Cc: Rafael J. Wysocki <rafael.j.wysocki@intel.com>
> Cc: Matt Fleming <matt@codeblueprint.co.uk>
> Cc: linux-mm@kvack.org
> Cc: linux-acpi@vger.kernel.org
> Cc: linux-efi@vger.kernel.org
> ---
>  arch/arm64/mm/init.c | 10 ++++++----
>  1 file changed, 6 insertions(+), 4 deletions(-)
> 
> diff --git a/arch/arm64/mm/init.c b/arch/arm64/mm/init.c
> index d45f862..e509e24 100644
> --- a/arch/arm64/mm/init.c
> +++ b/arch/arm64/mm/init.c
> @@ -222,12 +222,14 @@ void __init arm64_memblock_init(void)
>  
>  	/*
>  	 * Apply the memory limit if it was set. Since the kernel may be loaded
> -	 * high up in memory, add back the kernel region that must be accessible
> -	 * via the linear mapping.
> +	 * in the memory regions above the limit, so we need to clear the
> +	 * MEMBLOCK_NOMAP flag of this region to make it can be accessible via
> +	 * the linear mapping.
>  	 */
>  	if (memory_limit != (phys_addr_t)ULLONG_MAX) {
> -		memblock_enforce_memory_limit(memory_limit);
> -		memblock_add(__pa(_text), (u64)(_end - _text));
> +		memblock_mem_limit_mark_nomap(memory_limit);
> +		if (!memblock_is_map_memory(__pa(_text)))
> +			memblock_clear_nomap(__pa(_text), (u64)(_end - _text));

I think that the memblock_is_map_memory() check should go. Just because
a page of the kernel image is mapped doesn't mean that the rest is. That
will make this a 1-1 change.

Other than that, this looks right to me.

Thanks,
Mark.

>  	}
>  
>  	if (IS_ENABLED(CONFIG_BLK_DEV_INITRD) && initrd_start) {
> -- 
> 1.8.3.1
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
