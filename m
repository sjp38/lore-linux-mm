Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5BF0F8E0095
	for <linux-mm@kvack.org>; Tue, 11 Dec 2018 12:11:22 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id a9so11013342pla.2
        for <linux-mm@kvack.org>; Tue, 11 Dec 2018 09:11:22 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id 67sor22829968pgb.68.2018.12.11.09.11.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 11 Dec 2018 09:11:20 -0800 (PST)
Content-Type: text/plain;
	charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 12.1 \(3445.101.1\))
Subject: Re: Should this_cpu_read() be volatile?
From: Nadav Amit <nadav.amit@gmail.com>
In-Reply-To: <20181210085532.GG5289@hirez.programming.kicks-ass.net>
Date: Tue, 11 Dec 2018 09:11:17 -0800
Content-Transfer-Encoding: 7bit
Message-Id: <058624AF-3933-4C44-A137-E33FC5180B86@gmail.com>
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
 <20181210085532.GG5289@hirez.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Matthew Wilcox <willy@infradead.org>, Vlastimil Babka <vbabka@suse.cz>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, X86 ML <x86@kernel.org>, Ingo Molnar <mingo@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Andy Lutomirski <luto@kernel.org>

> On Dec 10, 2018, at 12:55 AM, Peter Zijlstra <peterz@infradead.org> wrote:
> 
> On Sun, Dec 09, 2018 at 04:57:43PM -0800, Nadav Amit wrote:
>>> On Dec 8, 2018, at 2:52 AM, Peter Zijlstra <peterz@infradead.org> wrote:
> 
>>> My patch proposed here:
>>> 
>>> https://marc.info/?l=linux-mm&m=154409548410209
>>> 
>>> would actually fix that one I think, preempt_count() uses
>>> raw_cpu_read_4() which will loose the volatile with that patch.
> 
>> I tested the patch you referenced, and it certainly improves the situation
>> for reads, but there are still small and big issues lying around.
> 
> I'm sure :-(, this has been 'festering' for a long while it seems. And
> esp. on x86 specific code, where for a long time we all assumed the
> various per-cpu APIs were in fact the same (which turns out to very much
> not be true).
> 
>> The biggest one is that (I think) smp_processor_id() should apparently use
>> __this_cpu_read().
> 
> Agreed, and note that this will also improve code generation on !x86.
> 
> However, I'm not sure the current !debug definition:
> 
> #define smp_processor_id() raw_smp_processor_id()
> 
> is actually correct. Where raw_smp_processor_id() must be
> this_cpu_read() to avoid CSE, we actually want to allow CSE on
> smp_processor_id() etc..

Yes. That makes sense.

> 
>> There are all kind of other smaller issues, such as set_irq_regs() and
>> get_irq_regs(), which should run with disabled interrupts. They affect the
>> generated code in do_IRQ() and others.
>> 
>> But beyond that, there are so many places in the code that use
>> this_cpu_read() while IRQs are guaranteed to be disabled. For example
>> arch/x86/mm/tlb.c is full with this_cpu_read/write() and almost(?) all
>> should be running with interrupts disabled. Having said that, in my build
>> only flush_tlb_func_common() was affected.
> 
> This all feels like something static analysis could help with; such
> tools would also make sense for !x86 where the difference between the
> various per-cpu accessors is even bigger.

If something like that existed, it could also allow to get rid of
local_irq_save() (and use local_irq_disable() instead).
