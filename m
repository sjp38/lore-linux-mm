Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 8BAE96B0012
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 18:27:33 -0400 (EDT)
Received: from d01relay06.pok.ibm.com (d01relay06.pok.ibm.com [9.56.227.116])
	by e7.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p3RM54eW020181
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 18:05:04 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay06.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p3RMRVTk1278146
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 18:27:31 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p3RMRUDA001247
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 18:27:31 -0400
Date: Wed, 27 Apr 2011 15:27:27 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: 2.6.39-rc4+: Kernel leaking memory during FS scanning,
 regression?
Message-ID: <20110427222727.GU2135@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <20110425214933.GO2468@linux.vnet.ibm.com>
 <20110426081904.0d2b1494@pluto.restena.lu>
 <20110426112756.GF4308@linux.vnet.ibm.com>
 <20110426183859.6ff6279b@neptune.home>
 <20110426190918.01660ccf@neptune.home>
 <BANLkTikjuqWP+PAsObJH4EAOyzgr2RbYNA@mail.gmail.com>
 <alpine.LFD.2.02.1104262314110.3323@ionos>
 <20110427081501.5ba28155@pluto.restena.lu>
 <20110427204139.1b0ea23b@neptune.home>
 <alpine.LFD.2.02.1104272351290.3323@ionos>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <alpine.LFD.2.02.1104272351290.3323@ionos>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: Bruno =?iso-8859-1?Q?Pr=E9mont?= <bonbons@linux-vserver.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mike Frysinger <vapier.adi@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "Paul E. McKenney" <paul.mckenney@linaro.org>, Pekka Enberg <penberg@kernel.org>

On Thu, Apr 28, 2011 at 12:06:11AM +0200, Thomas Gleixner wrote:
> On Wed, 27 Apr 2011, Bruno Premont wrote:
> > On Wed, 27 April 2011 Bruno Premont wrote:
> > Voluntary context switches stay constant from the time on SLABs pile up.
> > (which makes sense as it doesn't run get CPU slices anymore)
> > 
> > > > Can you please enable CONFIG_SCHED_DEBUG and provide the output of
> > > > /proc/sched_stat when the problem surfaces and a minute after the
> > > > first snapshot?
> > 
> > hm, did you mean CONFIG_SCHEDSTAT or /proc/sched_debug?
> > 
> > I did use CONFIG_SCHED_DEBUG (and there is no /proc/sched_stat) so I took
> > /proc/sched_debug which exists... (attached, taken about 7min and +1min
> > after SLABs started piling up), though build processes were SIGSTOPped
> > during first minute.
> 
> Oops. /proc/sched_debug is the right thing.
> 
> > printk wrote (in case its timestamp is useful, more below):
> > [  518.480103] sched: RT throttling activated
> 
> Ok. Aside of the fact that the CPU time accounting is completely hosed
> this is pointing to the root cause of the problem.
> 
> kthread_rcu seems to run in circles for whatever reason and the RT
> throttler catches it. After that things go down the drain completely
> as it should get on the CPU again after that 50ms throttling break.

Ah.  This could happen if there was a huge number of callbacks, in
which case blimit would be set very large and kthread_rcu could then
go CPU-bound.  And this workload was generating large numbers of
callbacks due to filesystem operations, right?

So, perhaps I should kick kthread_rcu back to SCHED_NORMAL if blimit
has been set high.  Or have some throttling of my own.  I must confess
that throttling kthread_rcu for two hours seems a bit harsh.  ;-)

If this was just throttling kthread_rcu for a few hundred milliseconds,
or even for a second or two, things would be just fine.

Left to myself, I will put together a patch that puts callback processing
down to SCHED_NORMAL in the case where there are huge numbers of
callbacks to be processed.

> Though we should not ignore the fact, that the RT throttler hit, but
> none of the RT tasks actually accumulated runtime.
> 
> So there is a couple of questions:
> 
>    - Why does the scheduler detect the 950 ms RT runtime, but does
>      not accumulate that runtime to any thread
> 
>    - Why is the runtime accounting totally hosed
> 
>    - Why does that not happen (at least not reproducible) with 
>      TREE_RCU

This one I can answer -- In Linus's tree, TREE_RCU still uses softirq,
so there is no RCU kthread, so there is nothing to throttle other
than ksoftirqd itself.

							Thanx, Paul

> I need some sleep now, but I will try to come up with sensible
> debugging tomorrow unless Paul or someone else beats me to it.
> 
> Thanks,
> 
> 	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
