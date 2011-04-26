Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id B85159000C1
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 18:28:57 -0400 (EDT)
Date: Wed, 27 Apr 2011 00:28:37 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: 2.6.39-rc4+: Kernel leaking memory during FS scanning,
 regression?
In-Reply-To: <BANLkTikjuqWP+PAsObJH4EAOyzgr2RbYNA@mail.gmail.com>
Message-ID: <alpine.LFD.2.02.1104262314110.3323@ionos>
References: <20110425180450.1ede0845@neptune.home> <BANLkTikSLA59tdgRL4B=cr5tvP2NbzZ=KA@mail.gmail.com> <20110425190032.7904c95d@neptune.home> <BANLkTi=hQ=HcPLCdbb1pSi+xJByMTah-gw@mail.gmail.com> <20110425203606.4e78246c@neptune.home> <20110425191607.GL2468@linux.vnet.ibm.com>
 <20110425231016.34b4293e@neptune.home> <BANLkTin7wSGi1=E2c2u6Jb5TG_KUpYh=Dw@mail.gmail.com> <20110425214933.GO2468@linux.vnet.ibm.com> <20110426081904.0d2b1494@pluto.restena.lu> <20110426112756.GF4308@linux.vnet.ibm.com> <20110426183859.6ff6279b@neptune.home>
 <20110426190918.01660ccf@neptune.home> <BANLkTikjuqWP+PAsObJH4EAOyzgr2RbYNA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323328-1734561087-1303852684=:3323"
Content-ID: <alpine.LFD.2.02.1104270006260.3323@ionos>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: =?ISO-8859-15?Q?Bruno_Pr=E9mont?= <bonbons@linux-vserver.org>, Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <a.p.zijlstra@chello.nl>, paulmck@linux.vnet.ibm.com, Mike Frysinger <vapier.adi@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "Paul E. McKenney" <paul.mckenney@linaro.org>, Pekka Enberg <penberg@kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323328-1734561087-1303852684=:3323
Content-Type: TEXT/PLAIN; CHARSET=ISO-8859-15
Content-Transfer-Encoding: 8BIT
Content-ID: <alpine.LFD.2.02.1104270006261.3323@ionos>

On Tue, 26 Apr 2011, Linus Torvalds wrote:

> On Tue, Apr 26, 2011 at 10:09 AM, Bruno Premont
> <bonbons@linux-vserver.org> wrote:
> >
> > Just in case, /proc/$(pidof rcu_kthread)/status shows ~20k voluntary
> > context switches and exactly one non-voluntary one.
> >
> > In addition when rcu_kthread has stopped doing its work
> > `swapoff $(swapdevice)` seems to block forever (at least normal shutdown
> > blocks on disabling swap device).
> > If I get to do it when I get back home I will manually try to swapoff
> > and take process traces with sysrq-t.
> 
> That "exactly one non-voluntary one" sounds like the smoking gun.
> 
> Normally SCHED_FIFO runs until it voluntarily gives up the CPU. That's
> kind of the point of SCHED_FIFO. Involuntary context switches happen
> when some higher-priority SCHED_FIFO process becomes runnable (irq
> handlers? You _do_ have CONFIG_IRQ_FORCED_THREADING=y in your config
> too), and maybe there is a bug in the runqueue handling for that case.

The forced irq threading is only effective when you add the command
line parameter "threadirqs". I don't see any irq threads in the ps
outputs, so that's not the problem.

Though the whole ps output is weird. There is only one thread/process
which accumulated CPU time

collectd  1605  0.6  0.7  49924  3748 ?        SNLsl 22:14   0:14

All others show 0:00 CPU time - not only kthread_rcu.

Bruno, are you running on real hardware or in a virtual machine?

Can you please enable CONFIG_SCHED_DEBUG and provide the output of
/proc/sched_stat when the problem surfaces and a minute after the
first snapshot?

Also please apply the patch below and check, whether the printk shows
up in your dmesg.

Thanks,

	tglx

---
 kernel/sched_rt.c |    1 +
 1 file changed, 1 insertion(+)

Index: linux-2.6-tip/kernel/sched_rt.c
===================================================================
--- linux-2.6-tip.orig/kernel/sched_rt.c
+++ linux-2.6-tip/kernel/sched_rt.c
@@ -609,6 +609,7 @@ static int sched_rt_runtime_exceeded(str
 
 	if (rt_rq->rt_time > runtime) {
 		rt_rq->rt_throttled = 1;
+		printk_once(KERN_WARNING "sched: RT throttling activated\n");
 		if (rt_rq_throttled(rt_rq)) {
 			sched_rt_rq_dequeue(rt_rq);
 			return 1;
--8323328-1734561087-1303852684=:3323--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
