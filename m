Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 8643F6B0032
	for <linux-mm@kvack.org>; Wed, 18 Sep 2013 18:57:50 -0400 (EDT)
Received: by mail-pa0-f42.google.com with SMTP id lj1so8918077pab.29
        for <linux-mm@kvack.org>; Wed, 18 Sep 2013 15:57:50 -0700 (PDT)
Date: Thu, 19 Sep 2013 00:57:20 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: RFC vmstat: On demand vmstat threads
In-Reply-To: <20130918150659.5091a2c3ca94b99304427ec5@linux-foundation.org>
Message-ID: <alpine.DEB.2.02.1309190033440.4089@ionos.tec.linutronix.de>
References: <00000140e9dfd6bd-40db3d4f-c1be-434f-8132-7820f81bb586-000000@email.amazonses.com> <CAOtvUMdfqyg80_9J8AnOaAdahuRYGC-bpemdo_oucDBPguXbVA@mail.gmail.com> <0000014109b8e5db-4b0f577e-c3b4-47fe-b7f2-0e5febbcc948-000000@email.amazonses.com>
 <20130918150659.5091a2c3ca94b99304427ec5@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Gilad Ben-Yossef <gilad@benyossef.com>, Tejun Heo <tj@kernel.org>, John Stultz <johnstul@us.ibm.com>, Mike Frysinger <vapier@gentoo.org>, Minchan Kim <minchan.kim@gmail.com>, Hakan Akkan <hakanakkan@gmail.com>, Max Krasnyansky <maxk@qualcomm.com>, Frederic Weisbecker <fweisbec@gmail.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Linux-MM <linux-mm@kvack.org>

On Wed, 18 Sep 2013, Andrew Morton wrote:
> On Tue, 10 Sep 2013 21:13:34 +0000 Christoph Lameter <cl@linux.com> wrote:
> > +	cpumask_copy(monitored_cpus, cpu_online_mask);
> > +	cpumask_clear_cpu(tick_do_timer_cpu, monitored_cpus);
> 
> What on earth are we using tick_do_timer_cpu for anyway? 
> tick_do_timer_cpu is cheerfully undocumented, as is this code's use of
> it.

tick_do_timer_cpu is a timer core internal variable, which holds the
CPU NR which is responsible for calling do_timer(), i.e. the
timekeeping stuff. This variable has two functions:

1) Prevent a thundering herd issue of a gazillion of CPUs trying to
   grab the timekeeping lock all at once. Only the CPU which is
   assigned to do the update is handling it.

2) Hand off the duty in the NOHZ idle case by setting the value to
   TICK_DO_TIMER_NONE, i.e. a non existing CPU. So the next cpu which
   looks at it will take over and keep the time keeping alive.
   The hand over procedure also covers cpu hotplug.

(Ab)Using it for anything else outside the timers core code is just
broken.

It's working for Christophs use case as his setup will not change the
assignment away from the boot cpu, but that's really not a brilliant
design to start with.

The vmstat accounting is not the only thing which we want to delegate
to dedicated core(s) for the full NOHZ mode.

So instead of playing broken games with explicitly not exposed core
code variables, we should implement a core code facility which is
aware of the NOHZ details and provides a sane way to delegate stuff to
a certain subset of CPUs.

Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
