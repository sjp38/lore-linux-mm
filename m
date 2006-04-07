Received: from smtp2.fc.hp.com (smtp2.fc.hp.com [15.11.136.114])
	by atlrel9.hp.com (Postfix) with ESMTP id E222934B21
	for <linux-mm@kvack.org>; Fri,  7 Apr 2006 16:35:38 -0400 (EDT)
Received: from ldl.fc.hp.com (linux-bugs.fc.hp.com [15.11.146.30])
	by smtp2.fc.hp.com (Postfix) with ESMTP id BD79EB3A5
	for <linux-mm@kvack.org>; Fri,  7 Apr 2006 20:35:38 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
	by ldl.fc.hp.com (Postfix) with ESMTP id 91CA9138E39
	for <linux-mm@kvack.org>; Fri,  7 Apr 2006 14:35:38 -0600 (MDT)
Received: from ldl.fc.hp.com ([127.0.0.1])
	by localhost (ldl [127.0.0.1]) (amavisd-new, port 10024) with ESMTP
	id 22576-03 for <linux-mm@kvack.org>;
	Fri, 7 Apr 2006 14:35:36 -0600 (MDT)
Received: from [16.116.101.121] (unknown [16.116.101.121])
	by ldl.fc.hp.com (Postfix) with ESMTP id 44C6E138E38
	for <linux-mm@kvack.org>; Fri,  7 Apr 2006 14:35:36 -0600 (MDT)
Subject: Re: [PATCH 2.6.17-rc1-mm1 1/9] AutoPage Migration - V0.2 - migrate
	task memory with default policy
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <1144441946.5198.52.camel@localhost.localdomain>
References: <1144441946.5198.52.camel@localhost.localdomain>
Content-Type: text/plain
Date: Fri, 07 Apr 2006 16:37:00 -0400
Message-Id: <1144442220.5198.55.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

AutoPage Migration - V0.2 - 1/9 migrate task memory with default policy

Define mempolicy.c internal flag for auto-migration.  This flag
will select auto-migration specific behavior in the existing 
page migration functions.

Add auto_migrate_task_memory() to mempolicy.c.  This function sets up 
to call migrate_to_node() with internal flags for auto-migration.

Modify vma_migratable(), called from check_range(), to skip VMAs that
don't have default policy when auto-migrating.  To do this,
vma_migratable() needs the MPOL flags.

I had to move get_vma_policy() up in mempolicy.c so that I could reference
it from vma_migratable().  Should I have just added a forward ref?

Subsequent patches will arrange for auto_migrate_task_memory() to be
called when a task returns to user space after the scheduler migrates
it to a cpu on a node different from the node where it last executed.

Signed-off-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>

Index: linux-2.6.16-mm1/mm/mempolicy.c
===================================================================
--- linux-2.6.16-mm1.orig/mm/mempolicy.c	2006-03-23 16:49:22.000000000 -0500
+++ linux-2.6.16-mm1/mm/mempolicy.c	2006-03-23 16:49:34.000000000 -0500
@@ -92,9 +92,14 @@
 #include <asm/uaccess.h>
 
 /* Internal flags */
-#define MPOL_MF_DISCONTIG_OK (MPOL_MF_INTERNAL << 0)	/* Skip checks for continuous vmas */
-#define MPOL_MF_INVERT (MPOL_MF_INTERNAL << 1)		/* Invert check for nodemask */
-#define MPOL_MF_STATS (MPOL_MF_INTERNAL << 2)		/* Gather statistics */
+#define MPOL_MF_DISCONTIG_OK \
+	(MPOL_MF_INTERNAL << 0)		/* Skip checks for continuous vmas */
+#define MPOL_MF_INVERT \
+	(MPOL_MF_INTERNAL << 1)		/* Invert check for nodemask */
+#define MPOL_MF_STATS \
+	(MPOL_MF_INTERNAL << 2)		/* Gather statistics */
+#define MPOL_MF_AUTOMIGRATE \
+	(MPOL_MF_INTERNAL << 3)		/* auto-migrating task memory */
 
 static struct kmem_cache *policy_cache;
 static struct kmem_cache *sn_cache;
@@ -110,6 +115,24 @@ struct mempolicy default_policy = {
 	.policy = MPOL_DEFAULT,
 };
 
