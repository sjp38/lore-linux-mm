Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id AC55D6B0069
	for <linux-mm@kvack.org>; Thu,  1 Dec 2016 13:10:00 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id q10so110003162pgq.7
        for <linux-mm@kvack.org>; Thu, 01 Dec 2016 10:10:00 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id w17si1014131pgf.262.2016.12.01.10.09.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Dec 2016 10:09:59 -0800 (PST)
Date: Thu, 1 Dec 2016 19:09:53 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: INFO: rcu_sched detected stalls on CPUs/tasks with `kswapd` and
 `mem_cgroup_shrink_node`
Message-ID: <20161201180953.GO3045@worktop.programming.kicks-ass.net>
References: <20161130131910.GF18432@dhcp22.suse.cz>
 <20161130142955.GS3924@linux.vnet.ibm.com>
 <20161130163820.GQ3092@twins.programming.kicks-ass.net>
 <20161130170557.GK18432@dhcp22.suse.cz>
 <20161130175015.GR3092@twins.programming.kicks-ass.net>
 <20161130194019.GF3924@linux.vnet.ibm.com>
 <20161201053035.GC3092@twins.programming.kicks-ass.net>
 <20161201124024.GB3924@linux.vnet.ibm.com>
 <20161201163614.GL3092@twins.programming.kicks-ass.net>
 <20161201165918.GG3924@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161201165918.GG3924@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: Michal Hocko <mhocko@kernel.org>, Donald Buczek <buczek@molgen.mpg.de>, Paul Menzel <pmenzel@molgen.mpg.de>, dvteam@molgen.mpg.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Josh Triplett <josh@joshtriplett.org>

On Thu, Dec 01, 2016 at 08:59:18AM -0800, Paul E. McKenney wrote:
> On Thu, Dec 01, 2016 at 05:36:14PM +0100, Peter Zijlstra wrote:
> > Well, with the above change cond_resched() is already sufficient, no?
> 
> Maybe.  Right now, cond_resched_rcu_qs() gets a quiescent state to
> the RCU core in less than one jiffy, with my other change, this becomes
> a handful of jiffies depending on HZ and NR_CPUS.  I expect this
> increase to a handful of jiffies to be a non-event.
> 
> After my upcoming patch, cond_resched() will get a quiescent state to
> the RCU core in about ten seconds.  While I am am not all that nervous
> about the increase from less than a jiffy to a handful of jiffies,
> increasing to ten seconds via cond_resched() does make me quite nervous.
> Past experience indicates that someone's kernel will likely be fatally
> inconvenienced by this magnitude of change.
> 
> Or am I misunderstanding what you are proposing?

No, that is indeed what I was proposing. Hurm.. OK let me ponder that a
bit. There might be a few games we can play with !PREEMPT to avoid IPIs.

Thing is, I'm slightly uncomfortable with de-coupling rcu-sched from
actual schedule() calls.

> > In fact, by doing the IPI thing we get the entire cond_resched*()
> > family, and we could add the should_resched() guard to
> > cond_resched_rcu().
> 
> So that cond_resched_rcu_qs() looks something like this, in order
> to avoid the function call in the case where the scheduler has nothing
> to do?

I was actually thinking of this:

diff --git a/include/linux/sched.h b/include/linux/sched.h
index 2d0c82e1d348..2dc7d8056b2a 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -3374,9 +3374,11 @@ static inline int signal_pending_state(long state, struct task_struct *p)
 static inline void cond_resched_rcu(void)
 {
 #if defined(CONFIG_DEBUG_ATOMIC_SLEEP) || !defined(CONFIG_PREEMPT_RCU)
-	rcu_read_unlock();
-	cond_resched();
-	rcu_read_lock();
+	if (should_resched(1)) {
+		rcu_read_unlock();
+		cond_resched();
+		rcu_read_lock();
+	}
 #endif
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
