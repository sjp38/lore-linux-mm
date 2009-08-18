Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id ADB056B004D
	for <linux-mm@kvack.org>; Tue, 18 Aug 2009 11:57:50 -0400 (EDT)
Date: Wed, 19 Aug 2009 00:57:54 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH for mmotm] oom: remove unnecessary task->sighand->siglock grabbing.
Message-Id: <20090819005301.A650.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com, Oleg Nesterov <oleg@redhat.com>
List-ID: <linux-mm.kvack.org>

Subject: [PATCH] oom: remove unnecessary task->sighand->siglock grabbing.

Oleg Nesterov get_oom_adj() doesn't need grab task->sighand->siglock.
tasklist_lock already prevent any race.

This patch remove its unnecessary lock.

Reported-by: Oleg Nesterov <oleg@redhat.com>
Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 mm/oom_kill.c |   29 +++++++----------------------
 1 file changed, 7 insertions(+), 22 deletions(-)

Index: b/mm/oom_kill.c
===================================================================
--- a/mm/oom_kill.c	2009-08-19 00:25:28.000000000 +0900
+++ b/mm/oom_kill.c	2009-08-19 00:43:31.000000000 +0900
@@ -34,17 +34,13 @@ int sysctl_oom_dump_tasks;
 static DEFINE_SPINLOCK(zone_scan_lock);
 /* #define DEBUG */
 
-int get_oom_adj(struct task_struct *tsk)
+static int get_oom_adj(struct task_struct *tsk)
 {
-	unsigned long flags;
-	int oom_adj = OOM_DISABLE;
-
-	if (tsk->mm && lock_task_sighand(tsk, &flags)) {
-		oom_adj = tsk->signal->oom_adj;
-		unlock_task_sighand(tsk, &flags);
-	}
+	/* OOM Killer can't kill kernel thread */
+	if (!tsk->mm)
+		return OOM_DISABLE;
 
-	return oom_adj;
+	return tsk->signal->oom_adj;
 }
 
 void set_oom_adj(struct task_struct *tsk, int oom_adj)
@@ -97,7 +93,6 @@ unsigned long badness(struct task_struct
 	struct task_struct *child;
 	int oom_adj;
 	struct task_cputime task_time;
-	unsigned long flags;
 	unsigned long utime;
 	unsigned long stime;
 
@@ -105,10 +100,7 @@ unsigned long badness(struct task_struct
 	if (oom_adj == OOM_DISABLE)
 		return 0;
 
-	if (!lock_task_sighand(p, &flags))
-		return 0;
 	thread_group_cputime(p, &task_time);
-	unlock_task_sighand(p, &flags);
 
 	task_lock(p);
 	mm = p->mm;
@@ -329,8 +321,6 @@ static struct task_struct *select_bad_pr
 static void dump_tasks(const struct mem_cgroup *mem)
 {
 	struct task_struct *g, *p;
-	unsigned long flags;
-	int oom_adj;
 
 	printk(KERN_INFO "[ pid ]   uid  tgid total_vm      rss cpu oom_adj "
 	       "name\n");
@@ -342,12 +332,6 @@ static void dump_tasks(const struct mem_
 		if (!thread_group_leader(p))
 			continue;
 
-		if (!lock_task_sighand(p, &flags))
-			continue;
-
-		oom_adj = p->signal->oom_adj;
-		unlock_task_sighand(p, &flags);
-
 		task_lock(p);
 		mm = p->mm;
 		if (!mm) {
@@ -361,7 +345,8 @@ static void dump_tasks(const struct mem_
 		}
 		printk(KERN_INFO "[%5d] %5d %5d %8lu %8lu %3d     %3d %s\n",
 		       p->pid, __task_cred(p)->uid, p->tgid, mm->total_vm,
-		       get_mm_rss(mm), (int)task_cpu(p), oom_adj, p->comm);
+		       get_mm_rss(mm), (int)task_cpu(p), get_oom_adj(p),
+		       p->comm);
 		task_unlock(p);
 	} while_each_thread(g, p);
 }


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
