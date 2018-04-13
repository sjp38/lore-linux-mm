Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6CAA36B0005
	for <linux-mm@kvack.org>; Fri, 13 Apr 2018 13:34:50 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id m11so2727307iob.14
        for <linux-mm@kvack.org>; Fri, 13 Apr 2018 10:34:50 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h77sor1143426ioe.325.2018.04.13.10.34.49
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 13 Apr 2018 10:34:49 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <b849e2ff-3693-9546-5850-1ddcea23ee29@virtuozzo.com>
References: <4ad725cc903f8534f8c8a60f0daade5e3d674f8d.1523554166.git.andreyknvl@google.com>
 <b849e2ff-3693-9546-5850-1ddcea23ee29@virtuozzo.com>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Fri, 13 Apr 2018 19:34:47 +0200
Message-ID: <CAAeHK+y18zU_PAS5KB82PNqtvGNex+S0Jk3bWaE19=YjThaNow@mail.gmail.com>
Subject: Re: [PATCH] kasan: add no_sanitize attribute for clang builds
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, David Woodhouse <dwmw@amazon.co.uk>, Will Deacon <will.deacon@arm.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Paul Lawrence <paullawrence@google.com>, Sandipan Das <sandipan@linux.vnet.ibm.com>, Kees Cook <keescook@chromium.org>, LKML <linux-kernel@vger.kernel.org>, kasan-dev <kasan-dev@googlegroups.com>, Linux Memory Management List <linux-mm@kvack.org>, Kostya Serebryany <kcc@google.com>

On Fri, Apr 13, 2018 at 5:31 PM, Andrey Ryabinin
<aryabinin@virtuozzo.com> wrote:
>
>
> On 04/12/2018 08:29 PM, Andrey Konovalov wrote:
>> KASAN uses the __no_sanitize_address macro to disable instrumentation
>> of particular functions. Right now it's defined only for GCC build,
>> which causes false positives when clang is used.
>>
>> This patch adds a definition for clang.
>>
>> Note, that clang's revision 329612 or higher is required.
>>
>> Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
>> ---
>>  include/linux/compiler-clang.h | 5 +++++
>>  1 file changed, 5 insertions(+)
>>
>> diff --git a/include/linux/compiler-clang.h b/include/linux/compiler-clang.h
>> index ceb96ecab96e..5a1d8580febe 100644
>> --- a/include/linux/compiler-clang.h
>> +++ b/include/linux/compiler-clang.h
>> @@ -25,6 +25,11 @@
>>  #define __SANITIZE_ADDRESS__
>>  #endif
>>
>> +#ifdef CONFIG_KASAN
>
> If, for whatever reason, developer decides to add __no_sanitize_address to some
> generic function, guess what will happen next when he/she will try to build CONFIG_KASAN=n kernel?

It's defined to nothing in compiler-gcc.h and redefined in
compiler-clang.h only if CONFIG_KASAN is enabled, so everything should
be fine. Am I missing something?

>
>> +#undef __no_sanitize_address
>> +#define __no_sanitize_address __attribute__((no_sanitize("address")))
>> +#endif
>> +
>>  /* Clang doesn't have a way to turn it off per-function, yet. */
>>  #ifdef __noretpoline
>>  #undef __noretpoline
>>
