Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f171.google.com (mail-ie0-f171.google.com [209.85.223.171])
	by kanga.kvack.org (Postfix) with ESMTP id 4ADF56B0038
	for <linux-mm@kvack.org>; Fri,  9 Jan 2015 09:35:35 -0500 (EST)
Received: by mail-ie0-f171.google.com with SMTP id ar1so15248039iec.2
        for <linux-mm@kvack.org>; Fri, 09 Jan 2015 06:35:35 -0800 (PST)
Received: from smtprelay.hostedemail.com (smtprelay0161.hostedemail.com. [216.40.44.161])
        by mx.google.com with ESMTP id g4si15174904igh.45.2015.01.09.06.35.33
        for <linux-mm@kvack.org>;
        Fri, 09 Jan 2015 06:35:34 -0800 (PST)
Date: Fri, 9 Jan 2015 09:35:30 -0500
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH 0/3] mm: cma: /proc/cmainfo
Message-ID: <20150109093530.655c845e@gandalf.local.home>
In-Reply-To: <20150109091904.41294966@gandalf.local.home>
References: <cover.1419602920.git.s.strogin@partner.samsung.com>
	<20141229023639.GC27095@bbox>
	<54A1B11A.6020307@codeaurora.org>
	<20141230044726.GA22342@bbox>
	<20150109091904.41294966@gandalf.local.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Laura Abbott <lauraa@codeaurora.org>, "Stefan I. Strogin" <s.strogin@partner.samsung.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, aneesh.kumar@linux.vnet.ibm.com, Laurent Pinchart <laurent.pinchart@ideasonboard.com>, Dmitry Safonov <d.safonov@partner.samsung.com>, Pintu Kumar <pintu.k@samsung.com>, Weijie Yang <weijie.yang@samsung.com>, SeongJae Park <sj38.park@gmail.com>, Hui Zhu <zhuhui@xiaomi.com>, Dyasly Sergey <s.dyasly@samsung.com>, Vyacheslav Tyrtov <v.tyrtov@samsung.com>, namhyung@kernel.org

On Fri, 9 Jan 2015 09:19:04 -0500
Steven Rostedt <rostedt@goodmis.org> wrote:

> task: <...>-2880
>   Event: func: __kmalloc() (74) Total: 53254 Avg: 719 Max: 1095 Min:481

I forgot to mention that all times are in nanoseconds (or whatever the
trace clock is set at).

>           | 
>           + ftrace_ops_list_func (0xffffffff810c229e)
>               100% (74) time:53254 max:1095 min:481 avg:719
>                ftrace_call (0xffffffff81526047)
>                trace_preempt_on (0xffffffff810d28ff)
>                preempt_count_sub (0xffffffff81061c62)
>                __mutex_lock_slowpath (0xffffffff81522807)
>                __kmalloc (0xffffffff811323f3)
>                __kmalloc (0xffffffff811323f3)

The above may be a bit confusing, as the stack trace included more than
it should have (it's variable and hard to get right).
ftrace_ops_list_func() did not call kmalloc, but it did call the
stack trace and was included. You want to look below to find the
interesting data.

This is still a new feature, and is using some of the kernel tracing
more than it has been in the past. There's still a few eggs that need
to be boiled here.


>                tracing_buffers_splice_read (0xffffffff810ca23e)

All the kmallocs for this task was called by
tracing_buffers_splice_read() (hmm, I chose to show you the trace-cmd
profile on itself. If I had included "-F -c" (follow workload only)  or
-e sched_switch I would have known which task to look at).

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

I'm not sure how much I trust this. I don't have FRAME_POINTERS
enabled, so the stack traces may not be as accurate.

But you get the idea, and this can show you where the slow paths lie.

-- Steve


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

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
