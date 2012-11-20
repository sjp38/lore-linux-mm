Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id 30B116B007B
	for <linux-mm@kvack.org>; Tue, 20 Nov 2012 02:49:18 -0500 (EST)
Received: by mail-ie0-f169.google.com with SMTP id 10so10084748ied.14
        for <linux-mm@kvack.org>; Mon, 19 Nov 2012 23:49:17 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20121120074445.GA14539@gmail.com>
References: <1353291284-2998-1-git-send-email-mingo@kernel.org>
 <20121119162909.GL8218@suse.de> <alpine.DEB.2.00.1211191644340.24618@chino.kir.corp.google.com>
 <alpine.DEB.2.00.1211191703270.24618@chino.kir.corp.google.com>
 <20121120060014.GA14065@gmail.com> <alpine.DEB.2.00.1211192213420.5498@chino.kir.corp.google.com>
 <20121120074445.GA14539@gmail.com>
From: Paul Turner <pjt@google.com>
Date: Mon, 19 Nov 2012 23:48:47 -0800
Message-ID: <CAPM31RKCQ_+ArU2ZV4VcQHKV30riTZKMvF06F4KatHA1tQ4xqQ@mail.gmail.com>
Subject: Re: [PATCH 00/27] Latest numa/core release, v16
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Peter Zijlstra <a.p.zijlstra@chello.nl>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>

On Mon, Nov 19, 2012 at 11:44 PM, Ingo Molnar <mingo@kernel.org> wrote:
>
> * David Rientjes <rientjes@google.com> wrote:
>
>> On Tue, 20 Nov 2012, Ingo Molnar wrote:
>>
>> > > > numa/core at ec05a2311c35 ("Merge branch 'sched/urgent' into
>> > > > sched/core") had an average throughput of 136918.34
>> > > > SPECjbb2005 bops, which is a 6.3% regression.
>> > >
>> > > perftop during the run on numa/core at 01aa90068b12 ("sched:
>> > > Use the best-buddy 'ideal cpu' in balancing decisions"):
>> > >
>> > >     15.99%  [kernel]  [k] page_fault
>> > >      4.05%  [kernel]  [k] getnstimeofday
>> > >      3.96%  [kernel]  [k] _raw_spin_lock
>> > >      3.20%  [kernel]  [k] rcu_check_callbacks
>> > >      2.93%  [kernel]  [k] generic_smp_call_function_interrupt
>> > >      2.90%  [kernel]  [k] __do_page_fault
>> > >      2.82%  [kernel]  [k] ktime_get
>> >
>> > Thanks for testing, that's very interesting - could you tell me
>> > more about exactly what kind of hardware this is? I'll try to
>> > find a similar system and reproduce the performance regression.
>> >
>>
>> This happened to be an Opteron (but not 83xx series), 2.4Ghz.
>
> Ok - roughly which family/model from /proc/cpuinfo?
>
>> Your benchmarks were different in the number of cores but also
>> in the amount of memory, do you think numa/core would regress
>> because this is 32GB and not 64GB?
>
> I'd not expect much sensitivity to RAM size.
>
>> > (A wild guess would be an older 4x Opteron system, 83xx
>> > series or so?)
>>
>> Just curious, how you would guess that? [...]
>
> I'm testing numa/core on many systems and the performance
> figures seemed to roughly map to that range.
>
>> [...]  Is there something about Opteron 83xx that make
>> numa/core regress?
>
> Not that I knew of - but apparently there is! I'll try to find a
> system that matches yours as closely as possible and have a
> look.

Here I'd note the node-distances that David included above.  This
system is not fully connected, having an (asymmetric) kite topology.
Only nodes nodes 1 and 2 are fully connected.

This is sufficiently whacky that it seems a likely candidate :-).

- Paul

>
>> > Also, the profile looks weird to me. Here is how perf top looks
>> > like on my system during a similarly configured, "healthy"
>> > SPECjbb run:
>> >
>> >  91.29%  perf-6687.map            [.] 0x00007fffed1e8f21
>> >   4.81%  libjvm.so                [.] 0x00000000007004a0
>> >   0.93%  [vdso]                   [.] 0x00007ffff7ffe60c
>> >   0.72%  [kernel]                 [k] do_raw_spin_lock
>> >   0.36%  [kernel]                 [k] generic_smp_call_function_interrupt
>> >   0.10%  [kernel]                 [k] format_decode
>> >   0.07%  [kernel]                 [k] rcu_check_callbacks
>> >   0.07%  [kernel]                 [k] apic_timer_interrupt
>> >   0.07%  [kernel]                 [k] call_function_interrupt
>> >   0.06%  libc-2.15.so             [.] __strcmp_sse42
>> >   0.06%  [kernel]                 [k] irqtime_account_irq
>> >   0.06%  perf                     [.] 0x000000000004bb7c
>> >   0.05%  [kernel]                 [k] x86_pmu_disable_all
>> >   0.04%  libc-2.15.so             [.] __memcpy_ssse3
>> >   0.04%  [kernel]                 [k] ktime_get
>> >   0.04%  [kernel]                 [k] account_group_user_time
>> >   0.03%  [kernel]                 [k] vbin_printf
>> >
>> > and that is what SPECjbb does: it spends 97% of its time in Java
>> > code - yet there's no Java overhead visible in your profile -
>> > how is that possible? Could you try a newer perf on that box:
>> >
>>
>> It's perf top -U, the benchmark itself was unchanged so I
>> didn't think it was interesting to gather the user symbols.
>> If that would be helpful, let me know!
>
> Yeah, regular perf top output would be very helpful to get a
> general sense of proportion. Thanks!
>
>         Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
