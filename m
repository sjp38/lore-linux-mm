Received: from mailrelay01.cce.cpqcorp.net (relay.cpqcorp.net [16.47.68.171])
	by ccerelbas03.cce.hp.com (Postfix) with ESMTP id 2128034020
	for <linux-mm@kvack.org>; Fri, 10 Mar 2006 13:46:19 -0600 (CST)
Received: from anw.zk3.dec.com (wasted.zk3.dec.com [16.140.32.3])
	by mailrelay01.cce.cpqcorp.net (Postfix) with ESMTP id DD063858B
	for <linux-mm@kvack.org>; Fri, 10 Mar 2006 13:46:18 -0600 (CST)
Subject: [PATCH/RFC] AutoPage Migration - V0.1 - 3/8 generic check/notify
	internode migration
From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Reply-To: lee.schermerhorn@hp.com
Content-Type: text/plain
Date: Fri, 10 Mar 2006 14:45:59 -0500
Message-Id: <1142019959.5204.19.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

AutoPage Migration - V0.1 - 3/8 generic check/notify internode migration

This patch adds the check for internode migration to be called
from scheduler load balancing, and the check for migration pending
to be called when a task returning to user space notices
'NOTIFY_PENDING.

Check for internode migration:  if scheduler driven memory migration
is enabled [sched_migrate_memory != 0] and this is a user task and the
destination cpu is on a different node from the task's current cpu,
the task will be marked for migration pending via member added to task
struct.  The TIF_NOTIFY_PENDING thread_info flag is set to cause the
task
to enter do_notify_resume[_user]() to check for migration pending.

When a task is rescheduled to user space with TIF_NOTIFY_PENDING,
it will check for migration pending, unless SIGKILL is pending.
If the task notices migration pending, it will call a
migrate_task_memory()
to migrate pages in vma's with default policy.  Only default policy
is affected by migration to a new node.

Note that we can't call migrate_task_memory() with interrupts disabled.
Temporarily enable interrupts around the call.

These checks become empty macros when 'MIGRATION' is not configured.

Signed-off-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>

Index: linux-2.6.16-rc5-git6/include/linux/sched.h
===================================================================
--- linux-2.6.16-rc5-git6.orig/include/linux/sched.h	2006-03-02
16:40:44.000000000 -0500
+++ linux-2.6.16-rc5-git6/include/linux/sched.h	2006-03-03
10:42:27.000000000 -0500
@@ -863,6 +863,9 @@ struct task_struct {
 #ifdef CONFIG_NUMA
   	struct mempolicy *mempolicy;
 	short il_next;
+#ifdef CONFIG_MIGRATION
+	int migrate_pending;		/* internode mem migration pending */
+#endif
 #endif
 #ifdef CONFIG_CPUSETS
 	struct cpuset *cpuset;
Index: linux-2.6.16-rc5-git6/include/linux/auto-migrate.h
===================================================================
--- linux-2.6.16-rc5-git6.orig/include/linux/auto-migrate.h	2006-03-03
10:06:58.000000000 -0500
+++ linux-2.6.16-rc5-git6/include/linux/auto-migrate.h	2006-03-03
10:42:05.000000000 -0500
@@ -13,8 +13,67 @@
 
 extern int sched_migrate_memory;	/* sysctl:  enable/disable */
 
-#else
+#ifdef _LINUX_SCHED_H	/* only used where this is defined */
+static inline void check_internode_migration(task_t *task, int
dest_cpu)
+{
+	if (sched_migrate_memory &&
+		task->mm && !(task->flags & PF_BORROWED_MM)) {
+		int node = cpu_to_node(task_cpu(task));
+		if ((node != cpu_to_node(dest_cpu))) {
+			/*
+			 * migrating a user task to a new node.
+			 * mark for memory migration on return to user space.
+			 */
+			struct thread_info *info = task->thread_info;
 
-#endif
+			task->migrate_pending = 1;
+			set_bit(TIF_NOTIFY_RESUME, &info->flags);
+		}
+	}
+}
 
-#endif
+extern void migrate_task_memory(void);
+
+static inline void check_migrate_pending(void)
+{
+	if (!sched_migrate_memory)
+		goto out;
+
+	/*
+	 * Don't bother with memory migration prep if 'KILL pending
+	 */
+	if (test_thread_flag(TIF_SIGPENDING) &&
+		(sigismember(&current->pending.signal, SIGKILL) ||
+		sigismember(&current->signal->shared_pending.signal, SIGKILL)))
+		goto out;
+
+	if (unlikely(current->migrate_pending)) {
+		int disable_irqs = 0;
+
+		if (likely(irqs_disabled())) {
+			disable_irqs = 1;
+			local_irq_enable();
+		}
+
+		migrate_task_memory();
+
+		if (likely(disable_irqs))
+			local_irq_disable();
+	}
+
+out:
+	current->migrate_pending = 0;
+	clear_thread_flag(TIF_NOTIFY_RESUME);
+	return;
+}
+#endif /* _LINUX_SCHED_H */
+
+#else	/* !CONFIG_MIGRATION */
+
+#define check_internode_migration(t,c)	/* NOTHING */
+
+#define check_migrate_pending()		/* NOTHING */
+
+#endif	/* CONFIG_MIGRATION */
+
+#endif /* _LINUX_AUTO_MIGRATE_H */


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
