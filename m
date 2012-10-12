Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id E02186B0044
	for <linux-mm@kvack.org>; Fri, 12 Oct 2012 04:29:45 -0400 (EDT)
Date: Fri, 12 Oct 2012 09:29:41 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 10/33] autonuma: CPU follows memory algorithm
Message-ID: <20121012082941.GR3317@csn.ul.ie>
References: <1349308275-2174-1-git-send-email-aarcange@redhat.com>
 <1349308275-2174-11-git-send-email-aarcange@redhat.com>
 <20121011145805.GW3317@csn.ul.ie>
 <20121012002513.GY1818@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20121012002513.GY1818@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <pzijlstr@redhat.com>, Ingo Molnar <mingo@elte.hu>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hillf Danton <dhillf@gmail.com>, Andrew Jones <drjones@redhat.com>, Dan Smith <danms@us.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, Paul Turner <pjt@google.com>, Christoph Lameter <cl@linux.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

On Fri, Oct 12, 2012 at 02:25:13AM +0200, Andrea Arcangeli wrote:
> On Thu, Oct 11, 2012 at 03:58:05PM +0100, Mel Gorman wrote:
> > On Thu, Oct 04, 2012 at 01:50:52AM +0200, Andrea Arcangeli wrote:
> > > This algorithm takes as input the statistical information filled by the
> > > knuma_scand (mm->mm_autonuma) and by the NUMA hinting page faults
> > > (p->task_autonuma), evaluates it for the current scheduled task, and
> > > compares it against every other running process to see if it should
> > > move the current task to another NUMA node.
> > > 
> > 
> > That sounds expensive if there are a lot of running processes in the
> > system. How often does this happen? Mention it here even though I
> > realised much later that it's obvious from the patch itself.
> 
> Ok I added:
> 
> ==
> This algorithm will run once every ~100msec,

~100msec (depending on the scheduler tick)

> and can be easily slowed
> down further

using the sysfs tunable ....

>. Its computational complexity is O(nr_cpus) and it's
> executed by all CPUs. The number of running threads and processes is
> not going to alter the cost of this algorithm, only the online number
> of CPUs is. However practically this will very rarely hit on all CPUs
> runqueues. Most of the time it will only compute on local data in the
> task_autonuma struct (for example if convergence has been
> reached). Even if no convergence has been reached yet, it'll only scan
> the CPUs in the NUMA nodes where the local task_autonuma data is
> showing that they are worth migrating to.

Ok, this explains how things are currently which is beter.

> ==
> 
> It's configurable through sysfs, 100mses is the default.
> 
> > > + * there is no affinity set for the task).
> > > + */
> > > +static bool inline task_autonuma_cpu(struct task_struct *p, int cpu)
> > > +{
> > 
> > nit, but elsewhere you have
> > 
> > static inline TYPE and here you have
> > static TYPE inline
> 
> Fixed.
> 
> > 
> > > +	int task_selected_nid;
> > > +	struct task_autonuma *task_autonuma = p->task_autonuma;
> > > +
> > > +	if (!task_autonuma)
> > > +		return true;
> > > +
> > > +	task_selected_nid = ACCESS_ONCE(task_autonuma->task_selected_nid);
> > > +	if (task_selected_nid < 0 || task_selected_nid == cpu_to_node(cpu))
> > > +		return true;
> > > +	else
> > > +		return false;
> > > +}
> > 
> > no need for else.
> 
> Removed.
> 
> > 
> > > +
> > > +static inline void sched_autonuma_balance(void)
> > > +{
> > > +	struct task_autonuma *ta = current->task_autonuma;
> > > +
> > > +	if (ta && current->mm)
> > > +		__sched_autonuma_balance();
> > > +}
> > > +
> > 
> > Ok, so this could do with a comment explaining where it is called from.
> > It is called during idle balancing at least so potentially this is every
> > scheduler tick. It'll be run from softirq context so the cost will not
> > be obvious to a process but the overhead will be there. What happens if
> > this takes longer than a scheduler tick to run? Is that possible?
> 
> softirqs can run for huge amount of time so it won't harm.
> 

They're allowed, but it's not free. Its not a stopper but eventually
we'll want to get away with it.

> Nested IRQs could even run on top of the softirq, and they could take
> milliseconds too if they're hyper inefficient and we must still run
> perfectly rock solid (with horrible latency, but still stable).
> 
> I added:
> 
> /*
>  * This is called in the context of the SCHED_SOFTIRQ from
>  * run_rebalance_domains().
>  */
> 

