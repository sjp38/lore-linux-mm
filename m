Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id A76B06B0038
	for <linux-mm@kvack.org>; Wed, 30 Nov 2016 09:30:01 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id m203so51248080wma.2
        for <linux-mm@kvack.org>; Wed, 30 Nov 2016 06:30:01 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id s5si7370652wma.130.2016.11.30.06.29.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Nov 2016 06:30:00 -0800 (PST)
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id uAUETSjI081590
	for <linux-mm@kvack.org>; Wed, 30 Nov 2016 09:29:59 -0500
Received: from e31.co.us.ibm.com (e31.co.us.ibm.com [32.97.110.149])
	by mx0b-001b2d01.pphosted.com with ESMTP id 271xk98krp-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 30 Nov 2016 09:29:58 -0500
Received: from localhost
	by e31.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Wed, 30 Nov 2016 07:29:57 -0700
Date: Wed, 30 Nov 2016 06:29:55 -0800
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: INFO: rcu_sched detected stalls on CPUs/tasks with `kswapd` and
 `mem_cgroup_shrink_node`
Reply-To: paulmck@linux.vnet.ibm.com
References: <20161121142901.GV3612@linux.vnet.ibm.com>
 <68025f6c-6801-ab46-b0fc-a9407353d8ce@molgen.mpg.de>
 <20161124101525.GB20668@dhcp22.suse.cz>
 <583AA50A.9010608@molgen.mpg.de>
 <20161128110449.GK14788@dhcp22.suse.cz>
 <109d5128-f3a4-4b6e-db17-7a1fcb953500@molgen.mpg.de>
 <29196f89-c35e-f79d-8e4d-2bf73fe930df@molgen.mpg.de>
 <20161130110944.GD18432@dhcp22.suse.cz>
 <20161130115320.GO3924@linux.vnet.ibm.com>
 <20161130131910.GF18432@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161130131910.GF18432@dhcp22.suse.cz>
Message-Id: <20161130142955.GS3924@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Donald Buczek <buczek@molgen.mpg.de>, Paul Menzel <pmenzel@molgen.mpg.de>, dvteam@molgen.mpg.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Josh Triplett <josh@joshtriplett.org>, peterz@infradead.org

On Wed, Nov 30, 2016 at 02:19:10PM +0100, Michal Hocko wrote:
> On Wed 30-11-16 03:53:20, Paul E. McKenney wrote:
> > On Wed, Nov 30, 2016 at 12:09:44PM +0100, Michal Hocko wrote:
> > > [CCing Paul]
> > > 
> > > On Wed 30-11-16 11:28:34, Donald Buczek wrote:
> > > [...]
> > > > shrink_active_list gets and releases the spinlock and calls cond_resched().
> > > > This should give other tasks a chance to run. Just as an experiment, I'm
> > > > trying
> > > > 
> > > > --- a/mm/vmscan.c
> > > > +++ b/mm/vmscan.c
> > > > @@ -1921,7 +1921,7 @@ static void shrink_active_list(unsigned long
> > > > nr_to_scan,
> > > >         spin_unlock_irq(&pgdat->lru_lock);
> > > > 
> > > >         while (!list_empty(&l_hold)) {
> > > > -               cond_resched();
> > > > +               cond_resched_rcu_qs();
> > > >                 page = lru_to_page(&l_hold);
> > > >                 list_del(&page->lru);
> > > > 
> > > > and didn't hit a rcu_sched warning for >21 hours uptime now. We'll see.
> > > 
> > > This is really interesting! Is it possible that the RCU stall detector
> > > is somehow confused?
> > 
> > No, it is not confused.  Again, cond_resched() is not a quiescent
> > state unless it does a context switch.  Therefore, if the task running
> > in that loop was the only runnable task on its CPU, cond_resched()
> > would -never- provide RCU with a quiescent state.
> 
> Sorry for being dense here. But why cannot we hide the QS handling into
> cond_resched()? I mean doesn't every current usage of cond_resched
> suffer from the same problem wrt RCU stalls?

We can, and you are correct that cond_resched() does not unconditionally
supply RCU quiescent states, and never has.  Last time I tried to add
cond_resched_rcu_qs() semantics to cond_resched(), I got told "no",
but perhaps it is time to try again.

One of the challenges is that there are two different timeframes.
If we want CONFIG_PREEMPT=n kernels to have millisecond-level scheduling
latencies, we need a cond_resched() more than once per millisecond, and
the usual uncertainties will mean more like once per hundred microseconds
or so.  In contrast, the occasional 100-millisecond RCU grace period when
under heavy load is normally not considered to be a problem, which means
that a cond_resched_rcu_qs() every 10 milliseconds or so is just fine.

Which means that cond_resched() is much more sensitive to overhead
than is cond_resched_rcu_qs().

No reason not to give it another try, though!  (Adding Peter Zijlstra
to CC for his reactions.)

Right now, the added overhead is a function call, two tests of per-CPU
variables, one increment of a per-CPU variable, and a barrier() before
and after.  I could probably combine the tests, but I do need at least
one test.  I cannot see how I can eliminate either barrier().  I might
be able to pull the increment under the test.

The patch below is instead very straightforward, avoiding any
optimizations.  Untested, probably does not even build.

Failing this approach, the rule is as follows:

1.	Add cond_resched() to in-kernel loops that cause excessive
	scheduling latencies.

2.	Add cond_resched_rcu_qs() to in-kernel loops that cause
	RCU CPU stall warnings.

							Thanx, Paul

> > In contrast, cond_resched_rcu_qs() unconditionally provides RCU
> > with a quiescent state (hence the _rcu_qs in its name), regardless
> > of whether or not a context switch happens.
> > 
> > It is therefore expected behavior that this change might prevent
> > RCU CPU stall warnings.

------------------------------------------------------------------------

commit d7100358d066cd7d64301a2da161390e9f4aa63f
Author: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
Date:   Wed Nov 30 06:24:30 2016 -0800

    sched,rcu: Make cond_resched() provide RCU quiescent state
    
    There is some confusion as to which of cond_resched() or
    cond_resched_rcu_qs() should be added to long in-kernel loops.
    This commit therefore eliminates the decision by adding RCU
    quiescent states to cond_resched().
    
    Warning: This is a prototype.  For example, it does not correctly
    handle Tasks RCU.  Which is OK for the moment, given that no one
    actually uses Tasks RCU yet.
    
    Reported-by: Michal Hocko <mhocko@kernel.org>
    Not-yet-signed-off-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
    Cc: Peter Zijlstra <peterz@infradead.org>

diff --git a/include/linux/sched.h b/include/linux/sched.h
index 348f51b0ec92..ccdb6064884e 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -3308,10 +3308,11 @@ static inline int signal_pending_state(long state, struct task_struct *p)
  * cond_resched_lock() will drop the spinlock before scheduling,
  * cond_resched_softirq() will enable bhs before scheduling.
  */
+void rcu_all_qs(void);
 #ifndef CONFIG_PREEMPT
 extern int _cond_resched(void);
 #else
-static inline int _cond_resched(void) { return 0; }
+static inline int _cond_resched(void) { rcu_all_qs(); return 0; }
 #endif
 
 #define cond_resched() ({			\
diff --git a/kernel/sched/core.c b/kernel/sched/core.c
index 94732d1ab00a..40b690813b80 100644
--- a/kernel/sched/core.c
+++ b/kernel/sched/core.c
@@ -4906,6 +4906,7 @@ int __sched _cond_resched(void)
 		preempt_schedule_common();
 		return 1;
 	}
+	rcu_all_qs();
 	return 0;
 }
 EXPORT_SYMBOL(_cond_resched);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
