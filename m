Received: from mailrelay01.cce.cpqcorp.net (relay.cpqcorp.net [16.47.68.171])
	by ccerelbas01.cce.hp.com (Postfix) with ESMTP id 9FB6634053
	for <linux-mm@kvack.org>; Fri, 10 Mar 2006 13:54:59 -0600 (CST)
Received: from anw.zk3.dec.com (and.zk3.dec.com [16.140.64.3])
	by mailrelay01.cce.cpqcorp.net (Postfix) with ESMTP id 683528524
	for <linux-mm@kvack.org>; Fri, 10 Mar 2006 13:54:59 -0600 (CST)
Subject: [PATCH/RFC] AutoPage Migration - V0.1 - 7/8 add hysteresis to
	internode migration
From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Reply-To: lee.schermerhorn@hp.com
Content-Type: text/plain
Date: Fri, 10 Mar 2006 14:54:39 -0500
Message-Id: <1142020480.5204.29.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

AutoPage Migration - V0.1 - 7/8 add hysteresis to internode migration

This patch adds hysteresis to the internode migration to prevent
page migration trashing when scheduler driven page migration is
enabled.  

Add static in-line function "too_soon_for_internode_migration"
[macro => 0 if !CONFIG_MIGRATION] to check for attempts to move
task to a new node sooner than sched_migrate_interval jiffies
after previous migration.

Modify try_to_wakeup() to leave task on its current cpu if too
soon to move it to a different node.

Modify can_migrate_task() to "just say no!" if the load balancer
proposes an internode migration too soon after previous internode
migration.

Added a control variable--sched_migrate_interval--to /sys/kernel/migration
to query/set the interval.  Provide some fairly arbitrary min, max and
default values.

Signed-off-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>

Index: linux-2.6.16-rc5-git6/include/linux/sched.h
===================================================================
--- linux-2.6.16-rc5-git6.orig/include/linux/sched.h	2006-03-03 13:18:02.000000000 -0500
+++ linux-2.6.16-rc5-git6/include/linux/sched.h	2006-03-03 13:43:39.000000000 -0500
@@ -864,6 +864,7 @@ struct task_struct {
   	struct mempolicy *mempolicy;
 	short il_next;
 #ifdef CONFIG_MIGRATION
+	unsigned long next_migrate;	/* internode migration hysteresis */
 	int migrate_pending;		/* internode mem migration pending */
 #endif
 #endif
Index: linux-2.6.16-rc5-git6/include/linux/auto-migrate.h
===================================================================
--- linux-2.6.16-rc5-git6.orig/include/linux/auto-migrate.h	2006-03-03 13:18:02.000000000 -0500
+++ linux-2.6.16-rc5-git6/include/linux/auto-migrate.h	2006-03-03 13:43:39.000000000 -0500
@@ -13,6 +13,12 @@
 
 extern int sched_migrate_memory;	/* sysctl:  enable/disable */
 
+extern unsigned long sched_migrate_interval;	/* sysctl:  seconds <=> jiffies */
+#define SCHED_MIGRATE_INTERVAL_DFLT (30*HZ)
+#define SCHED_MIGRATE_INTERVAL_MIN (5*HZ)
+#define SCHED_MIGRATE_INTERVAL_MAX (300*HZ)
+
+
 #ifdef _LINUX_SCHED_H	/* only used where this is defined */
 static inline void check_internode_migration(task_t *task, int dest_cpu)
 {
@@ -32,6 +38,25 @@ static inline void check_internode_migra
 	}
 }
 
+/*
+ * To avoids page migration thrashing when memory migration is enabled,
+ * check user task for too recent internode migration.
+ */
+static inline int too_soon_for_internode_migration(task_t *task,
+							 int this_cpu)
+{
+	if (sched_migrate_memory &&
+		task->mm && !(task->flags & PF_BORROWED_MM) &&
+		cpu_to_node(task_cpu(task)) != cpu_to_node(this_cpu)) {
+
+		if (task->migrate_pending ||
+			time_before(jiffies, task->next_migrate))
+			return 1;
+	}
+
+	return 0;
+}
+
 extern void migrate_task_memory(void);
 
 static inline void check_migrate_pending(void)
@@ -56,6 +81,7 @@ static inline void check_migrate_pending
 		}
 
 		migrate_task_memory();
