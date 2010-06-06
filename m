Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 203926B01B4
	for <linux-mm@kvack.org>; Sun,  6 Jun 2010 18:34:19 -0400 (EDT)
Received: from hpaq6.eem.corp.google.com (hpaq6.eem.corp.google.com [172.25.149.6])
	by smtp-out.google.com with ESMTP id o56MYG5Y022163
	for <linux-mm@kvack.org>; Sun, 6 Jun 2010 15:34:17 -0700
Received: from pzk34 (pzk34.prod.google.com [10.243.19.162])
	by hpaq6.eem.corp.google.com with ESMTP id o56MYEW7030966
	for <linux-mm@kvack.org>; Sun, 6 Jun 2010 15:34:15 -0700
Received: by pzk34 with SMTP id 34so3205059pzk.26
        for <linux-mm@kvack.org>; Sun, 06 Jun 2010 15:34:14 -0700 (PDT)
Date: Sun, 6 Jun 2010 15:34:12 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch 03/18] oom: dump_tasks use find_lock_task_mm too
In-Reply-To: <alpine.DEB.2.00.1006061520520.32225@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1006061523360.32225@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1006061520520.32225@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Oleg Nesterov <oleg@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

dump_task() should use find_lock_task_mm() too. It is necessary for
protecting task-exiting race.

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/oom_kill.c |   39 +++++++++++++++++++++------------------
 1 files changed, 21 insertions(+), 18 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -336,35 +336,38 @@ static struct task_struct *select_bad_process(unsigned long *ppoints,
  */
 static void dump_tasks(const struct mem_cgroup *mem)
 {
-	struct task_struct *g, *p;
+	struct task_struct *p;
+	struct task_struct *task;
 
 	printk(KERN_INFO "[ pid ]   uid  tgid total_vm      rss cpu oom_adj "
 	       "name\n");
-	do_each_thread(g, p) {
-		struct mm_struct *mm;
-
-		if (mem && !task_in_mem_cgroup(p, mem))
+	for_each_process(p) {
+		/*
+		 * We don't have is_global_init() check here, because the old
+		 * code do that. printing init process is not big matter. But
+		 * we don't hope to make unnecessary compatibility breaking.
+		 */
+		if (p->flags & PF_KTHREAD)
 			continue;
-		if (!thread_group_leader(p))
+		if (mem && !task_in_mem_cgroup(p, mem))
 			continue;
 
-		task_lock(p);
-		mm = p->mm;
-		if (!mm) {
+		task = find_lock_task_mm(p);
+		if (!task) {
 			/*
-			 * total_vm and rss sizes do not exist for tasks with no
-			 * mm so there's no need to report them; they can't be
-			 * oom killed anyway.
+			 * Probably oom vs task-exiting race was happen and ->mm
+			 * have been detached. thus there's no need to report
+			 * them; they can't be oom killed anyway.
 			 */
-			task_unlock(p);
 			continue;
 		}
+
 		printk(KERN_INFO "[%5d] %5d %5d %8lu %8lu %3d     %3d %s\n",
-		       p->pid, __task_cred(p)->uid, p->tgid, mm->total_vm,
-		       get_mm_rss(mm), (int)task_cpu(p), p->signal->oom_adj,
-		       p->comm);
-		task_unlock(p);
-	} while_each_thread(g, p);
+		       task->pid, __task_cred(task)->uid, task->tgid,
+		       task->mm->total_vm, get_mm_rss(task->mm),
+		       (int)task_cpu(task), task->signal->oom_adj, p->comm);
+		task_unlock(task);
+	}
 }
 
 static void dump_header(struct task_struct *p, gfp_t gfp_mask, int order,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
