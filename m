Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 045818E0004
	for <linux-mm@kvack.org>; Fri,  7 Dec 2018 18:13:01 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id b17so4595885pfc.11
        for <linux-mm@kvack.org>; Fri, 07 Dec 2018 15:13:00 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z83sor8133846pfd.11.2018.12.07.15.12.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 07 Dec 2018 15:12:59 -0800 (PST)
Content-Type: text/plain;
	charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 12.1 \(3445.101.1\))
Subject: Re: Number of arguments in vmalloc.c
From: Nadav Amit <nadav.amit@gmail.com>
In-Reply-To: <20181207084550.GA2237@hirez.programming.kicks-ass.net>
Date: Fri, 7 Dec 2018 15:12:56 -0800
Content-Transfer-Encoding: quoted-printable
Message-Id: <C29C792A-3F47-482D-B0D8-99EABEDF8882@gmail.com>
References: <20181128140136.GG10377@bombadil.infradead.org>
 <3264149f-e01e-faa2-3bc8-8aa1c255e075@suse.cz>
 <20181203161352.GP10377@bombadil.infradead.org>
 <4F09425C-C9AB-452F-899C-3CF3D4B737E1@gmail.com>
 <20181203224920.GQ10377@bombadil.infradead.org>
 <C377D9EF-A0F4-4142-8145-6942DC29A353@gmail.com>
 <EB579DAE-B25F-4869-8529-8586DF4AECFF@gmail.com>
 <20181206102559.GG13538@hirez.programming.kicks-ass.net>
 <55B665E1-3F64-4D87-B779-D1B4AFE719A9@gmail.com>
 <20181207084550.GA2237@hirez.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Matthew Wilcox <willy@infradead.org>, Vlastimil Babka <vbabka@suse.cz>, Linux-MM <linux-mm@kvack.org>

[ We can start a new thread, since I have the tendency to hijack =
threads. ]

> On Dec 7, 2018, at 12:45 AM, Peter Zijlstra <peterz@infradead.org> =
wrote:
>=20
> On Thu, Dec 06, 2018 at 09:26:24AM -0800, Nadav Amit wrote:
>>> On Dec 6, 2018, at 2:25 AM, Peter Zijlstra <peterz@infradead.org> =
wrote:
>>>=20
>>> On Thu, Dec 06, 2018 at 12:28:26AM -0800, Nadav Amit wrote:
>>>> [ +Peter ]
>>>>=20
>>>> So I dug some more (I=E2=80=99m still not done), and found various =
trivial things
>>>> (e.g., storing zero extending u32 immediate is shorter for =
registers,
>>>> inlining already takes place).
>>>>=20
>>>> *But* there is one thing that may require some attention - patch
>>>> b59167ac7bafd ("x86/percpu: Fix this_cpu_read()=E2=80=9D) set =
ordering constraints
>>>> on the VM_ARGS() evaluation. And this patch also imposes, it =
appears,
>>>> (unnecessary) constraints on other pieces of code.
>>>>=20
>>>> These constraints are due to the addition of the volatile keyword =
for
>>>> this_cpu_read() by the patch. This affects at least 68 functions in =
my
>>>> kernel build, some of which are hot (I think), e.g., =
finish_task_switch(),
>>>> smp_x86_platform_ipi() and select_idle_sibling().
>>>>=20
>>>> Peter, perhaps the solution was too big of a hammer? Is it possible =
instead
>>>> to create a separate "this_cpu_read_once()=E2=80=9D with the =
volatile keyword? Such
>>>> a function can be used for native_sched_clock() and other seqlocks, =
etc.
>>>=20
>>> No. like the commit writes this_cpu_read() _must_ imply READ_ONCE(). =
If
>>> you want something else, use something else, there's plenty other
>>> options available.
>>>=20
>>> There's this_cpu_op_stable(), but also __this_cpu_read() and
>>> raw_this_cpu_read() (which currently don't differ from =
this_cpu_read()
>>> but could).
>>=20
>> Would setting the inline assembly memory operand both as input and =
output be
>> better than using the =E2=80=9Cvolatile=E2=80=9D?
>=20
> I don't know.. I'm forever befuddled by the exact semantics of gcc
> inline asm.
>=20
>> I think that If you do that, the compiler would should the =
this_cpu_read()
>> as something that changes the per-cpu-variable, which would make it =
invalid
>> to re-read the value. At the same time, it would not prevent =
reordering the
>> read with other stuff.
>=20
> So the thing is; as I wrote, the generic version of this_cpu_*() is:
>=20
> 	local_irq_save();
> 	__this_cpu_*();
> 	local_irq_restore();
>=20
> And per local_irq_{save,restore}() including compiler barriers that
> cannot be reordered around either.
>=20
> And per the principle of least surprise, I think our primitives should
> have similar semantics.

I guess so, but as you=E2=80=99ll see below, the end result is ugly.

> I'm actually having difficulty finding the this_cpu_read() in any of =
the
> functions you mention, so I cannot make any concrete suggestions other
> than pointing at the alternative functions available.


So I got deeper into the code to understand a couple of differences. In =
the
case of select_idle_sibling(), the patch (Peter=E2=80=99s) increase the =
function
code size by 123 bytes (over the baseline of 986). The per-cpu variable =
is
called through the following call chain:

	select_idle_sibling()
	=3D> select_idle_cpu()
	=3D> local_clock()
	=3D> raw_smp_processor_id()

And results in 2 more calls to sched_clock_cpu(), as the compiler =
assumes
the processor id changes in between (which obviously wouldn=E2=80=99t =
happen). There
may be more changes around, which I didn=E2=80=99t fully analyze. But =
the very least
reading the processor id should not get =E2=80=9Cvolatile=E2=80=9D.

As for finish_task_switch(), the impact is only few bytes, but still
unnecessary. It appears that with your patch preempt_count() causes =
multiple
reads of __preempt_count in this code:

        if (WARN_ONCE(preempt_count() !=3D 2*PREEMPT_DISABLE_OFFSET,
                      "corrupted preempt_count: %s/%d/0x%x\n",
                      current->comm, current->pid, preempt_count()))
                preempt_count_set(FORK_PREEMPT_COUNT);

Again, this is unwarranted, as the preemption count should not be =
changed in
any interrupt.
