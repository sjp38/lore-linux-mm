Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f200.google.com (mail-it1-f200.google.com [209.85.166.200])
	by kanga.kvack.org (Postfix) with ESMTP id 055A16B4987
	for <linux-mm@kvack.org>; Tue, 27 Nov 2018 12:15:55 -0500 (EST)
Received: by mail-it1-f200.google.com with SMTP id j3so4464456itf.5
        for <linux-mm@kvack.org>; Tue, 27 Nov 2018 09:15:55 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b12sor1209995ioj.146.2018.11.27.09.15.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 27 Nov 2018 09:15:53 -0800 (PST)
MIME-Version: 1.0
References: <20181114133920.7134-1-steve.capper@arm.com> <20181114133920.7134-3-steve.capper@arm.com>
 <20181127170931.GC3563@arrakis.emea.arm.com>
In-Reply-To: <20181127170931.GC3563@arrakis.emea.arm.com>
From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Date: Tue, 27 Nov 2018 18:15:41 +0100
Message-ID: <CAKv+Gu-xeAdpWhK-MoAjXHX+hMteYQwKtLe_Bv_mtj2uUedSDw@mail.gmail.com>
Subject: Re: [PATCH V3 2/5] arm64: mm: Introduce DEFAULT_MAP_WINDOW
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Steve Capper <steve.capper@arm.com>, Linux-MM <linux-mm@kvack.org>, linux-arm-kernel <linux-arm-kernel@lists.infradead.org>, Will Deacon <will.deacon@arm.com>, Jon Masters <jcm@redhat.com>

On Tue, 27 Nov 2018 at 18:09, Catalin Marinas <catalin.marinas@arm.com> wrote:
>
> Hi Steve,
>
> On Wed, Nov 14, 2018 at 01:39:17PM +0000, Steve Capper wrote:
> > diff --git a/arch/arm64/include/asm/processor.h b/arch/arm64/include/asm/processor.h
> > index 3e2091708b8e..da41a2655b69 100644
> > --- a/arch/arm64/include/asm/processor.h
> > +++ b/arch/arm64/include/asm/processor.h
> > @@ -25,6 +25,9 @@
> >  #define USER_DS              (TASK_SIZE_64 - 1)
> >
> >  #ifndef __ASSEMBLY__
> > +
> > +#define DEFAULT_MAP_WINDOW_64        (UL(1) << VA_BITS)
> > +
> >  #ifdef __KERNEL__
>
> That's a strange place to place DEFAULT_MAP_WINDOW_64. Did you have any
> #include dependency issues? If yes, we could look at cleaning them up,
> maybe moving these definitions into a separate file.
>
> (also, if you do a clean-up I don't think we need __KERNEL__ anymore)
>
> >
> >  #include <linux/build_bug.h>
> > @@ -51,13 +54,16 @@
> >                               TASK_SIZE_32 : TASK_SIZE_64)
> >  #define TASK_SIZE_OF(tsk)    (test_tsk_thread_flag(tsk, TIF_32BIT) ? \
> >                               TASK_SIZE_32 : TASK_SIZE_64)
> > +#define DEFAULT_MAP_WINDOW   (test_thread_flag(TIF_32BIT) ? \
> > +                             TASK_SIZE_32 : DEFAULT_MAP_WINDOW_64)
> >  #else
> >  #define TASK_SIZE            TASK_SIZE_64
> > +#define DEFAULT_MAP_WINDOW   DEFAULT_MAP_WINDOW_64
> >  #endif /* CONFIG_COMPAT */
> >
> > -#define TASK_UNMAPPED_BASE   (PAGE_ALIGN(TASK_SIZE / 4))
> > +#define TASK_UNMAPPED_BASE   (PAGE_ALIGN(DEFAULT_MAP_WINDOW / 4))
> > +#define STACK_TOP_MAX                DEFAULT_MAP_WINDOW_64
> >
> > -#define STACK_TOP_MAX                TASK_SIZE_64
> >  #ifdef CONFIG_COMPAT
> >  #define AARCH32_VECTORS_BASE 0xffff0000
> >  #define STACK_TOP            (test_thread_flag(TIF_32BIT) ? \
> > diff --git a/arch/arm64/mm/init.c b/arch/arm64/mm/init.c
> > index 9d9582cac6c4..e5a1dc0beef9 100644
> > --- a/arch/arm64/mm/init.c
> > +++ b/arch/arm64/mm/init.c
> > @@ -609,7 +609,7 @@ void __init mem_init(void)
> >        * detected at build time already.
> >        */
> >  #ifdef CONFIG_COMPAT
> > -     BUILD_BUG_ON(TASK_SIZE_32                       > TASK_SIZE_64);
> > +     BUILD_BUG_ON(TASK_SIZE_32                       > DEFAULT_MAP_WINDOW_64);
> >  #endif
>
> Since you are at this, can you please remove the useless white space (I
> guess it was there before when we had more BUILD_BUG_ONs).
>
> > diff --git a/drivers/firmware/efi/libstub/arm-stub.c b/drivers/firmware/efi/libstub/arm-stub.c
> > index 30ac0c975f8a..d1ec7136e3e1 100644
> > --- a/drivers/firmware/efi/libstub/arm-stub.c
> > +++ b/drivers/firmware/efi/libstub/arm-stub.c
> > @@ -33,7 +33,7 @@
> >  #define EFI_RT_VIRTUAL_SIZE  SZ_512M
> >
> >  #ifdef CONFIG_ARM64
> > -# define EFI_RT_VIRTUAL_LIMIT        TASK_SIZE_64
> > +# define EFI_RT_VIRTUAL_LIMIT        DEFAULT_MAP_WINDOW_64
> >  #else
> >  # define EFI_RT_VIRTUAL_LIMIT        TASK_SIZE
> >  #endif
>
> Just curious, would anything happen if we leave this to TASK_SIZE_64?
>

Not really. The kernel virtual mapping of the EFI runtime services
regions are randomized based on the this value, so they may end up way
up in memory, but EFI doesn't really care about that.
