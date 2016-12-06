Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5E4B36B0069
	for <linux-mm@kvack.org>; Tue,  6 Dec 2016 12:45:33 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id x23so32477217pgx.6
        for <linux-mm@kvack.org>; Tue, 06 Dec 2016 09:45:33 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id s199si20287586pgs.43.2016.12.06.09.45.32
        for <linux-mm@kvack.org>;
        Tue, 06 Dec 2016 09:45:32 -0800 (PST)
Date: Tue, 6 Dec 2016 17:44:44 +0000
From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: [PATCHv4 08/10] mm/kasan: Switch to using __pa_symbol and
 lm_alias
Message-ID: <20161206174443.GG24177@leverpostej>
References: <1480445729-27130-1-git-send-email-labbott@redhat.com>
 <1480445729-27130-9-git-send-email-labbott@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1480445729-27130-9-git-send-email-labbott@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <labbott@redhat.com>
Cc: Ard Biesheuvel <ard.biesheuvel@linaro.org>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-arm-kernel@lists.infradead.org, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, kasan-dev@googlegroups.com

On Tue, Nov 29, 2016 at 10:55:27AM -0800, Laura Abbott wrote:
> __pa_symbol is the correct API to find the physical address of symbols.
> Switch to it to allow for debugging APIs to work correctly. Other
> functions such as p*d_populate may call __pa internally. Ensure that the
> address passed is in the linear region by calling lm_alias.

I've given this a go on Juno with CONFIG_KASAN_INLINE enabled, and
everything seems happy.

We'll need an include of <linux/mm.h> as that appears to be missing. I
guess we're getting lucky with transitive includes. Otherwise this looks
good to me.

With that fixed up:

Reviewed-by: Mark Rutland <mark.rutland@arm.com>
Tested-by: Mark Rutland <mark.rutland@arm.com>

Thanks,
Mark.

> Signed-off-by: Laura Abbott <labbott@redhat.com>
> ---
> Pointed out during review/testing of v3.
> ---
>  mm/kasan/kasan_init.c | 12 ++++++------
>  1 file changed, 6 insertions(+), 6 deletions(-)
> 
> diff --git a/mm/kasan/kasan_init.c b/mm/kasan/kasan_init.c
> index 3f9a41c..ff04721 100644
> --- a/mm/kasan/kasan_init.c
> +++ b/mm/kasan/kasan_init.c
> @@ -49,7 +49,7 @@ static void __init zero_pte_populate(pmd_t *pmd, unsigned long addr,
>  	pte_t *pte = pte_offset_kernel(pmd, addr);
>  	pte_t zero_pte;
>  
> -	zero_pte = pfn_pte(PFN_DOWN(__pa(kasan_zero_page)), PAGE_KERNEL);
> +	zero_pte = pfn_pte(PFN_DOWN(__pa_symbol(kasan_zero_page)), PAGE_KERNEL);
>  	zero_pte = pte_wrprotect(zero_pte);
>  
>  	while (addr + PAGE_SIZE <= end) {
> @@ -69,7 +69,7 @@ static void __init zero_pmd_populate(pud_t *pud, unsigned long addr,
>  		next = pmd_addr_end(addr, end);
>  
>  		if (IS_ALIGNED(addr, PMD_SIZE) && end - addr >= PMD_SIZE) {
> -			pmd_populate_kernel(&init_mm, pmd, kasan_zero_pte);
> +			pmd_populate_kernel(&init_mm, pmd, lm_alias(kasan_zero_pte));
>  			continue;
>  		}
>  
> @@ -94,7 +94,7 @@ static void __init zero_pud_populate(pgd_t *pgd, unsigned long addr,
>  
>  			pud_populate(&init_mm, pud, kasan_zero_pmd);
>  			pmd = pmd_offset(pud, addr);
> -			pmd_populate_kernel(&init_mm, pmd, kasan_zero_pte);
> +			pmd_populate_kernel(&init_mm, pmd, lm_alias(kasan_zero_pte));
>  			continue;
>  		}
>  
> @@ -135,11 +135,11 @@ void __init kasan_populate_zero_shadow(const void *shadow_start,
>  			 * puds,pmds, so pgd_populate(), pud_populate()
>  			 * is noops.
>  			 */
> -			pgd_populate(&init_mm, pgd, kasan_zero_pud);
> +			pgd_populate(&init_mm, pgd, lm_alias(kasan_zero_pud));
>  			pud = pud_offset(pgd, addr);
> -			pud_populate(&init_mm, pud, kasan_zero_pmd);
> +			pud_populate(&init_mm, pud, lm_alias(kasan_zero_pmd));
>  			pmd = pmd_offset(pud, addr);
> -			pmd_populate_kernel(&init_mm, pmd, kasan_zero_pte);
> +			pmd_populate_kernel(&init_mm, pmd, lm_alias(kasan_zero_pte));
>  			continue;
>  		}
>  
> -- 
> 2.7.4
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