Ok. A vague idea occurred to me while mulling this over that would avoid the
walk. I did not flesh this out at all so there will be major inaccuracies
but hopefully you'll get the general idea.

The scheduler already caches some information about domains such as
sd_llc storing a per-cpu basis a pointer to the highest shared domain
with the same lowest level cache.

It should be possible to cache on a per-NUMA node domain basis the
highest mm_numafault and task_mmfault and the PID within that domain 
in sd_numa_mostconverged with one entry per NUMA node. At a scheduling tick, the
current task does the for_each_online_node(), calculates its values,
them to sd_numa_mostconverged and updates the cache if necessary.

With the view to integrating this with CFQ better, this update should happen
in kernel/sched/fair.c in a function called update_convergence_stats()
or possibly even integrated within one of the existing CPU walkers
like nohz_idle_balance or maybe in idle_balance itself and moved out of
kernel/sched/numa.c.  It shouldn't migrate tasks at this point and
reduce the overhead in the idle balancer.

This should integrate the whole of the following block into CFQ.

        /*
         * Identify the NUMA node where this thread (task_struct), and
         * the process (mm_struct) as a whole, has the largest number
         * of NUMA faults.
         */

It then later considers doing the task exchange but only the
sd_numa_mostconverged values for each node are considered.
This gets rid of the
for_each_cpu_and(cpu, cpumask_of_node(nid), allowed) loop with the obvious
caveat that there is no guarantee that cached PID is eligible for exchange
but I expect that's rare (it could be mitigated by never caching pids
that are bound to a single node for example). This would make this block

        /*
         * Check the other NUMA nodes to see if there is a task we
         * should exchange places with.
         */

O(num_online_nodes()) instead of O(num_online_cpus()) and reduce
the cost of that path. It will converge slower, but only slightly slower,
as you only ever consider one task per node anyway after deciding which
one is the best.

Again, in the interest in integrating with CFQ further, this whole block
should then move to kernel/sched/fair.c , possibly within load_balance()
so they are working closer together.

That just leaves the task exchange part which can remain separate and
just called from load_balance() when autonuma is in use.

This is not a patch obviously but I think it's important to have some
sort of integrating path with CFQ in mind.

