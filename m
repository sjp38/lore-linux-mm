Date: Tue, 5 Apr 2005 21:17:14 -0700 (PDT)
From: Ray Bryant <raybry@sgi.com>
Message-Id: <20050406041714.25060.93147.24104@jackhammer.engr.sgi.com>
In-Reply-To: <20050406041633.25060.64831.21849@jackhammer.engr.sgi.com>
References: <20050406041633.25060.64831.21849@jackhammer.engr.sgi.com>
Subject: [PATCH_FOR_REVIEW 2.6.12-rc1 3/3] mm: manual page migration-rc1 -- sys_migrate_pages
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hirokazu Takahashi <taka@valinux.co.jp>, Marcello Tosatti <marcello@cyclades.com>, Dave Hansen <haveblue@us.ibm.com>, Andi Kleen <ak@suse.de>
Cc: Ray Bryant <raybry@sgi.com>, Ray Bryant <raybry@austin.rr.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

This is the main patch that creates the migrate_pages() system
call.  Note that in this case, the system call number was more
or less arbitrarily assigned at 1279.  This number needs to
allocated.

This patch sits on top of the page migration patches from
the Memory Hotplug project.  This particular patchset is built
on top of:

http://www.sr71.net/patches/2.6.12/2.6.12-rc1-mhp2/page_migration/patch-2.6.12-rc1-mhp3-pm.gz 

but it may appy on subsequent page migration patches as well.

This patch assumes that the "system.migration" extended attribute
approach is used to identify shared library files (these files 
will have the shared pages not migrated -- only the process
private pages will be migrated) or files that are not to be
migrated at all (system.migration attribute == "NONE").
Alternative approaches to identifying such files (e. g. library
files and files that should not be migrated) are possible and
should be pluggable in place of the implementation found in
get_migration_xattr(), is_migration_xattr_libr(), etc below.

Signed-off-by: Ray Bryant <raybry@sgi.com>

Index: linux-2.6.12-rc1-mhp3-page-migration/arch/ia64/kernel/entry.S
===================================================================
--- linux-2.6.12-rc1-mhp3-page-migration.orig/arch/ia64/kernel/entry.S	2005-04-05 20:04:15.000000000 -0700
+++ linux-2.6.12-rc1-mhp3-page-migration/arch/ia64/kernel/entry.S	2005-04-05 20:04:25.000000000 -0700
@@ -1582,6 +1582,10 @@ sys_call_table:
 	data8 sys_ni_syscall
 	data8 sys_ni_syscall
 	data8 sys_ni_syscall
-	data8 sys_ni_syscall
+#ifdef CONFIG_MEMORY_MIGRATE
+	data8 sys_migrate_pages			// 1279
+#else
+	data8 sys_ni_syscall			// 1279
+#endif
 
 	.org sys_call_table + 8*NR_syscalls	// guard against failures to increase NR_syscalls
Index: linux-2.6.12-rc1-mhp3-page-migration/include/linux/cpuset.h
===================================================================
--- linux-2.6.12-rc1-mhp3-page-migration.orig/include/linux/cpuset.h	2005-04-05 20:04:15.000000000 -0700
+++ linux-2.6.12-rc1-mhp3-page-migration/include/linux/cpuset.h	2005-04-05 20:04:25.000000000 -0700
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
Index: linux-2.6.12-rc1-mhp3-page-migration/include/linux/mempolicy.h
===================================================================
--- linux-2.6.12-rc1-mhp3-page-migration.orig/include/linux/mempolicy.h	2005-04-05 20:04:15.000000000 -0700
+++ linux-2.6.12-rc1-mhp3-page-migration/include/linux/mempolicy.h	2005-04-05 20:04:25.000000000 -0700
@@ -152,6 +152,8 @@ struct mempolicy *mpol_shared_policy_loo
 
 extern void numa_default_policy(void);
 extern void numa_policy_init(void);
+extern int migrate_process_policy(struct task_struct *, short *);
+extern int migrate_vma_policy(struct vm_area_struct *, short *);
 
 #else
 
