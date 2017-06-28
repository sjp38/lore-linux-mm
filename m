Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id D9CD26B0292
	for <linux-mm@kvack.org>; Wed, 28 Jun 2017 08:46:48 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id z10so54331337pff.1
        for <linux-mm@kvack.org>; Wed, 28 Jun 2017 05:46:48 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id 62si1511798pfs.424.2017.06.28.05.46.47
        for <linux-mm@kvack.org>;
        Wed, 28 Jun 2017 05:46:47 -0700 (PDT)
Date: Wed, 28 Jun 2017 13:45:53 +0100
From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: [PATCH] locking/atomics: don't alias ____ptr
Message-ID: <20170628124552.GG5981@leverpostej>
References: <cover.1498140838.git.dvyukov@google.com>
 <85d51d3551b676ba1fc40e8fbddd2eadd056d8dd.1498140838.git.dvyukov@google.com>
 <20170628100246.7nsvhblgi3xjbc4m@breakpoint.cc>
 <CACT4Y+Yhy-jucOC37um5xZewEj0sdw8Hjte7oOYxDdxkzOTYoA@mail.gmail.com>
 <alpine.DEB.2.20.1706281306120.1970@nanos>
 <CACT4Y+YqCP8RC9nRo5oBw2GFdFF+AVJgpcGGENR7hHL9s3GSHg@mail.gmail.com>
 <alpine.DEB.2.20.1706281315170.1970@nanos>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1706281315170.1970@nanos>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: Dmitry Vyukov <dvyukov@google.com>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Will Deacon <will.deacon@arm.com>, "H. Peter Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, kasan-dev <kasan-dev@googlegroups.com>, "x86@kernel.org" <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>

On Wed, Jun 28, 2017 at 01:21:43PM +0200, Thomas Gleixner wrote:
> On Wed, 28 Jun 2017, Dmitry Vyukov wrote:
> > On Wed, Jun 28, 2017 at 1:10 PM, Thomas Gleixner <tglx@linutronix.de> wrote:
> > >> In my case I ended up with something like:
> > >>
> > >> __typeof__(foo) __ptr = __ptr;
> > >>
> > >> which compiler decided to turn into 0.
> > >>
> > >> Thank you, macros.
> > >>
> > >> We can add more underscores, but the problem can happen again. Should
> > >> we prefix current function/macro name to all local vars?..
> > >
> > > Actually we can void that ___ptr dance completely.
> > >
> > > Thanks,
> > >
> > >         tglx
> > >
> > > 8<--------------------
> > >
> > > --- a/include/asm-generic/atomic-instrumented.h
> > > +++ b/include/asm-generic/atomic-instrumented.h
> > > @@ -359,37 +359,32 @@ static __always_inline bool atomic64_add
> > >
> > >  #define cmpxchg(ptr, old, new)                         \
> > >  ({                                                     \
> > > -       __typeof__(ptr) ___ptr = (ptr);                 \
> > > -       kasan_check_write(___ptr, sizeof(*___ptr));     \
> > > +       kasan_check_write((ptr), sizeof(*(ptr)));       \
> > >         arch_cmpxchg((ptr), (old), (new));              \
> > >  })
> > >
> > >  #define sync_cmpxchg(ptr, old, new)                    \
> > >  ({                                                     \
> > > -       __typeof__(ptr) ___ptr = (ptr);                 \
> > > -       kasan_check_write(___ptr, sizeof(*___ptr));     \
> > > -       arch_sync_cmpxchg(___ptr, (old), (new));        \
> > > +       kasan_check_write((ptr), sizeof(*(ptr)));       \
> > > +       arch_sync_cmpxchg((ptr), (old), (new));         \
> > >  })
> > >
> > >  #define cmpxchg_local(ptr, old, new)                   \
> > >  ({                                                     \
> > > -       __typeof__(ptr) ____ptr = (ptr);                \
> > > -       kasan_check_write(____ptr, sizeof(*____ptr));   \
> > > -       arch_cmpxchg_local(____ptr, (old), (new));      \
> > > +       kasan_check_write((ptr), sizeof(*(ptr)));       \
> > > +       arch_cmpxchg_local((ptr), (old), (new));        \
> > 
> > 
> > /\/\/\/\/\/\/\/\/\/\/\/\
> > 
> > These are macros.
> > If ptr is foo(), then we will call foo() twice.
> 
> Sigh, is that actually used?

For better or worse, we can't rule it out.

We'd risk even more subtle bugs in future trying to rely on that not
being the case. :/

> That's all insane. The whole crap gets worse because:
> 
>       cmpxchg() can be used on u8, u16, u32 ....

Yup, that's the whole reason for the macro insanity in the fist place.

Anoother option is something like:

static inline unsigned long
cmpxchg_size(unsigned long *ptr, unsigned long old, unsigned long new, int size)
{
	kasan_check_write(ptr, size);

	switch (size) {
	case 1:
		return arch_cmpxchg((u8 *)ptr, (u8)old, (u8)new);
	case 2:
		return arch_cmpxchg((u16 *)ptr, (u16)old, (u16)new);
	case 4:
		return arch_cmpxchg((u32 *)ptr, (u32)old, (u32)new);
	case 8:
		return arch_cmpxchg((u64 *)ptr, (u64)old, (u64)new);
	}

	BUILD_BUG();
}

#define cmpxchg(ptr, old, new)	\
	cmpxchg_size(ptr, old, new, sizeof(*ptr))

Thanks,
Mark.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
