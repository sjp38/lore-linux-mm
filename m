Received: from cthulhu.engr.sgi.com (cthulhu.engr.sgi.com [192.26.80.2])
	by omx3.sgi.com (8.12.11/8.12.9/linux-outbound_gateway-1.1) with ESMTP id j61NG0N7017972
	for <linux-mm@kvack.org>; Fri, 1 Jul 2005 16:16:00 -0700
Date: Fri, 1 Jul 2005 15:41:04 -0700 (PDT)
From: Ray Bryant <raybry@sgi.com>
Message-Id: <20050701224104.542.76941.36750@jackhammer.engr.sgi.com>
In-Reply-To: <20050701224038.542.60558.44109@jackhammer.engr.sgi.com>
References: <20050701224038.542.60558.44109@jackhammer.engr.sgi.com>
Subject: [PATCH 2.6.13-rc1 4/11] mm: manual page migration-rc4 -- add-sys_migrate_pages-rc4.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hirokazu Takahashi <taka@valinux.co.jp>, Marcelo Tosatti <marcelo.tosatti@cyclades.com>, Andi Kleen <ak@suse.de>, Dave Hansen <haveblue@us.ibm.com>
Cc: Christoph Hellwig <hch@infradead.org>, linux-mm <linux-mm@kvack.org>, Nathan Scott <nathans@sgi.com>, Ray Bryant <raybry@austin.rr.com>, lhms-devel@lists.sourceforge.net, Ray Bryant <raybry@sgi.com>, Paul Jackson <pj@sgi.com>, clameter@sgi.com
List-ID: <linux-mm.kvack.org>

This is the main patch that creates the migrate_pages() system
call.  Note that in this case, the system call number was more
or less arbitrarily assigned at 1279.  This number needs to
allocated.

This patch sits on top of the page migration patches from
the Memory Hotplug project.  This particular patchset is built
on top of:

http://www.sr71.net/patches/2.6.12/2.6.13-rc1-mhp1/page_migration/patch-2.6.13-rc1-mhp1-pm.gz

but it may apply on subsequent page migration patches as well.

This patch migrates all pages in the specified process (including
shared libraries.)

See the patches:
	sys_migrate_pages-migration-selection-rc4.patch
	add-mempolicy-control-rc4.patch

for details on the default kernel migration policy (this determines
which VMAs are actually migrated) and how this policy can be overridden
using the mbind() system call.

Updates since last release of this patchset:

	Suggestions from Dave Hansen and Hirokazu Takahashi
	have been incorporated.

Signed-off-by: Ray Bryant <raybry@sgi.com>

 arch/ia64/kernel/entry.S |    2 
 kernel/sys_ni.c          |    1 
 mm/mmigrate.c            |  184 ++++++++++++++++++++++++++++++++++++++++++++++-
 3 files changed, 185 insertions(+), 2 deletions(-)

Index: linux-2.6.13-rc1-mhp1-page-migration/arch/ia64/kernel/entry.S
===================================================================
--- linux-2.6.13-rc1-mhp1-page-migration.orig/arch/ia64/kernel/entry.S	2005-06-28 22:57:29.000000000 -0700
+++ linux-2.6.13-rc1-mhp1-page-migration/arch/ia64/kernel/entry.S	2005-06-30 11:17:05.000000000 -0700
@@ -1582,6 +1582,6 @@ sys_call_table:
 	data8 sys_set_zone_reclaim
 	data8 sys_ni_syscall
 	data8 sys_ni_syscall
-	data8 sys_ni_syscall
+	data8 sys_migrate_pages			// 1279
 
 	.org sys_call_table + 8*NR_syscalls	// guard against failures to increase NR_syscalls
