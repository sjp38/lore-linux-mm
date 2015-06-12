Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f43.google.com (mail-la0-f43.google.com [209.85.215.43])
	by kanga.kvack.org (Postfix) with ESMTP id 40A0E6B0038
	for <linux-mm@kvack.org>; Fri, 12 Jun 2015 14:14:20 -0400 (EDT)
Received: by laew7 with SMTP id w7so25691806lae.1
        for <linux-mm@kvack.org>; Fri, 12 Jun 2015 11:14:19 -0700 (PDT)
Received: from mail-la0-x232.google.com (mail-la0-x232.google.com. [2a00:1450:4010:c03::232])
        by mx.google.com with ESMTPS id t5si4003387lbb.35.2015.06.12.11.14.17
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Jun 2015 11:14:18 -0700 (PDT)
Received: by lacny3 with SMTP id ny3so5829223lac.3
        for <linux-mm@kvack.org>; Fri, 12 Jun 2015 11:14:17 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CACRpkdaRJJjCXR=vK1M2YhR26JZfGoBB+jcqz8r2MhERfxRzqA@mail.gmail.com>
References: <1431698344-28054-1-git-send-email-a.ryabinin@samsung.com>
	<1431698344-28054-6-git-send-email-a.ryabinin@samsung.com>
	<CACRpkdaRJJjCXR=vK1M2YhR26JZfGoBB+jcqz8r2MhERfxRzqA@mail.gmail.com>
Date: Fri, 12 Jun 2015 21:14:17 +0300
Message-ID: <CAPAsAGy-r8Z2N09wKV+e0kLfbwxd-eWK6N5Xajsnqq9jfyWqcQ@mail.gmail.com>
Subject: Re: [PATCH v2 5/5] arm64: add KASan support
From: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Walleij <linus.walleij@linaro.org>
Cc: Andrey Ryabinin <a.ryabinin@samsung.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Dmitry Vyukov <dvyukov@google.com>, Alexander Potapenko <glider@google.com>, David Keitel <dkeitel@codeaurora.org>, Arnd Bergmann <arnd@arndb.de>, Andrew Morton <akpm@linux-foundation.org>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

2015-06-11 16:39 GMT+03:00 Linus Walleij <linus.walleij@linaro.org>:
> On Fri, May 15, 2015 at 3:59 PM, Andrey Ryabinin <a.ryabinin@samsung.com> wrote:
>
>> This patch adds arch specific code for kernel address sanitizer
>> (see Documentation/kasan.txt).
>
> I looked closer at this again ... I am trying to get KASan up for
> ARM(32) with some tricks and hacks.
>

I have some patches for that. They still need some polishing, but works for me.
I could share after I get back to office on Tuesday.


>> +config KASAN_SHADOW_OFFSET
>> +       hex
>> +       default 0xdfff200000000000 if ARM64_VA_BITS_48
>> +       default 0xdffffc8000000000 if ARM64_VA_BITS_42
>> +       default 0xdfffff9000000000 if ARM64_VA_BITS_39
>
> So IIUC these offsets are simply chosen to satisfy the equation
>
>         SHADOW = (void *)((unsigned long)addr >> KASAN_SHADOW_SCALE_SHIFT)
>                 + KASAN_SHADOW_OFFSET;
>
> For all memory that needs to be covered, i.e. kernel text+data,
> modules text+data, any other kernel-mode running code+data.
>
> And it needs to be statically assigned like this because the offset
> is used at compile time.
>
> Atleast that is how I understood it... correct me if wrong.
> (Dunno if all is completely obvious to everyone else in the world...)
>

I think you understood this right.

>> +/*
>> + * KASAN_SHADOW_START: beginning of the kernel virtual addresses.
>> + * KASAN_SHADOW_END: KASAN_SHADOW_START + 1/8 of kernel virtual addresses.
>> + */
>> +#define KASAN_SHADOW_START      (UL(0xffffffffffffffff) << (VA_BITS))
>> +#define KASAN_SHADOW_END        (KASAN_SHADOW_START + (1UL << (VA_BITS - 3)))
>
> Will this not mean that shadow start to end actually covers *all*
> virtual addresses including userspace and what not? However a
> large portion of this shadow memory will be unused because the
> SHADOW_OFFSET only works for code compiled for the kernel
> anyway.
>

SHADOW_OFFSET:SHADOW_END - covers *all* 64bits of virtual addresses.
SHADOW_OFFSET:SHADOW_START - unused shadow.
SHADOW_START:SHADOW_END - covers only kernel virtual addresses (used shadow).


> When working on ARM32 I certainly could not map
> (1UL << (VA_BITS -3)) i.e. for 32 bit (1UL << 29) bytes (512 MB) of

Why not? We can just take it from TASK_SIZE.

> virtual memory for shadow, instead I had to restrict it to the size that
> actually maps the memory used by the kernel.
>

That should work too.

> I tried shrinking it down but it crashed on me so tell me how
> wrong I am ... :)
>
> But here comes the real tricks, where I need some help to
> understand the patch set, maybe some comments should be
> inserted here and there to ease understanding:
>

...

>> +
>> +void __init kasan_early_init(void)
>> +{
>> +       kasan_map_early_shadow(swapper_pg_dir);
>> +       start_kernel();
>> +}
>
> So as far as I can see, kasan_early_init() needs to be called before
> we even run start_kernel() because every memory access would
> crash unless the MMU is set up for the shadow memory.
>

 kasan_early_init() should be called before *any* instrumented function.

> Is it correct that when the pte's, pgd's and pud's are populated
> KASan really doesn't kick in, it's just done to have some scratch
> memory with whatever contents so as to do dummy updates
> for the __asan_loadN() and __asan_storeN() calls, and no checks
> start until the shadow memory is populated in kasan_init()
> i.e. there are no KASan checks for any code executing up
> to that point, just random writes and reads?
>

Yes, kasan_early_init() setups scratch memory with whatever contents.
But  KASan checks shadow before kasan_init(), that's the reason why we
need scratch shadow.
So checks are performed, but KASan don't print any reports, because
init_task has non-zero kasan_depth flag (see include/linux/init_task.h)
We check that flag in kasan_report() and print report iff it have zero value.

In kasan_init() after shadow populated, we enable reports by setting
kasan_depth to zero.


> Also, this code under kasan_early_init(), must that not be
> written extremely carefully to avoid any loads and stores?
> I.e. even if this file is obviously compiled with
> KASAN_SANITIZE_kasan_init.o := n so that it is not
> instrumented, I'm thinking about the functions it is calling,
> like set_pte(), pgd_populate(), pmd_offset() etc etc.
>

These functions are not instrumented as well, because they are static
and located in headers.
So these functions will be in kasan_init.o translation unit and will
be compiled without -fsanitize=kernel-address.

> Are we just lucky that these functions never do any loads
> and stores?
>

We relay on fact that these functions are static inline and do not call other
functions from other (instrumented) files.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
