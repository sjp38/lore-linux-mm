Received: from cthulhu.engr.sgi.com (cthulhu.engr.sgi.com [192.26.80.2])
	by omx3.sgi.com (8.12.11/8.12.9/linux-outbound_gateway-1.1) with ESMTP id j61NGWer018078
	for <linux-mm@kvack.org>; Fri, 1 Jul 2005 16:16:32 -0700
Date: Fri, 1 Jul 2005 15:41:36 -0700 (PDT)
From: Ray Bryant <raybry@sgi.com>
Message-Id: <20050701224136.542.19987.17299@jackhammer.engr.sgi.com>
In-Reply-To: <20050701224038.542.60558.44109@jackhammer.engr.sgi.com>
References: <20050701224038.542.60558.44109@jackhammer.engr.sgi.com>
Subject: [PATCH 2.6.13-rc1 9/11] mm: manual page migration-rc4 -- sys_migrate_pages-cpuset-support-rc4.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hirokazu Takahashi <taka@valinux.co.jp>, Andi Kleen <ak@suse.de>, Dave Hansen <haveblue@us.ibm.com>, Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Cc: Christoph Hellwig <hch@infradead.org>, linux-mm <linux-mm@kvack.org>, Nathan Scott <nathans@sgi.com>, Ray Bryant <raybry@austin.rr.com>, lhms-devel@lists.sourceforge.net, Ray Bryant <raybry@sgi.com>, Paul Jackson <pj@sgi.com>, clameter@sgi.com
List-ID: <linux-mm.kvack.org>

This patch adds cpuset support to the migrate_pages() system call.

The idea of this patch is that in order to do a migration:

(1)  The target task needs to be able to allocate pages on the
     nodes that are being migrated to.

(2)  However, the actual allocation of pages is not done by
     the target task.  Allocation is done by the task that is
     running the migrate_pages() system call.  Since it is 
     expected that the migration will be done by a batch manager
     of some kind that is authorized to control the jobs running
     in an enclosing cpuset, we make the requirement that the
     current task ALSO must be able to allocate pages on the
     nodes that are being migrated to.

Note well that if cpusets are not configured, the call to
cpuset_migration_allowed() gets optimizied away.

Signed-off-by: Ray Bryant <raybry@sgi.com>

 include/linux/cpuset.h |    8 +++++++-
 kernel/cpuset.c        |   48 +++++++++++++++++++++++++++++++++++++++++++++++-
 mm/mmigrate.c          |   15 +++++++++++----
 3 files changed, 65 insertions(+), 6 deletions(-)

Index: linux-2.6.12-rc5-mhp1-page-migration-export/include/linux/cpuset.h
===================================================================
--- linux-2.6.12-rc5-mhp1-page-migration-export.orig/include/linux/cpuset.h	2005-06-24 10:56:43.000000000 -0700
+++ linux-2.6.12-rc5-mhp1-page-migration-export/include/linux/cpuset.h	2005-06-24 11:01:59.000000000 -0700
@@ -4,7 +4,7 @@
  *  cpuset interface
  *
  *  Copyright (C) 2003 BULL SA
- *  Copyright (C) 2004 Silicon Graphics, Inc.
+ *  Copyright (C) 2004-2005 Silicon Graphics, Inc.
  *
  */
 
@@ -26,6 +26,7 @@ int cpuset_zonelist_valid_mems_allowed(s
 int cpuset_zone_allowed(struct zone *z);
 extern struct file_operations proc_cpuset_operations;
 extern char *cpuset_task_status_allowed(struct task_struct *task, char *buffer);
+extern int cpuset_migration_allowed(nodemask_t, struct task_struct *);
 
 #else /* !CONFIG_CPUSETS */
 
@@ -59,6 +60,11 @@ static inline char *cpuset_task_status_a
 	return buffer;
 }
 
+static inline int cpuset_migration_allowed(int *nodes, struct task *task)
+{
+	return 1;
+}
+
 #endif /* !CONFIG_CPUSETS */
 
 #endif /* _LINUX_CPUSET_H */
Index: linux-2.6.12-rc5-mhp1-page-migration-export/kernel/cpuset.c
===================================================================
--- linux-2.6.12-rc5-mhp1-page-migration-export.orig/kernel/cpuset.c	2005-06-24 10:56:43.000000000 -0700
+++ linux-2.6.12-rc5-mhp1-page-migration-export/kernel/cpuset.c	2005-06-24 11:01:59.000000000 -0700
@@ -4,7 +4,7 @@
  *  Processor and Memory placement constraints for sets of tasks.
  *
  *  Copyright (C) 2003 BULL SA.