Index: linux-2.6.12-rc1-mhp3-page-migration/include/linux/mmigrate.h
===================================================================
--- linux-2.6.12-rc1-mhp3-page-migration.orig/include/linux/mmigrate.h	2005-04-05 20:04:15.000000000 -0700
+++ linux-2.6.12-rc1-mhp3-page-migration/include/linux/mmigrate.h	2005-04-05 20:04:25.000000000 -0700
@@ -6,6 +6,11 @@
 
 #define MIGRATE_NODE_ANY -1
 
+#define MIGRATION_XATTR_NAME		"system.migration"
+#define MIGRATION_XATTR_LIBRARY 	"libr"
+#define MIGRATION_XATTR_NOMIGRATE	"none"
+#define MIGRATION_XATTR_LENGTH		4
+
 #ifdef CONFIG_MEMORY_MIGRATE
 extern int generic_migrate_page(struct page *, struct page *,
 		int (*)(struct page *, struct page *, struct list_head *));
Index: linux-2.6.12-rc1-mhp3-page-migration/kernel/cpuset.c
===================================================================
--- linux-2.6.12-rc1-mhp3-page-migration.orig/kernel/cpuset.c	2005-04-05 20:04:15.000000000 -0700
+++ linux-2.6.12-rc1-mhp3-page-migration/kernel/cpuset.c	2005-04-05 20:04:25.000000000 -0700
@@ -4,7 +4,7 @@
  *  Processor and Memory placement constraints for sets of tasks.
  *
  *  Copyright (C) 2003 BULL SA.
- *  Copyright (C) 2004 Silicon Graphics, Inc.
+ *  Copyright (C) 2004-2005 Silicon Graphics, Inc.
  *
  *  Portions derived from Patrick Mochel's sysfs code.
  *  sysfs is Copyright (c) 2001-3 Patrick Mochel
@@ -1470,6 +1470,28 @@ int cpuset_zone_allowed(struct zone *z)
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
Index: linux-2.6.12-rc1-mhp3-page-migration/mm/mempolicy.c
===================================================================
--- linux-2.6.12-rc1-mhp3-page-migration.orig/mm/mempolicy.c	2005-04-05 20:04:16.000000000 -0700
+++ linux-2.6.12-rc1-mhp3-page-migration/mm/mempolicy.c	2005-04-05 20:04:25.000000000 -0700
@@ -1132,3 +1132,117 @@ void numa_default_policy(void)
 {
 	sys_set_mempolicy(MPOL_DEFAULT, NULL, 0);
 }
