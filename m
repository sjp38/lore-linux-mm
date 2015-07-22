Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id DC13F6B0258
	for <linux-mm@kvack.org>; Wed, 22 Jul 2015 10:44:51 -0400 (EDT)
Received: by pdjr16 with SMTP id r16so142313492pdj.3
        for <linux-mm@kvack.org>; Wed, 22 Jul 2015 07:44:51 -0700 (PDT)
Received: from mailout4.w1.samsung.com (mailout4.w1.samsung.com. [210.118.77.14])
        by mx.google.com with ESMTPS id nx10si4415405pdb.51.2015.07.22.07.44.50
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 22 Jul 2015 07:44:50 -0700 (PDT)
Received: from eucpsbgm2.samsung.com (unknown [203.254.199.245])
 by mailout4.w1.samsung.com
 (Oracle Communications Messaging Server 7.0.5.31.0 64bit (built May  5 2014))
 with ESMTP id <0NRW00H4I8YM7HC0@mailout4.w1.samsung.com> for
 linux-mm@kvack.org; Wed, 22 Jul 2015 15:44:46 +0100 (BST)
Message-id: <55AFAC5A.5010507@samsung.com>
Date: Wed, 22 Jul 2015 17:44:42 +0300
From: Andrey Ryabinin <a.ryabinin@samsung.com>
MIME-version: 1.0
Subject: Re: [PATCH v3 1/5] mm: kasan: introduce generic
 kasan_populate_zero_shadow()
References: <1437561037-31995-1-git-send-email-a.ryabinin@samsung.com>
 <1437561037-31995-2-git-send-email-a.ryabinin@samsung.com>
 <CALW4P++z9oJhWNCLLOV0xChdbNVuqokEBmzut08XKfQe1viknw@mail.gmail.com>
In-reply-to: 
 <CALW4P++z9oJhWNCLLOV0xChdbNVuqokEBmzut08XKfQe1viknw@mail.gmail.com>
Content-type: text/plain; charset=utf-8
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexey Klimov <klimov.linux@gmail.com>
Cc: Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, linux-arm-kernel@lists.infradead.org, Arnd Bergmann <arnd@arndb.de>, linux-mm@kvack.org, Linus Walleij <linus.walleij@linaro.org>, x86@kernel.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, David Keitel <dkeitel@codeaurora.org>, Ingo Molnar <mingo@redhat.com>, Alexander Potapenko <glider@google.com>, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>, Yury Norov <yury.norov@gmail.com>

On 07/22/2015 05:25 PM, Alexey Klimov wrote:
> Hi Andrey,
> 
> Could you please check minor comments below?
> 
> On Wed, Jul 22, 2015 at 1:30 PM, Andrey Ryabinin <a.ryabinin@samsung.com> wrote:
>> Introduce generic kasan_populate_zero_shadow(start, end).
>> This function maps kasan_zero_page to the [start, end] addresses.
>>
>> In follow on patches it will be used for ARMv8 (and maybe other
>> architectures) and will replace x86_64 specific populate_zero_shadow().
>>
>> Signed-off-by: Andrey Ryabinin <a.ryabinin@samsung.com>
>> ---
>>  arch/x86/mm/kasan_init_64.c |   8 +--
>>  include/linux/kasan.h       |   8 +++
>>  mm/kasan/Makefile           |   2 +-
>>  mm/kasan/kasan_init.c       | 142 ++++++++++++++++++++++++++++++++++++++++++++
>>  4 files changed, 155 insertions(+), 5 deletions(-)
>>  create mode 100644 mm/kasan/kasan_init.c
>>
> 
> [..]
> 
>> diff --git a/mm/kasan/kasan_init.c b/mm/kasan/kasan_init.c
>> new file mode 100644
>> index 0000000..37fb46a
>> --- /dev/null
>> +++ b/mm/kasan/kasan_init.c
>> @@ -0,0 +1,142 @@
>> +#include <linux/bootmem.h>
>> +#include <linux/init.h>
>> +#include <linux/kasan.h>
>> +#include <linux/kernel.h>
>> +#include <linux/memblock.h>
>> +#include <linux/pfn.h>
>> +
>> +#include <asm/page.h>
>> +#include <asm/pgalloc.h>
>> +
> 
> Are you releasing code under GPL?
> Shouldn't there be any license header in such new file?
> 

Sure, will do.

...

>> +
>> +               if (pgd_none(*pgd)) {
>> +                       void *p = early_alloc(PAGE_SIZE, NUMA_NO_NODE);
>> +                       if (!p)
>> +                               return -ENOMEM;
>> +                       pgd_populate(&init_mm, pgd, p);
>> +               }
>> +               zero_pud_populate(pgd, addr, next);
> 
> But you're not checking return value after zero_pud_populate() and
> zero_pmd_populate() that might fail with ENOMEM.
> Is it critical here on init or can they be converted to return void?
> 
I think it's better to convert these functions to void.
BTW, this check after early_alloc() is pointless because early_alloc() will panic
if allocation failed.


> 
>> +/**
>> + * kasan_populate_zero_shadow - populate shadow memory region with
>> + *                               kasan_zero_page
>> + * @start - start of the memory range to populate
>> + * @end   - end of the memory range to populate
>> + */
>> +void __init kasan_populate_zero_shadow(const void *start, const void *end)
>> +{
>> +       if (zero_pgd_populate((unsigned long)start, (unsigned long)end))
>> +               panic("kasan: unable to map zero shadow!");
>> +}
>> --
>> 2.4.5
>>
>>
>> _______________________________________________
>> linux-arm-kernel mailing list
>> linux-arm-kernel@lists.infradead.org
>> http://lists.infradead.org/mailman/listinfo/linux-arm-kernel
> 
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
