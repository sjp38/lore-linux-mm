Date: Tue, 10 May 2005 21:38:40 -0700 (PDT)
From: Ray Bryant <raybry@sgi.com>
Message-Id: <20050511043840.10876.87654.53504@jackhammer.engr.sgi.com>
In-Reply-To: <20050511043756.10876.72079.60115@jackhammer.engr.sgi.com>
References: <20050511043756.10876.72079.60115@jackhammer.engr.sgi.com>
Subject: [PATCH 2.6.12-rc3 7/8] mm: manual page migration-rc2 -- sys_migrate_pages-cpuset-support-rc2.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hirokazu Takahashi <taka@valinux.co.jp>, Marcelo Tosatti <marcelo.tosatti@cyclades.com>, Andi Kleen <ak@suse.de>, Dave Hansen <haveblue@us.ibm.com>
Cc: Christoph Hellwig <hch@infradead.org>, linux-mm <linux-mm@kvack.org>, Nathan Scott <nathans@sgi.com>, Ray Bryant <raybry@austin.rr.com>, lhms-devel@lists.sourceforge.net, Ray Bryant <raybry@sgi.com>
List-ID: <linux-mm.kvack.org>

This patch adds cpuset support to the migrate_pages() system call.

The idea of this patch is that in order to do a migration:

(1)  The target task nees to be able to allocate pages on the
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

 include/linux/cpuset.h |    8 +++++++-
 kernel/cpuset.c        |   24 +++++++++++++++++++++++-
 mm/mmigrate.c          |   17 +++++++++++++++++
 3 files changed, 47 insertions(+), 2 deletions(-)

Index: linux-2.6.12-rc3-mhp1-page-migration-export/include/linux/cpuset.h
===================================================================
--- linux-2.6.12-rc3-mhp1-page-migration-export.orig/include/linux/cpuset.h	2005-04-20 17:03:16.000000000 -0700
+++ linux-2.6.12-rc3-mhp1-page-migration-export/include/linux/cpuset.h	2005-05-10 11:20:57.000000000 -0700
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
Index: linux-2.6.12-rc3-mhp1-page-migration-export/kernel/cpuset.c
===================================================================
--- linux-2.6.12-rc3-mhp1-page-migration-export.orig/kernel/cpuset.c	2005-04-20 17:03:16.000000000 -0700
+++ linux-2.6.12-rc3-mhp1-page-migration-export/kernel/cpuset.c	2005-05-10 11:20:57.000000000 -0700
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
+ * requires either tsk==current or the tsk's task_lock to be held
+ * by the caller.
+ **/
+
+const nodemask_t cpuset_mems_allowed(const struct task_struct *tsk)
+{
+	nodemask_t mask;
+
+	down(&cpuset_sem);
+	guarantee_online_mems(tsk->cpuset, &mask);
+	up(&cpuset_sem);
+
+	return mask;
+}
+
 /*
  * proc_cpuset_show()
  *  - Print tasks cpuset path into seq_file.
Index: linux-2.6.12-rc3-mhp1-page-migration-export/mm/mmigrate.c
===================================================================
--- linux-2.6.12-rc3-mhp1-page-migration-export.orig/mm/mmigrate.c	2005-05-10 11:18:40.000000000 -0700
+++ linux-2.6.12-rc3-mhp1-page-migration-export/mm/mmigrate.c	2005-05-10 11:21:39.000000000 -0700
@@ -27,6 +27,7 @@
 #include <linux/blkdev.h>
 #include <linux/nodemask.h>
 #include <linux/mempolicy.h>
+#include <linux/cpuset.h>
 #include <asm/bitops.h>
 
 /*
@@ -777,6 +778,7 @@ sys_migrate_pages(const pid_t pid, const
 		mm = task->mm;
 		if (mm)
 			atomic_inc(&mm->mm_users);
+		nodes = cpuset_mems_allowed(task);
 		task_unlock(task);
 	} else {
 		ret = -ESRCH;
@@ -789,6 +791,21 @@ sys_migrate_pages(const pid_t pid, const
 		goto out;
 	}
 
+	/* check to make sure the target task can allocate on new_nodes */
+	for(i = 0; i < count; i++)
+		if (!node_isset(tmp_new_nodes[i], nodes)) {
+			ret = -EINVAL;
+			goto out_dec;
+		}
+
+	/* the current task must also be able to allocate on new_nodes */
+	nodes = cpuset_mems_allowed(current);
+	for(i = 0; i < count; i++)
+		if (!node_isset(tmp_new_nodes[i], nodes)) {
+			ret = -EINVAL;
+			goto out_dec;
+		}
+
 	/* set up the node_map array */
 	for(i = 0; i < MAX_NUMNODES; i++)
 		node_map[i] = -1;

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
