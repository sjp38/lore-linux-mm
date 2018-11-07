Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f198.google.com (mail-oi1-f198.google.com [209.85.167.198])
	by kanga.kvack.org (Postfix) with ESMTP id 75F046B0529
	for <linux-mm@kvack.org>; Wed,  7 Nov 2018 12:09:05 -0500 (EST)
Received: by mail-oi1-f198.google.com with SMTP id n82-v6so11096967oih.8
        for <linux-mm@kvack.org>; Wed, 07 Nov 2018 09:09:05 -0800 (PST)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id g15si472159otl.80.2018.11.07.09.09.04
        for <linux-mm@kvack.org>;
        Wed, 07 Nov 2018 09:09:04 -0800 (PST)
Date: Wed, 7 Nov 2018 17:08:55 +0000
From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: [PATCH v10 07/22] kasan: initialize shadow to 0xff for tag-based
 mode
Message-ID: <20181107170855.n4ertf5qv7ff5btl@lakrids.cambridge.arm.com>
References: <cover.1541525354.git.andreyknvl@google.com>
 <9405f32797b52616cd0746bcea37df94e8e4256a.1541525354.git.andreyknvl@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <9405f32797b52616cd0746bcea37df94e8e4256a.1541525354.git.andreyknvl@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Konovalov <andreyknvl@google.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Nick Desaulniers <ndesaulniers@google.com>, Marc Zyngier <marc.zyngier@arm.com>, Dave Martin <dave.martin@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, "Eric W . Biederman" <ebiederm@xmission.com>, Ingo Molnar <mingo@kernel.org>, Paul Lawrence <paullawrence@google.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Arnd Bergmann <arnd@arndb.de>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Kate Stewart <kstewart@linuxfoundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, kasan-dev@googlegroups.com, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-sparse@vger.kernel.org, linux-mm@kvack.org, linux-kbuild@vger.kernel.org, Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Jann Horn <jannh@google.com>, Mark Brand <markbrand@google.com>, Chintan Pandya <cpandya@codeaurora.org>, Vishwath Mohan <vishwath@google.com>

On Tue, Nov 06, 2018 at 06:30:22PM +0100, Andrey Konovalov wrote:
> A tag-based KASAN shadow memory cell contains a memory tag, that
> corresponds to the tag in the top byte of the pointer, that points to that
> memory. The native top byte value of kernel pointers is 0xff, so with
> tag-based KASAN we need to initialize shadow memory to 0xff.
> 
> Reviewed-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
> Reviewed-by: Dmitry Vyukov <dvyukov@google.com>
> Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
> ---
>  arch/arm64/mm/kasan_init.c | 16 ++++++++++++++--
>  include/linux/kasan.h      |  8 ++++++++
>  mm/kasan/common.c          |  3 ++-
>  3 files changed, 24 insertions(+), 3 deletions(-)
> 
> diff --git a/arch/arm64/mm/kasan_init.c b/arch/arm64/mm/kasan_init.c
> index 63527e585aac..18ebc8994a7b 100644
> --- a/arch/arm64/mm/kasan_init.c
> +++ b/arch/arm64/mm/kasan_init.c
> @@ -43,6 +43,15 @@ static phys_addr_t __init kasan_alloc_zeroed_page(int node)
>  	return __pa(p);
>  }
>  
> +static phys_addr_t __init kasan_alloc_raw_page(int node)
> +{
> +	void *p = memblock_alloc_try_nid_raw(PAGE_SIZE, PAGE_SIZE,
> +						__pa(MAX_DMA_ADDRESS),
> +						MEMBLOCK_ALLOC_ACCESSIBLE,
> +						node);
> +	return __pa(p);
> +}
> +
>  static pte_t *__init kasan_pte_offset(pmd_t *pmdp, unsigned long addr, int node,
>  				      bool early)
>  {
> @@ -88,7 +97,9 @@ static void __init kasan_pte_populate(pmd_t *pmdp, unsigned long addr,
>  
>  	do {
>  		phys_addr_t page_phys = early ? __pa_symbol(kasan_zero_page)
> -					      : kasan_alloc_zeroed_page(node);
> +					      : kasan_alloc_raw_page(node);
> +		if (!early)
> +			memset(__va(page_phys), KASAN_SHADOW_INIT, PAGE_SIZE);
>  		next = addr + PAGE_SIZE;
>  		set_pte(ptep, pfn_pte(__phys_to_pfn(page_phys), PAGE_KERNEL));
>  	} while (ptep++, addr = next, addr != end && pte_none(READ_ONCE(*ptep)));
> @@ -138,6 +149,7 @@ asmlinkage void __init kasan_early_init(void)
>  		KASAN_SHADOW_END - (1UL << (64 - KASAN_SHADOW_SCALE_SHIFT)));
>  	BUILD_BUG_ON(!IS_ALIGNED(KASAN_SHADOW_START, PGDIR_SIZE));
>  	BUILD_BUG_ON(!IS_ALIGNED(KASAN_SHADOW_END, PGDIR_SIZE));
> +
>  	kasan_pgd_populate(KASAN_SHADOW_START, KASAN_SHADOW_END, NUMA_NO_NODE,
>  			   true);
>  }
> @@ -234,7 +246,7 @@ void __init kasan_init(void)
>  		set_pte(&kasan_zero_pte[i],
>  			pfn_pte(sym_to_pfn(kasan_zero_page), PAGE_KERNEL_RO));
>  
> -	memset(kasan_zero_page, 0, PAGE_SIZE);
> +	memset(kasan_zero_page, KASAN_SHADOW_INIT, PAGE_SIZE);

If this isn't going to contain zero, can we please have a preparatory
patch renaming this to something which isn't misleading?

Perhaps kasan_common_shadow_page?

Thanks,
Mark.
