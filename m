Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2A8156B0062
	for <linux-mm@kvack.org>; Sun,  4 Feb 2018 20:28:10 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id i8so2379896pgv.23
        for <linux-mm@kvack.org>; Sun, 04 Feb 2018 17:28:10 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t138si2318386pgb.548.2018.02.04.17.28.08
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 04 Feb 2018 17:28:08 -0800 (PST)
From: Davidlohr Bueso <dbueso@suse.de>
Subject: [PATCH 58/64] drivers/infiniband: use mm locking wrappers
Date: Mon,  5 Feb 2018 02:27:48 +0100
Message-Id: <20180205012754.23615-59-dbueso@wotan.suse.de>
In-Reply-To: <20180205012754.23615-1-dbueso@wotan.suse.de>
References: <20180205012754.23615-1-dbueso@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mingo@kernel.org
Cc: peterz@infradead.org, ldufour@linux.vnet.ibm.com, jack@suse.cz, mhocko@kernel.org, kirill.shutemov@linux.intel.com, mawilcox@microsoft.com, mgorman@techsingularity.net, dave@stgolabs.net, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Davidlohr Bueso <dbueso@suse.de>

From: Davidlohr Bueso <dave@stgolabs.net>

This becomes quite straightforward with the mmrange in place.

Signed-off-by: Davidlohr Bueso <dbueso@suse.de>
---
 drivers/infiniband/core/umem.c             | 16 +++++++++-------
 drivers/infiniband/core/umem_odp.c         | 11 ++++++-----
 drivers/infiniband/hw/hfi1/user_pages.c    | 15 +++++++++------
 drivers/infiniband/hw/mlx4/main.c          |  5 +++--
 drivers/infiniband/hw/mlx5/main.c          |  5 +++--
 drivers/infiniband/hw/qib/qib_user_pages.c | 10 ++++++----
 drivers/infiniband/hw/usnic/usnic_uiom.c   | 16 +++++++++-------
 7 files changed, 45 insertions(+), 33 deletions(-)