> > > +/*
> > > + * This function __sched_autonuma_balance() is responsible for
> > 
> > This function is far too shot and could do with another few pages :P
> 
> :) I tried to split it once already but gave up in the middle.
> 

FWIW, the blocks are at least clear and it was easier to follow than I
expected.

> > > + * "Full convergence" is achieved when all memory accesses by a task
> > > + * are 100% local to the CPU it is running on. A task's "best node" is
> > 
> > I think this is the first time you defined convergence in the series.
> > The explanation should be included in the documentation.
> 
> Ok. It's not too easy concept to explain with words.  Here a try:
> 
>  *
>  * A workload converges when all the memory of a thread or a process
>  * has been placed in the NUMA node of the CPU where the process or
>  * thread is running on.
>  *
> 

Sounds right to me.

> > > + * other_diff: how much the current task is closer to fully converge
> > > + * on the node of the other CPU than the other task that is currently
> > > + * running in the other CPU.
> > 
> > In the changelog you talked about comparing a process with every other
> > running process but here it looks like you intent to examine every
> > process that is *currently running* on a remote node and compare that.
> > What if the best process to swap with is not currently running? Do we
> > miss it?
> 
> Correct, only currently running processes are being checked. If a task
> in R state goes to sleep immediately, it's not relevant where it
> runs. We focus on "long running" compute tasks, so tasks that are in R
> state most frequently.
> 

Ok, so it can still miss some things but we're trying to reduce the
overhead, not increase it. If the most and worst PIDS were cached as I
described above they could be updated either on the idle balancing (and
potentially miss tasks like this does) or if high granularity was every
required it could be done on every reschedule. It's one call for a
relatively light function. I don't think it's necessary to have this
fine granularity though.

> > > + * If both checks succeed it guarantees that we found a way to
> > > + * multilaterally improve the system wide NUMA
> > > + * convergence. Multilateral here means that the same checks will not
> > > + * succeed again on those same two tasks, after the task exchange, so
> > > + * there is no risk of ping-pong.
> > > + *
> > 
> > At least not in that instance of time. A new CPU binding or change in
> > behaviour (such as a computation finishing and a reduce step starting)
> > might change that scoring.
> 
> Yes.
> 
> > > + * If a task exchange can happen because the two checks succeed, we
> > > + * select the destination CPU that will give us the biggest increase
> > > + * in system wide convergence (i.e. biggest "weight", in the above
> > > + * quoted code).
> > > + *
> > 
> > So there is a bit of luck that the best task to exchange is currently
> > running. How bad is that? It depends really on the number of tasks
> > running on that node and the priority. There is a chance that it doesn't
> > matter as such because if all the wrong tasks are currently running then
> > no exchange will take place - it was just wasted CPU. It does imply that
> > AutoNUMA works best of CPUs are not over-subscribed with processes. Is
> > that fair?
> 
> It seems to works fine with overcommit as well. specjbb x2 is
> converging fine, as well as numa01 in parallel with numa02. It's
> actually pretty cool to watch.
> 
> Try to run this:
> 
> while :; do ./nmstat -n numa; sleep 1; done
> 
> nmstat is a binary in autonuma benchmark.
> 
> Then run:
> 
> time (./numa01 & ./numa02 & wait)
> 
> The thing is, we work together with CFS, CFS in autopilot works fine,
> we only need to correct the occasional error.
> 
> It works the same as the active idle balancing, that corrects the
> occasional error for HT cores left idle, then CFS takes over.
> 

Ok.

> > Again, I have no suggestions at all on how this might be improved and
> > these comments are hand-waving towards where we *might* see problems in
> > the future. If problems are actually identified in practice for
> > worklaods then autonuma can be turned off until the relevant problem
> > area is fixed.
> 
> Exactly, it's enough to run:
> 
> echo 1 >/sys/kernel/mm/autonuma/enabled
> 
> If you want to get rid of the 2 bytes per page too, passing
> "noautonuma" at boot will do it (but then /sys/kernel/mm/autonuma
> disapperers and you can't enable it anymore).
> 
> Plus if there's any issue with the cost of sched_autonuma_balance it's
> more than enough to run "perf top" to find out.
> 

Yep. I'm just trying to anticipate what the problems might be so when/if
I see a problem profile I'll have a rough idea what it might be due to.

> > I would fully expect that there are parallel workloads that work on
> > differenet portions of a large set of data and it would be perfectly
> > reasonable for threads using the same address space to converge on
> > different nodes.
> 
> Agreed. Even if they can't converge fully they could have stats like
> 70/30, 30/70, with 30 being numa-false-shared and we'll schedule them
> right, so running faster than upstream. That 30% will also tend to
> slowly distribute better over time.
> 

Ok

> > I would hope we manage to figure out a way to examine fewer processes,
> > not more :)
> 
> 8)))
> 
> > > +void __sched_autonuma_balance(void)
> > > +{
> > > +	int cpu, nid, selected_cpu, selected_nid, mm_selected_nid;
> > > +	int this_nid = numa_node_id();
> > > +	int this_cpu = smp_processor_id();
> > > +	unsigned long task_fault, task_tot, mm_fault, mm_tot;
> > > +	unsigned long task_max, mm_max;
> > > +	unsigned long weight_diff_max;
> > > +	long uninitialized_var(s_w_nid);
> > > +	long uninitialized_var(s_w_this_nid);
> > > +	long uninitialized_var(s_w_other);
> > > +	bool uninitialized_var(s_w_type_thread);
> > > +	struct cpumask *allowed;
> > > +	struct task_struct *p = current, *other_task;
> > 
> > So the task in question is current but this is called by the idle
> > balancer. I'm missing something obvious here but it's not clear to me why
> > that process is necessarily relevant. What guarantee is there that all
> > tasks will eventually run this code? Maybe it doesn't matter because the
> > most CPU intensive tasks are also the most likely to end up in here but
> > a clarification would be nice.
> 
> Exactly. We only focus on who is significantly computing. If a task
> runs for 1msec we can't possibly care where it runs and where the
> memory is. If it keeps running for 1msec, over time even that task
> will be migrated right.
> 

This limitation is fine, but it should be mentioned in a comment above
__sched_autonuma_balance() for the next person that reviews this in the
future.

> > > +	struct task_autonuma *task_autonuma = p->task_autonuma;
> > > +	struct mm_autonuma *mm_autonuma;
> > > +	struct rq *rq;
> > > +
> > > +	/* per-cpu statically allocated in runqueues */
> > > +	long *task_numa_weight;
> > > +	long *mm_numa_weight;
> > > +
> > > +	if (!task_autonuma || !p->mm)
> > > +		return;
> > > +
> > > +	if (!autonuma_enabled()) {
> > > +		if (task_autonuma->task_selected_nid != -1)
> > > +			task_autonuma->task_selected_nid = -1;
> > > +		return;
> > > +	}
> > > +
> > > +	allowed = tsk_cpus_allowed(p);
> > > +	mm_autonuma = p->mm->mm_autonuma;
> > > +
> > > +	/*
> > > +	 * If the task has no NUMA hinting page faults or if the mm
> > > +	 * hasn't been fully scanned by knuma_scand yet, set task
> > > +	 * selected nid to the current nid, to avoid the task bounce
> > > +	 * around randomly.
> > > +	 */
> > > +	mm_tot = ACCESS_ONCE(mm_autonuma->mm_numa_fault_tot);
> > 
> > Why ACCESS_ONCE?
> 
> mm variables are altered by other threads too. Only task_autonuma is
> local to this task and cannot change from under us.
> 
> I did it all lockless, I don't care if we're off once in a while.
> 

