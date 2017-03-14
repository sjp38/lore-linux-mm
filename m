Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 443E26B038E
	for <linux-mm@kvack.org>; Tue, 14 Mar 2017 11:44:47 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id 190so307633798pgg.3
        for <linux-mm@kvack.org>; Tue, 14 Mar 2017 08:44:47 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id x26si15097408pge.30.2017.03.14.08.44.46
        for <linux-mm@kvack.org>;
        Tue, 14 Mar 2017 08:44:46 -0700 (PDT)
Date: Tue, 14 Mar 2017 15:44:30 +0000
From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: [PATCH] x86, kasan: add KASAN checks to atomic operations
Message-ID: <20170314154429.GB15740@leverpostej>
References: <20170306125851.GL6500@twins.programming.kicks-ass.net>
 <20170306130107.GK6536@twins.programming.kicks-ass.net>
 <CACT4Y+ZDxk2CkaGaqVJfrzoBf4ZXDZ2L8vaAnLOjuY0yx85jgA@mail.gmail.com>
 <20170306162018.GC18519@leverpostej>
 <20170306203500.GR6500@twins.programming.kicks-ass.net>
 <CACT4Y+ZNb_eCLVBz6cUyr0jVPdSW_-nCedcBAh0anfds91B2vw@mail.gmail.com>
 <20170308152027.GA13133@leverpostej>
 <20170308174300.GL20400@arm.com>
 <CACT4Y+bjMLgXHv0Wwuo1fnEWitxfdJLdH2oCy+rSa2kTjNXmuw@mail.gmail.com>
 <20170314153230.GR5680@worktop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170314153230.GR5680@worktop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Dmitry Vyukov <dvyukov@google.com>, Will Deacon <will.deacon@arm.com>, Andrew Morton <akpm@linux-foundation.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Ingo Molnar <mingo@redhat.com>, kasan-dev <kasan-dev@googlegroups.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, "x86@kernel.org" <x86@kernel.org>

On Tue, Mar 14, 2017 at 04:32:30PM +0100, Peter Zijlstra wrote:
> On Tue, Mar 14, 2017 at 04:22:52PM +0100, Dmitry Vyukov wrote:
> > -static __always_inline int atomic_read(const atomic_t *v)
> > +static __always_inline int arch_atomic_read(const atomic_t *v)
> >  {
> > -	return READ_ONCE((v)->counter);
> > +	return READ_ONCE_NOCHECK((v)->counter);
> 
> Should NOCHEKC come with a comment, because i've no idea why this is so.

I suspect the idea is that given the wrapper will have done the KASAN
check, duplicating it here is either sub-optimal, or results in
duplicate splats. READ_ONCE() has an implicit KASAN check,
READ_ONCE_NOCHECK() does not.

If this is to solve duplicate splats, it'd be worth having a
WRITE_ONCE_NOCHECK() for arch_atomic_set().

Agreed on the comment, regardless.

Thanks,
Mark.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
