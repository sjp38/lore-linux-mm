Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id 2DF926B0032
	for <linux-mm@kvack.org>; Tue, 16 Jul 2013 05:41:37 -0400 (EDT)
Date: Tue, 16 Jul 2013 10:41:31 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 18/18] sched: Swap tasks when reschuling if a CPU on a
 target node is imbalanced
Message-ID: <20130716094131.GG5055@suse.de>
References: <1373901620-2021-1-git-send-email-mgorman@suse.de>
 <1373901620-2021-19-git-send-email-mgorman@suse.de>
 <20130715201110.GO17211@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20130715201110.GO17211@twins.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, Jul 15, 2013 at 10:11:10PM +0200, Peter Zijlstra wrote:
> On Mon, Jul 15, 2013 at 04:20:20PM +0100, Mel Gorman wrote:
> > diff --git a/kernel/sched/core.c b/kernel/sched/core.c
> > index 53d8465..d679b01 100644
> > --- a/kernel/sched/core.c
> > +++ b/kernel/sched/core.c
> > @@ -4857,10 +4857,13 @@ fail:
> >  
> >  #ifdef CONFIG_NUMA_BALANCING
> >  /* Migrate current task p to target_cpu */
> > -int migrate_task_to(struct task_struct *p, int target_cpu)
> > +int migrate_task_to(struct task_struct *p, int target_cpu,
> > +		    struct task_struct *swap_p)
> >  {
> >  	struct migration_arg arg = { p, target_cpu };
> >  	int curr_cpu = task_cpu(p);
> > +	struct rq *rq;
> > +	int retval;
> >  
> >  	if (curr_cpu == target_cpu)
> >  		return 0;
> > @@ -4868,7 +4871,39 @@ int migrate_task_to(struct task_struct *p, int target_cpu)
> >  	if (!cpumask_test_cpu(target_cpu, tsk_cpus_allowed(p)))
> >  		return -EINVAL;
> >  
> > -	return stop_one_cpu(curr_cpu, migration_cpu_stop, &arg);
> > +	if (swap_p == NULL)
> > +		return stop_one_cpu(curr_cpu, migration_cpu_stop, &arg);
> > +
> > +	/* Make sure the target is still running the expected task */
> > +	rq = cpu_rq(target_cpu);
> > +	local_irq_disable();
> > +	raw_spin_lock(&rq->lock);
> 
> raw_spin_lock_irq() :-)
> 

damnit!

> > +	if (rq->curr != swap_p) {
> > +		raw_spin_unlock(&rq->lock);
> > +		local_irq_enable();
> > +		return -EINVAL;
> > +	}
> > +
> > +	/* Take a reference on the running task on the target cpu */
> > +	get_task_struct(swap_p);
> > +	raw_spin_unlock(&rq->lock);
> > +	local_irq_enable();
> 
> raw_spin_unlock_irq()
> 

Fixed.

> > +
> > +	/* Move current running task to target CPU */
> > +	retval = stop_one_cpu(curr_cpu, migration_cpu_stop, &arg);
> > +	if (raw_smp_processor_id() != target_cpu) {
> > +		put_task_struct(swap_p);
> > +		return retval;
> > +	}
> 
> (1)
> 
> > +	/* Move the remote task to the CPU just vacated */
> > +	local_irq_disable();
> > +	if (raw_smp_processor_id() == target_cpu)
> > +		__migrate_task(swap_p, target_cpu, curr_cpu);
> > +	local_irq_enable();
> > +
> > +	put_task_struct(swap_p);
> > +	return retval;
> >  }
> 
> So I know this is very much like what Ingo did in his patches, but
> there's a whole heap of 'problems' with this approach to task flipping.
> 
> So at (1) we just moved ourselves to the remote cpu. This might have
> left our original cpu idle and we might have done a newidle balance,
> even though we intend another task to run here.
> 

True. Minimally a parallel numa hinting fault that selected the source
nid as preferred nid might make the idle_cpu check and move there immediately

> At (1) we just moved ourselves to the remote cpu, however we might not
> be eligible to run, so moving the other task to our original CPU might
> take a while -- exacerbating the previously mention issue.
> 

Also true.

> Since (1) might take a whole lot of time, it might become rather
> unlikely that our task @swap_p is still queued on the cpu where we
> expected him to be.
> 

Which would hurt the intentions of patch 17.

hmm.

I did not want to do this lazily via the active load balancer because it
might never happen or by the time it did happen that it's no longer the
correct decision. This applied whether I set numa_preferred_nid or added
a numa_preferred_cpu.

What I think I can do is set a preferred CPU, wait until the next
wakeup and then move the task during select_task_rq as long as the load
balance permits. I cannot test it right now as all my test machines are
unplugged as part of a move but the patch against patch 17 is below.
Once p->numa_preferred_cpu exists then I should be able to lazily swap tasks
by setting p->numa_preferred_cpu.

Obviously untested and I need to give it more thought but this is the
general idea of what I mean.

