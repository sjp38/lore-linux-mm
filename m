Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id 999986B0039
	for <linux-mm@kvack.org>; Fri, 24 May 2013 10:01:33 -0400 (EDT)
Date: Fri, 24 May 2013 16:01:14 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: [RFC][PATCH] mm: Fix RLIMIT_MEMLOCK
Message-ID: <20130524140114.GK23650@twins.programming.kicks-ass.net>
References: <alpine.DEB.2.10.1305221523420.9944@vincent-weaver-1.um.maine.edu>
 <alpine.DEB.2.10.1305221953370.11450@vincent-weaver-1.um.maine.edu>
 <alpine.DEB.2.10.1305222344060.12929@vincent-weaver-1.um.maine.edu>
 <20130523044803.GA25399@ZenIV.linux.org.uk>
 <20130523104154.GA23650@twins.programming.kicks-ass.net>
 <0000013ed1b8d0cc-ad2bb878-51bd-430c-8159-629b23ed1b44-000000@email.amazonses.com>
 <20130523152458.GD23650@twins.programming.kicks-ass.net>
 <0000013ed2297ba8-467d474a-7068-45b3-9fa3-82641e6aa363-000000@email.amazonses.com>
 <20130523163901.GG23650@twins.programming.kicks-ass.net>
 <0000013ed28b638a-066d7dc7-b590-49f8-9423-badb9537b8b6-000000@email.amazonses.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <0000013ed28b638a-066d7dc7-b590-49f8-9423-badb9537b8b6-000000@email.amazonses.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Al Viro <viro@ZenIV.linux.org.uk>, Vince Weaver <vincent.weaver@maine.edu>, linux-kernel@vger.kernel.org, Paul Mackerras <paulus@samba.org>, Ingo Molnar <mingo@redhat.com>, Arnaldo Carvalho de Melo <acme@ghostprotocols.net>, trinity@vger.kernel.org, akpm@linux-foundation.org, torvalds@linux-foundation.org, roland@kernel.org, infinipath@qlogic.com, linux-mm@kvack.org

Subject: [RFC][PATCH] mm: Fix RLIMIT_MEMLOCK

Patch bc3e53f682 ("mm: distinguish between mlocked and pinned pages")
broke RLIMIT_MEMLOCK.

The primary purpose of mm_struct::locked_vm was to act as resource
counter against RLIMIT_MEMLOCK. By splitting it the semantics got
greatly fuddled.

The 'bug' fixed was when you would mlock() IB pinned memory, in that
case the pages would be counted twice in mm_struct::locked_vm. The only
reason someone would actually do this is with mlockall(), which
basically requires you've disabled RLIMIT_MEMLOCK.

However by splitting the counter into two counters, RLIMIT_MEMLOCK has
no single resource counter; instead the patch makes it so that both
locked and pinned pages are below RLIMIT_MEMLOCK, effectively doubling
RLIMIT_MEMLOCK.

I claim that the patch made a bad situation worse by shifting the bug
from an unlikely corner case to a far more likely scenario.

This patch proposes to properly fix the problem by introducing
VM_PINNED. This also provides the groundwork for a possible mpin()
syscall or MADV_PIN -- although these are not included.

It recognises that pinned page semantics are a strict super-set of
locked page semantics -- a pinned page will not generate major faults
(and thus satisfies mlock() requirements).

The patch has some rough edges, primarily IB doesn't compile for I got a
little lost trying to find the process address for a number of
*_release_user_pages() calls which are now required.

Furthermore, vma expansion (stack) vs VM_PINNED is 'broken' in that I
don't think it will behave properly if you PIN the bottom (or top if
your arch is so inclined) stack page.

If people find this approach unworkable, I request we revert the above
mentioned patch to at least restore RLIMIT_MEMLOCK to a usable state
again.

Not-signed-off-by: Peter Zijlstra <peterz@infradead.org>
---
vers/infiniband/core/umem.c                 | 41 ++++++------
 drivers/infiniband/hw/ipath/ipath_file_ops.c   |  2 +-
 drivers/infiniband/hw/ipath/ipath_kernel.h     |  4 +-
 drivers/infiniband/hw/ipath/ipath_user_pages.c | 29 ++++++---
 drivers/infiniband/hw/qib/qib.h                |  2 +-
 drivers/infiniband/hw/qib/qib_file_ops.c       |  2 +-
 drivers/infiniband/hw/qib/qib_user_pages.c     | 18 ++++--
 include/linux/mm.h                             |  3 +
 include/linux/mm_types.h                       |  5 ++
 include/linux/perf_event.h                     |  1 -
 include/rdma/ib_umem.h                         |  3 +-
 kernel/events/core.c                           | 17 +++--
 kernel/fork.c                                  |  2 +
 mm/mlock.c                                     | 87 +++++++++++++++++++++-----
 mm/mmap.c                                      | 16 +++--
 15 files changed, 167 insertions(+), 65 deletions(-)

