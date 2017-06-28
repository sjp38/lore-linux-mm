Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7C77A6B0292
	for <linux-mm@kvack.org>; Wed, 28 Jun 2017 10:15:16 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id f127so58281351pgc.10
        for <linux-mm@kvack.org>; Wed, 28 Jun 2017 07:15:16 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id q196si1628681pfq.484.2017.06.28.07.15.14
        for <linux-mm@kvack.org>;
        Wed, 28 Jun 2017 07:15:15 -0700 (PDT)
Date: Wed, 28 Jun 2017 15:14:20 +0100
From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: [PATCH] locking/atomics: don't alias ____ptr
Message-ID: <20170628141420.GK5981@leverpostej>
References: <cover.1498140838.git.dvyukov@google.com>
 <85d51d3551b676ba1fc40e8fbddd2eadd056d8dd.1498140838.git.dvyukov@google.com>
 <20170628100246.7nsvhblgi3xjbc4m@breakpoint.cc>
 <CACT4Y+Yhy-jucOC37um5xZewEj0sdw8Hjte7oOYxDdxkzOTYoA@mail.gmail.com>
 <1c1cbbfb-8e34-dd33-0e73-bbb2a758e962@virtuozzo.com>
 <20170628121246.qnk2csgzbgpqrmw3@linutronix.de>
 <alpine.DEB.2.20.1706281425350.1970@nanos>
 <alpine.DEB.2.20.1706281544480.1970@nanos>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1706281544480.1970@nanos>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: Sebastian Andrzej Siewior <bigeasy@linutronix.de>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Ingo Molnar <mingo@kernel.org>, Dmitry Vyukov <dvyukov@google.com>, Peter Zijlstra <peterz@infradead.org>, Will Deacon <will.deacon@arm.com>, "H. Peter Anvin" <hpa@zytor.com>, kasan-dev <kasan-dev@googlegroups.com>, "x86@kernel.org" <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>

On Wed, Jun 28, 2017 at 03:54:42PM +0200, Thomas Gleixner wrote:
> On Wed, 28 Jun 2017, Thomas Gleixner wrote:
> > On Wed, 28 Jun 2017, Sebastian Andrzej Siewior wrote:
> > > On 2017-06-28 14:15:18 [+0300], Andrey Ryabinin wrote:
> > > > The main problem here is that arch_cmpxchg64_local() calls cmpxhg_local() instead of using arch_cmpxchg_local().
> > > > 
> > > > So, the patch bellow should fix the problem, also this will fix double instrumentation of cmpcxchg64[_local]().
> > > > But I haven't tested this patch yet.
> > > 
> > > tested, works. Next step?
> > 
> > Check all other implementations in every architecture whether there is a
> > similar problem .....

FWIW, as x86 is the only user of atomic-instrumented.h, any similar
issues are unrelated to this series.

That's not to say they don't exist, just that they're orthognal to this.

I've been reworking things for arm64 [1], but there's more cleanup
needed first.

> > But this really want's a proper cleanup unless we want to waste the time
> > over and over again with the next hard to figure out macro expansion fail.
> > 
> > First of all, cmpxchg64[_local]() can be implemented as inlines right away.
> > 
> > For cmpxchg*(), the situation is slightly different, but the sizeof()
> > evaluation should be done at the top most level, even if we do it further
> > down in the low level arch/asm-generic implementation once more.
> > 
> > Something along the lines of:
> > 
> > static inline unsigned long cmpxchg_varsize(void *ptr, unsigned long old,
> > 					    unsigned long new, int size)
> > {
> > 	switch (size) {
> > 	case 1:
> > 	case 2:
> > 	case 4:
> > 		break;
> > 	case 8:
> > 		if (sizeof(unsigned long) == 8)
> > 			break;
> > 	default:
> > 		BUILD_BUG_ON(1);
> > 	}
> > 	kasan_check(ptr, size);
> > 	return arch_cmpxchg(ptr, old, new);
> > }

This'll need to re-cast things before the call to arch_cmpxchg(), and we
can move the check above the switch, as in [2].

> > #define cmpxchg(ptr, o, n)						\
> > ({									\
> > 	((__typeof__(*(ptr)))cmpxchg_varsize((ptr), (unsigned long)(o), \
> > 			     (unsigned long)(n), sizeof(*(ptr))));	\
> > })
> > 
> > That's the first step to cure the actual mess.
> > 
> > Ideally we get rid of that whole macro maze and convert everything to
> > proper inlines with actual cmpxchg8/16/32/64() variants, but that's going
> > to take some time. As an intermediate step we can at least propagate 'size'
> > to arch_cmpxchg(), which is not that much of an effort.
> 
> And to be honest. That should have be done in the first place _BEFORE_
> adding that atomic-instrumented stuff. I'm tempted to revert that mess
> instead of 'fixing' it half arsed.

Sure.

Let's figure out what this *should* look like first.

If that's sufficiently different to what we have now, we revert this and
clean things up first.

> As a side note, we have files (aside of x86/asm/atomic.h) which include
> asm/cmpxchg.h ...
> 
> net/sunrpc/xprtmultipath.c:#include <asm/cmpxchg.h>
> arch/x86/kvm/mmu.c:#include <asm/cmpxchg.h>
> arch/x86/um/asm/barrier.h:#include <asm/cmpxchg.h>

Ugh. I'd sent out a patch [3] for the first of these a while back, as I
spotted that when experimenting with arm64, but tht got dropped on the
floor.

I can resend that, if you like?

I guess it'd also make sense to fix the x86 bits at the same time, so
I'm fine with tahat being folded with other fixes.

> I'm really tired of all this featuritis crammed into the code without much
> thought. Dammit, can we please stop this and clean up the existing mess
> first before duct taping more mess on top of it.

Sorry for adding to the mess here.

Thanks,
Mark.

[1] https://git.kernel.org/pub/scm/linux/kernel/git/mark/linux.git/log/?h=arm64/kasan-atomic
[2] https://lkml.kernel.org/r/20170628124552.GG5981@leverpostej
[3] http://lkml.kernel.org/r/1489574142-20856-1-git-send-email-mark.rutland@arm.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
