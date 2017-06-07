Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id E26346B0279
	for <linux-mm@kvack.org>; Wed,  7 Jun 2017 00:55:03 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id t9so613313oih.13
        for <linux-mm@kvack.org>; Tue, 06 Jun 2017 21:55:03 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id a57si282648ote.162.2017.06.06.21.55.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Jun 2017 21:55:02 -0700 (PDT)
Received: from mail-ua0-f182.google.com (mail-ua0-f182.google.com [209.85.217.182])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id D7D4D23A0C
	for <linux-mm@kvack.org>; Wed,  7 Jun 2017 04:55:01 +0000 (UTC)
Received: by mail-ua0-f182.google.com with SMTP id x47so1059730uab.0
        for <linux-mm@kvack.org>; Tue, 06 Jun 2017 21:55:01 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1496806405.29205.131.camel@redhat.com>
References: <cover.1496701658.git.luto@kernel.org> <9b939d6218b78352b9f13594ebf97c1c88a6c33d.1496701658.git.luto@kernel.org>
 <1496776285.20270.64.camel@redhat.com> <CALCETrVX73+vHJMVYaddygEFj42oc3ShoUrXOm_s6CBwEP1peA@mail.gmail.com>
 <1496806405.29205.131.camel@redhat.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Tue, 6 Jun 2017 21:54:40 -0700
Message-ID: <CALCETrV9Xnr7vUdd4Q1dfHL8_FN6WAiGeXLGe3aDxs83a39OUw@mail.gmail.com>
Subject: Re: [RFC 05/11] x86/mm: Rework lazy TLB mode and TLB freshness tracking
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Andy Lutomirski <luto@kernel.org>, X86 ML <x86@kernel.org>, Borislav Petkov <bpetkov@suse.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Nadav Amit <nadav.amit@gmail.com>, Andrew Banman <abanman@sgi.com>, Mike Travis <travis@sgi.com>, Dimitri Sivanich <sivanich@sgi.com>, Juergen Gross <jgross@suse.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>

On Tue, Jun 6, 2017 at 8:33 PM, Rik van Riel <riel@redhat.com> wrote:
> On Tue, 2017-06-06 at 14:34 -0700, Andy Lutomirski wrote:
>> On Tue, Jun 6, 2017 at 12:11 PM, Rik van Riel <riel@redhat.com>
>> wrote:
>> > On Mon, 2017-06-05 at 15:36 -0700, Andy Lutomirski wrote:
>> >
>> > > +++ b/arch/x86/include/asm/mmu_context.h
>> > > @@ -122,8 +122,10 @@ static inline void switch_ldt(struct
>> > > mm_struct
>> > > *prev, struct mm_struct *next)
>> > >
>> > >  static inline void enter_lazy_tlb(struct mm_struct *mm, struct
>> > > task_struct *tsk)
>> > >  {
>> > > -     if (this_cpu_read(cpu_tlbstate.state) == TLBSTATE_OK)
>> > > -             this_cpu_write(cpu_tlbstate.state, TLBSTATE_LAZY);
>> > > +     int cpu = smp_processor_id();
>> > > +
>> > > +     if (cpumask_test_cpu(cpu, mm_cpumask(mm)))
>> > > +             cpumask_clear_cpu(cpu, mm_cpumask(mm));
>> > >  }
>> >
>> > This is an atomic write to a shared cacheline,
>> > every time a CPU goes idle.
>> >
>> > I am not sure you really want to do this, since
>> > there are some workloads out there that have a
>> > crazy number of threads, which go idle hundreds,
>> > or even thousands of times a second, on dozens
>> > of CPUs at a time. *cough*Java*cough*
>>
>> It seems to me that the set of workloads on which this patch will
>> hurt
>> performance is rather limited.  We'd need an mm with a lot of
>> threads,
>> probably spread among a lot of nodes, that is constantly going idle
>> and non-idle on multiple CPUs on the same node, where there's nothing
>> else happening on those CPUs.
>
> I am assuming the SPECjbb2015 benchmark is representative
> of how some actual (albeit crazy) Java workloads behave.

The little picture on the SPECjbb2015 site talks about
inter-java-process communication, which suggests that we'll bounce
between two non-idle mms, which should get significantly faster with
this patch set applied.

>
>> > Keeping track of the state in a CPU-local variable,
>> > written with a non-atomic write, would be much more
>> > CPU cache friendly here.
>>
>> We could, but then handing remote flushes becomes more complicated.
>
> I already wrote that code. It's not that hard.
>
>> My inclination would be to keep the patch as is and, if this is
>> actually a problem, think about solving it more generally.  The real
>> issue is that we need a way to reasonably efficiently find the set of
>> CPUs for which a given mm is currently loaded and non-lazy.  A simple
>> improvement would be to split up mm_cpumask so that we'd have one
>> cache line per node.  (And we'd presumably allow several mms to share
>> the same pile of memory.)  Or we could go all out and use percpu
>> state
>> only and iterate over all online CPUs when flushing (ick!).  Or
>> something in between.
>
> Reading per cpu state is relatively cheap. Writing is
> more expensive, but that only needs to be done at TLB
> flush time, and is much cheaper than sending an IPI.
>
> Tasks going idle and waking back up seems to be a much
> more common operation than doing a TLB flush. Having the
> idle path being the more expensive one makes little sense
> to me, but I may be overlooking something.

I agree with all of this.  I'm not saying that we shouldn't try to
optimize these transitions on large systems where an mm is in use on a
lot of cores at once.  My point is that we shouldn't treat idle as a
special case that functions completely differently from everything
else.  With ths series applied, we have the ability to accurately
determine whether a the current CPU's TLB is up to date for a given mm
with good cache performance: we look at a single shared cacheline
(mm->context) and two (one if !PCID) percpu cachelines.  Idle is
almost exactly the same condition as switched-out-but-still-live: we
have a context that's represented in the TLB, but we're not trying to
keep it coherent.  I think that, especially in the presence of PCID,
it would be rather odd to treat them differently.

The only real question in my book is how we should be tracking which
CPUs are currently attempting to maintain their TLBs *coherently* for
a given mm, which is exactly the same as the set of CPUs that are
currently running that mm non-lazily.  With my patches applied, it's a
cpumask.  4.11, it's a cpumask that's inaccurate, leading to
unnecessary IPIs, but that inaccuracy speeds up one particular type of
workload.  We could come up with other data structures for this.  The
very simplest is to ditch mm_cpumask entirely and just use percpu
variables for everything, but that would pessimize the single-threaded
case.

Anyway, my point is that I think that, if this is really a problem, we
should optimize mm_cpumask updating more generally instead of coming
up with something that's specific to idle transitions.

Anyway, I kind of suspect that we're arguing over something quite
minor.  I found a paper suggesting that cmpxchg took about 100ns for a
worst-case access to a cache line that's exclsively owned by another
socket.  We're using lock bts/btr, which should be a little faster,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
