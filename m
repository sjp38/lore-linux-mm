Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 317276B0011
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 18:33:26 -0400 (EDT)
Date: Thu, 28 Apr 2011 00:32:50 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: 2.6.39-rc4+: Kernel leaking memory during FS scanning,
 regression?
In-Reply-To: <20110427222727.GU2135@linux.vnet.ibm.com>
Message-ID: <alpine.LFD.2.02.1104280028250.3323@ionos>
References: <20110425214933.GO2468@linux.vnet.ibm.com> <20110426081904.0d2b1494@pluto.restena.lu> <20110426112756.GF4308@linux.vnet.ibm.com> <20110426183859.6ff6279b@neptune.home> <20110426190918.01660ccf@neptune.home> <BANLkTikjuqWP+PAsObJH4EAOyzgr2RbYNA@mail.gmail.com>
 <alpine.LFD.2.02.1104262314110.3323@ionos> <20110427081501.5ba28155@pluto.restena.lu> <20110427204139.1b0ea23b@neptune.home> <alpine.LFD.2.02.1104272351290.3323@ionos> <20110427222727.GU2135@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323328-555990961-1303943571=:3323"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: =?ISO-8859-15?Q?Bruno_Pr=E9mont?= <bonbons@linux-vserver.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mike Frysinger <vapier.adi@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "Paul E. McKenney" <paul.mckenney@linaro.org>, Pekka Enberg <penberg@kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323328-555990961-1303943571=:3323
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT



On Wed, 27 Apr 2011, Paul E. McKenney wrote:

> On Thu, Apr 28, 2011 at 12:06:11AM +0200, Thomas Gleixner wrote:
> > On Wed, 27 Apr 2011, Bruno Premont wrote:
> > > On Wed, 27 April 2011 Bruno Premont wrote:
> > > Voluntary context switches stay constant from the time on SLABs pile up.
> > > (which makes sense as it doesn't run get CPU slices anymore)
> > > 
> > > > > Can you please enable CONFIG_SCHED_DEBUG and provide the output of
> > > > > /proc/sched_stat when the problem surfaces and a minute after the
> > > > > first snapshot?
> > > 
> > > hm, did you mean CONFIG_SCHEDSTAT or /proc/sched_debug?
> > > 
> > > I did use CONFIG_SCHED_DEBUG (and there is no /proc/sched_stat) so I took
> > > /proc/sched_debug which exists... (attached, taken about 7min and +1min
> > > after SLABs started piling up), though build processes were SIGSTOPped
> > > during first minute.
> > 
> > Oops. /proc/sched_debug is the right thing.
> > 
> > > printk wrote (in case its timestamp is useful, more below):
> > > [  518.480103] sched: RT throttling activated
> > 
> > Ok. Aside of the fact that the CPU time accounting is completely hosed
> > this is pointing to the root cause of the problem.
> > 
> > kthread_rcu seems to run in circles for whatever reason and the RT
> > throttler catches it. After that things go down the drain completely
> > as it should get on the CPU again after that 50ms throttling break.
> 
> Ah.  This could happen if there was a huge number of callbacks, in
> which case blimit would be set very large and kthread_rcu could then
> go CPU-bound.  And this workload was generating large numbers of
> callbacks due to filesystem operations, right?
> 
> So, perhaps I should kick kthread_rcu back to SCHED_NORMAL if blimit
> has been set high.  Or have some throttling of my own.  I must confess
> that throttling kthread_rcu for two hours seems a bit harsh.  ;-)

That's not the intended thing. See below.
 
> If this was just throttling kthread_rcu for a few hundred milliseconds,
> or even for a second or two, things would be just fine.
> 
> Left to myself, I will put together a patch that puts callback processing
> down to SCHED_NORMAL in the case where there are huge numbers of
> callbacks to be processed.

Well that's going to paper over the problem at hand possibly. I really
don't see why that thing would run for more than 950ms in a row even
if there is a large number of callbacks pending.

And then I don't have an explanation for the hosed CPU accounting and
why that thing does not get another 950ms RT time when the 50ms
throttling break is over.

Thanks,

	tglx
--8323328-555990961-1303943571=:3323--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
