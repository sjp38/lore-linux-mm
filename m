Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id ACA6B8E0002
	for <linux-mm@kvack.org>; Thu, 20 Dec 2018 08:02:58 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id u17so1419992pgn.17
        for <linux-mm@kvack.org>; Thu, 20 Dec 2018 05:02:58 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x8sor31994840plo.55.2018.12.20.05.02.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 20 Dec 2018 05:02:57 -0800 (PST)
MIME-Version: 1.0
References: <706da77adfceb0c324e824d03b52d58a752577ea.1545139710.git.andreyknvl@google.com>
 <20181218125453.4c5e6c056d31ccaa3a73d4a5@linux-foundation.org>
In-Reply-To: <20181218125453.4c5e6c056d31ccaa3a73d4a5@linux-foundation.org>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Thu, 20 Dec 2018 14:02:45 +0100
Message-ID: <CAAeHK+yggnKfkycdUdTHG4MvWBMq_XK70m0rQuH873DZU+RnGQ@mail.gmail.com>
Subject: Re: [PATCH mm] kasan, arm64: use ARCH_SLAB_MINALIGN instead of manual aligning
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Christoph Lameter <cl@linux.com>, Mark Rutland <mark.rutland@arm.com>, Nick Desaulniers <ndesaulniers@google.com>, Marc Zyngier <marc.zyngier@arm.com>, Dave Martin <dave.martin@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, "Eric W . Biederman" <ebiederm@xmission.com>, Ingo Molnar <mingo@kernel.org>, Paul Lawrence <paullawrence@google.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Arnd Bergmann <arnd@arndb.de>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Kate Stewart <kstewart@linuxfoundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Vincenzo Frascino <vincenzo.frascino@arm.com>, kasan-dev <kasan-dev@googlegroups.com>, "open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>, linux-sparse@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, Linux Kbuild mailing list <linux-kbuild@vger.kernel.org>, Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Jann Horn <jannh@google.com>, Mark Brand <markbrand@google.com>, Chintan Pandya <cpandya@codeaurora.org>, Vishwath Mohan <vishwath@google.com>

On Tue, Dec 18, 2018 at 9:55 PM Andrew Morton <akpm@linux-foundation.org> wrote:
>
> On Tue, 18 Dec 2018 14:30:33 +0100 Andrey Konovalov <andreyknvl@google.com> wrote:
>
> > Instead of changing cache->align to be aligned to KASAN_SHADOW_SCALE_SIZE
> > in kasan_cache_create() we can reuse the ARCH_SLAB_MINALIGN macro.
> >
> > ...
> >
> > --- a/arch/arm64/include/asm/kasan.h
> > +++ b/arch/arm64/include/asm/kasan.h
> > @@ -36,6 +36,10 @@
> >  #define KASAN_SHADOW_OFFSET     (KASAN_SHADOW_END - (1ULL << \
> >                                       (64 - KASAN_SHADOW_SCALE_SHIFT)))
> >
> > +#ifdef CONFIG_KASAN_SW_TAGS
> > +#define ARCH_SLAB_MINALIGN   (1ULL << KASAN_SHADOW_SCALE_SHIFT)
> > +#endif
> > +
> >  void kasan_init(void);
> >  void kasan_copy_shadow(pgd_t *pgdir);
> >  asmlinkage void kasan_early_init(void);
>
> This looks unreliable.  include/linux/slab.h has
>
> /*
>  * Setting ARCH_SLAB_MINALIGN in arch headers allows a different alignment.
>  * Intended for arches that get misalignment faults even for 64 bit integer
>  * aligned buffers.
>  */
> #ifndef ARCH_SLAB_MINALIGN
> #define ARCH_SLAB_MINALIGN __alignof__(unsigned long long)
> #endif
>
> so if a .c file includes arch/arm64/include/asm/kasan.h after
> include/linux/slab.h, it can get a macro-redefined warning.  If the .c
> file includes those headers in the other order, ARCH_SLAB_MINALIGN will
> get a different value compared to other .c files.
>
> Or something like that.
>
> Different architectures define ARCH_SLAB_MINALIGN in different place:
>
> ./arch/microblaze/include/asm/page.h:#define ARCH_SLAB_MINALIGN L1_CACHE_BYTES
> ./arch/arm/include/asm/cache.h:#define ARCH_SLAB_MINALIGN 8
> ./arch/sh/include/asm/page.h:#define ARCH_SLAB_MINALIGN 8
> ./arch/c6x/include/asm/cache.h:#define ARCH_SLAB_MINALIGN       L1_CACHE_BYTES
> ./arch/sparc/include/asm/cache.h:#define ARCH_SLAB_MINALIGN     __alignof__(unsigned long long)
> ./arch/xtensa/include/asm/processor.h:#define ARCH_SLAB_MINALIGN STACK_ALIGN
>
> which is rather bad of us.
>
> But still.  I think your definition should occur in an arch header file
> which is reliably included from slab.h.  And kasan code should get its
> definition of ARCH_SLAB_MINALIGN by including slab.h.
>

KASAN code doesn't use this macro directly, so I don't think it needs
to get it's definition.

What do you think about adding #include <linux/kasan.h> into
linux/slab.h? Perhaps with a comment that this is needed to get
definition of ARCH_SLAB_MINALIGN?