Mention why ACCESS_ONCE is used in a comment the first time it appears
in kernel/sched/numa.c. It's not necessary to mention it after that.

> > > +	if (!mm_tot) {
> > > +		if (task_autonuma->task_selected_nid != this_nid)
> > > +			task_autonuma->task_selected_nid = this_nid;
> > > +		return;
> > > +	}
> > > +	task_tot = task_autonuma->task_numa_fault_tot;
> > > +	if (!task_tot) {
> > > +		if (task_autonuma->task_selected_nid != this_nid)
> > > +			task_autonuma->task_selected_nid = this_nid;
> > > +		return;
> > > +	}
> > > +
> > > +	rq = cpu_rq(this_cpu);
> > > +
> > > +	/*
> > > +	 * Verify that we can migrate the current task, otherwise try
> > > +	 * again later.
> > > +	 */
> > > +	if (ACCESS_ONCE(rq->autonuma_balance))
> > > +		return;
> > > +
> > > +	/*
> > > +	 * The following two arrays will hold the NUMA affinity weight
> > > +	 * information for the current process if scheduled on the
> > > +	 * given NUMA node.
> > > +	 *
> > > +	 * mm_numa_weight[nid] - mm NUMA affinity weight for the NUMA node
> > > +	 * task_numa_weight[nid] - task NUMA affinity weight for the NUMA node
> > > +	 */
> > > +	task_numa_weight = rq->task_numa_weight;
> > > +	mm_numa_weight = rq->mm_numa_weight;
> > > +
> > > +	/*
> > > +	 * Identify the NUMA node where this thread (task_struct), and
> > > +	 * the process (mm_struct) as a whole, has the largest number
> > > +	 * of NUMA faults.
> > > +	 */
> > > +	task_max = mm_max = 0;
> > > +	selected_nid = mm_selected_nid = -1;
> > > +	for_each_online_node(nid) {
> > > +		mm_fault = ACCESS_ONCE(mm_autonuma->mm_numa_fault[nid]);
> > > +		task_fault = task_autonuma->task_numa_fault[nid];
> > > +		if (mm_fault > mm_tot)
> > > +			/* could be removed with a seqlock */
> > > +			mm_tot = mm_fault;
> > > +		mm_numa_weight[nid] = mm_fault*AUTONUMA_BALANCE_SCALE/mm_tot;
> > > +		if (task_fault > task_tot) {
> > > +			task_tot = task_fault;
> > > +			WARN_ON(1);
> > > +		}
> > > +		task_numa_weight[nid] = task_fault*AUTONUMA_BALANCE_SCALE/task_tot;
> > > +		if (mm_numa_weight[nid] > mm_max) {
> > > +			mm_max = mm_numa_weight[nid];
> > > +			mm_selected_nid = nid;
> > > +		}
> > > +		if (task_numa_weight[nid] > task_max) {
> > > +			task_max = task_numa_weight[nid];
> > > +			selected_nid = nid;
> > > +		}
> > > +	}
> > 
> > Ok, so this is a big walk to take every time and as this happens every
> > scheduler tick, it seems unlikely that the workload would be changing
> > phases that often in terms of NUMA behaviour. Would it be possible for
> > this to be sampled less frequently and cache the result?
> 
> Even if there are 8 nodes, this is fairly quick and only requires 2
> cachelines. At 16 nodes we're at 4 cachelines. The cacheline of
> task_autonuma is fully local. The one of mm_autonuma can be shared
> (modulo numa hinting page faults with atuonuma28, in autonuma27 it was
> also sharable even despite numa hinting page faults).
> 

