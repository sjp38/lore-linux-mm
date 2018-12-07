Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 870E56B7F93
	for <linux-mm@kvack.org>; Fri,  7 Dec 2018 03:45:54 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id t2so2737894pfj.15
        for <linux-mm@kvack.org>; Fri, 07 Dec 2018 00:45:54 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id f82si2668087pfa.221.2018.12.07.00.45.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 07 Dec 2018 00:45:53 -0800 (PST)
Date: Fri, 7 Dec 2018 09:45:50 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: Number of arguments in vmalloc.c
Message-ID: <20181207084550.GA2237@hirez.programming.kicks-ass.net>
References: <20181128140136.GG10377@bombadil.infradead.org>
 <3264149f-e01e-faa2-3bc8-8aa1c255e075@suse.cz>
 <20181203161352.GP10377@bombadil.infradead.org>
 <4F09425C-C9AB-452F-899C-3CF3D4B737E1@gmail.com>
 <20181203224920.GQ10377@bombadil.infradead.org>
 <C377D9EF-A0F4-4142-8145-6942DC29A353@gmail.com>
 <EB579DAE-B25F-4869-8529-8586DF4AECFF@gmail.com>
 <20181206102559.GG13538@hirez.programming.kicks-ass.net>
 <55B665E1-3F64-4D87-B779-D1B4AFE719A9@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <55B665E1-3F64-4D87-B779-D1B4AFE719A9@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nadav Amit <nadav.amit@gmail.com>
Cc: Matthew Wilcox <willy@infradead.org>, Vlastimil Babka <vbabka@suse.cz>, Linux-MM <linux-mm@kvack.org>

On Thu, Dec 06, 2018 at 09:26:24AM -0800, Nadav Amit wrote:
> > On Dec 6, 2018, at 2:25 AM, Peter Zijlstra <peterz@infradead.org> wrote:
> > 
> > On Thu, Dec 06, 2018 at 12:28:26AM -0800, Nadav Amit wrote:
> >> [ +Peter ]
> >> 
> >> So I dug some more (I’m still not done), and found various trivial things
> >> (e.g., storing zero extending u32 immediate is shorter for registers,
> >> inlining already takes place).
> >> 
> >> *But* there is one thing that may require some attention - patch
> >> b59167ac7bafd ("x86/percpu: Fix this_cpu_read()”) set ordering constraints
> >> on the VM_ARGS() evaluation. And this patch also imposes, it appears,
> >> (unnecessary) constraints on other pieces of code.
> >> 
> >> These constraints are due to the addition of the volatile keyword for
> >> this_cpu_read() by the patch. This affects at least 68 functions in my
> >> kernel build, some of which are hot (I think), e.g., finish_task_switch(),
> >> smp_x86_platform_ipi() and select_idle_sibling().
> >> 
> >> Peter, perhaps the solution was too big of a hammer? Is it possible instead
> >> to create a separate "this_cpu_read_once()” with the volatile keyword? Such
> >> a function can be used for native_sched_clock() and other seqlocks, etc.
> > 
> > No. like the commit writes this_cpu_read() _must_ imply READ_ONCE(). If
> > you want something else, use something else, there's plenty other
> > options available.
> > 
> > There's this_cpu_op_stable(), but also __this_cpu_read() and
> > raw_this_cpu_read() (which currently don't differ from this_cpu_read()
> > but could).
> 
> Would setting the inline assembly memory operand both as input and output be
> better than using the “volatile”?

I don't know.. I'm forever befuddled by the exact semantics of gcc
inline asm.

> I think that If you do that, the compiler would should the this_cpu_read()
> as something that changes the per-cpu-variable, which would make it invalid
> to re-read the value. At the same time, it would not prevent reordering the
> read with other stuff.

So the thing is; as I wrote, the generic version of this_cpu_*() is:

	local_irq_save();
	__this_cpu_*();
	local_irq_restore();

And per local_irq_{save,restore}() including compiler barriers that
cannot be reordered around either.

And per the principle of least surprise, I think our primitives should
have similar semantics.


I'm actually having difficulty finding the this_cpu_read() in any of the
functions you mention, so I cannot make any concrete suggestions other
than pointing at the alternative functions available.