diff --git a/drivers/infiniband/core/umem.c b/drivers/infiniband/core/umem.c
index a841123..f8f47dc 100644
--- a/drivers/infiniband/core/umem.c
+++ b/drivers/infiniband/core/umem.c
@@ -137,17 +137,22 @@ struct ib_umem *ib_umem_get(struct ib_ucontext *context, unsigned long addr,
 
 	down_write(&current->mm->mmap_sem);
 
-	locked     = npages + current->mm->pinned_vm;
+	locked     = npages + mm_locked_pages(current->mm);
 	lock_limit = rlimit(RLIMIT_MEMLOCK) >> PAGE_SHIFT;
 
 	if ((locked > lock_limit) && !capable(CAP_IPC_LOCK)) {
 		ret = -ENOMEM;
-		goto out;
+		goto err;
 	}
 
 	cur_base = addr & PAGE_MASK;
+	umem->start_addr = cur_base;
+	umem->end_addr   = cur_base + npages;
+
+	ret = mm_mpin(umem->start_addr, umem->end_addr);
+	if (ret)
+		goto err;
 
-	ret = 0;
 	while (npages) {
 		ret = get_user_pages(current, current->mm, cur_base,
 				     min_t(unsigned long, npages,
@@ -155,7 +160,7 @@ struct ib_umem *ib_umem_get(struct ib_ucontext *context, unsigned long addr,
 				     1, !umem->writable, page_list, vma_list);
 
 		if (ret < 0)
-			goto out;
+			goto err_unpin;
 
 		cur_base += ret * PAGE_SIZE;
 		npages   -= ret;
@@ -168,7 +173,7 @@ struct ib_umem *ib_umem_get(struct ib_ucontext *context, unsigned long addr,
 					GFP_KERNEL);
 			if (!chunk) {
 				ret = -ENOMEM;
-				goto out;
+				goto err_unpin;
 			}
 
 			chunk->nents = min_t(int, ret, IB_UMEM_MAX_PAGE_CHUNK);
@@ -191,7 +196,7 @@ struct ib_umem *ib_umem_get(struct ib_ucontext *context, unsigned long addr,
 				kfree(chunk);
 
 				ret = -ENOMEM;
-				goto out;
+				goto err_unpin;
 			}
 
 			ret -= chunk->nents;
@@ -202,19 +207,23 @@ struct ib_umem *ib_umem_get(struct ib_ucontext *context, unsigned long addr,
 		ret = 0;
 	}
 
-out:
-	if (ret < 0) {
-		__ib_umem_release(context->device, umem, 0);
-		kfree(umem);
-	} else
-		current->mm->pinned_vm = locked;
+	if (ret < 0)
+		goto err_unpin;
 
+unlock:
 	up_write(&current->mm->mmap_sem);
 	if (vma_list)
 		free_page((unsigned long) vma_list);
 	free_page((unsigned long) page_list);
 
 	return ret < 0 ? ERR_PTR(ret) : umem;
+
+err_unpin:
+	mm_munpin(umem->start_addr, umem->end_addr);
+err:
+	__ib_umem_release(context->device, umem, 0);
+	kfree(umem);
+	goto unlock;
 }
 EXPORT_SYMBOL(ib_umem_get);
 
@@ -223,7 +232,7 @@ static void ib_umem_account(struct work_struct *work)
 	struct ib_umem *umem = container_of(work, struct ib_umem, work);
 
 	down_write(&umem->mm->mmap_sem);
-	umem->mm->pinned_vm -= umem->diff;
+	mm_munpin(umem->start_addr, umem->end_addr);
 	up_write(&umem->mm->mmap_sem);
 	mmput(umem->mm);
 	kfree(umem);
@@ -237,7 +246,6 @@ void ib_umem_release(struct ib_umem *umem)
 {
 	struct ib_ucontext *context = umem->context;
 	struct mm_struct *mm;
-	unsigned long diff;
 
 	__ib_umem_release(umem->context->device, umem, 1);
 
@@ -247,8 +255,6 @@ void ib_umem_release(struct ib_umem *umem)
 		return;
 	}
 
-	diff = PAGE_ALIGN(umem->length + umem->offset) >> PAGE_SHIFT;
-
 	/*
 	 * We may be called with the mm's mmap_sem already held.  This
 	 * can happen when a userspace munmap() is the call that drops
@@ -261,7 +267,6 @@ void ib_umem_release(struct ib_umem *umem)
 		if (!down_write_trylock(&mm->mmap_sem)) {
 			INIT_WORK(&umem->work, ib_umem_account);
 			umem->mm   = mm;
-			umem->diff = diff;
 
 			queue_work(ib_wq, &umem->work);
 			return;
@@ -269,7 +274,7 @@ void ib_umem_release(struct ib_umem *umem)
 	} else
 		down_write(&mm->mmap_sem);
 
-	current->mm->pinned_vm -= diff;
+	mm_munpin(umem->start_addr, umem->end_addr);
 	up_write(&mm->mmap_sem);
 	mmput(mm);
 	kfree(umem);
diff --git a/drivers/infiniband/hw/ipath/ipath_file_ops.c b/drivers/infiniband/hw/ipath/ipath_file_ops.c
index 6d7f453..16a0ad2 100644
--- a/drivers/infiniband/hw/ipath/ipath_file_ops.c
+++ b/drivers/infiniband/hw/ipath/ipath_file_ops.c
@@ -456,7 +456,7 @@ static int ipath_tid_update(struct ipath_portdata *pd, struct file *fp,
 				ipath_stats.sps_pageunlocks++;
 			}
 		}
-		ipath_release_user_pages(pagep, cnt);
+		ipath_release_user_pages(pagep, ti->tidvaddr, cnt);
 	} else {
 		/*
 		 * Copy the updated array, with ipath_tid's filled in, back
diff --git a/drivers/infiniband/hw/ipath/ipath_kernel.h b/drivers/infiniband/hw/ipath/ipath_kernel.h
index 6559af6..448bc97 100644
--- a/drivers/infiniband/hw/ipath/ipath_kernel.h
+++ b/drivers/infiniband/hw/ipath/ipath_kernel.h
@@ -1082,8 +1082,8 @@ static inline void ipath_sdma_desc_unreserve(struct ipath_devdata *dd, u16 cnt)
 #define IPATH_DFLT_RCVHDRSIZE 9
 
 int ipath_get_user_pages(unsigned long, size_t, struct page **);
-void ipath_release_user_pages(struct page **, size_t);
-void ipath_release_user_pages_on_close(struct page **, size_t);
+void ipath_release_user_pages(struct page **, unsigned long, size_t);
+void ipath_release_user_pages_on_close(struct page **, unsigned long, size_t);
 int ipath_eeprom_read(struct ipath_devdata *, u8, void *, int);
 int ipath_eeprom_write(struct ipath_devdata *, u8, const void *, int);
 int ipath_tempsense_read(struct ipath_devdata *, u8 regnum);
diff --git a/drivers/infiniband/hw/ipath/ipath_user_pages.c b/drivers/infiniband/hw/ipath/ipath_user_pages.c
index dc66c45..e368614 100644
--- a/drivers/infiniband/hw/ipath/ipath_user_pages.c
+++ b/drivers/infiniband/hw/ipath/ipath_user_pages.c
@@ -39,7 +39,7 @@
 #include "ipath_kernel.h"
 
 static void __ipath_release_user_pages(struct page **p, size_t num_pages,
-				   int dirty)
+				       int dirty)
 {
 	size_t i;
 
@@ -57,12 +57,15 @@ static int __ipath_get_user_pages(unsigned long start_page, size_t num_pages,
 				  struct page **p, struct vm_area_struct **vma)
 {
 	unsigned long lock_limit;
+	unsigned long locked;
 	size_t got;
 	int ret;
 
+	locked = mm_locked_pages(current->mm);
+	locked += num_pages;
 	lock_limit = rlimit(RLIMIT_MEMLOCK) >> PAGE_SHIFT;
 
-	if (num_pages > lock_limit) {
+	if (locked > lock_limit) {
 		ret = -ENOMEM;
 		goto bail;
 	}
@@ -70,6 +73,10 @@ static int __ipath_get_user_pages(unsigned long start_page, size_t num_pages,
 	ipath_cdbg(VERBOSE, "pin %lx pages from vaddr %lx\n",
 		   (unsigned long) num_pages, start_page);
 
+	ret = mm_mpin(start_page, start_page + num_pages);
+	if (ret)
+		goto bail;
+
 	for (got = 0; got < num_pages; got += ret) {
 		ret = get_user_pages(current, current->mm,
 				     start_page + got * PAGE_SIZE,
@@ -78,14 +85,12 @@ static int __ipath_get_user_pages(unsigned long start_page, size_t num_pages,
 		if (ret < 0)
 			goto bail_release;
 	}
-
-	current->mm->pinned_vm += num_pages;
-
 	ret = 0;
 	goto bail;
 
 bail_release:
 	__ipath_release_user_pages(p, got, 0);
+	mm_munpin(start_page, start_page + num_pages);
 bail:
 	return ret;
 }
@@ -172,13 +177,13 @@ int ipath_get_user_pages(unsigned long start_page, size_t num_pages,
 	return ret;
 }
 
-void ipath_release_user_pages(struct page **p, size_t num_pages)
+void ipath_release_user_pages(struct page **p, unsigned long start_page,
+			      size_t num_pages)
 {
 	down_write(&current->mm->mmap_sem);
 
 	__ipath_release_user_pages(p, num_pages, 1);
-
-	current->mm->pinned_vm -= num_pages;
+	mm_munpin(start_page, start_page + num_pages);
 
 	up_write(&current->mm->mmap_sem);
 }
@@ -186,6 +191,7 @@ void ipath_release_user_pages(struct page **p, size_t num_pages)
 struct ipath_user_pages_work {
 	struct work_struct work;
 	struct mm_struct *mm;
+	unsigned long start_page;
 	unsigned long num_pages;
 };
 
@@ -195,13 +201,15 @@ static void user_pages_account(struct work_struct *_work)
 		container_of(_work, struct ipath_user_pages_work, work);
 
 	down_write(&work->mm->mmap_sem);
-	work->mm->pinned_vm -= work->num_pages;
+	mm_munpin(work->start_page, work->start_page + work->num_pages);
 	up_write(&work->mm->mmap_sem);
 	mmput(work->mm);
 	kfree(work);
 }
 
-void ipath_release_user_pages_on_close(struct page **p, size_t num_pages)
+void ipath_release_user_pages_on_close(struct page **p, 
+				       unsigned long start_page,
+				       size_t num_pages)
 {
 	struct ipath_user_pages_work *work;
 	struct mm_struct *mm;
@@ -218,6 +226,7 @@ void ipath_release_user_pages_on_close(struct page **p, size_t num_pages)
 
 	INIT_WORK(&work->work, user_pages_account);
 	work->mm = mm;
+	work->start_page = start_page;
 	work->num_pages = num_pages;
 
 	queue_work(ib_wq, &work->work);
diff --git a/drivers/infiniband/hw/qib/qib.h b/drivers/infiniband/hw/qib/qib.h
index 4d11575..a6213e2 100644
--- a/drivers/infiniband/hw/qib/qib.h
+++ b/drivers/infiniband/hw/qib/qib.h
@@ -1343,7 +1343,7 @@ void qib_sdma_process_event(struct qib_pportdata *, enum qib_sdma_events);
 #define QIB_RCVHDR_ENTSIZE 32
 
 int qib_get_user_pages(unsigned long, size_t, struct page **);
-void qib_release_user_pages(struct page **, size_t);
+void qib_release_user_pages(struct page **, unsigned long, size_t);
 int qib_eeprom_read(struct qib_devdata *, u8, void *, int);
 int qib_eeprom_write(struct qib_devdata *, u8, const void *, int);
 u32 __iomem *qib_getsendbuf_range(struct qib_devdata *, u32 *, u32, u32);
diff --git a/drivers/infiniband/hw/qib/qib_file_ops.c b/drivers/infiniband/hw/qib/qib_file_ops.c
index b56c942..ceff69f 100644
--- a/drivers/infiniband/hw/qib/qib_file_ops.c
+++ b/drivers/infiniband/hw/qib/qib_file_ops.c
@@ -423,7 +423,7 @@ static int qib_tid_update(struct qib_ctxtdata *rcd, struct file *fp,
 				dd->pageshadow[ctxttid + tid] = NULL;
 			}
 		}
-		qib_release_user_pages(pagep, cnt);
+		qib_release_user_pages(pagep, ti->tidvaddr, cnt);
 	} else {
 		/*
 		 * Copy the updated array, with qib_tid's filled in, back
diff --git a/drivers/infiniband/hw/qib/qib_user_pages.c b/drivers/infiniband/hw/qib/qib_user_pages.c
index 2bc1d2b..e7b0e0d 100644
--- a/drivers/infiniband/hw/qib/qib_user_pages.c
+++ b/drivers/infiniband/hw/qib/qib_user_pages.c
@@ -55,16 +55,24 @@ static int __qib_get_user_pages(unsigned long start_page, size_t num_pages,
 				struct page **p, struct vm_area_struct **vma)
 {
 	unsigned long lock_limit;
+	unsigned long locked;
 	size_t got;
 	int ret;
 
+	locked = mm_locked_pages(current->mm);
+	locked += num_pages;
+
 	lock_limit = rlimit(RLIMIT_MEMLOCK) >> PAGE_SHIFT;
 
-	if (num_pages > lock_limit && !capable(CAP_IPC_LOCK)) {
+	if (locked > lock_limit && !capable(CAP_IPC_LOCK)) {
 		ret = -ENOMEM;
 		goto bail;
 	}
 
+	ret = mm_mpin(start_page, start_page + num_pages);
+	if (ret)
+		goto bail;
+
 	for (got = 0; got < num_pages; got += ret) {
 		ret = get_user_pages(current, current->mm,
 				     start_page + got * PAGE_SIZE,
@@ -74,13 +82,12 @@ static int __qib_get_user_pages(unsigned long start_page, size_t num_pages,
 			goto bail_release;
 	}
 
-	current->mm->pinned_vm += num_pages;
-
 	ret = 0;
 	goto bail;
 
 bail_release:
 	__qib_release_user_pages(p, got, 0);
+	mm_munpin(start_page, star_page + num_pages);
 bail:
 	return ret;
 }
@@ -143,15 +150,16 @@ int qib_get_user_pages(unsigned long start_page, size_t num_pages,
 	return ret;
 }
 
-void qib_release_user_pages(struct page **p, size_t num_pages)
+void qib_release_user_pages(struct page **p, unsigned long start_page, size_t num_pages)
 {
 	if (current->mm) /* during close after signal, mm can be NULL */
 		down_write(&current->mm->mmap_sem);
 
 	__qib_release_user_pages(p, num_pages, 1);
 
+
 	if (current->mm) {
-		current->mm->pinned_vm -= num_pages;
+		mm_munpin(start_page, start_page + num_pages);
 		up_write(&current->mm->mmap_sem);
 	}
 }
diff --git a/include/linux/mm.h b/include/linux/mm.h
index e0c8528..de10e5b 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -90,6 +90,7 @@ extern unsigned int kobjsize(const void *objp);
 #define VM_PFNMAP	0x00000400	/* Page-ranges managed without "struct page", just pure PFN */
 #define VM_DENYWRITE	0x00000800	/* ETXTBSY on write attempts.. */
 
+#define VM_PINNED	0x00001000
 #define VM_LOCKED	0x00002000
 #define VM_IO           0x00004000	/* Memory mapped I/O or similar */
 
@@ -1526,6 +1527,8 @@ static inline void mm_populate(unsigned long addr, unsigned long len)
 	/* Ignore errors */
 	(void) __mm_populate(addr, len, 1);
 }
+extern int mm_mpin(unsigned long start, unsigned long end);
+extern int mm_unpin(unsigned long start, unsigned long end);
 #else
 static inline void mm_populate(unsigned long addr, unsigned long len) {}
 #endif
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index ace9a5f..3e3475b 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -456,4 +456,9 @@ static inline cpumask_t *mm_cpumask(struct mm_struct *mm)
 	return mm->cpu_vm_mask_var;
 }
 