Index: linux-2.6.13-rc1-mhp1-page-migration/mm/mmigrate.c
===================================================================
--- linux-2.6.13-rc1-mhp1-page-migration.orig/mm/mmigrate.c	2005-06-30 11:16:37.000000000 -0700
+++ linux-2.6.13-rc1-mhp1-page-migration/mm/mmigrate.c	2005-06-30 11:17:05.000000000 -0700
@@ -5,6 +5,9 @@
  *
  *  Authors:	IWAMOTO Toshihiro <iwamoto@valinux.co.jp>
  *		Hirokazu Takahashi <taka@valinux.co.jp>
+ *
+ * sys_migrate_pages() added by Ray Bryant <raybry@sgi.com>
+ * Copyright (C) 2005, Silicon Graphics, Inc.
  */
 
 #include <linux/config.h>
@@ -21,6 +24,8 @@
 #include <linux/rmap.h>
 #include <linux/mmigrate.h>
 #include <linux/delay.h>
+#include <linux/nodemask.h>
+#include <asm/bitops.h>
 
 /*
  * The concept of memory migration is to replace a target page with
@@ -436,7 +441,7 @@ migrate_onepage(struct page *page, int n
 	if (nodeid == MIGRATE_NODE_ANY)
 		newpage = page_cache_alloc(mapping);
 	else
-		newpage = alloc_pages_node(nodeid, mapping->flags, 0);
+		newpage = alloc_pages_node(nodeid, (unsigned int)mapping->flags, 0);
 	if (newpage == NULL) {
 		unlock_page(page);
 		return ERR_PTR(-ENOMEM);
@@ -587,6 +592,183 @@ int try_to_migrate_pages(struct list_hea
 	return nr_busy;
 }
 
+static int
+migrate_vma(struct task_struct *task, struct mm_struct *mm,
+	struct vm_area_struct *vma, int *node_map)
+{
+	struct page *page, *page2;
+	unsigned long vaddr;
+	int count = 0, nr_busy;
+	LIST_HEAD(pglist);
+
+	/* can't migrate mlock()'d pages */
+	if (vma->vm_flags & VM_LOCKED)
+		return 0;
+
+	/*
+	 * gather all of the pages to be migrated from this vma into pglist
+	 */
+	spin_lock(&mm->page_table_lock);
+ 	for (vaddr = vma->vm_start; vaddr < vma->vm_end; vaddr += PAGE_SIZE) {
+		page = follow_page(mm, vaddr, 0);
+		/*
+		 * follow_page has been known to return pages with zero mapcount
+		 * and NULL mapping.  Skip those pages as well
+		 */
+		if (!page || !page_mapcount(page))
+			continue;
+
+		if (node_map[page_to_nid(page)] >= 0) {
+			if (steal_page_from_lru(page_zone(page), page, &pglist))
+				count++;
+			else
+				BUG();
+		}
+	}
+	spin_unlock(&mm->page_table_lock);
+
+	/* call the page migration code to move the pages */
+	if (!count)
+		return 0;
+
+	nr_busy = try_to_migrate_pages(&pglist, node_map);
+
+	if (nr_busy < 0)
+		return nr_busy;
+
+	if (nr_busy == 0)
+		return count;
+
+	/* return the unmigrated pages to the LRU lists */
+	list_for_each_entry_safe(page, page2, &pglist, lru) {
+		list_del(&page->lru);
+		putback_page_to_lru(page_zone(page), page);
+	}
+	return -EAGAIN;
+
+}
+
+static inline int nodes_invalid(int *nodes, __u32 count)
+{
+	int i;
+	for (i = 0; i < count; i++)
+		if (nodes[i] < 0 ||
+		    nodes[i] > MAX_NUMNODES ||
+		    !node_online(nodes[i]))
+			return 1;
+	return 0;
+}
+
+void lru_add_drain_per_cpu(void *info)
+{
+	lru_add_drain();
+}
+
+asmlinkage long
+sys_migrate_pages(pid_t pid, __u32 count, __u32 __user *old_nodes,
+	__u32 __user *new_nodes)
+{
+	int i, ret = 0, migrated = 0;
+	int *tmp_old_nodes = NULL;
+	int *tmp_new_nodes = NULL;
+	int *node_map = NULL;
+	struct task_struct *task;
+	struct mm_struct *mm = NULL;
+	size_t size = count * sizeof(tmp_old_nodes[0]);
+	struct vm_area_struct *vma;
+	nodemask_t old_node_mask, new_node_mask;
+
+	if ((count < 1) || (count > MAX_NUMNODES))
+		goto out_einval;
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
+	if (copy_from_user(tmp_old_nodes, (void __user *)old_nodes, size) ||
+	    copy_from_user(tmp_new_nodes, (void __user *)new_nodes, size)) {
+		ret = -EFAULT;
+		goto out;
+	}
+
+	if (nodes_invalid(tmp_old_nodes, count) ||
+	    nodes_invalid(tmp_new_nodes, count))
+		goto out_einval;
+
+	nodes_clear(old_node_mask);
+	nodes_clear(new_node_mask);
+	for (i = 0; i < count; i++) {
+		node_set(tmp_old_nodes[i], old_node_mask);
+		node_set(tmp_new_nodes[i], new_node_mask);
+
+	}
+
+	if (nodes_intersects(old_node_mask, new_node_mask))
+		goto out_einval;
+
+	read_lock(&tasklist_lock);
+	task = find_task_by_pid(pid);
+	if (task) {
+		task_lock(task);
+		mm = task->mm;
+		if (mm)
+			atomic_inc(&mm->mm_users);
+		task_unlock(task);
+	} else {
+		ret = -ESRCH;
+		read_unlock(&tasklist_lock);
+		goto out;
+	}
+	read_unlock(&tasklist_lock);
+	if (!mm)
+		goto out_einval;
+
+	/* set up the node_map array */
+	for (i = 0; i < MAX_NUMNODES; i++)
+		node_map[i] = -1;
+	for (i = 0; i < count; i++)
+		node_map[tmp_old_nodes[i]] = tmp_new_nodes[i];
+
+	/* prepare for lru list manipulation */
+  	smp_call_function(&lru_add_drain_per_cpu, NULL, 0, 1);
+	lru_add_drain();
+
+	/* actually do the migration */
+	down_read(&mm->mmap_sem);
+	for (vma = mm->mmap; vma; vma = vma->vm_next) {
+		ret = migrate_vma(task, mm, vma, node_map);
+		if (ret < 0)
+			goto out_up_mmap_sem;
+		migrated += ret;
+	}
+	up_read(&mm->mmap_sem);
+	ret = migrated;
+
+out:
+	if (mm)
+		mmput(mm);
+
+	kfree(tmp_old_nodes);
+	kfree(tmp_new_nodes);
+	kfree(node_map);
+
+	return ret;
+
+out_einval:
+	ret = -EINVAL;
+	goto out;
+
+out_up_mmap_sem:
+	up_read(&mm->mmap_sem);
+	goto out;
+
+}
+
 EXPORT_SYMBOL(generic_migrate_page);
 EXPORT_SYMBOL(migrate_page_common);
 EXPORT_SYMBOL(migrate_page_buffer);
Index: linux-2.6.13-rc1-mhp1-page-migration/kernel/sys_ni.c
===================================================================
--- linux-2.6.13-rc1-mhp1-page-migration.orig/kernel/sys_ni.c	2005-06-28 22:57:29.000000000 -0700
+++ linux-2.6.13-rc1-mhp1-page-migration/kernel/sys_ni.c	2005-06-30 11:17:48.000000000 -0700
@@ -40,6 +40,7 @@ cond_syscall(sys_shutdown);
 cond_syscall(sys_sendmsg);
 cond_syscall(sys_recvmsg);
 cond_syscall(sys_socketcall);
+cond_syscall(sys_migrate_pages);
 cond_syscall(sys_futex);
 cond_syscall(compat_sys_futex);
 cond_syscall(sys_epoll_create);

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
