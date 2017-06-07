Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id B7F476B0279
	for <linux-mm@kvack.org>; Tue,  6 Jun 2017 23:33:29 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id w1so285601qtg.6
        for <linux-mm@kvack.org>; Tue, 06 Jun 2017 20:33:29 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id p123si503437qkd.290.2017.06.06.20.33.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Jun 2017 20:33:28 -0700 (PDT)
Message-ID: <1496806405.29205.131.camel@redhat.com>
Subject: Re: [RFC 05/11] x86/mm: Rework lazy TLB mode and TLB freshness
 tracking
From: Rik van Riel <riel@redhat.com>
Date: Tue, 06 Jun 2017 23:33:25 -0400
In-Reply-To: <CALCETrVX73+vHJMVYaddygEFj42oc3ShoUrXOm_s6CBwEP1peA@mail.gmail.com>
References: <cover.1496701658.git.luto@kernel.org>
	 <9b939d6218b78352b9f13594ebf97c1c88a6c33d.1496701658.git.luto@kernel.org>
	 <1496776285.20270.64.camel@redhat.com>
	 <CALCETrVX73+vHJMVYaddygEFj42oc3ShoUrXOm_s6CBwEP1peA@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: X86 ML <x86@kernel.org>, Borislav Petkov <bpetkov@suse.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Nadav Amit <nadav.amit@gmail.com>, Andrew Banman <abanman@sgi.com>, Mike Travis <travis@sgi.com>, Dimitri Sivanich <sivanich@sgi.com>, Juergen Gross <jgross@suse.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>

On Tue, 2017-06-06 at 14:34 -0700, Andy Lutomirski wrote:
> On Tue, Jun 6, 2017 at 12:11 PM, Rik van Riel <riel@redhat.com>
> wrote:
> > On Mon, 2017-06-05 at 15:36 -0700, Andy Lutomirski wrote:
> > 
> > > +++ b/arch/x86/include/asm/mmu_context.h
> > > @@ -122,8 +122,10 @@ static inline void switch_ldt(struct
> > > mm_struct
> > > *prev, struct mm_struct *next)
> > > 
> > > A static inline void enter_lazy_tlb(struct mm_struct *mm, struct
> > > task_struct *tsk)
> > > A {
> > > -A A A A A if (this_cpu_read(cpu_tlbstate.state) == TLBSTATE_OK)
> > > -A A A A A A A A A A A A A this_cpu_write(cpu_tlbstate.state, TLBSTATE_LAZY);
> > > +A A A A A int cpu = smp_processor_id();
> > > +
> > > +A A A A A if (cpumask_test_cpu(cpu, mm_cpumask(mm)))
> > > +A A A A A A A A A A A A A cpumask_clear_cpu(cpu, mm_cpumask(mm));
> > > A }
> > 
> > This is an atomic write to a shared cacheline,
> > every time a CPU goes idle.
> > 
> > I am not sure you really want to do this, since
> > there are some workloads out there that have a
> > crazy number of threads, which go idle hundreds,
> > or even thousands of times a second, on dozens
> > of CPUs at a time. *cough*Java*cough*
> 
> It seems to me that the set of workloads on which this patch will
> hurt
> performance is rather limited.A A We'd need an mm with a lot of
> threads,
> probably spread among a lot of nodes, that is constantly going idle
> and non-idle on multiple CPUs on the same node, where there's nothing
> else happening on those CPUs.

I am assuming the SPECjbb2015 benchmark is representative
of how some actual (albeit crazy) Java workloads behave.

> > Keeping track of the state in a CPU-local variable,
> > written with a non-atomic write, would be much more
> > CPU cache friendly here.
> 
> We could, but then handing remote flushes becomes more complicated.

I already wrote that code. It's not that hard.

> My inclination would be to keep the patch as is and, if this is
> actually a problem, think about solving it more generally.A A The real
> issue is that we need a way to reasonably efficiently find the set of
> CPUs for which a given mm is currently loaded and non-lazy.A A A simple
> improvement would be to split up mm_cpumask so that we'd have one
> cache line per node.A A (And we'd presumably allow several mms to share
> the same pile of memory.)A A Or we could go all out and use percpu
> state
> only and iterate over all online CPUs when flushing (ick!).A A Or
> something in between.

Reading per cpu state is relatively cheap. Writing is
more expensive, but that only needs to be done at TLB
flush time, and is much cheaper than sending an IPI.

Tasks going idle and waking back up seems to be a much
more common operation than doing a TLB flush. Having the
idle path being the more expensive one makes little sense
to me, but I may be overlooking something.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
