Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 48D106B0003
	for <linux-mm@kvack.org>; Wed, 13 Jun 2018 17:46:54 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id x14-v6so2499697wrr.17
        for <linux-mm@kvack.org>; Wed, 13 Jun 2018 14:46:54 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id i23-v6si3244556wra.179.2018.06.13.14.46.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Wed, 13 Jun 2018 14:46:52 -0700 (PDT)
Date: Wed, 13 Jun 2018 23:46:45 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH REPOST] Revert mm/vmstat.c: fix vmstat_update() preemption
 BUG
In-Reply-To: <524ecef9-e513-fec4-1178-ac1a87452e57@suse.cz>
Message-ID: <alpine.DEB.2.21.1806132205420.1596@nanos.tec.linutronix.de>
References: <20180504104451.20278-1-bigeasy@linutronix.de> <513014a0-a149-5141-a5a0-9b0a4ce9a8d8@suse.cz> <20180508160257.6e19707ccf1dabe5ec9e8847@linux-foundation.org> <20180509223539.43aznhri72ephluc@linutronix.de>
 <524ecef9-e513-fec4-1178-ac1a87452e57@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Sebastian Andrzej Siewior <bigeasy@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, "Steven J . Hill" <steven.hill@cavium.com>, Tejun Heo <htejun@gmail.com>, Christoph Lameter <cl@linux.com>, Peter Zijlstra <peterz@infradead.org>

On Thu, 10 May 2018, Vlastimil Babka wrote:
> On 05/10/2018 12:35 AM, Sebastian Andrzej Siewior wrote:
> >> The only thing this buys us is that people will hassle us if we forget
> >> to fix the bug, and how pathetic is that?  I mean, we may as well put
> >>
> >> 	printk("don't forget to fix the vmstat_update() bug!\n");
> > 
> > No that is different. That would be seen by everyone. The bug was only
> > reported by Steven J. Hill which did not respond since. This message
> > would also imply that we know how to fix the bug but didn't do it yet
> > which is not the case. We seen that something was wrong but have no idea
> > *how* it got there.
> > 
> > The preempt_disable() was added by the end of v4.16. The
> > smp_processor_id() in vmstat_update() was added in commit 7cc36bbddde5
> > ("vmstat: on-demand vmstat workers V8") which was in v3.18-rc1. The
> > hotplug rework took place in v4.10-rc1. And it took (counting from the
> > hotplug rework) 6 kernel releases for someone to trigger that warning
> > _if_ this was related to the hotplug rework.
> > 
> > What we have *now* is way worse: We have a possible bug that triggered
> > the warning. As we see in report the code in question was _already_
> > invoked on the wrong CPU. The preempt_disable() just silences the
> > warning, hiding the real issue so nobody will do a thing about it since
> > it will be never reported again (in a kernel with preemption and debug
> > enabled).
> 
> Fully agree with everything you said!
> 
> We could extend the warning to e.g. print affinity mask of the thread,
> and e.g. state of cpus that are subject to ongoing hotplug/hotremove.
> But maybe it's not so useful in general, as the common case is likely
> indeed a missing preempt_disable, and this is an exception? In any case,
> I would hope that Steven applies some patch locally and we get more
> details about what's going on at that MIPS machine.

So after this went completely silent and S.J. Hill seems to be lost in the
intertubes, I spent quite some time staring at that code and the commit
in question:

    "Attempting to hotplug CPUs with CONFIG_VM_EVENT_COUNTERS enabled can
     cause vmstat_update() to report a BUG due to preemption not being
     disabled around smp_processor_id()."

That changelog is pretty much useless as it just decscribes the symptom and
the 'fix' follows suit by papering over that symptom.

Plus it's even more obscure that only the queue_delayed_work_on() bit needs
to be fixed because vmstat_update() does:

        if (refresh_cpu_vm_stats(true))
	      queue_delayed_work_on(smp_processor_id() ....);

and refresh_cpu_vm_stats() is full of this_cpu_* accesses which all are
equipped with __this_cpu_preempt_check() calls which depend on
CONFIG_DEBUG_PREEMPT as well.

So how does only the queue_delayed_work_on(smp_processor_id()) part
trigger? That does not make any sense at all.

Can we please revert that master piece of duct tape engineering and wait
for someone to actually trigger the warning again? All we can hope it's
someone who really sits down and does a proper analysis of the problem
instead of throwing some half baken 'works for me' crap over the fence and
then running as fast as it goes.

As I was at it I stared at the hotplug code some more.

vmstat_update() is a delayed work function which is scheduled on a
particular per CPU mm_percpu_wq. In case of CPU hotplug the work (and the
timer) is canceled _before_ the per CPU workqueues are unbound. It cannot
be requeued because vmstat_shepherd() on some other CPU would be stuck in
get_online_cpus() and by the time it's unstuck the CPU is gone from the
online cpumask.

So this looks all about correct, but there is a very subtle case where the
above has a hole. That requires to execute the hotplug state control and
not the full /sys/..../cpu$N/online mechanism, e.g. by doing:

# echo $PERF_ONLINE_STATE > /sys/devices/system/cpu/cpu1/hotplug/target

CPU0					CPU1		

do_cpu_down(1, CPUHP_AP_PERF_ONLINE)
 write_lock_cpus()
 __cpu_down(1, CPUHP_AP_PERF_ONLINE)
  kick_cpu(1);
  wait_for_completion(); 		while (state > CPUHP_AP_PERF_ONLINE)
					   invoke_shutdown_callback(state--);

					 That invokes:

					     vmstat_cpu_offline();
					       cancel_delayed_work();
					     
					     ...
					     					     
					     workqueue_offline_cpu()
					       unbind_workers();
					     ...
					
					complete();
 write_unlock_cpus();

Note, after this returns, CPU1 is still in the online mask. So the next
invocation of vmstat_sheperd() can queue the work on CPU1 again.

If that happens then the work will run on an unbound work queue somewhere
if I'm not completely misreading the workqueue code. Tejun ???

I'll try that tomorrow if nobody beats me to it, but that's the only way I
found how the debug warning can trigger. That does not explain why it
triggers only the smp_processor_id() thing and not the this_cpu_* check,
but I don't trust that information in the changelog at all.

Thanks,

	tglx