+/* Return effective policy for a VMA */
+static struct mempolicy * get_vma_policy(struct task_struct *task,
+		struct vm_area_struct *vma, unsigned long addr)
+{
+	struct mempolicy *pol = task->mempolicy;
+
+	if (vma) {
+		if (vma->vm_ops && vma->vm_ops->get_policy)
+			pol = vma->vm_ops->get_policy(vma, addr);
+		else if (vma->vm_policy &&
+				vma->vm_policy->policy != MPOL_DEFAULT)
+			pol = vma->vm_policy;
+	}
+	if (!pol)
+		pol = &default_policy;
+	return pol;
+}
+
 /* Do sanity checking on a policy */
 static int mpol_check_policy(int mode, nodemask_t *nodes)
 {
@@ -309,11 +332,17 @@ static inline int check_pgd_range(struct
 }
 
 /* Check if a vma is migratable */
-static inline int vma_migratable(struct vm_area_struct *vma)
+static inline int vma_migratable(struct vm_area_struct *vma, int flags)
 {
 	if (vma->vm_flags & (
 		VM_LOCKED|VM_IO|VM_HUGETLB|VM_PFNMAP|VM_RESERVED))
 		return 0;
+	if (flags & MPOL_MF_AUTOMIGRATE) {
+		struct mempolicy *pol =
+			get_vma_policy(current, vma, vma->vm_start);
+		if (pol->policy != MPOL_DEFAULT)
+			return 0;
+	}
 	return 1;
 }
 
@@ -350,7 +379,7 @@ check_range(struct mm_struct *mm, unsign
 		if (!is_vm_hugetlb_page(vma) &&
 		    ((flags & MPOL_MF_STRICT) ||
 		     ((flags & (MPOL_MF_MOVE | MPOL_MF_MOVE_ALL)) &&
-				vma_migratable(vma)))) {
+				vma_migratable(vma, flags)))) {
 			unsigned long endvma = vma->vm_end;
 
 			if (endvma > end)
@@ -695,6 +724,33 @@ int do_migrate_pages(struct mm_struct *m
 
 }
 
+/**
+ * auto_migrate_task_memory()
+ *
+ * Called just before returning to user state when a task has been
+ * migrated to a new node by the schedule and sched_migrate_memory
+ * is enabled.
+ */
+void auto_migrate_task_memory(void)
+{
+	struct mm_struct *mm = NULL;
+	int dest = cpu_to_node(task_cpu(current));
+	int flags = MPOL_MF_MOVE | MPOL_MF_INVERT | MPOL_MF_AUTOMIGRATE;
+
+	mm = current->mm;
+	/*
+	 * we're returning to user space, so mm must be non-NULL
+	 */
+	BUG_ON(!mm);
+
+	/*
+	 * Pass destination node as source node plus 'INVERT flag:
+	 *    Migrate all pages NOT on destination node.
+	 * 'AUTOMIGRATE flag selects only VMAs with default policy
+	 */
+	migrate_to_node(mm, dest, dest, flags);
+}
+
 #else
 
 static void migrate_page_add(struct page *page, struct list_head *pagelist,
@@ -1049,24 +1105,6 @@ asmlinkage long compat_sys_mbind(compat_
 
 #endif
 
-/* Return effective policy for a VMA */
-static struct mempolicy * get_vma_policy(struct task_struct *task,
-		struct vm_area_struct *vma, unsigned long addr)
-{
-	struct mempolicy *pol = task->mempolicy;
-
-	if (vma) {
-		if (vma->vm_ops && vma->vm_ops->get_policy)
-			pol = vma->vm_ops->get_policy(vma, addr);
-		else if (vma->vm_policy &&
-				vma->vm_policy->policy != MPOL_DEFAULT)
-			pol = vma->vm_policy;
-	}
-	if (!pol)
-		pol = &default_policy;
-	return pol;
-}
-
 /* Return a zonelist representing a mempolicy */
 static struct zonelist *zonelist_policy(gfp_t gfp, struct mempolicy *policy)
 {
Index: linux-2.6.16-mm1/include/linux/auto-migrate.h
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux-2.6.16-mm1/include/linux/auto-migrate.h	2006-03-23 16:49:34.000000000 -0500
@@ -0,0 +1,20 @@
+#ifndef _LINUX_AUTO_MIGRATE_H
+#define _LINUX_AUTO_MIGRATE_H
+
+/*
+ * minimal memory migration definitions need by scheduler,
+ * sysctl, ..., so that they don't need to drag in the entire
+ * migrate.h and all that it depends on.
+ */
+
+#include <linux/config.h>
+
+#ifdef CONFIG_MIGRATION
+
+extern void auto_migrate_task_memory(void);
+
+#else	/* !CONFIG_MIGRATION */
+
+#endif	/* CONFIG_MIGRATION */
+
+#endif


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
