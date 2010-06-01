Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id E9B5D6B01B9
	for <linux-mm@kvack.org>; Tue,  1 Jun 2010 01:52:14 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o515qClw002230
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 1 Jun 2010 14:52:12 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id D779145DE55
	for <linux-mm@kvack.org>; Tue,  1 Jun 2010 14:52:10 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id C8A0545DE51
	for <linux-mm@kvack.org>; Tue,  1 Jun 2010 14:52:01 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id C0148E08001
	for <linux-mm@kvack.org>; Tue,  1 Jun 2010 14:51:52 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 33A711DB801D
	for <linux-mm@kvack.org>; Tue,  1 Jun 2010 14:51:50 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH 5/5] oom: dump_tasks() use find_lock_task_mm() too
In-Reply-To: <20100601144238.243A.A69D9226@jp.fujitsu.com>
References: <20100601144238.243A.A69D9226@jp.fujitsu.com>
Message-Id: <20100601145033.2446.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue,  1 Jun 2010 14:51:49 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Oleg Nesterov <oleg@redhat.com>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

dump_task() should have the same process iteration logic as
select_bad_process().

It is needed for protecting from task exiting race.


Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 mm/oom_kill.c |   31 +++++++++++++------------------
 1 files changed, 13 insertions(+), 18 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index cbad4d4..a8af9e8 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -344,35 +344,30 @@ static struct task_struct *select_bad_process(unsigned long *ppoints,
  */
 static void dump_tasks(const struct mem_cgroup *mem)
 {
-	struct task_struct *g, *p;
+	struct task_struct *p;
+	struct task_struct *task;
 
 	printk(KERN_INFO "[ pid ]   uid  tgid total_vm      rss cpu oom_adj "
 	       "name\n");
-	do_each_thread(g, p) {
+
+	for_each_process(p) {
 		struct mm_struct *mm;
 
-		if (mem && !task_in_mem_cgroup(p, mem))
+		if (is_global_init(p) || (p->flags & PF_KTHREAD))
 			continue;
-		if (!thread_group_leader(p))
+		if (mem && !task_in_mem_cgroup(p, mem))
 			continue;
 
-		task_lock(p);
-		mm = p->mm;
-		if (!mm) {
-			/*
-			 * total_vm and rss sizes do not exist for tasks with no
-			 * mm so there's no need to report them; they can't be
-			 * oom killed anyway.
-			 */
-			task_unlock(p);
+		task = find_lock_task_mm(p);
+		if (!task)
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
