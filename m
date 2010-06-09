Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id EB1496B01E0
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 23:59:35 -0400 (EDT)
Received: from kpbe14.cbf.corp.google.com (kpbe14.cbf.corp.google.com [172.25.105.78])
	by smtp-out.google.com with ESMTP id o593xXVB004989
	for <linux-mm@kvack.org>; Tue, 8 Jun 2010 20:59:33 -0700
Received: from pxi4 (pxi4.prod.google.com [10.243.27.4])
	by kpbe14.cbf.corp.google.com with ESMTP id o593xW5h024065
	for <linux-mm@kvack.org>; Tue, 8 Jun 2010 20:59:32 -0700
Received: by pxi4 with SMTP id 4so2898031pxi.26
        for <linux-mm@kvack.org>; Tue, 08 Jun 2010 20:59:32 -0700 (PDT)
Date: Tue, 8 Jun 2010 20:59:28 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch -mm 6/6] oom: improve commentary in dump_tasks()
In-Reply-To: <alpine.DEB.2.00.1006082053130.6219@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1006082058400.6219@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1006082053130.6219@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Oleg Nesterov <oleg@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

The comments in dump_tasks() should be updated to be more clear about why
tasks are filtered and how they are filtered by its argument.

An unnecessary comment concerning a check for is_global_init() is removed
since it isn't of importance.

Suggested-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/oom_kill.c |   11 +++--------
 1 files changed, 3 insertions(+), 8 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -351,7 +351,7 @@ static struct task_struct *select_bad_process(unsigned long *ppoints,
 
 /**
  * dump_tasks - dump current memory state of all system tasks
- * @mem: target memory controller
+ * @mem: current's memory controller, if constrained
  *
  * Dumps the current memory state of all system tasks, excluding kernel threads.
  * State information includes task's pid, uid, tgid, vm size, rss, cpu, oom_adj
@@ -370,11 +370,6 @@ static void dump_tasks(const struct mem_cgroup *mem)
 	printk(KERN_INFO "[ pid ]   uid  tgid total_vm      rss cpu oom_adj "
 	       "name\n");
 	for_each_process(p) {
-		/*
-		 * We don't have is_global_init() check here, because the old
-		 * code do that. printing init process is not big matter. But
-		 * we don't hope to make unnecessary compatibility breaking.
-		 */
 		if (p->flags & PF_KTHREAD)
 			continue;
 		if (mem && !task_in_mem_cgroup(p, mem))
@@ -383,8 +378,8 @@ static void dump_tasks(const struct mem_cgroup *mem)
 		task = find_lock_task_mm(p);
 		if (!task) {
 			/*
-			 * Probably oom vs task-exiting race was happen and ->mm
-			 * have been detached. thus there's no need to report
+			 * This is a kthread or all of p's threads have already
+			 * detached their mm's.  There's no need to report 
 			 * them; they can't be oom killed anyway.
 			 */
 			continue;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
