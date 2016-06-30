Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id D261B828E1
	for <linux-mm@kvack.org>; Thu, 30 Jun 2016 11:53:49 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id a2so63241301lfe.0
        for <linux-mm@kvack.org>; Thu, 30 Jun 2016 08:53:49 -0700 (PDT)
Received: from baptiste.telenet-ops.be (baptiste.telenet-ops.be. [2a02:1800:120:4::f00:13])
        by mx.google.com with ESMTPS id i196si1406870wmd.55.2016.06.30.08.53.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 Jun 2016 08:53:46 -0700 (PDT)
Date: Thu, 30 Jun 2016 17:53:42 +0200 (CEST)
From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: Boot failure on emev2/kzm9d (was: Re: [PATCH v2 11/11] mm/slab:
 lockless decision to grow cache)
In-Reply-To: <20160630151838.GW4650@linux.vnet.ibm.com>
Message-ID: <alpine.DEB.2.10.1606301752410.6474@ayla.of.borg>
References: <20160623024742.GD1473@linux.vnet.ibm.com> <20160623025329.GA13095@linux.vnet.ibm.com> <CAMuHMdVqNV5ZbR3_NV5ZsLxoNQUXXGpfAcaoMJffaJbRPUb6-A@mail.gmail.com> <20160629164415.GG4650@linux.vnet.ibm.com> <CAMuHMdUfQ-gBqjZGvawf5zxgb-0UnWb+fzD-kcWU+kavwvadgQ@mail.gmail.com>
 <20160629181208.GP4650@linux.vnet.ibm.com> <20160630074710.GC30114@js1304-P5Q-DELUXE> <CAMuHMdVx4p9=CNCwZuuUyxsYZGN7VPs7F+RbysQjYGSY25TPQA@mail.gmail.com> <20160630132401.GT4650@linux.vnet.ibm.com> <CAMuHMdVTX3ojMsO5Mv++pA5r+st4yBTTo39QTbV-FxPmJ7fbkQ@mail.gmail.com>
 <20160630151838.GW4650@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Linux-Renesas <linux-renesas-soc@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Pekka Enberg <penberg@kernel.org>, Linux MM <linux-mm@kvack.org>, Jesper Dangaard Brouer <brouer@redhat.com>, Christoph Lameter <cl@linux.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>