+
+/*
+ * update a node mask according to a migration request
+ */
+static void migrate_node_mask(unsigned long *new_node_mask, 
+			      unsigned long *old_node_mask,
+			      short *nodemap)
+{
+	int i;
+
+	bitmap_zero(new_node_mask, MAX_NUMNODES);
+
+	i = find_first_bit(old_node_mask, MAX_NUMNODES);
+	while(i < MAX_NUMNODES) {
+		if (nodemap[i] >= 0)
+			set_bit(nodemap[i], new_node_mask);
+		else
+			set_bit(i, new_node_mask);
+		i = find_next_bit(old_node_mask, MAX_NUMNODES, i+1);
+	}
+}
+
+/*
+ * update a process or vma mempolicy according to a migration request
+ */
+static struct mempolicy *migrate_policy(struct mempolicy *old, short *nodemap)
+{
+	struct mempolicy *new;
+	DECLARE_BITMAP(old_nodes, MAX_NUMNODES);
+	DECLARE_BITMAP(new_nodes, MAX_NUMNODES);
+	struct zone *z;
+	int i;
+
+	new = kmem_cache_alloc(policy_cache, GFP_KERNEL);
+	if (!new)
+		return ERR_PTR(-ENOMEM);
+	atomic_set(&new->refcnt, 0);
+	switch(old->policy) {
+	case MPOL_DEFAULT:
+		BUG();
+	case MPOL_INTERLEAVE:
+		migrate_node_mask(new->v.nodes, old->v.nodes, nodemap);
+		break;
+	case MPOL_PREFERRED:
+		if (old->v.preferred_node>=0 && (nodemap[old->v.preferred_node] >= 0))
+			new->v.preferred_node = nodemap[old->v.preferred_node];
+		else
+			new->v.preferred_node = old->v.preferred_node;
+		break;
+	case MPOL_BIND:
+		bitmap_zero(old_nodes, MAX_NUMNODES);
+		for (i = 0; (z = old->v.zonelist->zones[i]) != NULL; i++)
+			set_bit(z->zone_pgdat->node_id, old_nodes);
+		migrate_node_mask(new_nodes, old_nodes, nodemap);
+		new->v.zonelist = bind_zonelist(new_nodes);
+		if (!new->v.zonelist) {
+			kmem_cache_free(policy_cache, new);
+			return ERR_PTR(-ENOMEM);
+		}
+	}
+	new->policy = old->policy;
+	return new;
+}
+
+/*
+ * update a process mempolicy based on a migration request
+ */
+int migrate_process_policy(struct task_struct *task, short *nodemap)
+{
+	struct mempolicy *new, *old = task->mempolicy;
+	int tmp;
+
+	if ((!old) || (old->policy == MPOL_DEFAULT))
+		return 0;
+
+	new = migrate_policy(task->mempolicy, nodemap);
+	if (IS_ERR(new))
+		return (PTR_ERR(new));
+
+	mpol_get(new);
+	task->mempolicy = new;
+	mpol_free(old);
+
+	if (task->mempolicy->policy == MPOL_INTERLEAVE) {
+		/* 
+		 * If the task is still running and allocating storage, this
+		 * is racy, but there is not much that can be done about it.
+		 */
+		tmp = task->il_next;
+		if (nodemap[tmp] >= 0)
+			task->il_next = nodemap[tmp];
+	}
+
+	return 0;
+
+}
+
+/*
+ * update a vma mempolicy based on a migration request
+ */
+int migrate_vma_policy(struct vm_area_struct *vma, short *nodemap)
+{
+
+	struct mempolicy *new;
+
+	if (!vma->vm_policy || vma->vm_policy->policy == MPOL_DEFAULT)
+		return 0;
+
+	new = migrate_policy(vma->vm_policy, nodemap);
+	if (IS_ERR(new))
+		return (PTR_ERR(new));
+
+	return(policy_vma(vma, new));  
+}
Index: linux-2.6.12-rc1-mhp3-page-migration/mm/mmigrate.c
===================================================================
--- linux-2.6.12-rc1-mhp3-page-migration.orig/mm/mmigrate.c	2005-04-05 20:04:16.000000000 -0700
+++ linux-2.6.12-rc1-mhp3-page-migration/mm/mmigrate.c	2005-04-05 20:05:28.000000000 -0700
@@ -5,6 +5,9 @@
  *
  *  Authors:	IWAMOTO Toshihiro <iwamoto@valinux.co.jp>
  *		Hirokazu Takahashi <taka@valinux.co.jp>
+ *
+ * sys_migrate_pages() added by Ray Bryant <raybry@sgi.com>
+ * Copyright (C) 2005, Silicon Graphics, Inc.
  */
 
 #include <linux/config.h>
@@ -21,6 +24,11 @@
 #include <linux/rmap.h>
 #include <linux/mmigrate.h>
 #include <linux/delay.h>
