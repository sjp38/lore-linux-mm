Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f54.google.com (mail-yh0-f54.google.com [209.85.213.54])
	by kanga.kvack.org (Postfix) with ESMTP id C96386B0036
	for <linux-mm@kvack.org>; Sat, 10 May 2014 21:12:41 -0400 (EDT)
Received: by mail-yh0-f54.google.com with SMTP id i57so5132043yha.13
        for <linux-mm@kvack.org>; Sat, 10 May 2014 18:12:41 -0700 (PDT)
Received: from e36.co.us.ibm.com (e36.co.us.ibm.com. [32.97.110.154])
        by mx.google.com with ESMTPS id e69si10759254yhk.127.2014.05.10.18.12.40
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sat, 10 May 2014 18:12:41 -0700 (PDT)
Received: from /spool/local
	by e36.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Sat, 10 May 2014 19:12:40 -0600
Received: from b03cxnp07029.gho.boulder.ibm.com (b03cxnp07029.gho.boulder.ibm.com [9.17.130.16])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id D3BC81FF0028
	for <linux-mm@kvack.org>; Sat, 10 May 2014 19:12:37 -0600 (MDT)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by b03cxnp07029.gho.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s4AN9PAx57540840
	for <linux-mm@kvack.org>; Sun, 11 May 2014 01:09:25 +0200
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id s4B1GSMh007472
	for <linux-mm@kvack.org>; Sat, 10 May 2014 19:16:29 -0600
Date: Sat, 10 May 2014 18:12:34 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: vmstat: On demand vmstat workers V4
Message-ID: <20140511011234.GC4827@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <alpine.DEB.2.10.1405081033090.23786@gentwo.org>
 <20140508142903.c2ef166c95d2b8acd0d7ea7d@linux-foundation.org>
 <alpine.DEB.2.02.1405090003120.6261@ionos.tec.linutronix.de>
 <alpine.DEB.2.10.1405090949170.11318@gentwo.org>
 <alpine.DEB.2.02.1405091659350.6261@ionos.tec.linutronix.de>
 <alpine.DEB.2.10.1405091027040.11318@gentwo.org>
 <alpine.DEB.2.02.1405092358390.6261@ionos.tec.linutronix.de>
 <20140509234745.GB8754@linux.vnet.ibm.com>
 <alpine.DEB.2.02.1405101407290.6261@ionos.tec.linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1405101407290.6261@ionos.tec.linutronix.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Gilad Ben-Yossef <gilad@benyossef.com>, Tejun Heo <tj@kernel.org>, Mike Frysinger <vapier@gentoo.org>, Minchan Kim <minchan.kim@gmail.com>, Hakan Akkan <hakanakkan@gmail.com>, Max Krasnyansky <maxk@qualcomm.com>, Frederic Weisbecker <fweisbec@gmail.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, hughd@google.com, viresh.kumar@linaro.org, Ingo Molnar <mingo@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, John Stultz <john.stultz@linaro.org>

On Sat, May 10, 2014 at 02:20:36PM +0200, Thomas Gleixner wrote:
> On Fri, 9 May 2014, Paul E. McKenney wrote:
> 
> > On Sat, May 10, 2014 at 12:57:15AM +0200, Thomas Gleixner wrote:
> > > On Fri, 9 May 2014, Christoph Lameter wrote:
> > > > On Fri, 9 May 2014, Thomas Gleixner wrote:
> > > > > I understand why you want to get this done by a housekeeper, I just
> > > > > did not understand why we need this whole move it around business is
> > > > > required.
> > > > 
> > > > This came about because of another objection against having it simply
> > > > fixed to a processor. After all that processor may be disabled etc etc.
> > > 
> > > I really regret that I did not pay more attention (though my cycle
> > > constraints simply do not allow it).
> > 
> > As far as I can see, the NO_HZ_FULL timekeeping CPU is always zero.  If it
> > can change in NO_HZ_FULL kernels, RCU will do some very strange things!
> 
> Good. I seriously hope it stays that way.

Unless and until systems end up with so many CPUs that a single CPU
cannot keep up with all the housekeeping tasks.  But we should wait to
burn that bridge until after we drive off it.  ;-)

> > One possible issue here is that Christoph's patch is unconditional.
> > It takes effect for both NO_HZ_FULL and !NO_HZ_FULL.  If I recall
> > correctly, the timekeeping CPU -can- change in !NO_HZ_FULL kernels,
> > which might be what Christoph was trying to take into account.
> 
> Ok. Sorry, I was just in a lousy mood after wasting half a day in
> reviewing even lousier patches related to that NO_HZ* muck.

I can relate...

> So, right with NO_HZ_IDLE the time keeper can move around and
> housekeeping stuff might want to move around as well.
> 
> But it's not necessary a good idea to bundle that with the timekeeper,
> as under certain conditions the timekeeper duty can move around fast
> and left unassigned again when the system is fully idle.
> 
> And we really do not want a gazillion of sites which implement a
> metric ton of different ways to connect some random housekeeping jobs
> with the timekeeper.
> 
> So the proper solution to this is to have either a thread or a
> dedicated housekeeping worker, which is placed by the scheduler
> depending on the system configuration and workload.
> 
> That way it can be kept at cpu0 for the nohz=off and the nohz_full
> case. In the nohz_idle case we can have different placement
> algorithms. On a big/little ARM machine you probably want to keep it
> on the first cpu of one or the other cluster. And there might be other
> constraints on servers.
> 
> So we are way better of with a generic facility, where the various
> housekeeping jobs can be queued.
> 
> Does that make sense?

It might well.

Here is what I currently do for RCU:

1.	If !NO_HZ_FULL, I let the grace-period kthreads run wherever
	the scheduler wants them to.

2.	If NO_HZ_FULL, I bind the grace-period kthreads to the
	timekeeping CPU.

But if I could just mark it as a housekeeping kthread and have something
take care of it.

So let's see...

Your nohz=off case recognizes a real-time setup, correct?  In which
case it does make sense to get the housekeeping out of the way of the
worker CPUs.  I would look pretty silly arguing against the nohz_full
case, since that is what RCU does.  Right now I just pay attention to
the Kconfig parameter, but perhaps it would make sense to also look at
the boot parameters.  Especially since some distros seem to be setting
NO_HZ_FULL by default.  ;-)

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
