Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id 935586B0267
	for <linux-mm@kvack.org>; Fri, 22 Jun 2012 17:45:23 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so5111040pbb.14
        for <linux-mm@kvack.org>; Fri, 22 Jun 2012 14:45:22 -0700 (PDT)
Date: Fri, 22 Jun 2012 14:45:21 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch] mm, oom: replace some information in tasklist dump
Message-ID: <alpine.DEB.2.00.1206221444370.23486@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org

The number of ptes and swap entries are used in the oom killer's badness
heuristic, so they should be shown in the tasklist dump.

This patch adds those fields and replaces cpu and oom_adj values that are
currently emitted.  Cpu isn't interesting and oom_adj is deprecated and
will be removed later this year, the same information is already
displayed as oom_score_adj which is used internally.

At the same time, make the documentation a little more clear to state
this information is helpful to determine why the oom killer chose the
task it did to kill.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 Documentation/sysctl/vm.txt |    7 ++++---
 mm/oom_kill.c               |   11 ++++++-----
 2 files changed, 10 insertions(+), 8 deletions(-)

diff --git a/Documentation/sysctl/vm.txt b/Documentation/sysctl/vm.txt
--- a/Documentation/sysctl/vm.txt
+++ b/Documentation/sysctl/vm.txt
@@ -502,9 +502,10 @@ oom_dump_tasks
 
 Enables a system-wide task dump (excluding kernel threads) to be
 produced when the kernel performs an OOM-killing and includes such
-information as pid, uid, tgid, vm size, rss, cpu, oom_adj score, and
-name.  This is helpful to determine why the OOM killer was invoked
-and to identify the rogue task that caused it.
+information as pid, uid, tgid, vm size, rss, nr_ptes, swapents,
+oom_score_adj score, and name.  This is helpful to determine why the
+OOM killer was invoked, to identify the rogue task that caused it,
+and to determine why the OOM killer chose the task it did to kill.
 
 If this is set to zero, this information is suppressed.  On very
 large systems with thousands of tasks it may not be feasible to dump
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -371,8 +371,8 @@ static struct task_struct *select_bad_process(unsigned int *ppoints,
  * Dumps the current memory state of all eligible tasks.  Tasks not in the same
  * memcg, not in the same cpuset, or bound to a disjoint set of mempolicy nodes
  * are not shown.
- * State information includes task's pid, uid, tgid, vm size, rss, cpu, oom_adj
- * value, oom_score_adj value, and name.
+ * State information includes task's pid, uid, tgid, vm size, rss, nr_ptes,
+ * swapents, oom_score_adj value, and name.
  *
  * Call with tasklist_lock read-locked.
  */
@@ -381,7 +381,7 @@ static void dump_tasks(const struct mem_cgroup *memcg, const nodemask_t *nodemas
 	struct task_struct *p;
 	struct task_struct *task;
 
-	pr_info("[ pid ]   uid  tgid total_vm      rss cpu oom_adj oom_score_adj name\n");
+	pr_info("[ pid ]   uid  tgid total_vm      rss nr_ptes swapents oom_score_adj name\n");
 	for_each_process(p) {
 		if (oom_unkillable_task(p, memcg, nodemask))
 			continue;
@@ -396,10 +396,11 @@ static void dump_tasks(const struct mem_cgroup *memcg, const nodemask_t *nodemas
 			continue;
 		}
 
-		pr_info("[%5d] %5d %5d %8lu %8lu %3u     %3d         %5d %s\n",
+		pr_info("[%5d] %5d %5d %8lu %8lu %7lu %8lu         %5d %s\n",
 			task->pid, from_kuid(&init_user_ns, task_uid(task)),
 			task->tgid, task->mm->total_vm, get_mm_rss(task->mm),
-			task_cpu(task), task->signal->oom_adj,
+			task->mm->nr_ptes,
+			get_mm_counter(task->mm, MM_SWAPENTS),
 			task->signal->oom_score_adj, task->comm);
 		task_unlock(task);
 	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
