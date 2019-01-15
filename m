Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id F073E8E0004
	for <linux-mm@kvack.org>; Tue, 15 Jan 2019 13:13:27 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id a10so2097674plp.14
        for <linux-mm@kvack.org>; Tue, 15 Jan 2019 10:13:27 -0800 (PST)
Received: from smtp2.provo.novell.com (smtp2.provo.novell.com. [137.65.250.81])
        by mx.google.com with ESMTPS id s8si623264pgm.508.2019.01.15.10.13.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Jan 2019 10:13:26 -0800 (PST)
From: Davidlohr Bueso <dave@stgolabs.net>
Subject: [PATCH 1/6] mm: make mm->pinned_vm an atomic counter
Date: Tue, 15 Jan 2019 10:12:55 -0800
Message-Id: <20190115181300.27547-2-dave@stgolabs.net>
In-Reply-To: <20190115181300.27547-1-dave@stgolabs.net>
References: <20190115181300.27547-1-dave@stgolabs.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: dledford@redhat.com, jgg@mellanox.com, linux-rdma@vger.kernel.org, linux-mm@kvack.org, dave@stgolabs.net, Davidlohr Bueso <dbueso@suse.de>

Taking a sleeping lock to _only_ increment a variable is quite the
overkill, and pretty much all users do this. Furthermore, some drivers
(ie: infiniband and scif) that need pinned semantics can go to quite
some trouble to actually delay via workqueue (un)accounting for pinned
pages when not possible to acquire it.

By making the counter atomic we no longer need to hold the mmap_sem
and can simply some code around it for pinned_vm users.

Signed-off-by: Davidlohr Bueso <dbueso@suse.de>
---
 drivers/infiniband/core/umem.c             | 12 ++++++------
 drivers/infiniband/hw/hfi1/user_pages.c    |  6 +++---
 drivers/infiniband/hw/qib/qib_user_pages.c |  4 ++--
 drivers/infiniband/hw/usnic/usnic_uiom.c   |  8 ++++----
 drivers/misc/mic/scif/scif_rma.c           |  6 +++---
 fs/proc/task_mmu.c                         |  2 +-
 include/linux/mm_types.h                   |  2 +-
 kernel/events/core.c                       |  8 ++++----
 kernel/fork.c                              |  2 +-
 mm/debug.c                                 |  3 ++-
 10 files changed, 27 insertions(+), 26 deletions(-)

