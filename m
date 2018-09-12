Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3CAD18E0001
	for <linux-mm@kvack.org>; Wed, 12 Sep 2018 10:54:29 -0400 (EDT)
Received: by mail-io1-f72.google.com with SMTP id s14-v6so520391ioc.0
        for <linux-mm@kvack.org>; Wed, 12 Sep 2018 07:54:29 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i24-v6sor812111jaj.83.2018.09.12.07.54.27
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 12 Sep 2018 07:54:28 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <b4ba65afa55f2fdfd2856fb03c5aba99c7a8bdd7.1535462971.git.andreyknvl@google.com>
References: <cover.1535462971.git.andreyknvl@google.com> <b4ba65afa55f2fdfd2856fb03c5aba99c7a8bdd7.1535462971.git.andreyknvl@google.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Wed, 12 Sep 2018 16:54:06 +0200
Message-ID: <CACT4Y+Z4zLSBdXGtk-6nH64UpOVA8s5TJZSpokAqEu4pE8LpCA@mail.gmail.com>
Subject: Re: [PATCH v6 04/18] khwasan, arm64: adjust shadow size for CONFIG_KASAN_HW
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Konovalov <andreyknvl@google.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Mark Rutland <mark.rutland@arm.com>, Nick Desaulniers <ndesaulniers@google.com>, Marc Zyngier <marc.zyngier@arm.com>, Dave Martin <dave.martin@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, "Eric W . Biederman" <ebiederm@xmission.com>, Ingo Molnar <mingo@kernel.org>, Paul Lawrence <paullawrence@google.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Arnd Bergmann <arnd@arndb.de>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Kate Stewart <kstewart@linuxfoundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, kasan-dev <kasan-dev@googlegroups.com>, linux-doc@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>, linux-sparse@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, "open list:KERNEL BUILD + fi..." <linux-kbuild@vger.kernel.org>, Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Jann Horn <jannh@google.com>, Mark Brand <markbrand@google.com>, Chintan Pandya <cpandya@codeaurora.org>, Vishwath Mohan <vishwath@google.com>

On Wed, Aug 29, 2018 at 1:35 PM, Andrey Konovalov <andreyknvl@google.com> wrote:
> KWHASAN uses 1 shadow byte for 16 bytes of kernel memory, so it requires
> 1/16th of the kernel virtual address space for the shadow memory.
>
> This commit sets KASAN_SHADOW_SCALE_SHIFT to 4 when KHWASAN is enabled.
>
> Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
> ---
>  arch/arm64/Makefile             |  2 +-
>  arch/arm64/include/asm/memory.h | 13 +++++++++----
>  2 files changed, 10 insertions(+), 5 deletions(-)
>
> diff --git a/arch/arm64/Makefile b/arch/arm64/Makefile
> index 106039d25e2f..17047b8ab984 100644
> --- a/arch/arm64/Makefile
> +++ b/arch/arm64/Makefile
> @@ -94,7 +94,7 @@ endif
>  # KASAN_SHADOW_OFFSET = VA_START + (1 << (VA_BITS - KASAN_SHADOW_SCALE_SHIFT))
>  #                               - (1 << (64 - KASAN_SHADOW_SCALE_SHIFT))
>  # in 32-bit arithmetic
> -KASAN_SHADOW_SCALE_SHIFT := 3
> +KASAN_SHADOW_SCALE_SHIFT := $(if $(CONFIG_KASAN_HW), 4, 3)
>  KASAN_SHADOW_OFFSET := $(shell printf "0x%08x00000000\n" $$(( \
>         (0xffffffff & (-1 << ($(CONFIG_ARM64_VA_BITS) - 32))) \
>         + (1 << ($(CONFIG_ARM64_VA_BITS) - 32 - $(KASAN_SHADOW_SCALE_SHIFT))) \
> diff --git a/arch/arm64/include/asm/memory.h b/arch/arm64/include/asm/memory.h
> index b96442960aea..f5e262ee76c1 100644
> --- a/arch/arm64/include/asm/memory.h
> +++ b/arch/arm64/include/asm/memory.h
> @@ -74,12 +74,17 @@
>  #define KERNEL_END        _end
>
>  /*
> - * KASAN requires 1/8th of the kernel virtual address space for the shadow
> - * region. KASAN can bloat the stack significantly, so double the (minimum)
> - * stack size when KASAN is in use.
> + * KASAN and KHWASAN require 1/8th and 1/16th of the kernel virtual address


I am somewhat confused by the terminology.
"KASAN" is not actually "CONFIG_KASAN" below, it is actually
"CONFIG_KASAN_GENERIC". While "KHWASAN" translates to "KASAN_HW" few
lines later.
I think we need some consistent terminology for comments and config
names until it's too late.


> + * space for the shadow region respectively. They can bloat the stack
> + * significantly, so double the (minimum) stack size when they are in use.
>   */
> -#ifdef CONFIG_KASAN
> +#ifdef CONFIG_KASAN_GENERIC
>  #define KASAN_SHADOW_SCALE_SHIFT 3
> +#endif
> +#ifdef CONFIG_KASAN_HW
> +#define KASAN_SHADOW_SCALE_SHIFT 4
> +#endif
> +#ifdef CONFIG_KASAN
>  #define KASAN_SHADOW_SIZE      (UL(1) << (VA_BITS - KASAN_SHADOW_SCALE_SHIFT))
>  #define KASAN_THREAD_SHIFT     1
>  #else
> --
> 2.19.0.rc0.228.g281dcd1b4d0-goog
>
