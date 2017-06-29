Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id D4EBD2802FE
	for <linux-mm@kvack.org>; Thu, 29 Jun 2017 02:48:17 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id i185so612185wmi.7
        for <linux-mm@kvack.org>; Wed, 28 Jun 2017 23:48:17 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id i23si3289862wrb.180.2017.06.28.23.48.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Wed, 28 Jun 2017 23:48:16 -0700 (PDT)
Date: Thu, 29 Jun 2017 08:47:46 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH] locking/atomics: don't alias ____ptr
In-Reply-To: <alpine.DEB.2.20.1706282020490.1890@nanos>
Message-ID: <alpine.DEB.2.20.1706290844590.1861@nanos>
References: <cover.1498140838.git.dvyukov@google.com> <85d51d3551b676ba1fc40e8fbddd2eadd056d8dd.1498140838.git.dvyukov@google.com> <20170628100246.7nsvhblgi3xjbc4m@breakpoint.cc> <CACT4Y+Yhy-jucOC37um5xZewEj0sdw8Hjte7oOYxDdxkzOTYoA@mail.gmail.com>
 <1c1cbbfb-8e34-dd33-0e73-bbb2a758e962@virtuozzo.com> <20170628121246.qnk2csgzbgpqrmw3@linutronix.de> <alpine.DEB.2.20.1706281425350.1970@nanos> <alpine.DEB.2.20.1706281544480.1970@nanos> <20170628141420.GK5981@leverpostej> <alpine.DEB.2.20.1706281709140.1970@nanos>
 <20170628155445.GD8252@leverpostej> <alpine.DEB.2.20.1706282020490.1890@nanos>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mark Rutland <mark.rutland@arm.com>
Cc: Sebastian Andrzej Siewior <bigeasy@linutronix.de>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Ingo Molnar <mingo@kernel.org>, Dmitry Vyukov <dvyukov@google.com>, Peter Zijlstra <peterz@infradead.org>, Will Deacon <will.deacon@arm.com>, "H. Peter Anvin" <hpa@zytor.com>, kasan-dev <kasan-dev@googlegroups.com>, "x86@kernel.org" <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>

On Wed, 28 Jun 2017, Thomas Gleixner wrote:
> On Wed, 28 Jun 2017, Mark Rutland wrote:
> > On Wed, Jun 28, 2017 at 05:24:24PM +0200, Thomas Gleixner wrote:
> > Given we're gonig to clean things up, we may as well avoid the backwards
> > include of <asm-generic/atomic_instrumented.h>, whcih was only there as
> > a bodge:
> > 
> > For the UP arches we do:
> > # echo '#include <asm-generic/atomic_up.h>' >arch/xxx/include/asm/atomic.h
> > # mv include/asm-generic/atomic.h include/asm-generic/atomic_up.h
> > 
> > Then we add a <linux/atomic_instrumented.h>:
> > 
> > #ifndef __LINUX_ATOMIC_INSTRUMENTED_H
> > #define __LINUX_ATOMIC INSTRUMENTED_H
> > 
> > #include <asm/atomic.h>
> > 
> > #if CONFIG_ATOMIC_INSTRUMENTED_H
> > <instrumentation>
> > #endif
> > 
> > #endif /* __LINUX_ATOMIC_ARCH_H */
> > 
> > ... and make <linux/atomic.h> incldue that rather than <asm/atomic.h>.
> > 
> > That way the instrumentation's orthogonal to the UP-ness of the arch,
> > and we can fold any other instrumentation in there, or later move it
> > directly into <linux/atomic.h>
> 
> Sounds like a plan.

Actually we should make it slightly different and make asm-generic/atomic.h
the central point for everything.

It should contain the wrapper macro and the central inlines including the
kasan stuff and include either arch/arch_atomic.h or
asm-generic/atomic_up.h.

That way all potential instrumentation happens in the generic header (which
is a NOP for archs which do not support it) and pull in the appropriate
arch specific or generic UP low level implementations.

Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
