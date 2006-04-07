Received: from smtp2.fc.hp.com (smtp.fc.hp.com [15.11.136.114])
	by atlrel7.hp.com (Postfix) with ESMTP id 9ED3534E67
	for <linux-mm@kvack.org>; Fri,  7 Apr 2006 16:43:48 -0400 (EDT)
Received: from ldl.fc.hp.com (ldl.fc.hp.com [15.11.146.30])
	by smtp2.fc.hp.com (Postfix) with ESMTP id 79DE1AD24
	for <linux-mm@kvack.org>; Fri,  7 Apr 2006 20:43:48 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
	by ldl.fc.hp.com (Postfix) with ESMTP id 55911138E39
	for <linux-mm@kvack.org>; Fri,  7 Apr 2006 14:43:48 -0600 (MDT)
Received: from ldl.fc.hp.com ([127.0.0.1])
	by localhost (ldl [127.0.0.1]) (amavisd-new, port 10024) with ESMTP
	id 23197-10 for <linux-mm@kvack.org>;
	Fri, 7 Apr 2006 14:43:46 -0600 (MDT)
Received: from [16.116.101.121] (unknown [16.116.101.121])
	by ldl.fc.hp.com (Postfix) with ESMTP id 1B6B2138E38
	for <linux-mm@kvack.org>; Fri,  7 Apr 2006 14:43:46 -0600 (MDT)
Subject: Re: [PATCH 2.6.17-rc1-mm1 9/9] AutoPage Migration - V0.2 - hook
	automigration to migrate-on-fault
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <1144441946.5198.52.camel@localhost.localdomain>
References: <1144441946.5198.52.camel@localhost.localdomain>
Content-Type: text/plain
Date: Fri, 07 Apr 2006 16:45:10 -0400
Message-Id: <1144442710.5198.71.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

AutoPage Migration - V0.2 - 9/9 hook automigration to migrate-on-fault

Add a /sys/kernel/migration control--auto_migrate_lazy--to use 
migrate-on-fault for auto-migration.

Modify migrate_to_node() to just unmap the eligible pages
via migrate_pages_unmap_only() when MPOL_MF_LAZY flag is set.

This patch depends on the "migrate-on-fault" patch series that
defines the MPOL_MF_LAZY flag and the migrate_pages_unmap_only()
function.

Signed-off-by: Lee Schermerhorn <lee.schermerhorn@hp.com>

Index: linux-2.6.16-mm1/mm/mempolicy.c
===================================================================
--- linux-2.6.16-mm1.orig/mm/mempolicy.c	2006-03-23 16:50:30.000000000 -0500
+++ linux-2.6.16-mm1/mm/mempolicy.c	2006-03-23 16:50:36.000000000 -0500
@@ -635,7 +635,11 @@ int migrate_to_node(struct mm_struct *mm
 			flags | MPOL_MF_DISCONTIG_OK, &pagelist);
 
 	if (!list_empty(&pagelist)) {
-		err = migrate_pages_to(&pagelist, NULL, dest);
+		if (flags & MPOL_MF_LAZY)
+			err = migrate_pages_unmap_only(&pagelist);
+		else
+			err = migrate_pages_to(&pagelist, NULL, dest);
+
 		if (!list_empty(&pagelist))
 			putback_lru_pages(&pagelist);
 	}
@@ -744,6 +748,9 @@ void auto_migrate_task_memory(void)
 	 */
 	BUG_ON(!mm);
 
+	if (auto_migrate_lazy)
+		flags |= MPOL_MF_LAZY;
+
 	/*
 	 * Pass destination node as source node plus 'INVERT flag:
 	 *    Migrate all pages NOT on destination node.
@@ -1000,7 +1007,6 @@ out:
 	return err;
 }
 
-
 /* Retrieve NUMA policy */
 asmlinkage long sys_get_mempolicy(int __user *policy,
 				unsigned long __user *nmask,
Index: linux-2.6.16-mm1/mm/migrate.c
===================================================================
--- linux-2.6.16-mm1.orig/mm/migrate.c	2006-03-23 16:50:30.000000000 -0500
+++ linux-2.6.16-mm1/mm/migrate.c	2006-03-23 16:50:36.000000000 -0500
@@ -129,6 +129,37 @@ static ssize_t migrate_max_mapcount_stor
 }
 MIGRATION_ATTR_RW(migrate_max_mapcount);
 
+/*
+ * auto_migrate_lazy:  use "lazy migration"--i.e., migration-on-fault--
+ * for scheduler driven task memory migration.
+ */
+int auto_migrate_lazy = 0;
+
+static int __init set_auto_migrate_lazy(char *str)
+{
+	get_option(&str, &auto_migrate_lazy);
+	return 1;
+}
+
+__setup("auto_migrate_lazy", set_auto_migrate_lazy);
+
+static ssize_t auto_migrate_lazy_show(struct subsystem *subsys, char *page)
+{
+	return sprintf(page, "auto_migrate_lazy %s\n",
+			auto_migrate_lazy ? "on" : "off");
+}
+static ssize_t auto_migrate_lazy_store(struct subsystem *subsys,
+				      const char *page, size_t count)
+{
+        unsigned long n = simple_strtoul(page, NULL, 10);
+	if (n)
+		auto_migrate_lazy = 1;
+	else
+		auto_migrate_lazy = 0;
+        return count;
+}
+MIGRATION_ATTR_RW(auto_migrate_lazy);
+
 decl_subsys(migration, NULL, NULL);
 EXPORT_SYMBOL(migration_subsys);
 
@@ -136,6 +167,7 @@ static struct attribute *migration_attrs
 	&auto_migrate_enable_attr.attr,
 	&auto_migrate_interval_attr.attr,
 	&migrate_max_mapcount_attr.attr,
+	&auto_migrate_lazy_attr.attr,
 	NULL
 };
 
Index: linux-2.6.16-mm1/include/linux/auto-migrate.h
===================================================================
--- linux-2.6.16-mm1.orig/include/linux/auto-migrate.h	2006-03-23 16:50:30.000000000 -0500
+++ linux-2.6.16-mm1/include/linux/auto-migrate.h	2006-03-23 16:50:36.000000000 -0500
@@ -21,6 +21,7 @@ extern unsigned long auto_migrate_interv
 #define AUTO_MIGRATE_INTERVAL_MAX (300*HZ)
 
 extern unsigned int migrate_max_mapcount;
+extern int auto_migrate_lazy;
 
 #ifdef _LINUX_SCHED_H	/* only used where this is defined */
 static inline void check_internode_migration(task_t *task, int dest_cpu)
@@ -101,6 +102,7 @@ out:
 
 #define check_migrate_pending()		/* NOTHING */
 #define migrate_max_mapcount (1)
+#define auto_migrate_lazy (0)
 
 #endif	/* CONFIG_MIGRATION */
 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
