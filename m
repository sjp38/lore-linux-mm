Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id ED0266B0055
	for <linux-mm@kvack.org>; Tue, 28 Apr 2009 23:20:06 -0400 (EDT)
Received: from sj-core-2.cisco.com (sj-core-2.cisco.com [171.71.177.254])
	by sj-dkim-2.cisco.com (8.12.11/8.12.11) with ESMTP id n3T3KOcF020281
	for <linux-mm@kvack.org>; Tue, 28 Apr 2009 20:20:24 -0700
Received: from cliff.cisco.com (cliff.cisco.com [171.69.11.141])
	by sj-core-2.cisco.com (8.13.8/8.13.8) with ESMTP id n3T3KOE5013638
	for <linux-mm@kvack.org>; Wed, 29 Apr 2009 03:20:24 GMT
Received: from cuplxvomd02.corp.sa.net ([64.101.20.155]) by cliff.cisco.com (8.6.12/8.6.5) with ESMTP id DAA22027 for <linux-mm@kvack.org>; Wed, 29 Apr 2009 03:20:24 GMT
Date: Tue, 28 Apr 2009 20:20:24 -0700
From: David VomLehn <dvomlehn@cisco.com>
Subject: [Patch 1/2] MM: Consolidate memory management functions
Message-ID: <20090429032024.GA26211@cuplxvomd02.corp.sa.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This is the first part of a previous patch which has now been split into two
pieces to make review simpler. This part consolidates duplicates of MMU and
MMU-less memory managment functions into mm/util.c:

__vm_enough_memory
	Moved the MMU version of this from mm/mmap.c and the MMU-less version
	from mm/nommu.c.  The only difference between the two versions of
	this function was the use of hugetlb_total_pages() in the MMU version,
	which might reasonably be expected to be zero in all non-MMU systems
	and thus a NOP.

get_user_pages
	Moved the MMU version from mm/memory.c and the MMU-less version
	from mm/nommu.c. The two versions of these were identical.

Signed-off-by: David VomLehn <dvomlehn@cisco.com>
---
 mm/memory.c |   18 --------
 mm/mmap.c   |  107 ----------------------------------------------
 mm/nommu.c  |  130 --------------------------------------------------------
 mm/util.c   |  136 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 136 insertions(+), 255 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index cf6873e..8837dd4 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1360,24 +1360,6 @@ int __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
 	return i;
 }
 
-int get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
-		unsigned long start, int len, int write, int force,
-		struct page **pages, struct vm_area_struct **vmas)
-{
-	int flags = 0;
-
-	if (write)
-		flags |= GUP_FLAGS_WRITE;
-	if (force)
-		flags |= GUP_FLAGS_FORCE;
-
-	return __get_user_pages(tsk, mm,
-				start, len, flags,
-				pages, vmas);
-}
-
-EXPORT_SYMBOL(get_user_pages);
-
 pte_t *get_locked_pte(struct mm_struct *mm, unsigned long addr,
 			spinlock_t **ptl)
 {
diff --git a/mm/mmap.c b/mm/mmap.c
index 4a38411..2079b02 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -82,114 +82,7 @@ pgprot_t vm_get_page_prot(unsigned long vm_flags)
 }
 EXPORT_SYMBOL(vm_get_page_prot);
 
-int sysctl_overcommit_memory = OVERCOMMIT_GUESS;  /* heuristic overcommit */
-int sysctl_overcommit_ratio = 50;	/* default is 50% */
 int sysctl_max_map_count __read_mostly = DEFAULT_MAX_MAP_COUNT;
