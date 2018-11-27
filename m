Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f197.google.com (mail-it1-f197.google.com [209.85.166.197])
	by kanga.kvack.org (Postfix) with ESMTP id AFDD66B48E4
	for <linux-mm@kvack.org>; Tue, 27 Nov 2018 11:12:48 -0500 (EST)
Received: by mail-it1-f197.google.com with SMTP id o205so27347527itc.2
        for <linux-mm@kvack.org>; Tue, 27 Nov 2018 08:12:48 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r1-v6sor7190128itb.19.2018.11.27.08.12.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 27 Nov 2018 08:12:47 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20181123174352.ri3qo3wx2irm6hzj@lakrids.cambridge.arm.com>
References: <cover.1542648335.git.andreyknvl@google.com> <356c34c9a2ae8348a6cbd1de53135a28187fa120.1542648335.git.andreyknvl@google.com>
 <20181123174352.ri3qo3wx2irm6hzj@lakrids.cambridge.arm.com>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Tue, 27 Nov 2018 17:12:45 +0100
Message-ID: <CAAeHK+y7Ya25+pzLTxBbin5HkirPyw3Fbz5Tb-HU1GeUnhDMjA@mail.gmail.com>
Subject: Re: [PATCH v11 05/24] kasan: add CONFIG_KASAN_GENERIC and CONFIG_KASAN_SW_TAGS
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mark Rutland <mark.rutland@arm.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Nick Desaulniers <ndesaulniers@google.com>, Marc Zyngier <marc.zyngier@arm.com>, Dave Martin <dave.martin@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, "Eric W . Biederman" <ebiederm@xmission.com>, Ingo Molnar <mingo@kernel.org>, Paul Lawrence <paullawrence@google.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Arnd Bergmann <arnd@arndb.de>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Kate Stewart <kstewart@linuxfoundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, kasan-dev@googlegroups.com, "open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>, linux-sparse@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, Linux Kbuild mailing list <linux-kbuild@vger.kernel.org>, Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Jann Horn <jannh@google.com>, Mark Brand <markbrand@google.com>, Chintan Pandya <cpandya@codeaurora.org>, Vishwath Mohan <vishwath@google.com>

