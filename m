Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id AED016B0292
	for <linux-mm@kvack.org>; Wed, 28 Jun 2017 09:21:07 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id b11so10189362wmh.0
        for <linux-mm@kvack.org>; Wed, 28 Jun 2017 06:21:07 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id j187si5485101wmj.76.2017.06.28.06.21.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Wed, 28 Jun 2017 06:21:06 -0700 (PDT)
Date: Wed, 28 Jun 2017 15:20:36 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH] locking/atomics: don't alias ____ptr
In-Reply-To: <20170628121246.qnk2csgzbgpqrmw3@linutronix.de>
Message-ID: <alpine.DEB.2.20.1706281425350.1970@nanos>
References: <cover.1498140838.git.dvyukov@google.com> <85d51d3551b676ba1fc40e8fbddd2eadd056d8dd.1498140838.git.dvyukov@google.com> <20170628100246.7nsvhblgi3xjbc4m@breakpoint.cc> <CACT4Y+Yhy-jucOC37um5xZewEj0sdw8Hjte7oOYxDdxkzOTYoA@mail.gmail.com>
 <1c1cbbfb-8e34-dd33-0e73-bbb2a758e962@virtuozzo.com> <20170628121246.qnk2csgzbgpqrmw3@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Ingo Molnar <mingo@kernel.org>, Dmitry Vyukov <dvyukov@google.com>, Mark Rutland <mark.rutland@arm.com>, Peter Zijlstra <peterz@infradead.org>, Will Deacon <will.deacon@arm.com>, "H. Peter Anvin" <hpa@zytor.com>, kasan-dev <kasan-dev@googlegroups.com>, "x86@kernel.org" <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>

On Wed, 28 Jun 2017, Sebastian Andrzej Siewior wrote:
> On 2017-06-28 14:15:18 [+0300], Andrey Ryabinin wrote:
> > The main problem here is that arch_cmpxchg64_local() calls cmpxhg_local() instead of using arch_cmpxchg_local().
> > 
> > So, the patch bellow should fix the problem, also this will fix double instrumentation of cmpcxchg64[_local]().
> > But I haven't tested this patch yet.
> 
> tested, works. Next step?

Check all other implementations in every architecture whether there is a
similar problem .....

But this really want's a proper cleanup unless we want to waste the time
over and over again with the next hard to figure out macro expansion fail.

First of all, cmpxchg64[_local]() can be implemented as inlines right away.

For cmpxchg*(), the situation is slightly different, but the sizeof()
evaluation should be done at the top most level, even if we do it further
down in the low level arch/asm-generic implementation once more.

Something along the lines of:

static inline unsigned long cmpxchg_varsize(void *ptr, unsigned long old,
					    unsigned long new, int size)
{
	switch (size) {
	case 1:
	case 2:
	case 4:
		break;
	case 8:
		if (sizeof(unsigned long) == 8)
			break;
	default:
		BUILD_BUG_ON(1);
	}
	kasan_check(ptr, size);
	return arch_cmpxchg(ptr, old, new);
}

#define cmpxchg(ptr, o, n)						\
({									\
	((__typeof__(*(ptr)))cmpxchg_varsize((ptr), (unsigned long)(o), \
			     (unsigned long)(n), sizeof(*(ptr))));	\
})

That's the first step to cure the actual mess.

Ideally we get rid of that whole macro maze and convert everything to
proper inlines with actual cmpxchg8/16/32/64() variants, but that's going
to take some time. As an intermediate step we can at least propagate 'size'
to arch_cmpxchg(), which is not that much of an effort.

Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
