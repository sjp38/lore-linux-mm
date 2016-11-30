Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id CFF736B0272
	for <linux-mm@kvack.org>; Wed, 30 Nov 2016 12:17:19 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id 3so37162494pgd.3
        for <linux-mm@kvack.org>; Wed, 30 Nov 2016 09:17:19 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id j190si65195689pgd.278.2016.11.30.09.17.18
        for <linux-mm@kvack.org>;
        Wed, 30 Nov 2016 09:17:18 -0800 (PST)
Date: Wed, 30 Nov 2016 17:17:13 +0000
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCHv4 05/10] arm64: Use __pa_symbol for kernel symbols
Message-ID: <20161130171713.GE4439@e104818-lin.cambridge.arm.com>
References: <1480445729-27130-1-git-send-email-labbott@redhat.com>
 <1480445729-27130-6-git-send-email-labbott@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1480445729-27130-6-git-send-email-labbott@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <labbott@redhat.com>
Cc: Mark Rutland <mark.rutland@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Will Deacon <will.deacon@arm.com>, Christoffer Dall <christoffer.dall@linaro.org>, Marc Zyngier <marc.zyngier@arm.com>, Lorenzo Pieralisi <lorenzo.pieralisi@arm.com>, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, linux-arm-kernel@lists.infradead.org, Marek Szyprowski <m.szyprowski@samsung.com>

On Tue, Nov 29, 2016 at 10:55:24AM -0800, Laura Abbott wrote:
> --- a/arch/arm64/include/asm/memory.h
> +++ b/arch/arm64/include/asm/memory.h
> @@ -205,6 +205,8 @@ static inline void *phys_to_virt(phys_addr_t x)
>  #define __va(x)			((void *)__phys_to_virt((phys_addr_t)(x)))
>  #define pfn_to_kaddr(pfn)	__va((pfn) << PAGE_SHIFT)
>  #define virt_to_pfn(x)      __phys_to_pfn(__virt_to_phys((unsigned long)(x)))
> +#define sym_to_pfn(x)	    __phys_to_pfn(__pa_symbol(x))
> +#define lm_alias(x)		__va(__pa_symbol(x))
[...]
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -76,6 +76,10 @@ extern int mmap_rnd_compat_bits __read_mostly;
>  #define page_to_virt(x)	__va(PFN_PHYS(page_to_pfn(x)))
>  #endif
>  
> +#ifndef lm_alias
> +#define lm_alias(x)	__va(__pa_symbol(x))
> +#endif

You can drop the arm64-specific lm_alias macro as it's the same as the
generic one you introduced in the same patch.

-- 
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
