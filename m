Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 505BC8E0004
	for <linux-mm@kvack.org>; Sat,  8 Dec 2018 05:52:34 -0500 (EST)
Received: by mail-wr1-f71.google.com with SMTP id 49so2162778wra.14
        for <linux-mm@kvack.org>; Sat, 08 Dec 2018 02:52:34 -0800 (PST)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id u141si4422397wmu.75.2018.12.08.02.52.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sat, 08 Dec 2018 02:52:32 -0800 (PST)
Date: Sat, 8 Dec 2018 11:52:20 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: Should this_cpu_read() be volatile?
Message-ID: <20181208105220.GF5289@hirez.programming.kicks-ass.net>
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
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <C064896E-268A-4462-8D51-E43C1CF10104@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nadav Amit <nadav.amit@gmail.com>
Cc: Matthew Wilcox <willy@infradead.org>, Vlastimil Babka <vbabka@suse.cz>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, X86 ML <x86@kernel.org>, Ingo Molnar <mingo@redhat.com>, Thomas Gleixner <tglx@linutronix.de>

On Fri, Dec 07, 2018 at 04:40:52PM -0800, Nadav Amit wrote:

> > I'm actually having difficulty finding the this_cpu_read() in any of the
> > functions you mention, so I cannot make any concrete suggestions other
> > than pointing at the alternative functions available.
> 
> 
> So I got deeper into the code to understand a couple of differences. In the
> case of select_idle_sibling(), the patch (Peter’s) increase the function
> code size by 123 bytes (over the baseline of 986). The per-cpu variable is
> called through the following call chain:
> 
> 	select_idle_sibling()
> 	=> select_idle_cpu()
> 	=> local_clock()
> 	=> raw_smp_processor_id()
> 
> And results in 2 more calls to sched_clock_cpu(), as the compiler assumes
> the processor id changes in between (which obviously wouldn’t happen).

That is the thing with raw_smp_processor_id(), it is allowed to be used
in preemptible context, and there it _obviously_ can change between
subsequent invocations.

So again, this change is actually good.

If we want to fix select_idle_cpu(), we should maybe not use
local_clock() there but use sched_clock_cpu() with a stable argument,
this code runs with IRQs disabled and therefore the CPU number is stable
for us here.

> There may be more changes around, which I didn’t fully analyze. But
> the very least reading the processor id should not get “volatile”.
> 
> As for finish_task_switch(), the impact is only few bytes, but still
> unnecessary. It appears that with your patch preempt_count() causes multiple
> reads of __preempt_count in this code:
> 
>        if (WARN_ONCE(preempt_count() != 2*PREEMPT_DISABLE_OFFSET,
>                      "corrupted preempt_count: %s/%d/0x%x\n",
>                      current->comm, current->pid, preempt_count()))
>                preempt_count_set(FORK_PREEMPT_COUNT);

My patch proposed here:

  https://marc.info/?l=linux-mm&m=154409548410209

would actually fix that one I think, preempt_count() uses
raw_cpu_read_4() which will loose the volatile with that patch.
