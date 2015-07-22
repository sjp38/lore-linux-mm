Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 933A66B0257
	for <linux-mm@kvack.org>; Wed, 22 Jul 2015 10:34:33 -0400 (EDT)
Received: by pacan13 with SMTP id an13so140934841pac.1
        for <linux-mm@kvack.org>; Wed, 22 Jul 2015 07:34:33 -0700 (PDT)
Received: from mailout1.w1.samsung.com (mailout1.w1.samsung.com. [210.118.77.11])
        by mx.google.com with ESMTPS id n6si4260957pdr.195.2015.07.22.07.34.31
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 22 Jul 2015 07:34:32 -0700 (PDT)
Received: from eucpsbgm2.samsung.com (unknown [203.254.199.245])
 by mailout1.w1.samsung.com
 (Oracle Communications Messaging Server 7.0.5.31.0 64bit (built May  5 2014))
 with ESMTP id <0NRW007SI8HFL8B0@mailout1.w1.samsung.com> for
 linux-mm@kvack.org; Wed, 22 Jul 2015 15:34:27 +0100 (BST)
Message-id: <55AFA9F1.5070703@samsung.com>
Date: Wed, 22 Jul 2015 17:34:25 +0300
From: Andrey Ryabinin <a.ryabinin@samsung.com>
MIME-version: 1.0
Subject: Re: [PATCH v3 1/5] mm: kasan: introduce generic
 kasan_populate_zero_shadow()
References: <1437561037-31995-1-git-send-email-a.ryabinin@samsung.com>
 <1437561037-31995-2-git-send-email-a.ryabinin@samsung.com>
 <20150722141719.GA16627@e104818-lin.cambridge.arm.com>
In-reply-to: <20150722141719.GA16627@e104818-lin.cambridge.arm.com>
Content-type: text/plain; charset=windows-1252
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Will Deacon <will.deacon@arm.com>, linux-arm-kernel@lists.infradead.org, Arnd Bergmann <arnd@arndb.de>, linux-mm@kvack.org, Linus Walleij <linus.walleij@linaro.org>, x86@kernel.org, linux-kernel@vger.kernel.org, David Keitel <dkeitel@codeaurora.org>, Ingo Molnar <mingo@redhat.com>, Alexander Potapenko <glider@google.com>, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

On 07/22/2015 05:17 PM, Catalin Marinas wrote:
> On Wed, Jul 22, 2015 at 01:30:33PM +0300, Andrey Ryabinin wrote:
>> diff --git a/arch/x86/mm/kasan_init_64.c b/arch/x86/mm/kasan_init_64.c
>> index e1840f3..2390dba 100644
>> --- a/arch/x86/mm/kasan_init_64.c
>> +++ b/arch/x86/mm/kasan_init_64.c
>> @@ -12,9 +12,9 @@
>>  extern pgd_t early_level4_pgt[PTRS_PER_PGD];
>>  extern struct range pfn_mapped[E820_X_MAX];
>>  
>> -static pud_t kasan_zero_pud[PTRS_PER_PUD] __page_aligned_bss;
>> -static pmd_t kasan_zero_pmd[PTRS_PER_PMD] __page_aligned_bss;
>> -static pte_t kasan_zero_pte[PTRS_PER_PTE] __page_aligned_bss;
>> +pud_t kasan_zero_pud[PTRS_PER_PUD] __page_aligned_bss;
>> +pmd_t kasan_zero_pmd[PTRS_PER_PMD] __page_aligned_bss;
>> +pte_t kasan_zero_pte[PTRS_PER_PTE] __page_aligned_bss;
>>  
>>  /*
>>   * This page used as early shadow. We don't use empty_zero_page
>> @@ -24,7 +24,7 @@ static pte_t kasan_zero_pte[PTRS_PER_PTE] __page_aligned_bss;
>>   * that allowed to access, but not instrumented by kasan
>>   * (vmalloc/vmemmap ...).
>>   */
>> -static unsigned char kasan_zero_page[PAGE_SIZE] __page_aligned_bss;
>> +unsigned char kasan_zero_page[PAGE_SIZE] __page_aligned_bss;
> 
> Did you lose part of the patch when rebasing? I can see you copied
> kasan_populate_zero_shadow() to the mm code but it's still present in
> the x86 one and the above changes to remove static seem meaningless.
> 
> Or you plan to submit the rest of the x86 code separately?
> 

Yes, I was going to send x86 patch later.
Static has to be removed because this conflicts with kasan_zero_p* declarations in include/linux/kasan.h.

> BTW, you could even move kasan_zero_p[tme]d arrays to mm/.
> 

Makes sense.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
