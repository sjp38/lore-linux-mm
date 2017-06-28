Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7258E28030E
	for <linux-mm@kvack.org>; Wed, 28 Jun 2017 14:29:26 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id p204so7260313wmg.3
        for <linux-mm@kvack.org>; Wed, 28 Jun 2017 11:29:26 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id 9si2284234wrt.100.2017.06.28.11.21.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Wed, 28 Jun 2017 11:21:48 -0700 (PDT)
Date: Wed, 28 Jun 2017 20:21:16 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH] locking/atomics: don't alias ____ptr
In-Reply-To: <20170628155445.GD8252@leverpostej>
Message-ID: <alpine.DEB.2.20.1706282020490.1890@nanos>
References: <cover.1498140838.git.dvyukov@google.com> <85d51d3551b676ba1fc40e8fbddd2eadd056d8dd.1498140838.git.dvyukov@google.com> <20170628100246.7nsvhblgi3xjbc4m@breakpoint.cc> <CACT4Y+Yhy-jucOC37um5xZewEj0sdw8Hjte7oOYxDdxkzOTYoA@mail.gmail.com>
 <1c1cbbfb-8e34-dd33-0e73-bbb2a758e962@virtuozzo.com> <20170628121246.qnk2csgzbgpqrmw3@linutronix.de> <alpine.DEB.2.20.1706281425350.1970@nanos> <alpine.DEB.2.20.1706281544480.1970@nanos> <20170628141420.GK5981@leverpostej> <alpine.DEB.2.20.1706281709140.1970@nanos>
 <20170628155445.GD8252@leverpostej>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mark Rutland <mark.rutland@arm.com>
Cc: Sebastian Andrzej Siewior <bigeasy@linutronix.de>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Ingo Molnar <mingo@kernel.org>, Dmitry Vyukov <dvyukov@google.com>, Peter Zijlstra <peterz@infradead.org>, Will Deacon <will.deacon@arm.com>, "H. Peter Anvin" <hpa@zytor.com>, kasan-dev <kasan-dev@googlegroups.com>, "x86@kernel.org" <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>

On Wed, 28 Jun 2017, Mark Rutland wrote:
> On Wed, Jun 28, 2017 at 05:24:24PM +0200, Thomas Gleixner wrote:
> Given we're gonig to clean things up, we may as well avoid the backwards
> include of <asm-generic/atomic_instrumented.h>, whcih was only there as
> a bodge:
> 
> For the UP arches we do:
> # echo '#include <asm-generic/atomic_up.h>' >arch/xxx/include/asm/atomic.h
> # mv include/asm-generic/atomic.h include/asm-generic/atomic_up.h
> 
> Then we add a <linux/atomic_instrumented.h>:
> 
> #ifndef __LINUX_ATOMIC_INSTRUMENTED_H
> #define __LINUX_ATOMIC INSTRUMENTED_H
> 
> #include <asm/atomic.h>
> 
> #if CONFIG_ATOMIC_INSTRUMENTED_H
> <instrumentation>
> #endif
> 
> #endif /* __LINUX_ATOMIC_ARCH_H */
> 
> ... and make <linux/atomic.h> incldue that rather than <asm/atomic.h>.
> 
> That way the instrumentation's orthogonal to the UP-ness of the arch,
> and we can fold any other instrumentation in there, or later move it
> directly into <linux/atomic.h>

Sounds like a plan.

Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
