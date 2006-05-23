Date: Tue, 23 May 2006 10:43:59 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Message-Id: <20060523174359.10156.70847.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20060523174344.10156.66845.sendpatchset@schroedinger.engr.sgi.com>
References: <20060523174344.10156.66845.sendpatchset@schroedinger.engr.sgi.com>
Subject: [3/5] move_pages: lots of fixups
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: Hugh Dickins <hugh@veritas.com>, linux-ia64@vger.kernel.org, Peter Zijlstra <a.p.zijlstra@chello.nl>, Lee Schermerhorn <lee.schermerhorn@hp.com>, Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org, Andi Kleen <ak@suse.de>, Christoph Lameter <clameter@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Fix up sys_move_pages()

1. Update comments and documentation.
2. Make the page array passed to sys_move_pages void **
3. Check for boundary conditions on the size of the pm array.
4. Use vmalloc for page array instead of kmalloc().
5. Process parameters before taking mmap_sem
6. Add the required call to migrate_prep().
7. Extract a couple of functions to simplify the function.
8. Add function prototype in include/linux/syscalls.h
9. Disambiguify the page status codes and the return code
   of the function.
10. Do not migrate reserved pages (zero pages etc)

Updated description of the function call:

move_pages() is used to move individual pages of a process. The function can
be used to determine the location of pages and to move them onto the desired
node. move_pages() returns status information for each page.

long move_pages(pid, number_of_pages_to_move,
		addresses_of_pages[],
		nodes[] or NULL,
		status[],
		flags);

The addresses of pages is an array of void * pointing to the
pages to be moved.

The nodes array contains the node numbers that the pages should be moved
to. If a NULL is passed instead of an array then no pages are moved but
the status array is updated. The status request may be used to determine
the page state before issuing another move_pages() to move pages.

The status array will contain the state of all individual page migration
attempts when the function terminates. The status array is only valid if
move_pages() completed successfullly.

Possible page states in status[]:

0..MAX_NUMNODES	The page is now on the indicated node.

-ENOENT		Page is not present

-EACCES		Page is mapped by multiple processes and can only
		be moved if MPOL_MF_MOVE_ALL is specified.

-EPERM		The page has been mlocked by a process/driver and
		cannot be moved.

-EBUSY		Page is busy and cannot be moved. Try again later.

-EFAULT		Invalid address (no VMA or zero page).

-ENOMEM		Unable to allocate memory on target node.

-EIO		Unable to write back page. The page must be written
		back in order to move it since the page is dirty and the
		filesystem does not provide a migration function that
		would allow the moving of dirty pages.

-EINVAL		A dirty page cannot be moved. The filesystem does not provide
		a migration function and has no ability to write back pages.

The flags parameter indicates what types of pages to move:

MPOL_MF_MOVE	Move pages that are only mapped by the process.

MPOL_MF_MOVE_ALL Also move pages that are mapped by multiple processes.
		Requires sufficient capabilities.

Possible return codes from move_pages()

-ENOENT		No pages found that would require moving. All pages
		are either already on the target node, not present, had an
		invalid address or could not be moved because they were
		mapped by multiple processes.

-EINVAL		Flags other than MPOL_MF_MOVE(_ALL) specified or an attempt
		to migrate pages in a kernel thread.

-EPERM		MPOL_MF_MOVE_ALL specified without sufficient priviledges.
		or an attempt to move a process belonging to another user.

-EACCES		One of the target nodes is not allowed by the current cpuset.

-ENODEV		One of the target nodes is not online.

-ESRCH		Process does not exist.

-E2BIG		Too many pages to move.

-ENOMEM		Not enough memory to allocate control array.

-EFAULT		Parameters could not be accessed.

A test program for move_pages() may be found with the patches
on ftp.kernel.org:/pub/linux/kernel/people/christoph/pmig/patches-2.6.17-rc4-mm3

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.17-rc4-mm3/mm/migrate.c
===================================================================
--- linux-2.6.17-rc4-mm3.orig/mm/migrate.c	2006-05-23 10:03:29.156194729 -0700
+++ linux-2.6.17-rc4-mm3/mm/migrate.c	2006-05-23 10:09:50.473360098 -0700
@@ -26,6 +26,7 @@
 #include <linux/cpuset.h>
 #include <linux/writeback.h>
 #include <linux/mempolicy.h>
