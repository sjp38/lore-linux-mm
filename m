Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 77DD76B0011
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 18:02:26 -0400 (EDT)
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by e3.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p3RLf3x6012090
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 17:41:03 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p3RM2ONJ092626
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 18:02:24 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p3RM2Mmg030463
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 18:02:23 -0400
Date: Wed, 27 Apr 2011 15:02:20 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: 2.6.39-rc4+: Kernel leaking memory during FS scanning,
 regression?
Message-ID: <20110427220220.GP2135@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <20110425191607.GL2468@linux.vnet.ibm.com>
 <20110425231016.34b4293e@neptune.home>
 <BANLkTin7wSGi1=E2c2u6Jb5TG_KUpYh=Dw@mail.gmail.com>
 <20110425214933.GO2468@linux.vnet.ibm.com>
 <20110426081904.0d2b1494@pluto.restena.lu>
 <20110426112756.GF4308@linux.vnet.ibm.com>
 <20110426183859.6ff6279b@neptune.home>
 <BANLkTin3UG=xF1VQOtdEDOnShoMQwQ7gFg@mail.gmail.com>
 <20110426185036.GG2135@linux.vnet.ibm.com>
 <BANLkTinqm7CTACEYuMZxKmXkjwHRyg+fHw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <BANLkTinqm7CTACEYuMZxKmXkjwHRyg+fHw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: sedat.dilek@gmail.com
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Bruno =?iso-8859-1?Q?Pr=E9mont?= <bonbons@linux-vserver.org>, Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mike Frysinger <vapier.adi@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "Paul E. McKenney" <paul.mckenney@linaro.org>, Pekka Enberg <penberg@kernel.org>

On Tue, Apr 26, 2011 at 09:17:28PM +0200, Sedat Dilek wrote:
> On Tue, Apr 26, 2011 at 8:50 PM, Paul E. McKenney
> <paulmck@linux.vnet.ibm.com> wrote:
> > On Tue, Apr 26, 2011 at 10:12:39AM -0700, Linus Torvalds wrote:
> >> On Tue, Apr 26, 2011 at 9:38 AM, Bruno Premont
> >> <bonbons@linux-vserver.org> wrote:
> >> >
> >> > Here it comes:
> >> >
> >> > rcu_kthread (when build processes are STOPped):
> >> > [  836.050003] rcu_kthread     R running   7324     6      2 0x00000000
> >> > [  836.050003]  dd473f28 00000046 5a000240 dd65207c dd407360 dd651d40 0000035c dd473ed8
> >> > [  836.050003]  c10bf8a2 c14d63d8 dd65207c dd473f28 dd445040 dd445040 dd473eec c10be848
> >> > [  836.050003]  dd651d40 dd407360 ddfdca00 dd473f14 c10bfde2 00000000 00000001 000007b6
> >> > [  836.050003] Call Trace:
> >> > [  836.050003]  [<c10bf8a2>] ? check_object+0x92/0x210
> >> > [  836.050003]  [<c10be848>] ? init_object+0x38/0x70
> >> > [  836.050003]  [<c10bfde2>] ? free_debug_processing+0x112/0x1f0
> >> > [  836.050003]  [<c103d9fd>] ? lock_timer_base+0x2d/0x70
> >> > [  836.050003]  [<c13c8ec7>] schedule_timeout+0x137/0x280
> >>
> >> Hmm.
> >>
> >> I'm adding Ingo and Peter to the cc, because this whole "rcu_kthread
> >> is running, but never actually running" is starting to smell like a
> >> scheduler issue.
> >>
> >> Peter/Ingo: RCUTINY seems to be broken for Bruno. During any kind of
> >> heavy workload, at some point it looks like rcu_kthread simply stops
> >> making any progress. It's constantly in runnable state, but it doesn't
> >> actually use any CPU time, and it's not processing the RCU callbacks,
> >> so the RCU memory freeing isn't happening, and slabs just build up
> >> until the machine dies.
> >>
> >> And it really is RCUTINY, because the thing doesn't happen with the
> >> regular tree-RCU.
> >
> > The difference between TINY_RCU and TREE_RCU is that TREE_RCU still uses
> > softirq for the core RCU processing.  TINY_RCU switched to a kthread
> > when I implemented RCU priority boosting.  There is a similar change in
> > my -rcu tree that makes TREE_RCU use kthreads, and Sedat has been running
> > into a very similar problem with that change in place.  Which is why I
> > do not yet push it to the -next tree.
> >
> >> This is without CONFIG_RCU_BOOST_PRIO, so we basically have
> >>
> >>         struct sched_param sp;
> >>
> >>         rcu_kthread_task = kthread_run(rcu_kthread, NULL, "rcu_kthread");
> >>         sp.sched_priority = RCU_BOOST_PRIO;
> >>         sched_setscheduler_nocheck(rcu_kthread_task, SCHED_FIFO, &sp);
> >>
> >> where RCU_BOOST_PRIO is 1 for the non-boost case.
> >
> > Good point!  Bruno, Sedat, could you please set CONFIG_RCU_BOOST_PRIO to
> > (say) 50, and see if this still happens?  (I bet that you do, but...)
> >
> 
> What's with CONFIG_RCU_BOOST_DELAY setting?

