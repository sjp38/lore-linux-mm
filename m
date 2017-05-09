Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 82D25831FD
	for <linux-mm@kvack.org>; Tue,  9 May 2017 19:16:15 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id f96so5983019qki.14
        for <linux-mm@kvack.org>; Tue, 09 May 2017 16:16:15 -0700 (PDT)
Received: from mail-qk0-x242.google.com (mail-qk0-x242.google.com. [2607:f8b0:400d:c09::242])
        by mx.google.com with ESMTPS id k66si1381914qkf.319.2017.05.09.16.16.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 May 2017 16:16:14 -0700 (PDT)
Received: by mail-qk0-x242.google.com with SMTP id u75so2295867qka.1
        for <linux-mm@kvack.org>; Tue, 09 May 2017 16:16:14 -0700 (PDT)
Subject: Re: [PATCH v3 2/3] ARM: Silence first allocation with
 CONFIG_ARM_MODULE_PLTS=y
References: <20170427181902.28829-1-f.fainelli@gmail.com>
 <20170427181902.28829-3-f.fainelli@gmail.com>
From: Florian Fainelli <f.fainelli@gmail.com>
Message-ID: <fccefcb2-b711-0589-168a-714e55064279@gmail.com>
Date: Tue, 9 May 2017 16:16:09 -0700
MIME-Version: 1.0
In-Reply-To: <20170427181902.28829-3-f.fainelli@gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russell King <linux@armlinux.org.uk>
Cc: linux-arm-kernel@lists.infradead.org, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, zijun_hu <zijun_hu@htc.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Chris Wilson <chris@chris-wilson.co.uk>, open list <linux-kernel@vger.kernel.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, angus@angusclark.org

On 04/27/2017 11:19 AM, Florian Fainelli wrote:
> When CONFIG_ARM_MODULE_PLTS is enabled, the first allocation using the
> module space fails, because the module is too big, and then the module
> allocation is attempted from vmalloc space. Silence the first allocation
> failure in that case by setting __GFP_NOWARN.

Russell, are you okay with this change? Do you have a preference as
which tree should carry this patch series?

Thanks

> 
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
> ---
>  arch/arm/kernel/module.c | 11 +++++++++--
>  1 file changed, 9 insertions(+), 2 deletions(-)
> 
> diff --git a/arch/arm/kernel/module.c b/arch/arm/kernel/module.c
> index 80254b47dc34..3ff571c2c71c 100644
> --- a/arch/arm/kernel/module.c
> +++ b/arch/arm/kernel/module.c
> @@ -40,8 +40,15 @@
>  #ifdef CONFIG_MMU
>  void *module_alloc(unsigned long size)
>  {
> -	void *p = __vmalloc_node_range(size, 1, MODULES_VADDR, MODULES_END,
> -				GFP_KERNEL, PAGE_KERNEL_EXEC, 0, NUMA_NO_NODE,
> +	gfp_t gfp_mask = GFP_KERNEL;
> +	void *p;
> +
> +	/* Silence the initial allocation */
> +	if (IS_ENABLED(CONFIG_ARM_MODULE_PLTS))
> +		gfp_mask |= __GFP_NOWARN;
> +
> +	p = __vmalloc_node_range(size, 1, MODULES_VADDR, MODULES_END,
> +				gfp_mask, PAGE_KERNEL_EXEC, 0, NUMA_NO_NODE,
>  				__builtin_return_address(0));
>  	if (!IS_ENABLED(CONFIG_ARM_MODULE_PLTS) || p)
>  		return p;
> 


-- 
Florian

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
