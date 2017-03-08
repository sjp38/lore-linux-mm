Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 393BA83200
	for <linux-mm@kvack.org>; Wed,  8 Mar 2017 12:42:54 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id 77so65438520pgc.5
        for <linux-mm@kvack.org>; Wed, 08 Mar 2017 09:42:54 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id l1si3907883pln.71.2017.03.08.09.42.53
        for <linux-mm@kvack.org>;
        Wed, 08 Mar 2017 09:42:53 -0800 (PST)
Date: Wed, 8 Mar 2017 17:43:00 +0000
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH] x86, kasan: add KASAN checks to atomic operations
Message-ID: <20170308174300.GL20400@arm.com>
References: <20170306124254.77615-1-dvyukov@google.com>
 <CACT4Y+YmpTMdJca-rE2nXR-qa=wn_bCqQXaRghtg1uC65-pKyA@mail.gmail.com>
 <20170306125851.GL6500@twins.programming.kicks-ass.net>
 <20170306130107.GK6536@twins.programming.kicks-ass.net>
 <CACT4Y+ZDxk2CkaGaqVJfrzoBf4ZXDZ2L8vaAnLOjuY0yx85jgA@mail.gmail.com>
 <20170306162018.GC18519@leverpostej>
 <20170306203500.GR6500@twins.programming.kicks-ass.net>
 <CACT4Y+ZNb_eCLVBz6cUyr0jVPdSW_-nCedcBAh0anfds91B2vw@mail.gmail.com>
 <20170308152027.GA13133@leverpostej>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170308152027.GA13133@leverpostej>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mark Rutland <mark.rutland@arm.com>
Cc: Dmitry Vyukov <dvyukov@google.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Ingo Molnar <mingo@redhat.com>, kasan-dev <kasan-dev@googlegroups.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, "x86@kernel.org" <x86@kernel.org>

On Wed, Mar 08, 2017 at 03:20:41PM +0000, Mark Rutland wrote:
> On Wed, Mar 08, 2017 at 02:42:10PM +0100, Dmitry Vyukov wrote:
> > I think if we scope compiler atomic builtins to KASAN/KTSAN/KMSAN (and
> > consequently x86/arm64) initially, it becomes more realistic. For the
> > tools we don't care about absolute efficiency and this gets rid of
> > Will's points (2), (4) and (6) here https://lwn.net/Articles/691295/.
> > Re (3) I think rmb/wmb can be reasonably replaced with
> > atomic_thread_fence(acquire/release). Re (5) situation with
> > correctness becomes better very quickly as more people use them in
> > user-space. Since KASAN is not intended to be used in production (or
> > at least such build is expected to crash), we can afford to shake out
> > any remaining correctness issues in such build. (1) I don't fully
> > understand, what exactly is the problem with seq_cst?
> 
> I'll have to leave it to Will to have the final word on these; I'm
> certainly not familiar enough with the C11 memory model to comment on
> (1).

rmb()/wmb() are not remotely similar to
atomic_thread_fenc_{acquire,release}, even if you restrict ordering to
coherent CPUs (i.e. the smp_* variants). Please don't do that :)

I'm also terrified of the optimisations that the compiler is theoretically
allowed to make to C11 atomics given the assumptions of the language
virtual machine, which are not necessarily valid in the kernel environment.
We would at least need well-supported compiler options to disable these
options, and also to allow data races with things like READ_ONCE.

Will

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
