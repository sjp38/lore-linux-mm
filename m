Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 75C2D8E0001
	for <linux-mm@kvack.org>; Sun,  9 Dec 2018 19:57:48 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id s27so6415914pgm.4
        for <linux-mm@kvack.org>; Sun, 09 Dec 2018 16:57:48 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id v15sor15837090pfa.0.2018.12.09.16.57.46
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 09 Dec 2018 16:57:47 -0800 (PST)
Content-Type: text/plain;
	charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 12.1 \(3445.101.1\))
Subject: Re: Should this_cpu_read() be volatile?
From: Nadav Amit <nadav.amit@gmail.com>
In-Reply-To: <20181208105220.GF5289@hirez.programming.kicks-ass.net>
Date: Sun, 9 Dec 2018 16:57:43 -0800
Content-Transfer-Encoding: quoted-printable
Message-Id: <5DE00B41-835C-4E68-B192-2A3C7ACB4392@gmail.com>
References: <20181203161352.GP10377@bombadil.infradead.org>
 <4F09425C-C9AB-452F-899C-3CF3D4B737E1@gmail.com>
 <20181203224920.GQ10377@bombadil.infradead.org>
 <C377D9EF-A0F4-4142-8145-6942DC29A353@gmail.com>
 <EB579DAE-B25F-4869-8529-8586DF4AECFF@gmail.com>
 <20181206102559.GG13538@hirez.programming.kicks-ass.net>
 <55B665E1-3F64-4D87-B779-D1B4AFE719A9@gmail.com>
 <20181207084550.GA2237@hirez.programming.kicks-ass.net>
 <C29C792A-3F47-482D-B0D8-99EABEDF8882@gmail.com>
 <C064896E-268A-4462-8D51-E43C1CF10104@gmail.com>
 <20181208105220.GF5289@hirez.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Matthew Wilcox <willy@infradead.org>, Vlastimil Babka <vbabka@suse.cz>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, X86 ML <x86@kernel.org>, Ingo Molnar <mingo@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Andy Lutomirski <luto@kernel.org>

> On Dec 8, 2018, at 2:52 AM, Peter Zijlstra <peterz@infradead.org> =
wrote:
>=20
> On Fri, Dec 07, 2018 at 04:40:52PM -0800, Nadav Amit wrote:
>=20
>>> I'm actually having difficulty finding the this_cpu_read() in any of =
the
>>> functions you mention, so I cannot make any concrete suggestions =
other
>>> than pointing at the alternative functions available.
>>=20
>>=20
>> So I got deeper into the code to understand a couple of differences. =
In the
>> case of select_idle_sibling(), the patch (Peter=E2=80=99s) increase =
the function
>> code size by 123 bytes (over the baseline of 986). The per-cpu =
variable is
>> called through the following call chain:
>>=20
>> 	select_idle_sibling()
>> 	=3D> select_idle_cpu()
>> 	=3D> local_clock()
>> 	=3D> raw_smp_processor_id()
>>=20
>> And results in 2 more calls to sched_clock_cpu(), as the compiler =
assumes
>> the processor id changes in between (which obviously wouldn=E2=80=99t =
happen).
>=20
> That is the thing with raw_smp_processor_id(), it is allowed to be =
used
> in preemptible context, and there it _obviously_ can change between
> subsequent invocations.
>=20
> So again, this change is actually good.
>=20
> If we want to fix select_idle_cpu(), we should maybe not use
> local_clock() there but use sched_clock_cpu() with a stable argument,
> this code runs with IRQs disabled and therefore the CPU number is =
stable
> for us here.
>=20
>> There may be more changes around, which I didn=E2=80=99t fully =
analyze. But
>> the very least reading the processor id should not get =
=E2=80=9Cvolatile=E2=80=9D.
>>=20
>> As for finish_task_switch(), the impact is only few bytes, but still
>> unnecessary. It appears that with your patch preempt_count() causes =
multiple
>> reads of __preempt_count in this code:
>>=20
>>       if (WARN_ONCE(preempt_count() !=3D 2*PREEMPT_DISABLE_OFFSET,
>>                     "corrupted preempt_count: %s/%d/0x%x\n",
>>                     current->comm, current->pid, preempt_count()))
>>               preempt_count_set(FORK_PREEMPT_COUNT);
>=20
> My patch proposed here:
>=20
>  https://marc.info/?l=3Dlinux-mm&m=3D154409548410209
>=20
> would actually fix that one I think, preempt_count() uses
> raw_cpu_read_4() which will loose the volatile with that patch.

Sorry for the spam from yesterday. That what happens when I try to write
emails on my phone while I=E2=80=99m distracted.

I tested the patch you referenced, and it certainly improves the =
situation
for reads, but there are still small and big issues lying around.

The biggest one is that (I think) smp_processor_id() should apparently =
use
__this_cpu_read(). Anyhow, when preemption checks are on, it is =
validated
that smp_processor_id() is not used while preemption is enabled, and =
IRQs
are not supposed to change its value. Otherwise the generated code of =
many
functions is affected.

There are all kind of other smaller issues, such as set_irq_regs() and
get_irq_regs(), which should run with disabled interrupts. They affect =
the
generated code in do_IRQ() and others.

But beyond that, there are so many places in the code that use
this_cpu_read() while IRQs are guaranteed to be disabled. For example
arch/x86/mm/tlb.c is full with this_cpu_read/write() and almost(?) all
should be running with interrupts disabled. Having said that, in my =
build
only flush_tlb_func_common() was affected.