+#include <linux/vmalloc.h>
 
 #include "internal.h"
 
@@ -63,9 +64,8 @@ int isolate_lru_page(struct page *page, 
 }
 
 /*
- * migrate_prep() needs to be called after we have compiled the list of pages
- * to be migrated using isolate_lru_page() but before we begin a series of calls
- * to migrate_pages().
+ * migrate_prep() needs to be called before we start compiling a list of pages
+ * to be migrated using isolate_lru_page().
  */
 int migrate_prep(void)
 {
@@ -723,6 +723,7 @@ out:
  * Move a list of individual pages
  */
 struct page_to_node {
+	unsigned long addr;
 	struct page *page;
 	int node;
 	int status;
@@ -733,10 +734,10 @@ static struct page *new_page_node(struct
 {
 	struct page_to_node *pm = (struct page_to_node *)private;
 
-	while (pm->page && pm->page != p)
+	while (pm->node != MAX_NUMNODES && pm->page != p)
 		pm++;
 
-	if (!pm->page)
+	if (pm->node == MAX_NUMNODES)
 		return NULL;
 
 	*result = &pm->status;
@@ -745,11 +746,122 @@ static struct page *new_page_node(struct
 }
 
 /*
+ * Move a set of pages as indicated in the pm array. The addr
+ * field must be set to the virtual address of the page to be moved
+ * and the node number must contain a valid target node.
+ */
+static int do_move_pages(struct mm_struct *mm, struct page_to_node *pm,
+				int migrate_all)
+{
+	int err;
+	struct page_to_node *pp;
+	LIST_HEAD(pagelist);
+
+	down_read(&mm->mmap_sem);
+
+	/*
+	 * Build a list of pages to migrate
+	 */
+	migrate_prep();
+	for (pp = pm; pp->node != MAX_NUMNODES; pp++) {
+		struct vm_area_struct *vma;
+		struct page *page;
+
+		/*
+		 * A valid page pointer that will not match any of the
+		 * pages that will be moved.
+		 */
+		pp->page = ZERO_PAGE(0);
+
+		err = -EFAULT;
+		vma = find_vma(mm, pp->addr);
+		if (!vma)
+			goto set_status;
+
+		page = follow_page(vma, pp->addr, FOLL_GET);
+		err = -ENOENT;
+		if (!page)
+			goto set_status;
+
+		if (PageReserved(page))		/* Check for zero page */
+			goto put_and_set;
+
+		pp->page = page;
+		err = page_to_nid(page);
+
+		if (err == pp->node)
+			/*
+			 * Node already in the right place
+			 */
+			goto put_and_set;
+
+		err = -EACCES;
+		if (page_mapcount(page) > 1 &&
+				!migrate_all)
+			goto put_and_set;
+
+		err = isolate_lru_page(page, &pagelist);
+put_and_set:
+		/*
+		 * Either remove the duplicate refcount from
+		 * isolate_lru_page() or drop the page ref if it was
+		 * not isolated.
+		 */
+		put_page(page);
+set_status:
+		pp->status = err;
+	}
+
+	if (!list_empty(&pagelist))
+		err = migrate_pages(&pagelist, new_page_node,
+				(unsigned long)pm);
+	else
+		err = -ENOENT;
+
+	up_read(&mm->mmap_sem);
+	return err;
+}
+
+/*
+ * Determine the nodes of a list of pages. The addr in the pm array
+ * must have been set to the virtual address of which we want to determine
+ * the node number.
+ */
+static int do_pages_stat(struct mm_struct *mm, struct page_to_node *pm)
+{
+	down_read(&mm->mmap_sem);
+
+	for ( ; pm->node != MAX_NUMNODES; pm++) {
+		struct vm_area_struct *vma;
+		struct page *page;
+		int err;
+
+		err = -EFAULT;
+		vma = find_vma(mm, pm->addr);
+		if (!vma)
+			goto set_status;
+
+		page = follow_page(vma, pm->addr, 0);
+		err = -ENOENT;
+		/* Use PageReserved to check for zero page */
+		if (!page || PageReserved(page))
+			goto set_status;
+
+		err = page_to_nid(page);
+set_status:
+		pm->status = err;
+	}
+
+	up_read(&mm->mmap_sem);
+	return 0;
+}
+
+/*
  * Move a list of pages in the address space of the currently executing
  * process.
  */
-asmlinkage long sys_move_pages(int pid, unsigned long nr_pages,
-			const unsigned long __user *pages,
+asmlinkage long sys_move_pages(pid_t pid, unsigned long nr_pages,
+			const void __user * __user *pages,
 			const int __user *nodes,
 			int __user *status, int flags)
 {
@@ -759,7 +871,6 @@ asmlinkage long sys_move_pages(int pid, 
 	nodemask_t task_nodes;
 	struct mm_struct *mm;
 	struct page_to_node *pm = NULL;
-	LIST_HEAD(pagelist);
 
 	/* Check flags */
 	if (flags & ~(MPOL_MF_MOVE|MPOL_MF_MOVE_ALL))
@@ -787,99 +898,64 @@ asmlinkage long sys_move_pages(int pid, 
 	}
 
 	task_nodes = cpuset_mems_allowed(task);
-	pm = kmalloc(GFP_KERNEL, (nr_pages + 1) * sizeof(struct page_to_node));
+
+	/* Limit nr_pages so that the multiplication may not overflow */
+	if (nr_pages >= ULONG_MAX / sizeof(struct page_to_node) - 1) {
+		err = -E2BIG;
+		goto out2;
+	}
+
+	pm = vmalloc((nr_pages + 1) * sizeof(struct page_to_node));
 	if (!pm) {
 		err = -ENOMEM;
 		goto out2;
 	}
 
-	down_read(&mm->mmap_sem);
-
-	for(i = 0 ; i < nr_pages; i++) {
-		unsigned long addr;
-		int node;
-		struct vm_area_struct *vma;
-		struct page *page;
-
-		pm[i].page = ZERO_PAGE(0);
+	/*
+	 * Get parameters from user space and initialize the pm
+	 * array. Return various errors if the user did something wrong.
+	 */
+	for (i = 0; i < nr_pages; i++) {
+		const void *p;
 
 		err = -EFAULT;
-		if (get_user(addr, pages + i))
-			goto putback;
-
-		vma = find_vma(mm, addr);
-		if (!vma)
-			goto set_status;
+		if (get_user(p, pages + i))
+			goto out;
 
-		page = follow_page(vma, addr, FOLL_GET);
-		err = -ENOENT;
-		if (!page)
-			goto set_status;
-
-		pm[i].page = page;
-		if (!nodes) {
-			err = page_to_nid(page);
-			put_page(page);
-			goto set_status;
-		}
+		pm[i].addr = (unsigned long)p;
+		if (nodes) {
+			int node;
 
-		err = -EPERM;
-		if (page_mapcount(page) > 1 &&
-				!(flags & MPOL_MF_MOVE_ALL)) {
-			put_page(page);
-			goto set_status;
-		}
-
-
-		err = isolate_lru_page(page, &pagelist);
-		__put_page(page);
-		if (err)
-			goto remove;
-
-		err = -EFAULT;
-		if (get_user(node, nodes + i))
-			goto remove;
-
-		err = -ENOENT;
-		if (!node_online(node))
-			goto remove;
+			if (get_user(node, nodes + i))
+				goto out;
 
-		err = -EPERM;
-		if (!node_isset(node, task_nodes))
-			goto remove;
+			err = -ENODEV;
+			if (!node_online(node))
+				goto out;
 
-		pm[i].node = node;
-		err = -EAGAIN;
-		if (node != page_to_nid(page))
-			goto set_status;
+			err = -EACCES;
+			if (!node_isset(node, task_nodes))
+				goto out;
 
-		err = node;
-remove:
-		list_del(&page->lru);
-		move_to_lru(page);
-set_status:
-		pm[i].status = err;
+			pm[i].node = node;
+		}
 	}
-	err = 0;
-	if (!nodes || list_empty(&pagelist))
-		goto out;
+	/* End marker */
+	pm[nr_pages].node = MAX_NUMNODES;
 
-	pm[nr_pages].page = NULL;
-
-	err = migrate_pages(&pagelist, new_page_node, (unsigned long)pm);
-	goto out;
-
-putback:
-	putback_lru_pages(&pagelist);
+	if (nodes)
+		err = do_move_pages(mm, pm, flags & MPOL_MF_MOVE_ALL);
+	else
+		err = do_pages_stat(mm, pm);
 
-out:
-	up_read(&mm->mmap_sem);
 	if (err >= 0)
 		/* Return status information */
-		for(i = 0; i < nr_pages; i++)
-			put_user(pm[i].status, status +i);
+		for (i = 0; i < nr_pages; i++)
+			if (put_user(pm[i].status, status + i))
+				err = -EFAULT;
 
-	kfree(pm);
+out:
+	vfree(pm);
 out2:
 	mmput(mm);
 	return err;
Index: linux-2.6.17-rc4-mm3/Documentation/vm/page_migration
===================================================================
--- linux-2.6.17-rc4-mm3.orig/Documentation/vm/page_migration	2006-05-22 18:03:26.500852784 -0700
+++ linux-2.6.17-rc4-mm3/Documentation/vm/page_migration	2006-05-23 10:03:36.021003240 -0700
@@ -26,8 +26,13 @@ a process are located. See also the numa
 Manual migration is useful if for example the scheduler has relocated
 a process to a processor on a distant node. A batch scheduler or an
 administrator may detect the situation and move the pages of the process
-nearer to the new processor. At some point in the future we may have
-some mechanism in the scheduler that will automatically move the pages.
+nearer to the new processor. The kernel itself does only provide
+manual page migration support. Automatic page migration may be implemented
+through user space processes that move pages. A special function call
+"move_pages" allows the moving of individual pages within a process.
+A NUMA profiler may f.e. obtain a log showing frequent off node
+accesses and may use the result to move pages to more advantageous
+locations.
 
 Larger installations usually partition the system using cpusets into
 sections of nodes. Paul Jackson has equipped cpusets with the ability to
@@ -62,22 +67,14 @@ A. In kernel use of migrate_pages()
    It also prevents the swapper or other scans to encounter
    the page.
 
-2. Generate a list of newly allocates pages. These pages will contain the
-   contents of the pages from the first list after page migration is
-   complete.
+2. We need to have a function of type new_page_t that can be
+   passed to migrate_pages(). This function should figure out
+   how to allocate the correct new page given the old page.
 
 3. The migrate_pages() function is called which attempts
-   to do the migration. It returns the moved pages in the
-   list specified as the third parameter and the failed
-   migrations in the fourth parameter. When the function
-   returns the first list will contain the pages that could still be retried.
-
-4. The leftover pages of various types are returned
-   to the LRU using putback_to_lru_pages() or otherwise
-   disposed of. The pages will still have the refcount as
-   increased by isolate_lru_pages() if putback_to_lru_pages() is not
-   used! The kernel may want to handle the various cases of failures in
-   different ways.
+   to do the migration. It will call the function to allocate
+   the new page for each page that is considered for
+   moving.
 
 B. How migrate_pages() works
 ----------------------------
Index: linux-2.6.17-rc4-mm3/include/linux/syscalls.h
===================================================================
--- linux-2.6.17-rc4-mm3.orig/include/linux/syscalls.h	2006-05-22 18:03:31.876495496 -0700
+++ linux-2.6.17-rc4-mm3/include/linux/syscalls.h	2006-05-23 10:03:36.022956244 -0700
@@ -515,6 +515,11 @@ asmlinkage long sys_set_mempolicy(int mo
 asmlinkage long sys_migrate_pages(pid_t pid, unsigned long maxnode,
 				const unsigned long __user *from,
 				const unsigned long __user *to);
+asmlinkage long sys_move_pages(pid_t pid, unsigned long nr_pages,
+				const void __user * __user *pages,
+				const int __user *nodes,
+				int __user *status,
+				int flags);
 asmlinkage long sys_mbind(unsigned long start, unsigned long len,
 				unsigned long mode,
 				unsigned long __user *nmask,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
