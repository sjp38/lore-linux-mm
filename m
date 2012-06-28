Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx118.postini.com [74.125.245.118])
	by kanga.kvack.org (Postfix) with SMTP id 802A26B005A
	for <linux-mm@kvack.org>; Wed, 27 Jun 2012 21:43:50 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so2830619pbb.14
        for <linux-mm@kvack.org>; Wed, 27 Jun 2012 18:43:49 -0700 (PDT)
Date: Wed, 27 Jun 2012 18:43:47 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [rfc][patch 3/3] mm, memcg: introduce own oom handler to iterate
 only over its own threads
In-Reply-To: <alpine.DEB.2.00.1206262229380.32567@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1206271837460.14446@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1206251846020.24838@chino.kir.corp.google.com> <alpine.DEB.2.00.1206251847180.24838@chino.kir.corp.google.com> <4FE94968.6010500@jp.fujitsu.com> <alpine.DEB.2.00.1206261323260.8673@chino.kir.corp.google.com>
 <alpine.DEB.2.00.1206262229380.32567@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan@kernel.org>, Oleg Nesterov <oleg@redhat.com>, linux-mm@kvack.org, cgroups@vger.kernel.org

On Tue, 26 Jun 2012, David Rientjes wrote:

> It turns out that task->children is not an rcu-protected list so this 
> doesn't work.  Both (1) and (3) can be accomplished with 
> rcu_read_{lock,unlock}() that can nest inside the tasklist_lock for the 
> global oom killer.  (We could even split the global oom killer tasklist 
> locking and optimize it seperately from this patchset.)
> 
> So we have a couple of options:
> 
>  - allow oom_kill_process() to do
> 
> 	if (memcg)
> 		read_lock(&tasklist_lock);
> 	...
> 	if (memcg)
> 		read_unlock(&tasklist_lock);
> 
>    around the iteration over the victim's children.  This should solve the 
>    issue since any other iteration over the entire tasklist would have 
>    triggered the same starvation if it were that bad, or
> 
>  - suppress the iteration for memcg ooms and just kill the parent instead.
> 

Adding Oleg for comment as well.

I did the first option but I split tasklist_lock for global oom conditions 
as well.  The only place we actually need it is when iterating the 
victim's children since that list is not rcu-protected.  If this happens 
to be too painful for parallel memcg ooms then we can look to protecting 
it, but it shouldn't be a problem for global ooms because of the global 
oom killer's zonelist serialization.

It's a tough patch to review, but the basics are that

 - oom_kill_process() is made to no longer need tasklist_lock; it's only
   taken for the iteration over children and everything else, including
   dump_header() is protected by rcu_read_lock() for kernels enabling
   /proc/sys/vm/oom_dump_tasks,

 - oom_kill_process() assumes that we have a reference to p, the victim,
   when it's called.  It can release this reference and grab a child's
   reference if necessary and drops it before returning, and

 - select_bad_process() does not require tasklist_lock, it gets
   protected by rcu_read_lock() as well.

Comments?

 memcontrol.c |    2 --
 oom_kill.c   |   33 ++++++++++++++++++++++-----------
 2 files changed, 22 insertions(+), 13 deletions(-)
---
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1522,10 +1522,8 @@ void __mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
 	if (!chosen)
 		return;
 	points = chosen_points * 1000 / totalpages;
-	read_lock(&tasklist_lock);
 	oom_kill_process(chosen, gfp_mask, order, points, totalpages, memcg,
 			 NULL, "Memory cgroup out of memory");
