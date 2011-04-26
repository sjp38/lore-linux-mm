Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 455D99000C1
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 14:50:48 -0400 (EDT)
Received: from d01relay01.pok.ibm.com (d01relay01.pok.ibm.com [9.56.227.233])
	by e4.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p3QIUJoh003673
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 14:30:19 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p3QIoeMc039530
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 14:50:40 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p3QIodpq026312
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 14:50:40 -0400
Date: Tue, 26 Apr 2011 11:50:36 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: 2.6.39-rc4+: Kernel leaking memory during FS scanning,
 regression?
Message-ID: <20110426185036.GG2135@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <BANLkTi=hQ=HcPLCdbb1pSi+xJByMTah-gw@mail.gmail.com>
 <20110425203606.4e78246c@neptune.home>
 <20110425191607.GL2468@linux.vnet.ibm.com>
 <20110425231016.34b4293e@neptune.home>
 <BANLkTin7wSGi1=E2c2u6Jb5TG_KUpYh=Dw@mail.gmail.com>
 <20110425214933.GO2468@linux.vnet.ibm.com>
 <20110426081904.0d2b1494@pluto.restena.lu>
 <20110426112756.GF4308@linux.vnet.ibm.com>
 <20110426183859.6ff6279b@neptune.home>
 <BANLkTin3UG=xF1VQOtdEDOnShoMQwQ7gFg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <BANLkTin3UG=xF1VQOtdEDOnShoMQwQ7gFg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Bruno =?iso-8859-1?Q?Pr=E9mont?= <bonbons@linux-vserver.org>, Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mike Frysinger <vapier.adi@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "Paul E. McKenney" <paul.mckenney@linaro.org>, Pekka Enberg <penberg@kernel.org>

On Tue, Apr 26, 2011 at 10:12:39AM -0700, Linus Torvalds wrote:
> On Tue, Apr 26, 2011 at 9:38 AM, Bruno Premont
> <bonbons@linux-vserver.org> wrote:
> >
> > Here it comes:
> >
> > rcu_kthread (when build processes are STOPped):
> > [  836.050003] rcu_kthread     R running   7324     6      2 0x00000000
> > [  836.050003]  dd473f28 00000046 5a000240 dd65207c dd407360 dd651d40 0000035c dd473ed8
> > [  836.050003]  c10bf8a2 c14d63d8 dd65207c dd473f28 dd445040 dd445040 dd473eec c10be848
> > [  836.050003]  dd651d40 dd407360 ddfdca00 dd473f14 c10bfde2 00000000 00000001 000007b6
> > [  836.050003] Call Trace:
> > [  836.050003]  [<c10bf8a2>] ? check_object+0x92/0x210
> > [  836.050003]  [<c10be848>] ? init_object+0x38/0x70
> > [  836.050003]  [<c10bfde2>] ? free_debug_processing+0x112/0x1f0
> > [  836.050003]  [<c103d9fd>] ? lock_timer_base+0x2d/0x70
> > [  836.050003]  [<c13c8ec7>] schedule_timeout+0x137/0x280
> 
> Hmm.
> 
> I'm adding Ingo and Peter to the cc, because this whole "rcu_kthread
> is running, but never actually running" is starting to smell like a
> scheduler issue.
> 
> Peter/Ingo: RCUTINY seems to be broken for Bruno. During any kind of
> heavy workload, at some point it looks like rcu_kthread simply stops
> making any progress. It's constantly in runnable state, but it doesn't
> actually use any CPU time, and it's not processing the RCU callbacks,
> so the RCU memory freeing isn't happening, and slabs just build up
> until the machine dies.
> 
> And it really is RCUTINY, because the thing doesn't happen with the
> regular tree-RCU.

The difference between TINY_RCU and TREE_RCU is that TREE_RCU still uses
softirq for the core RCU processing.  TINY_RCU switched to a kthread
when I implemented RCU priority boosting.  There is a similar change in
my -rcu tree that makes TREE_RCU use kthreads, and Sedat has been running
into a very similar problem with that change in place.  Which is why I
do not yet push it to the -next tree.

> This is without CONFIG_RCU_BOOST_PRIO, so we basically have
> 
>         struct sched_param sp;
> 
>         rcu_kthread_task = kthread_run(rcu_kthread, NULL, "rcu_kthread");
>         sp.sched_priority = RCU_BOOST_PRIO;
>         sched_setscheduler_nocheck(rcu_kthread_task, SCHED_FIFO, &sp);
> 
> where RCU_BOOST_PRIO is 1 for the non-boost case.

Good point!  Bruno, Sedat, could you please set CONFIG_RCU_BOOST_PRIO to
(say) 50, and see if this still happens?  (I bet that you do, but...)

> Is that so low that even the idle thread will take priority? It's a UP
> config with PREEMPT_VOLUNTARY. So pretty much _all_ the stars are
> aligned for odd scheduling behavior.
> 
> Other users of SCHED_FIFO tend to set the priority really high (eg
> "MAX_RT_PRIO-1" is clearly the default one - softirq's, watchdog), but
> "1" is not unheard of either (touchscreen/ucb1400_ts and
> mmc/core/sdio_irq), and there are some other random choises out tere.
> 
> Any ideas?

I have found one bug so far in my code, but it only affects TREE_RCU
in my -rcu tree, and even then only if HOTPLUG_CPU is enabled.  I am
testing a fix, but I expect Sedat's tests to still break.

I gave Sedat a patch that make rcu_kthread() run at normal (non-realtime)
priority, and he did not see the failure.  So running non-realtime at
least greatly reduces the probability of failure.

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
