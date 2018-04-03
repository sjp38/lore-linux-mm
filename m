Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3E0666B0006
	for <linux-mm@kvack.org>; Tue,  3 Apr 2018 10:45:31 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id h81-v6so17112508itb.0
        for <linux-mm@kvack.org>; Tue, 03 Apr 2018 07:45:31 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n126-v6sor316751itd.106.2018.04.03.07.45.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 03 Apr 2018 07:45:30 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <a724eee6-7aff-df8b-de2b-8e9446e94623@virtuozzo.com>
References: <cover.1521828273.git.andreyknvl@google.com> <b79947167d09478d3f61d2ec8de37322c0e1fe92.1521828274.git.andreyknvl@google.com>
 <a724eee6-7aff-df8b-de2b-8e9446e94623@virtuozzo.com>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Tue, 3 Apr 2018 16:45:26 +0200
Message-ID: <CAAeHK+w9T8dTKP8tuw+B2MojvzRE6YQ1=O1FddZA62cYaeLV2g@mail.gmail.com>
Subject: Re: [RFC PATCH v2 08/15] khwasan: add tag related helper functions
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Jonathan Corbet <corbet@lwn.net>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Marc Zyngier <marc.zyngier@arm.com>, Christopher Li <sparse@chrisli.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Masahiro Yamada <yamada.masahiro@socionext.com>, Michal Marek <michal.lkml@markovi.net>, Mark Rutland <mark.rutland@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Yury Norov <ynorov@caviumnetworks.com>, Nick Desaulniers <ndesaulniers@google.com>, Suzuki K Poulose <suzuki.poulose@arm.com>, Kristina Martsenko <kristina.martsenko@arm.com>, Punit Agrawal <punit.agrawal@arm.com>, Dave Martin <Dave.Martin@arm.com>, Michael Weiser <michael.weiser@gmx.de>, James Morse <james.morse@arm.com>, Julien Thierry <julien.thierry@arm.com>, Steve Capper <steve.capper@arm.com>, Tyler Baicar <tbaicar@codeaurora.org>, "Eric W . Biederman" <ebiederm@xmission.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, Paul Lawrence <paullawrence@google.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, David Woodhouse <dwmw@amazon.co.uk>, Sandipan Das <sandipan@linux.vnet.ibm.com>, Kees Cook <keescook@chromium.org>, Herbert Xu <herbert@gondor.apana.org.au>, Geert Uytterhoeven <geert@linux-m68k.org>, Josh Poimboeuf <jpoimboe@redhat.com>, Arnd Bergmann <arnd@arndb.de>, kasan-dev <kasan-dev@googlegroups.com>, linux-doc@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>, kvmarm@lists.cs.columbia.edu, linux-sparse@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, Linux Kbuild mailing list <linux-kbuild@vger.kernel.org>, Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Kees Cook <keescook@google.com>, Jann Horn <jannh@google.com>, Mark Brand <markbrand@google.com>

On Fri, Mar 30, 2018 at 6:13 PM, Andrey Ryabinin
<aryabinin@virtuozzo.com> wrote:
>
>
> On 03/23/2018 09:05 PM, Andrey Konovalov wrote:
>
>> diff --git a/mm/kasan/khwasan.c b/mm/kasan/khwasan.c
>> index 24d75245e9d0..da4b17997c71 100644
>> --- a/mm/kasan/khwasan.c
>> +++ b/mm/kasan/khwasan.c
>> @@ -39,6 +39,57 @@
>>  #include "kasan.h"
>>  #include "../slab.h"
>>
>> +int khwasan_enabled;
>
> This is not unused (set, but never used).

It's used in the "khwasan: add hooks implementation" patch. I'll move
it's declaration there as well.

Thanks!

>
>> +
>> +static DEFINE_PER_CPU(u32, prng_state);
>> +
>> +void khwasan_init(void)
>> +{
>> +     int cpu;
>> +
>> +     for_each_possible_cpu(cpu) {
>> +             per_cpu(prng_state, cpu) = get_random_u32();
>> +     }
>> +     WRITE_ONCE(khwasan_enabled, 1);
>> +}
>> +
>