Two cachelines that bounce though because of writes. I still don't
really like it but it can be lived with for now I guess, it's not my call
really. However, I'd like you to consider the suggestion above on how we
might create a per-NUMA scheduling domain cache of this information that
is only updated by a task if it scores "better" or "worse" than the current
cached value.

> > > +			/*
> > > +			 * Grab the fault/tot of the processes running
> > > +			 * in the other CPUs to compute w_other.
> > > +			 */
> > > +			raw_spin_lock_irq(&rq->lock);
> > > +			_other_task = rq->curr;
> > > +			/* recheck after implicit barrier() */
> > > +			mm = _other_task->mm;
> > > +			if (!mm) {
> > > +				raw_spin_unlock_irq(&rq->lock);
> > > +				continue;
> > > +			}
> > > +
> > 
> > Is it really critical to pin those values using the lock? That seems *really*
> > heavy. If the results have to be exactly stable then is there any chance
> > the values could be encoded in the high and low bits of a single unsigned
> > long and read without the lock?  Updates would be more expensive but that's
> > in a trap anyway. This on the other hand is a scheduler path.
> 
> The reason of the lock is to prevent rq->curr, mm etc.. to be freed
> from under us.
> 

Crap, yes.

> > > +			/*
> > > +			 * Check if the _other_task is allowed to be
> > > +			 * migrated to this_cpu.
> > > +			 */
> > > +			if (!cpumask_test_cpu(this_cpu,
> > > +					      tsk_cpus_allowed(_other_task))) {
> > > +				raw_spin_unlock_irq(&rq->lock);
> > > +				continue;
> > > +			}
> > > +
> > 
> > Would it not make sense to check this *before* we take the lock and
> > grab all its counters? It probably will not make much of a difference in
> > practice as I expect it's rare that the target CPU is running a task
> > that can't migrate but it still feels the wrong way around.
> 
> It's a micro optimization to do it here. It's too rare that the above
> fails, while !tot may be zero much more frequently (like if the task
> has been just started).
> 

Ok.

> > > +	if (selected_cpu != this_cpu) {
> > > +		if (autonuma_debug()) {
> > > +			char *w_type_str;
> > > +			w_type_str = s_w_type_thread ? "thread" : "process";
> > > +			printk("%p %d - %dto%d - %dto%d - %ld %ld %ld - %s\n",
> > > +			       p->mm, p->pid, this_nid, selected_nid,
> > > +			       this_cpu, selected_cpu,
> > > +			       s_w_other, s_w_nid, s_w_this_nid,
> > > +			       w_type_str);
> > > +		}
> > 
> > Can these be made tracepoints and get rid of the autonuma_debug() check?
> > I recognise there is a risk that some tool might grow to depend on
> > implementation details but in this case it seems very unlikely.
> 
> The debug mode provides me also a dump of all mm done racy, I wouldn't
> know how to do it with tracing.
> 

For live reporting on a terminal;

$ trace-cmd start -e autonuma:some_event_whatever_you_called_it
$ cat /sys/kernel/debug/tracing/trace_pipe
$ trace-cmd stop -e autonuma:some_event_whatever_you_called_it

you can record the trace using trace-cmd record but I suspect in this
case you want live reporting and I think this is the best way of doing
it.

> So I wouldn't remove the printk until we can replace everything with
> tracing, but I'd welcome to add a tracepoint too. There are already
> other proper tracepoints driving "perf script numatop".
> 

Good.

> > Ok, so I confess I did not work out if the weights and calculations really
> > make sense or not but at a glance they seem reasonable and I spotted no
> > obvious flaws. The function is pretty heavy though and may be doing more
> > work around locking than is really necessary. That said, there will be
> > workloads where the cost is justified and offset by the performance gains
> > from improved NUMA locality. I just don't expect it to be a universal win so
> > we'll need to keep an eye on the system CPU usage and incrementally optimise
> > where possible. I suspect there will be a time when an incremental
> > optimisation just does not cut it any more but by then I would also
> > expect there will be more data on how autonuma behaves in practice and a
> > new algorithm might be more obvious at that point.
> 
> Agreed. Chances are I can replace all this already with RCU and a
> rcu_dereference or ACCESS_ONCE to grab the rq->curr->task_autonuma and
> rq->curr->mm->mm_autonuma data. I didn't try yet. The task struct
> shouldn't go away from under us after rcu_read_lock, the mm may be more
> tricky, I haven't checked this yet. Optimizations welcome ;)
> 

Optimizations are limited to hand waving and no patches for the moment
:)

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
