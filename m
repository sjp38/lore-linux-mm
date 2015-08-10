Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id AD4206B0253
	for <linux-mm@kvack.org>; Mon, 10 Aug 2015 08:00:08 -0400 (EDT)
Received: by wicja10 with SMTP id ja10so34129588wic.1
        for <linux-mm@kvack.org>; Mon, 10 Aug 2015 05:00:08 -0700 (PDT)
Received: from mail-wi0-x242.google.com (mail-wi0-x242.google.com. [2a00:1450:400c:c05::242])
        by mx.google.com with ESMTPS id jc5si15696763wic.74.2015.08.10.05.00.06
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Aug 2015 05:00:06 -0700 (PDT)
Received: by wibvo3 with SMTP id vo3so20946083wib.3
        for <linux-mm@kvack.org>; Mon, 10 Aug 2015 05:00:06 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <87mvxzptqv.fsf@linux.vnet.ibm.com>
References: <1437756119-12817-1-git-send-email-a.ryabinin@samsung.com>
	<1437756119-12817-3-git-send-email-a.ryabinin@samsung.com>
	<87mvxzptqv.fsf@linux.vnet.ibm.com>
Date: Mon, 10 Aug 2015 15:00:05 +0300
Message-ID: <CAPAsAGwsA138f=oNaqJ4qT6Ow9VyoSqAkwZSa_pCDJVsA-JuAg@mail.gmail.com>
Subject: Re: [PATCH v4 2/7] mm: kasan: introduce generic kasan_populate_zero_shadow()
From: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, linux-arm-kernel@lists.infradead.org, Arnd Bergmann <arnd@arndb.de>, Linus Walleij <linus.walleij@linaro.org>, David Keitel <dkeitel@codeaurora.org>, Alexander Potapenko <glider@google.com>, Andrew Morton <akpm@linux-foundation.org>, Dmitry Vyukov <dvyukov@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Alexey Klimov <klimov.linux@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, "x86@kernel.org" <x86@kernel.org>

2015-08-10 9:01 GMT+03:00 Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>:
> Andrey Ryabinin <a.ryabinin@samsung.com> writes:
>
>> Introduce generic kasan_populate_zero_shadow(start, end).
>> This function maps kasan_zero_page to the [start, end] addresses.
>>
>> In follow on patches it will be used for ARMv8 (and maybe other
>> architectures) and will replace x86_64 specific populate_zero_shadow().
>>
>> Signed-off-by: Andrey Ryabinin <a.ryabinin@samsung.com>
>
> This assume that we can have shared pgtable_t in generic code ? Is that
> true for generic code ? Even if it is we may want to allow some arch to
> override this ? On ppc64, we store the hardware hash page table slot
> number in pte_t, Hence we won't be able to share pgtable_t.
>

So, ppc64 could define some config which will disable compilation of
mm/kasan/kasan_init.c.
However, it might be a bad idea to use such never defined config symbol now.
So I think this could be done later, in "KASAN for powerpc" series.

>
>
>> ---
>>  arch/x86/mm/kasan_init_64.c |  14 ----
>>  include/linux/kasan.h       |   8 +++
>>  mm/kasan/Makefile           |   2 +-
>>  mm/kasan/kasan_init.c       | 151 ++++++++++++++++++++++++++++++++++++++++++++
>>  4 files changed, 160 insertions(+), 15 deletions(-)
>>  create mode 100644 mm/kasan/kasan_init.c
>>
>> diff --git a/arch/x86/mm/kasan_init_64.c b/arch/x86/mm/kasan_init_64.c
>> index e1840f3..812086c 100644
>> --- a/arch/x86/mm/kasan_init_64.c
>> +++ b/arch/x86/mm/kasan_init_64.c
>> @@ -12,20 +12,6 @@
>>  extern pgd_t early_level4_pgt[PTRS_PER_PGD];
>>  extern struct range pfn_mapped[E820_X_MAX];
>>
>> -static pud_t kasan_zero_pud[PTRS_PER_PUD] __page_aligned_bss;
>> -static pmd_t kasan_zero_pmd[PTRS_PER_PMD] __page_aligned_bss;
>> -static pte_t kasan_zero_pte[PTRS_PER_PTE] __page_aligned_bss;
>> -
>> -/*
>
> -aneesh
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
