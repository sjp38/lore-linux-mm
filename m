Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id 1A2C46B0038
	for <linux-mm@kvack.org>; Tue,  2 Jun 2015 04:53:35 -0400 (EDT)
Received: by wizo1 with SMTP id o1so135588810wiz.1
        for <linux-mm@kvack.org>; Tue, 02 Jun 2015 01:53:34 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j1si23224263wia.88.2015.06.02.01.53.33
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 02 Jun 2015 01:53:33 -0700 (PDT)
From: Michal Hocko <mhocko@suse.cz>
Subject: [PATCH] oom: split out forced OOM killer
Date: Tue,  2 Jun 2015 10:53:07 +0200
Message-Id: <1433235187-32673-1-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

OOM killer might be triggered externally via sysrq+f. This is supposed
to kill a task no matter what e.g. a task is selected even though there
is an OOM victim on the way to exit. This is a big hammer for an admin
to help to resolve a memory short condition when the system is not able
to cope with it on its own in a reasonable time frame (e.g. when the
system is trashing or the OOM killer cannot make sufficient progress).

The forced OOM killing is currently wired into out_of_memory()
call which is kind of ugly because generic out_of_memory path
has to deal with configuration settings and heuristics which
are completely irrelevant to the forced OOM killer (e.g.
sysctl_oom_kill_allocating_task or OOM killer prevention for already
dying tasks). Some of those will not apply to sysrq because the handler
runs from the worker context.
check_panic_on_oom on the other hand will work and that is kind of
unexpected because sysrq+f should be usable to kill a mem hog whether
the global OOM policy is to panic or not.
It also doesn't make much sense to panic the system when no task cannot
be killed because admin has a separate sysrq for that purpose.

Let's pull forced OOM killer code out into a separate function
(force_out_of_memory) which is really trivial now. Also extract the core
of oom_kill_process into __oom_kill_process which doesn't do any
OOM prevention heuristics.
As a bonus we can clearly state that this is a forced OOM killer in the
OOM message which is helpful to distinguish it from the regular OOM
killer.

Signed-off-by: Michal Hocko <mhocko@suse.cz>
---
 drivers/tty/sysrq.c |  3 +--
 include/linux/oom.h |  3 ++-
 mm/oom_kill.c       | 73 +++++++++++++++++++++++++++++++++++++++--------------
 mm/page_alloc.c     |  2 +-
 4 files changed, 58 insertions(+), 23 deletions(-)

diff --git a/drivers/tty/sysrq.c b/drivers/tty/sysrq.c
index 3a42b7187b8e..06a95a8ed701 100644
--- a/drivers/tty/sysrq.c
+++ b/drivers/tty/sysrq.c
@@ -356,8 +356,7 @@ static struct sysrq_key_op sysrq_term_op = {
 static void moom_callback(struct work_struct *ignored)
 {
 	mutex_lock(&oom_lock);
-	if (!out_of_memory(node_zonelist(first_memory_node, GFP_KERNEL),
-			   GFP_KERNEL, 0, NULL, true))
+	if (!force_out_of_memory())
 		pr_info("OOM request ignored because killer is disabled\n");
 	mutex_unlock(&oom_lock);
 }
diff --git a/include/linux/oom.h b/include/linux/oom.h
index 7deecb7bca5e..061e0ffd3493 100644
--- a/include/linux/oom.h
+++ b/include/linux/oom.h
@@ -70,8 +70,9 @@ extern enum oom_scan_t oom_scan_process_thread(struct task_struct *task,
 		unsigned long totalpages, const nodemask_t *nodemask,
 		bool force_kill);
 
+extern bool force_out_of_memory(void);
 extern bool out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
-		int order, nodemask_t *mask, bool force_kill);
+		int order, nodemask_t *mask);
 
 extern void exit_oom_victim(void);
 
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index dff991e0681e..8fea31e17461 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -487,7 +487,7 @@ void oom_killer_enable(void)
  * Must be called while holding a reference to p, which will be released upon
  * returning.
  */
-void oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
+static void __oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
 		      unsigned int points, unsigned long totalpages,
 		      struct mem_cgroup *memcg, nodemask_t *nodemask,
 		      const char *message)
@@ -500,19 +500,6 @@ void oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
 	static DEFINE_RATELIMIT_STATE(oom_rs, DEFAULT_RATELIMIT_INTERVAL,
 					      DEFAULT_RATELIMIT_BURST);
 
