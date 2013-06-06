Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id 19D156B0033
	for <linux-mm@kvack.org>; Thu,  6 Jun 2013 08:44:02 -0400 (EDT)
Date: Thu, 6 Jun 2013 14:43:51 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: [PATCH] mm: Revert pinned_vm braindamage
Message-ID: <20130606124351.GZ27176@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: torvalds@linux-foundation.org, roland@kernel.org, mingo@kernel.org, tglx@linutronix.de, kosaki.motohiro@gmail.com, penberg@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-rdma@vger.kernel.org


Patch bc3e53f682 ("mm: distinguish between mlocked and pinned pages")
broke RLIMIT_MEMLOCK.

Before that patch: mm_struct::locked_vm < RLIMIT_MEMLOCK; after that
patch we have: mm_struct::locked_vm < RLIMIT_MEMLOCK &&
mm_struct::pinned_vm < RLIMIT_MEMLOCK.

The patch doesn't mention RLIMIT_MEMLOCK and thus also doesn't discus
this (user visible) change in semantics. And thus we must assume it was
unintentional.

Since RLIMIT_MEMLOCK is very clearly a limit on the amount of pages the
process can 'lock' into memory it should very much include pinned pages
as well as mlock()ed pages. Neither can be paged.

Since nobody had anything constructive to say about the VM_PINNED
approach and the IB code hurts my head too much to make it work I
propose we revert said patch.


Once again the rationale; MLOCK(2) is part of POSIX Realtime Extentsion
(1003.1b-1993/1003.1i-1995). It states that the specified part of the
user address space should stay memory resident until either program exit
or a matching munlock() call.

This definition basically excludes major faults from happening on the
pages -- a major fault being one where IO needs to happen to obtain the
page content; the direct implication being that page content must remain
in memory.

Linux has taken this literal and made mlock()ed pages subject to page
migration (albeit only for the explicit move_pages() syscall; but it
would very much like to make them subject to implicit page migration for
the purpose of compaction etc.).

This view disregards the intention of the spec; since mlock() is part of
the realtime spec the intention is very much that the user address range
generate no faults; neither minor nor major -- any delay is
unacceptable.

This leaves the RT people unhappy -- therefore _if_ we continue with
this Linux specific interpretation of mlock() we must introduce new
syscalls that implement the intended mlock() semantics.

It was found that there are useful purposes for this weaker mlock(), a
rationale to indeed have two sets of syscalls. The weaker mlock() can be
used in the context of security -- where we avoid sensitive data being
written to disk, and in the context of userspace deamons that are part
of the IO path -- which would otherwise form IO deadlocks.

The proposed second set of primitives would be mpin() and munpin() and
would implement the intended mlock() semantics.

Such pages would not be migratable in any way (a possible
implementation would be to 'pin' the pages using an extra refcount on
the page frame). From the above we can see that any mpin()ed page is
also an mlock()ed page, since mpin() will disallow any fault, and thus
will also disallow major faults.

While we still lack the formal mpin() and munpin() syscalls there are a
number of sites that have similar 'side effects' and result in user
controlled 'pinning' of pages. Namely IB and perf.

For the purpose of RLIMIT_MEMLOCK we must use intent only as it is not
part of the formal spec. The only useful thing is to limit the amount of
pages a user can exempt from paging. This would therefore include all
pages either mlock()ed or mpin()ed.


Back to the patch; a resource limit must have a resource counter to
enact the limit upon. Before the patch this was mm_struct::locked_vm.
After the patch there is no such thing left.

The patch was proposed to 'fix' a double accounting problem where pages
are both pinned and mlock()ed. This was particularly visible when using
mlockall() on a process that uses either IB or perf.

I state that since mlockall() disables/invalidates RLIMIT_MEMLOCK the
actual resource counter value is irrelevant, and thus the reported
problem is a non-problem.

However, it would still be possible to observe weirdness in the very
unlikely event that a user would indeed call mlock() upon an address
range obtained from IB/perf. In this case he would be unduly constrained
and find his effective RLIMIT_MEMLOCK limit halved (at worst).

After the patch; that same user will find he has an effectively double
RLIMIT_MEMLOCK, since the IB/perf pages are not counted towards the same
limit as his mlock() pages are. It is far more likely a user will employ
mlock() on different rages than those he received from IB/perf since he
already knows those aren't going anywhere.

