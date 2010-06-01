Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id D3F456B01B6
	for <linux-mm@kvack.org>; Tue,  1 Jun 2010 01:47:03 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o515l1vA026691
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 1 Jun 2010 14:47:01 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 09BB545DE54
	for <linux-mm@kvack.org>; Tue,  1 Jun 2010 14:47:01 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id DD9C845DE53
	for <linux-mm@kvack.org>; Tue,  1 Jun 2010 14:47:00 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id BD0FBE08001
	for <linux-mm@kvack.org>; Tue,  1 Jun 2010 14:47:00 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 63C64E08004
	for <linux-mm@kvack.org>; Tue,  1 Jun 2010 14:47:00 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH 1/5] oom: make oom_unkillable() helper function
Message-Id: <20100601144238.243A.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue,  1 Jun 2010 14:46:59 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Oleg Nesterov <oleg@redhat.com>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>


This patch series was made on top yesterday oom pile
=====================================================================

Now, sysctl_oom_kill_allocating_task case and CONSTRAINT_MEMORY_POLICY
case don't call select_bad_process(). then, oom_kill_process() need
very similar check for distinguish unkillable tasks.

This patch unify such two logic.

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 mm/oom_kill.c |   62 ++++++++++++++++++++++++--------------------------------
 1 files changed, 27 insertions(+), 35 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index f6aa3fc..bac4515 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -250,6 +250,21 @@ static enum oom_constraint constrained_alloc(struct zonelist *zonelist,
 }
 #endif
 
+int oom_unkillable(struct task_struct *p, struct mem_cgroup *mem)
+{
+	/* skip the init task and kthreads */
+	if (is_global_init(p) || (p->flags & PF_KTHREAD))
+		return 1;
+
+	if (mem && !task_in_mem_cgroup(p, mem))
+		return 1;
+
+	if (p->signal->oom_adj == OOM_DISABLE)
+		return 1;
+
+	return 0;
+}
+
 /*
  * Simple selection loop. We chose the process with the highest
  * number of 'points'. We expect the caller will lock the tasklist.
@@ -268,10 +283,7 @@ static struct task_struct *select_bad_process(unsigned long *ppoints,
 	for_each_process(p) {
 		unsigned long points;
 
-		/* skip the init task and kthreads */
-		if (is_global_init(p) || (p->flags & PF_KTHREAD))
-			continue;
-		if (mem && !task_in_mem_cgroup(p, mem))
+		if (oom_unkillable(p, mem))
 			continue;
 
 		/*
@@ -304,9 +316,6 @@ static struct task_struct *select_bad_process(unsigned long *ppoints,
 			*ppoints = ULONG_MAX;
 		}
 
-		if (p->signal->oom_adj == OOM_DISABLE)
-			continue;
-
 		points = badness(p, uptime.tv_sec);
 		if (points > *ppoints || !chosen) {
 			chosen = p;
@@ -386,20 +395,18 @@ static void dump_header(struct task_struct *p, gfp_t gfp_mask, int order,
  * flag though it's unlikely that  we select a process with CAP_SYS_RAW_IO
  * set.
  */
-static void __oom_kill_task(struct task_struct *p, int verbose)
+static int __oom_kill_process(struct task_struct *p, struct mem_cgroup *mem,
+			      int verbose)
 {
-	if (is_global_init(p)) {
-		WARN_ON(1);
-		printk(KERN_WARNING "tried to kill init!\n");
-		return;
-	}
+	if (oom_unkillable(p, mem))
+		return 1;
 
 	p = find_lock_task_mm(p);
 	if (!p) {
 		WARN_ON(1);
 		printk(KERN_WARNING "tried to kill an mm-less task %d (%s)!\n",
 			task_pid_nr(p), p->comm);
-		return;
+		return 1;
 	}
 
 	if (verbose)
@@ -420,22 +427,6 @@ static void __oom_kill_task(struct task_struct *p, int verbose)
 	set_tsk_thread_flag(p, TIF_MEMDIE);
 
 	force_sig(SIGKILL, p);
-}
-
-static int oom_kill_task(struct task_struct *p)
-{
-	/* WARNING: mm may not be dereferenced since we did not obtain its
-	 * value from get_task_mm(p).  This is OK since all we need to do is
-	 * compare mm to q->mm below.
-	 *
-	 * Furthermore, even if mm contains a non-NULL value, p->mm may
-	 * change to NULL at any time since we do not hold task_lock(p).
-	 * However, this is of no concern to us.
-	 */
-	if (!p->mm || p->signal->oom_adj == OOM_DISABLE)
-		return 1;
-
-	__oom_kill_task(p, 1);
 
 	return 0;
 }
@@ -454,7 +445,7 @@ static int oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
 	 * its children or threads, just set TIF_MEMDIE so it can die quickly
 	 */
 	if (p->flags & PF_EXITING) {
-		__oom_kill_task(p, 0);
+		__oom_kill_process(p, mem, 0);
 		return 0;
 	}
 
@@ -465,12 +456,13 @@ static int oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
 	list_for_each_entry(c, &p->children, sibling) {
 		if (c->mm == p->mm)
 			continue;
-		if (mem && !task_in_mem_cgroup(c, mem))
-			continue;
-		if (!oom_kill_task(c))
+
+		/* Ok, Kill the child */
+		if (!__oom_kill_process(c, mem, 1))
 			return 0;
 	}
-	return oom_kill_task(p);
+
+	return __oom_kill_process(p, mem, 1);
 }
 
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR
-- 
1.6.5.2



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
