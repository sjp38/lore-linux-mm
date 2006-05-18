Date: Thu, 18 May 2006 11:21:31 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Message-Id: <20060518182131.20734.27190.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20060518182111.20734.5489.sendpatchset@schroedinger.engr.sgi.com>
References: <20060518182111.20734.5489.sendpatchset@schroedinger.engr.sgi.com>
Subject: [RFC 4/5] page migration: Support moving of individual pages
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: akpm@osdl.org, bls@sgi.com, jes@sgi.com, Lee Schermerhorn <lee.schermerhorn@hp.com>, Christoph Lameter <clameter@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Add support for sys_move_pages()

move_pages() is used to move individual pages of a process. The function can
be used to determine the location of pages and to move them onto the desired
node. move_pages() returns status information for each page.

int move_pages(pid, number_of_pages_to_move,
		addresses_of_pages[],
		nodes[] or NULL,
		status[],
		flags);

The addresses of pages is an array of unsigned longs pointing to the
pages to be moved.

The nodes array contains the node numbers that the pages should be moved
to. If a NULL is passed then no pages are moved but the status array is
updated.

The status array contains a status indicating the result of the migration
operation or the current state of the page if nodes == NULL.

Possible page states:

0..MAX_NUMNODES		The page is now on the indicated node.

-ENOENT		Page is not present or target node is not present

-EPERM		Page is mapped by multiple processes and can only
		be moved if MPOL_MF_MOVE_ALL is specified. Or the
		target node is not allowed by the current cpuset.
		Or the page has been mlocked by a process/driver and
		cannot be moved.

-EBUSY		Page is busy and cannot be moved. Try again later.

-EFAULT		Cannot read node information from node array.

-ENOMEM		Unable to allocate memory on target node.

-EIO		Unable to write back page. Page must be written
		back since the page is dirty and the filesystem does not
		provide a migration function.

-EINVAL		Filesystem does not provide a migration function but also
		has no ability to write back pages.

The flags parameter indicates what types of pages to move:

MPOL_MF_MOVE	Move pages that are only mapped by the process.
MPOL_MF_MOVE_ALL Also move pages that are mapped by multiple processes.
		Requires sufficient capabilities.

Possible return codes from move_pages()

-EINVAL		flags other than MPOL_MF_MOVE(_ALL) specified or an attempt
		to migrate pages in a kernel thread.

-EPERM		MPOL_MF_MOVE_ALL specified without sufficient priviledges.
		or an attempt to move a process belonging to another user.

-ESRCH		Process does not exist.

-ENOMEM		Not enough memory to allocate control array.

-EFAULT		Parameters could not be accessed.

Test program for this may be found with the patches
on ftp.kernel.org:/pub/linux/kernel/people/christoph/pmig/patches-2.6.17-rc4-mm1

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.17-rc4-mm1/mm/migrate.c
===================================================================
--- linux-2.6.17-rc4-mm1.orig/mm/migrate.c	2006-05-18 09:56:43.766958108 -0700
+++ linux-2.6.17-rc4-mm1/mm/migrate.c	2006-05-18 10:02:04.586936931 -0700
@@ -25,6 +25,7 @@
 #include <linux/cpu.h>
 #include <linux/cpuset.h>
 #include <linux/writeback.h>
+#include <linux/mempolicy.h>
 
 #include "internal.h"
 
@@ -710,3 +711,176 @@ out:
 	return nr_failed + retry;
 }
 
