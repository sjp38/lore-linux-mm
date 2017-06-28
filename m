Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2F3CE6B02C3
	for <linux-mm@kvack.org>; Wed, 28 Jun 2017 11:24:56 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id j85so10799797wmj.2
        for <linux-mm@kvack.org>; Wed, 28 Jun 2017 08:24:56 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id d205si5615425wmf.195.2017.06.28.08.24.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Wed, 28 Jun 2017 08:24:54 -0700 (PDT)
Date: Wed, 28 Jun 2017 17:24:24 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH] locking/atomics: don't alias ____ptr
In-Reply-To: <20170628141420.GK5981@leverpostej>
Message-ID: <alpine.DEB.2.20.1706281709140.1970@nanos>
References: <cover.1498140838.git.dvyukov@google.com> <85d51d3551b676ba1fc40e8fbddd2eadd056d8dd.1498140838.git.dvyukov@google.com> <20170628100246.7nsvhblgi3xjbc4m@breakpoint.cc> <CACT4Y+Yhy-jucOC37um5xZewEj0sdw8Hjte7oOYxDdxkzOTYoA@mail.gmail.com>
 <1c1cbbfb-8e34-dd33-0e73-bbb2a758e962@virtuozzo.com> <20170628121246.qnk2csgzbgpqrmw3@linutronix.de> <alpine.DEB.2.20.1706281425350.1970@nanos> <alpine.DEB.2.20.1706281544480.1970@nanos> <20170628141420.GK5981@leverpostej>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mark Rutland <mark.rutland@arm.com>
Cc: Sebastian Andrzej Siewior <bigeasy@linutronix.de>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Ingo Molnar <mingo@kernel.org>, Dmitry Vyukov <dvyukov@google.com>, Peter Zijlstra <peterz@infradead.org>, Will Deacon <will.deacon@arm.com>, "H. Peter Anvin" <hpa@zytor.com>, kasan-dev <kasan-dev@googlegroups.com>, "x86@kernel.org" <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>

On Wed, 28 Jun 2017, Mark Rutland wrote:
> On Wed, Jun 28, 2017 at 03:54:42PM +0200, Thomas Gleixner wrote:
> > > static inline unsigned long cmpxchg_varsize(void *ptr, unsigned long old,
> > > 					    unsigned long new, int size)
> > > {
> > > 	switch (size) {
> > > 	case 1:
> > > 	case 2:
> > > 	case 4:
> > > 		break;
> > > 	case 8:
> > > 		if (sizeof(unsigned long) == 8)
> > > 			break;
> > > 	default:
> > > 		BUILD_BUG_ON(1);
> > > 	}
> > > 	kasan_check(ptr, size);
> > > 	return arch_cmpxchg(ptr, old, new);
> > > }
> 
> This'll need to re-cast things before the call to arch_cmpxchg(), and we
> can move the check above the switch, as in [2].

Sure, but I rather see that changed to:

1) Create arch_cmpxchg8/16/32/64() inlines first

2) Add that varsize wrapper:

static inline unsigned long cmpxchg_varsize(void *ptr, unsigned long old,
                                            unsigned long new, int size)
{
        switch (size) {
        case 1:
                kasan_check_write(ptr, size);
                return arch_cmpxchg8((u8 *)ptr, (u8) old, (u8)new);
        case 2:
                kasan_check_write(ptr, size);
                return arch_cmpxchg16((u16 *)ptr, (u16) old, (u16)new);
        case 4:
                kasan_check_write(ptr, size);
                return arch_cmpxchg32((u32 *)ptr, (u32) old, (u32)new);
        case 8:
                if (sizeof(unsigned long) == 8) {
                        kasan_check_write(ptr, size);
                        return arch_cmpxchg64((u64 *)ptr, (u64) old, (u64)new);
                }
        default:
                BUILD_BUG();
        }
}

#define cmpxchg(ptr, o, n)                                              \
({                                                                      \
        ((__typeof__(*(ptr)))cmpxchg_varsize((ptr), (unsigned long)(o), \
                             (unsigned long)(n), sizeof(*(ptr))));      \
})

Which allows us to create:

static inline u8 cmpxchg8(u8 *ptr, u8 old, u8 new)
{
	kasan_check_write(ptr, sizeof(old));
	return arch_cmpxchg8(ptr, old, new);
}

and friends as well and later migrate the existing users away from that
untyped macro mess.

And instead of adding

    #include <asm/atomic-instrumented.h>

to the architecture code, we rather do

# mv arch/xxx/include/asm/atomic.h mv arch/xxx/include/asm/arch_atomic.h
# echo '#include <asm-generic/atomic.h>' >arch/xxx/include/asm/atomic.h

# mv include/asm-generic/atomic.h include/asm-generic/atomic_up.h

and create a new include/asm-generic/atomic.h

#ifndef __ASM_GENERIC_ATOMIC_H
#define __ASM_GENERIC_ATOMIC_H

#ifdef CONFIG_ATOMIC_INSTRUMENTED_H
#include <asm-generic/atomic_instrumented.h>
#else
#include <asm-generic/atomic_up.h>
#endif

#endif

Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
