Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id DE87F6B0025
	for <linux-mm@kvack.org>; Fri, 20 May 2011 04:04:29 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 417AE3EE0C1
	for <linux-mm@kvack.org>; Fri, 20 May 2011 17:04:27 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 2114245DE5E
	for <linux-mm@kvack.org>; Fri, 20 May 2011 17:04:27 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 04EB445DE59
	for <linux-mm@kvack.org>; Fri, 20 May 2011 17:04:27 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id E4E04EF800B
	for <linux-mm@kvack.org>; Fri, 20 May 2011 17:04:26 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id A2363EF8001
	for <linux-mm@kvack.org>; Fri, 20 May 2011 17:04:26 +0900 (JST)
Message-ID: <4DD6207E.1070300@jp.fujitsu.com>
Date: Fri, 20 May 2011 17:04:14 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
MIME-Version: 1.0
Subject: [PATCH 4/5] oom: don't kill random process
References: <4DD61F80.1020505@jp.fujitsu.com>
In-Reply-To: <4DD61F80.1020505@jp.fujitsu.com>
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
oom-score=1 and then, oom killer ignore process memory usage
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
index d6b0424..b608b69 100644
--- a/fs/proc/base.c
+++ b/fs/proc/base.c
@@ -482,7 +482,7 @@ static int proc_oom_score(struct task_struct *task, char *buffer)

 	read_lock(&tasklist_lock);
 	if (pid_alive(task)) {
-		points = oom_badness(task, NULL, NULL, totalpages);
+		points = oom_badness(task, NULL, NULL, totalpages, 1);
 		ratio = points * 1000 / totalpages;
 	}
 	read_unlock(&tasklist_lock);
diff --git a/include/linux/oom.h b/include/linux/oom.h
index 0f5b588..3dd3669 100644
--- a/include/linux/oom.h
+++ b/include/linux/oom.h
@@ -42,7 +42,8 @@ enum oom_constraint {

 /* The badness from the OOM killer */
 extern unsigned long oom_badness(struct task_struct *p, struct mem_cgroup *mem,
-			const nodemask_t *nodemask, unsigned long totalpages);
+			const nodemask_t *nodemask, unsigned long totalpages,
+			int protect_root);
 extern int try_set_zonelist_oom(struct zonelist *zonelist, gfp_t gfp_flags);
 extern void clear_zonelist_oom(struct zonelist *zonelist, gfp_t gfp_flags);

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 8bbc3df..7d280d4 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -133,7 +133,8 @@ static bool oom_unkillable_task(struct task_struct *p,
  * task consuming the most memory to avoid subsequent oom failures.
  */
 unsigned long oom_badness(struct task_struct *p, struct mem_cgroup *mem,
-		      const nodemask_t *nodemask, unsigned long totalpages)
+			 const nodemask_t *nodemask, unsigned long totalpages,
+			 int protect_root)
 {
 	unsigned long points;
 	unsigned long score_adj = 0;
@@ -186,7 +187,7 @@ unsigned long oom_badness(struct task_struct *p, struct mem_cgroup *mem,
 	 *
 	 * XXX: Too large bonus, example, if the system have tera-bytes memory..
 	 */
-	if (has_capability_noaudit(p, CAP_SYS_ADMIN)) {
+	if (protect_root && has_capability_noaudit(p, CAP_SYS_ADMIN)) {
 		if (points >= totalpages / 32)
 			points -= totalpages / 32;
 		else
@@ -298,8 +299,11 @@ static struct task_struct *select_bad_process(unsigned long *ppoints,
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

@@ -332,7 +336,7 @@ static struct task_struct *select_bad_process(unsigned long *ppoints,
 			 */
 			if (p == current) {
 				chosen = p;
-				*ppoints = ULONG_MAX;
+				chosen_points = ULONG_MAX;
 			} else {
 				/*
 				 * If this task is not being ptraced on exit,
@@ -345,13 +349,49 @@ static struct task_struct *select_bad_process(unsigned long *ppoints,
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

@@ -467,11 +507,6 @@ static int oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
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

@@ -485,35 +520,11 @@ static int oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
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