- *  Copyright (C) 2004 Silicon Graphics, Inc.
+ *  Copyright (C) 2004-2005 Silicon Graphics, Inc.
  *
  *  Portions derived from Patrick Mochel's sysfs code.
  *  sysfs is Copyright (c) 2001-3 Patrick Mochel
@@ -1500,6 +1500,52 @@ int cpuset_zone_allowed(struct zone *z)
 		node_isset(z->zone_pgdat->node_id, current->mems_allowed);
 }
 
+/**
+ * cpuset_mems_allowed - return mems_allowed mask from a tasks cpuset.
+ * @tsk: pointer to task_struct from which to obtain cpuset->mems_allowed.
+ *
+ * Description: Returns the nodemask_t mems_allowed of the cpuset
+ * attached to the specified @tsk.
+ *
+ **/
+
+static const nodemask_t cpuset_mems_allowed(const struct task_struct *tsk)
+{
+	nodemask_t mask;
+
+	down(&cpuset_sem);
+	task_lock((struct task_struct *)tsk);
+	guarantee_online_mems(tsk->cpuset, &mask);
+	task_unlock((struct task_struct *)tsk);
+	up(&cpuset_sem);
+
+	return mask;
+}
+
+/**
+ * cpuset_migration_allowed(int *nodes, struct task_struct *tsk)
+ * @mask:  pointer to nodemask of nodes to be migrated to
+ * @tsk:   pointer to task struct of task being migrated
+ *
+ * Description: Returns true if the migration should be allowed.
+ *
+ */
+int cpuset_migration_allowed(nodemask_t mask, struct task_struct *tsk)
+{
+	nodemask_t current_nodes_allowed, target_nodes_allowed;
+	current_nodes_allowed = cpuset_mems_allowed(current);
+
+	/* Obviously, the target task needs to be able to allocate on
+	 * the new set of nodes.  However, the migrated pages will
+	 * actually be allocated by the current task, so the current
+	 * task has to be able to allocate on those nodes as well */
+	target_nodes_allowed  = cpuset_mems_allowed(tsk);
+	if (!nodes_subset(mask, current_nodes_allowed) ||
+	    !nodes_subset(mask, target_nodes_allowed))
+		return 0;
+	return 1;
+}
+
 /*
  * proc_cpuset_show()
  *  - Print tasks cpuset path into seq_file.
Index: linux-2.6.12-rc5-mhp1-page-migration-export/mm/mmigrate.c
===================================================================
--- linux-2.6.12-rc5-mhp1-page-migration-export.orig/mm/mmigrate.c	2005-06-24 11:01:59.000000000 -0700
+++ linux-2.6.12-rc5-mhp1-page-migration-export/mm/mmigrate.c	2005-06-24 11:02:20.000000000 -0700
@@ -26,6 +26,7 @@
 #include <linux/delay.h>
 #include <linux/nodemask.h>
 #include <linux/mempolicy.h>
+#include <linux/cpuset.h>
 #include <asm/bitops.h>
 
 /*
@@ -690,7 +691,7 @@ sys_migrate_pages(pid_t pid, __u32 count
 	int *tmp_old_nodes = NULL;
 	int *tmp_new_nodes = NULL;
 	int *node_map = NULL;
-	struct task_struct *task;
+	struct task_struct *task = NULL;
 	struct mm_struct *mm = NULL;
 	size_t size = count * sizeof(tmp_old_nodes[0]);
 	struct vm_area_struct *vma;
@@ -734,8 +735,10 @@ sys_migrate_pages(pid_t pid, __u32 count
 	if (task) {
 		task_lock(task);
 		mm = task->mm;
-		if (mm)
+		if (mm) {
 			atomic_inc(&mm->mm_users);
+			get_task_struct(task);
+		}
 		task_unlock(task);
 	} else {
 		ret = -ESRCH;
@@ -746,7 +749,9 @@ sys_migrate_pages(pid_t pid, __u32 count
 	if (!mm)
 		goto out_einval;
 
-	/* set up the node_map array */
+	if (!cpuset_migration_allowed(new_node_mask, task))
+		goto out_einval;
+
 	for (i = 0; i < MAX_NUMNODES; i++)
 		node_map[i] = -1;
 	for (i = 0; i < count; i++)
@@ -773,8 +778,10 @@ sys_migrate_pages(pid_t pid, __u32 count
 	ret = migrated;
 
 out:
-	if (mm)
+	if (mm) {
 		mmput(mm);
+		put_task_struct(task);
+	}
 
 	kfree(tmp_old_nodes);
 	kfree(tmp_new_nodes);

-- 
Best Regards,
Ray
-----------------------------------------------
Ray Bryant                       raybry@sgi.com
The box said: "Requires Windows 98 or better",
           so I installed Linux.
-----------------------------------------------
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
