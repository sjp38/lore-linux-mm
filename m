Received: from smtp1.fc.hp.com (smtp1.fc.hp.com [15.15.136.127])
	by atlrel9.hp.com (Postfix) with ESMTP id E78E835025
	for <linux-mm@kvack.org>; Fri,  7 Apr 2006 16:41:18 -0400 (EDT)
Received: from ldl.fc.hp.com (linux-bugs.fc.hp.com [15.11.146.30])
	by smtp1.fc.hp.com (Postfix) with ESMTP id C08CB102C9
	for <linux-mm@kvack.org>; Fri,  7 Apr 2006 20:41:18 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
	by ldl.fc.hp.com (Postfix) with ESMTP id 78C8C138E39
	for <linux-mm@kvack.org>; Fri,  7 Apr 2006 14:41:18 -0600 (MDT)
Received: from ldl.fc.hp.com ([127.0.0.1])
	by localhost (ldl [127.0.0.1]) (amavisd-new, port 10024) with ESMTP
	id 23160-05 for <linux-mm@kvack.org>;
	Fri, 7 Apr 2006 14:41:16 -0600 (MDT)
Received: from [16.116.101.121] (unknown [16.116.101.121])
	by ldl.fc.hp.com (Postfix) with ESMTP id 44064138E38
	for <linux-mm@kvack.org>; Fri,  7 Apr 2006 14:41:16 -0600 (MDT)
Subject: Re: [PATCH 2.6.17-rc1-mm1 7/9] AutoPage Migration - V0.2 - add
	hysteresis to internode migration
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <1144441946.5198.52.camel@localhost.localdomain>
References: <1144441946.5198.52.camel@localhost.localdomain>
Content-Type: text/plain
Date: Fri, 07 Apr 2006 16:42:40 -0400
Message-Id: <1144442561.5198.67.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

AutoPage Migration - V0.2 - 7/9 add hysteresis to internode migration

V0.2:	moved to mm/migrate.c; renamed to "auto_migrate_interval"

This patch adds hysteresis to the internode migration to prevent
page migration trashing when automatic scheduler driven page migration
is enabled.  

Add static in-line function "too_soon_for_internode_migration"
[macro => 0 if !CONFIG_MIGRATION] to check for attempts to move
task to a new node sooner than auto_migrate_interval jiffies
after previous migration.

Modify try_to_wakeup() to leave task on its current cpu if too
soon to move it to a different node.

Modify can_migrate_task() to "just say no!" if the load balancer
proposes an internode migration too soon after previous internode
migration.

Added a control variable--auto_migrate_interval--to /sys/kernel/migration
to query/set the interval.  Provide some fairly arbitrary min, max and
default values.

Signed-off-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>

Index: linux-2.6.17-rc1-mm1/include/linux/sched.h
===================================================================
--- linux-2.6.17-rc1-mm1.orig/include/linux/sched.h	2006-04-05 10:15:00.000000000 -0400
+++ linux-2.6.17-rc1-mm1/include/linux/sched.h	2006-04-05 10:16:26.000000000 -0400
@@ -909,6 +909,7 @@ struct task_struct {
   	struct mempolicy *mempolicy;
 	short il_next;
 #ifdef CONFIG_MIGRATION
+	unsigned long next_migrate;	/* internode migration hysteresis */
 	int migrate_pending;		/* internode mem migration pending */
 #endif
 #endif
Index: linux-2.6.17-rc1-mm1/mm/migrate.c
===================================================================
--- linux-2.6.17-rc1-mm1.orig/mm/migrate.c	2006-04-05 10:14:58.000000000 -0400
+++ linux-2.6.17-rc1-mm1/mm/migrate.c	2006-04-05 10:16:26.000000000 -0400
@@ -26,6 +26,7 @@
 #include <linux/cpuset.h>
 #include <linux/swapops.h>
 #include <linux/sysfs.h>
+#include <linux/auto-migrate.h>
 
 #include "internal.h"
 
@@ -73,11 +74,45 @@ static ssize_t auto_migrate_enable_store
 }
 MIGRATION_ATTR_RW(auto_migrate_enable);
 
