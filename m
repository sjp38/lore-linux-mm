Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 562D86B01C4
	for <linux-mm@kvack.org>; Thu,  3 Jun 2010 02:24:42 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o536Of78009065
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 3 Jun 2010 15:24:42 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id B27F545DE50
	for <linux-mm@kvack.org>; Thu,  3 Jun 2010 15:24:41 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 992E645DE4C
	for <linux-mm@kvack.org>; Thu,  3 Jun 2010 15:24:41 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 7F4A61DB8012
	for <linux-mm@kvack.org>; Thu,  3 Jun 2010 15:24:41 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 392471DB8013
	for <linux-mm@kvack.org>; Thu,  3 Jun 2010 15:24:41 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH 08/12] oom: dump_tasks() use find_lock_task_mm() too
In-Reply-To: <20100603135106.7247.A69D9226@jp.fujitsu.com>
References: <20100603135106.7247.A69D9226@jp.fujitsu.com>
Message-Id: <20100603152350.725F.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu,  3 Jun 2010 15:24:36 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: "Luis Claudio R. Goncalves" <lclaudio@uudg.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Oleg Nesterov <oleg@redhat.com>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

dump_task() should use find_lock_task_mm() too. It is necessary for
protecting task-exiting race.

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 mm/oom_kill.c |   37 ++++++++++++++++++++-----------------
 1 files changed, 20 insertions(+), 17 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 35a2ecc..6360c56 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -345,35 +345,38 @@ static struct task_struct *select_bad_process(unsigned long *ppoints,
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
 
-		if (mem && !task_in_mem_cgroup(p, mem))
+	for_each_process(p) {
+		/*
+		 * We don't have is_global_init() check here, because the old
+		 * code do that. printing init process is not big matter. But 
+		 * we don't hope to make unnecessary compatiblity breaking.
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
+		if (!task)
 			/*
-			 * total_vm and rss sizes do not exist for tasks with no
-			 * mm so there's no need to report them; they can't be
-			 * oom killed anyway.
+			 * Probably oom vs task-exiting race was happen and ->mm
+			 * have been detached. thus there's no need to report them;
+			 * they can't be oom killed anyway.
 			 */
-			task_unlock(p);
 			continue;
-		}
+
 		printk(KERN_INFO "[%5d] %5d %5d %8lu %8lu %3d     %3d %s\n",
-		       p->pid, __task_cred(p)->uid, p->tgid, mm->total_vm,
-		       get_mm_rss(mm), (int)task_cpu(p), p->signal->oom_adj,
+		       task->pid, __task_cred(task)->uid, task->tgid, task->mm->total_vm,
+		       get_mm_rss(task->mm), (int)task_cpu(task), task->signal->oom_adj,
 		       p->comm);
-		task_unlock(p);
-	} while_each_thread(g, p);
+		task_unlock(task);
+	}
 }
 
 static void dump_header(struct task_struct *p, gfp_t gfp_mask, int order,
-- 
1.6.5.2



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
