Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 6E2996B01AF
	for <linux-mm@kvack.org>; Thu,  3 Jun 2010 01:50:40 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o535obwV012945
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 3 Jun 2010 14:50:38 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 8D12745DE50
	for <linux-mm@kvack.org>; Thu,  3 Jun 2010 14:50:37 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 5C26D45DE4C
	for <linux-mm@kvack.org>; Thu,  3 Jun 2010 14:50:37 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 3B863E08003
	for <linux-mm@kvack.org>; Thu,  3 Jun 2010 14:50:37 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id C4AE71DB8013
	for <linux-mm@kvack.org>; Thu,  3 Jun 2010 14:50:36 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH 02/12] oom: introduce find_lock_task_mm() to fix !mm false positives
In-Reply-To: <20100603135106.7247.A69D9226@jp.fujitsu.com>
References: <20100603135106.7247.A69D9226@jp.fujitsu.com>
Message-Id: <20100603144948.724D.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu,  3 Jun 2010 14:50:36 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: "Luis Claudio R. Goncalves" <lclaudio@uudg.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Oleg Nesterov <oleg@redhat.com>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

From: Oleg Nesterov <oleg@redhat.com>

Almost all ->mm == NUL checks in oom_kill.c are wrong.

The current code assumes that the task without ->mm has already
released its memory and ignores the process. However this is not
necessarily true when this process is multithreaded, other live
sub-threads can use this ->mm.

- Remove the "if (!p->mm)" check in select_bad_process(), it is
  just wrong.

- Add the new helper, find_lock_task_mm(), which finds the live
  thread which uses the memory and takes task_lock() to pin ->mm

- change oom_badness() to use this helper instead of just checking
  ->mm != NULL.

- As David pointed out, select_bad_process() must never choose the
  task without ->mm, but no matter what badness() returns the
  task can be chosen if nothing else has been found yet.

Note! This patch is not enough, we need more changes.

	- badness() was fixed, but oom_kill_task() still ignores
	  the task without ->mm

This will be addressed later.

Signed-off-by: Oleg Nesterov <oleg@redhat.com>
Cc: David Rientjes <rientjes@google.com>
Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 mm/oom_kill.c |   28 +++++++++++++++++-----------
 1 files changed, 17 insertions(+), 11 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 070b713..ce9c744 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -52,6 +52,19 @@ static int has_intersects_mems_allowed(struct task_struct *tsk)
 	return 0;
 }
 
+static struct task_struct *find_lock_task_mm(struct task_struct *p)
+{
+	struct task_struct *t = p;
+	do {
+		task_lock(t);
+		if (likely(t->mm))
+			return t;
+		task_unlock(t);
+	} while_each_thread(p, t);
+
+	return NULL;
+}
+
 /**
  * badness - calculate a numeric value for how bad this task has been
  * @p: task struct of which task we should calculate
@@ -74,7 +87,6 @@ static int has_intersects_mems_allowed(struct task_struct *tsk)
 unsigned long badness(struct task_struct *p, unsigned long uptime)
 {
 	unsigned long points, cpu_time, run_time;
-	struct mm_struct *mm;
 	struct task_struct *child;
 	int oom_adj = p->signal->oom_adj;
 	struct task_cputime task_time;
@@ -84,17 +96,14 @@ unsigned long badness(struct task_struct *p, unsigned long uptime)
 	if (oom_adj == OOM_DISABLE)
 		return 0;
 
-	task_lock(p);
-	mm = p->mm;
-	if (!mm) {
-		task_unlock(p);
+	p = find_lock_task_mm(p);
+	if (!p)
 		return 0;
-	}
 
 	/*
 	 * The memory size of the process is the basis for the badness.
 	 */
-	points = mm->total_vm;
+	points = p->mm->total_vm;
 
 	/*
 	 * After this unlock we can no longer dereference local variable `mm'
@@ -117,7 +126,7 @@ unsigned long badness(struct task_struct *p, unsigned long uptime)
 	 */
 	list_for_each_entry(child, &p->children, sibling) {
 		task_lock(child);
-		if (child->mm != mm && child->mm)
+		if (child->mm != p->mm && child->mm)
 			points += child->mm->total_vm/2 + 1;
 		task_unlock(child);
 	}
@@ -256,9 +265,6 @@ static struct task_struct *select_bad_process(unsigned long *ppoints,
 	for_each_process(p) {
 		unsigned long points;
 
-		/* skip the tasks which have already released their mm. */
-		if (!p->mm)
-			continue;
 		/* skip the init task and kthreads */
 		if (is_global_init(p) || (p->flags & PF_KTHREAD))
 			continue;
-- 
1.6.5.2



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