Therefore the patch trades an unlikely weirdness for a much more likely
weirdness. So barring a proper solution I propose we revert.

I've yet to hear a coherent objection to the above. Christoph is always
quick to yell: 'but if fixes a double accounting issue' but is
completely deaf to the fact that he changed user visible semantics
without mention and regard.

Signed-off-by: Peter Zijlstra <peterz@infradead.org>
---
 drivers/infiniband/core/umem.c                 | 8 ++++----
 drivers/infiniband/hw/ipath/ipath_user_pages.c | 6 +++---
 drivers/infiniband/hw/qib/qib_user_pages.c     | 4 ++--
 fs/proc/task_mmu.c                             | 2 --
 include/linux/mm_types.h                       | 1 -
 kernel/events/core.c                           | 6 +++---
 6 files changed, 12 insertions(+), 15 deletions(-)

diff --git a/drivers/infiniband/core/umem.c b/drivers/infiniband/core/umem.c
index a841123..cc92137b 100644
--- a/drivers/infiniband/core/umem.c
+++ b/drivers/infiniband/core/umem.c
@@ -137,7 +137,7 @@ struct ib_umem *ib_umem_get(struct ib_ucontext *context, unsigned long addr,
 
 	down_write(&current->mm->mmap_sem);
 
-	locked     = npages + current->mm->pinned_vm;
+	locked     = npages + current->mm->locked_vm;
 	lock_limit = rlimit(RLIMIT_MEMLOCK) >> PAGE_SHIFT;
 
 	if ((locked > lock_limit) && !capable(CAP_IPC_LOCK)) {
@@ -207,7 +207,7 @@ struct ib_umem *ib_umem_get(struct ib_ucontext *context, unsigned long addr,
 		__ib_umem_release(context->device, umem, 0);
 		kfree(umem);
 	} else
-		current->mm->pinned_vm = locked;
+		current->mm->locked_vm = locked;
 
 	up_write(&current->mm->mmap_sem);
 	if (vma_list)
@@ -223,7 +223,7 @@ static void ib_umem_account(struct work_struct *work)
 	struct ib_umem *umem = container_of(work, struct ib_umem, work);
 
 	down_write(&umem->mm->mmap_sem);
-	umem->mm->pinned_vm -= umem->diff;
+	umem->mm->locked_vm -= umem->diff;
 	up_write(&umem->mm->mmap_sem);
 	mmput(umem->mm);
 	kfree(umem);
@@ -269,7 +269,7 @@ void ib_umem_release(struct ib_umem *umem)
 	} else
 		down_write(&mm->mmap_sem);
 
-	current->mm->pinned_vm -= diff;
+	current->mm->locked_vm -= diff;
 	up_write(&mm->mmap_sem);
 	mmput(mm);
 	kfree(umem);
diff --git a/drivers/infiniband/hw/ipath/ipath_user_pages.c b/drivers/infiniband/hw/ipath/ipath_user_pages.c
index dc66c45..cfed539 100644
--- a/drivers/infiniband/hw/ipath/ipath_user_pages.c
+++ b/drivers/infiniband/hw/ipath/ipath_user_pages.c
@@ -79,7 +79,7 @@ static int __ipath_get_user_pages(unsigned long start_page, size_t num_pages,
 			goto bail_release;
 	}
 
-	current->mm->pinned_vm += num_pages;
+	current->mm->locked_vm += num_pages;
 
 	ret = 0;
 	goto bail;
@@ -178,7 +178,7 @@ void ipath_release_user_pages(struct page **p, size_t num_pages)
 
 	__ipath_release_user_pages(p, num_pages, 1);
 
-	current->mm->pinned_vm -= num_pages;
+	current->mm->locked_vm -= num_pages;
 
 	up_write(&current->mm->mmap_sem);
 }
@@ -195,7 +195,7 @@ static void user_pages_account(struct work_struct *_work)
 		container_of(_work, struct ipath_user_pages_work, work);
 
 	down_write(&work->mm->mmap_sem);
-	work->mm->pinned_vm -= work->num_pages;
+	work->mm->locked_vm -= work->num_pages;
 	up_write(&work->mm->mmap_sem);
 	mmput(work->mm);
 	kfree(work);
