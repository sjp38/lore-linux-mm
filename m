Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id D32C06B0038
	for <linux-mm@kvack.org>; Wed, 14 Dec 2016 11:15:44 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id s63so406860wms.7
        for <linux-mm@kvack.org>; Wed, 14 Dec 2016 08:15:44 -0800 (PST)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id j13si7912350wmf.109.2016.12.14.08.15.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Dec 2016 08:15:43 -0800 (PST)
Received: by mail-wm0-f65.google.com with SMTP id g23so199279wme.1
        for <linux-mm@kvack.org>; Wed, 14 Dec 2016 08:15:43 -0800 (PST)
Date: Wed, 14 Dec 2016 17:15:41 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Fw: [lkp-developer] [sched,rcu]  cf7a2dca60: [No primary change]
 +186% will-it-scale.time.involuntary_context_switches
Message-ID: <20161214161540.GP25573@dhcp22.suse.cz>
References: <20161213151408.GC3924@linux.vnet.ibm.com>
 <20161214095425.GE25573@dhcp22.suse.cz>
 <20161214110609.GK3924@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161214110609.GK3924@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, peterz@infradead.org

On Wed 14-12-16 03:06:09, Paul E. McKenney wrote:
> On Wed, Dec 14, 2016 at 10:54:25AM +0100, Michal Hocko wrote:
> > On Tue 13-12-16 07:14:08, Paul E. McKenney wrote:
> > > Just FYI for the moment...
> > > 
> > > So even with the slowed-down checking, making cond_resched() do what
> > > cond_resched_rcu_qs() does results in a smallish but quite measurable
> > > degradation according to 0day.
> > 
> > So if I understand those results properly, the reason seems to be the
> > increased involuntary context switches, right? Or am I misreading the
> > data?
> > I am looking at your "sched,rcu: Make cond_resched() provide RCU
> > quiescent state" in linux-next and I am wondering whether rcu_all_qs has
> > to be called unconditionally and not only when should_resched failed few
> > times? I guess you have discussed that with Peter already but do not
> > remember the outcome.
> 
> My first thought is to wait for the grace period to age further before
> checking, the idea being to avoid increasing cond_resched() overhead
> any further.  But if that doesn't work, then yes, I may have to look at
> adding more checks to cond_resched().

This might be really naive but would something like the following work?
The overhead should be pretty much negligible, I guess. Ideally the pcp
variable could be set somewhere from check_cpu_stall() but I couldn't
wrap my head around that code to see how exactly.
--- 
diff --git a/include/linux/rcutiny.h b/include/linux/rcutiny.h
index ac81e4063b40..1c005c5304a3 100644
--- a/include/linux/rcutiny.h
+++ b/include/linux/rcutiny.h
@@ -243,6 +243,10 @@ static inline void rcu_all_qs(void)
 	barrier(); /* Avoid RCU read-side critical sections leaking across. */
 }
 
+static inline void cond_resched_rcu_check(void)
+{
+}
+
 /* RCUtree hotplug events */
 #define rcutree_prepare_cpu      NULL
 #define rcutree_online_cpu       NULL
diff --git a/include/linux/rcutree.h b/include/linux/rcutree.h
index 63a4e4cf40a5..176f6e386379 100644
--- a/include/linux/rcutree.h
+++ b/include/linux/rcutree.h
@@ -110,6 +110,18 @@ extern int rcu_scheduler_active __read_mostly;
 bool rcu_is_watching(void);
 
 void rcu_all_qs(void);
+#ifndef CONFIG_PREEMPT
+DECLARE_PER_CPU(int, rcu_needs_qs);
+
+static inline void cond_resched_rcu_check(void)
+{
+	/* Make sure we do not miss rcu_all_qs at least every now and then */
+	if (this_cpu_inc_return(rcu_needs_qs) > 10) {
+		this_cpu_write(rcu_needs_qs, 0);
+		rcu_all_qs();
+	}
+}
+#endif
 
 /* RCUtree hotplug events */
 int rcutree_prepare_cpu(unsigned int cpu);
diff --git a/kernel/rcu/tree.c b/kernel/rcu/tree.c
index 69a5611a7e7c..783c74ae9930 100644
--- a/kernel/rcu/tree.c
+++ b/kernel/rcu/tree.c
@@ -268,6 +268,9 @@ void rcu_bh_qs(void)
 }
 
 static DEFINE_PER_CPU(int, rcu_sched_qs_mask);
+#ifndef CONFIG_PREEMPT
+DEFINE_PER_CPU(int, rcu_needs_qs);
+#endif
 
 static DEFINE_PER_CPU(struct rcu_dynticks, rcu_dynticks) = {
 	.dynticks_nesting = DYNTICK_TASK_EXIT_IDLE,
diff --git a/kernel/sched/core.c b/kernel/sched/core.c
index 154fd689fe02..a58844be2ef1 100644
--- a/kernel/sched/core.c
+++ b/kernel/sched/core.c
@@ -4905,6 +4905,8 @@ int __sched _cond_resched(void)
 	if (should_resched(0)) {
 		preempt_schedule_common();
 		return 1;
+	} else {
+		cond_resched_rcu_check();
 	}
 	return 0;
 }
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
