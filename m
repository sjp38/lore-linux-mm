Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 71C2A6B0032
	for <linux-mm@kvack.org>; Mon, 12 Jan 2015 21:27:52 -0500 (EST)
Received: by mail-pa0-f48.google.com with SMTP id rd3so639349pab.7
        for <linux-mm@kvack.org>; Mon, 12 Jan 2015 18:27:52 -0800 (PST)
Received: from lgeamrelo02.lge.com (lgeamrelo02.lge.com. [156.147.1.126])
        by mx.google.com with ESMTP id ck1si25622788pdb.2.2015.01.12.18.27.49
        for <linux-mm@kvack.org>;
        Mon, 12 Jan 2015 18:27:50 -0800 (PST)
Date: Tue, 13 Jan 2015 11:27:47 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 0/3] mm: cma: /proc/cmainfo
Message-ID: <20150113022747.GA14137@bbox>
References: <cover.1419602920.git.s.strogin@partner.samsung.com>
 <20141229023639.GC27095@bbox>
 <54A1B11A.6020307@codeaurora.org>
 <20141230044726.GA22342@bbox>
 <20150109091904.41294966@gandalf.local.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20150109091904.41294966@gandalf.local.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Laura Abbott <lauraa@codeaurora.org>, "Stefan I. Strogin" <s.strogin@partner.samsung.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, aneesh.kumar@linux.vnet.ibm.com, Laurent Pinchart <laurent.pinchart@ideasonboard.com>, Dmitry Safonov <d.safonov@partner.samsung.com>, Pintu Kumar <pintu.k@samsung.com>, Weijie Yang <weijie.yang@samsung.com>, SeongJae Park <sj38.park@gmail.com>, Hui Zhu <zhuhui@xiaomi.com>, Dyasly Sergey <s.dyasly@samsung.com>, Vyacheslav Tyrtov <v.tyrtov@samsung.com>, namhyung@kernel.org

Hello, Steven,

On Fri, Jan 09, 2015 at 09:19:04AM -0500, Steven Rostedt wrote:
> 
> Wow, too much work over the holidays ;-)

Pretend to be diligent.