CONFIG_RCU_BOOST_DELAY controls how long preemptible RCU lets a grace
period run before boosting the priority of any blocked RCU readers.

It is completely irrelevant if the rcu_kthread task isn't getting a
chance to run, though.  This is because it is the rcu_kthread task
that does the boosting.

> Are those values OK?
> 
> $ egrep 'M486|M686|X86_UP|CONFIG_SMP|NR_CPUS|PREEMPT|_RCU|_HIGHMEM|PAE' .config
> CONFIG_TREE_PREEMPT_RCU=y
> CONFIG_PREEMPT_RCU=y
> CONFIG_RCU_TRACE=y
> CONFIG_RCU_FANOUT=32
> # CONFIG_RCU_FANOUT_EXACT is not set
> CONFIG_TREE_RCU_TRACE=y
> CONFIG_RCU_BOOST=y

I suggest CONFIG_RCU_BOOST=n to keep things simple for the moment, but
CONFIG_RCU_BOOST=y should be OK too.

> CONFIG_RCU_BOOST_PRIO=50
> CONFIG_RCU_BOOST_DELAY=500
> CONFIG_SMP=y
> # CONFIG_M486 is not set
> CONFIG_M686=y

I don't have an opinion on CONFIG_M486 vs. CONFIG_M686.

> CONFIG_NR_CPUS=32
> # CONFIG_PREEMPT_NONE is not set
> # CONFIG_PREEMPT_VOLUNTARY is not set
> CONFIG_PREEMPT=y
> CONFIG_HIGHMEM4G=y
> # CONFIG_HIGHMEM64G is not set
> CONFIG_HIGHMEM=y
> CONFIG_DEBUG_OBJECTS_RCU_HEAD=y
> CONFIG_DEBUG_PREEMPT=y

The above two could be left out, but shouldn't hurt.

> # CONFIG_SPARSE_RCU_POINTER is not set
> # CONFIG_DEBUG_HIGHMEM is not set
> CONFIG_RCU_TORTURE_TEST=m
> CONFIG_RCU_CPU_STALL_TIMEOUT=60
> CONFIG_RCU_CPU_STALL_VERBOSE=y
> CONFIG_PREEMPT_TRACER=y

So they look fine to me, the ones that I understand, anyway.  ;-)

							Thanx, Paul
> 
> - Sedat -
> 
> >> Is that so low that even the idle thread will take priority? It's a UP
> >> config with PREEMPT_VOLUNTARY. So pretty much _all_ the stars are
> >> aligned for odd scheduling behavior.
> >>
> >> Other users of SCHED_FIFO tend to set the priority really high (eg
> >> "MAX_RT_PRIO-1" is clearly the default one - softirq's, watchdog), but
> >> "1" is not unheard of either (touchscreen/ucb1400_ts and
> >> mmc/core/sdio_irq), and there are some other random choises out tere.
> >>
> >> Any ideas?
> >
> > I have found one bug so far in my code, but it only affects TREE_RCU
> > in my -rcu tree, and even then only if HOTPLUG_CPU is enabled.  I am
> > testing a fix, but I expect Sedat's tests to still break.
> >
> > I gave Sedat a patch that make rcu_kthread() run at normal (non-realtime)
> > priority, and he did not see the failure.  So running non-realtime at
> > least greatly reduces the probability of failure.
> >
> >                                                        Thanx, Paul
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-fsdevel" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> >

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