diff --git a/drivers/infiniband/core/umem.c b/drivers/infiniband/core/umem.c
index fd9601ed5b84..bdbb345916d0 100644
--- a/drivers/infiniband/core/umem.c
+++ b/drivers/infiniband/core/umem.c
@@ -164,7 +164,7 @@ struct ib_umem *ib_umem_get(struct ib_ucontext *context, unsigned long addr,
 
 	npages = ib_umem_num_pages(umem);
 
-	down_write(&current->mm->mmap_sem);
+	mm_write_lock(current->mm, &mmrange);
 
 	locked     = npages + current->mm->pinned_vm;
 	lock_limit = rlimit(RLIMIT_MEMLOCK) >> PAGE_SHIFT;
@@ -237,7 +237,7 @@ struct ib_umem *ib_umem_get(struct ib_ucontext *context, unsigned long addr,
 	} else
 		current->mm->pinned_vm = locked;
 
-	up_write(&current->mm->mmap_sem);
+	mm_write_unlock(current->mm, &mmrange);
 	if (vma_list)
 		free_page((unsigned long) vma_list);
 	free_page((unsigned long) page_list);
@@ -249,10 +249,11 @@ EXPORT_SYMBOL(ib_umem_get);
 static void ib_umem_account(struct work_struct *work)
 {
 	struct ib_umem *umem = container_of(work, struct ib_umem, work);
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
-	down_write(&umem->mm->mmap_sem);
+	mm_write_lock(umem->mm, &mmrange);
 	umem->mm->pinned_vm -= umem->diff;
-	up_write(&umem->mm->mmap_sem);
+	mm_write_unlock(umem->mm, &mmrange);
 	mmput(umem->mm);
 	kfree(umem);
 }
@@ -267,6 +268,7 @@ void ib_umem_release(struct ib_umem *umem)
 	struct mm_struct *mm;
 	struct task_struct *task;
 	unsigned long diff;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	if (umem->odp_data) {
 		ib_umem_odp_release(umem);
@@ -295,7 +297,7 @@ void ib_umem_release(struct ib_umem *umem)
 	 * we defer the vm_locked accounting to the system workqueue.
 	 */
 	if (context->closing) {
-		if (!down_write_trylock(&mm->mmap_sem)) {
+		if (!mm_write_trylock(mm, &mmrange)) {
 			INIT_WORK(&umem->work, ib_umem_account);
 			umem->mm   = mm;
 			umem->diff = diff;
@@ -304,10 +306,10 @@ void ib_umem_release(struct ib_umem *umem)
 			return;
 		}
 	} else
-		down_write(&mm->mmap_sem);
+		mm_write_lock(mm, &mmrange);
 
 	mm->pinned_vm -= diff;
-	up_write(&mm->mmap_sem);
+	mm_write_unlock(mm, &mmrange);
 	mmput(mm);
 out:
 	kfree(umem);
diff --git a/drivers/infiniband/core/umem_odp.c b/drivers/infiniband/core/umem_odp.c
index 0572953260e8..3b5f6814ba41 100644
--- a/drivers/infiniband/core/umem_odp.c
+++ b/drivers/infiniband/core/umem_odp.c
@@ -334,16 +334,17 @@ int ib_umem_odp_get(struct ib_ucontext *context, struct ib_umem *umem,
 	if (access & IB_ACCESS_HUGETLB) {
 		struct vm_area_struct *vma;
 		struct hstate *h;
+		DEFINE_RANGE_LOCK_FULL(mmrange);
 
-		down_read(&mm->mmap_sem);
+		mm_read_lock(mm, &mmrange);
 		vma = find_vma(mm, ib_umem_start(umem));
 		if (!vma || !is_vm_hugetlb_page(vma)) {
-			up_read(&mm->mmap_sem);
+			mm_read_unlock(mm, &mmrange);
 			return -EINVAL;
 		}
 		h = hstate_vma(vma);
 		umem->page_shift = huge_page_shift(h);
-		up_read(&mm->mmap_sem);
+		mm_read_unlock(mm, &mmrange);
 		umem->hugetlb = 1;
 	} else {
 		umem->hugetlb = 0;
@@ -674,7 +675,7 @@ int ib_umem_odp_map_dma_pages(struct ib_umem *umem, u64 user_virt, u64 bcnt,
 				(bcnt + BIT(page_shift) - 1) >> page_shift,
 				PAGE_SIZE / sizeof(struct page *));
 
-		down_read(&owning_mm->mmap_sem);
+		mm_read_lock(owning_mm, &mmrange);
 		/*
 		 * Note: this might result in redundent page getting. We can
 		 * avoid this by checking dma_list to be 0 before calling
@@ -685,7 +686,7 @@ int ib_umem_odp_map_dma_pages(struct ib_umem *umem, u64 user_virt, u64 bcnt,
 		npages = get_user_pages_remote(owning_process, owning_mm,
 				user_virt, gup_num_pages,
 				flags, local_page_list, NULL, NULL, &mmrange);
-		up_read(&owning_mm->mmap_sem);
+		mm_read_unlock(owning_mm, &mmrange);
 
 		if (npages < 0)
 			break;
diff --git a/drivers/infiniband/hw/hfi1/user_pages.c b/drivers/infiniband/hw/hfi1/user_pages.c
index e341e6dcc388..1a6103d4f367 100644
--- a/drivers/infiniband/hw/hfi1/user_pages.c
+++ b/drivers/infiniband/hw/hfi1/user_pages.c
@@ -76,6 +76,7 @@ bool hfi1_can_pin_pages(struct hfi1_devdata *dd, struct mm_struct *mm,
 	unsigned int usr_ctxts =
 			dd->num_rcv_contexts - dd->first_dyn_alloc_ctxt;
 	bool can_lock = capable(CAP_IPC_LOCK);
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	/*
 	 * Calculate per-cache size. The calculation below uses only a quarter
@@ -91,9 +92,9 @@ bool hfi1_can_pin_pages(struct hfi1_devdata *dd, struct mm_struct *mm,
 	/* Convert to number of pages */
 	size = DIV_ROUND_UP(size, PAGE_SIZE);
 
-	down_read(&mm->mmap_sem);
+	mm_read_lock(mm, &mmrange);
 	pinned = mm->pinned_vm;
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &mmrange);
 
 	/* First, check the absolute limit against all pinned pages. */
 	if (pinned + npages >= ulimit && !can_lock)
@@ -106,14 +107,15 @@ int hfi1_acquire_user_pages(struct mm_struct *mm, unsigned long vaddr, size_t np
 			    bool writable, struct page **pages)
 {
 	int ret;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	ret = get_user_pages_fast(vaddr, npages, writable, pages);
 	if (ret < 0)
 		return ret;
 
-	down_write(&mm->mmap_sem);
+	mm_write_lock(mm, &mmrange);
 	mm->pinned_vm += ret;
-	up_write(&mm->mmap_sem);
+	mm_write_unlock(mm, &mmrange);
 
 	return ret;
 }
@@ -122,6 +124,7 @@ void hfi1_release_user_pages(struct mm_struct *mm, struct page **p,
 			     size_t npages, bool dirty)
 {
 	size_t i;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	for (i = 0; i < npages; i++) {
 		if (dirty)
@@ -130,8 +133,8 @@ void hfi1_release_user_pages(struct mm_struct *mm, struct page **p,
 	}
 
 	if (mm) { /* during close after signal, mm can be NULL */
-		down_write(&mm->mmap_sem);
+		mm_write_lock(mm, &mmrange);
 		mm->pinned_vm -= npages;
-		up_write(&mm->mmap_sem);
+		mm_write_unlock(mm, &mmrange);
 	}
 }
diff --git a/drivers/infiniband/hw/mlx4/main.c b/drivers/infiniband/hw/mlx4/main.c
index 8d2ee9322f2e..3124717bda45 100644
--- a/drivers/infiniband/hw/mlx4/main.c
+++ b/drivers/infiniband/hw/mlx4/main.c
@@ -1188,6 +1188,7 @@ static void mlx4_ib_disassociate_ucontext(struct ib_ucontext *ibcontext)
 	struct mlx4_ib_ucontext *context = to_mucontext(ibcontext);
 	struct task_struct *owning_process  = NULL;
 	struct mm_struct   *owning_mm       = NULL;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	owning_process = get_pid_task(ibcontext->tgid, PIDTYPE_PID);
 	if (!owning_process)
@@ -1219,7 +1220,7 @@ static void mlx4_ib_disassociate_ucontext(struct ib_ucontext *ibcontext)
 	/* need to protect from a race on closing the vma as part of
 	 * mlx4_ib_vma_close().
 	 */
-	down_write(&owning_mm->mmap_sem);
+	mm_write_lock(owning_mm, &mmrange);
 	for (i = 0; i < HW_BAR_COUNT; i++) {
 		vma = context->hw_bar_info[i].vma;
 		if (!vma)
@@ -1239,7 +1240,7 @@ static void mlx4_ib_disassociate_ucontext(struct ib_ucontext *ibcontext)
 		context->hw_bar_info[i].vma->vm_ops = NULL;
 	}
 
-	up_write(&owning_mm->mmap_sem);
+	mm_write_unlock(owning_mm, &mmrange);
 	mmput(owning_mm);
 	put_task_struct(owning_process);
 }
diff --git a/drivers/infiniband/hw/mlx5/main.c b/drivers/infiniband/hw/mlx5/main.c
index 4236c8086820..303fed2657fe 100644
--- a/drivers/infiniband/hw/mlx5/main.c
+++ b/drivers/infiniband/hw/mlx5/main.c
@@ -1902,6 +1902,7 @@ static void mlx5_ib_disassociate_ucontext(struct ib_ucontext *ibcontext)
 	struct mlx5_ib_ucontext *context = to_mucontext(ibcontext);
 	struct task_struct *owning_process  = NULL;
 	struct mm_struct   *owning_mm       = NULL;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	owning_process = get_pid_task(ibcontext->tgid, PIDTYPE_PID);
 	if (!owning_process)
@@ -1931,7 +1932,7 @@ static void mlx5_ib_disassociate_ucontext(struct ib_ucontext *ibcontext)
 	/* need to protect from a race on closing the vma as part of
 	 * mlx5_ib_vma_close.
 	 */
-	down_write(&owning_mm->mmap_sem);
+	mm_write_lock(owning_mm, &mmrange);
 	mutex_lock(&context->vma_private_list_mutex);
 	list_for_each_entry_safe(vma_private, n, &context->vma_private_list,
 				 list) {
@@ -1948,7 +1949,7 @@ static void mlx5_ib_disassociate_ucontext(struct ib_ucontext *ibcontext)
 		kfree(vma_private);
 	}
 	mutex_unlock(&context->vma_private_list_mutex);
-	up_write(&owning_mm->mmap_sem);
+	mm_write_unlock(owning_mm, &mmrange);
 	mmput(owning_mm);
 	put_task_struct(owning_process);
 }
diff --git a/drivers/infiniband/hw/qib/qib_user_pages.c b/drivers/infiniband/hw/qib/qib_user_pages.c
index 6bcb4f9f9b30..13b7f6f93560 100644
--- a/drivers/infiniband/hw/qib/qib_user_pages.c
+++ b/drivers/infiniband/hw/qib/qib_user_pages.c
@@ -136,24 +136,26 @@ int qib_get_user_pages(unsigned long start_page, size_t num_pages,
 	int ret;
 	DEFINE_RANGE_LOCK_FULL(mmrange);
 
-	down_write(&current->mm->mmap_sem);
+	mm_write_lock(current->mm, &mmrange);
 
 	ret = __qib_get_user_pages(start_page, num_pages, p, &mmrange);
 
-	up_write(&current->mm->mmap_sem);
+	mm_write_unlock(current->mm, &mmrange);
 
 	return ret;
 }
 
 void qib_release_user_pages(struct page **p, size_t num_pages)
 {
+	DEFINE_RANGE_LOCK_FULL(mmrange);
+
 	if (current->mm) /* during close after signal, mm can be NULL */
-		down_write(&current->mm->mmap_sem);
+		mm_write_lock(current->mm, &mmrange);
 
 	__qib_release_user_pages(p, num_pages, 1);
 
 	if (current->mm) {
 		current->mm->pinned_vm -= num_pages;
-		up_write(&current->mm->mmap_sem);
+		mm_write_unlock(current->mm, &mmrange);
 	}
 }
diff --git a/drivers/infiniband/hw/usnic/usnic_uiom.c b/drivers/infiniband/hw/usnic/usnic_uiom.c
index 5f36c6d2e21b..7cb05133311c 100644
--- a/drivers/infiniband/hw/usnic/usnic_uiom.c
+++ b/drivers/infiniband/hw/usnic/usnic_uiom.c
@@ -57,10 +57,11 @@ static void usnic_uiom_reg_account(struct work_struct *work)
 {
 	struct usnic_uiom_reg *umem = container_of(work,
 						struct usnic_uiom_reg, work);
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
-	down_write(&umem->mm->mmap_sem);
+	mm_write_lock(umem->mm, &mmrange);
 	umem->mm->locked_vm -= umem->diff;
-	up_write(&umem->mm->mmap_sem);
+	mm_write_unlock(umem->mm, &mmrange);
 	mmput(umem->mm);
 	kfree(umem);
 }
@@ -126,7 +127,7 @@ static int usnic_uiom_get_pages(unsigned long addr, size_t size, int writable,
 
 	npages = PAGE_ALIGN(size + (addr & ~PAGE_MASK)) >> PAGE_SHIFT;
 
-	down_write(&current->mm->mmap_sem);
+	mm_write_lock(current->mm, &mmrange);
 
 	locked = npages + current->mm->locked_vm;
 	lock_limit = rlimit(RLIMIT_MEMLOCK) >> PAGE_SHIFT;
@@ -189,7 +190,7 @@ static int usnic_uiom_get_pages(unsigned long addr, size_t size, int writable,
 	else
 		current->mm->locked_vm = locked;
 
-	up_write(&current->mm->mmap_sem);
+	mm_write_unlock(current->mm, &mmrange);
 	free_page((unsigned long) page_list);
 	return ret;
 }
@@ -425,6 +426,7 @@ void usnic_uiom_reg_release(struct usnic_uiom_reg *uiomr, int closing)
 {
 	struct mm_struct *mm;
 	unsigned long diff;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	__usnic_uiom_reg_release(uiomr->pd, uiomr, 1);
 
@@ -445,7 +447,7 @@ void usnic_uiom_reg_release(struct usnic_uiom_reg *uiomr, int closing)
 	 * we defer the vm_locked accounting to the system workqueue.
 	 */
 	if (closing) {
-		if (!down_write_trylock(&mm->mmap_sem)) {
+		if (!mm_write_trylock(mm, &mmrange)) {
 			INIT_WORK(&uiomr->work, usnic_uiom_reg_account);
 			uiomr->mm = mm;
 			uiomr->diff = diff;
@@ -454,10 +456,10 @@ void usnic_uiom_reg_release(struct usnic_uiom_reg *uiomr, int closing)
 			return;
 		}
 	} else
-		down_write(&mm->mmap_sem);
+		mm_write_lock(mm, &mmrange);
 
 	current->mm->locked_vm -= diff;
-	up_write(&mm->mmap_sem);
+	mm_write_unlock(mm, &mmrange);
 	mmput(mm);
 	kfree(uiomr);
 }
-- 
2.13.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
