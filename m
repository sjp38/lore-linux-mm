Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id E37D28D003A
	for <linux-mm@kvack.org>; Tue, 15 Mar 2011 05:59:21 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id BA1DA3EE0BC
	for <linux-mm@kvack.org>; Tue, 15 Mar 2011 18:59:17 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 9A2BC45DE5E
	for <linux-mm@kvack.org>; Tue, 15 Mar 2011 18:59:17 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 6AB8045DE5A
	for <linux-mm@kvack.org>; Tue, 15 Mar 2011 18:59:17 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 5EA17E38001
	for <linux-mm@kvack.org>; Tue, 15 Mar 2011 18:59:17 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 1CBBDE08004
	for <linux-mm@kvack.org>; Tue, 15 Mar 2011 18:59:17 +0900 (JST)
Date: Tue, 15 Mar 2011 18:52:42 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH] fork bomb killer
Message-Id: <20110315185242.9533e65b.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, rientjes@google.com, Oleg Nesterov <oleg@redhat.com>, Andrey Vagin <avagin@openvz.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>

While testing Andrey's case, I confirmed I need to reboot the system by
power off when I ran a fork-bomb. The speed of fork() is much faster
than some smart killing as pkill(1) and oom-killer cannot reach the speed.

I wonder it's better to have a fork-bomb killer even if it's a just heuristic
method. This is a one. This one works fine with Andrey's case and I don't need
to reboot more. And I confirmed this can kill a case like

	while True:
		os.fork()

BTW, does usual man see fork-bomb in a production system ?
I saw only once which was caused be a shell script.

==
A fork bomb killer.

When fork-bomb runs, the system exhausts memory and we need to
reboot the system, in usual. The oom-killer or admin's killall
is slower than fork-bomb if system memory is exhausted.

So, fork-bomb-killer is appreciated even if it's a just heuristic.

This patch implements a heuristic for fork-bomb. The logic finds
a fork bomb which
 - has spawned 10+ tasks recently (10 min).
 - aggregate score of bomb is larger than the baddest task's badness.

When fork-bomb found,
 - new fork in the session under where fork bomb is will return -ENOMEM
   for the next 30secs.
 - all tasks of fork-bomb will be killed.

Note:
 - I wonder I shoud add a sysctl knob for this.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 include/linux/mm_types.h |    3 
 include/linux/oom.h      |    6 +
 include/linux/sched.h    |    6 +
 kernel/fork.c            |    2 
 mm/oom_kill.c            |  148 +++++++++++++++++++++++++++++++++++++++++++++++
 5 files changed, 165 insertions(+)

Index: mmotm-temp/include/linux/oom.h
===================================================================
--- mmotm-temp.orig/include/linux/oom.h
+++ mmotm-temp/include/linux/oom.h
@@ -62,6 +62,12 @@ static inline void oom_killer_enable(voi
 	oom_killer_disabled = false;
 }
 
+extern struct pid *fork_bomb_session;
+static inline bool in_fork_bomb(void)
+{
+	return task_session(current) == fork_bomb_session;
+}
+
 /* The badness from the OOM killer */
 extern unsigned long badness(struct task_struct *p, struct mem_cgroup *mem,
 		      const nodemask_t *nodemask, unsigned long uptime);
Index: mmotm-temp/kernel/fork.c
===================================================================
--- mmotm-temp.orig/kernel/fork.c
+++ mmotm-temp/kernel/fork.c
@@ -1417,6 +1417,8 @@ long do_fork(unsigned long clone_flags,
 			return -EPERM;
 	}
 
+	if (in_fork_bomb())
+		return -ENOMEM;
 	/*
 	 * When called from kernel_thread, don't do user tracing stuff.
 	 */
Index: mmotm-temp/mm/oom_kill.c
===================================================================
--- mmotm-temp.orig/mm/oom_kill.c
+++ mmotm-temp/mm/oom_kill.c
@@ -332,6 +332,150 @@ static struct task_struct *select_bad_pr
 	return chosen;
 }
 
