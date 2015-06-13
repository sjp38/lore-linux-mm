Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f45.google.com (mail-oi0-f45.google.com [209.85.218.45])
	by kanga.kvack.org (Postfix) with ESMTP id E0AAF6B0038
	for <linux-mm@kvack.org>; Sat, 13 Jun 2015 11:25:23 -0400 (EDT)
Received: by oihd6 with SMTP id d6so36696839oih.2
        for <linux-mm@kvack.org>; Sat, 13 Jun 2015 08:25:23 -0700 (PDT)
Received: from mail-ob0-f174.google.com (mail-ob0-f174.google.com. [209.85.214.174])
        by mx.google.com with ESMTPS id go5si3827271obb.42.2015.06.13.08.25.22
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 13 Jun 2015 08:25:22 -0700 (PDT)
Received: by obbgp2 with SMTP id gp2so39416659obb.2
        for <linux-mm@kvack.org>; Sat, 13 Jun 2015 08:25:22 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAPAsAGy-r8Z2N09wKV+e0kLfbwxd-eWK6N5Xajsnqq9jfyWqcQ@mail.gmail.com>
References: <1431698344-28054-1-git-send-email-a.ryabinin@samsung.com>
	<1431698344-28054-6-git-send-email-a.ryabinin@samsung.com>
	<CACRpkdaRJJjCXR=vK1M2YhR26JZfGoBB+jcqz8r2MhERfxRzqA@mail.gmail.com>
	<CAPAsAGy-r8Z2N09wKV+e0kLfbwxd-eWK6N5Xajsnqq9jfyWqcQ@mail.gmail.com>
Date: Sat, 13 Jun 2015 17:25:22 +0200
Message-ID: <CACRpkdZmHLMxosLXjyOPdkavo=UNzmTcHOLF5vV4cS1ULfbq6A@mail.gmail.com>
Subject: Re: [PATCH v2 5/5] arm64: add KASan support
From: Linus Walleij <linus.walleij@linaro.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Cc: Andrey Ryabinin <a.ryabinin@samsung.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Dmitry Vyukov <dvyukov@google.com>, Alexander Potapenko <glider@google.com>, David Keitel <dkeitel@codeaurora.org>, Arnd Bergmann <arnd@arndb.de>, Andrew Morton <akpm@linux-foundation.org>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Fri, Jun 12, 2015 at 8:14 PM, Andrey Ryabinin <ryabinin.a.a@gmail.com> wrote:
> 2015-06-11 16:39 GMT+03:00 Linus Walleij <linus.walleij@linaro.org>:
>> On Fri, May 15, 2015 at 3:59 PM, Andrey Ryabinin <a.ryabinin@samsung.com> wrote:
>>
>>> This patch adds arch specific code for kernel address sanitizer
>>> (see Documentation/kasan.txt).
>>
>> I looked closer at this again ... I am trying to get KASan up for
>> ARM(32) with some tricks and hacks.
>>
>
> I have some patches for that. They still need some polishing, but works for me.
> I could share after I get back to office on Tuesday.

OK! I'd be happy to test!

I have a WIP patch too, but it was trying to do a physical carveout
at early boot because of misunderstandings as to how KASan works...
Yeah I'm a slow learner.

>>> +/*
>>> + * KASAN_SHADOW_START: beginning of the kernel virtual addresses.
>>> + * KASAN_SHADOW_END: KASAN_SHADOW_START + 1/8 of kernel virtual addresses.
>>> + */
>>> +#define KASAN_SHADOW_START      (UL(0xffffffffffffffff) << (VA_BITS))
>>> +#define KASAN_SHADOW_END        (KASAN_SHADOW_START + (1UL << (VA_BITS - 3)))
>>
>> Will this not mean that shadow start to end actually covers *all*
>> virtual addresses including userspace and what not? However a
>> large portion of this shadow memory will be unused because the
>> SHADOW_OFFSET only works for code compiled for the kernel
>> anyway.
>>
>
> SHADOW_OFFSET:SHADOW_END - covers *all* 64bits of virtual addresses.
> SHADOW_OFFSET:SHADOW_START - unused shadow.
> SHADOW_START:SHADOW_END - covers only kernel virtual addresses (used shadow).

Aha. I see now...

>> When working on ARM32 I certainly could not map
>> (1UL << (VA_BITS -3)) i.e. for 32 bit (1UL << 29) bytes (512 MB) of
>
> Why not? We can just take it from TASK_SIZE.

Yeah the idea to steal it from userspace occured to me too...
with ARM32 having a highmem split in the middle of vmalloc I was
quite stressed when trying to chisel it out from the vmalloc area.

I actually managed to remove all static iomaps from my platform
so I could allocate the KASan memory from high to log addresses
at 0xf7000000-0xff000000 but it puts requirements on all
the ARM32 platforms to rid their static maps :P

>> Is it correct that when the pte's, pgd's and pud's are populated
>> KASan really doesn't kick in, it's just done to have some scratch
>> memory with whatever contents so as to do dummy updates
>> for the __asan_loadN() and __asan_storeN() calls, and no checks
>> start until the shadow memory is populated in kasan_init()
>> i.e. there are no KASan checks for any code executing up
>> to that point, just random writes and reads?
>
> Yes, kasan_early_init() setups scratch memory with whatever contents.
> But  KASan checks shadow before kasan_init(), that's the reason why we
> need scratch shadow.
>
> So checks are performed, but KASan don't print any reports, because
> init_task has non-zero kasan_depth flag (see include/linux/init_task.h)
> We check that flag in kasan_report() and print report iff it have zero value.
>
> In kasan_init() after shadow populated, we enable reports by setting
> kasan_depth to zero.

Aha now I understand how this works! Now I understand
this init_task.kasan_depth = 0 too.

>> Are we just lucky that these functions never do any loads
>> and stores?
>>
>
> We relay on fact that these functions are static inline and do not call other
> functions from other (instrumented) files.

Aha, makes perfect sense.

I think I understand the code a bit now ... it maps all the KASan
shadow memory to the physical memory of the zero page and let all
updates hit that memory until the memory manager is up and running,
then you allocate physical memory backing the shadow in
kasan_populate_zero_shadow().

I misunderstood it such that the backing physical shadow memory
had to be available when we do the early call... no wonder I
got lost.

Yours,
Linus Walleij

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
