Date: Wed, 22 Jun 2005 09:40:01 -0700 (PDT)
From: Ray Bryant <raybry@sgi.com>
Message-Id: <20050622164001.25515.86485.67136@tomahawk.engr.sgi.com>
In-Reply-To: <20050622163908.25515.49944.65860@tomahawk.engr.sgi.com>
References: <20050622163908.25515.49944.65860@tomahawk.engr.sgi.com>
Subject: [PATCH 2.6.12-rc5 8/10] mm: manual page migration-rc3 -- sys_migrate_pages-cpuset-support-rc3.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hirokazu Takahashi <taka@valinux.co.jp>, Dave Hansen <haveblue@us.ibm.com>, Marcelo Tosatti <marcelo.tosatti@cyclades.com>, Andi Kleen <ak@suse.de>
Cc: Christoph Hellwig <hch@infradead.org>, Ray Bryant <raybry@austin.rr.com>, linux-mm <linux-mm@kvack.org>, lhms-devel@lists.sourceforge.net, Ray Bryant <raybry@sgi.com>, Paul Jackson <pj@sgi.com>, Nathan Scott <nathans@sgi.com>
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

Note well that if cpusets are not configured, both of these tests
become noops.

Signed-off-by: Ray Bryant <raybry@sgi.com>
--

 include/linux/cpuset.h |    8 +++++++-
 kernel/cpuset.c        |   24 +++++++++++++++++++++++-
 mm/mmigrate.c          |   24 ++++++++++++++++++++----
 3 files changed, 50 insertions(+), 6 deletions(-)

Index: linux-2.6.12-rc5-mhp1-page-migration-export/include/linux/cpuset.h
===================================================================
--- linux-2.6.12-rc5-mhp1-page-migration-export.orig/include/linux/cpuset.h	2005-06-13 11:12:34.000000000 -0700
+++ linux-2.6.12-rc5-mhp1-page-migration-export/include/linux/cpuset.h	2005-06-13 11:13:04.000000000 -0700
@@ -4,7 +4,7 @@
  *  cpuset interface
  *
  *  Copyright (C) 2003 BULL SA
- *  Copyright (C) 2004 Silicon Graphics, Inc.
+ *  Copyright (C) 2004-2005 Silicon Graphics, Inc.
  *
  */
 
@@ -24,6 +24,7 @@ void cpuset_update_current_mems_allowed(
 void cpuset_restrict_to_mems_allowed(unsigned long *nodes);
 int cpuset_zonelist_valid_mems_allowed(struct zonelist *zl);
 int cpuset_zone_allowed(struct zone *z);
+extern const nodemask_t cpuset_mems_allowed(const struct task_struct *tsk);
 extern struct file_operations proc_cpuset_operations;
 extern char *cpuset_task_status_allowed(struct task_struct *task, char *buffer);
 
@@ -53,6 +54,11 @@ static inline int cpuset_zone_allowed(st
 	return 1;
 }
 
+static inline nodemask_t cpuset_mems_allowed(const struct task_struct *tsk)
+{
+	return node_possible_map;
+}
+
 static inline char *cpuset_task_status_allowed(struct task_struct *task,
 							char *buffer)
 {
Index: linux-2.6.12-rc5-mhp1-page-migration-export/kernel/cpuset.c
===================================================================
--- linux-2.6.12-rc5-mhp1-page-migration-export.orig/kernel/cpuset.c	2005-06-13 11:12:34.000000000 -0700
+++ linux-2.6.12-rc5-mhp1-page-migration-export/kernel/cpuset.c	2005-06-13 11:13:04.000000000 -0700
@@ -4,7 +4,7 @@
  *  Processor and Memory placement constraints for sets of tasks.
  *
  *  Copyright (C) 2003 BULL SA.
- *  Copyright (C) 2004 Silicon Graphics, Inc.
+ *  Copyright (C) 2004-2005 Silicon Graphics, Inc.
  *
  *  Portions derived from Patrick Mochel's sysfs code.
  *  sysfs is Copyright (c) 2001-3 Patrick Mochel
@@ -1500,6 +1500,28 @@ int cpuset_zone_allowed(struct zone *z)
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
+const nodemask_t cpuset_mems_allowed(const struct task_struct *tsk)
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
 /*
  * proc_cpuset_show()
  *  - Print tasks cpuset path into seq_file.
Index: linux-2.6.12-rc5-mhp1-page-migration-export/mm/mmigrate.c
===================================================================
--- linux-2.6.12-rc5-mhp1-page-migration-export.orig/mm/mmigrate.c	2005-06-13 11:12:58.000000000 -0700
+++ linux-2.6.12-rc5-mhp1-page-migration-export/mm/mmigrate.c	2005-06-13 11:13:04.000000000 -0700
@@ -26,6 +26,7 @@
 #include <linux/delay.h>
 #include <linux/nodemask.h>
 #include <linux/mempolicy.h>
+#include <linux/cpuset.h>
 #include <asm/bitops.h>
 
 /*
@@ -673,11 +674,12 @@ sys_migrate_pages(pid_t pid, __u32 count
 	int *tmp_old_nodes = NULL;
 	int *tmp_new_nodes = NULL;
 	int *node_map;
-	struct task_struct *task;
+	struct task_struct *task = NULL;
 	struct mm_struct *mm = NULL;
 	size_t size = count * sizeof(tmp_old_nodes[0]);
 	struct vm_area_struct *vma;
-	nodemask_t old_node_mask, new_node_mask;
+	nodemask_t old_node_mask, new_node_mask, target_nodes_allowed;
+	nodemask_t current_nodes_allowed;
 
 	if ((count < 1) || (count > MAX_NUMNODES))
 		return -EINVAL;
@@ -724,8 +726,10 @@ sys_migrate_pages(pid_t pid, __u32 count
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
@@ -736,6 +740,16 @@ sys_migrate_pages(pid_t pid, __u32 count
 	if (!mm)
 		goto out_einval;
 
+	/* Obviously, the target task needs to be able to allocate on
+	 * the new set of nodes.  However, the migrated pages will
+	 * actually be allocated by the current task, so the current
+	 * task has to be able to allocate on those nodes as well */
+	target_nodes_allowed = cpuset_mems_allowed(task);
+	current_nodes_allowed = cpuset_mems_allowed(current);
+	if (!nodes_subset(new_node_mask, target_nodes_allowed) ||
+	    !nodes_subset(new_node_mask, current_nodes_allowed))
+		goto out_einval;
+
 	/* set up the node_map array */
 	for (i = 0; i < MAX_NUMNODES; i++)
 		node_map[i] = -1;
@@ -768,8 +782,10 @@ sys_migrate_pages(pid_t pid, __u32 count
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
