Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f177.google.com (mail-lb0-f177.google.com [209.85.217.177])
	by kanga.kvack.org (Postfix) with ESMTP id 298E86B0038
	for <linux-mm@kvack.org>; Tue, 11 Aug 2015 12:25:18 -0400 (EDT)
Received: by lbbpu9 with SMTP id pu9so89135386lbb.3
        for <linux-mm@kvack.org>; Tue, 11 Aug 2015 09:25:17 -0700 (PDT)
Received: from mail-lb0-x230.google.com (mail-lb0-x230.google.com. [2a00:1450:4010:c04::230])
        by mx.google.com with ESMTPS id h9si1705469lam.85.2015.08.11.09.25.15
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Aug 2015 09:25:16 -0700 (PDT)
Received: by lbbsx3 with SMTP id sx3so32895668lbb.0
        for <linux-mm@kvack.org>; Tue, 11 Aug 2015 09:25:15 -0700 (PDT)
Subject: Re: [PATCH v5 2/6] x86/kasan, mm: introduce generic
 kasan_populate_zero_shadow()
References: <1439259499-13913-1-git-send-email-ryabinin.a.a@gmail.com>
 <1439259499-13913-3-git-send-email-ryabinin.a.a@gmail.com>
 <20150811154117.GH23307@e104818-lin.cambridge.arm.com>
From: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Message-ID: <55CA21E8.2060704@gmail.com>
Date: Tue, 11 Aug 2015 19:25:12 +0300
MIME-Version: 1.0
In-Reply-To: <20150811154117.GH23307@e104818-lin.cambridge.arm.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Will Deacon <will.deacon@arm.com>, linux-arm-kernel@lists.infradead.org, Yury <yury.norov@gmail.com>, Alexey Klimov <klimov.linux@gmail.com>, Arnd Bergmann <arnd@arndb.de>, linux-mm@kvack.org, Linus Walleij <linus.walleij@linaro.org>, x86@kernel.org, linux-kernel@vger.kernel.org, David Keitel <dkeitel@codeaurora.org>, Alexander Potapenko <glider@google.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>



On 08/11/2015 06:41 PM, Catalin Marinas wrote:
> On Tue, Aug 11, 2015 at 05:18:15AM +0300, Andrey Ryabinin wrote:
>> --- /dev/null
>> +++ b/mm/kasan/kasan_init.c
> [...]
>> +#if CONFIG_PGTABLE_LEVELS > 3
>> +pud_t kasan_zero_pud[PTRS_PER_PUD] __page_aligned_bss;
>> +#endif
>> +#if CONFIG_PGTABLE_LEVELS > 2
>> +pmd_t kasan_zero_pmd[PTRS_PER_PMD] __page_aligned_bss;
>> +#endif
>> +pte_t kasan_zero_pte[PTRS_PER_PTE] __page_aligned_bss;
> 
> Is there any problem if you don't add the #ifs here? Wouldn't the linker
> remove them if they are not used?
> 


> Original hunk copied here for easy comparison:
> 
>> -static int __init zero_pte_populate(pmd_t *pmd, unsigned long addr,
>> -				unsigned long end)
>> -{
>> -	pte_t *pte = pte_offset_kernel(pmd, addr);
>> -
>> -	while (addr + PAGE_SIZE <= end) {
>> -		WARN_ON(!pte_none(*pte));
>> -		set_pte(pte, __pte(__pa_nodebug(kasan_zero_page)
>> -					| __PAGE_KERNEL_RO));
>> -		addr += PAGE_SIZE;
>> -		pte = pte_offset_kernel(pmd, addr);
>> -	}
>> -	return 0;
>> -}
> [...]
>> +static void __init zero_pte_populate(pmd_t *pmd, unsigned long addr,
>> +				unsigned long end)
>> +{
>> +	pte_t *pte = pte_offset_kernel(pmd, addr);
>> +	pte_t zero_pte;
>> +
>> +	zero_pte = pfn_pte(PFN_DOWN(__pa(kasan_zero_page)), PAGE_KERNEL);
>> +	zero_pte = pte_wrprotect(zero_pte);
>> +
>> +	while (addr + PAGE_SIZE <= end) {
>> +		set_pte_at(&init_mm, addr, pte, zero_pte);
>> +		addr += PAGE_SIZE;
>> +		pte = pte_offset_kernel(pmd, addr);
>> +	}
>> +}
> 
> I think there are some differences with the original x86 code. The first
> one is the use of __pa_nodebug, does it cause any problems if
> CONFIG_DEBUG_VIRTUAL is enabled?
> 
__pa_nodebug() should be used before kasan_early_init(), this piece of code
executed far later, so it's ok to use __pa() here.
This was actually a mistake in original code to use __pa_nodebug().

> The second is the use of a read-only attribute when mapping
> kasan_zero_page on x86. Can it cope with a writable mapping?
> 

Did you miss this line:

+	zero_pte = pte_wrprotect(zero_pte);

?


> If there are no issues, it should be documented in the commit log.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
