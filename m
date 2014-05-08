Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f45.google.com (mail-ee0-f45.google.com [74.125.83.45])
	by kanga.kvack.org (Postfix) with ESMTP id E7E896B0123
	for <linux-mm@kvack.org>; Thu,  8 May 2014 18:18:33 -0400 (EDT)
Received: by mail-ee0-f45.google.com with SMTP id d49so2070269eek.18
        for <linux-mm@kvack.org>; Thu, 08 May 2014 15:18:33 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2001:470:1f0b:db:abcd:42:0:1])
        by mx.google.com with ESMTPS id d5si2593622eei.118.2014.05.08.15.18.31
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Thu, 08 May 2014 15:18:32 -0700 (PDT)
Date: Fri, 9 May 2014 00:18:30 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: vmstat: On demand vmstat workers V4
In-Reply-To: <20140508142903.c2ef166c95d2b8acd0d7ea7d@linux-foundation.org>
Message-ID: <alpine.DEB.2.02.1405090003120.6261@ionos.tec.linutronix.de>
References: <alpine.DEB.2.10.1405081033090.23786@gentwo.org> <20140508142903.c2ef166c95d2b8acd0d7ea7d@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Gilad Ben-Yossef <gilad@benyossef.com>, Tejun Heo <tj@kernel.org>, John Stultz <johnstul@us.ibm.com>, Mike Frysinger <vapier@gentoo.org>, Minchan Kim <minchan.kim@gmail.com>, Hakan Akkan <hakanakkan@gmail.com>, Max Krasnyansky <maxk@qualcomm.com>, Frederic Weisbecker <fweisbec@gmail.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, hughd@google.com, viresh.kumar@linaro.org

On Thu, 8 May 2014, Andrew Morton wrote:
> On Thu, 8 May 2014 10:35:15 -0500 (CDT) Christoph Lameter <cl@linux.com> wrote:
> > --- linux.orig/kernel/time/tick-common.c	2014-05-06 10:51:19.711239813 -0500
> > +++ linux/kernel/time/tick-common.c	2014-05-06 10:51:19.711239813 -0500
> > @@ -222,6 +222,24 @@
> >  		tick_setup_oneshot(newdev, handler, next_event);
> >  }
> > 
> > +/*
> > + * Return a cpu number that may be used to run housekeeping
> > + * tasks. This is usually the timekeeping cpu unless that
> > + * is not available. Then we simply fall back to the current
> > + * cpu.
> > + */
> 
> This comment is unusably vague.  What the heck is a "housekeeping
> task"?  Why would anyone call this and what is special about the CPU
> number it returns?
> 
> 
> > +int tick_get_housekeeping_cpu(void)
> > +{
> > +	int cpu;
> > +
> > +	if (system_state < SYSTEM_RUNNING || tick_do_timer_cpu < 0)
> > +		cpu = raw_smp_processor_id();

That's completely bogus. The system state check is pointless and
tick_do_timer_cpu even more so because if you call that code from a
worker thread tick_do_timer_cpu should be assigned to some cpu.

Aside of that I'm having a hard time to understand why this stuff
wants to move around at all.

I think we agreed long ago, that for the whole HPC FULL_NOHZ stuff you
have to sacrify at least one CPU for housekeeping purposes of all
kinds, timekeeping, statistics and whatever.

So if you have a housekeeper, then it makes absolutely no sense at all
to move it around in circles.

Can you please enlighten me why we need this at all?

Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