-atomic_long_t vm_committed_space = ATOMIC_LONG_INIT(0);
-
-/*
- * Check that a process has enough memory to allocate a new virtual
- * mapping. 0 means there is enough memory for the allocation to
- * succeed and -ENOMEM implies there is not.
- *
- * We currently support three overcommit policies, which are set via the
- * vm.overcommit_memory sysctl.  See Documentation/vm/overcommit-accounting
- *
- * Strict overcommit modes added 2002 Feb 26 by Alan Cox.
- * Additional code 2002 Jul 20 by Robert Love.
- *
- * cap_sys_admin is 1 if the process has admin privileges, 0 otherwise.
- *
- * Note this is a helper function intended to be used by LSMs which
- * wish to use this logic.
- */
-int __vm_enough_memory(struct mm_struct *mm, long pages, int cap_sys_admin)
-{
-	unsigned long free, allowed;
-
-	vm_acct_memory(pages);
-
-	/*
-	 * Sometimes we want to use more memory than we have
-	 */
-	if (sysctl_overcommit_memory == OVERCOMMIT_ALWAYS)
-		return 0;
-
-	if (sysctl_overcommit_memory == OVERCOMMIT_GUESS) {
-		unsigned long n;
-
-		free = global_page_state(NR_FILE_PAGES);
-		free += nr_swap_pages;
-
-		/*
-		 * Any slabs which are created with the
-		 * SLAB_RECLAIM_ACCOUNT flag claim to have contents
-		 * which are reclaimable, under pressure.  The dentry
-		 * cache and most inode caches should fall into this
-		 */
-		free += global_page_state(NR_SLAB_RECLAIMABLE);
-
-		/*
-		 * Leave the last 3% for root
-		 */
-		if (!cap_sys_admin)
-			free -= free / 32;
-
-		if (free > pages)
-			return 0;
-
-		/*
-		 * nr_free_pages() is very expensive on large systems,
-		 * only call if we're about to fail.
-		 */
-		n = nr_free_pages();
-
-		/*
-		 * Leave reserved pages. The pages are not for anonymous pages.
-		 */
-		if (n <= totalreserve_pages)
-			goto error;
-		else
-			n -= totalreserve_pages;
-
-		/*
-		 * Leave the last 3% for root
-		 */
-		if (!cap_sys_admin)
-			n -= n / 32;
-		free += n;
-
-		if (free > pages)
-			return 0;
-
-		goto error;
-	}
-
-	allowed = (totalram_pages - hugetlb_total_pages())
-	       	* sysctl_overcommit_ratio / 100;
-	/*
-	 * Leave the last 3% for root
-	 */
-	if (!cap_sys_admin)
-		allowed -= allowed / 32;
-	allowed += total_swap_pages;
-
-	/* Don't let a single process grow too big:
-	   leave 3% of the size of this process for other processes */
-	if (mm)
-		allowed -= mm->total_vm / 32;
-
-	/*
-	 * cast `allowed' as a signed long because vm_committed_space
-	 * sometimes has a negative value
-	 */
-	if (atomic_long_read(&vm_committed_space) < (long)allowed)
-		return 0;
-error:
-	vm_unacct_memory(pages);
-
-	return -ENOMEM;
-}
 
 /*
  * Requires inode->i_mapping->i_mmap_lock
diff --git a/mm/nommu.c b/mm/nommu.c
index 72eda4a..b140a18 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -62,9 +62,6 @@ void *high_memory;
 struct page *mem_map;
 unsigned long max_mapnr;
 unsigned long num_physpages;
-atomic_long_t vm_committed_space = ATOMIC_LONG_INIT(0);
-int sysctl_overcommit_memory = OVERCOMMIT_GUESS; /* heuristic overcommit */
-int sysctl_overcommit_ratio = 50; /* default is 50% */
 int sysctl_max_map_count = DEFAULT_MAX_MAP_COUNT;
 int sysctl_nr_trim_pages = 1; /* page trimming behaviour */
 int heap_stack_gap = 0;
@@ -213,30 +210,6 @@ finish_or_fault:
 }
 
 
-/*
- * get a list of pages in an address range belonging to the specified process
- * and indicate the VMA that covers each page
- * - this is potentially dodgy as we may end incrementing the page count of a
- *   slab page or a secondary page from a compound page
- * - don't permit access to VMAs that don't support it, such as I/O mappings
- */
-int get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
-	unsigned long start, int len, int write, int force,
-	struct page **pages, struct vm_area_struct **vmas)
-{
-	int flags = 0;
-
-	if (write)
-		flags |= GUP_FLAGS_WRITE;
-	if (force)
-		flags |= GUP_FLAGS_FORCE;
-
-	return __get_user_pages(tsk, mm,
-				start, len, flags,
-				pages, vmas);
-}
-EXPORT_SYMBOL(get_user_pages);
-
 DEFINE_RWLOCK(vmlist_lock);
 struct vm_struct *vmlist;
 
@@ -1756,109 +1729,6 @@ unsigned long get_unmapped_area(struct file *file, unsigned long addr,
 }
 EXPORT_SYMBOL(get_unmapped_area);
 
