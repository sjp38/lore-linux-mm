Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id BE9066B005A
	for <linux-mm@kvack.org>; Fri, 29 Jun 2012 14:04:27 -0400 (EDT)
Message-ID: <4FEDEE02.7060405@redhat.com>
Date: Fri, 29 Jun 2012 14:03:46 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 13/40] autonuma: CPU follow memory algorithm
References: <1340888180-15355-1-git-send-email-aarcange@redhat.com> <1340888180-15355-14-git-send-email-aarcange@redhat.com>
In-Reply-To: <1340888180-15355-14-git-send-email-aarcange@redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hillf Danton <dhillf@gmail.com>, Dan Smith <danms@us.ibm.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Johannes Weiner <hannes@cmpxchg.org>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>, Alex Shi <alex.shi@intel.com>, Mauricio Faria de Oliveira <mauricfo@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Don Morris <don.morris@hp.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>

On 06/28/2012 08:55 AM, Andrea Arcangeli wrote:
> This algorithm takes as input the statistical information filled by the
> knuma_scand (mm->mm_autonuma) and by the NUMA hinting page faults
> (p->sched_autonuma),

Somewhat confusing patch order, since the NUMA hinting page faults
appear to be later in the patch series.

At least the data structures got introduced earlier, albeit without
any documentation whatsoever (that needs fixing).

> evaluates it for the current scheduled task, and
> compares it against every other running process to see if it should
> move the current task to another NUMA node.

This is a little worrying. What if you are running on a system
with hundreds of NUMA nodes? How often does this code run?

> +static bool inline task_autonuma_cpu(struct task_struct *p, int cpu)
> +{
> +#ifdef CONFIG_AUTONUMA
> +	int autonuma_node;
> +	struct task_autonuma *task_autonuma = p->task_autonuma;
> +
> +	if (!task_autonuma)
> +		return true;
> +
> +	autonuma_node = ACCESS_ONCE(task_autonuma->autonuma_node);
> +	if (autonuma_node<  0 || autonuma_node == cpu_to_node(cpu))
> +		return true;
> +	else
> +		return false;
> +#else
> +	return true;
> +#endif
> +}

What is the return value of task_autonuma_cpu supposed
to represent?  It is not at all clear what this function
is trying to do...

> +#ifdef CONFIG_AUTONUMA
> +	/* this is used by the scheduler and the page allocator */
> +	struct mm_autonuma *mm_autonuma;
> +#endif
>   };

Great.  What is it used for, and how?
Why is that not documented?

