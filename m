Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 53ADB6B0038
	for <linux-mm@kvack.org>; Mon,  6 Mar 2017 07:58:50 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id v190so68471650pfb.5
        for <linux-mm@kvack.org>; Mon, 06 Mar 2017 04:58:50 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id t1si3729621pfa.289.2017.03.06.04.58.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Mar 2017 04:58:49 -0800 (PST)
Date: Mon, 6 Mar 2017 13:58:51 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH] x86, kasan: add KASAN checks to atomic operations
Message-ID: <20170306125851.GL6500@twins.programming.kicks-ass.net>
References: <20170306124254.77615-1-dvyukov@google.com>
 <CACT4Y+YmpTMdJca-rE2nXR-qa=wn_bCqQXaRghtg1uC65-pKyA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CACT4Y+YmpTMdJca-rE2nXR-qa=wn_bCqQXaRghtg1uC65-pKyA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Ingo Molnar <mingo@redhat.com>, kasan-dev <kasan-dev@googlegroups.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, Mar 06, 2017 at 01:50:47PM +0100, Dmitry Vyukov wrote:
> On Mon, Mar 6, 2017 at 1:42 PM, Dmitry Vyukov <dvyukov@google.com> wrote:
> > KASAN uses compiler instrumentation to intercept all memory accesses.
> > But it does not see memory accesses done in assembly code.
> > One notable user of assembly code is atomic operations. Frequently,
> > for example, an atomic reference decrement is the last access to an
> > object and a good candidate for a racy use-after-free.
> >
> > Add manual KASAN checks to atomic operations.
> > Note: we need checks only before asm blocks and don't need them
> > in atomic functions composed of other atomic functions
> > (e.g. load-cmpxchg loops).
> 
> Peter, also pointed me at arch/x86/include/asm/bitops.h. Will add them in v2.
> 

> >  static __always_inline void atomic_add(int i, atomic_t *v)
> >  {
> > +       kasan_check_write(v, sizeof(*v));
> >         asm volatile(LOCK_PREFIX "addl %1,%0"
> >                      : "+m" (v->counter)
> >                      : "ir" (i));


So the problem is doing load/stores from asm bits, and GCC
(traditionally) doesn't try and interpret APP asm bits.

However, could we not write a GCC plugin that does exactly that?
Something that interprets the APP asm bits and generates these KASAN
bits that go with it?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
