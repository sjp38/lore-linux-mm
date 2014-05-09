Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f54.google.com (mail-qa0-f54.google.com [209.85.216.54])
	by kanga.kvack.org (Postfix) with ESMTP id 272EA6B0037
	for <linux-mm@kvack.org>; Fri,  9 May 2014 10:53:50 -0400 (EDT)
Received: by mail-qa0-f54.google.com with SMTP id j15so4211447qaq.13
        for <linux-mm@kvack.org>; Fri, 09 May 2014 07:53:49 -0700 (PDT)
Received: from qmta03.emeryville.ca.mail.comcast.net (qmta03.emeryville.ca.mail.comcast.net. [2001:558:fe2d:43:76:96:30:32])
        by mx.google.com with ESMTP id e4si2142520qcc.65.2014.05.09.07.53.49
        for <linux-mm@kvack.org>;
        Fri, 09 May 2014 07:53:49 -0700 (PDT)
Date: Fri, 9 May 2014 09:53:45 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: vmstat: On demand vmstat workers V4
In-Reply-To: <alpine.DEB.2.02.1405090003120.6261@ionos.tec.linutronix.de>
Message-ID: <alpine.DEB.2.10.1405090949170.11318@gentwo.org>
References: <alpine.DEB.2.10.1405081033090.23786@gentwo.org> <20140508142903.c2ef166c95d2b8acd0d7ea7d@linux-foundation.org> <alpine.DEB.2.02.1405090003120.6261@ionos.tec.linutronix.de>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Gilad Ben-Yossef <gilad@benyossef.com>, Tejun Heo <tj@kernel.org>, John Stultz <johnstul@us.ibm.com>, Mike Frysinger <vapier@gentoo.org>, Minchan Kim <minchan.kim@gmail.com>, Hakan Akkan <hakanakkan@gmail.com>, Max Krasnyansky <maxk@qualcomm.com>, Frederic Weisbecker <fweisbec@gmail.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, hughd@google.com, viresh.kumar@linaro.org

On Fri, 9 May 2014, Thomas Gleixner wrote:

> > > +/*
> > > + * Return a cpu number that may be used to run housekeeping
> > > + * tasks. This is usually the timekeeping cpu unless that
> > > + * is not available. Then we simply fall back to the current
> > > + * cpu.
> > > + */
> >
> > This comment is unusably vague.  What the heck is a "housekeeping
> > task"?  Why would anyone call this and what is special about the CPU
> > number it returns?

I just need a processor that keeps watch over the vmstat workers in the
system. The processor that does timekeeping is an obvious choice. I am
open to other suggestions.

Typically our system have processors that are used for OS processing and
processor that are focused on app services. Those need to be as
undisturbed as possible.

 > >
> >
> > > +int tick_get_housekeeping_cpu(void)
> > > +{
> > > +	int cpu;
> > > +
> > > +	if (system_state < SYSTEM_RUNNING || tick_do_timer_cpu < 0)
> > > +		cpu = raw_smp_processor_id();
>
> That's completely bogus. The system state check is pointless and
> tick_do_timer_cpu even more so because if you call that code from a
> worker thread tick_do_timer_cpu should be assigned to some cpu.
>
> Aside of that I'm having a hard time to understand why this stuff
> wants to move around at all.
>
> I think we agreed long ago, that for the whole HPC FULL_NOHZ stuff you
> have to sacrify at least one CPU for housekeeping purposes of all
> kinds, timekeeping, statistics and whatever.

Ok how do I figure out that cpu? I'd rather have a specific cpu that
never changes.

> So if you have a housekeeper, then it makes absolutely no sense at all
> to move it around in circles.
>
> Can you please enlighten me why we need this at all?

The vmstat kworker thread checks every 2 seconds if there are vmstat
updates that need to be folded into the global statistics. This is not
necessary if the application is running and no OS services are being used.
Thus we could switch off vmstat updates and avoid taking the processor
away from the application.

This has also been noted by multiple other people at was brought up at the
mm summit by others who noted the same issues.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