On Fri, Nov 23, 2018 at 6:43 PM, Mark Rutland <mark.rutland@arm.com> wrote:
> On Mon, Nov 19, 2018 at 06:26:21PM +0100, Andrey Konovalov wrote:
>> This commit splits the current CONFIG_KASAN config option into two:
>> 1. CONFIG_KASAN_GENERIC, that enables the generic KASAN mode (the one
>>    that exists now);
>> 2. CONFIG_KASAN_SW_TAGS, that enables the software tag-based KASAN mode.
>>
>> The name CONFIG_KASAN_SW_TAGS is chosen as in the future we will have
>> another hardware tag-based KASAN mode, that will rely on hardware memory
>> tagging support in arm64.
>>
>> With CONFIG_KASAN_SW_TAGS enabled, compiler options are changed to
>> instrument kernel files with -fsantize=kernel-hwaddress (except the ones
>> for which KASAN_SANITIZE := n is set).
>>
>> Both CONFIG_KASAN_GENERIC and CONFIG_KASAN_SW_TAGS support both
>> CONFIG_KASAN_INLINE and CONFIG_KASAN_OUTLINE instrumentation modes.
>>
>> This commit also adds empty placeholder (for now) implementation of
>> tag-based KASAN specific hooks inserted by the compiler and adjusts
>> common hooks implementation to compile correctly with each of the
>> config options.
>>
>> Reviewed-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
>> Reviewed-by: Dmitry Vyukov <dvyukov@google.com>
>> Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
>> ---
>>  arch/arm64/Kconfig                  |  1 +
>>  include/linux/compiler-clang.h      |  5 +-
>>  include/linux/compiler-gcc.h        |  6 ++
>>  include/linux/compiler_attributes.h | 13 ----
>>  include/linux/kasan.h               | 16 +++--
>>  lib/Kconfig.kasan                   | 96 +++++++++++++++++++++++------
>>  mm/kasan/Makefile                   |  6 +-
>>  mm/kasan/generic.c                  |  2 +-
>>  mm/kasan/kasan.h                    |  3 +-
>>  mm/kasan/tags.c                     | 75 ++++++++++++++++++++++
>>  mm/slub.c                           |  2 +-
>>  scripts/Makefile.kasan              | 53 +++++++++-------
>>  12 files changed, 216 insertions(+), 62 deletions(-)
>>  create mode 100644 mm/kasan/tags.c
>>
>> diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
>> index 787d7850e064..8b331dcfb48e 100644
>> --- a/arch/arm64/Kconfig
>> +++ b/arch/arm64/Kconfig
>> @@ -111,6 +111,7 @@ config ARM64
>>       select HAVE_ARCH_JUMP_LABEL
>>       select HAVE_ARCH_JUMP_LABEL_RELATIVE
>>       select HAVE_ARCH_KASAN if !(ARM64_16K_PAGES && ARM64_VA_BITS_48)
>> +     select HAVE_ARCH_KASAN_SW_TAGS if !(ARM64_16K_PAGES && ARM64_VA_BITS_48)
>
>> --- a/lib/Kconfig.kasan
>> +++ b/lib/Kconfig.kasan
>> @@ -1,35 +1,95 @@
>> +# This config refers to the generic KASAN mode.
>>  config HAVE_ARCH_KASAN
>>       bool
>>
>> +config HAVE_ARCH_KASAN_SW_TAGS
>> +     bool
>> +
>> +config CC_HAS_KASAN_GENERIC
>> +     def_bool $(cc-option, -fsanitize=kernel-address)
>> +
>> +config CC_HAS_KASAN_SW_TAGS
>> +     def_bool $(cc-option, -fsanitize=kernel-hwaddress)
>
>> +if HAVE_ARCH_KASAN_SW_TAGS
>> +
>> +config KASAN_SW_TAGS
>> +     bool "Software tag-based mode"
>> +     depends on CC_HAS_KASAN_SW_TAGS
>> +     depends on (SLUB && SYSFS) || (SLAB && !DEBUG_SLAB)
>> +     select SLUB_DEBUG if SLUB
>> +     select CONSTRUCTORS
>> +     select STACKDEPOT
>> +     help
>> +       Enables software tag-based KASAN mode.
>> +       This mode requires Top Byte Ignore support by the CPU and therefore
>> +       is only supported for arm64.
>> +       This mode requires Clang version 7.0.0 or later.
>> +       This mode consumes about 1/16th of available memory at kernel start
>> +       and introduces an overhead of ~20% for the rest of the allocations.
>> +       This mode may potentially introduce problems relating to pointer
>> +       casting and comparison, as it embeds tags into the top byte of each
>> +       pointer.
>> +       For better error detection enable CONFIG_STACKTRACE.
>> +       Currently CONFIG_KASAN_SW_TAGS doesn't work with CONFIG_DEBUG_SLAB
>> +       (the resulting kernel does not boot).
>> +
>> +endif
>
> IIUC as of this patch a user can select KASAN_SW_TAGS...
>
>> +ifdef CONFIG_KASAN_SW_TAGS
>> +
>> +ifdef CONFIG_KASAN_INLINE
>> +    instrumentation_flags := -mllvm -hwasan-mapping-offset=$(KASAN_SHADOW_OFFSET)
>> +else
>> +    instrumentation_flags := -mllvm -hwasan-instrument-with-calls=1
>> +endif
>> +
>> +CFLAGS_KASAN := -fsanitize=kernel-hwaddress \
>> +             -mllvm -hwasan-instrument-stack=0 \
>> +             $(instrumentation_flags)
>> +
>> +endif # CONFIG_KASAN_SW_TAGS
>
> ... and therefore we start using the compiler option, even though we
> haven't introduced all of the necessary infrastructure yet.
>
> That doesn't sound right to me. At the very least, that breaks
> randconfig builds.
>
> What we can do, in-order, is:
>
> 1) introduce the core refactoring, dependent on HAVE_ARCH_KASAN_SW_TAGS
> 2) instroduce the new infrastructure and arch code
> 3) select HAVE_ARCH_KASAN_SW_TAGS
>
> ... such that at (3), all KASAN configurations are known to work.
>
> Thanks,
> Mark.

Will do in v12, thanks!
