Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 254D38E0001
	for <linux-mm@kvack.org>; Mon, 10 Dec 2018 03:55:40 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id c14so7826637pls.21
        for <linux-mm@kvack.org>; Mon, 10 Dec 2018 00:55:40 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id v11si9542270plp.85.2018.12.10.00.55.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 10 Dec 2018 00:55:38 -0800 (PST)
Date: Mon, 10 Dec 2018 09:55:32 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: Should this_cpu_read() be volatile?
Message-ID: <20181210085532.GG5289@hirez.programming.kicks-ass.net>
References: <20181203224920.GQ10377@bombadil.infradead.org>
 <C377D9EF-A0F4-4142-8145-6942DC29A353@gmail.com>
 <EB579DAE-B25F-4869-8529-8586DF4AECFF@gmail.com>
 <20181206102559.GG13538@hirez.programming.kicks-ass.net>
 <55B665E1-3F64-4D87-B779-D1B4AFE719A9@gmail.com>
 <20181207084550.GA2237@hirez.programming.kicks-ass.net>
 <C29C792A-3F47-482D-B0D8-99EABEDF8882@gmail.com>
 <C064896E-268A-4462-8D51-E43C1CF10104@gmail.com>
 <20181208105220.GF5289@hirez.programming.kicks-ass.net>
 <5DE00B41-835C-4E68-B192-2A3C7ACB4392@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5DE00B41-835C-4E68-B192-2A3C7ACB4392@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nadav Amit <nadav.amit@gmail.com>
Cc: Matthew Wilcox <willy@infradead.org>, Vlastimil Babka <vbabka@suse.cz>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, X86 ML <x86@kernel.org>, Ingo Molnar <mingo@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Andy Lutomirski <luto@kernel.org>

On Sun, Dec 09, 2018 at 04:57:43PM -0800, Nadav Amit wrote:
> > On Dec 8, 2018, at 2:52 AM, Peter Zijlstra <peterz@infradead.org> wrote:

> > My patch proposed here:
> > 
> >  https://marc.info/?l=linux-mm&m=154409548410209
> > 
> > would actually fix that one I think, preempt_count() uses
> > raw_cpu_read_4() which will loose the volatile with that patch.

> I tested the patch you referenced, and it certainly improves the situation
> for reads, but there are still small and big issues lying around.

I'm sure :-(, this has been 'festering' for a long while it seems. And
esp. on x86 specific code, where for a long time we all assumed the
various per-cpu APIs were in fact the same (which turns out to very much
not be true).

> The biggest one is that (I think) smp_processor_id() should apparently use
> __this_cpu_read().

Agreed, and note that this will also improve code generation on !x86.

However, I'm not sure the current !debug definition:

#define smp_processor_id() raw_smp_processor_id()

is actually correct. Where raw_smp_processor_id() must be
this_cpu_read() to avoid CSE, we actually want to allow CSE on
smp_processor_id() etc..

> There are all kind of other smaller issues, such as set_irq_regs() and
> get_irq_regs(), which should run with disabled interrupts. They affect the
> generated code in do_IRQ() and others.
> 
> But beyond that, there are so many places in the code that use
> this_cpu_read() while IRQs are guaranteed to be disabled. For example
> arch/x86/mm/tlb.c is full with this_cpu_read/write() and almost(?) all
> should be running with interrupts disabled. Having said that, in my build
> only flush_tlb_func_common() was affected.

This all feels like something static analysis could help with; such
tools would also make sense for !x86 where the difference between the
various per-cpu accessors is even bigger.
