Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id BECB16B00CF
	for <linux-mm@kvack.org>; Sun,  1 Jul 2012 14:06:14 -0400 (EDT)
Message-ID: <4FF07CD4.1070101@redhat.com>
Date: Sun, 01 Jul 2012 12:37:40 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 22/40] autonuma: teach CFS about autonuma affinity
References: <1340888180-15355-1-git-send-email-aarcange@redhat.com> <1340888180-15355-23-git-send-email-aarcange@redhat.com>
In-Reply-To: <1340888180-15355-23-git-send-email-aarcange@redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hillf Danton <dhillf@gmail.com>, Dan Smith <danms@us.ibm.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Johannes Weiner <hannes@cmpxchg.org>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>, Alex Shi <alex.shi@intel.com>, Mauricio Faria de Oliveira <mauricfo@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Don Morris <don.morris@hp.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>

On 06/28/2012 08:56 AM, Andrea Arcangeli wrote:

> @@ -2621,6 +2622,8 @@ find_idlest_cpu(struct sched_group *group, struct task_struct *p, int this_cpu)
>   		load = weighted_cpuload(i);
>
>   		if (load<  min_load || (load == min_load&&  i == this_cpu)) {
> +			if (!task_autonuma_cpu(p, i))
> +				continue;
>   			min_load = load;
>   			idlest = i;
>   		}

Is it right to only consider CPUs on the "right" NUMA
node, or do we want to harvest idle time elsewhere as
a last resort?

After your change the comment above find_idlest_cpu
no longer matches what the function does!

                 if (load < min_load || (load == min_load && i == 
this_cpu)) {
                         min_load = load;
                         idlest = i;
                 }

Would it make sense for task_autonuma_cpu(p, i) to be
inside the if ( ) braces, since that is what you are
trying to do?

		if ((load < min_load || (load == min_load &&
			i == this_cpu)) && task_autonuma_cpu(p, i)) {

> @@ -2639,24 +2642,27 @@ static int select_idle_sibling(struct task_struct *p, int target)

These bits make sense.

>   	/*
>   	 * Otherwise, iterate the domains and find an elegible idle cpu.
>   	 */
> +	idle_target = false;
>   	sd = rcu_dereference(per_cpu(sd_llc, target));
>   	for_each_lower_domain(sd) {
>   		sg = sd->groups;
> @@ -2670,9 +2676,18 @@ static int select_idle_sibling(struct task_struct *p, int target)
>   					goto next;
>   			}
>
> -			target = cpumask_first_and(sched_group_cpus(sg),
> -					tsk_cpus_allowed(p));
> -			goto done;
> +			for_each_cpu_and(i, sched_group_cpus(sg),
> +						tsk_cpus_allowed(p)) {
> +				/* Find autonuma cpu only in idle group */
> +				if (task_autonuma_cpu(p, i)) {
> +					target = i;
> +					goto done;
> +				}
> +				if (!idle_target) {
> +					idle_target = true;
> +					target = i;
> +				}
> +			}

There already is a for loop right above this:

                         for_each_cpu(i, sched_group_cpus(sg)) {
                                 if (!idle_cpu(i))
                                         goto next;
                         }

It appears to loop over all the CPUs in a sched group, but
not really.  If the first CPU in the sched group is idle,
it will fall through.

If the first CPU in the sched group is not idle, we move
on to the next sched group, instead of looking at the
other CPUs in the sched group.

Peter, Ingo, what is the original code in select_idle_sibling
supposed to do?

That original for_each_cpu loop would make more sense if
it actually looped over each cpu in the group.

Then we could remember two targets. One idle target, and
one autonuma-compliant idle target.

If, after looping over the CPUs, we find no autonuma-compliant
target, we use the other idle target.

Does that make sense?

Am I overlooking something about how the way select_idle_sibling
is supposed to work?

> @@ -3195,6 +3217,8 @@ static int move_one_task(struct lb_env *env)
>   {
>   	struct task_struct *p, *n;
>
> +	env->flags |= LBF_NUMA;
> +numa_repeat:
>   	list_for_each_entry_safe(p, n,&env->src_rq->cfs_tasks, se.group_node) {
>   		if (throttled_lb_pair(task_group(p), env->src_rq->cpu, env->dst_cpu))
>   			continue;
> @@ -3209,8 +3233,14 @@ static int move_one_task(struct lb_env *env)
>   		 * stats here rather than inside move_task().
>   		 */
>   		schedstat_inc(env->sd, lb_gained[env->idle]);
> +		env->flags&= ~LBF_NUMA;
>   		return 1;
>   	}
> +	if (env->flags&  LBF_NUMA) {
> +		env->flags&= ~LBF_NUMA;
> +		goto numa_repeat;
> +	}
> +
>   	return 0;
>   }

Would it make sense to remember the first non-autonuma-compliant
task that can be moved, and keep searching for one that fits
autonuma's criteria further down the line?

Then, if you fail to find a good autonuma task in the first
iteration, you do not have to loop over the list a second time.

> @@ -3235,6 +3265,8 @@ static int move_tasks(struct lb_env *env)
>   	if (env->imbalance<= 0)
>   		return 0;
>
> +	env->flags |= LBF_NUMA;
> +numa_repeat:

Same here.  Loops are bad enough, and it looks like it would
only cost one pointer on the stack to avoid numa_repeat :)

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
