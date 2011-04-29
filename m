Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 77E5F900001
	for <linux-mm@kvack.org>; Thu, 28 Apr 2011 20:43:01 -0400 (EDT)
Received: from d01relay01.pok.ibm.com (d01relay01.pok.ibm.com [9.56.227.233])
	by e9.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p3T0EOjY002402
	for <linux-mm@kvack.org>; Thu, 28 Apr 2011 20:14:24 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p3T0gxff094564
	for <linux-mm@kvack.org>; Thu, 28 Apr 2011 20:43:00 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p3T0gwk6024199
	for <linux-mm@kvack.org>; Thu, 28 Apr 2011 20:42:59 -0400
Date: Thu, 28 Apr 2011 17:42:55 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: 2.6.39-rc4+: Kernel leaking memory during FS scanning,
 regression?
Message-ID: <20110429004255.GF2191@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <BANLkTik4+PAGHF-9KREYk8y+KDQLDAp2Mg@mail.gmail.com>
 <alpine.LFD.2.02.1104282044120.3005@ionos>
 <20110428222301.0b745a0a@neptune.home>
 <alpine.LFD.2.02.1104282227340.3005@ionos>
 <20110428224444.43107883@neptune.home>
 <alpine.LFD.2.02.1104282251080.3005@ionos>
 <1304027480.2971.121.camel@work-vm>
 <alpine.LFD.2.02.1104282353140.3005@ionos>
 <BANLkTi=uDstjKEQaPOkxX94NxMQU2Pu5gA@mail.gmail.com>
 <BANLkTikS-PN0PDBbCz3emWRBL90sGMY+Kg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <BANLkTikS-PN0PDBbCz3emWRBL90sGMY+Kg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: sedat.dilek@gmail.com
Cc: Thomas Gleixner <tglx@linutronix.de>, john stultz <johnstul@us.ibm.com>, Bruno =?iso-8859-1?Q?Pr=E9mont?= <bonbons@linux-vserver.org>, Mike Galbraith <efault@gmx.de>, Linus Torvalds <torvalds@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mike Frysinger <vapier.adi@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "Paul E. McKenney" <paul.mckenney@linaro.org>, Pekka Enberg <penberg@kernel.org>

On Fri, Apr 29, 2011 at 01:35:44AM +0200, Sedat Dilek wrote:
> On Fri, Apr 29, 2011 at 1:06 AM, Sedat Dilek <sedat.dilek@googlemail.com> wrote:
> > On Fri, Apr 29, 2011 at 12:02 AM, Thomas Gleixner <tglx@linutronix.de> wrote:
> >> On Thu, 28 Apr 2011, john stultz wrote:
> >>> On Thu, 2011-04-28 at 23:04 +0200, Thomas Gleixner wrote:
> >>> > /me suspects hrtimer changes to be the real culprit.
> >>>
> >>> I'm not seeing anything on right off, but it does smell like
> >>> e06383db9ec591696a06654257474b85bac1f8cb would be where such an issue
> >>> would crop up.
> >>>
> >>> Bruno, could you try checking out e06383db9ec, confirming it still
> >>> occurs (and then maybe seeing if it goes away at e06383db9ec^1)?
> >>>
> >>> I'll keep digging in the meantime.
> >>
> >> I found the bug already. The problem is that sched_init() calls
> >> init_rt_bandwidth() which calls hrtimer_init() _BEFORE_
> >> hrtimers_init() is called.
> >>
> >> That was unnoticed so far as the CLOCK id to hrtimer base conversion
> >> was hardcoded. Now we use a table which is set up at hrtimers_init(),
> >> so the bandwith hrtimer ends up on CLOCK_REALTIME because the table is
> >> in the bss.
> >>
> >> The patch below fixes this, by providing the table statically rather
> >> than runtime initialized. Though that whole ordering wants to be
> >> revisited.
> >>
> >> Thanks,
> >>
> >>        tglx
> >>
> >> --- linux-2.6.orig/kernel/hrtimer.c
> >> +++ linux-2.6/kernel/hrtimer.c
> >> @@ -81,7 +81,11 @@ DEFINE_PER_CPU(struct hrtimer_cpu_base,
> >>        }
> >>  };
> >>
> >> -static int hrtimer_clock_to_base_table[MAX_CLOCKS];
> >> +static int hrtimer_clock_to_base_table[MAX_CLOCKS] = {
> >> +       [CLOCK_REALTIME] = HRTIMER_BASE_REALTIME,
> >> +       [CLOCK_MONOTONIC] = HRTIMER_BASE_MONOTONIC,
> >> +       [CLOCK_BOOTTIME] = HRTIMER_BASE_BOOTTIME,
> >> +};
> >>
> >>  static inline int hrtimer_clockid_to_base(clockid_t clock_id)
> >>  {
> >> @@ -1722,10 +1726,6 @@ static struct notifier_block __cpuinitda
> >>
> >>  void __init hrtimers_init(void)
> >>  {
> >> -       hrtimer_clock_to_base_table[CLOCK_REALTIME] = HRTIMER_BASE_REALTIME;
> >> -       hrtimer_clock_to_base_table[CLOCK_MONOTONIC] = HRTIMER_BASE_MONOTONIC;
> >> -       hrtimer_clock_to_base_table[CLOCK_BOOTTIME] = HRTIMER_BASE_BOOTTIME;
> >> -
> >>        hrtimer_cpu_notify(&hrtimers_nb, (unsigned long)CPU_UP_PREPARE,
> >>                          (void *)(long)smp_processor_id());
> >>        register_cpu_notifier(&hrtimers_nb);
> >>
> >>
> >>
> >
> > Looks good so far, no stalls or call-traces.
> >
> > Really stressing with 20+ open tabs in firefox with flash-movie
> > running in one of them , tar-job, IRC-client etc.
> > I will run some more tests and collect data and send them later.
> >
> > - Sedat -
> >
> > P.S.: Patchset against linux-2.6-rcu.git#sedat.2011.04.23a where 0003
> > is from [2]
> >
> > [1] http://git.us.kernel.org/?p=linux/kernel/git/paulmck/linux-2.6-rcu.git;a=shortlog;h=refs/heads/sedat.2011.04.23a
> > [2] https://patchwork.kernel.org/patch/739782/
> >
> > $ l ../RCU-HOORAY/
> > insgesamt 40
> > drwxr-xr-x  2 sd sd  4096 29. Apr 01:02 .
> > drwxr-xr-x 35 sd sd 20480 29. Apr 01:01 ..
> > -rw-r--r--  1 sd sd   726 29. Apr 01:01
> > 0001-Revert-rcu-restrict-TREE_RCU-to-SMP-builds-with-PREE.patch
> > -rw-r--r--  1 sd sd   735 29. Apr 01:01
> > 0002-sched-Add-warning-when-RT-throttling-is-activated.patch
> > -rw-r--r--  1 sd sd  2376 29. Apr 01:01
> > 0003-2.6.39-rc4-Kernel-leaking-memory-during-FS-scanning-.patch
> >
> 
> As promised the tarball (at the end of the log I made some XZ compressing).
> 
> Wow!
> $ uptime
>  01:35:17 up 45 min,  3 users,  load average: 0.45, 0.57, 1.27
> 
> Thanks to all involved people helping to kill that bug (Come on Paul, smile!).

Woo-hoo!!!!

Many thanks to Thomas for tracking this down -- it is fair to say that
I never would have thought to look at timer initialization!  ;-)

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