On Thu, 30 Jun 2016, Paul E. McKenney wrote:
> On Thu, Jun 30, 2016 at 03:31:57PM +0200, Geert Uytterhoeven wrote:
> > On Thu, Jun 30, 2016 at 3:24 PM, Paul E. McKenney
> > <paulmck@linux.vnet.ibm.com> wrote:
> > > On Thu, Jun 30, 2016 at 09:58:51AM +0200, Geert Uytterhoeven wrote:
> > >> On Thu, Jun 30, 2016 at 9:47 AM, Joonsoo Kim <iamjoonsoo.kim@lge.com> wrote:
> > >> > On Wed, Jun 29, 2016 at 11:12:08AM -0700, Paul E. McKenney wrote:
> > >> >> On Wed, Jun 29, 2016 at 07:52:06PM +0200, Geert Uytterhoeven wrote:
> > >> >> > On Wed, Jun 29, 2016 at 6:44 PM, Paul E. McKenney
> > >> >> > <paulmck@linux.vnet.ibm.com> wrote:
> > >> >> > > On Wed, Jun 29, 2016 at 04:54:44PM +0200, Geert Uytterhoeven wrote:
> > >> >> > >> On Thu, Jun 23, 2016 at 4:53 AM, Paul E. McKenney
> > >> >> > >> <paulmck@linux.vnet.ibm.com> wrote:
> > >> >> > >> > On Wed, Jun 22, 2016 at 07:47:42PM -0700, Paul E. McKenney wrote:
> > >> >> > >
> > >> >> > > [ . . . ]
> > >> >> > >
> > >> >> > >> > @@ -4720,11 +4720,18 @@ static void __init rcu_dump_rcu_node_tree(struct rcu_state *rsp)
> > >> >> > >> >                         pr_info(" ");
> > >> >> > >> >                         level = rnp->level;
> > >> >> > >> >                 }
> > >> >> > >> > -               pr_cont("%d:%d ^%d  ", rnp->grplo, rnp->grphi, rnp->grpnum);
> > >> >> > >> > +               pr_cont("%d:%d/%#lx/%#lx ^%d  ", rnp->grplo, rnp->grphi,
> > >> >> > >> > +                       rnp->qsmask,
> > >> >> > >> > +                       rnp->qsmaskinit | rnp->qsmaskinitnext, rnp->grpnum);
> > >> >> > >> >         }
> > >> >> > >> >         pr_cont("\n");
> > >> >> > >> >  }
> > >> >> > >>
> > >> >> > >> For me it always crashes during the 37th call of synchronize_sched() in
> > >> >> > >> setup_kmem_cache_node(), which is the first call after secondary CPU bring up.
> > >> >> > >> With your and my debug code, I get:
> > >> >> > >>
> > >> >> > >>   CPU: Testing write buffer coherency: ok
> > >> >> > >>   CPU0: thread -1, cpu 0, socket 0, mpidr 80000000
> > >> >> > >>   Setting up static identity map for 0x40100000 - 0x40100058
> > >> >> > >>   cnt = 36, sync
> > >> >> > >>   CPU1: thread -1, cpu 1, socket 0, mpidr 80000001
> > >> >> > >>   Brought up 2 CPUs
> > >> >> > >>   SMP: Total of 2 processors activated (2132.00 BogoMIPS).
> > >> >> > >>   CPU: All CPU(s) started in SVC mode.
> > >> >> > >>   rcu_node tree layout dump
> > >> >> > >>    0:1/0x0/0x3 ^0
> > >> >> > >
> > >> >> > > Thank you for running this!
> > >> >> > >
> > >> >> > > OK, so RCU knows about both CPUs (the "0x3"), and the previous
> > >> >> > > grace period has seen quiescent states from both of them (the "0x0").
> > >> >> > > That would indicate that your synchronize_sched() showed up when RCU was
> > >> >> > > idle, so it had to start a new grace period.  It also rules out failure
> > >> >> > > modes where RCU thinks that there are more CPUs than really exist.
> > >> >> > > (Don't laugh, such things have really happened.)
> > >> >> > >
> > >> >> > >>   devtmpfs: initialized
> > >> >> > >>   VFP support v0.3: implementor 41 architecture 3 part 30 variant 9 rev 1
> > >> >> > >>   clocksource: jiffies: mask: 0xffffffff max_cycles: 0xffffffff,
> > >> >> > >> max_idle_ns: 19112604462750000 ns
> > >> >> > >>
> > >> >> > >> I hope it helps. Thanks!
> > >> >> > >
> > >> >> > > I am going to guess that this was the first grace period since the second
> > >> >> > > CPU came online.  When there only on CPU online, synchronize_sched()
> > >> >> > > is a no-op.
> > >> >> > >
> > >> >> > > OK, this showed some things that aren't a problem.  What might the
> > >> >> > > problem be?
> > >> >> > >
> > >> >> > > o       The grace-period kthread has not yet started.  It -should- start
> > >> >> > >         at early_initcall() time, but who knows?  Adding code to print
> > >> >> > >         out that kthread's task_struct address.
> > >> >> > >
> > >> >> > > o       The grace-period kthread might not be responding to wakeups.
> > >> >> > >         Checking this requires that a grace period be in progress,
> > >> >> > >         so please put a call_rcu_sched() just before the call to
> > >> >> > >         rcu_dump_rcu_node_tree().  (Sample code below.)  Adding code
> > >> >> > >         to my patch to print out more GP-kthread state as well.
> > >> >> > >
> > >> >> > > o       One of the CPUs might not be responding to RCU.  That -should-
> > >> >> > >         result in an RCU CPU stall warning, so I will ignore this
> > >> >> > >         possibility for the moment.
> > >> >> > >
> > >> >> > >         That said, do you have some way to determine whether scheduling
> > >> >> > >         clock interrupts are really happening?  Without these interrupts,
> > >> >> > >         no RCU CPU stall warnings.
> > >> >> >
> > >> >> > I believe there are no clocksources yet. The jiffies clocksource is the first
> > >> >> > clocksource found, and that happens after the first call to
> > >> >> > synchronize_sched(), cfr. my dmesg snippet above.
> > >> >> >
> > >> >> > In a working boot:
> > >> >> > # cat /sys/bus/clocksource/devices/clocksource0/available_clocksource
> > >> >> > e0180000.timer jiffies
> > >> >> > # cat /sys/bus/clocksource/devices/clocksource0/current_clocksource
> > >> >> > e0180000.timer
> > >> >>
> > >> >> Ah!  But if there is no jiffies clocksource, then schedule_timeout()
> > >> >> and friends will never return, correct?  If so, I guarantee you that
> > >> >> synchronize_sched() will unconditionally hang.
> > >> >>
> > >> >> So if I understand correctly, the fix is to get the jiffies clocksource
> > >> >> running before the first call to synchronize_sched().
> > >> >
> > >> > If so, following change would be sufficient.
> > >> >
> > >> > Thanks.
> > >> >
> > >> > ------>8-------
> > >> > diff --git a/kernel/time/jiffies.c b/kernel/time/jiffies.c
> > >> > index 555e21f..4f6471f 100644
> > >> > --- a/kernel/time/jiffies.c
> > >> > +++ b/kernel/time/jiffies.c
> > >> > @@ -98,7 +98,7 @@ static int __init init_jiffies_clocksource(void)
> > >> >         return __clocksource_register(&clocksource_jiffies);
> > >> >  }
> > >> >
> > >> > -core_initcall(init_jiffies_clocksource);
> > >> > +early_initcall(init_jiffies_clocksource);
> > >> >
> > >> >  struct clocksource * __init __weak clocksource_default_clock(void)
> > >> >  {
> > >>
> > >> Thanks for your patch!
> > >>
> > >> While this does move jiffies clocksource initialization before secondary CPU
> > >> bringup, it still hangs when calling call_rcu() or synchronize_sched():
> > >>
> > >>   CPU: Testing write buffer coherency: ok
> > >>   CPU0: thread -1, cpu 0, socket 0, mpidr 80000000
> > >>   Setting up static identity map for 0x40100000 - 0x40100058
> > >>   cnt = 36, sync
> > >>   clocksource: jiffies: mask: 0xffffffff max_cycles: 0xffffffff,
> > >> max_idle_ns: 19112604462750000 ns
> > >>   CPU1: thread -1, cpu 1, socket 0, mpidr 80000001
> > >>   Brought up 2 CPUs
> > >>   SMP: Total of 2 processors activated (2132.00 BogoMIPS).
> > >>   CPU: All CPU(s) started in SVC mode.
> > >>   RCU: rcu_sched GP kthread: c784e1c0 state: 1 flags: 0x0 g:-300 c:-300
> > >>        jiffies: 0xffff8ad0  GP start: 0x0 Last GP activity: 0x0
> > >>   rcu_node tree layout dump
> > >>    0:1/0x0/0x3 ^0
> > >
> > > This is in fact the initial state for RCU grace periods.  In other words,
> > > all the earlier calls to synchronize_sched() likely happened while there
> > > was only one CPU online.
> > >
> > >>   devtmpfs: initialized
> > >>   VFP support v0.3: implementor 41 architecture 3 part 30 variant 9 rev 1
> > >
> > > Could you please add the call_rcu() and timed delay as described in my
> > > earlier email?  That would hopefully help me see the state of the stalled
> > > grace period.
> > 
> > I already did, cfr. "it still hangs when calling call_rcu() or
> > synchronize_sched()".
> 
> Ah, sorry for my inattention.
> 
> I am a bit surprised that it could hang when calling call_rcu(), given
> that call_rcu() is callable from atomic contexts.  Could you please show
> me the current test code you have?
> 
> If the hang is in call_rcu(), could you please try disabling irqs across
> the call to call_rcu()?

These are my local changes:

diff --git a/kernel/rcu/tree.c b/kernel/rcu/tree.c
index c7f1bc4f817c4a34..50bea263e510006f 100644
--- a/kernel/rcu/tree.c
+++ b/kernel/rcu/tree.c
@@ -4707,11 +4707,16 @@ static void __init rcu_init_geometry(void)
  * Dump out the structure of the rcu_node combining tree associated
  * with the rcu_state structure referenced by rsp.
  */
-static void __init rcu_dump_rcu_node_tree(struct rcu_state *rsp)
+static void rcu_dump_rcu_node_tree(struct rcu_state *rsp)
 {
 	int level = 0;
 	struct rcu_node *rnp;
 
+	pr_info("RCU: %s GP kthread: %p state: %d flags: %#x g:%ld c:%ld\n",
+		rsp->name, rsp->gp_kthread, rsp->gp_state, rsp->gp_flags,
+		(long)rsp->gpnum, (long)rsp->completed);
+	pr_info("     jiffies: %#lx  GP start: %#lx Last GP activity: %#lx\n",
+		jiffies, rsp->gp_start, rsp->gp_activity);
 	pr_info("rcu_node tree layout dump\n");
 	pr_info(" ");
 	rcu_for_each_node_breadth_first(rsp, rnp) {
@@ -4720,11 +4725,32 @@ static void __init rcu_dump_rcu_node_tree(struct rcu_state *rsp)
 			pr_info(" ");
 			level = rnp->level;
 		}
-		pr_cont("%d:%d ^%d  ", rnp->grplo, rnp->grphi, rnp->grpnum);
+		pr_cont("%d:%d/%#lx/%#lx ^%d  ", rnp->grplo, rnp->grphi,
+			rnp->qsmask,
+			rnp->qsmaskinit | rnp->qsmaskinitnext, rnp->grpnum);
 	}
 	pr_cont("\n");
 }
 
