Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1E0326B0038
	for <linux-mm@kvack.org>; Wed,  3 May 2017 07:18:17 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id v1so72898904pgv.8
        for <linux-mm@kvack.org>; Wed, 03 May 2017 04:18:17 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id 90si21128021plf.121.2017.05.03.04.18.15
        for <linux-mm@kvack.org>;
        Wed, 03 May 2017 04:18:15 -0700 (PDT)
Date: Wed, 3 May 2017 12:18:16 +0100
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH v3 3/3] arm64: Silence first allocation with
 CONFIG_ARM64_MODULE_PLTS=y
Message-ID: <20170503111814.GF8233@arm.com>
References: <20170427181902.28829-1-f.fainelli@gmail.com>
 <20170427181902.28829-4-f.fainelli@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170427181902.28829-4-f.fainelli@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Cc: linux-arm-kernel@lists.infradead.org, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, zijun_hu <zijun_hu@htc.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Chris Wilson <chris@chris-wilson.co.uk>, open list <linux-kernel@vger.kernel.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, angus@angusclark.org

On Thu, Apr 27, 2017 at 11:19:02AM -0700, Florian Fainelli wrote:
> When CONFIG_ARM64_MODULE_PLTS is enabled, the first allocation using the
> module space fails, because the module is too big, and then the module
> allocation is attempted from vmalloc space. Silence the first allocation
> failure in that case by setting __GFP_NOWARN.
> 
> Reviewed-by: Ard Biesheuvel <ard.biesheuvel@linaro.org>
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
> ---
>  arch/arm64/kernel/module.c | 7 ++++++-
>  1 file changed, 6 insertions(+), 1 deletion(-)

I'm not sure what the merge plan is for these, but the arm64 bit here
looks fine to me:

Acked-by: Will Deacon <will.deacon@arm.com>

Will

> diff --git a/arch/arm64/kernel/module.c b/arch/arm64/kernel/module.c
> index 7f316982ce00..093c13541efb 100644
> --- a/arch/arm64/kernel/module.c
> +++ b/arch/arm64/kernel/module.c
> @@ -32,11 +32,16 @@
>  
>  void *module_alloc(unsigned long size)
>  {
> +	gfp_t gfp_mask = GFP_KERNEL;
>  	void *p;
>  
> +	/* Silence the initial allocation */
> +	if (IS_ENABLED(CONFIG_ARM64_MODULE_PLTS))
> +		gfp_mask |= __GFP_NOWARN;
> +
>  	p = __vmalloc_node_range(size, MODULE_ALIGN, module_alloc_base,
>  				module_alloc_base + MODULES_VSIZE,
> -				GFP_KERNEL, PAGE_KERNEL_EXEC, 0,
> +				gfp_mask, PAGE_KERNEL_EXEC, 0,
>  				NUMA_NO_NODE, __builtin_return_address(0));
>  
>  	if (!p && IS_ENABLED(CONFIG_ARM64_MODULE_PLTS) &&
> -- 
> 2.9.3
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