+/*
+ * auto_migrate_interval:  minimum interval between internode
+ * task migration when auto-migration enabled.
+ * units:  jiffies
+ */
+unsigned long auto_migrate_interval     = AUTO_MIGRATE_INTERVAL_DFLT;
+
+//TODO:  __setup function for boot command option
+
+static ssize_t auto_migrate_interval_show(struct subsystem *subsys,
+					 char *page)
+{
+	return sprintf(page, "auto_migrate_interval %ld\n",
+		 auto_migrate_interval/HZ );
+}
+static ssize_t auto_migrate_interval_store(struct subsystem *subsys,
+				      const char *page, size_t count)
+{
+        unsigned long n = simple_strtoul(page, NULL, 10) * HZ;
+
+	/*
+	 * silently clip to min/max
+	 */
+	if (n < AUTO_MIGRATE_INTERVAL_MIN)
+		auto_migrate_interval = AUTO_MIGRATE_INTERVAL_MIN;
+	else if (n > AUTO_MIGRATE_INTERVAL_MAX)
+		auto_migrate_interval = AUTO_MIGRATE_INTERVAL_MAX;
+	else
+		auto_migrate_interval = n;
+        return count;
+}
+MIGRATION_ATTR_RW(auto_migrate_interval);
+
 decl_subsys(migration, NULL, NULL);
 EXPORT_SYMBOL(migration_subsys);
 
 static struct attribute *migration_attrs[] = {
 	&auto_migrate_enable_attr.attr,
+	&auto_migrate_interval_attr.attr,
 	NULL
 };
 
Index: linux-2.6.17-rc1-mm1/include/linux/auto-migrate.h
===================================================================
--- linux-2.6.17-rc1-mm1.orig/include/linux/auto-migrate.h	2006-04-05 10:15:00.000000000 -0400
+++ linux-2.6.17-rc1-mm1/include/linux/auto-migrate.h	2006-04-05 10:16:26.000000000 -0400
@@ -15,6 +15,11 @@ extern void auto_migrate_task_memory(voi
 
 extern int auto_migrate_enable;
 
+extern unsigned long auto_migrate_interval;    /* seconds <=> jiffies */
+#define AUTO_MIGRATE_INTERVAL_DFLT (30*HZ)
+#define AUTO_MIGRATE_INTERVAL_MIN (5*HZ)
+#define AUTO_MIGRATE_INTERVAL_MAX (300*HZ)
+
 #ifdef _LINUX_SCHED_H	/* only used where this is defined */
 static inline void check_internode_migration(task_t *task, int dest_cpu)
 {
@@ -33,6 +38,25 @@ static inline void check_internode_migra
 	}
 }
 
+/*
+ * To avoids page migration thrashing when auto memory migration is enabled,
+ * check user task for too recent internode migration.
+ */
+static inline int too_soon_for_internode_migration(task_t *task,
+                                                         int this_cpu)
+{
+	if (auto_migrate_enable &&
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
 static inline void check_migrate_pending(void)
 {
 	if (!auto_migrate_enable)
@@ -55,6 +79,7 @@ static inline void check_migrate_pending
 		}
 
 		auto_migrate_task_memory();
+		current->next_migrate = jiffies + auto_migrate_interval;
 
 		if (likely(disable_irqs))
 			local_irq_disable();
@@ -70,6 +95,7 @@ out:
 #else	/* !CONFIG_MIGRATION */
 
 #define check_internode_migration(t,c)	/* NOTHING */
+#define too_soon_for_internode_migration(t,c) 0
 
 #define check_migrate_pending()		/* NOTHING */
 
Index: linux-2.6.17-rc1-mm1/kernel/sched.c
===================================================================
--- linux-2.6.17-rc1-mm1.orig/kernel/sched.c	2006-04-05 10:16:13.000000000 -0400
+++ linux-2.6.17-rc1-mm1/kernel/sched.c	2006-04-05 10:16:26.000000000 -0400
@@ -1378,7 +1378,8 @@ static int try_to_wake_up(task_t *p, uns
 		}
 	}
 
-	if (unlikely(!cpu_isset(this_cpu, p->cpus_allowed)))
+	if (unlikely(!cpu_isset(this_cpu, p->cpus_allowed)
+		|| too_soon_for_internode_migration(p, this_cpu)))
 		goto out_set_cpu;
 
 	/*
@@ -2013,6 +2014,7 @@ int can_migrate_task(task_t *p, runqueue
 	 * 1) running (obviously), or
 	 * 2) cannot be migrated to this CPU due to cpus_allowed, or
 	 * 3) are cache-hot on their current CPU.
+	 * 4) too soon since last internode migration
 	 */
 	if (!cpu_isset(this_cpu, p->cpus_allowed))
 		return 0;
@@ -2021,6 +2023,10 @@ int can_migrate_task(task_t *p, runqueue
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
