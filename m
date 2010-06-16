Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 512226B01C1
	for <linux-mm@kvack.org>; Wed, 16 Jun 2010 07:31:25 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o5GBVMP6005048
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 16 Jun 2010 20:31:23 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 7F5DA45DE4F
	for <linux-mm@kvack.org>; Wed, 16 Jun 2010 20:31:22 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 4DBEB45DE53
	for <linux-mm@kvack.org>; Wed, 16 Jun 2010 20:31:22 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id E85E2E08001
	for <linux-mm@kvack.org>; Wed, 16 Jun 2010 20:31:21 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id F14041DB805F
	for <linux-mm@kvack.org>; Wed, 16 Jun 2010 20:31:20 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH 2/9] oom: rename badness() to oom_badness()
In-Reply-To: <20100616201948.72D7.A69D9226@jp.fujitsu.com>
References: <20100616201948.72D7.A69D9226@jp.fujitsu.com>
Message-Id: <20100616202920.72DA.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed, 16 Jun 2010 20:31:20 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>


badness() is wrong name because it's too generic name. rename it.

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 fs/proc/base.c      |    4 +---
 include/linux/oom.h |    3 +++
 mm/oom_kill.c       |   13 ++++++-------
 3 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/fs/proc/base.c b/fs/proc/base.c
index 28099a1..d33c43c 100644
--- a/fs/proc/base.c
+++ b/fs/proc/base.c
@@ -427,8 +427,6 @@ static const struct file_operations proc_lstats_operations = {
 
 #endif
 
-/* The badness from the OOM killer */
-unsigned long badness(struct task_struct *p, unsigned long uptime);
 static int proc_oom_score(struct task_struct *task, char *buffer)
 {
 	unsigned long points = 0;
@@ -437,7 +435,7 @@ static int proc_oom_score(struct task_struct *task, char *buffer)
 	do_posix_clock_monotonic_gettime(&uptime);
 	read_lock(&tasklist_lock);
 	if (pid_alive(task))
-		points = badness(task, uptime.tv_sec);
+		points = oom_badness(task, uptime.tv_sec);
 	read_unlock(&tasklist_lock);
 	return sprintf(buffer, "%lu\n", points);
 }
diff --git a/include/linux/oom.h b/include/linux/oom.h
index 9d7c34a..4cd6b89 100644
--- a/include/linux/oom.h
+++ b/include/linux/oom.h
@@ -14,6 +14,7 @@
 
 struct zonelist;
 struct notifier_block;
+struct task_struct;
 
 /*
  * Types of limitations to the nodes from which allocations may occur
@@ -25,6 +26,8 @@ enum oom_constraint {
 	CONSTRAINT_MEMCG,
 };
 
+
+extern unsigned long oom_badness(struct task_struct *p, unsigned long uptime);
 extern int try_set_zonelist_oom(struct zonelist *zonelist, gfp_t gfp_flags);
 extern void clear_zonelist_oom(struct zonelist *zonelist, gfp_t gfp_flags);
 
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 0623c3d..1969cc1 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -102,7 +102,7 @@ static struct task_struct *find_lock_task_mm(struct task_struct *p)
 }
 
 /**
- * badness - calculate a numeric value for how bad this task has been
+ * oom_badness - calculate a numeric value for how bad this task has been
  * @p: task struct of which task we should calculate
  * @uptime: current uptime in seconds
  *
@@ -119,8 +119,7 @@ static struct task_struct *find_lock_task_mm(struct task_struct *p)
  *    algorithm has been meticulously tuned to meet the principle
  *    of least surprise ... (be careful when you change it)
  */
-
-unsigned long badness(struct task_struct *p, unsigned long uptime)
+unsigned long oom_badness(struct task_struct *p, unsigned long uptime)
 {
 	unsigned long points, cpu_time, run_time;
 	struct task_struct *child;
@@ -336,7 +335,7 @@ static struct task_struct *select_bad_process(unsigned long *ppoints,
 		if (p->signal->oom_adj == OOM_DISABLE)
 			continue;
 
-		points = badness(p, uptime.tv_sec);
+		points = oom_badness(p, uptime.tv_sec);
 		if (points > *ppoints || !chosen) {
 			chosen = p;
 			*ppoints = points;
@@ -456,7 +455,7 @@ static int oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
 
 	/*
 	 * If any of p's children has a different mm and is eligible for kill,
-	 * the one with the highest badness() score is sacrificed for its
+	 * the one with the highest oom_badness() score is sacrificed for its
 	 * parent.  This attempts to lose the minimal amount of work done while
 	 * still freeing memory.
 	 */
@@ -472,8 +471,8 @@ static int oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
 			if (!has_intersects_mems_allowed(child, nodemask))
 				continue;
 
-			/* badness() returns 0 if the thread is unkillable */
-			child_points = badness(child, uptime.tv_sec);
+			/* oom_badness() returns 0 if the thread is unkillable */
+			child_points = oom_badness(child, uptime.tv_sec);
 			if (child_points > victim_points) {
 				victim = child;
 				victim_points = child_points;
-- 
1.6.5.2



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
