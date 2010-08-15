Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 95FF66B01F1
	for <linux-mm@kvack.org>; Sun, 15 Aug 2010 00:31:04 -0400 (EDT)
Received: from hpaq1.eem.corp.google.com (hpaq1.eem.corp.google.com [172.25.149.1])
	by smtp-out.google.com with ESMTP id o7F4V1cE001183
	for <linux-mm@kvack.org>; Sat, 14 Aug 2010 21:31:01 -0700
Received: from pxi14 (pxi14.prod.google.com [10.243.27.14])
	by hpaq1.eem.corp.google.com with ESMTP id o7F4UxUp003320
	for <linux-mm@kvack.org>; Sat, 14 Aug 2010 21:31:00 -0700
Received: by pxi14 with SMTP id 14so1732863pxi.38
        for <linux-mm@kvack.org>; Sat, 14 Aug 2010 21:30:59 -0700 (PDT)
Date: Sat, 14 Aug 2010 21:30:54 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch 1/2] oom: avoid killing a task if a thread sharing its mm
 cannot be killed
Message-ID: <alpine.DEB.2.00.1008142128050.31510@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Oleg Nesterov <oleg@redhat.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

The oom killer's goal is to kill a memory-hogging task so that it may
exit, free its memory, and allow the current context to allocate the
memory that triggered it in the first place.  Thus, killing a task is
pointless if other threads sharing its mm cannot be killed because of its
/proc/pid/oom_adj or /proc/pid/oom_score_adj value.

This patch checks all user threads on the system to determine whether
oom_badness(p) should return 0 for p, which means it should not be killed.
If a thread shares p's mm and is unkillable, p is considered to be
unkillable as well.

Kthreads are not considered toward this rule since they only temporarily
assume a task's mm via use_mm().

Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/oom_kill.c |   30 +++++++++++++++++++++++-------
 1 files changed, 23 insertions(+), 7 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -83,6 +83,27 @@ static bool has_intersects_mems_allowed(struct task_struct *tsk,
 #endif /* CONFIG_NUMA */
 
 /*
+ * Determines whether an mm is unfreeable since a user thread attached to
+ * it cannot be killed.  Kthreads only temporarily assume a thread's mm,
+ * so they are not considered.
+ *
+ * mm need not be protected by task_lock() since it will not be
+ * dereferened.
+ */
+static bool is_mm_unfreeable(struct mm_struct *mm)
+{
+	struct task_struct *g, *q;
+
+	do_each_thread(g, q) {
+		if (q->mm == mm && !(q->flags & PF_KTHREAD) &&
+		    q->signal->oom_score_adj == OOM_SCORE_ADJ_MIN)
+			return true;
+	} while_each_thread(g, q);
+
+	return false;
+}
+
+/*
  * If this is a system OOM (not a memcg OOM) and the task selected to be
  * killed is not already running at high (RT) priorities, speed up the
  * recovery by boosting the dying task to the lowest FIFO priority.
@@ -160,12 +181,7 @@ unsigned int oom_badness(struct task_struct *p, struct mem_cgroup *mem,
 	p = find_lock_task_mm(p);
 	if (!p)
 		return 0;
-
-	/*
-	 * Shortcut check for OOM_SCORE_ADJ_MIN so the entire heuristic doesn't
-	 * need to be executed for something that cannot be killed.
-	 */
-	if (p->signal->oom_score_adj == OOM_SCORE_ADJ_MIN) {
+	if (is_mm_unfreeable(p->mm)) {
 		task_unlock(p);
 		return 0;
 	}
@@ -675,7 +691,7 @@ void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
 	read_lock(&tasklist_lock);
 	if (sysctl_oom_kill_allocating_task &&
 	    !oom_unkillable_task(current, NULL, nodemask) &&
-	    (current->signal->oom_adj != OOM_DISABLE)) {
+	    !is_mm_unfreeable(current->mm)) {
 		/*
 		 * oom_kill_process() needs tasklist_lock held.  If it returns
 		 * non-zero, current could not be killed so we must fallback to

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
