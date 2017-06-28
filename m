Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id CB2186B02C3
	for <linux-mm@kvack.org>; Wed, 28 Jun 2017 11:55:40 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id t75so18957219pgb.0
        for <linux-mm@kvack.org>; Wed, 28 Jun 2017 08:55:40 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id 88si1835343pfi.181.2017.06.28.08.55.39
        for <linux-mm@kvack.org>;
        Wed, 28 Jun 2017 08:55:39 -0700 (PDT)
Date: Wed, 28 Jun 2017 16:54:45 +0100
From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: [PATCH] locking/atomics: don't alias ____ptr
Message-ID: <20170628155445.GD8252@leverpostej>
References: <cover.1498140838.git.dvyukov@google.com>
 <85d51d3551b676ba1fc40e8fbddd2eadd056d8dd.1498140838.git.dvyukov@google.com>
 <20170628100246.7nsvhblgi3xjbc4m@breakpoint.cc>
 <CACT4Y+Yhy-jucOC37um5xZewEj0sdw8Hjte7oOYxDdxkzOTYoA@mail.gmail.com>
 <1c1cbbfb-8e34-dd33-0e73-bbb2a758e962@virtuozzo.com>
 <20170628121246.qnk2csgzbgpqrmw3@linutronix.de>
 <alpine.DEB.2.20.1706281425350.1970@nanos>
 <alpine.DEB.2.20.1706281544480.1970@nanos>
 <20170628141420.GK5981@leverpostej>
 <alpine.DEB.2.20.1706281709140.1970@nanos>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1706281709140.1970@nanos>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: Sebastian Andrzej Siewior <bigeasy@linutronix.de>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Ingo Molnar <mingo@kernel.org>, Dmitry Vyukov <dvyukov@google.com>, Peter Zijlstra <peterz@infradead.org>, Will Deacon <will.deacon@arm.com>, "H. Peter Anvin" <hpa@zytor.com>, kasan-dev <kasan-dev@googlegroups.com>, "x86@kernel.org" <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>

On Wed, Jun 28, 2017 at 05:24:24PM +0200, Thomas Gleixner wrote:
> On Wed, 28 Jun 2017, Mark Rutland wrote:
> > On Wed, Jun 28, 2017 at 03:54:42PM +0200, Thomas Gleixner wrote:
> > > > static inline unsigned long cmpxchg_varsize(void *ptr, unsigned long old,
> > > > 					    unsigned long new, int size)
> > > > {
> > > > 	switch (size) {
> > > > 	case 1:
> > > > 	case 2:
> > > > 	case 4:
> > > > 		break;
> > > > 	case 8:
> > > > 		if (sizeof(unsigned long) == 8)
> > > > 			break;
> > > > 	default:
> > > > 		BUILD_BUG_ON(1);
> > > > 	}
> > > > 	kasan_check(ptr, size);
> > > > 	return arch_cmpxchg(ptr, old, new);
> > > > }
> > 
> > This'll need to re-cast things before the call to arch_cmpxchg(), and we
> > can move the check above the switch, as in [2].
> 
> Sure, but I rather see that changed to:
> 
> 1) Create arch_cmpxchg8/16/32/64() inlines first
> 
> 2) Add that varsize wrapper:
> 
> static inline unsigned long cmpxchg_varsize(void *ptr, unsigned long old,
>                                             unsigned long new, int size)
> {
>         switch (size) {
>         case 1:
>                 kasan_check_write(ptr, size);
>                 return arch_cmpxchg8((u8 *)ptr, (u8) old, (u8)new);
>         case 2:
>                 kasan_check_write(ptr, size);
>                 return arch_cmpxchg16((u16 *)ptr, (u16) old, (u16)new);
>         case 4:
>                 kasan_check_write(ptr, size);
>                 return arch_cmpxchg32((u32 *)ptr, (u32) old, (u32)new);
>         case 8:
>                 if (sizeof(unsigned long) == 8) {
>                         kasan_check_write(ptr, size);
>                         return arch_cmpxchg64((u64 *)ptr, (u64) old, (u64)new);
>                 }
>         default:
>                 BUILD_BUG();
>         }
> }
> 
> #define cmpxchg(ptr, o, n)                                              \
> ({                                                                      \
>         ((__typeof__(*(ptr)))cmpxchg_varsize((ptr), (unsigned long)(o), \
>                              (unsigned long)(n), sizeof(*(ptr))));      \
> })
> 
> Which allows us to create:
> 
> static inline u8 cmpxchg8(u8 *ptr, u8 old, u8 new)
> {
> 	kasan_check_write(ptr, sizeof(old));
> 	return arch_cmpxchg8(ptr, old, new);
> }
> 
> and friends as well and later migrate the existing users away from that
> untyped macro mess.

Sure, that makes sense to me.

> 
> And instead of adding
> 
>     #include <asm/atomic-instrumented.h>
> 
> to the architecture code, we rather do
> 
> # mv arch/xxx/include/asm/atomic.h mv arch/xxx/include/asm/arch_atomic.h
> # echo '#include <asm-generic/atomic.h>' >arch/xxx/include/asm/atomic.h
> 
> # mv include/asm-generic/atomic.h include/asm-generic/atomic_up.h
> 
> and create a new include/asm-generic/atomic.h
> 
> #ifndef __ASM_GENERIC_ATOMIC_H
> #define __ASM_GENERIC_ATOMIC_H
> 
> #ifdef CONFIG_ATOMIC_INSTRUMENTED_H
> #include <asm-generic/atomic_instrumented.h>
> #else
> #include <asm-generic/atomic_up.h>
> #endif
> 
> #endif

Given we're gonig to clean things up, we may as well avoid the backwards
include of <asm-generic/atomic_instrumented.h>, whcih was only there as
a bodge:

For the UP arches we do:
# echo '#include <asm-generic/atomic_up.h>' >arch/xxx/include/asm/atomic.h
# mv include/asm-generic/atomic.h include/asm-generic/atomic_up.h

Then we add a <linux/atomic_instrumented.h>:

#ifndef __LINUX_ATOMIC_INSTRUMENTED_H
#define __LINUX_ATOMIC INSTRUMENTED_H

#include <asm/atomic.h>

#if CONFIG_ATOMIC_INSTRUMENTED_H
<instrumentation>
#endif

#endif /* __LINUX_ATOMIC_ARCH_H */

... and make <linux/atomic.h> incldue that rather than <asm/atomic.h>.

That way the instrumentation's orthogonal to the UP-ness of the arch,
and we can fold any other instrumentation in there, or later move it
directly into <linux/atomic.h>

Thanks,
Mark.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
