Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f197.google.com (mail-it1-f197.google.com [209.85.166.197])
	by kanga.kvack.org (Postfix) with ESMTP id 058E86B0003
	for <linux-mm@kvack.org>; Mon, 12 Nov 2018 13:21:57 -0500 (EST)
Received: by mail-it1-f197.google.com with SMTP id h126-v6so1208337ita.1
        for <linux-mm@kvack.org>; Mon, 12 Nov 2018 10:21:56 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 71-v6sor35462081jay.9.2018.11.12.10.21.55
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 12 Nov 2018 10:21:55 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20181107170458.jirk2b3tszrcagbt@lakrids.cambridge.arm.com>
References: <cover.1541525354.git.andreyknvl@google.com> <ea8f0391d7befab4afec34d2a009028cd9e0f326.1541525354.git.andreyknvl@google.com>
 <20181107170458.jirk2b3tszrcagbt@lakrids.cambridge.arm.com>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Mon, 12 Nov 2018 19:21:54 +0100
Message-ID: <CAAeHK+zgaNtWsGUF1h1zu9NpZBinyEKNuUUYe14TkMXWRRFhdQ@mail.gmail.com>
Subject: Re: [PATCH v10 05/22] kasan: add CONFIG_KASAN_GENERIC and CONFIG_KASAN_SW_TAGS
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mark Rutland <mark.rutland@arm.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Nick Desaulniers <ndesaulniers@google.com>, Marc Zyngier <marc.zyngier@arm.com>, Dave Martin <dave.martin@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, "Eric W . Biederman" <ebiederm@xmission.com>, Ingo Molnar <mingo@kernel.org>, Paul Lawrence <paullawrence@google.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Arnd Bergmann <arnd@arndb.de>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Kate Stewart <kstewart@linuxfoundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, kasan-dev@googlegroups.com, "open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>, linux-sparse@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, Linux Kbuild mailing list <linux-kbuild@vger.kernel.org>, Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Jann Horn <jannh@google.com>, Mark Brand <markbrand@google.com>, Chintan Pandya <cpandya@codeaurora.org>, Vishwath Mohan <vishwath@google.com>

On Wed, Nov 7, 2018 at 6:04 PM, Mark Rutland <mark.rutland@arm.com> wrote:
> On Tue, Nov 06, 2018 at 06:30:20PM +0100, Andrey Konovalov wrote:
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
>>  include/linux/compiler_attributes.h | 13 -----
>>  include/linux/kasan.h               | 16 ++++--
>>  lib/Kconfig.kasan                   | 87 +++++++++++++++++++++++------
>>  mm/kasan/Makefile                   |  6 +-
>>  mm/kasan/generic.c                  |  2 +-
>>  mm/kasan/kasan.h                    |  3 +-
>>  mm/kasan/tags.c                     | 75 +++++++++++++++++++++++++
>>  mm/slub.c                           |  2 +-
>>  scripts/Makefile.kasan              | 27 ++++++++-
>>  12 files changed, 201 insertions(+), 42 deletions(-)
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
> Given this relies on a compiler feature, can we please gate this on
> compiler feature detection? e.g. in some common Kconfig have:
>
>         select CC_HAS_ASAN_HWADDRESS if $(cc-option -fsanitize=kernel-hwaddress)
>
> ... and on arm64 we can do:
>
>         select HAVE_ARCH_KASAN_SW_TAGS if !(ARM64_16K_PAGES && ARM64_VA_BITS_48)
>
> ... and core KASAN Kconfig can have:
>
> config KASAN_SW_TAGS
>         depends on HAVE_ARCH_KASAN_SW_TAGS
>         depends on CC_HAS_ASAN_HWADDRESS
>
> [...]
>
>> +ifeq ($(call cc-option, $(CFLAGS_KASAN) -Werror),)
>> +    ifneq ($(CONFIG_COMPILE_TEST),y)
>> +        $(warning Cannot use CONFIG_KASAN_SW_TAGS: \
>> +            -fsanitize=hwaddress is not supported by compiler)
>> +    endif
>> +endif
>
> ... and then this warning shouldn't be possible, and can go.

Will do in v11, thanks!