+static void do_nothing_cb(struct rcu_head *rcu_head)
+{
+}
+
+void rcu_dump_rcu_sched_tree(void)
+{
+	struct rcu_head rh;
+	unsigned long flags;
+
+	rcu_dump_rcu_node_tree(&rcu_sched_state);  /* Initial state. */
+	local_irq_save(flags);
+	// call_rcu(&rh, do_nothing_cb);
+	local_irq_restore(flags);
+	// schedule_timeout_uninterruptible(5 * HZ);  /* Or whatever delay. */
+	rcu_dump_rcu_node_tree(&rcu_sched_state); /* GP state. */
+	//synchronize_sched();  /* Probably hangs. */
+	//rcu_barrier();  /* Drop RCU's references to rh before return. */
+}
+
 void __init rcu_init(void)
 {
 	int cpu;
diff --git a/kernel/time/jiffies.c b/kernel/time/jiffies.c
index 555e21f7b966c789..4f6471f54f69a6fe 100644
--- a/kernel/time/jiffies.c
+++ b/kernel/time/jiffies.c
@@ -98,7 +98,7 @@ static int __init init_jiffies_clocksource(void)
 	return __clocksource_register(&clocksource_jiffies);
 }
 
-core_initcall(init_jiffies_clocksource);
+early_initcall(init_jiffies_clocksource);
 
 struct clocksource * __init __weak clocksource_default_clock(void)
 {
diff --git a/mm/slab.c b/mm/slab.c
index cc8bbc1e6bc9b6fe..f9b2f50adc705173 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -909,6 +909,8 @@ static int init_cache_node_node(int node)
 	return 0;
 }
 