+#include <linux/blkdev.h>
+#include <linux/nodemask.h>
+#include <linux/mempolicy.h>
+#include <linux/cpuset.h>
+#include <asm/bitops.h>
 
 /*
  * The concept of memory migration is to replace a target page with
@@ -587,6 +595,262 @@ int try_to_migrate_pages(struct list_hea
 	return nr_busy;
 }
 
+static int get_migration_xattr(struct file *file, char *xattr)
+{
+	int rc;
+
+	if (!file->f_mapping->host->i_op->getxattr ||
+	    !file->f_dentry)
+		return 0;
+
+ 	rc = file->f_mapping->host->i_op->getxattr(file->f_dentry, 
+		MIGRATION_XATTR_NAME, xattr, MIGRATION_XATTR_LENGTH);
+
+	return rc;
+
+}
+
+static inline int is_migration_xattr_libr(char *x)
+{
+	return strncmp(x, MIGRATION_XATTR_LIBRARY, MIGRATION_XATTR_LENGTH);
+}
+
+static inline int is_migration_xattr_none(char *x)
+{
+	return strncmp(x, MIGRATION_XATTR_NOMIGRATE, MIGRATION_XATTR_LENGTH);
+}
+
+static int
+migrate_vma(struct task_struct *task, struct mm_struct *mm,
+	struct vm_area_struct *vma, short *node_map)
+{
+	struct page *page;
+	struct zone *zone;
+	unsigned long vaddr;
+	int count = 0, nid, pass = 0, nr_busy = 0, library, rc;
+	LIST_HEAD(page_list);
+	char xattr[MIGRATION_XATTR_LENGTH];
+
+	/* can't migrate mlock()'d pages */
+	if (vma->vm_flags & VM_LOCKED)
+		return 0;
+
+	/*
+	 * if the vma is an anon vma, it is migratable.
+	 * if the vma maps a file, then:
+	 *
+	 * system.migration     PageAnon(page)     Migrate?
+	 * ----------------     --------------     --------
+	 *  "none"                not checked          No
+	 * not present            not checked         Yes
+	 *  "libr"                    0                No
+	 *  "libr"                    1               Yes
+	 * any other value        not checked         Yes
+	 */
+
+	library = 0;
+	if (vma->vm_file) {
+	        rc = get_migration_xattr(vma->vm_file, xattr);	
+		if (rc == 0) {
+			if (is_migration_xattr_none(xattr))
+				return 0;
+			if (is_migration_xattr_libr(xattr))
+				library = 1;
+		}
+	}
+
+	/*
+	 * gather all of the pages to be migrated from this vma into page_list
+	 */
+	spin_lock(&mm->page_table_lock);
+ 	for (vaddr = vma->vm_start; vaddr < vma->vm_end; vaddr += PAGE_SIZE) {
+		page = follow_page(mm, vaddr, 0);
+		/* 
+		 * follow_page has been known to return pages with zero mapcount 
+		 * and NULL mapping.  Skip those pages as well
+		 */
+		if (page && page_mapcount(page)) {
+			if (library && !PageAnon(page))
+				continue;
+			nid = page_to_nid(page);
+			if (node_map[nid] >= 0) {
+				zone = page_zone(page);
+				spin_lock_irq(&zone->lru_lock);
+				if (PageLRU(page) && __steal_page_from_lru(zone, page)) {
+					count++;
+					list_add(&page->lru, &page_list);
+				} else
+					BUG();
+				spin_unlock_irq(&zone->lru_lock);
+			}
+		}
+	}
+	spin_unlock(&mm->page_table_lock);
+
+retry:
+
+	/* call the page migration code to move the pages */
+	if (!list_empty(&page_list))
+		nr_busy = try_to_migrate_pages(&page_list, node_map);
+
+	if (nr_busy > 0) {
+		pass++;
+		if (pass > 10)
+			return -EAGAIN;
+		/* wait until some I/O completes and try again */
+		blk_congestion_wait(WRITE, HZ/10);
+		goto retry;
+	} else if (nr_busy < 0)
+		return nr_busy;
+
+	return count;
+}
+
+void lru_add_drain_per_cpu(void *info)
+{
+	lru_add_drain();
+}
+
+asmlinkage long
+sys_migrate_pages(const pid_t pid, const int count, 
+	caddr_t old_nodes, caddr_t new_nodes)
+{
+	int i, ret = 0, migrated = 0;
+	short *tmp_old_nodes;
+	short *tmp_new_nodes;
+	short *node_map;
+	struct task_struct *task;
+	struct mm_struct *mm = 0;
+	size_t size = count * sizeof(tmp_old_nodes[0]);
+	struct vm_area_struct *vma;
+	nodemask_t nodes;
+
+	tmp_old_nodes = kmalloc(size, GFP_KERNEL);
+	tmp_new_nodes = kmalloc(size, GFP_KERNEL);
+	node_map = kmalloc(MAX_NUMNODES*sizeof(node_map[0]), GFP_KERNEL);
+
+	if (!tmp_old_nodes || !tmp_new_nodes || !node_map) {
+		ret = -ENOMEM;
+		goto out;
+	}
+
+	if ((count < 1) || (count >= MAX_NUMNODES)) {
+		ret = -EINVAL;
+		goto out;
+	}
+
+	if (copy_from_user(tmp_old_nodes, old_nodes, size) || 
+	    copy_from_user(tmp_new_nodes, new_nodes, size)) {
+		ret = -EFAULT;
+		goto out;
+	}
+
+	/* Make sure node arguments are within valid limits */
+	for(i = 0; i < count; i++)
+		if ((tmp_old_nodes[i] < 0)                 ||
+		    (tmp_old_nodes[i] >= MAX_NUMNODES)     ||
+		    (tmp_new_nodes[i] <  0)                ||
+		    (tmp_new_nodes[i] >= MAX_NUMNODES)) {
+		    	ret = -EINVAL;
+			goto out;
+		}
+		
+	/* disallow migration to an off-line node */
+	for(i = 0; i < count; i++)
+		if ((tmp_new_nodes[i] != MIGRATE_NODE_ANY) &&
+			!node_online(tmp_new_nodes[i]))	 {
+				ret = -EINVAL;
+				goto out;
+			}
+	/*
+	 * old_nodes and new_nodes must be disjoint
+	 */
+	nodes_clear(nodes);
+	for(i=0; i<count; i++)
+		node_set(tmp_old_nodes[i], nodes);
+	for(i=0; i<count; i++)
+		if(node_isset(tmp_new_nodes[i], nodes))
+			return -EINVAL;
+
+	/* find the task and mm_structs for this process */
+	read_lock(&tasklist_lock);
+	task = find_task_by_pid(pid);
+	if (task) {
+		task_lock(task);
+		mm = task->mm;
+		if (mm)
+			atomic_inc(&mm->mm_users);
+		nodes = cpuset_mems_allowed(task);
+		task_unlock(task);
+	} else {
+		ret = -ESRCH;
+		goto out;
+	}
+	read_unlock(&tasklist_lock);
+	if (!mm) {
+		ret = -EINVAL;
+		goto out;
+	}
+
+	/* check to make sure the target task can allocate on new_nodes */
+	for(i = 0; i < count; i++)
+		if (tmp_new_nodes[i] >= 0)
+			if (!node_isset(tmp_new_nodes[i], nodes)) {
+				ret = -EINVAL;
+				goto out_dec;
+			}
+
+	/* the current task must also be able to allocate on new_nodes */
+	nodes = cpuset_mems_allowed(current);
+	for(i = 0; i < count; i++)
+		if (tmp_new_nodes[i] >= 0)
+			if (!node_isset(tmp_new_nodes[i], nodes)) {
+				ret = -EINVAL;
+				goto out_dec;
+			}
+
+	/* set up the node_map array */
+	for(i = 0; i < MAX_NUMNODES; i++)
+		node_map[i] = -1;
+	for(i = 0; i < count; i++)
+		node_map[tmp_old_nodes[i]] = tmp_new_nodes[i];
+
+	/* prepare for lru list manipulation */
+  	smp_call_function(&lru_add_drain_per_cpu, NULL, 0, 1);
+	lru_add_drain();
+
+	/* update the process mempolicy, if needed */
+	ret = migrate_process_policy(task, node_map);
+	if (ret)
+		goto out_dec;
+
+	/* actually do the migration */
+	for (vma = mm->mmap; vma; vma = vma->vm_next) {
+		/* update the vma mempolicy, if needed */
+		ret = migrate_vma_policy(vma, node_map);
+		if (ret)
+			goto out_dec;
+		/* migrate the pages of this vma */
+		ret = migrate_vma(task, mm, vma, node_map);
+		if (ret >= 0)
+			migrated += ret;
+		else
+			goto out_dec;
+	}
+	ret = migrated;
+
+out_dec:
+	atomic_dec(&mm->mm_users);
+
+out:
+	kfree(tmp_old_nodes);
+	kfree(tmp_new_nodes);
+	kfree(node_map);
+
+	return ret;
+
+}
+
 EXPORT_SYMBOL(generic_migrate_page);
 EXPORT_SYMBOL(migrate_page_common);
 EXPORT_SYMBOL(migrate_page_buffer);

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
