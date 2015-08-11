Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id EF37F6B0256
	for <linux-mm@kvack.org>; Tue, 11 Aug 2015 12:40:17 -0400 (EDT)
Received: by pacrr5 with SMTP id rr5so131210460pac.3
        for <linux-mm@kvack.org>; Tue, 11 Aug 2015 09:40:17 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id gt1si4372879pac.153.2015.08.11.09.40.16
        for <linux-mm@kvack.org>;
        Tue, 11 Aug 2015 09:40:17 -0700 (PDT)
Date: Tue, 11 Aug 2015 17:40:11 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH v5 2/6] x86/kasan, mm: introduce generic
 kasan_populate_zero_shadow()
Message-ID: <20150811164010.GJ23307@e104818-lin.cambridge.arm.com>
References: <1439259499-13913-1-git-send-email-ryabinin.a.a@gmail.com>
 <1439259499-13913-3-git-send-email-ryabinin.a.a@gmail.com>
 <20150811154117.GH23307@e104818-lin.cambridge.arm.com>
 <55CA21E8.2060704@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <55CA21E8.2060704@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>, Yury <yury.norov@gmail.com>, Arnd Bergmann <arnd@arndb.de>, linux-mm@kvack.org, Linus Walleij <linus.walleij@linaro.org>, x86@kernel.org, Will Deacon <will.deacon@arm.com>, linux-kernel@vger.kernel.org, Alexey Klimov <klimov.linux@gmail.com>, Ingo Molnar <mingo@redhat.com>, Alexander Potapenko <glider@google.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, David Keitel <dkeitel@codeaurora.org>, Dmitry Vyukov <dvyukov@google.com>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, linux-arm-kernel@lists.infradead.org

On Tue, Aug 11, 2015 at 07:25:12PM +0300, Andrey Ryabinin wrote:
> On 08/11/2015 06:41 PM, Catalin Marinas wrote:
> > On Tue, Aug 11, 2015 at 05:18:15AM +0300, Andrey Ryabinin wrote:
> >> --- /dev/null
> >> +++ b/mm/kasan/kasan_init.c
> > [...]
> >> +#if CONFIG_PGTABLE_LEVELS > 3
> >> +pud_t kasan_zero_pud[PTRS_PER_PUD] __page_aligned_bss;
> >> +#endif
> >> +#if CONFIG_PGTABLE_LEVELS > 2
> >> +pmd_t kasan_zero_pmd[PTRS_PER_PMD] __page_aligned_bss;
> >> +#endif
> >> +pte_t kasan_zero_pte[PTRS_PER_PTE] __page_aligned_bss;
> > 
> > Is there any problem if you don't add the #ifs here? Wouldn't the linker
> > remove them if they are not used?
> 
> > Original hunk copied here for easy comparison:
> > 
> >> -static int __init zero_pte_populate(pmd_t *pmd, unsigned long addr,
> >> -				unsigned long end)
> >> -{
> >> -	pte_t *pte = pte_offset_kernel(pmd, addr);
> >> -
> >> -	while (addr + PAGE_SIZE <= end) {
> >> -		WARN_ON(!pte_none(*pte));
> >> -		set_pte(pte, __pte(__pa_nodebug(kasan_zero_page)
> >> -					| __PAGE_KERNEL_RO));
> >> -		addr += PAGE_SIZE;
> >> -		pte = pte_offset_kernel(pmd, addr);
> >> -	}
> >> -	return 0;
> >> -}
> > [...]
> >> +static void __init zero_pte_populate(pmd_t *pmd, unsigned long addr,
> >> +				unsigned long end)
> >> +{
> >> +	pte_t *pte = pte_offset_kernel(pmd, addr);
> >> +	pte_t zero_pte;
> >> +
> >> +	zero_pte = pfn_pte(PFN_DOWN(__pa(kasan_zero_page)), PAGE_KERNEL);
> >> +	zero_pte = pte_wrprotect(zero_pte);
> >> +
> >> +	while (addr + PAGE_SIZE <= end) {
> >> +		set_pte_at(&init_mm, addr, pte, zero_pte);
> >> +		addr += PAGE_SIZE;
> >> +		pte = pte_offset_kernel(pmd, addr);
> >> +	}
> >> +}
> > 
> > I think there are some differences with the original x86 code. The first
> > one is the use of __pa_nodebug, does it cause any problems if
> > CONFIG_DEBUG_VIRTUAL is enabled?
> 
> __pa_nodebug() should be used before kasan_early_init(), this piece of code
> executed far later, so it's ok to use __pa() here.
> This was actually a mistake in original code to use __pa_nodebug().

OK. So please add a comment in the commit log.

> > The second is the use of a read-only attribute when mapping
> > kasan_zero_page on x86. Can it cope with a writable mapping?
> > 
> 
> Did you miss this line:
> 
> +	zero_pte = pte_wrprotect(zero_pte);

Ah, yes, I missed this.

Anyway, for this patch:

Acked-by: Catalin Marinas <catalin.marinas@arm.com>

Not sure how you plan to merge it though since there are x86
dependencies. I could send the whole series via tip or the mm tree (and
I guess it's pretty late for 4.3).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
