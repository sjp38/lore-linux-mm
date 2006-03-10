Received: from mailrelay01.cce.cpqcorp.net (mailrelay01.cce.cpqcorp.net [16.47.68.171])
	by ccerelbas03.cce.hp.com (Postfix) with ESMTP id A9E6D34165
	for <linux-mm@kvack.org>; Fri, 10 Mar 2006 13:59:49 -0600 (CST)
Received: from anw.zk3.dec.com (or.zk3.dec.com [16.140.48.4])
	by mailrelay01.cce.cpqcorp.net (Postfix) with ESMTP id 7258C83D3
	for <linux-mm@kvack.org>; Fri, 10 Mar 2006 13:59:49 -0600 (CST)
Subject: [PATCH/RFC] AutoPage Migration - V0.1 - 8/8 hook automigration to
	migrate-on-fault
From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Reply-To: lee.schermerhorn@hp.com
Content-Type: text/plain
Date: Fri, 10 Mar 2006 14:59:30 -0500
Message-Id: <1142020770.5204.34.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

AutoPage Migration - V0.1 - 8/8 hook automigration to migrate-on-fault

N.B., this patch depends on the "migrate-on-fault" patch series.

Add a /sys/kernel/migration control--sched_migrate_lazy--to use 
migrate-on-fault when sched_migrate_memory enabled.

Modify migrate_vma_to_node() to just unmap the eligible pages
via migrate_pages_unmap_only() when sched_migrate_lazy enabled.

Signed-off-by: Lee Schermerhorn <lee.schermerhorn@hp.com>

Index: linux-2.6.16-rc5-git11/mm/mempolicy.c
===================================================================
--- linux-2.6.16-rc5-git11.orig/mm/mempolicy.c	2006-03-09 16:19:57.000000000 -0500
+++ linux-2.6.16-rc5-git11/mm/mempolicy.c	2006-03-09 16:46:49.000000000 -0500
@@ -187,6 +187,37 @@ static ssize_t sched_migrate_interval_st
 }
 MIGRATION_ATTR_RW(sched_migrate_interval);
 
+/*
+ * sched_migrate_lazy:  use "lazy migration"--i.e., migration-on-fault--
+ * for scheduler driven task memory migration.
+ */
+int sched_migrate_lazy = 0;
+
+static int __init set_sched_migrate_lazy(char *str)
+{
+	get_option(&str, &sched_migrate_lazy);
+	return 1;
+}
+
+__setup("sched_migrate_lazy", set_sched_migrate_lazy);
+
+static ssize_t sched_migrate_lazy_show(struct subsystem *subsys, char *page)
+{
+	return sprintf(page, "sched_migrate_lazy %s\n",
+			sched_migrate_lazy ? "on" : "off");
+}
+static ssize_t sched_migrate_lazy_store(struct subsystem *subsys,
+				      const char *page, size_t count)
+{
+        unsigned long n = simple_strtoul(page, NULL, 10);
+	if (n)
+		sched_migrate_lazy = 1;
+	else
+		sched_migrate_lazy = 0;
+        return count;
+}
+MIGRATION_ATTR_RW(sched_migrate_lazy);
+
 
 decl_subsys(migration, NULL, NULL);
 EXPORT_SYMBOL(migration_subsys);
@@ -194,6 +225,7 @@ EXPORT_SYMBOL(migration_subsys);
 static struct attribute *migration_attrs[] = {
 	&sched_migrate_memory_attr.attr,
 	&sched_migrate_interval_attr.attr,
+	&sched_migrate_lazy_attr.attr,
 	NULL
 };
 
@@ -882,8 +914,12 @@ static int migrate_vma_to_node(struct vm
 
 	if (IS_ERR(vma))
 		err = PTR_ERR(vma);
-	else if (!list_empty(&pagelist))
-		err = migrate_pages_to(&pagelist, NULL, dest);
+	else if (!list_empty(&pagelist)) {
+		if (!sched_migrate_lazy)
+			err = migrate_pages_to(&pagelist, NULL, dest);
+		else
+			err = migrate_pages_unmap_only(&pagelist);
+	}
 
 	if (!list_empty(&pagelist))
 		putback_lru_pages(&pagelist);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