-	read_unlock(&tasklist_lock);
 	put_task_struct(chosen);
 }
 
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -336,7 +336,7 @@ enum oom_scan_t oom_scan_process_thread(struct task_struct *task,
 
 /*
  * Simple selection loop. We chose the process with the highest
- * number of 'points'. We expect the caller will lock the tasklist.
+ * number of 'points'.
  *
  * (not docbooked, we don't want this one cluttering up the manual)
  */
@@ -348,6 +348,7 @@ static struct task_struct *select_bad_process(unsigned int *ppoints,
 	struct task_struct *chosen = NULL;
 	unsigned long chosen_points = 0;
 
+	rcu_read_lock();
 	do_each_thread(g, p) {
 		unsigned int points;
 
@@ -370,6 +371,9 @@ static struct task_struct *select_bad_process(unsigned int *ppoints,
 			chosen_points = points;
 		}
 	} while_each_thread(g, p);
+	if (chosen)
+		get_task_struct(chosen);
+	rcu_read_unlock();
 
 	*ppoints = chosen_points * 1000 / totalpages;
 	return chosen;
@@ -385,8 +389,6 @@ static struct task_struct *select_bad_process(unsigned int *ppoints,
  * are not shown.
  * State information includes task's pid, uid, tgid, vm size, rss, cpu, oom_adj
  * value, oom_score_adj value, and name.
- *
- * Call with tasklist_lock read-locked.
  */
 static void dump_tasks(const struct mem_cgroup *memcg, const nodemask_t *nodemask)
 {
@@ -394,6 +396,7 @@ static void dump_tasks(const struct mem_cgroup *memcg, const nodemask_t *nodemas
 	struct task_struct *task;
 
 	pr_info("[ pid ]   uid  tgid total_vm      rss cpu oom_adj oom_score_adj name\n");
+	rcu_read_lock();
 	for_each_process(p) {
 		if (oom_unkillable_task(p, memcg, nodemask))
 			continue;
@@ -415,6 +418,7 @@ static void dump_tasks(const struct mem_cgroup *memcg, const nodemask_t *nodemas
 			task->signal->oom_score_adj, task->comm);
 		task_unlock(task);
 	}
+	rcu_read_unlock();
 }
 
 static void dump_header(struct task_struct *p, gfp_t gfp_mask, int order,
@@ -454,6 +458,7 @@ void oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
 	 */
 	if (p->flags & PF_EXITING) {
 		set_tsk_thread_flag(p, TIF_MEMDIE);
+		put_task_struct(p);
 		return;
 	}
 
@@ -471,6 +476,7 @@ void oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
 	 * parent.  This attempts to lose the minimal amount of work done while
 	 * still freeing memory.
 	 */
+	read_lock(&tasklist_lock);
 	do {
 		list_for_each_entry(child, &t->children, sibling) {
 			unsigned int child_points;
@@ -483,15 +489,23 @@ void oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
 			child_points = oom_badness(child, memcg, nodemask,
 								totalpages);
 			if (child_points > victim_points) {
+				put_task_struct(victim);
 				victim = child;
 				victim_points = child_points;
+				get_task_struct(victim);
 			}
 		}
 	} while_each_thread(p, t);
+	read_unlock(&tasklist_lock);
 
-	victim = find_lock_task_mm(victim);
-	if (!victim)
+	rcu_read_lock();
+	p = find_lock_task_mm(victim);
+	if (!p) {
+		rcu_read_unlock();
+		put_task_struct(victim);
 		return;
+	} else
+		victim = p;
 
 	/* mm cannot safely be dereferenced after task_unlock(victim) */
 	mm = victim->mm;
@@ -522,9 +536,11 @@ void oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
 			task_unlock(p);
 			do_send_sig_info(SIGKILL, SEND_SIG_FORCED, p, true);
 		}
+	rcu_read_unlock();
 
 	set_tsk_thread_flag(victim, TIF_MEMDIE);
 	do_send_sig_info(SIGKILL, SEND_SIG_FORCED, victim, true);
+	put_task_struct(victim);
 }
 #undef K
 
@@ -545,9 +561,7 @@ static void check_panic_on_oom(enum oom_constraint constraint, gfp_t gfp_mask,
 		if (constraint != CONSTRAINT_NONE)
 			return;
 	}
-	read_lock(&tasklist_lock);
 	dump_header(NULL, gfp_mask, order, NULL, nodemask);
-	read_unlock(&tasklist_lock);
 	panic("Out of memory: %s panic_on_oom is enabled\n",
 		sysctl_panic_on_oom == 2 ? "compulsory" : "system-wide");
 }
@@ -720,10 +734,10 @@ void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
 	mpol_mask = (constraint == CONSTRAINT_MEMORY_POLICY) ? nodemask : NULL;
 	check_panic_on_oom(constraint, gfp_mask, order, mpol_mask);
 
-	read_lock(&tasklist_lock);
 	if (sysctl_oom_kill_allocating_task &&
 	    !oom_unkillable_task(current, NULL, nodemask) &&
 	    current->mm) {
+		get_task_struct(current);
 		oom_kill_process(current, gfp_mask, order, 0, totalpages, NULL,
 				 nodemask,
 				 "Out of memory (oom_kill_allocating_task)");
@@ -734,7 +748,6 @@ void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
 	/* Found nothing?!?! Either we hang forever, or we panic. */
 	if (!p) {
 		dump_header(NULL, gfp_mask, order, NULL, mpol_mask);
-		read_unlock(&tasklist_lock);
 		panic("Out of memory and no killable processes...\n");
 	}
 	if (PTR_ERR(p) != -1UL) {
@@ -743,8 +756,6 @@ void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
 		killed = 1;
 	}
 out:
-	read_unlock(&tasklist_lock);
-
 	/*
 	 * Give "p" a good chance of killing itself before we
 	 * retry to allocate memory unless "p" is current

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
