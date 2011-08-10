Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 58C016B0171
	for <linux-mm@kvack.org>; Wed, 10 Aug 2011 16:21:51 -0400 (EDT)
Date: Wed, 10 Aug 2011 15:21:47 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: [RFC] mm: Distinguish between mlocked and pinned pages
Message-ID: <alpine.DEB.2.00.1108101516430.20403@router.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, linux-mm@kvack.org
Cc: linux-rdma@vger.kernel.org, Hugh Dickins <hughd@google.com>

Some kernel components pin user space memory (infiniband and perf)
(by increasing the page count) and account that memory as "mlocked".

The difference between mlocking and pinning is:

A. mlocked pages are marked with PG_mlocked and are exempt from
   swapping. Page migration may move them around though.
   They are kept on a special LRU list.

B. Pinned pages cannot be moved because something needs to
   directly access physical memory. They may not be on any
   LRU list.

I recently saw an mlockalled process where mm->locked_vm became
bigger than the virtual size of the process (!) because some
memory was accounted for twice:

Once when the page was mlocked and once when the Infiniband
layer increased the refcount because it needt to pin the RDMA
memory.

This patch introduces a separate counter for pinned pages and
accounts them seperately.

Signed-off-by: Christoph Lameter <cl@linux.com>

---
 drivers/infiniband/core/umem.c                 |    6 +++---
 drivers/infiniband/hw/ipath/ipath_user_pages.c |    6 +++---
 drivers/infiniband/hw/qib/qib_user_pages.c     |    4 ++--
 fs/proc/task_mmu.c                             |    2 ++
 include/linux/mm_types.h                       |    2 +-
 kernel/events/core.c                           |    6 +++---
 6 files changed, 14 insertions(+), 12 deletions(-)

