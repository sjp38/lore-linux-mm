Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id AAB176B022E
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 07:56:32 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o58BuU53018475
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 8 Jun 2010 20:56:30 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 78B7245DE52
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 20:56:30 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 4676545DE4E
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 20:56:30 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 2A6151DB8040
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 20:56:30 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id C1FA21DB8037
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 20:56:29 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH 03/10] oom: rename badness() to oom_badness()
In-Reply-To: <20100608204621.767A.A69D9226@jp.fujitsu.com>
References: <20100608204621.767A.A69D9226@jp.fujitsu.com>
Message-Id: <20100608205536.7683.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue,  8 Jun 2010 20:56:29 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: "Luis Claudio R. Goncalves" <lclaudio@uudg.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Oleg Nesterov <oleg@redhat.com>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>, Minchan Kim <minchan.kim@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

badness() is wrong name because it's too generic name.

rename it.

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 fs/proc/base.c      |    4 +---
 include/linux/oom.h |    2 ++
 mm/oom_kill.c       |   10 +++++-----
 3 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/fs/proc/base.c b/fs/proc/base.c
index 2222102..c099f03 100644
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
index 5376623..effb223 100644
--- a/include/linux/oom.h
+++ b/include/linux/oom.h
@@ -14,6 +14,7 @@
 
 struct zonelist;
 struct notifier_block;
+struct task_struct;
 
 /*
  * Types of limitations to the nodes from which allocations may occur
@@ -29,6 +30,7 @@ extern void clear_zonelist_oom(struct zonelist *zonelist, gfp_t gfp_flags);
 
 extern void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
 		int order, nodemask_t *mask);
+extern unsigned long oom_badness(struct task_struct *p, unsigned long uptime);
 extern int register_oom_notifier(struct notifier_block *nb);
 extern int unregister_oom_notifier(struct notifier_block *nb);
 
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 3c83fba..80492ff 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -66,7 +66,7 @@ static struct task_struct *find_lock_task_mm(struct task_struct *p)
 }
 
 /**
- * badness - calculate a numeric value for how bad this task has been
+ * oom_badness - calculate a numeric value for how bad this task has been
  * @p: task struct of which task we should calculate
  * @uptime: current uptime in seconds
  *
@@ -84,7 +84,7 @@ static struct task_struct *find_lock_task_mm(struct task_struct *p)
  *    of least surprise ... (be careful when you change it)
  */
 
-unsigned long badness(struct task_struct *p, unsigned long uptime)
+unsigned long oom_badness(struct task_struct *p, unsigned long uptime)
 {
 	unsigned long points, cpu_time, run_time;
 	struct task_struct *c;
@@ -302,7 +302,7 @@ static struct task_struct *select_bad_process(unsigned long *ppoints,
 		if (test_tsk_thread_flag(p, TIF_MEMDIE))
 			return ERR_PTR(-1UL);
 
-		points = badness(p, uptime.tv_sec);
+		points = oom_badness(p, uptime.tv_sec);
 		if (points > *ppoints || !chosen) {
 			chosen = p;
 			*ppoints = points;
@@ -438,8 +438,8 @@ static int oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
 			if (oom_unkillable(c, mem))
 				continue;
 
-			/* badness() returns 0 if the thread is unkillable */
-			cpoints = badness(c, uptime.tv_sec);
+			/* oom_badness() returns 0 if the thread is unkillable */
+			cpoints = oom_badness(c, uptime.tv_sec);
 			if (cpoints > victim_points) {
 				victim = c;
 				victim_points = cpoints;
-- 
1.6.5.2



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
