Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 36D3F828E1
	for <linux-mm@kvack.org>; Wed, 29 Jun 2016 12:44:22 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id f126so53792900wma.3
        for <linux-mm@kvack.org>; Wed, 29 Jun 2016 09:44:22 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id cf5si5928584wjc.150.2016.06.29.09.44.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 Jun 2016 09:44:20 -0700 (PDT)
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u5TGd31i106183
	for <linux-mm@kvack.org>; Wed, 29 Jun 2016 12:44:19 -0400
Received: from e19.ny.us.ibm.com (e19.ny.us.ibm.com [129.33.205.209])
	by mx0b-001b2d01.pphosted.com with ESMTP id 23v097umst-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 29 Jun 2016 12:44:19 -0400
Received: from localhost
	by e19.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Wed, 29 Jun 2016 12:44:18 -0400
Received: from b01cxnp23032.gho.pok.ibm.com (b01cxnp23032.gho.pok.ibm.com [9.57.198.27])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 8E50138C804F
	for <linux-mm@kvack.org>; Wed, 29 Jun 2016 12:44:15 -0400 (EDT)
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by b01cxnp23032.gho.pok.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u5TGiIhq55771280
	for <linux-mm@kvack.org>; Wed, 29 Jun 2016 16:44:18 GMT
Received: from d01av01.pok.ibm.com (localhost [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u5TGiDF5009375
	for <linux-mm@kvack.org>; Wed, 29 Jun 2016 12:44:15 -0400
Date: Wed, 29 Jun 2016 09:44:15 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: Boot failure on emev2/kzm9d (was: Re: [PATCH v2 11/11] mm/slab:
 lockless decision to grow cache)
Reply-To: paulmck@linux.vnet.ibm.com
References: <20160621064302.GA20635@js1304-P5Q-DELUXE>
 <20160621125406.GF3923@linux.vnet.ibm.com>
 <20160622005208.GB25106@js1304-P5Q-DELUXE>
 <CAMuHMdW-wSxASozhmPh0b+9UJFFVbYHqTqH5e9P1oO7T59YE7g@mail.gmail.com>
 <20160622190859.GA1473@linux.vnet.ibm.com>
 <20160623004935.GA20752@linux.vnet.ibm.com>
 <20160623023756.GA30438@js1304-P5Q-DELUXE>
 <20160623024742.GD1473@linux.vnet.ibm.com>
 <20160623025329.GA13095@linux.vnet.ibm.com>
 <CAMuHMdVqNV5ZbR3_NV5ZsLxoNQUXXGpfAcaoMJffaJbRPUb6-A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAMuHMdVqNV5ZbR3_NV5ZsLxoNQUXXGpfAcaoMJffaJbRPUb6-A@mail.gmail.com>
Message-Id: <20160629164415.GG4650@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Geert Uytterhoeven <geert@linux-m68k.org>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Linux MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux-Renesas <linux-renesas-soc@vger.kernel.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>

On Wed, Jun 29, 2016 at 04:54:44PM +0200, Geert Uytterhoeven wrote:
> Hi Paul,
> 
> On Thu, Jun 23, 2016 at 4:53 AM, Paul E. McKenney
> <paulmck@linux.vnet.ibm.com> wrote:
> > On Wed, Jun 22, 2016 at 07:47:42PM -0700, Paul E. McKenney wrote:

[ . . . ]

> > @@ -4720,11 +4720,18 @@ static void __init rcu_dump_rcu_node_tree(struct rcu_state *rsp)
> >                         pr_info(" ");
> >                         level = rnp->level;
> >                 }
> > -               pr_cont("%d:%d ^%d  ", rnp->grplo, rnp->grphi, rnp->grpnum);
> > +               pr_cont("%d:%d/%#lx/%#lx ^%d  ", rnp->grplo, rnp->grphi,
> > +                       rnp->qsmask,
> > +                       rnp->qsmaskinit | rnp->qsmaskinitnext, rnp->grpnum);
> >         }
> >         pr_cont("\n");
> >  }
> 
> For me it always crashes during the 37th call of synchronize_sched() in
> setup_kmem_cache_node(), which is the first call after secondary CPU bring up.
> With your and my debug code, I get:
> 
>   CPU: Testing write buffer coherency: ok
>   CPU0: thread -1, cpu 0, socket 0, mpidr 80000000
>   Setting up static identity map for 0x40100000 - 0x40100058
>   cnt = 36, sync
>   CPU1: thread -1, cpu 1, socket 0, mpidr 80000001
>   Brought up 2 CPUs
>   SMP: Total of 2 processors activated (2132.00 BogoMIPS).
>   CPU: All CPU(s) started in SVC mode.
>   rcu_node tree layout dump
>    0:1/0x0/0x3 ^0

Thank you for running this!

OK, so RCU knows about both CPUs (the "0x3"), and the previous
grace period has seen quiescent states from both of them (the "0x0").
That would indicate that your synchronize_sched() showed up when RCU was
idle, so it had to start a new grace period.  It also rules out failure
modes where RCU thinks that there are more CPUs than really exist.
(Don't laugh, such things have really happened.)

>   devtmpfs: initialized
>   VFP support v0.3: implementor 41 architecture 3 part 30 variant 9 rev 1
>   clocksource: jiffies: mask: 0xffffffff max_cycles: 0xffffffff,
> max_idle_ns: 19112604462750000 ns
> 
> I hope it helps. Thanks!

I am going to guess that this was the first grace period since the second
CPU came online.  When there only on CPU online, synchronize_sched()
is a no-op.

OK, this showed some things that aren't a problem.  What might the
problem be?

o	The grace-period kthread has not yet started.  It -should- start
	at early_initcall() time, but who knows?  Adding code to print
	out that kthread's task_struct address.

o	The grace-period kthread might not be responding to wakeups.
	Checking this requires that a grace period be in progress,
	so please put a call_rcu_sched() just before the call to
	rcu_dump_rcu_node_tree().  (Sample code below.)  Adding code
	to my patch to print out more GP-kthread state as well.

o	One of the CPUs might not be responding to RCU.  That -should-
	result in an RCU CPU stall warning, so I will ignore this
	possibility for the moment.

	That said, do you have some way to determine whether scheduling
	clock interrupts are really happening?  Without these interrupts,
	no RCU CPU stall warnings.

OK, that should be enough for the next phase, please see the end for the
patch.  This patch applies on top of my previous one.

Could you please set this up as follows?

	struct rcu_head rh;

	rcu_dump_rcu_node_tree(&rcu_sched_state);  /* Initial state. */
	call_rcu(&rh, do_nothing_cb);
	schedule_timeout_uninterruptible(5 * HZ);  /* Or whatever delay. */
	rcu_dump_rcu_node_tree(&rcu_sched_state);  /* GP state. */
	synchronize_sched();  /* Probably hangs. */
	rcu_barrier();  /* Drop RCU's references to rh before return. */

							Thanx, Paul

------------------------------------------------------------------------

commit 82829ec76c2c0de18874a60ebd7ff8ee80f244d1
Author: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
Date:   Wed Jun 29 09:42:13 2016 -0700

    rcu: More diagnostics
    
    Signed-off-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>

diff --git a/kernel/rcu/tree.c b/kernel/rcu/tree.c
index 2eda7bece401..ff55c569473c 100644
--- a/kernel/rcu/tree.c
+++ b/kernel/rcu/tree.c
@@ -4712,6 +4712,11 @@ static void rcu_dump_rcu_node_tree(struct rcu_state *rsp)
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

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
