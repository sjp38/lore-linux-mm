Date: Tue, 10 May 2005 21:38:21 -0700 (PDT)
From: Ray Bryant <raybry@sgi.com>
Message-Id: <20050511043821.10876.47127.71762@jackhammer.engr.sgi.com>
In-Reply-To: <20050511043756.10876.72079.60115@jackhammer.engr.sgi.com>
References: <20050511043756.10876.72079.60115@jackhammer.engr.sgi.com>
Subject: [PATCH 2.6.12-rc3 4/8] mm: manual page migration-rc2 -- add-sys_migrate_pages-rc2.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hirokazu Takahashi <taka@valinux.co.jp>, Marcelo Tosatti <marcelo.tosatti@cyclades.com>, Andi Kleen <ak@suse.de>, Dave Hansen <haveblue@us.ibm.com>
Cc: Christoph Hellwig <hch@infradead.org>, linux-mm <linux-mm@kvack.org>, Nathan Scott <nathans@sgi.com>, Ray Bryant <raybry@austin.rr.com>, lhms-devel@lists.sourceforge.net, Ray Bryant <raybry@sgi.com>
List-ID: <linux-mm.kvack.org>

This is the main patch that creates the migrate_pages() system
call.  Note that in this case, the system call number was more
or less arbitrarily assigned at 1279.  This number needs to
allocated.

This patch sits on top of the page migration patches from
the Memory Hotplug project.  This particular patchset is built
on top of:

http://www.sr71.net/patches/2.6.12/2.6.12-rc3-mhp1/page_migration/patch-2.6.12-rc3-mhp1-pm.gz

but it may appy on subsequent page migration patches as well.

This patch migrates all pages in the specified process (including
shared libraries.)

See the patch sys_migrate_pages-xattr-support.patch where the
extended attribute "system.migration" is used to identify shared
libraries and non-migratable files.

Signed-off-by: Ray Bryant <raybry@sgi.com>

 arch/ia64/kernel/entry.S |    6 +
 mm/mmigrate.c            |  182 +++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 187 insertions(+), 1 deletion(-)

Index: linux-2.6.12-rc3-mhp1-page-migration-export/arch/ia64/kernel/entry.S
===================================================================
--- linux-2.6.12-rc3-mhp1-page-migration-export.orig/arch/ia64/kernel/entry.S	2005-04-20 17:03:12.000000000 -0700
+++ linux-2.6.12-rc3-mhp1-page-migration-export/arch/ia64/kernel/entry.S	2005-05-10 10:22:24.000000000 -0700
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
Index: linux-2.6.12-rc3-mhp1-page-migration-export/mm/mmigrate.c
===================================================================
--- linux-2.6.12-rc3-mhp1-page-migration-export.orig/mm/mmigrate.c	2005-05-10 10:22:24.000000000 -0700
+++ linux-2.6.12-rc3-mhp1-page-migration-export/mm/mmigrate.c	2005-05-10 10:40:35.000000000 -0700
@@ -5,6 +5,9 @@
  *
  *  Authors:	IWAMOTO Toshihiro <iwamoto@valinux.co.jp>
  *		Hirokazu Takahashi <taka@valinux.co.jp>
+ *
+ * sys_migrate_pages() added by Ray Bryant <raybry@sgi.com>
+ * Copyright (C) 2005, Silicon Graphics, Inc.
  */
 
 #include <linux/config.h>
@@ -21,6 +24,9 @@
 #include <linux/rmap.h>
 #include <linux/mmigrate.h>
 #include <linux/delay.h>
+#include <linux/blkdev.h>
+#include <linux/nodemask.h>
+#include <asm/bitops.h>
 
 /*
  * The concept of memory migration is to replace a target page with
@@ -587,6 +593,182 @@ int try_to_migrate_pages(struct list_hea
 	return nr_busy;
 }
 
+static int
+migrate_vma(struct task_struct *task, struct mm_struct *mm,
+	struct vm_area_struct *vma, short *node_map)
+{
+	struct page *page;
+	struct zone *zone;
+	unsigned long vaddr;
+	int count = 0, nid, pass = 0, nr_busy = 0;
+	LIST_HEAD(page_list);
+
+	/* can't migrate mlock()'d pages */
+	if (vma->vm_flags & VM_LOCKED)
+		return 0;
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
+			nid = page_to_nid(page);
+			if (node_map[nid] >= 0) {
+				zone = page_zone(page);
+				if (PageLRU(page) &&
+				    steal_page_from_lru(zone, page, &page_list))
+					count++;
+				else
+					BUG();
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
+	if ((count < 1) || (count > MAX_NUMNODES))
+		return -EINVAL;
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
+	if (copy_from_user(tmp_old_nodes, old_nodes, size) ||
+	    copy_from_user(tmp_new_nodes, new_nodes, size)) {
+		ret = -EFAULT;
+		goto out;
+	}
+
+	/* Make sure node arguments are within valid limits */
+	for(i = 0; i < count; i++)
+		if ((tmp_old_nodes[i] < 0) 		||
+		    (tmp_old_nodes[i] >= MAX_NUMNODES)  ||
+		    (tmp_new_nodes[i] < 0) 		||
+		    (tmp_new_nodes[i] >= MAX_NUMNODES)) {
+		    	ret = -EINVAL;
+			goto out;
+		}
+
+	/* disallow migration to an off-line node */
+	for(i = 0; i < count; i++)
+		if (!node_online(tmp_new_nodes[i])) {
+			ret = -EINVAL;
+			goto out;
+		}
+
+	/*
+	 * old_nodes and new_nodes must be disjoint
+	 */
+	nodes_clear(nodes);
+	for(i=0; i<count; i++)
+		node_set(tmp_old_nodes[i], nodes);
+	for(i=0; i<count; i++)
+		if(node_isset(tmp_new_nodes[i], nodes)) {
+			ret = -EINVAL;
+			goto out;
+		}
+
+	/* find the task and mm_structs for this process */
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
+	if (!mm) {
+		ret = -EINVAL;
+		goto out;
+	}
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
+	/* actually do the migration */
+	for (vma = mm->mmap; vma; vma = vma->vm_next) {
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
