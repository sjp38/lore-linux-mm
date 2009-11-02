Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 23CA96B0062
	for <linux-mm@kvack.org>; Mon,  2 Nov 2009 02:29:53 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nA27To6l004341
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 2 Nov 2009 16:29:50 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 0E73845DE51
	for <linux-mm@kvack.org>; Mon,  2 Nov 2009 16:29:50 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id E112C45DE4F
	for <linux-mm@kvack.org>; Mon,  2 Nov 2009 16:29:49 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id C2A4D1DB803A
	for <linux-mm@kvack.org>; Mon,  2 Nov 2009 16:29:49 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 68F2D1DB803C
	for <linux-mm@kvack.org>; Mon,  2 Nov 2009 16:29:49 +0900 (JST)
Date: Mon, 2 Nov 2009 16:27:16 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][-mm][PATCH 4/6] oom-killer: fork bomb detector
Message-Id: <20091102162716.e7803741.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20091102162244.9425e49b.kamezawa.hiroyu@jp.fujitsu.com>
References: <20091102162244.9425e49b.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, aarcange@redhat.com, akpm@linux-foundation.org, minchan.kim@gmail.com, rientjes@google.com, vedran.furac@gmail.com, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>
List-ID: <linux-mm.kvack.org>

From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

This patch implements an easy fork-bomb detector.

Now, fork-bomb detecting logic checks sum of all children's total_vm. But
it tends to estimate badly and task lauchters are easily killed by mistake.

This patch uses new algorithm.

At first, check select_bad_process() to scan from the newest process.
For each process, if runtime is below FORK_BOMB_RUNTIME_THRESH(5min),
a process gets score +1 and adds sum all children score to itself.
By this, we can check size of recently created process tree.

If process tree is enough large (> 12.5% of nr_procs), we assume it as
fork-bomb and kill it. 12.5% seems small but we're under OOM situation
and this is not small number.

BTW, checking fork-bomb only at oom means that this check is done
only after most of processes are swapped out. Hmm..is there good
place to add a hook ?

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 include/linux/memcontrol.h |    5 +
 include/linux/mm_types.h   |    2 
 include/linux/sched.h      |    8 ++
 mm/memcontrol.c            |    7 ++
 mm/oom_kill.c              |  149 ++++++++++++++++++++++++++++++++++-----------
 5 files changed, 137 insertions(+), 34 deletions(-)

Index: mmotm-2.6.32-Nov2/include/linux/mm_types.h
===================================================================
--- mmotm-2.6.32-Nov2.orig/include/linux/mm_types.h
+++ mmotm-2.6.32-Nov2/include/linux/mm_types.h
@@ -289,6 +289,8 @@ struct mm_struct {
 #ifdef CONFIG_MMU_NOTIFIER
 	struct mmu_notifier_mm *mmu_notifier_mm;
 #endif
+	/* For OOM, fork-bomb detector */
+	unsigned long bomb_score;
 };
 
 /* Future-safe accessor for struct mm_struct's cpu_vm_mask. */
Index: mmotm-2.6.32-Nov2/include/linux/sched.h
===================================================================
--- mmotm-2.6.32-Nov2.orig/include/linux/sched.h
+++ mmotm-2.6.32-Nov2/include/linux/sched.h
@@ -2176,6 +2176,14 @@ static inline unsigned long wait_task_in
 #define for_each_process(p) \
 	for (p = &init_task ; (p = next_task(p)) != &init_task ; )
 
