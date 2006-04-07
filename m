Received: from smtp1.fc.hp.com (smtp1.fc.hp.com [15.15.136.127])
	by atlrel8.hp.com (Postfix) with ESMTP id C443B36F83
	for <linux-mm@kvack.org>; Fri,  7 Apr 2006 16:42:28 -0400 (EDT)
Received: from ldl.fc.hp.com (ldl.fc.hp.com [15.11.146.30])
	by smtp1.fc.hp.com (Postfix) with ESMTP id 9DE54102C9
	for <linux-mm@kvack.org>; Fri,  7 Apr 2006 20:42:28 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
	by ldl.fc.hp.com (Postfix) with ESMTP id 757F6138E38
	for <linux-mm@kvack.org>; Fri,  7 Apr 2006 14:42:28 -0600 (MDT)
Received: from ldl.fc.hp.com ([127.0.0.1])
	by localhost (ldl [127.0.0.1]) (amavisd-new, port 10024) with ESMTP
	id 23197-08 for <linux-mm@kvack.org>;
	Fri, 7 Apr 2006 14:42:26 -0600 (MDT)
Received: from [16.116.101.121] (unknown [16.116.101.121])
	by ldl.fc.hp.com (Postfix) with ESMTP id D7A3B138E39
	for <linux-mm@kvack.org>; Fri,  7 Apr 2006 14:42:25 -0600 (MDT)
Subject: Re: [PATCH 2.6.17-rc1-mm1 8/9] AutoPage Migration - V0.2 - add max
	mapcount migration threshold
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <1144441946.5198.52.camel@localhost.localdomain>
References: <1144441946.5198.52.camel@localhost.localdomain>
Content-Type: text/plain
Date: Fri, 07 Apr 2006 16:43:50 -0400
Message-Id: <1144442630.5198.69.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

AutoPage Migration - V0.2 - 8/9 add max mapcount migration threshold

This patch adds an additional migration control that allows one
to vary the page mapcount threshold above which pages will not
be migrated by MPOL_MF_MOVE.  The default value is 1, which yields
the same behavior as before this patch.

Signed-off-by: Lee Schermerhorn <lee.schermerhorn@hp.com>

Index: linux-2.6.16-mm1/include/linux/auto-migrate.h
===================================================================
--- linux-2.6.16-mm1.orig/include/linux/auto-migrate.h	2006-03-23 16:50:24.000000000 -0500
+++ linux-2.6.16-mm1/include/linux/auto-migrate.h	2006-03-23 16:50:30.000000000 -0500
@@ -20,6 +20,8 @@ extern unsigned long auto_migrate_interv
 #define AUTO_MIGRATE_INTERVAL_MIN (5*HZ)
 #define AUTO_MIGRATE_INTERVAL_MAX (300*HZ)
 
+extern unsigned int migrate_max_mapcount;
+
 #ifdef _LINUX_SCHED_H	/* only used where this is defined */
 static inline void check_internode_migration(task_t *task, int dest_cpu)
 {
@@ -98,6 +100,7 @@ out:
 #define too_soon_for_internode_migration(t,c) 0
 
 #define check_migrate_pending()		/* NOTHING */
+#define migrate_max_mapcount (1)
 
 #endif	/* CONFIG_MIGRATION */
 
Index: linux-2.6.16-mm1/mm/migrate.c
===================================================================
--- linux-2.6.16-mm1.orig/mm/migrate.c	2006-03-23 16:50:24.000000000 -0500
+++ linux-2.6.16-mm1/mm/migrate.c	2006-03-23 16:50:30.000000000 -0500
@@ -107,12 +107,35 @@ static ssize_t auto_migrate_interval_sto
 }
 MIGRATION_ATTR_RW(auto_migrate_interval);
 
+/*
+ * migrate_max_mapcount:  specify how many mappers allowed
+ * before we won't migrate a page via MPOL_MF_MOVE.
+ */
+unsigned int migrate_max_mapcount = 1;	/* default == minimum */
+
+static ssize_t migrate_max_mapcount_show(struct subsystem *subsys, char *page)
+{
+	return sprintf(page, "migrate_max_mapcount %d\n", migrate_max_mapcount);
+}
+static ssize_t migrate_max_mapcount_store(struct subsystem *subsys,
+				      const char *page, size_t count)
+{
+        unsigned int n = simple_strtoul(page, NULL, 10);
+	if (n < 1)
+		migrate_max_mapcount = 1;
+	else
+		migrate_max_mapcount = n;
+        return count;
+}
+MIGRATION_ATTR_RW(migrate_max_mapcount);
+
 decl_subsys(migration, NULL, NULL);
 EXPORT_SYMBOL(migration_subsys);
 
 static struct attribute *migration_attrs[] = {
 	&auto_migrate_enable_attr.attr,
 	&auto_migrate_interval_attr.attr,
+	&migrate_max_mapcount_attr.attr,
 	NULL
 };
 
Index: linux-2.6.16-mm1/mm/mempolicy.c
===================================================================
--- linux-2.6.16-mm1.orig/mm/mempolicy.c	2006-03-23 16:49:34.000000000 -0500
+++ linux-2.6.16-mm1/mm/mempolicy.c	2006-03-23 16:50:30.000000000 -0500
@@ -87,6 +87,7 @@
 #include <linux/seq_file.h>
 #include <linux/proc_fs.h>
 #include <linux/migrate.h>
+#include <linux/auto-migrate.h>
 
 #include <asm/tlbflush.h>
 #include <asm/uaccess.h>
@@ -452,7 +453,6 @@ static int contextualize_policy(int mode
 	return mpol_check_policy(mode, nodes);
 }
 
-
 /*
  * Update task->flags PF_MEMPOLICY bit: set iff non-default
  * mempolicy.  Allows more rapid checking of this (combined perhaps
@@ -611,9 +611,10 @@ static void migrate_page_add(struct page
 				unsigned long flags)
 {
 	/*
-	 * Avoid migrating a page that is shared with others.
+	 * Avoid migrating a page that is shared with [too many] others.
 	 */
-	if ((flags & MPOL_MF_MOVE_ALL) || page_mapcount(page) == 1)
+	if ((flags & MPOL_MF_MOVE_ALL) ||
+		page_mapcount(page) <= migrate_max_mapcount)
 		isolate_lru_page(page, pagelist);
 }
 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
