Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 606326B0266
	for <linux-mm@kvack.org>; Wed, 11 Oct 2017 15:19:24 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id u138so3986001wmu.2
        for <linux-mm@kvack.org>; Wed, 11 Oct 2017 12:19:24 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d17sor904436wra.44.2017.10.11.12.19.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 11 Oct 2017 12:19:23 -0700 (PDT)
Subject: Re: [PATCH 10/11] Change mapping of kasan_zero_page int readonly
References: <20171011082227.20546-1-liuwenliang@huawei.com>
 <20171011082227.20546-11-liuwenliang@huawei.com>
From: Florian Fainelli <f.fainelli@gmail.com>
Message-ID: <c59a7a5a-8168-8409-228a-0e4f841ced98@gmail.com>
Date: Wed, 11 Oct 2017 12:19:13 -0700
MIME-Version: 1.0
In-Reply-To: <20171011082227.20546-11-liuwenliang@huawei.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Abbott Liu <liuwenliang@huawei.com>, linux@armlinux.org.uk, aryabinin@virtuozzo.com, afzal.mohd.ma@gmail.com, labbott@redhat.com, kirill.shutemov@linux.intel.com, mhocko@suse.com, cdall@linaro.org, marc.zyngier@arm.com, catalin.marinas@arm.com, akpm@linux-foundation.org, mawilcox@microsoft.com, tglx@linutronix.de, thgarnie@google.com, keescook@chromium.org, arnd@arndb.de, vladimir.murzin@arm.com, tixy@linaro.org, ard.biesheuvel@linaro.org, robin.murphy@arm.com, mingo@kernel.org, grygorii.strashko@linaro.org
Cc: glider@google.com, dvyukov@google.com, opendmb@gmail.com, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, jiazhenghua@huawei.com, dylix.dailei@huawei.com, zengweilin@huawei.com, heshaoliang@huawei.com

On 10/11/2017 01:22 AM, Abbott Liu wrote:
>  Because the kasan_zero_page(which is used as the shadow
>  region for some memory that KASan doesn't need to track.) won't be writen
>  after kasan_init, so change the mapping of kasan_zero_page into readonly.
> 
> Cc: Andrey Ryabinin <a.ryabinin@samsung.com>
> ---
>  arch/arm/mm/kasan_init.c | 12 ++++++++++++
>  1 file changed, 12 insertions(+)
> 
> diff --git a/arch/arm/mm/kasan_init.c b/arch/arm/mm/kasan_init.c
> index 7cfdc39..c11826a 100644
> --- a/arch/arm/mm/kasan_init.c
> +++ b/arch/arm/mm/kasan_init.c
> @@ -200,6 +200,7 @@ void __init kasan_init(void)
>  {
>  	struct memblock_region *reg;
>  	u64 orig_ttbr0;
> +	int i;

Nit: unsigned int i.

>  
>  	orig_ttbr0 = cpu_get_ttbr(0);
>  
> @@ -243,6 +244,17 @@ void __init kasan_init(void)
>  	create_mapping((unsigned long)kasan_mem_to_shadow((void *)MODULES_VADDR),
>  		(unsigned long)kasan_mem_to_shadow((void *)(PKMAP_BASE+PMD_SIZE)),
>  		NUMA_NO_NODE);
> +
> +	/*
> +	 * KAsan may reuse the contents of kasan_zero_pte directly, so we
> +	 * should make sure that it maps the zero page read-only.
> +	 */
> +	for (i = 0; i < PTRS_PER_PTE; i++)
> +                set_pte_at(&init_mm, KASAN_SHADOW_START + i*PAGE_SIZE,
> +                        &kasan_zero_pte[i], pfn_pte(
> +                                virt_to_pfn(kasan_zero_page),
> +                                __pgprot(_L_PTE_DEFAULT | L_PTE_DIRTY | L_PTE_XN | L_PTE_RDONLY)));
> +	memset(kasan_zero_page, 0, PAGE_SIZE);



>  	cpu_set_ttbr0(orig_ttbr0);
>  	flush_cache_all();
>  	local_flush_bp_all();
> 


-- 
Florian

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