> @@ -1514,6 +1514,9 @@ struct task_struct {
>   	struct mempolicy *mempolicy;	/* Protected by alloc_lock */
>   	short il_next;
>   	short pref_node_fork;
> +#ifdef CONFIG_AUTONUMA
> +	struct task_autonuma *task_autonuma;
> +#endif

This could use a comment,too.  I know task_struct has historically
been documented rather poorly, but it may be time to break that
tradition and add documentation.

> +/*
> + * autonuma_balance_cpu_stop() is a callback to be invoked by
> + * stop_one_cpu_nowait(). It is used by sched_autonuma_balance() to
> + * migrate the tasks to the selected_cpu, from softirq context.
> + */
> +static int autonuma_balance_cpu_stop(void *data)
> +{

Uhhh what?   It does not look like anything ends up stopped
as a result of this function running.

It looks like the function migrates a task to another NUMA
node, and always returns 0. Maybe void should be the return
type, and not the argument type?

It would be nice if the function name described what the
function does.

> +	struct rq *src_rq = data;

A void* as the function parameter, when you know what the
data pointer actually is?

Why are you doing this?

> +	int src_cpu = cpu_of(src_rq);
> +	int dst_cpu = src_rq->autonuma_balance_dst_cpu;
> +	struct task_struct *p = src_rq->autonuma_balance_task;

Why is the task to be migrated an item in the runqueue struct,
and not a function argument?

This seems backwards from the way things are usually done.
Not saying it is wrong, but doing things this way needs a good
explanation.

> +out_unlock:
> +	src_rq->autonuma_balance = false;
> +	raw_spin_unlock(&src_rq->lock);
> +	/* spinlocks acts as barrier() so p is stored local on the stack */

What race are you trying to protect against?

Surely the reason p continues to be valid is that you are
holding a refcount to the task?

> +	raw_spin_unlock_irq(&p->pi_lock);
> +	put_task_struct(p);
> +	return 0;
> +}

> +enum {
> +	W_TYPE_THREAD,
> +	W_TYPE_PROCESS,
> +};

What is W?  What is the difference between thread type
and process type Ws?

You wrote a lot of text describing sched_autonuma_balance(),
but none of it helps me understand what you are trying to do :(

> + * We run the above math on every CPU not part of the current NUMA
> + * node, and we compare the current process against the other
> + * processes running in the other CPUs in the remote NUMA nodes. The
> + * objective is to select the cpu (in selected_cpu) with a bigger
> + * "weight". The bigger the "weight" the biggest gain we'll get by
> + * moving the current process to the selected_cpu (not only the
> + * biggest immediate CPU gain but also the fewer async memory
> + * migrations that will be required to reach full convergence
> + * later). If we select a cpu we migrate the current process to it.

The one thing you have not described at all is what factors
go into the weight calculation, and why you are using those.

We can all read C and figure out what the code does, but
we need to know why.

What factors does the code use to weigh the NUMA nodes and processes?

Why are statistics kept both on a per process and a per thread basis?

What is the difference between those two?

What makes a particular NUMA node a good node for a thread to run on?

When is it worthwhile moving stuff around?

When is it not worthwhile?

> + * One non trivial bit of this logic that deserves an explanation is
> + * how the three crucial variables of the core math
> + * (w_nid/w_other/wcpu_nid) are going to change depending on whether
> + * the other CPU is running a thread of the current process, or a
> + * thread of a different process.

It would be nice to know what w_nid/w_other/w_cpu_nid mean.

You have a one-line description of them higher up in the comment,
but there is still no description at all of what factors go into
calculating the weights, or why...

> + * A simple example is required. Given the following:
> + * - 2 processes
> + * - 4 threads per process
> + * - 2 NUMA nodes
> + * - 4 CPUS per NUMA node
> + *
> + * Because the 8 threads belong to 2 different processes, by using the
> + * process statistics when comparing threads of different processes,
> + * we will converge reliably and quickly to a configuration where the
> + * 1st process is entirely contained in one node and the 2nd process
> + * in the other node.
> + *
> + * If all threads only use thread local memory (no sharing of memory
> + * between the threads), it wouldn't matter if we use per-thread or
> + * per-mm statistics for w_nid/w_other/w_cpu_nid. We could then use
> + * per-thread statistics all the time.
> + *
> + * But clearly with threads it's expected to get some sharing of
> + * memory. To avoid false sharing it's better to keep all threads of
> + * the same process in the same node (or if they don't fit in a single
> + * node, in as fewer nodes as possible). This is why we have to use
> + * processes statistics in w_nid/w_other/wcpu_nid when comparing
> + * threads of different processes. Why instead do we have to use
> + * thread statistics when comparing threads of the same process? This
> + * should be obvious if you're still reading

Nothing at all here is obvious, because you have not explained
what factors go into determining each weight.

You describe a lot of specific details, but are missing the
general overview that helps us make sense of things.

> +void sched_autonuma_balance(void)
> +{
> +	int cpu, nid, selected_cpu, selected_nid, selected_nid_mm;
> +	int cpu_nid = numa_node_id();
> +	int this_cpu = smp_processor_id();
> +	/*
> +	 * w_t: node thread weight
> +	 * w_t_t: total sum of all node thread weights
> +	 * w_m: node mm/process weight
> +	 * w_m_t: total sum of all node mm/process weights
> +	 */
> +	unsigned long w_t, w_t_t, w_m, w_m_t;
> +	unsigned long w_t_max, w_m_max;
> +	unsigned long weight_max, weight;
> +	long s_w_nid = -1, s_w_cpu_nid = -1, s_w_other = -1;
> +	int s_w_type = -1;
> +	struct cpumask *allowed;
> +	struct task_struct *p = current;
> +	struct task_autonuma *task_autonuma = p->task_autonuma;

Considering that p is always current, it may be better to just use
current throughout the function, that way people can see at a glance
that "p" cannot go away while the code is running, because current
is running the code on itself.

> +	/*
> +	 * The below two arrays holds the NUMA affinity information of
> +	 * the current process if scheduled in the "nid". This is task
> +	 * local and mm local information. We compute this information
> +	 * for all nodes.
> +	 *
> +	 * task/mm_numa_weight[nid] will become w_nid.
> +	 * task/mm_numa_weight[cpu_nid] will become w_cpu_nid.
> +	 */
> +	rq = cpu_rq(this_cpu);
> +	task_numa_weight = rq->task_numa_weight;
> +	mm_numa_weight = rq->mm_numa_weight;

It is a mystery to me why these items are allocated in the
runqueue structure. We have per-cpu allocations for things
like this, why are you adding them to the runqueue?

If there is a reason, you need to document it.

> +	w_t_max = w_m_max = 0;
> +	selected_nid = selected_nid_mm = -1;
> +	for_each_online_node(nid) {
> +		w_m = ACCESS_ONCE(p->mm->mm_autonuma->mm_numa_fault[nid]);
> +		w_t = task_autonuma->task_numa_fault[nid];
> +		if (w_m>  w_m_t)
> +			w_m_t = w_m;
> +		mm_numa_weight[nid] = w_m*AUTONUMA_BALANCE_SCALE/w_m_t;
> +		if (w_t>  w_t_t)
> +			w_t_t = w_t;
> +		task_numa_weight[nid] = w_t*AUTONUMA_BALANCE_SCALE/w_t_t;
> +		if (mm_numa_weight[nid]>  w_m_max) {
> +			w_m_max = mm_numa_weight[nid];
> +			selected_nid_mm = nid;
> +		}
> +		if (task_numa_weight[nid]>  w_t_max) {
> +			w_t_max = task_numa_weight[nid];
> +			selected_nid = nid;
> +		}
> +	}

What do the task and mm numa weights mean?

What factors go into calculating them?

Is it better to have a higher or a lower number? :)

We could use less documentation of what the code
does, and more explaining what the code is trying
to do, and why.


Under what circumstances do we continue into this loop?

What is it trying to do?

> +	for_each_online_node(nid) {
> +		/*
> +		 * Calculate the "weight" for all CPUs that the
> +		 * current process is allowed to be migrated to,
> +		 * except the CPUs of the current nid (it would be
> +		 * worthless from a NUMA affinity standpoint to
> +		 * migrate the task to another CPU of the current
> +		 * node).
> +		 */
> +		if (nid == cpu_nid)
> +			continue;
> +		for_each_cpu_and(cpu, cpumask_of_node(nid), allowed) {
> +			long w_nid, w_cpu_nid, w_other;
> +			int w_type;
> +			struct mm_struct *mm;
> +			rq = cpu_rq(cpu);
> +			if (!cpu_online(cpu))
> +				continue;
> +
> +			if (idle_cpu(cpu))
> +				/*
> +				 * Offload the while IDLE balancing
> +				 * and physical / logical imbalances
> +				 * to CFS.
> +				 */

			/* CFS idle balancing takes care of this */

> +				continue;
> +
> +			mm = rq->curr->mm;
> +			if (!mm)
> +				continue;
> +			/*
> +			 * Grab the w_m/w_t/w_m_t/w_t_t of the
> +			 * processes running in the other CPUs to
> +			 * compute w_other.
> +			 */
> +			raw_spin_lock_irq(&rq->lock);
> +			/* recheck after implicit barrier() */
> +			mm = rq->curr->mm;
> +			if (!mm) {
> +				raw_spin_unlock_irq(&rq->lock);
> +				continue;
> +			}
> +			w_m_t = ACCESS_ONCE(mm->mm_autonuma->mm_numa_fault_tot);
> +			w_t_t = rq->curr->task_autonuma->task_numa_fault_tot;
> +			if (!w_m_t || !w_t_t) {
> +				raw_spin_unlock_irq(&rq->lock);
> +				continue;
> +			}
> +			w_m = ACCESS_ONCE(mm->mm_autonuma->mm_numa_fault[nid]);
> +			w_t = rq->curr->task_autonuma->task_numa_fault[nid];
> +			raw_spin_unlock_irq(&rq->lock);

Is this why the info is stored in the runqueue struct?

How do we know the other runqueue's data is consistent?
We seem to be doing our own updates outside of the lock...

How do we know the other runqueue's data is up to date?
How often is this function run?

> +			/*
> +			 * Generate the w_nid/w_cpu_nid from the
> +			 * pre-computed mm/task_numa_weight[] and
> +			 * compute w_other using the w_m/w_t info
> +			 * collected from the other process.
> +			 */
> +			if (mm == p->mm) {

			if (mm == current->mm) {

> +				if (w_t>  w_t_t)
> +					w_t_t = w_t;
> +				w_other = w_t*AUTONUMA_BALANCE_SCALE/w_t_t;
> +				w_nid = task_numa_weight[nid];
> +				w_cpu_nid = task_numa_weight[cpu_nid];
> +				w_type = W_TYPE_THREAD;
> +			} else {
> +				if (w_m>  w_m_t)
> +					w_m_t = w_m;
> +				w_other = w_m*AUTONUMA_BALANCE_SCALE/w_m_t;
> +				w_nid = mm_numa_weight[nid];
> +				w_cpu_nid = mm_numa_weight[cpu_nid];
> +				w_type = W_TYPE_PROCESS;
> +			}

Wait, what?

Why is w_t used in one case, and w_m in the other?

Explaining the meaning of the two, and how each is used,
would help people understand this code.

> +			/*
> +			 * Finally check if there's a combined gain in
> +			 * NUMA affinity. If there is and it's the
> +			 * biggest weight seen so far, record its
> +			 * weight and select this NUMA remote "cpu" as
> +			 * candidate migration destination.
> +			 */
> +			if (w_nid>  w_other&&  w_nid>  w_cpu_nid) {
> +				weight = w_nid - w_other + w_nid - w_cpu_nid;

I read this as "check if moving the current task to the other CPU,
and moving its task away, would increase overall NUMA affinity".

Is that correct?

> +	stop_one_cpu_nowait(this_cpu,
> +			    autonuma_balance_cpu_stop, rq,
> +			&rq->autonuma_balance_work);
> +#ifdef __ia64__
> +#error "NOTE: tlb_migrate_finish won't run here"
> +#endif
> +}

So that is why the function is called autonuma_balance_cpu_stop?
Even though its function is to migrate a task?

What will happen in the IA64 case?
Memory corruption?
What would the IA64 maintainers have to do to make things work?

> diff --git a/kernel/sched/sched.h b/kernel/sched/sched.h
> index 6d52cea..e5b7ae9 100644
> --- a/kernel/sched/sched.h
> +++ b/kernel/sched/sched.h
> @@ -463,6 +463,24 @@ struct rq {
>   #ifdef CONFIG_SMP
>   	struct llist_head wake_list;
>   #endif
> +#ifdef CONFIG_AUTONUMA
> +	/*
> +	 * Per-cpu arrays to compute the per-thread and per-process
> +	 * statistics. Allocated statically to avoid overflowing the
> +	 * stack with large MAX_NUMNODES values.
> +	 *
> +	 * FIXME: allocate dynamically and with num_possible_nodes()
> +	 * array sizes only if autonuma is not impossible, to save
> +	 * some dozen KB of RAM when booting on not NUMA (or small
> +	 * NUMA) systems.
> +	 */

I have a second FIXME: document what these fields actually mean,
what they are used for, and why they are allocated as part of the
runqueue structure.

> +	long task_numa_weight[MAX_NUMNODES];
> +	long mm_numa_weight[MAX_NUMNODES];
> +	bool autonuma_balance;
> +	int autonuma_balance_dst_cpu;
> +	struct task_struct *autonuma_balance_task;
> +	struct cpu_stop_work autonuma_balance_work;
> +#endif


-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