+#ifdef CONFIG_NUMA
+/*
+ * Move a list of individual pages
+ */
+struct page_to_node {
+	struct page *page;
+	int node;
+	int status;
+};
+
+static struct page *new_page_node(struct page *p, unsigned long private)
+{
+	struct page_to_node *pm = (struct page_to_node *)private;
+
+	while (pm->page && pm->page != p)
+		pm++;
+
+	if (!pm->page)
+		return NULL;
+
+	return alloc_pages_node(pm->node, GFP_HIGHUSER, 0);
+}
+
+/*
+ * Move a list of pages in the address space of the currently executing
+ * process.
+ */
+asmlinkage long sys_move_pages(int pid, unsigned long nr_pages,
+			const unsigned long __user *pages,
+			const int __user *nodes,
+			int __user *status, int flags)
+{
+	int err = 0;
+	int i;
+	struct task_struct *task;
+	nodemask_t task_nodes;
+	struct mm_struct *mm;
+	struct page_to_node *pm = NULL;
+	LIST_HEAD(pagelist);
+
+	/* Check flags */
+	if (flags & ~(MPOL_MF_MOVE|MPOL_MF_MOVE_ALL))
+		return -EINVAL;
+
+	if ((flags & MPOL_MF_MOVE_ALL) && !capable(CAP_SYS_NICE))
+		return -EPERM;
+
+	/* Find the mm_struct */
+	read_lock(&tasklist_lock);
+	task = pid ? find_task_by_pid(pid) : current;
+	if (!task) {
+		read_unlock(&tasklist_lock);
+		return -ESRCH;
+	}
+	mm = get_task_mm(task);
+	read_unlock(&tasklist_lock);
+
+	if (!mm)
+		return -EINVAL;
+
+	/*
+	 * Check if this process has the right to modify the specified
+	 * process. The right exists if the process has administrative
+	 * capabilities, superuser privileges or the same
+	 * userid as the target process.
+	 */
+	if ((current->euid != task->suid) && (current->euid != task->uid) &&
+	    (current->uid != task->suid) && (current->uid != task->uid) &&
+	    !capable(CAP_SYS_NICE)) {
+		err = -EPERM;
+		goto out2;
+	}
+
+	task_nodes = cpuset_mems_allowed(task);
+	pm = kmalloc(GFP_KERNEL, (nr_pages + 1) * sizeof(struct page_to_node));
+	if (!pm) {
+		err = -ENOMEM;
+		goto out2;
+	}
+
+	down_read(&mm->mmap_sem);
+
+	for(i = 0 ; i < nr_pages; i++) {
+		unsigned long addr;
+		int node;
+		struct vm_area_struct *vma;
+		struct page *page;
+
+		pm[i].page = ZERO_PAGE(0);
+
+		err = -EFAULT;
+		if (get_user(addr, pages + i))
+			goto putback;
+
+		vma = find_vma(mm, addr);
+		if (!vma)
+			goto set_status;
+
+		page = follow_page(vma, addr, FOLL_GET);
+		err = -ENOENT;
+		if (!page)
+			goto set_status;
+
+		pm[i].page = page;
+		if (!nodes) {
+			err = page_to_nid(page);
+			put_page(page);
+			goto set_status;
+		}
+
+		err = -EPERM;
+		if (page_mapcount(page) > 1 &&
+				!(flags & MPOL_MF_MOVE_ALL)) {
+			put_page(page);
+			goto set_status;
+		}
+
+
+		err = isolate_lru_page(page, &pagelist);
+		__put_page(page);
+		if (err)
+			goto remove;
+
+		err = -EFAULT;
+		if (get_user(node, nodes + i))
+			goto remove;
+
+		err = -ENOENT;
+		if (!node_online(node))
+			goto remove;
+
+		err = -EPERM;
+		if (!node_isset(node, task_nodes))
+			goto remove;
+
+		pm[i].node = node;
+		err = 0;
+		if (node != page_to_nid(page))
+			goto set_status;
+
+		err = node;
+remove:
+		list_del(&page->lru);
+		move_to_lru(page);
+set_status:
+		pm[i].status = err;
+	}
+	err = 0;
+	if (!nodes || list_empty(&pagelist))
+		goto out;
+
+	pm[nr_pages].page = NULL;
+
+	err = migrate_pages(&pagelist, new_page_node, (unsigned long)pm);
+	goto out;
+
+putback:
+	putback_lru_pages(&pagelist);
+
+out:
+	up_read(&mm->mmap_sem);
+	if (err >= 0)
+		/* Return status information */
+		for(i = 0; i < nr_pages; i++)
+			put_user(pm[i].status, status +i);
+
+	kfree(pm);
+out2:
+	mmput(mm);
+	return err;
+}
+#endif
+
Index: linux-2.6.17-rc4-mm1/kernel/sys_ni.c
===================================================================
--- linux-2.6.17-rc4-mm1.orig/kernel/sys_ni.c	2006-05-11 16:31:53.000000000 -0700
+++ linux-2.6.17-rc4-mm1/kernel/sys_ni.c	2006-05-18 09:59:39.621304007 -0700
@@ -87,6 +87,7 @@ cond_syscall(sys_inotify_init);
 cond_syscall(sys_inotify_add_watch);
 cond_syscall(sys_inotify_rm_watch);
 cond_syscall(sys_migrate_pages);
+cond_syscall(sys_move_pages);
 cond_syscall(sys_chown16);
 cond_syscall(sys_fchown16);
 cond_syscall(sys_getegid16);
Index: linux-2.6.17-rc4-mm1/include/asm-ia64/unistd.h
===================================================================
--- linux-2.6.17-rc4-mm1.orig/include/asm-ia64/unistd.h	2006-05-15 15:40:11.023565789 -0700
+++ linux-2.6.17-rc4-mm1/include/asm-ia64/unistd.h	2006-05-18 09:59:39.623257011 -0700
@@ -265,7 +265,7 @@
 #define __NR_keyctl			1273
 #define __NR_ioprio_set			1274
 #define __NR_ioprio_get			1275
-/* 1276 is available for reuse (was briefly sys_set_zone_reclaim) */
+#define __NR_move_pages			1276
 #define __NR_inotify_init		1277
 #define __NR_inotify_add_watch		1278
 #define __NR_inotify_rm_watch		1279
Index: linux-2.6.17-rc4-mm1/arch/ia64/kernel/entry.S
===================================================================
--- linux-2.6.17-rc4-mm1.orig/arch/ia64/kernel/entry.S	2006-05-15 15:40:06.642978421 -0700
+++ linux-2.6.17-rc4-mm1/arch/ia64/kernel/entry.S	2006-05-18 09:59:39.625210015 -0700
@@ -1584,7 +1584,7 @@ sys_call_table:
 	data8 sys_keyctl
 	data8 sys_ioprio_set
 	data8 sys_ioprio_get			// 1275
-	data8 sys_ni_syscall
+	data8 sys_move_pages
 	data8 sys_inotify_init
 	data8 sys_inotify_add_watch
 	data8 sys_inotify_rm_watch

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
