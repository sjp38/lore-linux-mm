Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 92E8490016F
	for <linux-mm@kvack.org>; Wed, 22 Jun 2011 06:49:01 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id BDF803EE0B6
	for <linux-mm@kvack.org>; Wed, 22 Jun 2011 19:48:57 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id A048245DE8F
	for <linux-mm@kvack.org>; Wed, 22 Jun 2011 19:48:57 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 8644A45DE8E
	for <linux-mm@kvack.org>; Wed, 22 Jun 2011 19:48:57 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 7AEE11DB803F
	for <linux-mm@kvack.org>; Wed, 22 Jun 2011 19:48:57 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 364901DB803B
	for <linux-mm@kvack.org>; Wed, 22 Jun 2011 19:48:57 +0900 (JST)
Message-ID: <4E01C88E.3070806@jp.fujitsu.com>
Date: Wed, 22 Jun 2011 19:48:46 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
MIME-Version: 1.0
Subject: [PATCH 5/6] oom: don't kill random process
References: <4E01C7D5.3060603@jp.fujitsu.com>
In-Reply-To: <4E01C7D5.3060603@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kosaki.motohiro@jp.fujitsu.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, caiqian@redhat.com, rientjes@google.com, hughd@google.com, kamezawa.hiroyu@jp.fujitsu.com, minchan.kim@gmail.com, oleg@redhat.com

CAI Qian reported oom-killer killed all system daemons in his
system at first if he ran fork bomb as root. The problem is,
current logic give them bonus of 3% of system ram. Example,
he has 16GB machine, then root processes have ~500MB oom
immune. It bring us crazy bad result. _all_ processes have
oom-score=1 and then, oom killer ignore process memroy usage
and kill random process. This regression is caused by commit
a63d83f427 (oom: badness heuristic rewrite).

This patch changes select_bad_process() slightly. If oom points == 1,
it's a sign that the system have only root privileged processes or
similar. Thus, select_bad_process() calculate oom badness without
root bonus and select eligible process.

Also, this patch move finding sacrifice child logic into
select_bad_process(). It's necessary to implement adequate
no root bonus recalculation. and it makes good side effect,
current logic doesn't behave as the doc.

Documentation/sysctl/vm.txt says

    oom_kill_allocating_task

    If this is set to non-zero, the OOM killer simply kills the task that
    triggered the out-of-memory condition.  This avoids the expensive
    tasklist scan.

IOW, oom_kill_allocating_task shouldn't search sacrifice child.
This patch also fixes this issue.

Reported-by: CAI Qian <caiqian@redhat.com>
Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 fs/proc/base.c      |    2 +-
 include/linux/oom.h |    3 +-
 mm/oom_kill.c       |   89 ++++++++++++++++++++++++++++----------------------
 3 files changed, 53 insertions(+), 41 deletions(-)

diff --git a/fs/proc/base.c b/fs/proc/base.c
index 4a10763..5e4a8a1 100644
--- a/fs/proc/base.c
+++ b/fs/proc/base.c
@@ -485,7 +485,7 @@ static int proc_oom_score(struct task_struct *task, char *buffer)

 	read_lock(&tasklist_lock);
 	if (pid_alive(task)) {
-		points = oom_badness(task, NULL, NULL, totalpages);
+		points = oom_badness(task, NULL, NULL, totalpages, 1);
 		ratio = points * 1000 / totalpages;
 	}
 	read_unlock(&tasklist_lock);
