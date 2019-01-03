Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5A0318E0002
	for <linux-mm@kvack.org>; Thu,  3 Jan 2019 10:52:33 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id f17so33932312edm.20
        for <linux-mm@kvack.org>; Thu, 03 Jan 2019 07:52:33 -0800 (PST)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id a17si9380760edr.179.2019.01.03.07.52.31
        for <linux-mm@kvack.org>;
        Thu, 03 Jan 2019 07:52:31 -0800 (PST)
Date: Thu, 3 Jan 2019 15:52:30 +0000
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH v2 1/3] kasan, arm64: use ARCH_SLAB_MINALIGN instead of
 manual aligning
Message-ID: <20190103155230.GA10070@edgewater-inn.cambridge.arm.com>
References: <cover.1546450432.git.andreyknvl@google.com>
 <b16c90197bb2c06c780e6e981c40345e03fda465.1546450432.git.andreyknvl@google.com>
 <20190102121436.5c2b72d1b0ec49affadc9692@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190102121436.5c2b72d1b0ec49affadc9692@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrey Konovalov <andreyknvl@google.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Catalin Marinas <catalin.marinas@arm.com>, Christoph Lameter <cl@linux.com>, Mark Rutland <mark.rutland@arm.com>, Nick Desaulniers <ndesaulniers@google.com>, Marc Zyngier <marc.zyngier@arm.com>, Dave Martin <dave.martin@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, "Eric W . Biederman" <ebiederm@xmission.com>, Ingo Molnar <mingo@kernel.org>, Paul Lawrence <paullawrence@google.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Arnd Bergmann <arnd@arndb.de>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Kate Stewart <kstewart@linuxfoundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Vincenzo Frascino <vincenzo.frascino@arm.com>, kasan-dev@googlegroups.com, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-sparse@vger.kernel.org, linux-mm@kvack.org, linux-kbuild@vger.kernel.org, Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Jann Horn <jannh@google.com>, Mark Brand <markbrand@google.com>, Chintan Pandya <cpandya@codeaurora.org>, Vishwath Mohan <vishwath@google.com>

On Wed, Jan 02, 2019 at 12:14:36PM -0800, Andrew Morton wrote:
> On Wed,  2 Jan 2019 18:36:06 +0100 Andrey Konovalov <andreyknvl@google.com> wrote:
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
> >  					(64 - KASAN_SHADOW_SCALE_SHIFT)))
> >  
> > +#ifdef CONFIG_KASAN_SW_TAGS
> > +#define ARCH_SLAB_MINALIGN	(1ULL << KASAN_SHADOW_SCALE_SHIFT)
> > +#endif
> > +
> >  void kasan_init(void);
> >  void kasan_copy_shadow(pgd_t *pgdir);
> >  asmlinkage void kasan_early_init(void);
> > diff --git a/include/linux/slab.h b/include/linux/slab.h
> > index 11b45f7ae405..d87f913ab4e8 100644
> > --- a/include/linux/slab.h
> > +++ b/include/linux/slab.h
> > @@ -16,6 +16,7 @@
> >  #include <linux/overflow.h>
> >  #include <linux/types.h>
> >  #include <linux/workqueue.h>
> > +#include <linux/kasan.h>
> >  
> 
> This still seems unadvisable.  Like other architectures, arm defines
> ARCH_SLAB_MINALIGN in arch/arm/include/asm/cache.h. 
> arch/arm/include/asm64/cache.h doesn't define ARCH_SLAB_MINALIGN
> afaict.
> 
> If arch/arm/include/asm64/cache.h later gets a definition of
> ARCH_SLAB_MINALIGN then we again face the risk that different .c files
> will see different values of ARCH_SLAB_MINALIGN depending on which
> headers they include.
> 
> So what to say about this?  The architecture's ARCH_SLAB_MINALIGN
> should be defined in the architecture's cache.h, end of story.  Not in
> slab.h, not in kasan.h.

Agreed. Also, as far as I can tell, this patch isn't actually a fix (unlike
the other two in this series) so it should be harmless to drop it for now.

Will