-/*
- * Check that a process has enough memory to allocate a new virtual
- * mapping. 0 means there is enough memory for the allocation to
- * succeed and -ENOMEM implies there is not.
- *
- * We currently support three overcommit policies, which are set via the
- * vm.overcommit_memory sysctl.  See Documentation/vm/overcommit-accounting
- *
- * Strict overcommit modes added 2002 Feb 26 by Alan Cox.
- * Additional code 2002 Jul 20 by Robert Love.
- *
- * cap_sys_admin is 1 if the process has admin privileges, 0 otherwise.
- *
- * Note this is a helper function intended to be used by LSMs which
- * wish to use this logic.
- */
-int __vm_enough_memory(struct mm_struct *mm, long pages, int cap_sys_admin)
-{
-	unsigned long free, allowed;
-
-	vm_acct_memory(pages);
-
-	/*
-	 * Sometimes we want to use more memory than we have
-	 */
-	if (sysctl_overcommit_memory == OVERCOMMIT_ALWAYS)
-		return 0;
-
-	if (sysctl_overcommit_memory == OVERCOMMIT_GUESS) {
-		unsigned long n;
-
-		free = global_page_state(NR_FILE_PAGES);
-		free += nr_swap_pages;
-
-		/*
-		 * Any slabs which are created with the
-		 * SLAB_RECLAIM_ACCOUNT flag claim to have contents
-		 * which are reclaimable, under pressure.  The dentry
-		 * cache and most inode caches should fall into this
-		 */
-		free += global_page_state(NR_SLAB_RECLAIMABLE);
-
-		/*
-		 * Leave the last 3% for root
-		 */
-		if (!cap_sys_admin)
-			free -= free / 32;
-
-		if (free > pages)
-			return 0;
-
-		/*
-		 * nr_free_pages() is very expensive on large systems,
-		 * only call if we're about to fail.
-		 */
-		n = nr_free_pages();
-
-		/*
-		 * Leave reserved pages. The pages are not for anonymous pages.
-		 */
-		if (n <= totalreserve_pages)
-			goto error;
-		else
-			n -= totalreserve_pages;
-
-		/*
-		 * Leave the last 3% for root
-		 */
-		if (!cap_sys_admin)
-			n -= n / 32;
-		free += n;
-
-		if (free > pages)
-			return 0;
-
-		goto error;
-	}
-
-	allowed = totalram_pages * sysctl_overcommit_ratio / 100;
-	/*
-	 * Leave the last 3% for root
-	 */
-	if (!cap_sys_admin)
-		allowed -= allowed / 32;
-	allowed += total_swap_pages;
-
-	/* Don't let a single process grow too big:
-	   leave 3% of the size of this process for other processes */
-	if (mm)
-		allowed -= mm->total_vm / 32;
-
-	/*
-	 * cast `allowed' as a signed long because vm_committed_space
-	 * sometimes has a negative value
-	 */
-	if (atomic_long_read(&vm_committed_space) < (long)allowed)
-		return 0;
-error:
-	vm_unacct_memory(pages);
-
-	return -ENOMEM;
-}
-
 int in_gate_area_no_task(unsigned long addr)
 {
 	return 0;
diff --git a/mm/util.c b/mm/util.c
index 55bef16..5cdaa35 100644
--- a/mm/util.c
+++ b/mm/util.c
@@ -6,6 +6,10 @@
 #include <linux/sched.h>
 #include <linux/tracepoint.h>
 #include <asm/uaccess.h>
+#include <linux/swap.h>
+#include <linux/mman.h>
+#include <linux/hugetlb.h>
+#include "internal.h"
 
 /**
  * kstrdup - allocate space for and copy an existing string
@@ -223,6 +227,30 @@ void arch_pick_mmap_layout(struct mm_struct *mm)
 }
 #endif
 
+/*
+ * get a list of pages in an address range belonging to the specified process
+ * and indicate the VMA that covers each page
+ * - this is potentially dodgy as we may end incrementing the page count of a
+ *   slab page or a secondary page from a compound page
+ * - don't permit access to VMAs that don't support it, such as I/O mappings
+ */
+int get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
+	unsigned long start, int len, int write, int force,
+	struct page **pages, struct vm_area_struct **vmas)
+{
+	int flags = 0;
+
+	if (write)
+		flags |= GUP_FLAGS_WRITE;
+	if (force)
+		flags |= GUP_FLAGS_FORCE;
+
+	return __get_user_pages(tsk, mm,
+				start, len, flags,
+				pages, vmas);
+}
+EXPORT_SYMBOL(get_user_pages);
+
 /**
  * get_user_pages_fast() - pin user pages in memory
  * @start:	starting user address
@@ -254,6 +282,114 @@ int __attribute__((weak)) get_user_pages_fast(unsigned long start,
 }
 EXPORT_SYMBOL_GPL(get_user_pages_fast);
 
+int sysctl_overcommit_memory = OVERCOMMIT_GUESS;  /* heuristic overcommit */
+int sysctl_overcommit_ratio = 50;	/* default is 50% */
+atomic_long_t vm_committed_space = ATOMIC_LONG_INIT(0);
+
+/*
+ * Check that a process has enough memory to allocate a new virtual
+ * mapping. 0 means there is enough memory for the allocation to
+ * succeed and -ENOMEM implies there is not.
+ *
+ * We currently support three overcommit policies, which are set via the
+ * vm.overcommit_memory sysctl.  See Documentation/vm/overcommit-accounting
+ *
+ * Strict overcommit modes added 2002 Feb 26 by Alan Cox.
+ * Additional code 2002 Jul 20 by Robert Love.
+ *
+ * cap_sys_admin is 1 if the process has admin privileges, 0 otherwise.
+ *
+ * Note this is a helper function intended to be used by LSMs which
+ * wish to use this logic.
+ */
+int __vm_enough_memory(struct mm_struct *mm, long pages, int cap_sys_admin)
+{
+	unsigned long free, allowed;
+
+	vm_acct_memory(pages);
+
+	/*
+	 * Sometimes we want to use more memory than we have
+	 */
+	if (sysctl_overcommit_memory == OVERCOMMIT_ALWAYS)
+		return 0;
+
+	if (sysctl_overcommit_memory == OVERCOMMIT_GUESS) {
+		unsigned long n;
+
+		free = global_page_state(NR_FILE_PAGES);
+		free += nr_swap_pages;
+
+		/*
+		 * Any slabs which are created with the
+		 * SLAB_RECLAIM_ACCOUNT flag claim to have contents
+		 * which are reclaimable, under pressure.  The dentry
+		 * cache and most inode caches should fall into this
+		 */
+		free += global_page_state(NR_SLAB_RECLAIMABLE);
+
+		/*
+		 * Leave the last 3% for root
+		 */
+		if (!cap_sys_admin)
+			free -= free / 32;
+
+		if (free > pages)
+			return 0;
+
+		/*
+		 * nr_free_pages() is very expensive on large systems,
+		 * only call if we're about to fail.
+		 */
+		n = nr_free_pages();
+
+		/*
+		 * Leave reserved pages. The pages are not for anonymous pages.
+		 */
+		if (n <= totalreserve_pages)
+			goto error;
+		else
+			n -= totalreserve_pages;
+
+		/*
+		 * Leave the last 3% for root
+		 */
+		if (!cap_sys_admin)
+			n -= n / 32;
+		free += n;
+
+		if (free > pages)
+			return 0;
+
+		goto error;
+	}
+
+	allowed = (totalram_pages - hugetlb_total_pages())
+		* sysctl_overcommit_ratio / 100;
+	/*
+	 * Leave the last 3% for root
+	 */
+	if (!cap_sys_admin)
+		allowed -= allowed / 32;
+	allowed += total_swap_pages;
+
+	/* Don't let a single process grow too big:
+	   leave 3% of the size of this process for other processes */
+	if (mm)
+		allowed -= mm->total_vm / 32;
+
+	/*
+	 * cast `allowed' as a signed long because vm_committed_space
+	 * sometimes has a negative value
+	 */
+	if (atomic_long_read(&vm_committed_space) < (long)allowed)
+		return 0;
+error:
+	vm_unacct_memory(pages);
+
+	return -ENOMEM;
+}
+
 /* Tracepoints definitions. */
 DEFINE_TRACE(kmalloc);
 DEFINE_TRACE(kmem_cache_alloc);
config-vm_enough_memory	-	Add sysctls for vm_enough_memory	MM

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