diff --git a/include/linux/oom.h b/include/linux/oom.h
index 75b104c..272e3bb 100644
--- a/include/linux/oom.h
+++ b/include/linux/oom.h
@@ -43,7 +43,8 @@ enum oom_constraint {
 extern int test_set_oom_score_adj(int new_val);

 extern unsigned long oom_badness(struct task_struct *p, struct mem_cgroup *mem,
-			const nodemask_t *nodemask, unsigned long totalpages);
+			const nodemask_t *nodemask, unsigned long totalpages,
+			int protect_root);
 extern int try_set_zonelist_oom(struct zonelist *zonelist, gfp_t gfp_flags);
 extern void clear_zonelist_oom(struct zonelist *zonelist, gfp_t gfp_flags);

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index cff8000..cf48fd5 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -160,7 +160,8 @@ static bool oom_unkillable_task(struct task_struct *p,
  * task consuming the most memory to avoid subsequent oom failures.
  */
 unsigned long oom_badness(struct task_struct *p, struct mem_cgroup *mem,
-		      const nodemask_t *nodemask, unsigned long totalpages)
+			 const nodemask_t *nodemask, unsigned long totalpages,
+			 int protect_root)
 {
 	unsigned long points;
 	unsigned long score_adj = 0;
@@ -198,7 +199,7 @@ unsigned long oom_badness(struct task_struct *p, struct mem_cgroup *mem,
 	task_unlock(p);

 	/* Root processes get 3% bonus. */
-	if (task_euid(p) == 0) {
+	if (protect_root && task_euid(p) == 0) {
 		if (points >= totalpages / 32)
 			points -= totalpages / 32;
 		else
@@ -310,8 +311,11 @@ static struct task_struct *select_bad_process(unsigned long *ppoints,
 {
 	struct task_struct *g, *p;
 	struct task_struct *chosen = NULL;
-	*ppoints = 0;
+	int protect_root = 1;
+	unsigned long chosen_points = 0;
+	struct task_struct *child;

+ retry:
 	do_each_thread_reverse(g, p) {
 		unsigned long points;

@@ -344,7 +348,7 @@ static struct task_struct *select_bad_process(unsigned long *ppoints,
 			 */
 			if (p == current) {
 				chosen = p;
-				*ppoints = ULONG_MAX;
+				chosen_points = ULONG_MAX;
 			} else {
 				/*
 				 * If this task is not being ptraced on exit,
@@ -357,13 +361,49 @@ static struct task_struct *select_bad_process(unsigned long *ppoints,
 			}
 		}

-		points = oom_badness(p, mem, nodemask, totalpages);
-		if (points > *ppoints) {
+		points = oom_badness(p, mem, nodemask, totalpages, protect_root);
+		if (points > chosen_points) {
 			chosen = p;
-			*ppoints = points;
+			chosen_points = points;
 		}
 	} while_each_thread(g, p);

+	/*
+	 * chosen_point==1 may be a sign that root privilege bonus is too large
+	 * and we choose wrong task. Let's recalculate oom score without the
+	 * dubious bonus.
+	 */
+	if (protect_root && (chosen_points == 1)) {
+		protect_root = 0;
+		goto retry;
+	}
+
+	/*
+	 * If any of p's children has a different mm and is eligible for kill,
+	 * the one with the highest badness() score is sacrificed for its
+	 * parent.  This attempts to lose the minimal amount of work done while
+	 * still freeing memory.
+	 */
+	g = p = chosen;
+	do {
+		list_for_each_entry(child, &p->children, sibling) {
+			unsigned long child_points;
+
+			if (child->mm == p->mm)
+				continue;
+			/*
+			 * oom_badness() returns 0 if the thread is unkillable
+			 */
+			child_points = oom_badness(child, mem, nodemask,
+						   totalpages, protect_root);
+			if (child_points > chosen_points) {
+				chosen = child;
+				chosen_points = child_points;
+			}
+		}
+	} while_each_thread(g, p);
+
+	*ppoints = chosen_points;
 	return chosen;
 }

@@ -479,11 +519,6 @@ static int oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
 			    struct mem_cgroup *mem, nodemask_t *nodemask,
 			    const char *message)
 {
-	struct task_struct *victim = p;
-	struct task_struct *child;
-	struct task_struct *t = p;
-	unsigned long victim_points = 0;
-
 	if (printk_ratelimit())
 		dump_header(p, gfp_mask, order, mem, nodemask);

@@ -497,35 +532,11 @@ static int oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
 	}

 	task_lock(p);
-	pr_err("%s: Kill process %d (%s) points %lu or sacrifice child\n",
-		message, task_pid_nr(p), p->comm, points);
+	pr_err("%s: Kill process %d (%s) points %lu\n",
+	       message, task_pid_nr(p), p->comm, points);
 	task_unlock(p);

-	/*
-	 * If any of p's children has a different mm and is eligible for kill,
-	 * the one with the highest badness() score is sacrificed for its
-	 * parent.  This attempts to lose the minimal amount of work done while
-	 * still freeing memory.
-	 */
-	do {
-		list_for_each_entry(child, &t->children, sibling) {
-			unsigned long child_points;
-
-			if (child->mm == p->mm)
-				continue;
-			/*
-			 * oom_badness() returns 0 if the thread is unkillable
-			 */
-			child_points = oom_badness(child, mem, nodemask,
-								totalpages);
-			if (child_points > victim_points) {
-				victim = child;
-				victim_points = child_points;
-			}
-		}
-	} while_each_thread(p, t);
-
-	return oom_kill_task(victim, mem);
+	return oom_kill_task(p, mem);
 }

 /*
-- 
1.7.3.1



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
