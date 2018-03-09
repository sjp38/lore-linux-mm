Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9BEFE6B0007
	for <linux-mm@kvack.org>; Fri,  9 Mar 2018 13:15:31 -0500 (EST)
Received: by mail-it0-f69.google.com with SMTP id y83so2797956ita.5
        for <linux-mm@kvack.org>; Fri, 09 Mar 2018 10:15:31 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id d72sor1244535itb.69.2018.03.09.10.15.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 09 Mar 2018 10:15:30 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20180305142907.uvrvwmtfl7o45myf@lakrids.cambridge.arm.com>
References: <cover.1520017438.git.andreyknvl@google.com> <739eecf573b6342fc41c4f89d7f64eb8c183e312.1520017438.git.andreyknvl@google.com>
 <20180305142907.uvrvwmtfl7o45myf@lakrids.cambridge.arm.com>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Fri, 9 Mar 2018 19:15:29 +0100
Message-ID: <CAAeHK+x1JgQQouoYEeLO8tASwcxck1eKrRcWJqqrjD4xTV148w@mail.gmail.com>
Subject: Re: [RFC PATCH 06/14] khwasan: enable top byte ignore for the kernel
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mark Rutland <mark.rutland@arm.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Jonathan Corbet <corbet@lwn.net>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Theodore Ts'o <tytso@mit.edu>, Jan Kara <jack@suse.com>, Christopher Li <sparse@chrisli.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Masahiro Yamada <yamada.masahiro@socionext.com>, Michal Marek <michal.lkml@markovi.net>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Yury Norov <ynorov@caviumnetworks.com>, Nick Desaulniers <ndesaulniers@google.com>, Marc Zyngier <marc.zyngier@arm.com>, Bob Picco <bob.picco@oracle.com>, Suzuki K Poulose <suzuki.poulose@arm.com>, Kristina Martsenko <kristina.martsenko@arm.com>, Punit Agrawal <punit.agrawal@arm.com>, Dave Martin <Dave.Martin@arm.com>, James Morse <james.morse@arm.com>, Julien Thierry <julien.thierry@arm.com>, Michael Weiser <michael.weiser@gmx.de>, Steve Capper <steve.capper@arm.com>, Ingo Molnar <mingo@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Sandipan Das <sandipan@linux.vnet.ibm.com>, Paul Lawrence <paullawrence@google.com>, David Woodhouse <dwmw@amazon.co.uk>, Kees Cook <keescook@chromium.org>, Geert Uytterhoeven <geert@linux-m68k.org>, Josh Poimboeuf <jpoimboe@redhat.com>, Arnd Bergmann <arnd@arndb.de>, kasan-dev <kasan-dev@googlegroups.com>, linux-doc@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>, linux-ext4@vger.kernel.org, linux-sparse@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, Linux Kbuild mailing list <linux-kbuild@vger.kernel.org>, Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Kees Cook <keescook@google.com>, Jann Horn <jannh@google.com>, Mark Brand <markbrand@google.com>

On Mon, Mar 5, 2018 at 3:29 PM, Mark Rutland <mark.rutland@arm.com> wrote:
> On Fri, Mar 02, 2018 at 08:44:25PM +0100, Andrey Konovalov wrote:
>> +#ifdef CONFIG_KASAN_TAGS
>> +#define TCR_TBI_FLAGS (TCR_TBI0 | TCR_TBI1)
>> +#else
>> +#define TCR_TBI_FLAGS TCR_TBI0
>> +#endif
>
> Rather than pulling TBI0 into this, I think it'd make more sense to
> have:
>
> #ifdef CONFIG_KASAN_TAGS
> #define KASAN_TCR_FLAGS TCR_TBI1
> #else
> #define KASAN_TCR_FLAGS
> #endif
>
>> +
>>  #define MAIR(attr, mt)       ((attr) << ((mt) * 8))
>>
>>  /*
>> @@ -432,7 +438,7 @@ ENTRY(__cpu_setup)
>>        * both user and kernel.
>>        */
>>       ldr     x10, =TCR_TxSZ(VA_BITS) | TCR_CACHE_FLAGS | TCR_SMP_FLAGS | \
>> -                     TCR_TG_FLAGS | TCR_ASID16 | TCR_TBI0 | TCR_A1
>> +                     TCR_TG_FLAGS | TCR_ASID16 | TCR_TBI_FLAGS | TCR_A1
>
> ... and just append KASAN_TCR_FLAGS to the flags here.
>
> That's roughtly what we do with ENDIAN_SET_EL1 for SCTLR_EL1.
>

OK, will do!