> 
> 
> On Tue, 30 Dec 2014 13:47:26 +0900
> Minchan Kim <minchan@kernel.org> wrote:
> 
> 
> > Then, I don't think we could keep all of allocations. What we need
> > is only slow allocations. I hope we can do that with ftrace.
> > 
> > ex)
> > 
> > # cd /sys/kernel/debug/tracing
> > # echo 1 > options/stacktrace
> > # echo cam_alloc > set_ftrace_filter
> > # echo your_threshold > tracing_thresh
> > 
> > I know it doesn't work now but I think it's more flexible
> > and general way to handle such issues(ie, latency of some functions).
> > So, I hope we could enhance ftrace rather than new wheel.
> > Ccing ftrace people.
> > 
> 
> I've been working on trace-cmd this month and came up with a new
> "profile" command. I don't have cma_alloc but doing something like this
> with kmalloc.
> 
> 
> # trace-cmd profile -S -p function_graph -l __kmalloc -l '__kmalloc:stacktrace' --stderr workload 2>profile.out
> 
> and this gives me in profile.out, something like this:
> 
> ------
> CPU: 0
> entries: 0
> overrun: 0
> commit overrun: 0
> bytes: 3560
> oldest event ts:   349.925480
> now ts:   356.910819
> dropped events: 0
> read events: 36
> 
> CPU: 1
> entries: 0
> overrun: 0
> commit overrun: 0
> bytes: 408
> oldest event ts:   354.610624
> now ts:   356.910838
> dropped events: 0
> read events: 48
> 
> CPU: 2
> entries: 0
> overrun: 0
> commit overrun: 0
> bytes: 3184
> oldest event ts:   356.761870
> now ts:   356.910854
> dropped events: 0
> read events: 1830
> 
> CPU: 3
> entries: 6
> overrun: 0
> commit overrun: 0
> bytes: 2664
> oldest event ts:   356.440675
> now ts:   356.910875
> dropped events: 0
> read events: 717
> 
> [...]
> 
> task: <...>-2880
>   Event: func: __kmalloc() (74) Total: 53254 Avg: 719 Max: 1095 Min:481
>           | 
>           + ftrace_ops_list_func (0xffffffff810c229e)
>               100% (74) time:53254 max:1095 min:481 avg:719
>                ftrace_call (0xffffffff81526047)
>                trace_preempt_on (0xffffffff810d28ff)
>                preempt_count_sub (0xffffffff81061c62)
>                __mutex_lock_slowpath (0xffffffff81522807)
>                __kmalloc (0xffffffff811323f3)
>                __kmalloc (0xffffffff811323f3)
>                tracing_buffers_splice_read (0xffffffff810ca23e)
>                 | 
>                 + set_next_entity (0xffffffff81067027)
>                 |   66% (49) time:34925 max:1044 min:481 avg:712
>                 |    __switch_to (0xffffffff810016d7)
>                 |    trace_hardirqs_on (0xffffffff810d28db)
>                 |    _raw_spin_unlock_irq (0xffffffff81523a8e)
>                 |    trace_preempt_on (0xffffffff810d28ff)
>                 |    preempt_count_sub (0xffffffff81061c62)
>                 |    __schedule (0xffffffff815204d3)
>                 |    trace_preempt_on (0xffffffff810d28ff)
>                 |    buffer_spd_release (0xffffffff810c91fd)
>                 |    SyS_splice (0xffffffff8115dccf)
>                 |    system_call_fastpath (0xffffffff81523f92)
>                 | 
>                 + do_read_fault.isra.74 (0xffffffff8111431d)
>                 |   24% (18) time:12654 max:1008 min:481 avg:703
>                 |     | 
>                 |     + select_task_rq_fair (0xffffffff81067806)
>                 |     |   89% (16) time:11234 max:1008 min:481 avg:702
>                 |     |    trace_preempt_on (0xffffffff810d28ff)
>                 |     |    buffer_spd_release (0xffffffff810c91fd)
>                 |     |    SyS_splice (0xffffffff8115dccf)
>                 |     |    system_call_fastpath (0xffffffff81523f92)
>                 |     | 
>                 |     + handle_mm_fault (0xffffffff81114df4)
>                 |         11% (2) time:1420 max:879 min:541 avg:710
>                 |          trace_preempt_on (0xffffffff810d28ff)
>                 |          buffer_spd_release (0xffffffff810c91fd)
>                 |          SyS_splice (0xffffffff8115dccf)
>                 |          system_call_fastpath (0xffffffff81523f92)
>                 |       
>                 | 
>                 | 
>                 + update_stats_wait_end (0xffffffff81066c5c)
>                 |   6% (4) time:3153 max:1095 min:635 avg:788
>                 |    set_next_entity (0xffffffff81067027)
>                 |    __switch_to (0xffffffff810016d7)
>                 |    trace_hardirqs_on (0xffffffff810d28db)
>                 |    _raw_spin_unlock_irq (0xffffffff81523a8e)
>                 |    trace_preempt_on (0xffffffff810d28ff)
>                 |    preempt_count_sub (0xffffffff81061c62)
>                 |    __schedule (0xffffffff815204d3)
>                 |    trace_preempt_on (0xffffffff810d28ff)
>                 |    buffer_spd_release (0xffffffff810c91fd)
>                 |    SyS_splice (0xffffffff8115dccf)
>                 |    system_call_fastpath (0xffffffff81523f92)
>                 | 
>                 + _raw_spin_unlock (0xffffffff81523af5)
>                 |   3% (2) time:1854 max:936 min:918 avg:927
>                 |    do_read_fault.isra.74 (0xffffffff8111431d)
>                 |    handle_mm_fault (0xffffffff81114df4)
>                 |    buffer_spd_release (0xffffffff810c91fd)
>                 |    SyS_splice (0xffffffff8115dccf)
>                 |    system_call_fastpath (0xffffffff81523f92)
>                 | 
>                 + trace_hardirqs_off (0xffffffff810d2891)
>                     1% (1) time:668 max:668 min:668 avg:668
>                      kmem_cache_free (0xffffffff81130e48)
>                      __dequeue_signal (0xffffffff8104c802)
>                      trace_preempt_on (0xffffffff810d28ff)
>                      preempt_count_sub (0xffffffff81061c62)
>                      _raw_spin_unlock_irq (0xffffffff81523a8e)
>                      recalc_sigpending (0xffffffff8104c5d1)
>                      __set_task_blocked (0xffffffff8104cd2e)
>                      trace_preempt_on (0xffffffff810d28ff)
>                      preempt_count_sub (0xffffffff81061c62)
>                      preempt_count_sub (0xffffffff81061c62)
>                      buffer_spd_release (0xffffffff810c91fd)
>                      SyS_splice (0xffffffff8115dccf)
>                      system_call_fastpath (0xffffffff81523f92)
>                   

Looks great!

> If you want better names, I would add "-e sched_switch", as that will
> record the comms of the tasks and you don't end up with a bunch of
> "<...>".

Good tip.

> 
> Is this something you are looking for. The profile command does not
> save to disk, thus it does the analysis live, and you don't need to
> worry about running out of disk space. Although, since it is live, it
> may tend to drop more events (see the "overrun values").
> 
> You can get trace-cmd from:
> 
> git://git.kernel.org/pub/scm/linux/kernel/git/rostedt/trace-cmd.git
> 
> You'll need the latest from the master branch, as even 2.5 doesn't have
> the --stderr yet.
> 
> Make sure to do a make install and make install_doc, then you can do:
> 
>  man trace-cmd-record
>  man trace-cmd-profile
> 
> to read about all the options.

Thansk for giving me a chance to use great tool!

> 
> -- Steve
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
