Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 788D38E0007
	for <linux-mm@kvack.org>; Tue, 15 Jan 2019 13:13:41 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id q62so2168928pgq.9
        for <linux-mm@kvack.org>; Tue, 15 Jan 2019 10:13:41 -0800 (PST)
Received: from smtp2.provo.novell.com (smtp2.provo.novell.com. [137.65.250.81])
        by mx.google.com with ESMTPS id u4si3692634pga.91.2019.01.15.10.13.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Jan 2019 10:13:40 -0800 (PST)
From: Davidlohr Bueso <dave@stgolabs.net>
Subject: [PATCH 6/6] drivers/IB,core: reduce scope of mmap_sem
Date: Tue, 15 Jan 2019 10:13:00 -0800
Message-Id: <20190115181300.27547-7-dave@stgolabs.net>
In-Reply-To: <20190115181300.27547-1-dave@stgolabs.net>
References: <20190115181300.27547-1-dave@stgolabs.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: dledford@redhat.com, jgg@mellanox.com, linux-rdma@vger.kernel.org, linux-mm@kvack.org, dave@stgolabs.net, Davidlohr Bueso <dbueso@suse.de>

ib_umem_get() uses gup_longterm() and relies on the lock to
stabilze the vma_list, so we cannot really get rid of mmap_sem
altogether, but now that the counter is atomic, we can get of
some complexity that mmap_sem brings with only pinned_vm.

Signed-off-by: Davidlohr Bueso <dbueso@suse.de>
---
 drivers/infiniband/core/umem.c | 41 ++---------------------------------------
 1 file changed, 2 insertions(+), 39 deletions(-)

diff --git a/drivers/infiniband/core/umem.c b/drivers/infiniband/core/umem.c
index bf556215aa7e..baa2412bf6fb 100644
--- a/drivers/infiniband/core/umem.c
+++ b/drivers/infiniband/core/umem.c
@@ -160,15 +160,12 @@ struct ib_umem *ib_umem_get(struct ib_ucontext *context, unsigned long addr,
 
 	lock_limit = rlimit(RLIMIT_MEMLOCK) >> PAGE_SHIFT;
 
-	down_write(&mm->mmap_sem);
-	new_pinned = atomic_long_read(&mm->pinned_vm) + npages;
+	new_pinned = atomic_long_add_return(npages, &mm->pinned_vm);
 	if (new_pinned > lock_limit && !capable(CAP_IPC_LOCK)) {
-		up_write(&mm->mmap_sem);
+		atomic_long_sub(npages, &mm->pinned_vm);
 		ret = -ENOMEM;
 		goto out;
 	}
-	atomic_long_set(&mm->pinned_vm, new_pinned);
-	up_write(&mm->mmap_sem);
 
 	cur_base = addr & PAGE_MASK;
 
@@ -228,9 +225,7 @@ struct ib_umem *ib_umem_get(struct ib_ucontext *context, unsigned long addr,
 umem_release:
 	__ib_umem_release(context->device, umem, 0);
 vma:
-	down_write(&mm->mmap_sem);
 	atomic_long_sub(ib_umem_num_pages(umem), &mm->pinned_vm);
-	up_write(&mm->mmap_sem);
 out:
 	if (vma_list)
 		free_page((unsigned long) vma_list);
@@ -253,25 +248,12 @@ static void __ib_umem_release_tail(struct ib_umem *umem)
 		kfree(umem);
 }
 
-static void ib_umem_release_defer(struct work_struct *work)
-{
-	struct ib_umem *umem = container_of(work, struct ib_umem, work);
-
-	down_write(&umem->owning_mm->mmap_sem);
-	atomic_long_sub(ib_umem_num_pages(umem), &umem->owning_mm->pinned_vm);
-	up_write(&umem->owning_mm->mmap_sem);
-
-	__ib_umem_release_tail(umem);
-}
-
 /**
  * ib_umem_release - release memory pinned with ib_umem_get
  * @umem: umem struct to release
  */
 void ib_umem_release(struct ib_umem *umem)
 {
-	struct ib_ucontext *context = umem->context;
-
 	if (umem->is_odp) {
 		ib_umem_odp_release(to_ib_umem_odp(umem));
 		__ib_umem_release_tail(umem);
@@ -280,26 +262,7 @@ void ib_umem_release(struct ib_umem *umem)
 
 	__ib_umem_release(umem->context->device, umem, 1);
 
-	/*
-	 * We may be called with the mm's mmap_sem already held.  This
-	 * can happen when a userspace munmap() is the call that drops
-	 * the last reference to our file and calls our release
-	 * method.  If there are memory regions to destroy, we'll end
-	 * up here and not be able to take the mmap_sem.  In that case
-	 * we defer the vm_locked accounting a workqueue.
-	 */
-	if (context->closing) {
-		if (!down_write_trylock(&umem->owning_mm->mmap_sem)) {
-			INIT_WORK(&umem->work, ib_umem_release_defer);
-			queue_work(ib_wq, &umem->work);
-			return;
-		}
-	} else {
-		down_write(&umem->owning_mm->mmap_sem);
-	}
 	atomic_long_sub(ib_umem_num_pages(umem), &umem->owning_mm->pinned_vm);
-	up_write(&umem->owning_mm->mmap_sem);
-
 	__ib_umem_release_tail(umem);
 }
 EXPORT_SYMBOL(ib_umem_release);
-- 
2.16.4
