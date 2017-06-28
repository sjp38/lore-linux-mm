Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0DCC46B0292
	for <linux-mm@kvack.org>; Wed, 28 Jun 2017 12:56:57 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id b184so11039511wme.14
        for <linux-mm@kvack.org>; Wed, 28 Jun 2017 09:56:57 -0700 (PDT)
Received: from mail-wm0-x232.google.com (mail-wm0-x232.google.com. [2a00:1450:400c:c09::232])
        by mx.google.com with ESMTPS id n84si3320037wmf.101.2017.06.28.09.56.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Jun 2017 09:56:55 -0700 (PDT)
Received: by mail-wm0-x232.google.com with SMTP id i127so65624967wma.0
        for <linux-mm@kvack.org>; Wed, 28 Jun 2017 09:56:55 -0700 (PDT)
Date: Wed, 28 Jun 2017 18:56:52 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH] locking/atomics: don't alias ____ptr
Message-ID: <20170628165651.bier32hnv3y4hmd6@gmail.com>
References: <85d51d3551b676ba1fc40e8fbddd2eadd056d8dd.1498140838.git.dvyukov@google.com>
 <20170628100246.7nsvhblgi3xjbc4m@breakpoint.cc>
 <CACT4Y+Yhy-jucOC37um5xZewEj0sdw8Hjte7oOYxDdxkzOTYoA@mail.gmail.com>
 <1c1cbbfb-8e34-dd33-0e73-bbb2a758e962@virtuozzo.com>
 <20170628121246.qnk2csgzbgpqrmw3@linutronix.de>
 <alpine.DEB.2.20.1706281425350.1970@nanos>
 <alpine.DEB.2.20.1706281544480.1970@nanos>
 <20170628141420.GK5981@leverpostej>
 <alpine.DEB.2.20.1706281709140.1970@nanos>
 <20170628155445.GD8252@leverpostej>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170628155445.GD8252@leverpostej>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mark Rutland <mark.rutland@arm.com>
Cc: Thomas Gleixner <tglx@linutronix.de>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Dmitry Vyukov <dvyukov@google.com>, Peter Zijlstra <peterz@infradead.org>, Will Deacon <will.deacon@arm.com>, "H. Peter Anvin" <hpa@zytor.com>, kasan-dev <kasan-dev@googlegroups.com>, "x86@kernel.org" <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>


* Mark Rutland <mark.rutland@arm.com> wrote:

> > And instead of adding
> > 
> >     #include <asm/atomic-instrumented.h>
> > 
> > to the architecture code, we rather do
> > 
> > # mv arch/xxx/include/asm/atomic.h mv arch/xxx/include/asm/arch_atomic.h
> > # echo '#include <asm-generic/atomic.h>' >arch/xxx/include/asm/atomic.h
> > 
> > # mv include/asm-generic/atomic.h include/asm-generic/atomic_up.h
> > 
> > and create a new include/asm-generic/atomic.h
> > 
> > #ifndef __ASM_GENERIC_ATOMIC_H
> > #define __ASM_GENERIC_ATOMIC_H
> > 
> > #ifdef CONFIG_ATOMIC_INSTRUMENTED_H
> > #include <asm-generic/atomic_instrumented.h>
> > #else
> > #include <asm-generic/atomic_up.h>
> > #endif
> > 
> > #endif
> 
> Given we're gonig to clean things up, we may as well avoid the backwards
> include of <asm-generic/atomic_instrumented.h>, whcih was only there as
> a bodge:

So, since the final v4.12 release is so close, I've put the following KASAN 
commits aside into tip:WIP.locking/atomics:

4b47cc154eed: locking/atomic/x86, asm-generic: Add comments for atomic instrumentation
35787d9d7ca4: locking/atomics, asm-generic: Add KASAN instrumentation to atomic operations
68c1ed1fdb0a: kasan: Allow kasan_check_read/write() to accept pointers to volatiles
f1c3049f6729: locking/atomic/x86: Switch atomic.h to use atomic-instrumented.h
d079eebb3958: locking/atomic: Add asm-generic/atomic-instrumented.h
007d185b4462: locking/atomic/x86: Use 's64 *' for 'old' argument of atomic64_try_cmpxchg()
ba1c9f83f633: locking/atomic/x86: Un-macro-ify atomic ops implementation

(Note, I had to rebase these freshly, to decouple them from a refcount_t commit 
that we need.)

and won't send them to Linus unless the cleanups are done and acked by Thomas.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