-	/*
-	 * If the task is already exiting, don't alarm the sysadmin or kill
-	 * its children or threads, just set TIF_MEMDIE so it can die quickly
-	 */
-	task_lock(p);
-	if (p->mm && task_will_free_mem(p)) {
-		mark_oom_victim(p);
-		task_unlock(p);
-		put_task_struct(p);
-		return;
-	}
-	task_unlock(p);
-
 	if (__ratelimit(&oom_rs))
 		dump_header(p, gfp_mask, order, memcg, nodemask);
 
@@ -597,6 +584,28 @@ void oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
 }
 #undef K
 
+void oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
+		      unsigned int points, unsigned long totalpages,
+		      struct mem_cgroup *memcg, nodemask_t *nodemask,
+		      const char *message)
+{
+	/*
+	 * If the task is already exiting, don't alarm the sysadmin or kill
+	 * its children or threads, just set TIF_MEMDIE so it can die quickly
+	 */
+	task_lock(p);
+	if (p->mm && task_will_free_mem(p)) {
+		mark_oom_victim(p);
+		task_unlock(p);
+		put_task_struct(p);
+		return;
+	}
+	task_unlock(p);
+
+	__oom_kill_process(p, gfp_mask, order, points, totalpages, memcg,
+			nodemask, message);
+}
+
 /*
  * Determines whether the kernel must panic because of the panic_on_oom sysctl.
  */
@@ -635,12 +644,38 @@ int unregister_oom_notifier(struct notifier_block *nb)
 EXPORT_SYMBOL_GPL(unregister_oom_notifier);
 
 /**
- * __out_of_memory - kill the "best" process when we run out of memory
+ * force_out_of_memory - forces OOM killer
+ *
+ * External trigger for the OOM killer. The system doesn't have to be under
+ * OOM condition (e.g. sysrq+f).
+ */
+bool force_out_of_memory(void)
+{
+	struct zonelist *zonelist = node_zonelist(first_memory_node, GFP_KERNEL);
+	struct task_struct *p;
+	unsigned long totalpages;
+	unsigned int points;
+
+	if (oom_killer_disabled)
+		return false;
+
+	constrained_alloc(zonelist, GFP_KERNEL, NULL, &totalpages);
+	p = select_bad_process(&points, totalpages, NULL, true);
+	if (p != (void *)-1UL)
+		__oom_kill_process(p, GFP_KERNEL, 0, points, totalpages, NULL,
+				 NULL, "Forced out of memory killer");
+	else
+		pr_warn("Forced out of memory. No killable task found...\n");
+
+	return true;
+}
+
+/**
+ * out_of_memory - kill the "best" process when we run out of memory
  * @zonelist: zonelist pointer
  * @gfp_mask: memory allocation flags
  * @order: amount of memory being requested as a power of 2
  * @nodemask: nodemask passed to page allocator
- * @force_kill: true if a task must be killed, even if others are exiting
  *
  * If we run out of memory, we have the choice between either
  * killing a random task (bad), letting the system crash (worse)
@@ -648,7 +683,7 @@ EXPORT_SYMBOL_GPL(unregister_oom_notifier);
  * don't have to be perfect here, we just have to be good.
  */
 bool out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
-		   int order, nodemask_t *nodemask, bool force_kill)
+		   int order, nodemask_t *nodemask)
 {
 	const nodemask_t *mpol_mask;
 	struct task_struct *p;
@@ -699,7 +734,7 @@ bool out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
 		goto out;
 	}
 
-	p = select_bad_process(&points, totalpages, mpol_mask, force_kill);
+	p = select_bad_process(&points, totalpages, mpol_mask, false);
 	/* Found nothing?!?! Either we hang forever, or we panic. */
 	if (!p) {
 		dump_header(NULL, gfp_mask, order, NULL, mpol_mask);
@@ -734,7 +769,7 @@ void pagefault_out_of_memory(void)
 	if (!mutex_trylock(&oom_lock))
 		return;
 
-	if (!out_of_memory(NULL, 0, 0, NULL, false)) {
+	if (!out_of_memory(NULL, 0, 0, NULL)) {
 		/*
 		 * There shouldn't be any user tasks runnable while the
 		 * OOM killer is disabled, so the current task has to
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 1f9ffbb087cb..014806d13138 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2731,7 +2731,7 @@ __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
 			goto out;
 	}
 	/* Exhausted what can be done so it's blamo time */
-	if (out_of_memory(ac->zonelist, gfp_mask, order, ac->nodemask, false)
+	if (out_of_memory(ac->zonelist, gfp_mask, order, ac->nodemask)
 			|| WARN_ON_ONCE(gfp_mask & __GFP_NOFAIL))
 		*did_some_progress = 1;
 out:
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
