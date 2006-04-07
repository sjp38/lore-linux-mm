Received: from smtp1.fc.hp.com (smtp.fc.hp.com [15.15.136.127])
	by atlrel6.hp.com (Postfix) with ESMTP id 8DD8C34996
	for <linux-mm@kvack.org>; Fri,  7 Apr 2006 16:36:25 -0400 (EDT)
Received: from ldl.fc.hp.com (ldl.fc.hp.com [15.11.146.30])
	by smtp1.fc.hp.com (Postfix) with ESMTP id 62FA0109C3
	for <linux-mm@kvack.org>; Fri,  7 Apr 2006 20:36:25 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
	by ldl.fc.hp.com (Postfix) with ESMTP id 2D36D138E3A
	for <linux-mm@kvack.org>; Fri,  7 Apr 2006 14:36:25 -0600 (MDT)
Received: from ldl.fc.hp.com ([127.0.0.1])
	by localhost (ldl [127.0.0.1]) (amavisd-new, port 10024) with ESMTP
	id 22731-02 for <linux-mm@kvack.org>;
	Fri, 7 Apr 2006 14:36:23 -0600 (MDT)
Received: from [16.116.101.121] (unknown [16.116.101.121])
	by ldl.fc.hp.com (Postfix) with ESMTP id E3B37138E38
	for <linux-mm@kvack.org>; Fri,  7 Apr 2006 14:36:22 -0600 (MDT)
Subject: Re: [PATCH 2.6.17-rc1-mm1 2/9] AutoPage Migration - V0.2 - add
	auto_migrate_enable sysctl
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <1144441946.5198.52.camel@localhost.localdomain>
References: <1144441946.5198.52.camel@localhost.localdomain>
Content-Type: text/plain
Date: Fri, 07 Apr 2006 16:37:47 -0400
Message-Id: <1144442267.5198.56.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

AutoPage Migration - V0.2 - 2/9 add auto_migrate_enable sysctl

V0.2:  moved controls to mm/migrate.c
	renamed "sched_migrate_memory" to "auto_migrate_enable"

This patch adds the infrastructure for "migration controls" under
/sys/kernel/migration.  It also adds a single such control--
auto_migrate_enable--to enable/disable automatic, scheduler driven
task memory migration.  May also be initialized from boot command
line option.

Default is disabled!

Signed-off-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>

Index: linux-2.6.16-mm1/mm/migrate.c
===================================================================
--- linux-2.6.16-mm1.orig/mm/migrate.c	2006-03-23 16:49:16.000000000 -0500
+++ linux-2.6.16-mm1/mm/migrate.c	2006-03-23 16:49:40.000000000 -0500
@@ -25,8 +25,7 @@
 #include <linux/cpu.h>
 #include <linux/cpuset.h>
 #include <linux/swapops.h>
-
-#include "internal.h"
+#include <linux/sysfs.h>
 
 #include "internal.h"
 
@@ -36,6 +35,76 @@
 #define lru_to_page(_head) (list_entry((_head)->prev, struct page, lru))
 
 /*
+ * System Controls for [auto] migration
+ */
+#define MIGRATION_ATTR_RW(_name) \
+static struct subsys_attribute _name##_attr = \
+	__ATTR(_name, 0644, _name##_show, _name##_store)
+
+/*
+ * auto_migrate_enable:  boot option and sysctl to enable/disable
+ * memory migration on inter-node task migration due to scheduler
+ * load balancing or change in cpu affinity.
+ */
+int auto_migrate_enable = 0;
+
+static int __init set_auto_migrate_enable(char *str)
+{
+	get_option(&str, &auto_migrate_enable);
+	return 1;
+}
+
+__setup("auto_migrate_enable", set_auto_migrate_enable);
+
+static ssize_t auto_migrate_enable_show(struct subsystem *subsys, char *page)
+{
+	return sprintf(page, "auto_migrate_enable %s\n",
+			auto_migrate_enable ? "on" : "off");
+}
+static ssize_t auto_migrate_enable_store(struct subsystem *subsys,
+				      const char *page, size_t count)
+{
+        unsigned long n = simple_strtoul(page, NULL, 10);
+	if (n)
+		auto_migrate_enable = 1;
+	else
+		auto_migrate_enable = 0;
+        return count;
+}
+MIGRATION_ATTR_RW(auto_migrate_enable);
+
+decl_subsys(migration, NULL, NULL);
+EXPORT_SYMBOL(migration_subsys);
+
+static struct attribute *migration_attrs[] = {
+	&auto_migrate_enable_attr.attr,
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
+/*
  * Isolate one page from the LRU lists. If successful put it onto
  * the indicated list with elevated page count.
  *
Index: linux-2.6.16-mm1/include/linux/auto-migrate.h
===================================================================
--- linux-2.6.16-mm1.orig/include/linux/auto-migrate.h	2006-03-23 16:49:34.000000000 -0500
+++ linux-2.6.16-mm1/include/linux/auto-migrate.h	2006-03-23 16:49:40.000000000 -0500
@@ -13,6 +13,8 @@
 
 extern void auto_migrate_task_memory(void);
 
+extern int auto_migrate_enable;
+
 #else	/* !CONFIG_MIGRATION */
 
 #endif	/* CONFIG_MIGRATION */


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