+static inline unsigned long mm_locked_pages(struct mm_struct *mm)
+{
+	return mm->pinned_vm + mm->locked_vm;
+}
+
 #endif /* _LINUX_MM_TYPES_H */
diff --git a/include/linux/perf_event.h b/include/linux/perf_event.h
index f463a46..1003c71 100644
--- a/include/linux/perf_event.h
+++ b/include/linux/perf_event.h
@@ -389,7 +389,6 @@ struct perf_event {
 	/* mmap bits */
 	struct mutex			mmap_mutex;
 	atomic_t			mmap_count;
-	int				mmap_locked;
 	struct user_struct		*mmap_user;
 	struct ring_buffer		*rb;
 	struct list_head		rb_entry;
diff --git a/include/rdma/ib_umem.h b/include/rdma/ib_umem.h
index 9ee0d2e..4f3c802 100644
--- a/include/rdma/ib_umem.h
+++ b/include/rdma/ib_umem.h
@@ -41,6 +41,8 @@ struct ib_ucontext;
 
 struct ib_umem {
 	struct ib_ucontext     *context;
+	unsigned long		start_addr;
+	unsigned long		nr_pages;
 	size_t			length;
 	int			offset;
 	int			page_size;
@@ -49,7 +51,6 @@ struct ib_umem {
 	struct list_head	chunk_list;
 	struct work_struct	work;
 	struct mm_struct       *mm;
-	unsigned long		diff;
 };
 
 struct ib_umem_chunk {
diff --git a/kernel/events/core.c b/kernel/events/core.c
index 9dc297f..ceb8905 100644
--- a/kernel/events/core.c
+++ b/kernel/events/core.c
@@ -3617,7 +3617,6 @@ static void perf_mmap_close(struct vm_area_struct *vma)
 		struct ring_buffer *rb = event->rb;
 
 		atomic_long_sub((size >> PAGE_SHIFT) + 1, &user->locked_vm);
-		vma->vm_mm->pinned_vm -= event->mmap_locked;
 		rcu_assign_pointer(event->rb, NULL);
 		ring_buffer_detach(event, rb);
 		mutex_unlock(&event->mmap_mutex);
@@ -3699,7 +3698,7 @@ static int perf_mmap(struct file *file, struct vm_area_struct *vma)
 
 	lock_limit = rlimit(RLIMIT_MEMLOCK);
 	lock_limit >>= PAGE_SHIFT;
-	locked = vma->vm_mm->pinned_vm + extra;
+	locked = mm_locked_pages(vma->vm_mm) + extra;
 
 	if ((locked > lock_limit) && perf_paranoid_tracepoint_raw() &&
 		!capable(CAP_IPC_LOCK)) {
@@ -3723,9 +3722,8 @@ static int perf_mmap(struct file *file, struct vm_area_struct *vma)
 	rcu_assign_pointer(event->rb, rb);
 
 	atomic_long_add(user_extra, &user->locked_vm);
-	event->mmap_locked = extra;
 	event->mmap_user = get_current_user();
-	vma->vm_mm->pinned_vm += event->mmap_locked;
+	vma->vm_mm->pinned_vm += extra;
 
 	perf_event_update_userpage(event);
 
@@ -3734,7 +3732,16 @@ static int perf_mmap(struct file *file, struct vm_area_struct *vma)
 		atomic_inc(&event->mmap_count);
 	mutex_unlock(&event->mmap_mutex);
 
-	vma->vm_flags |= VM_DONTEXPAND | VM_DONTDUMP;
+	/*
+	 * We're a vma of pinned pages; add special to avoid MADV_DODUMP and
+	 * mlock(). mlock()+munlock() could accidentally put these pages onto
+	 * the LRU, we wouldn't want that; also it implies VM_DONTEXPAND
+	 * which we need as well.
+	 *
+	 * VM_PINNED will make munmap automagically subtract
+	 * mm_struct::pinned_vm.
+	 */
+	vma->vm_flags |= VM_PINNED | VM_SPECIAL | VM_DONTDUMP;
 	vma->vm_ops = &perf_mmap_vmops;
 
 	return ret;
diff --git a/kernel/fork.c b/kernel/fork.c
index 987b28a..815f196 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -411,6 +411,8 @@ static int dup_mmap(struct mm_struct *mm, struct mm_struct *oldmm)
 		if (anon_vma_fork(tmp, mpnt))
 			goto fail_nomem_anon_vma_fork;
 		tmp->vm_flags &= ~VM_LOCKED;
+		if (tmp->vm_flags & VM_PINNED)
+			mm->pinned_vm += vma_pages(tmp);
 		tmp->vm_next = tmp->vm_prev = NULL;
 		file = tmp->vm_file;
 		if (file) {
diff --git a/mm/mlock.c b/mm/mlock.c
index 79b7cf7..335c705 100644
--- a/mm/mlock.c
+++ b/mm/mlock.c
@@ -277,9 +277,8 @@ static int mlock_fixup(struct vm_area_struct *vma, struct vm_area_struct **prev,
 {
 	struct mm_struct *mm = vma->vm_mm;
 	pgoff_t pgoff;
-	int nr_pages;
+	int nr_pages, nr_locked, nr_pinned;
 	int ret = 0;
-	int lock = !!(newflags & VM_LOCKED);
 
 	if (newflags == vma->vm_flags || (vma->vm_flags & VM_SPECIAL) ||
 	    is_vm_hugetlb_page(vma) || vma == get_gate_vma(current->mm))
@@ -310,9 +309,49 @@ static int mlock_fixup(struct vm_area_struct *vma, struct vm_area_struct **prev,
 	 * Keep track of amount of locked VM.
 	 */
 	nr_pages = (end - start) >> PAGE_SHIFT;
-	if (!lock)
-		nr_pages = -nr_pages;
-	mm->locked_vm += nr_pages;
+
+	/*
+	 * We should only account pages once, if VM_PINNED is set pages are
+	 * accounted in mm_struct::pinned_vm, otherwise if VM_LOCKED is set,
+	 * we'll account them in mm_struct::locked_vm.
+	 *
+	 * PL  := vma->vm_flags
+	 * PL' := newflags
+	 * PLd := {pinned,locked}_vm delta
+	 *
+	 * PL->PL' PLd
+	 * -----------
+	 * 00  01  0+
+	 * 00  10  +0
+	 * 01  11  +-
+	 * 01  00  0-
+	 * 10  00  -0
+	 * 10  11  00
+	 * 11  01  -+
+	 * 11  10  00
+	 */
+
+	nr_pinned = nr_locked = 0;
+
+	if ((vma->vm_flags ^ newflags) & VM_PINNED) {
+		if (vma->vm_flags & VM_PINNED)
+			nr_pinned = -nr_pages;
+		else
+			nr_pinned = nr_pages;
+	}
+
+	if (vma->vm_flags & VM_PINNED) {
+		if ((newflags & (VM_PINNED|VM_LOCKED)) == VM_LOCKED)
+			nr_locked = nr_pages;
+	} else {
+		if (vma->vm_flags & VM_LOCKED)
+			nr_locked = -nr_pages;
+		else if (newflags & VM_LOCKED)
+			nr_locked = nr_pages;
+	}
+
+	mm->pinned_vm += nr_pinned;
+	mm->locked_vm += nr_locked;
 
 	/*
 	 * vm_flags is protected by the mmap_sem held in write mode.
@@ -320,7 +359,7 @@ static int mlock_fixup(struct vm_area_struct *vma, struct vm_area_struct **prev,
 	 * set VM_LOCKED, __mlock_vma_pages_range will bring it back.
 	 */
 
-	if (lock)
+	if (((vma->vm_flags ^ newflags) & VM_PINNED) || (newflags & VM_LOCKED))
 		vma->vm_flags = newflags;
 	else
 		munlock_vma_pages_range(vma, start, end);
@@ -330,7 +369,10 @@ static int mlock_fixup(struct vm_area_struct *vma, struct vm_area_struct **prev,
 	return ret;
 }
 
-static int do_mlock(unsigned long start, size_t len, int on)
+#define MLOCK_F_ON	0x01
+#define MLOCK_F_PIN	0x02
+
+static int do_mlock(unsigned long start, size_t len, unsigned int flags)
 {
 	unsigned long nstart, end, tmp;
 	struct vm_area_struct * vma, * prev;
@@ -352,13 +394,18 @@ static int do_mlock(unsigned long start, size_t len, int on)
 		prev = vma;
 
 	for (nstart = start ; ; ) {
-		vm_flags_t newflags;
+		vm_flags_t newflags = vma->vm_flags;
+		vm_flags_t flag = VM_LOCKED;
 
-		/* Here we know that  vma->vm_start <= nstart < vma->vm_end. */
+		if (flags & MLOCK_F_PIN)
+			flag = VM_PINNED;
 
-		newflags = vma->vm_flags & ~VM_LOCKED;
-		if (on)
-			newflags |= VM_LOCKED;
+		if (flags & MLOCK_F_ON)
+			newflags |= flag;
+		else
+			newflags &= ~flag;
+
+		/* Here we know that  vma->vm_start <= nstart < vma->vm_end. */
 
 		tmp = vma->vm_end;
 		if (tmp > end)
@@ -381,6 +428,18 @@ static int do_mlock(unsigned long start, size_t len, int on)
 	return error;
 }
 
+int mm_mpin(unsigned long start, unsigned long end)
+{
+	return do_mlock(start, end, MLOCK_F_ON | MLOCK_F_PIN);
+}
+EXPORT_SYMBOL_GPL(mm_mpin);
+
+int mm_munpin(unsigned long start, unsigned long end)
+{
+	return do_mlock(start, end, MLOCK_F_PIN);
+}
+EXPORT_SYMBOL_GPL(mm_munpin);
+
 /*
  * __mm_populate - populate and/or mlock pages within a range of address space.
  *
@@ -460,14 +519,14 @@ SYSCALL_DEFINE2(mlock, unsigned long, start, size_t, len)
 	start &= PAGE_MASK;
 
 	locked = len >> PAGE_SHIFT;
-	locked += current->mm->locked_vm;
+	locked += mm_locked_pages(current->mm);
 
 	lock_limit = rlimit(RLIMIT_MEMLOCK);
 	lock_limit >>= PAGE_SHIFT;
 
 	/* check against resource limits */
 	if ((locked <= lock_limit) || capable(CAP_IPC_LOCK))
-		error = do_mlock(start, len, 1);
+		error = do_mlock(start, len, MLOCK_F_ON);
 	up_write(&current->mm->mmap_sem);
 	if (!error)
 		error = __mm_populate(start, len, 0);
diff --git a/mm/mmap.c b/mm/mmap.c
index f681e18..5cd10c4 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -1258,7 +1258,7 @@ unsigned long do_mmap_pgoff(struct file *file, unsigned long addr,
 	if (vm_flags & VM_LOCKED) {
 		unsigned long locked, lock_limit;
 		locked = len >> PAGE_SHIFT;
-		locked += mm->locked_vm;
+		locked += mm_locked_pages(mm);
 		lock_limit = rlimit(RLIMIT_MEMLOCK);
 		lock_limit >>= PAGE_SHIFT;
 		if (locked > lock_limit && !capable(CAP_IPC_LOCK))
@@ -2070,7 +2070,7 @@ static int acct_stack_growth(struct vm_area_struct *vma, unsigned long size, uns
 	if (vma->vm_flags & VM_LOCKED) {
 		unsigned long locked;
 		unsigned long limit;
-		locked = mm->locked_vm + grow;
+		locked = mm_locked_pages(mm) + grow;
 		limit = ACCESS_ONCE(rlim[RLIMIT_MEMLOCK].rlim_cur);
 		limit >>= PAGE_SHIFT;
 		if (locked > limit && !capable(CAP_IPC_LOCK))
@@ -2547,13 +2547,17 @@ int do_munmap(struct mm_struct *mm, unsigned long start, size_t len)
 	/*
 	 * unlock any mlock()ed ranges before detaching vmas
 	 */
-	if (mm->locked_vm) {
+	if (mm->locked_vm || mm->pinned_vm) {
 		struct vm_area_struct *tmp = vma;
 		while (tmp && tmp->vm_start < end) {
-			if (tmp->vm_flags & VM_LOCKED) {
+			if (tmp->vm_flags & VM_PINNED)
+				mm->pinned_vm -= vma_pages(tmp);
+			else if (tmp->vm_flags & VM_LOCKED)
 				mm->locked_vm -= vma_pages(tmp);
+
+			if (tmp->vm_flags & VM_LOCKED)
 				munlock_vma_pages_all(tmp);
-			}
+
 			tmp = tmp->vm_next;
 		}
 	}
@@ -2628,7 +2632,7 @@ static unsigned long do_brk(unsigned long addr, unsigned long len)
 	if (mm->def_flags & VM_LOCKED) {
 		unsigned long locked, lock_limit;
 		locked = len >> PAGE_SHIFT;
-		locked += mm->locked_vm;
+		locked += mm_locked_pages(mm);
 		lock_limit = rlimit(RLIMIT_MEMLOCK);
 		lock_limit >>= PAGE_SHIFT;
 		if (locked > lock_limit && !capable(CAP_IPC_LOCK))

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
