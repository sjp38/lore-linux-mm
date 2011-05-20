Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 159306B0025
	for <linux-mm@kvack.org>; Fri, 20 May 2011 04:05:16 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 81C013EE0BD
	for <linux-mm@kvack.org>; Fri, 20 May 2011 17:05:13 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 6ABE445DE54
	for <linux-mm@kvack.org>; Fri, 20 May 2011 17:05:13 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 4A76545DE59
	for <linux-mm@kvack.org>; Fri, 20 May 2011 17:05:13 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 3BF7DEF8001
	for <linux-mm@kvack.org>; Fri, 20 May 2011 17:05:13 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id EC39EE08001
	for <linux-mm@kvack.org>; Fri, 20 May 2011 17:05:12 +0900 (JST)
Message-ID: <4DD620AE.7020308@jp.fujitsu.com>
Date: Fri, 20 May 2011 17:05:02 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
MIME-Version: 1.0
Subject: [PATCH 5/5] oom: merge oom_kill_process() with oom_kill_task()
References: <4DD61F80.1020505@jp.fujitsu.com>
In-Reply-To: <4DD61F80.1020505@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kosaki.motohiro@jp.fujitsu.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, caiqian@redhat.com, rientjes@google.com, hughd@google.com, kamezawa.hiroyu@jp.fujitsu.com, minchan.kim@gmail.com, oleg@redhat.com

Now, oom_kill_process() become almost empty function. Let's
merge it with oom_kill_task().

Also, this patch replace task_pid_nr() with task_tgid_nr().
Because 1) oom killer kill a process, not thread. 2) a userland
don't care thread id.

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 mm/oom_kill.c |   53 ++++++++++++++++++++++-------------------------------
 1 files changed, 22 insertions(+), 31 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 7d280d4..ec075cc 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -458,11 +458,26 @@ static void dump_header(struct task_struct *p, gfp_t gfp_mask, int order,
 }

 #define K(x) ((x) << (PAGE_SHIFT-10))
-static int oom_kill_task(struct task_struct *p, struct mem_cgroup *mem)
+static int oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
+			    unsigned long points, unsigned long totalpages,
+			    struct mem_cgroup *mem, nodemask_t *nodemask,
+			    const char *message)
 {
 	struct task_struct *q;
 	struct mm_struct *mm;

+	if (printk_ratelimit())
+		dump_header(p, gfp_mask, order, mem, nodemask);
+
+	/*
+	 * If the task is already exiting, don't alarm the sysadmin or kill
+	 * its children or threads, just set TIF_MEMDIE so it can die quickly
+	 */
+	if (p->flags & PF_EXITING) {
+		set_tsk_thread_flag(p, TIF_MEMDIE);
+		return 0;
+	}
+
 	p = find_lock_task_mm(p);
 	if (!p)
 		return 1;
@@ -470,10 +485,11 @@ static int oom_kill_task(struct task_struct *p, struct mem_cgroup *mem)
 	/* mm cannot be safely dereferenced after task_unlock(p) */
 	mm = p->mm;

-	pr_err("Killed process %d (%s) total-vm:%lukB, anon-rss:%lukB, file-rss:%lukB\n",
-		task_pid_nr(p), p->comm, K(p->mm->total_vm),
-		K(get_mm_counter(p->mm, MM_ANONPAGES)),
-		K(get_mm_counter(p->mm, MM_FILEPAGES)));
+	pr_err("%s: Kill process %d (%s) points:%lu total-vm:%lukB, anon-rss:%lukB, file-rss:%lukB\n",
+	       message, task_tgid_nr(p), p->comm, points,
+	       K(p->mm->total_vm),
+	       K(get_mm_counter(p->mm, MM_ANONPAGES)),
+	       K(get_mm_counter(p->mm, MM_FILEPAGES)));
 	task_unlock(p);

 	/*
@@ -490,7 +506,7 @@ static int oom_kill_task(struct task_struct *p, struct mem_cgroup *mem)
 		if (q->mm == mm && !same_thread_group(q, p)) {
 			task_lock(q);	/* Protect ->comm from prctl() */
 			pr_err("Kill process %d (%s) sharing same memory\n",
-				task_pid_nr(q), q->comm);
+				task_tgid_nr(q), q->comm);
 			task_unlock(q);
 			force_sig(SIGKILL, q);
 		}
@@ -502,31 +518,6 @@ static int oom_kill_task(struct task_struct *p, struct mem_cgroup *mem)
 }
 #undef K

-static int oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
-			    unsigned long points, unsigned long totalpages,
-			    struct mem_cgroup *mem, nodemask_t *nodemask,
-			    const char *message)
-{
-	if (printk_ratelimit())
-		dump_header(p, gfp_mask, order, mem, nodemask);
-
-	/*
-	 * If the task is already exiting, don't alarm the sysadmin or kill
-	 * its children or threads, just set TIF_MEMDIE so it can die quickly
-	 */
-	if (p->flags & PF_EXITING) {
-		set_tsk_thread_flag(p, TIF_MEMDIE);
-		return 0;
-	}
-
-	task_lock(p);
-	pr_err("%s: Kill process %d (%s) points %lu\n",
-	       message, task_pid_nr(p), p->comm, points);
-	task_unlock(p);
-
-	return oom_kill_task(p, mem);
-}
-
 /*
  * Determines whether the kernel must panic because of the panic_on_oom sysctl.
  */
-- 
1.7.3.1



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
