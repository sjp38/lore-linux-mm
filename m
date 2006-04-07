Received: from smtp1.fc.hp.com (smtp1.fc.hp.com [15.15.136.127])
	by atlrel8.hp.com (Postfix) with ESMTP id 8845836D36
	for <linux-mm@kvack.org>; Fri,  7 Apr 2006 16:37:25 -0400 (EDT)
Received: from ldl.fc.hp.com (ldl.fc.hp.com [15.11.146.30])
	by smtp1.fc.hp.com (Postfix) with ESMTP id 64730109C3
	for <linux-mm@kvack.org>; Fri,  7 Apr 2006 20:37:25 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
	by ldl.fc.hp.com (Postfix) with ESMTP id 3C867138E38
	for <linux-mm@kvack.org>; Fri,  7 Apr 2006 14:37:25 -0600 (MDT)
Received: from ldl.fc.hp.com ([127.0.0.1])
	by localhost (ldl [127.0.0.1]) (amavisd-new, port 10024) with ESMTP
	id 22731-07 for <linux-mm@kvack.org>;
	Fri, 7 Apr 2006 14:37:23 -0600 (MDT)
Received: from [16.116.101.121] (unknown [16.116.101.121])
	by ldl.fc.hp.com (Postfix) with ESMTP id 4FCE0138E3A
	for <linux-mm@kvack.org>; Fri,  7 Apr 2006 14:37:22 -0600 (MDT)
Subject: Re: [PATCH 2.6.17-rc1-mm1 3/9] AutoPage Migration - V0.2 - generic
	check/notify internode migration
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <1144441946.5198.52.camel@localhost.localdomain>
References: <1144441946.5198.52.camel@localhost.localdomain>
Content-Type: text/plain
Date: Fri, 07 Apr 2006 16:38:46 -0400
Message-Id: <1144442327.5198.58.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

AutoPage Migration - V0.2 - 3/9 generic check/notify internode migration

V02:  renamed migrate_task_memory() to auto_migrate_task_memory().
      renamed auto-migration enable control.

This patch adds the check for internode migration to be called
from scheduler load balancing, and the check for migration pending
to be called when a task returning to user space notices 'NOTIFY_PENDING.

Check for internode migration:  if automatic memory migration
is enabled [auto_migrate_enable != 0] and this is a user task and the
destination cpu is on a different node from the task's current cpu,
the task will be marked for migration pending via member added to task
struct.  The TIF_NOTIFY_PENDING thread_info flag is set to cause the task
to enter do_notify_resume[_user]() to check for migration pending.

When a task is rescheduled to user space with TIF_NOTIFY_PENDING,
it will check for migration pending, unless SIGKILL is pending.
If the task notices migration pending, it will call
auto_migrate_task_memory() to migrate pages in vma's with default
policy.  Only default policy is affected by migration to a new node.

Note that we can't call auto_migrate_task_memory() with interrupts
disabled.  Temporarily enable interrupts around the call.

These checks become empty macros when 'MIGRATION' is not configured.

Signed-off-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>

Index: linux-2.6.17-rc1-mm1/include/linux/sched.h
===================================================================
--- linux-2.6.17-rc1-mm1.orig/include/linux/sched.h	2006-04-05 10:14:36.000000000 -0400
+++ linux-2.6.17-rc1-mm1/include/linux/sched.h	2006-04-05 10:15:00.000000000 -0400
@@ -908,6 +908,9 @@ struct task_struct {
 #ifdef CONFIG_NUMA
   	struct mempolicy *mempolicy;
 	short il_next;
+#ifdef CONFIG_MIGRATION
+	int migrate_pending;		/* internode mem migration pending */
+#endif
 #endif
 #ifdef CONFIG_CPUSETS
 	struct cpuset *cpuset;
Index: linux-2.6.17-rc1-mm1/include/linux/auto-migrate.h
===================================================================
--- linux-2.6.17-rc1-mm1.orig/include/linux/auto-migrate.h	2006-04-05 10:14:58.000000000 -0400
+++ linux-2.6.17-rc1-mm1/include/linux/auto-migrate.h	2006-04-05 10:15:00.000000000 -0400
@@ -15,8 +15,64 @@ extern void auto_migrate_task_memory(voi
 
 extern int auto_migrate_enable;
 
+#ifdef _LINUX_SCHED_H	/* only used where this is defined */
+static inline void check_internode_migration(task_t *task, int dest_cpu)
+{
+	if (auto_migrate_enable &&
+		task->mm && !(task->flags & PF_BORROWED_MM)) {
+		int node = cpu_to_node(task_cpu(task));
+		if ((node != cpu_to_node(dest_cpu))) {
+			/*
+			 * migrating a user task to a new node.
+			 * mark for memory migration on return to user space.
+			 */
+			struct thread_info *info = task->thread_info;
+			task->migrate_pending = 1;
+			set_bit(TIF_NOTIFY_RESUME, &info->flags);
+		}
+	}
+}
+
+static inline void check_migrate_pending(void)
+{
+	if (!auto_migrate_enable)
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
+		auto_migrate_task_memory();
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
 #else	/* !CONFIG_MIGRATION */
 
+#define check_internode_migration(t,c)	/* NOTHING */
+
+#define check_migrate_pending()		/* NOTHING */
+
 #endif	/* CONFIG_MIGRATION */
 
 #endif


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
