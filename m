Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Subject: [PATCH 12 of 24] show mem information only when a task is actually
	being killed
Message-Id: <1473d573b9ba8a913baf.1187786939@v2.random>
In-Reply-To: <patchbomb.1187786927@v2.random>
Date: Wed, 22 Aug 2007 14:48:59 +0200
From: Andrea Arcangeli <andrea@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

# HG changeset patch
# User Andrea Arcangeli <andrea@suse.de>
# Date 1187778125 -7200
# Node ID 1473d573b9ba8a913bafa42da2cac5dcca274204
# Parent  adf88d0ba0d17beaceee47f7b8e0acbd97ddc320
show mem information only when a task is actually being killed

Don't show garbage while VM_is_OOM and the timeout didn't trigger.

Signed-off-by: Andrea Arcangeli <andrea@suse.de>

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -287,7 +287,7 @@ static void __oom_kill_task(struct task_
 	force_sig(SIGKILL, p);
 }
 
-static int oom_kill_task(struct task_struct *p)
+static int oom_kill_task(struct task_struct *p, gfp_t gfp_mask, int order)
 {
 	struct mm_struct *mm;
 	struct task_struct *g, *q;
@@ -314,93 +314,6 @@ static int oom_kill_task(struct task_str
 			return 1;
 	} while_each_thread(g, q);
 
-	__oom_kill_task(p, 1);
-
-	/*
-	 * kill all processes that share the ->mm (i.e. all threads),
-	 * but are in a different thread group. Don't let them have access
-	 * to memory reserves though, otherwise we might deplete all memory.
-	 */
-	do_each_thread(g, q) {
-		if (q->mm == mm && q->tgid != p->tgid)
-			force_sig(SIGKILL, q);
-	} while_each_thread(g, q);
-
-	return 0;
-}
-
-static int oom_kill_process(struct task_struct *p, unsigned long points,
-		const char *message)
-{
-	struct task_struct *c;
-	struct list_head *tsk;
-
-	/*
-	 * If the task is already exiting, don't alarm the sysadmin or kill
-	 * its children or threads, just set TIF_MEMDIE so it can die quickly
-	 */
-	if (p->flags & PF_EXITING) {
-		__oom_kill_task(p, 0);
-		return 0;
-	}
-
-	printk(KERN_ERR "%s: kill process %d (%s) score %li or a child\n",
-					message, p->pid, p->comm, points);
-
-	/* Try to kill a child first */
-	list_for_each(tsk, &p->children) {
-		c = list_entry(tsk, struct task_struct, sibling);
-		if (c->mm == p->mm)
-			continue;
-		/*
-		 * We cannot select tasks with TIF_MEMDIE already set
-		 * or we'll hard deadlock.
-		 */
-		if (unlikely(test_tsk_thread_flag(c, TIF_MEMDIE)))
-			continue;
-		if (!oom_kill_task(c))
-			return 0;
-	}
-	return oom_kill_task(p);
-}
-
-static BLOCKING_NOTIFIER_HEAD(oom_notify_list);
-
-int register_oom_notifier(struct notifier_block *nb)
-{
-	return blocking_notifier_chain_register(&oom_notify_list, nb);
-}
-EXPORT_SYMBOL_GPL(register_oom_notifier);
-
-int unregister_oom_notifier(struct notifier_block *nb)
-{
-	return blocking_notifier_chain_unregister(&oom_notify_list, nb);
-}
-EXPORT_SYMBOL_GPL(unregister_oom_notifier);
-
-/**
- * out_of_memory - kill the "best" process when we run out of memory
- *
- * If we run out of memory, we have the choice between either
- * killing a random task (bad), letting the system crash (worse)
- * OR try to be smart about which process to kill. Note that we
- * don't have to be perfect here, we just have to be good.
- */
-void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask, int order)
-{
-	struct task_struct *p;
-	unsigned long points = 0;
-	unsigned long freed = 0;
-	int constraint;
-	static DECLARE_MUTEX(OOM_lock);
-
-	blocking_notifier_call_chain(&oom_notify_list, 0, &freed);
-	if (freed > 0)
-		/* Got some memory back in the last second. */
-		return;
-
-	if (down_trylock(&OOM_lock))
-		return;
 	if (printk_ratelimit()) {
 		printk(KERN_WARNING "%s invoked oom-killer: "
 			"gfp_mask=0x%x, order=%d, oomkilladj=%d\n",
@@ -409,6 +322,94 @@ void out_of_memory(struct zonelist *zone
 		show_mem();
 	}
 
+	__oom_kill_task(p, 1);
+
+	/*
+	 * kill all processes that share the ->mm (i.e. all threads),
+	 * but are in a different thread group. Don't let them have access
+	 * to memory reserves though, otherwise we might deplete all memory.
+	 */
+	do_each_thread(g, q) {
+		if (q->mm == mm && q->tgid != p->tgid)
+			force_sig(SIGKILL, q);
+	} while_each_thread(g, q);
+
+	return 0;
+}
+
+static int oom_kill_process(struct task_struct *p, unsigned long points,
+			    const char *message, gfp_t gfp_mask, int order)
+{
+	struct task_struct *c;
+	struct list_head *tsk;
+
+	/*
+	 * If the task is already exiting, don't alarm the sysadmin or kill
+	 * its children or threads, just set TIF_MEMDIE so it can die quickly
+	 */
+	if (p->flags & PF_EXITING) {
+		__oom_kill_task(p, 0);
+		return 0;
+	}
+
+	printk(KERN_ERR "%s: kill process %d (%s) score %li or a child\n",
+					message, p->pid, p->comm, points);
+
+	/* Try to kill a child first */
+	list_for_each(tsk, &p->children) {
+		c = list_entry(tsk, struct task_struct, sibling);
+		if (c->mm == p->mm)
+			continue;
+		/*
+		 * We cannot select tasks with TIF_MEMDIE already set
+		 * or we'll hard deadlock.
+		 */
+		if (unlikely(test_tsk_thread_flag(c, TIF_MEMDIE)))
+			continue;
+		if (!oom_kill_task(c, gfp_mask, order))
+			return 0;
+	}
+	return oom_kill_task(p, gfp_mask, order);
+}
+
+static BLOCKING_NOTIFIER_HEAD(oom_notify_list);
+
+int register_oom_notifier(struct notifier_block *nb)
+{
+	return blocking_notifier_chain_register(&oom_notify_list, nb);
+}
+EXPORT_SYMBOL_GPL(register_oom_notifier);
+
+int unregister_oom_notifier(struct notifier_block *nb)
+{
+	return blocking_notifier_chain_unregister(&oom_notify_list, nb);
+}
+EXPORT_SYMBOL_GPL(unregister_oom_notifier);
+
+/**
+ * out_of_memory - kill the "best" process when we run out of memory
+ *
+ * If we run out of memory, we have the choice between either
+ * killing a random task (bad), letting the system crash (worse)
+ * OR try to be smart about which process to kill. Note that we
+ * don't have to be perfect here, we just have to be good.
+ */
+void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask, int order)
+{
+	struct task_struct *p;
+	unsigned long points = 0;
+	unsigned long freed = 0;
+	int constraint;
+	static DECLARE_MUTEX(OOM_lock);
+
+	blocking_notifier_call_chain(&oom_notify_list, 0, &freed);
+	if (freed > 0)
+		/* Got some memory back in the last second. */
+		return;
+
+	if (down_trylock(&OOM_lock))
+		return;
+
 	if (sysctl_panic_on_oom == 2)
 		panic("out of memory. Compulsory panic_on_oom is selected.\n");
 
@@ -435,12 +436,12 @@ void out_of_memory(struct zonelist *zone
 	switch (constraint) {
 	case CONSTRAINT_MEMORY_POLICY:
 		oom_kill_process(current, points,
-				"No available memory (MPOL_BIND)");
+				 "No available memory (MPOL_BIND)", gfp_mask, order);
 		break;
 
 	case CONSTRAINT_CPUSET:
 		oom_kill_process(current, points,
-				"No available memory in cpuset");
+				 "No available memory in cpuset", gfp_mask, order);
 		break;
 
 	case CONSTRAINT_NONE:
@@ -459,7 +460,7 @@ retry:
 			panic("Out of memory and no killable processes...\n");
 		}
 
-		if (oom_kill_process(p, points, "Out of memory"))
+		if (oom_kill_process(p, points, "Out of memory", gfp_mask, order))
 			goto retry;
 
 		break;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