+/*
+ * This function is for scanning list in reverse order. But, this is not
+ * RCU safe. lock(tasklist_lock) should be held. This is good when you want to
+ * find younger processes early.
+ */
+#define for_each_process_reverse(p) \
+	list_for_each_entry_reverse(p, &init_task.tasks, tasks)
+
 extern bool current_is_single_threaded(void);
 
 /*
Index: mmotm-2.6.32-Nov2/mm/oom_kill.c
===================================================================
--- mmotm-2.6.32-Nov2.orig/mm/oom_kill.c
+++ mmotm-2.6.32-Nov2/mm/oom_kill.c
@@ -79,7 +79,6 @@ static unsigned long __badness(struct ta
 {
 	unsigned long points, cpu_time, run_time;
 	struct mm_struct *mm;
-	struct task_struct *child;
 	int oom_adj = p->signal->oom_adj;
 	struct task_cputime task_time;
 	unsigned long utime;
@@ -112,21 +111,6 @@ static unsigned long __badness(struct ta
 		return ULONG_MAX;
 
 	/*
-	 * Processes which fork a lot of child processes are likely
-	 * a good choice. We add half the vmsize of the children if they
-	 * have an own mm. This prevents forking servers to flood the
-	 * machine with an endless amount of children. In case a single
-	 * child is eating the vast majority of memory, adding only half
-	 * to the parents will make the child our kill candidate of choice.
-	 */
-	list_for_each_entry(child, &p->children, sibling) {
-		task_lock(child);
-		if (child->mm != mm && child->mm)
-			points += get_mm_rss(child->mm)/2 + 1;
-		task_unlock(child);
-	}
-
-	/*
 	 * CPU time is in tens of seconds and run time is in thousands
          * of seconds. There is no particular reason for this other than
          * that it turned out to work very well in practice.
@@ -262,24 +246,92 @@ static inline enum oom_constraint guess_
 #endif
 
 /*
+ * Easy fork-bomb detector.
+ */
+/* 5 minutes for non-forkbomb processes */
+#define FORK_BOMB_RUNTIME_THRESH (5 * 60)
+
+static bool check_fork_bomb(struct task_struct *p, int uptime, int nr_procs)
+{
+	struct task_struct *child;
+	int runtime = uptime - p->start_time.tv_sec;
+	int bomb_score;
+	struct mm_struct *mm;
+	bool ret = false;
+
+	if (runtime > FORK_BOMB_RUNTIME_THRESH)
+		return ret;
+	/*
+	 * Because we search from newer processes, we can calculate tree's score
+	 * just by calculating children's score.
+	 */
+	mm = get_task_mm(p);
+	if (!mm)
+		return ret;
+
+	bomb_score = 0;
+	list_for_each_entry(child, &p->children, sibling) {
+		task_lock(child);
+		if (child->mm && child->mm != mm)
+			bomb_score += child->mm->bomb_score;
+		task_unlock(child);
+	}
+	mm->bomb_score = bomb_score + 1;
+	/*
+	 * Now, we estimated the size of process tree, which is recently
+	 * created. If it's big, we treat it as fork-bomb. This is heuristics
+	 * but we set this as 12.5% of all procs we do scan.
+	 * This number may be a little small..but we're under OOM situation.
+	 *
+	 * Discussion: On HIGHMEM system, this number should be smaller ?..
+	 */
+	if (bomb_score > nr_procs/8) {
+		ret = true;
+		printk(KERN_WARNING "Possible fork-bomb detected : %d(%s)",
+			p->pid, p->comm);
+	}
+	mmput(mm);
+	return ret;
+}
+
+/*
  * Simple selection loop. We chose the process with the highest
  * number of 'points'. We expect the caller will lock the tasklist.
  *
  * (not docbooked, we don't want this one cluttering up the manual)
  */
