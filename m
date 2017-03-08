Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 430D9831ED
	for <linux-mm@kvack.org>; Wed,  8 Mar 2017 10:49:08 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id o126so63399584pfb.2
        for <linux-mm@kvack.org>; Wed, 08 Mar 2017 07:49:08 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id k80si3608578pfk.272.2017.03.08.07.49.07
        for <linux-mm@kvack.org>;
        Wed, 08 Mar 2017 07:49:07 -0800 (PST)
Date: Wed, 8 Mar 2017 15:48:55 +0000
From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: [PATCH] x86, kasan: add KASAN checks to atomic operations
Message-ID: <20170308154854.GC13133@leverpostej>
References: <20170306125851.GL6500@twins.programming.kicks-ass.net>
 <20170306130107.GK6536@twins.programming.kicks-ass.net>
 <CACT4Y+ZDxk2CkaGaqVJfrzoBf4ZXDZ2L8vaAnLOjuY0yx85jgA@mail.gmail.com>
 <20170306162018.GC18519@leverpostej>
 <20170306203500.GR6500@twins.programming.kicks-ass.net>
 <CACT4Y+ZNb_eCLVBz6cUyr0jVPdSW_-nCedcBAh0anfds91B2vw@mail.gmail.com>
 <20170308152027.GA13133@leverpostej>
 <CACT4Y+bZqiE9Mxq1y4vdyT6=DCq0L+y_HjBH1=RJf5C9134CwQ@mail.gmail.com>
 <20170308154357.GB13133@leverpostej>
 <CACT4Y+ahGRxn7j8ZX=rTbwGm_eie-Wy81nKg9RGwjHzodFCK8g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CACT4Y+ahGRxn7j8ZX=rTbwGm_eie-Wy81nKg9RGwjHzodFCK8g@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: Will Deacon <will.deacon@arm.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Ingo Molnar <mingo@redhat.com>, kasan-dev <kasan-dev@googlegroups.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, "x86@kernel.org" <x86@kernel.org>

On Wed, Mar 08, 2017 at 04:45:58PM +0100, Dmitry Vyukov wrote:
> On Wed, Mar 8, 2017 at 4:43 PM, Mark Rutland <mark.rutland@arm.com> wrote:
> > On Wed, Mar 08, 2017 at 04:27:11PM +0100, Dmitry Vyukov wrote:
> >> On Wed, Mar 8, 2017 at 4:20 PM, Mark Rutland <mark.rutland@arm.com> wrote:
> >> > As in my other reply, I'd prefer that we wrapped the (arch-specific)
> >> > atomic implementations such that we can instrument them explicitly in a
> >> > core header. That means that the implementation and semantics of the
> >> > atomics don't change at all.
> >> >
> >> > Note that we could initially do this just for x86 and arm64), e.g. by
> >> > having those explicitly include an <asm-generic/atomic-instrumented.h>
> >> > at the end of their <asm/atomic.h>.
> >>
> >> How exactly do you want to do this incrementally?
> >> I don't feel ready to shuffle all archs, but doing x86 in one patch
> >> and then arm64 in another looks tractable.
> >
> > I guess we'd have three patches: one adding the header and any core
> > infrastructure, followed by separate patches migrating arm64 and x86
> > over.
> 
> But if we add e.g. atomic_read() which forwards to arch_atomic_read()
> to <linux/atomic.h>, it will break all archs that don't rename its
> atomic_read() to arch_atomic_read().

... as above, that'd be handled by placing this in an
<asm-generic/atomic-instrumented.h> file, that we only include at the
end of the arch implementation.

So we'd only include that on arm64 and x86, without needing to change
the names elsewhere.

Thanks,
Mark.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