diff --git a/drivers/infiniband/core/umem.c b/drivers/infiniband/core/umem.c
index c6144df47ea4..bf556215aa7e 100644
--- a/drivers/infiniband/core/umem.c
+++ b/drivers/infiniband/core/umem.c
@@ -161,13 +161,13 @@ struct ib_umem *ib_umem_get(struct ib_ucontext *context, unsigned long addr,
 	lock_limit = rlimit(RLIMIT_MEMLOCK) >> PAGE_SHIFT;
 
 	down_write(&mm->mmap_sem);
-	if (check_add_overflow(mm->pinned_vm, npages, &new_pinned) ||
-	    (new_pinned > lock_limit && !capable(CAP_IPC_LOCK))) {
+	new_pinned = atomic_long_read(&mm->pinned_vm) + npages;
+	if (new_pinned > lock_limit && !capable(CAP_IPC_LOCK)) {
 		up_write(&mm->mmap_sem);
 		ret = -ENOMEM;
 		goto out;
 	}
-	mm->pinned_vm = new_pinned;
+	atomic_long_set(&mm->pinned_vm, new_pinned);
 	up_write(&mm->mmap_sem);
 
 	cur_base = addr & PAGE_MASK;
@@ -229,7 +229,7 @@ struct ib_umem *ib_umem_get(struct ib_ucontext *context, unsigned long addr,
 	__ib_umem_release(context->device, umem, 0);
 vma:
 	down_write(&mm->mmap_sem);
-	mm->pinned_vm -= ib_umem_num_pages(umem);
+	atomic_long_sub(ib_umem_num_pages(umem), &mm->pinned_vm);
 	up_write(&mm->mmap_sem);
 out:
 	if (vma_list)
@@ -258,7 +258,7 @@ static void ib_umem_release_defer(struct work_struct *work)
 	struct ib_umem *umem = container_of(work, struct ib_umem, work);
 
 	down_write(&umem->owning_mm->mmap_sem);
-	umem->owning_mm->pinned_vm -= ib_umem_num_pages(umem);
+	atomic_long_sub(ib_umem_num_pages(umem), &umem->owning_mm->pinned_vm);
 	up_write(&umem->owning_mm->mmap_sem);
 
 	__ib_umem_release_tail(umem);
@@ -297,7 +297,7 @@ void ib_umem_release(struct ib_umem *umem)
 	} else {
 		down_write(&umem->owning_mm->mmap_sem);
 	}
-	umem->owning_mm->pinned_vm -= ib_umem_num_pages(umem);
+	atomic_long_sub(ib_umem_num_pages(umem), &umem->owning_mm->pinned_vm);
 	up_write(&umem->owning_mm->mmap_sem);
 
 	__ib_umem_release_tail(umem);
diff --git a/drivers/infiniband/hw/hfi1/user_pages.c b/drivers/infiniband/hw/hfi1/user_pages.c
index e341e6dcc388..df86a596d746 100644
--- a/drivers/infiniband/hw/hfi1/user_pages.c
+++ b/drivers/infiniband/hw/hfi1/user_pages.c
@@ -92,7 +92,7 @@ bool hfi1_can_pin_pages(struct hfi1_devdata *dd, struct mm_struct *mm,
 	size = DIV_ROUND_UP(size, PAGE_SIZE);
 
 	down_read(&mm->mmap_sem);
-	pinned = mm->pinned_vm;
+	pinned = atomic_long_read(&mm->pinned_vm);
 	up_read(&mm->mmap_sem);
 
 	/* First, check the absolute limit against all pinned pages. */
@@ -112,7 +112,7 @@ int hfi1_acquire_user_pages(struct mm_struct *mm, unsigned long vaddr, size_t np
 		return ret;
 
 	down_write(&mm->mmap_sem);
-	mm->pinned_vm += ret;
+	atomic_long_add(ret, &mm->pinned_vm);
 	up_write(&mm->mmap_sem);
 
 	return ret;
@@ -131,7 +131,7 @@ void hfi1_release_user_pages(struct mm_struct *mm, struct page **p,
 
 	if (mm) { /* during close after signal, mm can be NULL */
 		down_write(&mm->mmap_sem);
-		mm->pinned_vm -= npages;
+		atomic_long_sub(npages, &mm->pinned_vm);
 		up_write(&mm->mmap_sem);
 	}
 }
diff --git a/drivers/infiniband/hw/qib/qib_user_pages.c b/drivers/infiniband/hw/qib/qib_user_pages.c
index 16543d5e80c3..981795b23b73 100644
--- a/drivers/infiniband/hw/qib/qib_user_pages.c
+++ b/drivers/infiniband/hw/qib/qib_user_pages.c
@@ -75,7 +75,7 @@ static int __qib_get_user_pages(unsigned long start_page, size_t num_pages,
 			goto bail_release;
 	}
 
-	current->mm->pinned_vm += num_pages;
+	atomic_long_add(num_pages, &current->mm->pinned_vm);
 
 	ret = 0;
 	goto bail;
@@ -156,7 +156,7 @@ void qib_release_user_pages(struct page **p, size_t num_pages)
 	__qib_release_user_pages(p, num_pages, 1);
 
 	if (current->mm) {
-		current->mm->pinned_vm -= num_pages;
+		atomic_long_sub(num_pages, &current->mm->pinned_vm);
 		up_write(&current->mm->mmap_sem);
 	}
 }
diff --git a/drivers/infiniband/hw/usnic/usnic_uiom.c b/drivers/infiniband/hw/usnic/usnic_uiom.c
index 49275a548751..22c40c432b9e 100644
--- a/drivers/infiniband/hw/usnic/usnic_uiom.c
+++ b/drivers/infiniband/hw/usnic/usnic_uiom.c
@@ -129,7 +129,7 @@ static int usnic_uiom_get_pages(unsigned long addr, size_t size, int writable,
 	uiomr->owning_mm = mm = current->mm;
 	down_write(&mm->mmap_sem);
 
-	locked = npages + current->mm->pinned_vm;
+	locked = npages + atomic_long_read(&current->mm->pinned_vm);
 	lock_limit = rlimit(RLIMIT_MEMLOCK) >> PAGE_SHIFT;
 
 	if ((locked > lock_limit) && !capable(CAP_IPC_LOCK)) {
@@ -188,7 +188,7 @@ static int usnic_uiom_get_pages(unsigned long addr, size_t size, int writable,
 	if (ret < 0)
 		usnic_uiom_put_pages(chunk_list, 0);
 	else {
-		mm->pinned_vm = locked;
+		atomic_long_set(&mm->pinned_vm, locked);
 		mmgrab(uiomr->owning_mm);
 	}
 
@@ -442,7 +442,7 @@ static void usnic_uiom_release_defer(struct work_struct *work)
 		container_of(work, struct usnic_uiom_reg, work);
 
 	down_write(&uiomr->owning_mm->mmap_sem);
-	uiomr->owning_mm->pinned_vm -= usnic_uiom_num_pages(uiomr);
+	atomic_long_sub(usnic_uiom_num_pages(uiomr), &uiomr->owning_mm->pinned_vm);
 	up_write(&uiomr->owning_mm->mmap_sem);
 
 	__usnic_uiom_release_tail(uiomr);
@@ -470,7 +470,7 @@ void usnic_uiom_reg_release(struct usnic_uiom_reg *uiomr,
 	} else {
 		down_write(&uiomr->owning_mm->mmap_sem);
 	}
-	uiomr->owning_mm->pinned_vm -= usnic_uiom_num_pages(uiomr);
+	atomic_long_sub(usnic_uiom_num_pages(uiomr), &uiomr->owning_mm->pinned_vm);
 	up_write(&uiomr->owning_mm->mmap_sem);
 
 	__usnic_uiom_release_tail(uiomr);
diff --git a/drivers/misc/mic/scif/scif_rma.c b/drivers/misc/mic/scif/scif_rma.c
index 749321eb91ae..a92b4d6f099c 100644
--- a/drivers/misc/mic/scif/scif_rma.c
+++ b/drivers/misc/mic/scif/scif_rma.c
@@ -285,7 +285,7 @@ __scif_dec_pinned_vm_lock(struct mm_struct *mm,
 	} else {
 		down_write(&mm->mmap_sem);
 	}
-	mm->pinned_vm -= nr_pages;
+	atomic_long_sub(nr_pages, &mm->pinned_vm);
 	up_write(&mm->mmap_sem);
 	return 0;
 }
@@ -299,7 +299,7 @@ static inline int __scif_check_inc_pinned_vm(struct mm_struct *mm,
 		return 0;
 
 	locked = nr_pages;
-	locked += mm->pinned_vm;
+	locked += atomic_long_read(&mm->pinned_vm);
 	lock_limit = rlimit(RLIMIT_MEMLOCK) >> PAGE_SHIFT;
 	if ((locked > lock_limit) && !capable(CAP_IPC_LOCK)) {
 		dev_err(scif_info.mdev.this_device,
@@ -307,7 +307,7 @@ static inline int __scif_check_inc_pinned_vm(struct mm_struct *mm,
 			locked, lock_limit);
 		return -ENOMEM;
 	}
-	mm->pinned_vm = locked;
+	atomic_long_set(&mm->pinned_vm, locked);
 	return 0;
 }
 
diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index f0ec9edab2f3..f5ac0b7fadcb 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -59,7 +59,7 @@ void task_mem(struct seq_file *m, struct mm_struct *mm)
 	SEQ_PUT_DEC("VmPeak:\t", hiwater_vm);
 	SEQ_PUT_DEC(" kB\nVmSize:\t", total_vm);
 	SEQ_PUT_DEC(" kB\nVmLck:\t", mm->locked_vm);
-	SEQ_PUT_DEC(" kB\nVmPin:\t", mm->pinned_vm);
+	SEQ_PUT_DEC(" kB\nVmPin:\t", atomic_long_read(&mm->pinned_vm));
 	SEQ_PUT_DEC(" kB\nVmHWM:\t", hiwater_rss);
 	SEQ_PUT_DEC(" kB\nVmRSS:\t", total_rss);
 	SEQ_PUT_DEC(" kB\nRssAnon:\t", anon);
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 2c471a2c43fa..38b1c5dc6d82 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -405,7 +405,7 @@ struct mm_struct {
 
 		unsigned long total_vm;	   /* Total pages mapped */
 		unsigned long locked_vm;   /* Pages that have PG_mlocked set */
-		unsigned long pinned_vm;   /* Refcount permanently increased */
+		atomic_long_t    pinned_vm;   /* Refcount permanently increased */
 		unsigned long data_vm;	   /* VM_WRITE & ~VM_SHARED & ~VM_STACK */
 		unsigned long exec_vm;	   /* VM_EXEC & ~VM_WRITE & ~VM_STACK */
 		unsigned long stack_vm;	   /* VM_STACK */
diff --git a/kernel/events/core.c b/kernel/events/core.c
index 3cd13a30f732..af6ed973e9ee 100644
--- a/kernel/events/core.c
+++ b/kernel/events/core.c
@@ -5459,7 +5459,7 @@ static void perf_mmap_close(struct vm_area_struct *vma)
 
 		/* now it's safe to free the pages */
 		atomic_long_sub(rb->aux_nr_pages, &mmap_user->locked_vm);
-		vma->vm_mm->pinned_vm -= rb->aux_mmap_locked;
+		atomic_long_sub(rb->aux_mmap_locked, &vma->vm_mm->pinned_vm);
 
 		/* this has to be the last one */
 		rb_free_aux(rb);
@@ -5532,7 +5532,7 @@ static void perf_mmap_close(struct vm_area_struct *vma)
 	 */
 
 	atomic_long_sub((size >> PAGE_SHIFT) + 1, &mmap_user->locked_vm);
-	vma->vm_mm->pinned_vm -= mmap_locked;
+	atomic_long_sub(mmap_locked, &vma->vm_mm->pinned_vm);
 	free_uid(mmap_user);
 
 out_put:
@@ -5680,7 +5680,7 @@ static int perf_mmap(struct file *file, struct vm_area_struct *vma)
 
 	lock_limit = rlimit(RLIMIT_MEMLOCK);
 	lock_limit >>= PAGE_SHIFT;
-	locked = vma->vm_mm->pinned_vm + extra;
+	locked = atomic_long_read(&vma->vm_mm->pinned_vm) + extra;
 
 	if ((locked > lock_limit) && perf_paranoid_tracepoint_raw() &&
 		!capable(CAP_IPC_LOCK)) {
@@ -5721,7 +5721,7 @@ static int perf_mmap(struct file *file, struct vm_area_struct *vma)
 unlock:
 	if (!ret) {
 		atomic_long_add(user_extra, &user->locked_vm);
-		vma->vm_mm->pinned_vm += extra;
+		atomic_long_add(extra, &vma->vm_mm->pinned_vm);
 
 		atomic_inc(&event->mmap_count);
 	} else if (rb) {
diff --git a/kernel/fork.c b/kernel/fork.c
index b69248e6f0e0..cb34bf852231 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -981,7 +981,7 @@ static struct mm_struct *mm_init(struct mm_struct *mm, struct task_struct *p,
 	mm_pgtables_bytes_init(mm);
 	mm->map_count = 0;
 	mm->locked_vm = 0;
-	mm->pinned_vm = 0;
+	atomic_long_set(&mm->pinned_vm, 0);
 	memset(&mm->rss_stat, 0, sizeof(mm->rss_stat));
 	spin_lock_init(&mm->page_table_lock);
 	spin_lock_init(&mm->arg_lock);
diff --git a/mm/debug.c b/mm/debug.c
index 0abb987dad9b..d2dc74e83cd5 100644
--- a/mm/debug.c
+++ b/mm/debug.c
@@ -166,7 +166,8 @@ void dump_mm(const struct mm_struct *mm)
 		mm_pgtables_bytes(mm),
 		mm->map_count,
 		mm->hiwater_rss, mm->hiwater_vm, mm->total_vm, mm->locked_vm,
-		mm->pinned_vm, mm->data_vm, mm->exec_vm, mm->stack_vm,
+		atomic_long_read(&mm->pinned_vm),
+		mm->data_vm, mm->exec_vm, mm->stack_vm,
 		mm->start_code, mm->end_code, mm->start_data, mm->end_data,
 		mm->start_brk, mm->brk, mm->start_stack,
 		mm->arg_start, mm->arg_end, mm->env_start, mm->env_end,
-- 
2.16.4
