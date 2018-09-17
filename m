Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1F2638E0001
	for <linux-mm@kvack.org>; Mon, 17 Sep 2018 14:42:39 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id q5-v6so14042255ith.1
        for <linux-mm@kvack.org>; Mon, 17 Sep 2018 11:42:39 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 15-v6sor9407257ioc.311.2018.09.17.11.42.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 17 Sep 2018 11:42:37 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CACT4Y+baDKvmpKJ4SKoEuZG4ir2xRGscQ7Ro4hkVAX3jwiWnFg@mail.gmail.com>
References: <cover.1535462971.git.andreyknvl@google.com> <868c9168481ff5103034ac1e37b830d28ed5f4ee.1535462971.git.andreyknvl@google.com>
 <CACT4Y+baDKvmpKJ4SKoEuZG4ir2xRGscQ7Ro4hkVAX3jwiWnFg@mail.gmail.com>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Mon, 17 Sep 2018 20:42:36 +0200
Message-ID: <CAAeHK+yvVgV6LA8PgJz6ysCo+X38tCyLrMVhKOe08tFyZP_F0Q@mail.gmail.com>
Subject: Re: [PATCH v6 03/18] khwasan: add CONFIG_KASAN_GENERIC and CONFIG_KASAN_HW
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Mark Rutland <mark.rutland@arm.com>, Nick Desaulniers <ndesaulniers@google.com>, Marc Zyngier <marc.zyngier@arm.com>, Dave Martin <dave.martin@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, "Eric W . Biederman" <ebiederm@xmission.com>, Ingo Molnar <mingo@kernel.org>, Paul Lawrence <paullawrence@google.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Arnd Bergmann <arnd@arndb.de>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Kate Stewart <kstewart@linuxfoundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, kasan-dev <kasan-dev@googlegroups.com>, "open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>, linux-sparse@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, "open list:KERNEL BUILD + fi..." <linux-kbuild@vger.kernel.org>, Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Jann Horn <jannh@google.com>, Mark Brand <markbrand@google.com>, Chintan Pandya <cpandya@codeaurora.org>, Vishwath Mohan <vishwath@google.com>

On Wed, Sep 12, 2018 at 4:47 PM, Dmitry Vyukov <dvyukov@google.com> wrote:
> On Wed, Aug 29, 2018 at 1:35 PM, Andrey Konovalov <andreyknvl@google.com> wrote:

>>
>>  #define __no_sanitize_address __attribute__((no_sanitize("address")))
>> +#define __no_sanitize_hwaddress __attribute__((no_sanitize("hwaddress")))
>
> It seems that it would be better to have just 1 attribute for both types.
> Currently __no_sanitize_address is used just in a single place. But if
> it ever used more, people will need to always spell both which looks
> unnecessary, or, worse will only fix asan but forget about khwasan.
>
> If we do just:
>
> #define __no_sanitize_address __attribute__((no_sanitize("address",
> "hwaddress")))
>
> Then we don't need any changes in compiler-gcc.h nor in compiler.h,
> and no chance or forgetting one of them.

Will do in v7.

>>  config KASAN
>> -       bool "KASan: runtime memory debugger"
>> +       bool "KASAN: runtime memory debugger"
>> +       help
>> +         Enables KASAN (KernelAddressSANitizer) - runtime memory debugger,
>> +         designed to find out-of-bounds accesses and use-after-free bugs.
>
> Perhaps also give link to Documentation/dev-tools/kasan.rst while we are here.

Will do in v7.

>
>> +
>> +choice
>> +       prompt "KASAN mode"
>> +       depends on KASAN
>> +       default KASAN_GENERIC
>> +       help
>> +         KASAN has two modes: KASAN (a classic version, similar to userspace
>
> In these few sentences we call the old mode with 3 different terms:
> "generic", "classic" and "KASAN" :)
> This is somewhat confusing. Let's call it "generic" throughout (here
> and in the docs patch). "Generic" as in "supported on multiple arch
> and not-dependent on hardware features". "Classic" makes sense for
> people who knew KASAN before, but for future readers in won't make
> sense.

Will use "generic" in v7.

>>
>> +if HAVE_ARCH_KASAN_HW
>
> This choice looks somewhat weird on non-arm64. It's kinda a choice
> menu, but one can't really choose anything. Should we put the whole
> choice under HAVE_ARCH_KASAN_HW, and just select KASAN_GENERIC
> otherwise? I don't know what't the practice here. Andrey R?

I think having one option that is auto selected is fine.

>> +config KASAN_HW
>> +       bool "KHWASAN: the hardware assisted mode"

Do we need a hyphen here? hardware-assisted?

Yes, will fix in v7.
