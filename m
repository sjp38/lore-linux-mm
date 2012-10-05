Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id 453566B0044
	for <linux-mm@kvack.org>; Fri,  5 Oct 2012 07:56:03 -0400 (EDT)
Date: Fri, 5 Oct 2012 13:54:55 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 18/33] autonuma: teach CFS about autonuma affinity
Message-ID: <20121005115455.GH6793@redhat.com>
References: <1349308275-2174-1-git-send-email-aarcange@redhat.com>
 <1349308275-2174-19-git-send-email-aarcange@redhat.com>
 <1349419285.6984.98.camel@marge.simpson.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1349419285.6984.98.camel@marge.simpson.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Galbraith <efault@gmx.de>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <pzijlstr@redhat.com>, Ingo Molnar <mingo@elte.hu>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hillf Danton <dhillf@gmail.com>, Andrew Jones <drjones@redhat.com>, Dan Smith <danms@us.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, Paul Turner <pjt@google.com>, Christoph Lameter <cl@linux.com>, Suresh Siddha <suresh.b.siddha@intel.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Alex Shi <alex.shi@intel.com>, Mauricio Faria de Oliveira <mauricfo@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Don Morris <don.morris@hp.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>

On Fri, Oct 05, 2012 at 08:41:25AM +0200, Mike Galbraith wrote:
> On Thu, 2012-10-04 at 01:51 +0200, Andrea Arcangeli wrote: 
> > The CFS scheduler is still in charge of all scheduling decisions. At
> > times, however, AutoNUMA balancing will override them.
> > 
> > Generally, we'll just rely on the CFS scheduler to keep doing its
> > thing, while preferring the task's AutoNUMA affine node when deciding
> > to move a task to a different runqueue or when waking it up.
> 
> Why does AutoNuma fiddle with wakeup decisions _within_ a node?
> 
> pgbench intensely disliked me recently depriving it of migration routes
> in select_idle_sibling(), so AutoNuma saying NAK seems unlikely to make
> it or ilk any happier.

Preferring doesn't mean NAK. It means "search affine first" if there's
not, go the usual route like if autonuma was not there.

Here the code change to the select_idle_sibling() for reference. You
can see it still fallbacks into the first idle_target but it keeps
going and stops when the first NUMA affine idle target is found
according to task_autonuma_cpu().

Notably load and idle balancing decisions are never overridden or
NAKed: only a "preference" is added.

@@ -2658,6 +2662,7 @@ static int select_idle_sibling(struct task_struct *p, int target)
 	/*
 	 * Otherwise, iterate the domains and find an elegible idle cpu.
 	 */
+	idle_target = false;
 	sd = rcu_dereference(per_cpu(sd_llc, target));
 	for_each_lower_domain(sd) {
 		sg = sd->groups;
@@ -2671,9 +2676,18 @@ static int select_idle_sibling(struct task_struct *p, int target)
 					goto next;
 			}
 
-			target = cpumask_first_and(sched_group_cpus(sg),
-					tsk_cpus_allowed(p));
-			goto done;
+			for_each_cpu_and(i, sched_group_cpus(sg),
+					 tsk_cpus_allowed(p)) {
+				/* Find autonuma cpu only in idle group */
+				if (task_autonuma_cpu(p, i)) {
+					target = i;
+					goto done;
+				}
+				if (!idle_target) {
+					idle_target = true;
+					target = i;
+				}
+			}
 next:
 			sg = sg->next;
 		} while (sg != sd->groups);

In short there's no risk of regressions like it happened until 3.6-rc6
(I reverted that patch before it was reverted in 3.6-rc6).

> > For example, idle balancing, while looking into the runqueues of busy
> > CPUs, will first look for a task that "wants" to run on the NUMA node
> > of this idle CPU (one where task_autonuma_cpu() returns true).
> > 
> > Most of this is encoded in can_migrate_task becoming AutoNUMA aware
> > and running two passes for each balancing pass, the first NUMA aware,
> > and the second one relaxed.
> > 
> > Idle or newidle balancing is always allowed to fall back to scheduling
> > non-affine AutoNUMA tasks (ones with task_selected_nid set to another
> > node). Load_balancing, which affects fairness more than performance,
> > is only able to schedule against AutoNUMA affinity if the flag
> > /sys/kernel/mm/autonuma/scheduler/load_balance_strict is not set.
> > 
> > Tasks that haven't been fully profiled yet, are not affected by this
> > because their p->task_autonuma->task_selected_nid is still set to the
> > original value of -1 and task_autonuma_cpu will always return true in
> > that case.
> 
> Hm.  How does this profiling work for 1:N loads?  Once you need two or
> more nodes, there is no best node for the 1, so restricting it can only
> do harm.  For pgbench and ilk, loads of cross node traffic should mean
> the 1 is succeeding at keeping the N busy.

That resembles numa01 on the 8 node system. There are N threads
trashing over all the memory of 4 nodes, and another N threads
trashing over the memory of another 4 nodes. It still work massively
better than no autonuma.

If there are multiple threads their affinity will vary slighly and the
task_selected_nid will distribute (and if it doesn't distribute the
idle load balancing will still work perfectly as upstream).

If there's just one thread, so really 1:N, it doesn't matter in which
CPU of the 4 nodes we put it if it's the memory split is 25/25/25/25.

In short in those 1:N scenarios, it's usually better to just stick to
the last node it run on, and it does with AutoNUMA. This is why it's
better to have 1 task_selected_nid instead of 4. There may be level 3
caches for the node too and that will preserve them too.

See the update of task_selected_nid when no task exchange is done
(even when there are no statistics available yet), and also why I only
updated the below:

-       if (target == cpu && idle_cpu(cpu))
+       if (target == cpu && idle_cpu(cpu) && task_autonuma_cpu(p, cpu))

and not:

	if (target == prev_cpu && idle_cpu(prev_cpu))
		return prev_cpu;

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
