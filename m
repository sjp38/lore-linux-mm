Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id B914F6B007E
	for <linux-mm@kvack.org>; Wed, 22 Feb 2012 19:03:44 -0500 (EST)
Received: by pbcwz17 with SMTP id wz17so892771pbc.14
        for <linux-mm@kvack.org>; Wed, 22 Feb 2012 16:03:44 -0800 (PST)
Date: Wed, 22 Feb 2012 16:03:42 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: [patch] mm, oom: force oom kill on sysrq+f
Message-ID: <alpine.DEB.2.00.1202221602380.5980@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org

The oom killer chooses not to kill a thread if:

 - an eligible thread has already been oom killed and has yet to exit,
   and

 - an eligible thread is exiting but has yet to free all its memory and
   is not the thread attempting to currently allocate memory.

SysRq+F manually invokes the global oom killer to kill a memory-hogging
task.  This is normally done as a last resort to free memory when no
progress is being made or to test the oom killer itself.

For both uses, we always want to kill a thread and never defer.  This
patch causes SysRq+F to always kill an eligible thread and can be used to
force a kill even if another oom killed thread has failed to exit.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 drivers/tty/sysrq.c |    2 +-
 include/linux/oom.h |    2 +-
 mm/oom_kill.c       |   17 ++++++++++-------
 mm/page_alloc.c     |    2 +-
 4 files changed, 13 insertions(+), 10 deletions(-)

diff --git a/drivers/tty/sysrq.c b/drivers/tty/sysrq.c
--- a/drivers/tty/sysrq.c
+++ b/drivers/tty/sysrq.c
@@ -343,7 +343,7 @@ static struct sysrq_key_op sysrq_term_op = {
 
 static void moom_callback(struct work_struct *ignored)
 {
-	out_of_memory(node_zonelist(0, GFP_KERNEL), GFP_KERNEL, 0, NULL);
+	out_of_memory(node_zonelist(0, GFP_KERNEL), GFP_KERNEL, 0, NULL, true);
 }
 
 static DECLARE_WORK(moom_work, moom_callback);
diff --git a/include/linux/oom.h b/include/linux/oom.h
--- a/include/linux/oom.h
+++ b/include/linux/oom.h
@@ -49,7 +49,7 @@ extern int try_set_zonelist_oom(struct zonelist *zonelist, gfp_t gfp_flags);
 extern void clear_zonelist_oom(struct zonelist *zonelist, gfp_t gfp_flags);
 
 extern void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
-		int order, nodemask_t *mask);
+		int order, nodemask_t *mask, bool force_kill);
 extern int register_oom_notifier(struct notifier_block *nb);
 extern int unregister_oom_notifier(struct notifier_block *nb);
 
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -309,7 +309,7 @@ static enum oom_constraint constrained_alloc(struct zonelist *zonelist,
  */
 static struct task_struct *select_bad_process(unsigned int *ppoints,
 		unsigned long totalpages, struct mem_cgroup *memcg,
-		const nodemask_t *nodemask)
+		const nodemask_t *nodemask, bool force_kill)
 {
 	struct task_struct *g, *p;
 	struct task_struct *chosen = NULL;
@@ -335,7 +335,8 @@ static struct task_struct *select_bad_process(unsigned int *ppoints,
 		if (test_tsk_thread_flag(p, TIF_MEMDIE)) {
 			if (unlikely(frozen(p)))
 				__thaw_task(p);
-			return ERR_PTR(-1UL);
+			if (!force_kill)
+				return ERR_PTR(-1UL);
 		}
 		if (!p->mm)
 			continue;
@@ -353,7 +354,7 @@ static struct task_struct *select_bad_process(unsigned int *ppoints,
 			if (p == current) {
 				chosen = p;
 				*ppoints = 1000;
-			} else {
+			} else if (!force_kill) {
 				/*
 				 * If this task is not being ptraced on exit,
 				 * then wait for it to finish before killing
@@ -581,7 +582,7 @@ void mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask)
 	limit = mem_cgroup_get_limit(memcg) >> PAGE_SHIFT;
 	read_lock(&tasklist_lock);
 retry:
-	p = select_bad_process(&points, limit, memcg, NULL);
+	p = select_bad_process(&points, limit, memcg, NULL, false);
 	if (!p || PTR_ERR(p) == -1UL)
 		goto out;
 
@@ -700,6 +701,7 @@ static void clear_system_oom(void)
  * @gfp_mask: memory allocation flags
  * @order: amount of memory being requested as a power of 2
  * @nodemask: nodemask passed to page allocator
+ * @force_kill: true if a task must be killed, even if others are exiting
  *
  * If we run out of memory, we have the choice between either
  * killing a random task (bad), letting the system crash (worse)
@@ -707,7 +709,7 @@ static void clear_system_oom(void)
  * don't have to be perfect here, we just have to be good.
  */
 void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
-		int order, nodemask_t *nodemask)
+		int order, nodemask_t *nodemask, bool force_kill)
 {
 	const nodemask_t *mpol_mask;
 	struct task_struct *p;
@@ -757,7 +759,8 @@ void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
 	}
 
 retry:
-	p = select_bad_process(&points, totalpages, NULL, mpol_mask);
+	p = select_bad_process(&points, totalpages, NULL, mpol_mask,
+			       force_kill);
 	if (PTR_ERR(p) == -1UL)
 		goto out;
 
@@ -792,7 +795,7 @@ out:
 void pagefault_out_of_memory(void)
 {
 	if (try_set_system_oom()) {
-		out_of_memory(NULL, 0, 0, NULL);
+		out_of_memory(NULL, 0, 0, NULL, false);
 		clear_system_oom();
 	}
 	if (!test_thread_flag(TIF_MEMDIE))
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1968,7 +1968,7 @@ __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
 			goto out;
 	}
 	/* Exhausted what can be done so it's blamo time */
-	out_of_memory(zonelist, gfp_mask, order, nodemask);
+	out_of_memory(zonelist, gfp_mask, order, nodemask, false);
 
 out:
 	clear_zonelist_oom(zonelist, gfp_mask);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
