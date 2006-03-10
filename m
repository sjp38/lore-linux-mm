Received: from taynzmail03.nz-tay.cpqcorp.net (relay.cpqcorp.net [16.47.4.103])
	by atlrel6.hp.com (Postfix) with ESMTP id 0E70D34450
	for <linux-mm@kvack.org>; Fri, 10 Mar 2006 14:43:58 -0500 (EST)
Received: from anw.zk3.dec.com (or.zk3.dec.com [16.140.48.4])
	by taynzmail03.nz-tay.cpqcorp.net (Postfix) with ESMTP id B7AD51735
	for <linux-mm@kvack.org>; Fri, 10 Mar 2006 14:43:57 -0500 (EST)
Subject: [PATCH/RFC] AutoPage Migration - V0.1 - 2/8 add
	sched_migrate_memory sysctl
From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Reply-To: lee.schermerhorn@hp.com
Content-Type: text/plain
Date: Fri, 10 Mar 2006 14:43:38 -0500
Message-Id: <1142019818.5204.17.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

AutoPage Migration - V0.1 - 2/8 add sched_migrate_memory sysctl

This patch adds the infrastructure for "migration controls" under
/sys/kernel/migration.  It also adds a single such control--
sched_migrate_memory--to enable/disable scheduler driven task memory
migration.  May also be initialized from boot command line option.

Default is disabled!

Note that this patch also introduces a new header:  <linux/auto-migrate.h>
to contain the minimal memory migration definitions required to
hook the migration to the scheduler's inter-node task migration.
At this point, the header contains only the extern declaration for
the sched_migrate_memory control.

Signed-off-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>

Index: linux-2.6.16-rc5-git6/include/linux/auto-migrate.h
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux-2.6.16-rc5-git6/include/linux/auto-migrate.h	2006-03-03 12:46:01.000000000 -0500
@@ -0,0 +1,20 @@
+#ifndef _LINUX_AUTO_MIGRATE_H
+#define _LINUX_AUTO_MIGRATE_H
+
+/*
+ * minimal memory migration definitions need by scheduler,
+ * sysctl, ..., so that they don't need to drag in the entire
+ * mempolicy.h and all that it depends on.
+ */
+
+#include <linux/config.h>
+
+#ifdef CONFIG_MIGRATION
+
+extern int sched_migrate_memory;	/* sysctl:  enable/disable */
+
+#else
+
+#endif
+
+#endif
Index: linux-2.6.16-rc5-git6/mm/mempolicy.c
===================================================================
--- linux-2.6.16-rc5-git6.orig/mm/mempolicy.c	2006-03-03 10:05:39.000000000 -0500
+++ linux-2.6.16-rc5-git6/mm/mempolicy.c	2006-03-03 12:47:11.000000000 -0500
@@ -86,6 +86,7 @@
 #include <linux/swap.h>
 #include <linux/seq_file.h>
 #include <linux/proc_fs.h>
+#include <linux/sysfs.h>
 
 #include <asm/tlbflush.h>
 #include <asm/uaccess.h>
@@ -112,6 +113,78 @@ struct mempolicy default_policy = {
 	.policy = MPOL_DEFAULT,
 };
 
+/*
+ * System Controls for [auto] migration
+ */
+#define MIGRATION_ATTR_RW(_name) \
+static struct subsys_attribute _name##_attr = \
+	__ATTR(_name, 0644, _name##_show, _name##_store)
+
+
+/*
+ * sched_migrate_memory:  boot option and sysctl to enable/disable
+ * memory migration on inter-node task migration due to scheduler
+ * load balancing or change in cpu affinity.
+ */
+int sched_migrate_memory = 0;
+
+static int __init set_sched_migrate_memory(char *str)
+{
+	get_option(&str, &sched_migrate_memory);
+	return 1;
+}
+
+__setup("sched_migrate_memory", set_sched_migrate_memory);
+
+static ssize_t sched_migrate_memory_show(struct subsystem *subsys, char *page)
+{
+	return sprintf(page, "sched_migrate_memory %s\n",
+			sched_migrate_memory ? "on" : "off");
+}
+static ssize_t sched_migrate_memory_store(struct subsystem *subsys,
+				      const char *page, size_t count)
+{
+        unsigned long n = simple_strtoul(page, NULL, 10);
+	if (n)
+		sched_migrate_memory = 1;
+	else
+		sched_migrate_memory = 0;
+        return count;
+}
+MIGRATION_ATTR_RW(sched_migrate_memory);
+
+
+decl_subsys(migration, NULL, NULL);
+EXPORT_SYMBOL(migration_subsys);
+
+static struct attribute *migration_attrs[] = {
+	&sched_migrate_memory_attr.attr,
+	NULL
+};
+
+static struct attribute_group migration_attr_group = {
+	.attrs = migration_attrs,
+};
+
+static int __init migration_control_init(void)
+{
+	int error;
+
+	/*
+	 * child of kernel subsys
+	 */
+	kset_set_kset_s(&migration_subsys, kernel_subsys);
+	error = subsystem_register(&migration_subsys);
+	if (!error)
+		error = sysfs_create_group(&migration_subsys.kset.kobj,
+					   &migration_attr_group);
+	return error;
+}
+subsys_initcall(migration_control_init);
+/*
+ * end Migration System Controls
+ */
+
 /* Return effective policy for a VMA */
 static struct mempolicy * get_vma_policy(struct task_struct *task,
 		struct vm_area_struct *vma, unsigned long addr)
@@ -130,6 +203,7 @@ static struct mempolicy * get_vma_policy
 	return pol;
 }
 
+
 /* Do sanity checking on a policy */
 static int mpol_check_policy(int mode, nodemask_t *nodes)
 {


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
