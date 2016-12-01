Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f197.google.com (mail-wj0-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4BDED6B0069
	for <linux-mm@kvack.org>; Thu,  1 Dec 2016 13:42:58 -0500 (EST)
Received: by mail-wj0-f197.google.com with SMTP id j10so40616228wjb.3
        for <linux-mm@kvack.org>; Thu, 01 Dec 2016 10:42:58 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id g144si13150913wmg.12.2016.12.01.10.42.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Dec 2016 10:42:57 -0800 (PST)
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id uB1IcPtZ030316
	for <linux-mm@kvack.org>; Thu, 1 Dec 2016 13:42:55 -0500
Received: from e32.co.us.ibm.com (e32.co.us.ibm.com [32.97.110.150])
	by mx0b-001b2d01.pphosted.com with ESMTP id 272rfmbaaf-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 01 Dec 2016 13:42:55 -0500
Received: from localhost
	by e32.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Thu, 1 Dec 2016 11:42:54 -0700
Date: Thu, 1 Dec 2016 10:42:52 -0800
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: INFO: rcu_sched detected stalls on CPUs/tasks with `kswapd` and
 `mem_cgroup_shrink_node`
Reply-To: paulmck@linux.vnet.ibm.com
References: <20161130142955.GS3924@linux.vnet.ibm.com>
 <20161130163820.GQ3092@twins.programming.kicks-ass.net>
 <20161130170557.GK18432@dhcp22.suse.cz>
 <20161130175015.GR3092@twins.programming.kicks-ass.net>
 <20161130194019.GF3924@linux.vnet.ibm.com>
 <20161201053035.GC3092@twins.programming.kicks-ass.net>
 <20161201124024.GB3924@linux.vnet.ibm.com>
 <20161201163614.GL3092@twins.programming.kicks-ass.net>
 <20161201165918.GG3924@linux.vnet.ibm.com>
 <20161201180953.GO3045@worktop.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161201180953.GO3045@worktop.programming.kicks-ass.net>
Message-Id: <20161201184252.GP3924@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Michal Hocko <mhocko@kernel.org>, Donald Buczek <buczek@molgen.mpg.de>, Paul Menzel <pmenzel@molgen.mpg.de>, dvteam@molgen.mpg.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Josh Triplett <josh@joshtriplett.org>

On Thu, Dec 01, 2016 at 07:09:53PM +0100, Peter Zijlstra wrote:
> On Thu, Dec 01, 2016 at 08:59:18AM -0800, Paul E. McKenney wrote:
> > On Thu, Dec 01, 2016 at 05:36:14PM +0100, Peter Zijlstra wrote:
> > > Well, with the above change cond_resched() is already sufficient, no?
> > 
> > Maybe.  Right now, cond_resched_rcu_qs() gets a quiescent state to
> > the RCU core in less than one jiffy, with my other change, this becomes
> > a handful of jiffies depending on HZ and NR_CPUS.  I expect this
> > increase to a handful of jiffies to be a non-event.
> > 
> > After my upcoming patch, cond_resched() will get a quiescent state to
> > the RCU core in about ten seconds.  While I am am not all that nervous
> > about the increase from less than a jiffy to a handful of jiffies,
> > increasing to ten seconds via cond_resched() does make me quite nervous.
> > Past experience indicates that someone's kernel will likely be fatally
> > inconvenienced by this magnitude of change.
> > 
> > Or am I misunderstanding what you are proposing?
> 
> No, that is indeed what I was proposing. Hurm.. OK let me ponder that a
> bit. There might be a few games we can play with !PREEMPT to avoid IPIs.
> 
> Thing is, I'm slightly uncomfortable with de-coupling rcu-sched from
> actual schedule() calls.

OK, what is the source of your discomfort?

There are several intermediate levels of evasive action:

0.	If there is another runnable task and certain other conditions
	are met, cond_resched() will invoke schedule(), which will
	provide an RCU quiescent state.

1.	All cond_resched_rcu_qs() invocations increment the CPU's
	rcu_qs_ctr per-CPU variable, which is treated by later
	invocations of RCU core as a quiescent state.  (I have
	a patch queued that causes RCU to ignore changes to this
	counter until the grace period is a few jiffies old.)

	In this case, the rcu_node locks plus smp_mb__after_unlock_lock()
	provide the needed ordering.

2.	If any cond_resched_rcu_qs() sees that an expedited grace
	period is waiting on the current CPU, it invokes rcu_sched_qs()
	to force RCU to see the quiescent state.  (To your point,
	rcu_sched_qs() is normally called from schedule(), but also
	from the scheduling-clock interrupt when it interrupts
	usermode or idle.)

	Again, the rcu_node locks plus smp_mb__after_unlock_lock()
	provide the needed ordering.

3.	If the grace period extends for more than 50 milliseconds
	(by default, tunable), all subsequent cond_resched_rcu_qs()
	invocations on that CPU turn into momentary periods of
	idleness from RCU's viewpoint.  (Atomically add 2 to the
	dyntick-idle counter.)

	Here, the atomic increment is surrounded by smp_mb__*_atomic()
	to provide the needed ordering, which should be a good substitute
	for actually passing through schedule().

4.	If the grace period extends for more than 21 seconds (by default),
	we emit an RCU CPU stall warning and then do a resched_cpu().
	I am proposing also doing a resched_cpu() halfway to RCU CPU
	stall-warning time.

5.	An RCU-sched expedited grace period does a local resched_cpu()
	from its IPI handler to force the CPU through a quiescent
	state.  (Yes, I could just invoke resched_cpu() from the
	task orchestrating the expedited grace period, but this approach
	allows more common code between RCU-preempt and RCU-sched
	expedited grace periods.)

> > > In fact, by doing the IPI thing we get the entire cond_resched*()
> > > family, and we could add the should_resched() guard to
> > > cond_resched_rcu().
> > 
> > So that cond_resched_rcu_qs() looks something like this, in order
> > to avoid the function call in the case where the scheduler has nothing
> > to do?
> 
> I was actually thinking of this:

Oh!  I had forgotten about cond_resched_rcu(), and thought you did a typo.

Acked-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>

> diff --git a/include/linux/sched.h b/include/linux/sched.h
> index 2d0c82e1d348..2dc7d8056b2a 100644
> --- a/include/linux/sched.h
> +++ b/include/linux/sched.h
> @@ -3374,9 +3374,11 @@ static inline int signal_pending_state(long state, struct task_struct *p)
>  static inline void cond_resched_rcu(void)
>  {
>  #if defined(CONFIG_DEBUG_ATOMIC_SLEEP) || !defined(CONFIG_PREEMPT_RCU)
> -	rcu_read_unlock();
> -	cond_resched();
> -	rcu_read_lock();
> +	if (should_resched(1)) {
> +		rcu_read_unlock();
> +		cond_resched();
> +		rcu_read_lock();
> +	}
>  #endif
>  }
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