diff --git a/include/linux/sched.h b/include/linux/sched.h
index 454ad2e..f388673 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1503,9 +1503,9 @@ struct task_struct {
 #ifdef CONFIG_NUMA_BALANCING
 	int numa_scan_seq;
 	int numa_migrate_seq;
+	int numa_preferred_cpu;
 	unsigned int numa_scan_period;
 	unsigned int numa_scan_period_max;
-	unsigned long numa_migrate_retry;
 	u64 node_stamp;			/* migration stamp  */
 	struct callback_head numa_work;
 
@@ -1604,6 +1604,14 @@ struct task_struct {
 #ifdef CONFIG_NUMA_BALANCING
 extern void task_numa_fault(int last_node, int node, int pages, bool migrated);
 extern void set_numabalancing_state(bool enabled);
+static inline int numa_preferred_cpu(struct task_struct *p)
+{
+	return p->numa_preferred_cpu;
+}
+static inline void reset_numa_preferred_cpu(struct task_struct *p)
+{
+	p->numa_preferred_cpu = -1;
+}
 #else
 static inline void task_numa_fault(int last_node, int node, int pages,
 				   bool migrated)
@@ -1612,6 +1620,14 @@ static inline void task_numa_fault(int last_node, int node, int pages,
 static inline void set_numabalancing_state(bool enabled)
 {
 }
+static inline int numa_preferred_cpu(struct task_struct *p)
+{
+	return -1;
+}
+
+static inline void reset_numa_preferred_cpu(struct task_struct *p)
+{
+}
 #endif
 
 static inline struct pid *task_pid(struct task_struct *task)
diff --git a/kernel/sched/core.c b/kernel/sched/core.c
index 53d8465..309a27d 100644
--- a/kernel/sched/core.c
+++ b/kernel/sched/core.c
@@ -1553,6 +1553,9 @@ int wake_up_state(struct task_struct *p, unsigned int state)
  */
 static void __sched_fork(struct task_struct *p)
 {
+#ifdef CONFIG_NUMA_BALANCING
+	p->numa_preferred_cpu		= -1;
+#endif
 	p->on_rq			= 0;
 
 	p->se.on_rq			= 0;
@@ -1591,6 +1594,7 @@ static void __sched_fork(struct task_struct *p)
 	p->node_stamp = 0ULL;
 	p->numa_scan_seq = p->mm ? p->mm->numa_scan_seq : 0;
 	p->numa_migrate_seq = 0;
+	p->numa_preferred_cpu = -1;
 	p->numa_scan_period = sysctl_numa_balancing_scan_delay;
 	p->numa_preferred_nid = -1;
 	p->numa_work.next = &p->numa_work;
diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index 07a9f40..21806b5 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -940,14 +940,14 @@ static void numa_migrate_preferred(struct task_struct *p)
 	int preferred_cpu = task_cpu(p);
 
 	/* Success if task is already running on preferred CPU */
-	p->numa_migrate_retry = 0;
+	p->numa_preferred_cpu = -1;
 	if (cpu_to_node(preferred_cpu) == p->numa_preferred_nid)
 		return;
 
 	/* Otherwise, try migrate to a CPU on the preferred node */
 	preferred_cpu = task_numa_find_cpu(p, p->numa_preferred_nid);
 	if (migrate_task_to(p, preferred_cpu) != 0)
-		p->numa_migrate_retry = jiffies + HZ*5;
+		p->numa_preferred_cpu = preferred_cpu;
 }
 
 static void task_numa_placement(struct task_struct *p)
@@ -1052,10 +1052,6 @@ void task_numa_fault(int last_nidpid, int node, int pages, bool migrated)
 
 	task_numa_placement(p);
 
-	/* Retry task to preferred node migration if it previously failed */
-	if (p->numa_migrate_retry && time_after(jiffies, p->numa_migrate_retry))
-		numa_migrate_preferred(p);
-
 	/* Record the fault, double the weight if pages were migrated */
 	p->numa_faults_buffer[task_faults_idx(node, priv)] += pages << migrated;
 }
@@ -3538,10 +3534,25 @@ select_task_rq_fair(struct task_struct *p, int sd_flag, int wake_flags)
 	int new_cpu = cpu;
 	int want_affine = 0;
 	int sync = wake_flags & WF_SYNC;
+	int numa_cpu;
 
 	if (p->nr_cpus_allowed == 1)
 		return prev_cpu;
 
+	/*
+	 * If a previous NUMA CPU migration failed then recheck now and use a
+	 * CPU near the preferred CPU if it would not introduce load imbalance.
+	 */
+	numa_cpu = numa_preferred_cpu(p);
+	if (numa_cpu != -1 && cpumask_test_cpu(numa_cpu, tsk_cpus_allowed(p))) {
+		int least_loaded_cpu;
+
+		reset_numa_preferred_cpu(p);
+		least_loaded_cpu = task_numa_find_cpu(p, cpu_to_node(numa_cpu));
+		if (least_loaded_cpu != prev_cpu)
+			return least_loaded_cpu;
+	}
+
 	if (sd_flag & SD_BALANCE_WAKE) {
 		if (cpumask_test_cpu(cpu, tsk_cpus_allowed(p)))
 			want_affine = 1;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
