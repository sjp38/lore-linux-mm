Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id AA8896B0032
	for <linux-mm@kvack.org>; Thu,  8 Aug 2013 02:54:15 -0400 (EDT)
Received: by mail-la0-f45.google.com with SMTP id fj20so1845603lab.32
        for <linux-mm@kvack.org>; Wed, 07 Aug 2013 23:54:13 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <0000013f61e7609b-a8d1907b-8169-4f77-ab83-a624a8d0ab4a-000000@email.amazonses.com>
References: <CAOtvUMc5w3zNe8ed6qX0OOM__3F_hOTqvFa1AkdXF0PHvzGZqg@mail.gmail.com>
	<1371672168-9869-1-git-send-email-gilad@benyossef.com>
	<0000013f61e7609b-a8d1907b-8169-4f77-ab83-a624a8d0ab4a-000000@email.amazonses.com>
Date: Thu, 8 Aug 2013 09:54:13 +0300
Message-ID: <CAOtvUMe=QQni4Ouu=P_vh8QSb4ZdnaX_fW1twn3QFcOjYgJBGA@mail.gmail.com>
Subject: Re: [PATCH v2 1/2] mm: make vmstat_update periodic run conditional
From: Gilad Ben-Yossef <gilad@benyossef.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Frederic Weisbecker <fweisbec@gmail.com>

On Thu, Jun 20, 2013 at 5:05 PM, Christoph Lameter <cl@linux.com> wrote:
>
> On Wed, 19 Jun 2013, Gilad Ben-Yossef wrote:
>
> > +static void vmstat_update(struct work_struct *w)
> > +{
> > +     int cpu, this_cpu = smp_processor_id();
> > +
> > +     if (unlikely(this_cpu == vmstat_monitor_cpu))
> > +             for_each_cpu_not(cpu, &vmstat_cpus)
> > +                     if (need_vmstat(cpu))
> > +                             start_cpu_timer(cpu);
> > +
> > +     if (likely(refresh_cpu_vm_stats(this_cpu) || (this_cpu ==
> > vmstat_monitor_cpu)))
> > +             schedule_delayed_work(&__get_cpu_var(vmstat_work),
> > +
> > round_jiffies_relative(sysctl_stat_interval));
> > +     else
> > +             cpumask_clear_cpu(this_cpu, &vmstat_cpus);
>
> The clearing of vmstat_cpus could be avoided if this processor is not
> running tickless. Frequent updates to vmstat_cpus could become an issue.

I like the idea of tying the vmstat disabling to the tickless logic
but I seem to have run
into a bit of a chicken and egg problem here:

vmstat_update runs from the vmstat work queue item by the workqueue
kernel thread.

If this code is running, it means there are at least two schedulable tasks:
1. The workqueue kernel thread, because it is running.
2. At least one more task, otherwise were were in idle and the
workqueue kernel thread
would not execute this work item.

Unfortunately, having two schedulable tasks means we're not running
tickless, so the check
will never trigger - or have I've missed something obvious?

Thanks,
Gilad


--
Gilad Ben-Yossef
Chief Coffee Drinker
gilad@benyossef.com
Israel Cell: +972-52-8260388
US Cell: +1-973-8260388
http://benyossef.com

"If you take a class in large-scale robotics, can you end up in a situation
where the homework eats your dog?"
 -- Jean-Baptiste Queru

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