+/*
+ * If there is a quick fork-bomb and it locks memory (allocating anon
+ * when nr_swap_pages==0), users feel very bad response and will not
+ * be able to recover because fork-bomb tend to be faster than killall
+ * and oom-kill. This is for killing a group of process which seems to
+ * be a fork-bomb.
+ *
+ * This can kill a fork-bomb when
+ *  - Threads in a bomb are enough young.(10min)
+ *  - The number of new process are enough large (10)
+ *
+ *  And this will prevent new fork() in the session for 30secs.
+ */
+#define FORK_BOMB_THRESH	(10*HZ)
+#define FORK_BOMB_RECOVER_JIFFIES	(30*HZ)
+
+struct pid *fork_bomb_session __read_mostly;
+static struct delayed_work forkbomb_timeout;
+
+static void clear_fork_bomb(struct work_struct *w)
+{
+	fork_bomb_session = NULL;
+}
+
+static bool is_ancestor(struct task_struct *t, struct task_struct *p)
+{
+	while (t != &init_task) {
+		if (t == p)
+			return true;
+		t = t->real_parent;
+	}
+	return false;
+}
+
+static bool fork_bomb_detection(unsigned long totalpages, struct mem_cgroup *mem,
+		const nodemask_t *nodemask)
+{
+	unsigned long start_time, fork_bomb_thresh, score, bomb_score;
+	struct task_struct *p, *t, *child, *bomb_task;
+	struct mm_struct *mm;
+	struct pid *bomb_session;
+	int family, bomb_family;
+
+	/* A forkbomb killer works and killing someone ? */
+	if (fork_bomb_session)
+		return true;
+
+	if (jiffies > FORK_BOMB_THRESH*10)
+		fork_bomb_thresh = jiffies/2;
+	else
+		fork_bomb_thresh = FORK_BOMB_THRESH;
+
+	bomb_task = NULL;
+	bomb_score = 0;
+	bomb_session = NULL;
+	bomb_family = 0;
+
+	for_each_process_reverse(p) {
+
+		start_time = timespec_to_jiffies(&p->start_time);
+		start_time += fork_bomb_thresh;
+		/* if the process is not young, ignore this */
+		if (time_after(start_time, jiffies))
+			break;
+		if (!p->mm || oom_unkillable_task(p, mem, nodemask))
+			continue;
+
+		score = oom_badness(p, mem, nodemask, totalpages);
+		/* the task itself is a burden for the system */
+		score += 1;
+		/* If this task has no children, we have no interests */
+		family = 1;
+		t = p;
+		do {
+			list_for_each_entry(child, &t->children, sibling) {
+				struct task_struct *temp;
+
+				/* Ignore task in other session */
+				if (task_session(child) != task_session(p))
+					continue;
+				/* All children are younger than p. */
+				temp = find_lock_task_mm(child);
+				if (temp) {
+					score += temp->mm->fork_bomb_score;
+					family += temp->mm->fork_bomb_family;
+					task_unlock(temp);
+				}
+			}
+		} while_each_thread(p, t);
+		/* Here, we have an aggregate score of a process tree */
+		p = find_lock_task_mm(p);
+		if (p) {
+			mm = p->mm;
+			mm->fork_bomb_score = score;
+			mm->fork_bomb_family = family;
+			task_unlock(p);
+		} else
+			continue;
+
+		if (bomb_score < score) {
+			bomb_task = p;
+			bomb_score = score;
+			bomb_family = family;
+			bomb_session = task_session(p);
+		}
+    	}
+	/* if a usual shell script run by a shell is found, ignore */
+	if (!bomb_task || bomb_family < 10)
+		return false;
+
+	fork_bomb_session = task_session(bomb_task);
+	INIT_DELAYED_WORK(&forkbomb_timeout, clear_fork_bomb);
+	schedule_delayed_work(&forkbomb_timeout, FORK_BOMB_RECOVER_JIFFIES);
+
+	/*
+	 * Now, we found a bomb task. kill all children of bomb_task.
+	 * and disallow new fork() in this session for a while.
+	 * If bomb_task is a session leader, don't kill it.
+	 */
+	pr_err("Possible fork-bomb. Killing all bomb threadsi\n");
+	pr_err("Killed all young children shares session of %d (%s)"
+		"aggregated badness %ld\n",
+		task_pid_nr(bomb_task), bomb_task->comm, bomb_score);
+
+	do_each_pid_task(bomb_session, PIDTYPE_SID, p) {
+
+		start_time = timespec_to_jiffies(&p->start_time);
+		start_time += fork_bomb_thresh;
+
+		if (!thread_group_leader(p))
+			continue;
+		if (oom_unkillable_task(p, mem, nodemask))
+			continue;
+		if (time_after(start_time, jiffies))
+			continue;
+		if (!is_ancestor(p, bomb_task))
+			continue;
+		pr_err("    kill %d(%s)\n", task_pid_nr(p), p->comm);
+		force_sig(SIGKILL, p);
+	} while_each_pid_task(bomb_session, PIDTYPE_SID, p);
+
+	return true;
+}
+
 /**
  * dump_tasks - dump current memory state of all system tasks
  * @mem: current's memory controller, if constrained
@@ -522,6 +666,8 @@ void mem_cgroup_out_of_memory(struct mem
 	check_panic_on_oom(CONSTRAINT_MEMCG, gfp_mask, 0, NULL);
 	limit = mem_cgroup_get_limit(mem) >> PAGE_SHIFT;
 	read_lock(&tasklist_lock);
+	if (fork_bomb_detection(limit, mem, NULL))
+		goto out;
 retry:
 	p = select_bad_process(&points, limit, mem, NULL);
 	if (!p || PTR_ERR(p) == -1UL)
@@ -698,6 +844,8 @@ void out_of_memory(struct zonelist *zone
 			goto out;
 	}
 
+	if (fork_bomb_detection(totalpages, NULL, mpol_mask))
+		goto out;
 retry:
 	p = select_bad_process(&points, totalpages, NULL, mpol_mask);
 	if (PTR_ERR(p) == -1UL)
Index: mmotm-temp/include/linux/mm_types.h
===================================================================
--- mmotm-temp.orig/include/linux/mm_types.h
+++ mmotm-temp/include/linux/mm_types.h
@@ -317,6 +317,9 @@ struct mm_struct {
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 	pgtable_t pmd_huge_pte; /* protected by page_table_lock */
 #endif
+	/* fork bomb detector */
+	unsigned int fork_bomb_score;
+	unsigned int fork_bomb_family;
 };
 
 /* Future-safe accessor for struct mm_struct's cpu_vm_mask. */
Index: mmotm-temp/include/linux/sched.h
===================================================================
--- mmotm-temp.orig/include/linux/sched.h
+++ mmotm-temp/include/linux/sched.h
@@ -2198,6 +2198,12 @@ static inline unsigned long wait_task_in
 #define for_each_process(p) \
 	for (p = &init_task ; (p = next_task(p)) != &init_task ; )
 
+/* can only be used under tasklist lock. This is heavy. */
+#define prev_task(p) \
+	list_entry((p)->tasks.prev, struct task_struct, tasks)
+#define for_each_process_reverse(p) \
+	for (p = &init_task; (p = prev_task(p)) != &init_task ; )
+
 extern bool current_is_single_threaded(void);
 
 /*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