+
 static struct task_struct *select_bad_process(unsigned long *ppoints,
-					      enum oom_constraint constraint,
-					      struct mem_cgroup *mem)
+	enum oom_constraint constraint, struct mem_cgroup *mem, int *fork_bomb)
 {
 	struct task_struct *p;
 	struct task_struct *chosen = NULL;
 	struct timespec uptime;
+	int nr_proc;
+
 	*ppoints = 0;
+	*fork_bomb = 0;
 
 	do_posix_clock_monotonic_gettime(&uptime);
-	for_each_process(p) {
+	switch (constraint) {
+	case CONSTRAINT_MEMCG:
+		/* This includes # of threads...but...*/
+		nr_proc = memory_cgroup_task_count(mem);
+		break;
+	default:
+		nr_proc = nr_processes();
+		break;
+	}
+	/*
+	 * We're under read_lock(&tasklist_lock). At OOM, what we doubt is
+	 * young processes....considring fork-bomb. Then, we scan task list
+	 * in reverse order. (This is safe because we're under lock.
+	 */
+	for_each_process_reverse(p) {
 		unsigned long points;
 
+		if (*ppoints == ULONG_MAX)
+			break;
 		/*
 		 * skip kernel threads and tasks which have already released
 		 * their mm.
@@ -324,11 +376,17 @@ static struct task_struct *select_bad_pr
 
 		if (p->signal->oom_adj == OOM_DISABLE)
 			continue;
-
-		points = __badness(p, uptime.tv_sec, constraint, mem);
-		if (points > *ppoints || !chosen) {
+		if (check_fork_bomb(p, uptime.tv_sec, nr_proc)) {
 			chosen = p;
-			*ppoints = points;
+			*ppoints = ULONG_MAX;
+			*fork_bomb = 1;
+		}
+		if (*ppoints < ULONG_MAX) {
+			points = __badness(p, uptime.tv_sec, constraint, mem);
+			if (points > *ppoints || !chosen) {
+				chosen = p;
+				*ppoints = points;
+			}
 		}
 	}
 
@@ -448,9 +506,17 @@ static int oom_kill_task(struct task_str
 	return 0;
 }
 
+static int is_forkbomb_family(struct task_struct *c, struct task_struct *p)
+{
+	for (c = c->real_parent; c != &init_task; c = c->real_parent)
+		if (c == p)
+			return 1;
+	return 0;
+}
+
 static int oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
-			    unsigned long points, struct mem_cgroup *mem,
-			    const char *message)
+		    unsigned long points, struct mem_cgroup *mem,int fork_bomb,
+		    const char *message)
 {
 	struct task_struct *c;
 
@@ -468,12 +534,25 @@ static int oom_kill_process(struct task_
 
 	printk(KERN_ERR "%s: kill process %d (%s) score %li or a child\n",
 					message, task_pid_nr(p), p->comm, points);
-
-	/* Try to kill a child first */
+	if (fork_bomb) {
+		printk(KERN_ERR "possible fork-bomb is detected. kill them\n");
+		/* We need to kill the youngest one, at least */
+		rcu_read_lock();
+		for_each_process_reverse(c) {
+			if (c == p)
+				break;
+			if (is_forkbomb_family(c, p)) {
+				oom_kill_task(c);
+				break;
+			}
+		}
+		rcu_read_unlock();
+	}
+	/* Try to kill a child first. If fork-bomb, kill all. */
 	list_for_each_entry(c, &p->children, sibling) {
 		if (c->mm == p->mm)
 			continue;
-		if (!oom_kill_task(c))
+		if (!oom_kill_task(c) && !fork_bomb)
 			return 0;
 	}
 	return oom_kill_task(p);
@@ -483,18 +562,19 @@ static int oom_kill_process(struct task_
 void mem_cgroup_out_of_memory(struct mem_cgroup *mem, gfp_t gfp_mask)
 {
 	unsigned long points = 0;
+	int fork_bomb = 0;
 	struct task_struct *p;
 
 	read_lock(&tasklist_lock);
 retry:
-	p = select_bad_process(&points, CONSTRAINT_MEMCG, mem);
+	p = select_bad_process(&points, CONSTRAINT_MEMCG, mem, &fork_bomb);
 	if (PTR_ERR(p) == -1UL)
 		goto out;
 
 	if (!p)
 		p = current;
 
-	if (oom_kill_process(p, gfp_mask, 0, points, mem,
+	if (oom_kill_process(p, gfp_mask, 0, points, mem, fork_bomb,
 				"Memory cgroup out of memory"))
 		goto retry;
 out:
@@ -574,9 +654,10 @@ static void __out_of_memory(gfp_t gfp_ma
 {
 	struct task_struct *p;
 	unsigned long points;
+	int fork_bomb;
 
 	if (sysctl_oom_kill_allocating_task)
-		if (!oom_kill_process(current, gfp_mask, order, 0, NULL,
+		if (!oom_kill_process(current, gfp_mask, order, 0, NULL, 0,
 				"Out of memory (oom_kill_allocating_task)"))
 			return;
 retry:
@@ -584,7 +665,7 @@ retry:
 	 * Rambo mode: Shoot down a process and hope it solves whatever
 	 * issues we may have.
 	 */
-	p = select_bad_process(&points, constraint, NULL);
+	p = select_bad_process(&points, constraint, NULL, &fork_bomb);
 
 	if (PTR_ERR(p) == -1UL)
 		return;
@@ -596,7 +677,7 @@ retry:
 		panic("Out of memory and no killable processes...\n");
 	}
 
-	if (oom_kill_process(p, gfp_mask, order, points, NULL,
+	if (oom_kill_process(p, gfp_mask, order, points, NULL, fork_bomb,
 			     "Out of memory"))
 		goto retry;
 }
@@ -679,7 +760,7 @@ void out_of_memory(struct zonelist *zone
 
 	switch (constraint) {
 	case CONSTRAINT_MEMORY_POLICY:
-		oom_kill_process(current, gfp_mask, order, 0, NULL,
+		oom_kill_process(current, gfp_mask, order, 0, NULL, 0,
 				"No available memory (MPOL_BIND)");
 		break;
 	case CONSTRAINT_LOWMEM:
Index: mmotm-2.6.32-Nov2/include/linux/memcontrol.h
===================================================================
--- mmotm-2.6.32-Nov2.orig/include/linux/memcontrol.h
+++ mmotm-2.6.32-Nov2/include/linux/memcontrol.h
@@ -126,6 +126,7 @@ void mem_cgroup_update_file_mapped(struc
 unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order,
 						gfp_t gfp_mask, int nid,
 						int zid);
+int memory_cgroup_task_count(struct mem_cgroup *mem);
 #else /* CONFIG_CGROUP_MEM_RES_CTLR */
 struct mem_cgroup;
 
@@ -299,6 +300,10 @@ unsigned long mem_cgroup_soft_limit_recl
 	return 0;
 }
 
+static int memory_cgroup_task_count(struct mem_cgroup *mem)
+{
+	return 0;
+}
 #endif /* CONFIG_CGROUP_MEM_CONT */
 
 #endif /* _LINUX_MEMCONTROL_H */
Index: mmotm-2.6.32-Nov2/mm/memcontrol.c
===================================================================
--- mmotm-2.6.32-Nov2.orig/mm/memcontrol.c
+++ mmotm-2.6.32-Nov2/mm/memcontrol.c
@@ -1223,6 +1223,13 @@ static void record_last_oom(struct mem_c
 	mem_cgroup_walk_tree(mem, NULL, record_last_oom_cb);
 }
 
+int memory_cgroup_task_count(struct mem_cgroup *mem)
+{
+	struct cgroup *cg = mem->css.cgroup;
+
+	return cgroup_task_count(cg);
+}
+
 /*
  * Currently used to update mapped file statistics, but the routine can be
  * generalized to update other statistics as well.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
