Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id A62486B039F
	for <linux-mm@kvack.org>; Thu, 30 Mar 2017 06:41:21 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id u3so40740936pgn.12
        for <linux-mm@kvack.org>; Thu, 30 Mar 2017 03:41:21 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id r3si1814136plj.77.2017.03.30.03.41.20
        for <linux-mm@kvack.org>;
        Thu, 30 Mar 2017 03:41:20 -0700 (PDT)
Date: Thu, 30 Mar 2017 11:40:59 +0100
From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: [PATCH 4/8] asm-generic: add atomic-instrumented.h
Message-ID: <20170330104058.GB16211@leverpostej>
References: <cover.1490717337.git.dvyukov@google.com>
 <ffaaa56d5099d2926004f0290f73396d0bd842c8.1490717337.git.dvyukov@google.com>
 <20170329171526.GB26135@leverpostej>
 <20170330064339.GA20935@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170330064339.GA20935@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Dmitry Vyukov <dvyukov@google.com>, peterz@infradead.org, mingo@redhat.com, akpm@linux-foundation.org, will.deacon@arm.com, aryabinin@virtuozzo.com, kasan-dev@googlegroups.com, linux-kernel@vger.kernel.org, x86@kernel.org, linux-mm@kvack.org

On Thu, Mar 30, 2017 at 08:43:39AM +0200, Ingo Molnar wrote:
> 
> * Mark Rutland <mark.rutland@arm.com> wrote:
> 
> > With some minimal CPP, it can be a lot more manageable:
> > 
> > ----
> > #define INSTR_ATOMIC_XCHG(order)					\
> > static __always_inline int atomic_xchg##order(atomic_t *v, int i)	\
> > {									\
> > 	kasan_check_write(v, sizeof(*v));				\
> > 	arch_atomic_xchg##order(v, i);					\
> > }
> > 
> > #define INSTR_ATOMIC_XCHG()
> > 
> > #ifdef arch_atomic_xchg_relaxed
> > INSTR_ATOMIC_XCHG(_relaxed)
> > #define atomic_xchg_relaxed atomic_xchg_relaxed
> > #endif
> > 
> > #ifdef arch_atomic_xchg_acquire
> > INSTR_ATOMIC_XCHG(_acquire)
> > #define atomic_xchg_acquire atomic_xchg_acquire
> > #endif
> > 
> > #ifdef arch_atomic_xchg_relaxed
> > INSTR_ATOMIC_XCHG(_relaxed)
> > #define atomic_xchg_relaxed atomic_xchg_relaxed
> > #endif
> 
> Yeah, small detail: the third one wants to be _release, right?

Yes; my bad.

> > Is there any objection to some light CPP usage as above for adding the
> > {relaxed,acquire,release} variants?
> 
> No objection from me to that way of writing it, this still looks very readable, 
> and probably more readable than the verbose variants. It's similar in style to 
> linux/atomic.h which has a good balance of C versus CPP.

Great. I'll follow the above pattern when adding the ordering variants.

> What I objected to was the deep nested code generation approach in the original 
> patch.
> 
> CPP is fine in many circumstances, but there's a level of (ab-)use where it 
> becomes counterproductive.

Sure, that makes sense to me.

Thanks,
Mark.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
