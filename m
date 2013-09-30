Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 1337F6B0031
	for <linux-mm@kvack.org>; Mon, 30 Sep 2013 16:00:23 -0400 (EDT)
Received: by mail-pa0-f47.google.com with SMTP id kp14so6293510pab.20
        for <linux-mm@kvack.org>; Mon, 30 Sep 2013 13:00:22 -0700 (PDT)
From: "Rafael J. Wysocki" <rjw@rjwysocki.net>
Subject: Re: [PATCH] hotplug: Optimize {get,put}_online_cpus()
Date: Mon, 30 Sep 2013 22:11:47 +0200
Message-ID: <7632387.20FXkuCITr@vostro.rjw.lan>
In-Reply-To: <20130928163104.GA23352@redhat.com>
References: <20130925175055.GA25914@redhat.com> <20130928144720.GL15690@laptop.programming.kicks-ass.net> <20130928163104.GA23352@redhat.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="utf-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>, "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Cc: Peter Zijlstra <peterz@infradead.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Steven Rostedt <rostedt@goodmis.org>, Viresh Kumar <viresh.kumar@linaro.org>

On Saturday, September 28, 2013 06:31:04 PM Oleg Nesterov wrote:
> On 09/28, Peter Zijlstra wrote:
> >
> > On Sat, Sep 28, 2013 at 02:48:59PM +0200, Oleg Nesterov wrote:
> >
> > > Please note that this wait_event() adds a problem... it doesn't allow
> > > to "offload" the final synchronize_sched(). Suppose a 4k cpu machine
> > > does disable_nonboot_cpus(), we do not want 2 * 4k * synchronize_sched's
> > > in this case. We can solve this, but this wait_event() complicates
> > > the problem.
> >
> > That seems like a particularly easy fix; something like so?
> 
> Yes, but...
> 
> > @@ -586,6 +603,11 @@ int disable_nonboot_cpus(void)
> >
> > +	cpu_hotplug_done();
> > +
> > +	for_each_cpu(cpu, frozen_cpus)
> > +		cpu_notify_nofail(CPU_POST_DEAD_FROZEN, (void*)(long)cpu);
> 
> This changes the protocol, I simply do not know if it is fine in general
> to do __cpu_down(another_cpu) without CPU_POST_DEAD(previous_cpu). Say,
> currently it is possible that CPU_DOWN_PREPARE takes some global lock
> released by CPU_DOWN_FAILED or CPU_POST_DEAD.
> 
> Hmm. Now that workqueues do not use CPU_POST_DEAD, it has only 2 users,
> mce_cpu_callback() and cpufreq_cpu_callback() and the 1st one even ignores
> this notification if FROZEN. So yes, probably this is fine, but needs an
> ack from cpufreq maintainers (cc'ed), for example to ensure that it is
> fine to call __cpufreq_remove_dev_prepare() twice without _finish().

To my eyes it will return -EBUSY when it tries to stop an already stopped
governor, which will cause the entire chain to fail I guess.

Srivatsa has touched that code most recently, so he should know better, though.

Thanks,
Rafael

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