diff --git a/drivers/infiniband/hw/qib/qib_user_pages.c b/drivers/infiniband/hw/qib/qib_user_pages.c
index 2bc1d2b..7689e49 100644
--- a/drivers/infiniband/hw/qib/qib_user_pages.c
+++ b/drivers/infiniband/hw/qib/qib_user_pages.c
@@ -74,7 +74,7 @@ static int __qib_get_user_pages(unsigned long start_page, size_t num_pages,
 			goto bail_release;
 	}
 
-	current->mm->pinned_vm += num_pages;
+	current->mm->locked_vm += num_pages;
 
 	ret = 0;
 	goto bail;
@@ -151,7 +151,7 @@ void qib_release_user_pages(struct page **p, size_t num_pages)
 	__qib_release_user_pages(p, num_pages, 1);
 
 	if (current->mm) {
-		current->mm->pinned_vm -= num_pages;
+		current->mm->locked_vm -= num_pages;
 		up_write(&current->mm->mmap_sem);
 	}
 }
diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index 3e636d8..7d09d6a 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -44,7 +44,6 @@ void task_mem(struct seq_file *m, struct mm_struct *mm)
 		"VmPeak:\t%8lu kB\n"
 		"VmSize:\t%8lu kB\n"
 		"VmLck:\t%8lu kB\n"
-		"VmPin:\t%8lu kB\n"
 		"VmHWM:\t%8lu kB\n"
 		"VmRSS:\t%8lu kB\n"
 		"VmData:\t%8lu kB\n"
@@ -56,7 +55,6 @@ void task_mem(struct seq_file *m, struct mm_struct *mm)
 		hiwater_vm << (PAGE_SHIFT-10),
 		total_vm << (PAGE_SHIFT-10),
 		mm->locked_vm << (PAGE_SHIFT-10),
-		mm->pinned_vm << (PAGE_SHIFT-10),
 		hiwater_rss << (PAGE_SHIFT-10),
 		total_rss << (PAGE_SHIFT-10),
 		data << (PAGE_SHIFT-10),
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index ace9a5f..d185c13 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -356,7 +356,6 @@ struct mm_struct {
 
 	unsigned long total_vm;		/* Total pages mapped */
 	unsigned long locked_vm;	/* Pages that have PG_mlocked set */
-	unsigned long pinned_vm;	/* Refcount permanently increased */
 	unsigned long shared_vm;	/* Shared pages (files) */
 	unsigned long exec_vm;		/* VM_EXEC & ~VM_WRITE */
 	unsigned long stack_vm;		/* VM_GROWSUP/DOWN */
diff --git a/kernel/events/core.c b/kernel/events/core.c
index 95edd5a..1e926b2 100644
--- a/kernel/events/core.c
+++ b/kernel/events/core.c
@@ -3729,7 +3729,7 @@ static void perf_mmap_close(struct vm_area_struct *vma)
 
 		if (ring_buffer_put(rb)) {
 			atomic_long_sub((size >> PAGE_SHIFT) + 1, &mmap_user->locked_vm);
-			vma->vm_mm->pinned_vm -= mmap_locked;
+			vma->vm_mm->locked_vm -= mmap_locked;
 			free_uid(mmap_user);
 		}
 	}
@@ -3805,7 +3805,7 @@ static int perf_mmap(struct file *file, struct vm_area_struct *vma)
 
 	lock_limit = rlimit(RLIMIT_MEMLOCK);
 	lock_limit >>= PAGE_SHIFT;
-	locked = vma->vm_mm->pinned_vm + extra;
+	locked = vma->vm_mm->locked_vm + extra;
 
 	if ((locked > lock_limit) && perf_paranoid_tracepoint_raw() &&
 		!capable(CAP_IPC_LOCK)) {
@@ -3831,7 +3831,7 @@ static int perf_mmap(struct file *file, struct vm_area_struct *vma)
 	rb->mmap_user = get_current_user();
 
 	atomic_long_add(user_extra, &user->locked_vm);
-	vma->vm_mm->pinned_vm += extra;
+	vma->vm_mm->locked_vm += extra;
 
 	rcu_assign_pointer(event->rb, rb);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
