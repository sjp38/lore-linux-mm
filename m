Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id A85976B0038
	for <linux-mm@kvack.org>; Tue, 11 Aug 2015 11:41:25 -0400 (EDT)
Received: by pdco4 with SMTP id o4so84969816pdc.3
        for <linux-mm@kvack.org>; Tue, 11 Aug 2015 08:41:25 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id v5si4206566pdr.5.2015.08.11.08.41.24
        for <linux-mm@kvack.org>;
        Tue, 11 Aug 2015 08:41:24 -0700 (PDT)
Date: Tue, 11 Aug 2015 16:41:18 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH v5 2/6] x86/kasan, mm: introduce generic
 kasan_populate_zero_shadow()
Message-ID: <20150811154117.GH23307@e104818-lin.cambridge.arm.com>
References: <1439259499-13913-1-git-send-email-ryabinin.a.a@gmail.com>
 <1439259499-13913-3-git-send-email-ryabinin.a.a@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1439259499-13913-3-git-send-email-ryabinin.a.a@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Cc: Will Deacon <will.deacon@arm.com>, linux-arm-kernel@lists.infradead.org, Yury <yury.norov@gmail.com>, Alexey Klimov <klimov.linux@gmail.com>, Arnd Bergmann <arnd@arndb.de>, linux-mm@kvack.org, Linus Walleij <linus.walleij@linaro.org>, x86@kernel.org, linux-kernel@vger.kernel.org, David Keitel <dkeitel@codeaurora.org>, Alexander Potapenko <glider@google.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

On Tue, Aug 11, 2015 at 05:18:15AM +0300, Andrey Ryabinin wrote:
> --- /dev/null
> +++ b/mm/kasan/kasan_init.c
[...]
> +#if CONFIG_PGTABLE_LEVELS > 3
> +pud_t kasan_zero_pud[PTRS_PER_PUD] __page_aligned_bss;
> +#endif
> +#if CONFIG_PGTABLE_LEVELS > 2
> +pmd_t kasan_zero_pmd[PTRS_PER_PMD] __page_aligned_bss;
> +#endif
> +pte_t kasan_zero_pte[PTRS_PER_PTE] __page_aligned_bss;

Is there any problem if you don't add the #ifs here? Wouldn't the linker
remove them if they are not used?

Original hunk copied here for easy comparison:

> -static int __init zero_pte_populate(pmd_t *pmd, unsigned long addr,
> -				unsigned long end)
> -{
> -	pte_t *pte = pte_offset_kernel(pmd, addr);
> -
> -	while (addr + PAGE_SIZE <= end) {
> -		WARN_ON(!pte_none(*pte));
> -		set_pte(pte, __pte(__pa_nodebug(kasan_zero_page)
> -					| __PAGE_KERNEL_RO));
> -		addr += PAGE_SIZE;
> -		pte = pte_offset_kernel(pmd, addr);
> -	}
> -	return 0;
> -}
[...]
> +static void __init zero_pte_populate(pmd_t *pmd, unsigned long addr,
> +				unsigned long end)
> +{
> +	pte_t *pte = pte_offset_kernel(pmd, addr);
> +	pte_t zero_pte;
> +
> +	zero_pte = pfn_pte(PFN_DOWN(__pa(kasan_zero_page)), PAGE_KERNEL);
> +	zero_pte = pte_wrprotect(zero_pte);
> +
> +	while (addr + PAGE_SIZE <= end) {
> +		set_pte_at(&init_mm, addr, pte, zero_pte);
> +		addr += PAGE_SIZE;
> +		pte = pte_offset_kernel(pmd, addr);
> +	}
> +}

I think there are some differences with the original x86 code. The first
one is the use of __pa_nodebug, does it cause any problems if
CONFIG_DEBUG_VIRTUAL is enabled?

The second is the use of a read-only attribute when mapping
kasan_zero_page on x86. Can it cope with a writable mapping?

If there are no issues, it should be documented in the commit log.

-- 
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