+extern void rcu_dump_rcu_sched_tree(void);
+
 static int setup_kmem_cache_node(struct kmem_cache *cachep,
 				int node, gfp_t gfp, bool force_change)
 {
@@ -964,8 +966,19 @@ static int setup_kmem_cache_node(struct kmem_cache *cachep,
 	 * guaranteed to be valid until irq is re-enabled, because it will be
 	 * freed after synchronize_sched().
 	 */
-	if (force_change)
-		synchronize_sched();
+	if (force_change) {
+		static int cnt;
+
+		if (++cnt < 37) {
+printk("cnt = %d, sync\n", cnt);
+			synchronize_sched();
+		} else if (cnt == 37) {
+printk("cnt = %d, dump\n", cnt);
+			rcu_dump_rcu_sched_tree();
+		} else {
+printk("cnt = %d\n", cnt);
+		}
+	}
 
 fail:
 	kfree(old_shared);


With this it boots fine:

    ...
    cnt = 35, sync
    CPU: Testing write buffer coherency: ok
    CPU0: thread -1, cpu 0, socket 0, mpidr 80000000
    Setting up static identity map for 0x40100000 - 0x40100058
    cnt = 36, sync
    clocksource: jiffies: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 19112604462750000 ns
    CPU1: thread -1, cpu 1, socket 0, mpidr 80000001
    Brought up 2 CPUs
    SMP: Total of 2 processors activated (2132.00 BogoMIPS).
    CPU: All CPU(s) started in SVC mode.
    cnt = 37, dump
    RCU: rcu_sched GP kthread: c784e1c0 state: 1 flags: 0x0 g:-300 c:-300
	 jiffies: 0xffff8ad0  GP start: 0x0 Last GP activity: 0x0
    rcu_node tree layout dump
     0:1/0x0/0x3 ^0  
    RCU: rcu_sched GP kthread: c784e1c0 state: 1 flags: 0x0 g:-300 c:-300
	 jiffies: 0xffff8ad0  GP start: 0x0 Last GP activity: 0x0
    rcu_node tree layout dump
     0:1/0x0/0x3 ^0  
    devtmpfs: initialized
    VFP support v0.3: implementor 41 architecture 3 part 30 variant 9 rev 1
    cnt = 38
    cnt = 39
    ...

When enabling any of the 4 commented-out lines in rcu_dump_rcu_sched_tree(),
it will lock up.

Thanks!

Gr{oetje,eeting}s,

						Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
							    -- Linus Torvalds

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