Index: linux-2.6/fs/proc/task_mmu.c
===================================================================
--- linux-2.6.orig/fs/proc/task_mmu.c	2011-08-10 14:08:42.000000000 -0500
+++ linux-2.6/fs/proc/task_mmu.c	2011-08-10 15:01:37.000000000 -0500
@@ -44,6 +44,7 @@ void task_mem(struct seq_file *m, struct
 		"VmPeak:\t%8lu kB\n"
 		"VmSize:\t%8lu kB\n"
 		"VmLck:\t%8lu kB\n"
+		"VmPin:\t%8lu kB\n"
 		"VmHWM:\t%8lu kB\n"
 		"VmRSS:\t%8lu kB\n"
 		"VmData:\t%8lu kB\n"
@@ -55,6 +56,7 @@ void task_mem(struct seq_file *m, struct
 		hiwater_vm << (PAGE_SHIFT-10),
 		(total_vm - mm->reserved_vm) << (PAGE_SHIFT-10),
 		mm->locked_vm << (PAGE_SHIFT-10),
+		mm->pinned_vm << (PAGE_SHIFT-10),
 		hiwater_rss << (PAGE_SHIFT-10),
 		total_rss << (PAGE_SHIFT-10),
 		data << (PAGE_SHIFT-10),
Index: linux-2.6/include/linux/mm_types.h
===================================================================
--- linux-2.6.orig/include/linux/mm_types.h	2011-08-10 14:08:42.000000000 -0500
+++ linux-2.6/include/linux/mm_types.h	2011-08-10 14:09:02.000000000 -0500
@@ -281,7 +281,7 @@ struct mm_struct {
 	unsigned long hiwater_rss;	/* High-watermark of RSS usage */
 	unsigned long hiwater_vm;	/* High-water virtual memory usage */

-	unsigned long total_vm, locked_vm, shared_vm, exec_vm;
+	unsigned long total_vm, locked_vm, pinned_vm, shared_vm, exec_vm;
 	unsigned long stack_vm, reserved_vm, def_flags, nr_ptes;
 	unsigned long start_code, end_code, start_data, end_data;
 	unsigned long start_brk, brk, start_stack;
Index: linux-2.6/drivers/infiniband/core/umem.c
===================================================================
--- linux-2.6.orig/drivers/infiniband/core/umem.c	2011-08-10 14:08:57.000000000 -0500
+++ linux-2.6/drivers/infiniband/core/umem.c	2011-08-10 14:09:06.000000000 -0500
@@ -136,7 +136,7 @@ struct ib_umem *ib_umem_get(struct ib_uc

 	down_write(&current->mm->mmap_sem);

-	locked     = npages + current->mm->locked_vm;
+	locked     = npages + current->mm->pinned_vm;
 	lock_limit = rlimit(RLIMIT_MEMLOCK) >> PAGE_SHIFT;

 	if ((locked > lock_limit) && !capable(CAP_IPC_LOCK)) {
@@ -206,7 +206,7 @@ out:
 		__ib_umem_release(context->device, umem, 0);
 		kfree(umem);
 	} else
-		current->mm->locked_vm = locked;
+		current->mm->pinned_vm = locked;

 	up_write(&current->mm->mmap_sem);
 	if (vma_list)
@@ -222,7 +222,7 @@ static void ib_umem_account(struct work_
 	struct ib_umem *umem = container_of(work, struct ib_umem, work);

 	down_write(&umem->mm->mmap_sem);
-	umem->mm->locked_vm -= umem->diff;
+	umem->mm->pinned_vm -= umem->diff;
 	up_write(&umem->mm->mmap_sem);
 	mmput(umem->mm);
 	kfree(umem);
Index: linux-2.6/drivers/infiniband/hw/ipath/ipath_user_pages.c
===================================================================
--- linux-2.6.orig/drivers/infiniband/hw/ipath/ipath_user_pages.c	2011-08-10 14:08:57.000000000 -0500
+++ linux-2.6/drivers/infiniband/hw/ipath/ipath_user_pages.c	2011-08-10 14:09:06.000000000 -0500
@@ -79,7 +79,7 @@ static int __ipath_get_user_pages(unsign
 			goto bail_release;
 	}

-	current->mm->locked_vm += num_pages;
+	current->mm->pinned_vm += num_pages;

 	ret = 0;
 	goto bail;
@@ -178,7 +178,7 @@ void ipath_release_user_pages(struct pag

 	__ipath_release_user_pages(p, num_pages, 1);

-	current->mm->locked_vm -= num_pages;
+	current->mm->pinned_vm -= num_pages;

 	up_write(&current->mm->mmap_sem);
 }
@@ -195,7 +195,7 @@ static void user_pages_account(struct wo
 		container_of(_work, struct ipath_user_pages_work, work);

 	down_write(&work->mm->mmap_sem);
-	work->mm->locked_vm -= work->num_pages;
+	work->mm->pinned_vm -= work->num_pages;
 	up_write(&work->mm->mmap_sem);
 	mmput(work->mm);
 	kfree(work);
Index: linux-2.6/drivers/infiniband/hw/qib/qib_user_pages.c
===================================================================
--- linux-2.6.orig/drivers/infiniband/hw/qib/qib_user_pages.c	2011-08-10 14:08:57.000000000 -0500
+++ linux-2.6/drivers/infiniband/hw/qib/qib_user_pages.c	2011-08-10 14:09:06.000000000 -0500
@@ -74,7 +74,7 @@ static int __qib_get_user_pages(unsigned
 			goto bail_release;
 	}

-	current->mm->locked_vm += num_pages;
+	current->mm->pinned_vm += num_pages;

 	ret = 0;
 	goto bail;
@@ -151,7 +151,7 @@ void qib_release_user_pages(struct page
 	__qib_release_user_pages(p, num_pages, 1);

 	if (current->mm) {
-		current->mm->locked_vm -= num_pages;
+		current->mm->pinned_vm -= num_pages;
 		up_write(&current->mm->mmap_sem);
 	}
 }
Index: linux-2.6/kernel/events/core.c
===================================================================
--- linux-2.6.orig/kernel/events/core.c	2011-08-10 14:08:57.000000000 -0500
+++ linux-2.6/kernel/events/core.c	2011-08-10 15:04:16.000000000 -0500
@@ -3500,7 +3500,7 @@ static void perf_mmap_close(struct vm_ar
 		struct ring_buffer *rb = event->rb;

 		atomic_long_sub((size >> PAGE_SHIFT) + 1, &user->locked_vm);
-		vma->vm_mm->locked_vm -= event->mmap_locked;
+		vma->vm_mm->pinned_vm -= event->mmap_locked;
 		rcu_assign_pointer(event->rb, NULL);
 		mutex_unlock(&event->mmap_mutex);

@@ -3581,7 +3581,7 @@ static int perf_mmap(struct file *file,

 	lock_limit = rlimit(RLIMIT_MEMLOCK);
 	lock_limit >>= PAGE_SHIFT;
-	locked = vma->vm_mm->locked_vm + extra;
+	locked = vma->vm_mm->pinned_vm + extra;

 	if ((locked > lock_limit) && perf_paranoid_tracepoint_raw() &&
 		!capable(CAP_IPC_LOCK)) {
@@ -3607,7 +3607,7 @@ static int perf_mmap(struct file *file,
 	atomic_long_add(user_extra, &user->locked_vm);
 	event->mmap_locked = extra;
 	event->mmap_user = get_current_user();
-	vma->vm_mm->locked_vm += event->mmap_locked;
+	vma->vm_mm->pinned_vm += event->mmap_locked;

 unlock:
 	if (!ret)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