+		current->next_migrate = jiffies + sched_migrate_interval;
 
 		if (likely(disable_irqs))
 			local_irq_disable();
@@ -71,6 +97,7 @@ out:
 #else	/* !CONFIG_MIGRATION */
 
 #define check_internode_migration(t,c)	/* NOTHING */
+#define too_soon_for_internode_migration(t,c) 0
 
 #define check_migrate_pending()		/* NOTHING */
 
Index: linux-2.6.16-rc5-git6/mm/mempolicy.c
===================================================================
--- linux-2.6.16-rc5-git6.orig/mm/mempolicy.c	2006-03-03 13:18:02.000000000 -0500
+++ linux-2.6.16-rc5-git6/mm/mempolicy.c	2006-03-03 15:55:22.000000000 -0500
@@ -87,6 +87,7 @@
 #include <linux/seq_file.h>
 #include <linux/proc_fs.h>
 #include <linux/sysfs.h>
+#include <linux/auto-migrate.h>
 
 #include <asm/tlbflush.h>
 #include <asm/uaccess.h>
@@ -153,12 +154,46 @@ static ssize_t sched_migrate_memory_stor
 }
 MIGRATION_ATTR_RW(sched_migrate_memory);
 
+/*
+ * sched_migrate_interval:  minimum interval between internode
+ * task migration when 'sched_memory_migrate' enabled.
+ * units:  jiffies
+ */
+unsigned long sched_migrate_interval     = SCHED_MIGRATE_INTERVAL_DFLT;
+
+//TODO:  __setup function for boot command option
+
+static ssize_t sched_migrate_interval_show(struct subsystem *subsys,
+					 char *page)
+{
+	return sprintf(page, "sched_migrate_interval %ld\n",
+		 sched_migrate_interval/HZ );
+}
+static ssize_t sched_migrate_interval_store(struct subsystem *subsys,
+				      const char *page, size_t count)
+{
+        unsigned long n = simple_strtoul(page, NULL, 10) * HZ;
+
+	/*
+	 * silently clip to min/max
+	 */
+	if (n < SCHED_MIGRATE_INTERVAL_MIN)
+		sched_migrate_interval = SCHED_MIGRATE_INTERVAL_MIN;
+	else if (n > SCHED_MIGRATE_INTERVAL_MAX)
+		sched_migrate_interval = SCHED_MIGRATE_INTERVAL_MAX;
+	else
+		sched_migrate_interval = n;
+        return count;
+}
+MIGRATION_ATTR_RW(sched_migrate_interval);
+
 
 decl_subsys(migration, NULL, NULL);
 EXPORT_SYMBOL(migration_subsys);
 
 static struct attribute *migration_attrs[] = {
 	&sched_migrate_memory_attr.attr,
+	&sched_migrate_interval_attr.attr,
 	NULL
 };
 
Index: linux-2.6.16-rc5-git6/kernel/sched.c
===================================================================
--- linux-2.6.16-rc5-git6.orig/kernel/sched.c	2006-03-03 13:32:07.000000000 -0500
+++ linux-2.6.16-rc5-git6/kernel/sched.c	2006-03-03 13:43:39.000000000 -0500
@@ -1206,7 +1206,8 @@ static int try_to_wake_up(task_t *p, uns
 		}
 	}
 
-	if (unlikely(!cpu_isset(this_cpu, p->cpus_allowed)))
+	if (unlikely(!cpu_isset(this_cpu, p->cpus_allowed)
+		|| too_soon_for_internode_migration(p, this_cpu)))
 		goto out_set_cpu;
 
 	/*
@@ -1808,6 +1809,7 @@ int can_migrate_task(task_t *p, runqueue
 	 * 1) running (obviously), or
 	 * 2) cannot be migrated to this CPU due to cpus_allowed, or
 	 * 3) are cache-hot on their current CPU.
+	 * 4) too soon since last internode migration
 	 */
 	if (!cpu_isset(this_cpu, p->cpus_allowed))
 		return 0;
@@ -1816,6 +1818,10 @@ int can_migrate_task(task_t *p, runqueue
 	if (task_running(rq, p))
 		return 0;
 
+// TODO:  should this be under Agressive migration?
+	if (too_soon_for_internode_migration(p, this_cpu))
+		return 0;
+
 	/*
 	 * Aggressive migration if:
 	 * 1) task is cache cold, or


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
