Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f198.google.com (mail-yw0-f198.google.com [209.85.161.198])
	by kanga.kvack.org (Postfix) with ESMTP id 240426B0007
	for <linux-mm@kvack.org>; Fri, 23 Mar 2018 13:18:09 -0400 (EDT)
Received: by mail-yw0-f198.google.com with SMTP id l188so1083219ywd.6
        for <linux-mm@kvack.org>; Fri, 23 Mar 2018 10:18:09 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id 196si1800996ywx.103.2018.03.23.10.18.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Mar 2018 10:18:06 -0700 (PDT)
From: jglisse@redhat.com
Subject: [RFC PATCH 1/3] mm/mmu_notifier: use struct for invalidate_range_start/end parameters
Date: Fri, 23 Mar 2018 13:17:46 -0400
Message-Id: <20180323171748.20359-2-jglisse@redhat.com>
In-Reply-To: <20180323171748.20359-1-jglisse@redhat.com>
References: <20180323171748.20359-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, David Rientjes <rientjes@google.com>, Joerg Roedel <joro@8bytes.org>, Dan Williams <dan.j.williams@intel.com>, =?UTF-8?q?Christian=20K=C3=B6nig?= <christian.koenig@amd.com>, Paolo Bonzini <pbonzini@redhat.com>, Michal Hocko <mhocko@suse.com>, Leon Romanovsky <leonro@mellanox.com>, Artemy Kovalyov <artemyko@mellanox.com>, Evgeny Baskakov <ebaskakov@nvidia.com>, Ralph Campbell <rcampbell@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Mike Marciniszyn <mike.marciniszyn@intel.com>, Dennis Dalessandro <dennis.dalessandro@intel.com>, Alex Deucher <alexander.deucher@amd.com>, Sudeep Dutt <sudeep.dutt@intel.com>, Ashutosh Dixit <ashutosh.dixit@intel.com>, Dimitri Sivanich <sivanich@sgi.com>

From: JA(C)rA'me Glisse <jglisse@redhat.com>

Using a struct for mmu_notifier_invalidate_range_start()|end() allows
to add more parameters in the future without having to change every
call sites or every callback. They are no functional change with this
patch.

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
Cc: David Rientjes <rientjes@google.com>
Cc: Joerg Roedel <joro@8bytes.org>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Christian KA?nig <christian.koenig@amd.com>
Cc: Paolo Bonzini <pbonzini@redhat.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Leon Romanovsky <leonro@mellanox.com>
Cc: Artemy Kovalyov <artemyko@mellanox.com>
Cc: Evgeny Baskakov <ebaskakov@nvidia.com>
Cc: Ralph Campbell <rcampbell@nvidia.com>
Cc: Mark Hairgrove <mhairgrove@nvidia.com>
Cc: John Hubbard <jhubbard@nvidia.com>
Cc: Mike Marciniszyn <mike.marciniszyn@intel.com>
Cc: Dennis Dalessandro <dennis.dalessandro@intel.com>
Cc: Alex Deucher <alexander.deucher@amd.com>
Cc: Sudeep Dutt <sudeep.dutt@intel.com>
Cc: Ashutosh Dixit <ashutosh.dixit@intel.com>
Cc: Dimitri Sivanich <sivanich@sgi.com>
---
 drivers/gpu/drm/amd/amdgpu/amdgpu_mn.c  | 17 +++---
 drivers/gpu/drm/i915/i915_gem_userptr.c | 13 ++---
 drivers/gpu/drm/radeon/radeon_mn.c      | 11 ++--
 drivers/infiniband/core/umem_odp.c      | 16 +++---
 drivers/infiniband/hw/hfi1/mmu_rb.c     | 12 ++---
 drivers/misc/mic/scif/scif_dma.c        | 10 ++--
 drivers/misc/sgi-gru/grutlbpurge.c      | 13 +++--
 drivers/xen/gntdev.c                    |  7 ++-
 fs/dax.c                                |  7 +--
 fs/proc/task_mmu.c                      |  7 ++-
 include/linux/mm.h                      |  3 +-
 include/linux/mmu_notifier.h            | 67 ++++++++++++++++--------
 kernel/events/uprobes.c                 | 10 ++--
 mm/hmm.c                                | 15 +++---
 mm/huge_memory.c                        | 64 +++++++++++------------
 mm/hugetlb.c                            | 43 +++++++--------
 mm/khugepaged.c                         | 11 ++--
 mm/ksm.c                                | 22 ++++----
 mm/madvise.c                            | 20 +++----
 mm/memory.c                             | 92 ++++++++++++++++++---------------
 mm/migrate.c                            | 44 ++++++++--------
 mm/mmu_notifier.c                       | 16 +++---
 mm/mprotect.c                           | 13 ++---
 mm/mremap.c                             | 11 ++--
 mm/oom_kill.c                           | 18 ++++---
 mm/rmap.c                               | 20 ++++---
 virt/kvm/kvm_main.c                     | 12 ++---
 27 files changed, 301 insertions(+), 293 deletions(-)

diff --git a/drivers/gpu/drm/amd/amdgpu/amdgpu_mn.c b/drivers/gpu/drm/amd/amdgpu/amdgpu_mn.c
index bd67f4cb8e6c..c2e3f17adb09 100644
--- a/drivers/gpu/drm/amd/amdgpu/amdgpu_mn.c
+++ b/drivers/gpu/drm/amd/amdgpu/amdgpu_mn.c
@@ -196,26 +196,23 @@ static void amdgpu_mn_invalidate_node(struct amdgpu_mn_node *node,
  * unmap them by move them into system domain again.
  */
 static void amdgpu_mn_invalidate_range_start(struct mmu_notifier *mn,
-					     struct mm_struct *mm,
-					     unsigned long start,
-					     unsigned long end)
+					     const struct mmu_notifier_range *range)
 {
 	struct amdgpu_mn *rmn = container_of(mn, struct amdgpu_mn, mn);
 	struct interval_tree_node *it;
-
 	/* notification is exclusive, but interval is inclusive */
-	end -= 1;
+	unsigned long end = range->end - 1;
 
 	amdgpu_mn_read_lock(rmn);
 
-	it = interval_tree_iter_first(&rmn->objects, start, end);
+	it = interval_tree_iter_first(&rmn->objects, range->start, end);
 	while (it) {
 		struct amdgpu_mn_node *node;
 
 		node = container_of(it, struct amdgpu_mn_node, it);
-		it = interval_tree_iter_next(it, start, end);
+		it = interval_tree_iter_next(it, range->start, end);
 
-		amdgpu_mn_invalidate_node(node, start, end);
+		amdgpu_mn_invalidate_node(node, range->start, end);
 	}
 }
 
@@ -230,9 +227,7 @@ static void amdgpu_mn_invalidate_range_start(struct mmu_notifier *mn,
  * Release the lock again to allow new command submissions.
  */
 static void amdgpu_mn_invalidate_range_end(struct mmu_notifier *mn,
-					   struct mm_struct *mm,
-					   unsigned long start,
-					   unsigned long end)
+					   const struct mmu_notifier_range *range)
 {
 	struct amdgpu_mn *rmn = container_of(mn, struct amdgpu_mn, mn);
 
diff --git a/drivers/gpu/drm/i915/i915_gem_userptr.c b/drivers/gpu/drm/i915/i915_gem_userptr.c
index 382a77a1097e..afff9c8bb706 100644
--- a/drivers/gpu/drm/i915/i915_gem_userptr.c
+++ b/drivers/gpu/drm/i915/i915_gem_userptr.c
@@ -113,24 +113,21 @@ static void del_object(struct i915_mmu_object *mo)
 }
 
 static void i915_gem_userptr_mn_invalidate_range_start(struct mmu_notifier *_mn,
-						       struct mm_struct *mm,
-						       unsigned long start,
-						       unsigned long end)
+						       const struct mmu_notifier_range *range)
 {
 	struct i915_mmu_notifier *mn =
 		container_of(_mn, struct i915_mmu_notifier, mn);
 	struct i915_mmu_object *mo;
 	struct interval_tree_node *it;
+	/* interval ranges are inclusive, but invalidate range is exclusive */
+	unsigned long end = range->end - 1;
 	LIST_HEAD(cancelled);
 
 	if (RB_EMPTY_ROOT(&mn->objects.rb_root))
 		return;
 
-	/* interval ranges are inclusive, but invalidate range is exclusive */
-	end--;
-
 	spin_lock(&mn->lock);
-	it = interval_tree_iter_first(&mn->objects, start, end);
+	it = interval_tree_iter_first(&mn->objects, range->start, end);
 	while (it) {
 		/* The mmu_object is released late when destroying the
 		 * GEM object so it is entirely possible to gain a
@@ -146,7 +143,7 @@ static void i915_gem_userptr_mn_invalidate_range_start(struct mmu_notifier *_mn,
 			queue_work(mn->wq, &mo->work);
 
 		list_add(&mo->link, &cancelled);
-		it = interval_tree_iter_next(it, start, end);
+		it = interval_tree_iter_next(it, range->start, end);
 	}
 	list_for_each_entry(mo, &cancelled, link)
 		del_object(mo);
diff --git a/drivers/gpu/drm/radeon/radeon_mn.c b/drivers/gpu/drm/radeon/radeon_mn.c
index 1d62288b7ee3..4e4c4ea2e725 100644
--- a/drivers/gpu/drm/radeon/radeon_mn.c
+++ b/drivers/gpu/drm/radeon/radeon_mn.c
@@ -119,26 +119,23 @@ static void radeon_mn_release(struct mmu_notifier *mn,
  * unmap them by move them into system domain again.
  */
 static void radeon_mn_invalidate_range_start(struct mmu_notifier *mn,
-					     struct mm_struct *mm,
-					     unsigned long start,
-					     unsigned long end)
+					     const struct mmu_notifier_range *range)
 {
 	struct radeon_mn *rmn = container_of(mn, struct radeon_mn, mn);
 	struct interval_tree_node *it;
-
 	/* notification is exclusive, but interval is inclusive */
-	end -= 1;
+	unsigned long end = range->end - 1;
 
 	mutex_lock(&rmn->lock);
 
-	it = interval_tree_iter_first(&rmn->objects, start, end);
+	it = interval_tree_iter_first(&rmn->objects, range->start, end);
 	while (it) {
 		struct radeon_mn_node *node;
 		struct radeon_bo *bo;
 		long r;
 
 		node = container_of(it, struct radeon_mn_node, it);
-		it = interval_tree_iter_next(it, start, end);
+		it = interval_tree_iter_next(it, range->start, end);
 
 		list_for_each_entry(bo, &node->bos, mn_list) {
 
diff --git a/drivers/infiniband/core/umem_odp.c b/drivers/infiniband/core/umem_odp.c
index 2aadf5813a40..579e3678c816 100644
--- a/drivers/infiniband/core/umem_odp.c
+++ b/drivers/infiniband/core/umem_odp.c
@@ -208,9 +208,7 @@ static int invalidate_range_start_trampoline(struct ib_umem *item, u64 start,
 }
 
 static void ib_umem_notifier_invalidate_range_start(struct mmu_notifier *mn,
-						    struct mm_struct *mm,
-						    unsigned long start,
-						    unsigned long end)
+						    const struct mmu_notifier_range *range)
 {
 	struct ib_ucontext *context = container_of(mn, struct ib_ucontext, mn);
 
@@ -219,8 +217,8 @@ static void ib_umem_notifier_invalidate_range_start(struct mmu_notifier *mn,
 
 	ib_ucontext_notifier_start_account(context);
 	down_read(&context->umem_rwsem);
-	rbt_ib_umem_for_each_in_range(&context->umem_tree, start,
-				      end,
+	rbt_ib_umem_for_each_in_range(&context->umem_tree, range->start,
+				      range->end,
 				      invalidate_range_start_trampoline, NULL);
 	up_read(&context->umem_rwsem);
 }
@@ -233,9 +231,7 @@ static int invalidate_range_end_trampoline(struct ib_umem *item, u64 start,
 }
 
 static void ib_umem_notifier_invalidate_range_end(struct mmu_notifier *mn,
-						  struct mm_struct *mm,
-						  unsigned long start,
-						  unsigned long end)
+						  const struct mmu_notifier_range *range)
 {
 	struct ib_ucontext *context = container_of(mn, struct ib_ucontext, mn);
 
@@ -243,8 +239,8 @@ static void ib_umem_notifier_invalidate_range_end(struct mmu_notifier *mn,
 		return;
 
 	down_read(&context->umem_rwsem);
-	rbt_ib_umem_for_each_in_range(&context->umem_tree, start,
-				      end,
+	rbt_ib_umem_for_each_in_range(&context->umem_tree, range->start,
+				      range->end,
 				      invalidate_range_end_trampoline, NULL);
 	up_read(&context->umem_rwsem);
 	ib_ucontext_notifier_end_account(context);
diff --git a/drivers/infiniband/hw/hfi1/mmu_rb.c b/drivers/infiniband/hw/hfi1/mmu_rb.c
index 70aceefe14d5..2869e5f32b1e 100644
--- a/drivers/infiniband/hw/hfi1/mmu_rb.c
+++ b/drivers/infiniband/hw/hfi1/mmu_rb.c
@@ -68,8 +68,7 @@ struct mmu_rb_handler {
 static unsigned long mmu_node_start(struct mmu_rb_node *);
 static unsigned long mmu_node_last(struct mmu_rb_node *);
 static void mmu_notifier_range_start(struct mmu_notifier *,
-				     struct mm_struct *,
-				     unsigned long, unsigned long);
+				     const struct mmu_notifier_range *);
 static struct mmu_rb_node *__mmu_rb_search(struct mmu_rb_handler *,
 					   unsigned long, unsigned long);
 static void do_remove(struct mmu_rb_handler *handler,
@@ -285,9 +284,7 @@ void hfi1_mmu_rb_remove(struct mmu_rb_handler *handler,
 }
 
 static void mmu_notifier_range_start(struct mmu_notifier *mn,
-				     struct mm_struct *mm,
-				     unsigned long start,
-				     unsigned long end)
+				     const struct mmu_notifier_range *range)
 {
 	struct mmu_rb_handler *handler =
 		container_of(mn, struct mmu_rb_handler, mn);
@@ -297,10 +294,11 @@ static void mmu_notifier_range_start(struct mmu_notifier *mn,
 	bool added = false;
 
 	spin_lock_irqsave(&handler->lock, flags);
-	for (node = __mmu_int_rb_iter_first(root, start, end - 1);
+	for (node = __mmu_int_rb_iter_first(root, range->start, range->end - 1);
 	     node; node = ptr) {
 		/* Guard against node removal. */
-		ptr = __mmu_int_rb_iter_next(node, start, end - 1);
+		ptr = __mmu_int_rb_iter_next(node, range->start,
+				             range->end - 1);
 		trace_hfi1_mmu_mem_invalidate(node->addr, node->len);
 		if (handler->ops->invalidate(handler->ops_arg, node)) {
 			__mmu_int_rb_remove(node, root);
diff --git a/drivers/misc/mic/scif/scif_dma.c b/drivers/misc/mic/scif/scif_dma.c
index 63d6246d6dff..41f0f2db8287 100644
--- a/drivers/misc/mic/scif/scif_dma.c
+++ b/drivers/misc/mic/scif/scif_dma.c
@@ -201,20 +201,16 @@ static void scif_mmu_notifier_release(struct mmu_notifier *mn,
 }
 
 static void scif_mmu_notifier_invalidate_range_start(struct mmu_notifier *mn,
-						     struct mm_struct *mm,
-						     unsigned long start,
-						     unsigned long end)
+						     const struct mmu_notifier_range *range)
 {
 	struct scif_mmu_notif	*mmn;
 
 	mmn = container_of(mn, struct scif_mmu_notif, ep_mmu_notifier);
-	scif_rma_destroy_tcw(mmn, start, end - start);
+	scif_rma_destroy_tcw(mmn, range->start, range->end - range->start);
 }
 
 static void scif_mmu_notifier_invalidate_range_end(struct mmu_notifier *mn,
-						   struct mm_struct *mm,
-						   unsigned long start,
-						   unsigned long end)
+						   const struct mmu_notifier_range *range)
 {
 	/*
 	 * Nothing to do here, everything needed was done in
diff --git a/drivers/misc/sgi-gru/grutlbpurge.c b/drivers/misc/sgi-gru/grutlbpurge.c
index a3454eb56fbf..5459f6ae60a7 100644
--- a/drivers/misc/sgi-gru/grutlbpurge.c
+++ b/drivers/misc/sgi-gru/grutlbpurge.c
@@ -220,8 +220,7 @@ void gru_flush_all_tlb(struct gru_state *gru)
  * MMUOPS notifier callout functions
  */
 static void gru_invalidate_range_start(struct mmu_notifier *mn,
-				       struct mm_struct *mm,
-				       unsigned long start, unsigned long end)
+				       const struct mmu_notifier_range *range)
 {
 	struct gru_mm_struct *gms = container_of(mn, struct gru_mm_struct,
 						 ms_notifier);
@@ -229,13 +228,12 @@ static void gru_invalidate_range_start(struct mmu_notifier *mn,
 	STAT(mmu_invalidate_range);
 	atomic_inc(&gms->ms_range_active);
 	gru_dbg(grudev, "gms %p, start 0x%lx, end 0x%lx, act %d\n", gms,
-		start, end, atomic_read(&gms->ms_range_active));
-	gru_flush_tlb_range(gms, start, end - start);
+		range->start, range->end, atomic_read(&gms->ms_range_active));
+	gru_flush_tlb_range(gms, range->start, range->end - range->start);
 }
 
 static void gru_invalidate_range_end(struct mmu_notifier *mn,
-				     struct mm_struct *mm, unsigned long start,
-				     unsigned long end)
+				     const struct mmu_notifier_range *range)
 {
 	struct gru_mm_struct *gms = container_of(mn, struct gru_mm_struct,
 						 ms_notifier);
@@ -244,7 +242,8 @@ static void gru_invalidate_range_end(struct mmu_notifier *mn,
 	(void)atomic_dec_and_test(&gms->ms_range_active);
 
 	wake_up_all(&gms->ms_wait_queue);
-	gru_dbg(grudev, "gms %p, start 0x%lx, end 0x%lx\n", gms, start, end);
+	gru_dbg(grudev, "gms %p, start 0x%lx, end 0x%lx\n", gms, range->start,
+		range->end);
 }
 
 static void gru_release(struct mmu_notifier *mn, struct mm_struct *mm)
diff --git a/drivers/xen/gntdev.c b/drivers/xen/gntdev.c
index bd56653b9bbc..6bd6679c797d 100644
--- a/drivers/xen/gntdev.c
+++ b/drivers/xen/gntdev.c
@@ -466,18 +466,17 @@ static void unmap_if_in_range(struct grant_map *map,
 }
 
 static void mn_invl_range_start(struct mmu_notifier *mn,
-				struct mm_struct *mm,
-				unsigned long start, unsigned long end)
+				const struct mmu_notifier_range *range)
 {
 	struct gntdev_priv *priv = container_of(mn, struct gntdev_priv, mn);
 	struct grant_map *map;
 
 	mutex_lock(&priv->lock);
 	list_for_each_entry(map, &priv->maps, next) {
-		unmap_if_in_range(map, start, end);
+		unmap_if_in_range(map, range->start, range->end);
 	}
 	list_for_each_entry(map, &priv->freeable_maps, next) {
-		unmap_if_in_range(map, start, end);
+		unmap_if_in_range(map, range->start, range->end);
 	}
 	mutex_unlock(&priv->lock);
 }
diff --git a/fs/dax.c b/fs/dax.c
index 6ee6f7e24f5a..81f76b23d2fe 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -596,7 +596,8 @@ static void dax_mapping_entry_mkclean(struct address_space *mapping,
 
 	i_mmap_lock_read(mapping);
 	vma_interval_tree_foreach(vma, &mapping->i_mmap, index, index) {
-		unsigned long address, start, end;
+		struct mmu_notifier_range range;
+		unsigned long address;
 
 		cond_resched();
 
@@ -610,7 +611,7 @@ static void dax_mapping_entry_mkclean(struct address_space *mapping,
 		 * call mmu_notifier_invalidate_range_start() on our behalf
 		 * before taking any lock.
 		 */
-		if (follow_pte_pmd(vma->vm_mm, address, &start, &end, &ptep, &pmdp, &ptl))
+		if (follow_pte_pmd(vma->vm_mm, address, &range, &ptep, &pmdp, &ptl))
 			continue;
 
 		/*
@@ -652,7 +653,7 @@ static void dax_mapping_entry_mkclean(struct address_space *mapping,
 			pte_unmap_unlock(ptep, ptl);
 		}
 
-		mmu_notifier_invalidate_range_end(vma->vm_mm, start, end);
+		mmu_notifier_invalidate_range_end(vma->vm_mm, &range);
 	}
 	i_mmap_unlock_read(mapping);
 }
diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index ec6d2983a5cb..43557d75c050 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -1127,6 +1127,7 @@ static ssize_t clear_refs_write(struct file *file, const char __user *buf,
 			.mm = mm,
 			.private = &cp,
 		};
+		struct mmu_notifier_range range;
 
 		if (type == CLEAR_REFS_MM_HIWATER_RSS) {
 			if (down_write_killable(&mm->mmap_sem)) {
@@ -1161,11 +1162,13 @@ static ssize_t clear_refs_write(struct file *file, const char __user *buf,
 				downgrade_write(&mm->mmap_sem);
 				break;
 			}
-			mmu_notifier_invalidate_range_start(mm, 0, -1);
+			range.start = 0;
+			range.end = TASK_SIZE;
+			mmu_notifier_invalidate_range_start(mm, &range);
 		}
 		walk_page_range(0, mm->highest_vm_end, &clear_refs_walk);
 		if (type == CLEAR_REFS_SOFT_DIRTY)
-			mmu_notifier_invalidate_range_end(mm, 0, -1);
+			mmu_notifier_invalidate_range_end(mm, &range);
 		tlb_finish_mmu(&tlb, 0, -1);
 		up_read(&mm->mmap_sem);
 out_mm:
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 89179d0c1d96..e8ecd7307f60 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1317,8 +1317,9 @@ void free_pgd_range(struct mmu_gather *tlb, unsigned long addr,
 		unsigned long end, unsigned long floor, unsigned long ceiling);
 int copy_page_range(struct mm_struct *dst, struct mm_struct *src,
 			struct vm_area_struct *vma);
+struct mmu_notifier_range;
 int follow_pte_pmd(struct mm_struct *mm, unsigned long address,
-			     unsigned long *start, unsigned long *end,
+			     struct mmu_notifier_range *range,
 			     pte_t **ptepp, pmd_t **pmdpp, spinlock_t **ptlp);
 int follow_pfn(struct vm_area_struct *vma, unsigned long address,
 	unsigned long *pfn);
diff --git a/include/linux/mmu_notifier.h b/include/linux/mmu_notifier.h
index 2d07a1ed5a31..4a981daeb0a1 100644
--- a/include/linux/mmu_notifier.h
+++ b/include/linux/mmu_notifier.h
@@ -29,6 +29,18 @@ struct mmu_notifier_mm {
 	spinlock_t lock;
 };
 
+/*
+ * struct mmu_notifier_range - range being invalidated with range_start/end
+ * @mm: mm_struct invalidation is against
+ * @start: start address of range (inclusive)
+ * @end: end address of range (exclusive)
+ */
+struct mmu_notifier_range {
+	struct mm_struct *mm;
+	unsigned long start;
+	unsigned long end;
+};
+
 struct mmu_notifier_ops {
 	/*
 	 * Flags to specify behavior of callbacks for this MMU notifier.
@@ -156,11 +168,9 @@ struct mmu_notifier_ops {
 	 * MMU_INVALIDATE_DOES_NOT_BLOCK set.
 	 */
 	void (*invalidate_range_start)(struct mmu_notifier *mn,
-				       struct mm_struct *mm,
-				       unsigned long start, unsigned long end);
+				       const struct mmu_notifier_range *range);
 	void (*invalidate_range_end)(struct mmu_notifier *mn,
-				     struct mm_struct *mm,
-				     unsigned long start, unsigned long end);
+				     const struct mmu_notifier_range *range);
 
 	/*
 	 * invalidate_range() is either called between
@@ -229,11 +239,10 @@ extern int __mmu_notifier_test_young(struct mm_struct *mm,
 				     unsigned long address);
 extern void __mmu_notifier_change_pte(struct mm_struct *mm,
 				      unsigned long address, pte_t pte);
-extern void __mmu_notifier_invalidate_range_start(struct mm_struct *mm,
-				  unsigned long start, unsigned long end);
-extern void __mmu_notifier_invalidate_range_end(struct mm_struct *mm,
-				  unsigned long start, unsigned long end,
-				  bool only_end);
+extern void __mmu_notifier_invalidate_range_start(
+		struct mmu_notifier_range *range);
+extern void __mmu_notifier_invalidate_range_end(
+		struct mmu_notifier_range *range, bool only_end);
 extern void __mmu_notifier_invalidate_range(struct mm_struct *mm,
 				  unsigned long start, unsigned long end);
 extern bool mm_has_blockable_invalidate_notifiers(struct mm_struct *mm);
@@ -278,24 +287,30 @@ static inline void mmu_notifier_change_pte(struct mm_struct *mm,
 }
 
 static inline void mmu_notifier_invalidate_range_start(struct mm_struct *mm,
-				  unsigned long start, unsigned long end)
+					struct mmu_notifier_range *range)
 {
-	if (mm_has_notifiers(mm))
-		__mmu_notifier_invalidate_range_start(mm, start, end);
+	if (mm_has_notifiers(mm)) {
+		range->mm = mm;
+		__mmu_notifier_invalidate_range_start(range);
+	}
 }
 
 static inline void mmu_notifier_invalidate_range_end(struct mm_struct *mm,
-				  unsigned long start, unsigned long end)
+					struct mmu_notifier_range *range)
 {
-	if (mm_has_notifiers(mm))
-		__mmu_notifier_invalidate_range_end(mm, start, end, false);
+	if (mm_has_notifiers(mm)) {
+		range->mm = mm;
+		__mmu_notifier_invalidate_range_end(range, false);
+	}
 }
 
 static inline void mmu_notifier_invalidate_range_only_end(struct mm_struct *mm,
-				  unsigned long start, unsigned long end)
+					struct mmu_notifier_range *range)
 {
-	if (mm_has_notifiers(mm))
-		__mmu_notifier_invalidate_range_end(mm, start, end, true);
+	if (mm_has_notifiers(mm)) {
+		range->mm = mm;
+		__mmu_notifier_invalidate_range_end(range, true);
+	}
 }
 
 static inline void mmu_notifier_invalidate_range(struct mm_struct *mm,
@@ -429,6 +444,16 @@ extern void mmu_notifier_synchronize(void);
 
 #else /* CONFIG_MMU_NOTIFIER */
 
+/*
+ * struct mmu_notifier_range - range being invalidated with range_start/end
+ * @start: start address of range (inclusive)
+ * @end: end address of range (exclusive)
+ */
+struct mmu_notifier_range {
+	unsigned long start;
+	unsigned long end;
+};
+
 static inline int mm_has_notifiers(struct mm_struct *mm)
 {
 	return 0;
@@ -457,17 +482,17 @@ static inline void mmu_notifier_change_pte(struct mm_struct *mm,
 }
 
 static inline void mmu_notifier_invalidate_range_start(struct mm_struct *mm,
-				  unsigned long start, unsigned long end)
+					struct mmu_notifier_range *range)
 {
 }
 
 static inline void mmu_notifier_invalidate_range_end(struct mm_struct *mm,
-				  unsigned long start, unsigned long end)
+					struct mmu_notifier_range *range)
 {
 }
 
 static inline void mmu_notifier_invalidate_range_only_end(struct mm_struct *mm,
-				  unsigned long start, unsigned long end)
+					struct mmu_notifier_range *range)
 {
 }
 
diff --git a/kernel/events/uprobes.c b/kernel/events/uprobes.c
index 267f6ef91d97..bb80f6251b15 100644
--- a/kernel/events/uprobes.c
+++ b/kernel/events/uprobes.c
@@ -161,9 +161,7 @@ static int __replace_page(struct vm_area_struct *vma, unsigned long addr,
 		.address = addr,
 	};
 	int err;
-	/* For mmu_notifiers */
-	const unsigned long mmun_start = addr;
-	const unsigned long mmun_end   = addr + PAGE_SIZE;
+	struct mmu_notifier_range range;
 	struct mem_cgroup *memcg;
 
 	VM_BUG_ON_PAGE(PageTransHuge(old_page), old_page);
@@ -176,7 +174,9 @@ static int __replace_page(struct vm_area_struct *vma, unsigned long addr,
 	/* For try_to_free_swap() and munlock_vma_page() below */
 	lock_page(old_page);
 
-	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end);
+	range.start = addr;
+	range.end = range.start + PAGE_SIZE;
+	mmu_notifier_invalidate_range_start(mm, &range);
 	err = -EAGAIN;
 	if (!page_vma_mapped_walk(&pvmw)) {
 		mem_cgroup_cancel_charge(new_page, memcg, false);
@@ -210,7 +210,7 @@ static int __replace_page(struct vm_area_struct *vma, unsigned long addr,
 
 	err = 0;
  unlock:
-	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
+	mmu_notifier_invalidate_range_end(mm, &range);
 	unlock_page(old_page);
 	return err;
 }
diff --git a/mm/hmm.c b/mm/hmm.c
index 320545b98ff5..23bdd420bcb2 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -161,11 +161,9 @@ static void hmm_invalidate_range(struct hmm *hmm,
 }
 
 static void hmm_invalidate_range_start(struct mmu_notifier *mn,
-				       struct mm_struct *mm,
-				       unsigned long start,
-				       unsigned long end)
+				       const struct mmu_notifier_range *range)
 {
-	struct hmm *hmm = mm->hmm;
+	struct hmm *hmm = range->mm->hmm;
 
 	VM_BUG_ON(!hmm);
 
@@ -173,15 +171,14 @@ static void hmm_invalidate_range_start(struct mmu_notifier *mn,
 }
 
 static void hmm_invalidate_range_end(struct mmu_notifier *mn,
-				     struct mm_struct *mm,
-				     unsigned long start,
-				     unsigned long end)
+				     const struct mmu_notifier_range *range)
 {
-	struct hmm *hmm = mm->hmm;
+	struct hmm *hmm = range->mm->hmm;
 
 	VM_BUG_ON(!hmm);
 
-	hmm_invalidate_range(mm->hmm, HMM_UPDATE_INVALIDATE, start, end);
+	hmm_invalidate_range(range->mm->hmm, HMM_UPDATE_INVALIDATE,
+			     range->start, range->end);
 }
 
 static const struct mmu_notifier_ops hmm_mmu_notifier_ops = {
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index f2eccca30535..5452698975de 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1132,8 +1132,7 @@ static int do_huge_pmd_wp_page_fallback(struct vm_fault *vmf, pmd_t orig_pmd,
 	pmd_t _pmd;
 	int ret = 0, i;
 	struct page **pages;
-	unsigned long mmun_start;	/* For mmu_notifiers */
-	unsigned long mmun_end;		/* For mmu_notifiers */
+	struct mmu_notifier_range range;
 
 	pages = kmalloc(sizeof(struct page *) * HPAGE_PMD_NR,
 			GFP_KERNEL);
@@ -1171,9 +1170,9 @@ static int do_huge_pmd_wp_page_fallback(struct vm_fault *vmf, pmd_t orig_pmd,
 		cond_resched();
 	}
 
-	mmun_start = haddr;
-	mmun_end   = haddr + HPAGE_PMD_SIZE;
-	mmu_notifier_invalidate_range_start(vma->vm_mm, mmun_start, mmun_end);
+	range.start = haddr;
+	range.end = haddr + HPAGE_PMD_SIZE;
+	mmu_notifier_invalidate_range_start(vma->vm_mm, &range);
 
 	vmf->ptl = pmd_lock(vma->vm_mm, vmf->pmd);
 	if (unlikely(!pmd_same(*vmf->pmd, orig_pmd)))
@@ -1218,8 +1217,7 @@ static int do_huge_pmd_wp_page_fallback(struct vm_fault *vmf, pmd_t orig_pmd,
 	 * No need to double call mmu_notifier->invalidate_range() callback as
 	 * the above pmdp_huge_clear_flush_notify() did already call it.
 	 */
-	mmu_notifier_invalidate_range_only_end(vma->vm_mm, mmun_start,
-						mmun_end);
+	mmu_notifier_invalidate_range_only_end(vma->vm_mm, &range);
 
 	ret |= VM_FAULT_WRITE;
 	put_page(page);
@@ -1229,7 +1227,7 @@ static int do_huge_pmd_wp_page_fallback(struct vm_fault *vmf, pmd_t orig_pmd,
 
 out_free_pages:
 	spin_unlock(vmf->ptl);
-	mmu_notifier_invalidate_range_end(vma->vm_mm, mmun_start, mmun_end);
+	mmu_notifier_invalidate_range_end(vma->vm_mm, &range);
 	for (i = 0; i < HPAGE_PMD_NR; i++) {
 		memcg = (void *)page_private(pages[i]);
 		set_page_private(pages[i], 0);
@@ -1246,8 +1244,7 @@ int do_huge_pmd_wp_page(struct vm_fault *vmf, pmd_t orig_pmd)
 	struct page *page = NULL, *new_page;
 	struct mem_cgroup *memcg;
 	unsigned long haddr = vmf->address & HPAGE_PMD_MASK;
-	unsigned long mmun_start;	/* For mmu_notifiers */
-	unsigned long mmun_end;		/* For mmu_notifiers */
+	struct mmu_notifier_range range;
 	gfp_t huge_gfp;			/* for allocation and charge */
 	int ret = 0;
 
@@ -1335,9 +1332,9 @@ int do_huge_pmd_wp_page(struct vm_fault *vmf, pmd_t orig_pmd)
 		copy_user_huge_page(new_page, page, haddr, vma, HPAGE_PMD_NR);
 	__SetPageUptodate(new_page);
 
-	mmun_start = haddr;
-	mmun_end   = haddr + HPAGE_PMD_SIZE;
-	mmu_notifier_invalidate_range_start(vma->vm_mm, mmun_start, mmun_end);
+	range.start = haddr;
+	range.end = range.start + HPAGE_PMD_SIZE;
+	mmu_notifier_invalidate_range_start(vma->vm_mm, &range);
 
 	spin_lock(vmf->ptl);
 	if (page)
@@ -1372,8 +1369,7 @@ int do_huge_pmd_wp_page(struct vm_fault *vmf, pmd_t orig_pmd)
 	 * No need to double call mmu_notifier->invalidate_range() callback as
 	 * the above pmdp_huge_clear_flush_notify() did already call it.
 	 */
-	mmu_notifier_invalidate_range_only_end(vma->vm_mm, mmun_start,
-					       mmun_end);
+	mmu_notifier_invalidate_range_only_end(vma->vm_mm, &range);
 out:
 	return ret;
 out_unlock:
@@ -2005,13 +2001,15 @@ void __split_huge_pud(struct vm_area_struct *vma, pud_t *pud,
 {
 	spinlock_t *ptl;
 	struct mm_struct *mm = vma->vm_mm;
-	unsigned long haddr = address & HPAGE_PUD_MASK;
+	struct mmu_notifier_range range;
 
-	mmu_notifier_invalidate_range_start(mm, haddr, haddr + HPAGE_PUD_SIZE);
+	range.start = address & HPAGE_PUD_MASK;
+	range.end = range.start + HPAGE_PUD_SIZE;
+	mmu_notifier_invalidate_range_start(mm, &range);
 	ptl = pud_lock(mm, pud);
 	if (unlikely(!pud_trans_huge(*pud) && !pud_devmap(*pud)))
 		goto out;
-	__split_huge_pud_locked(vma, pud, haddr);
+	__split_huge_pud_locked(vma, pud, range.start);
 
 out:
 	spin_unlock(ptl);
@@ -2019,8 +2017,7 @@ void __split_huge_pud(struct vm_area_struct *vma, pud_t *pud,
 	 * No need to double call mmu_notifier->invalidate_range() callback as
 	 * the above pudp_huge_clear_flush_notify() did already call it.
 	 */
-	mmu_notifier_invalidate_range_only_end(mm, haddr, haddr +
-					       HPAGE_PUD_SIZE);
+	mmu_notifier_invalidate_range_only_end(mm, &range);
 }
 #endif /* CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE_PUD */
 
@@ -2219,9 +2216,11 @@ void __split_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
 {
 	spinlock_t *ptl;
 	struct mm_struct *mm = vma->vm_mm;
-	unsigned long haddr = address & HPAGE_PMD_MASK;
+	struct mmu_notifier_range range;
 
-	mmu_notifier_invalidate_range_start(mm, haddr, haddr + HPAGE_PMD_SIZE);
+	range.start = address & HPAGE_PMD_MASK;
+	range.end = range.start + HPAGE_PMD_SIZE;
+	mmu_notifier_invalidate_range_start(mm, &range);
 	ptl = pmd_lock(mm, pmd);
 
 	/*
@@ -2238,7 +2237,7 @@ void __split_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
 			clear_page_mlock(page);
 	} else if (!(pmd_devmap(*pmd) || is_pmd_migration_entry(*pmd)))
 		goto out;
-	__split_huge_pmd_locked(vma, pmd, haddr, freeze);
+	__split_huge_pmd_locked(vma, pmd, range.start, freeze);
 out:
 	spin_unlock(ptl);
 	/*
@@ -2254,8 +2253,7 @@ void __split_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
 	 *     any further changes to individual pte will notify. So no need
 	 *     to call mmu_notifier->invalidate_range()
 	 */
-	mmu_notifier_invalidate_range_only_end(mm, haddr, haddr +
-					       HPAGE_PMD_SIZE);
+	mmu_notifier_invalidate_range_only_end(mm, &range);
 }
 
 void split_huge_pmd_address(struct vm_area_struct *vma, unsigned long address,
@@ -2877,7 +2875,7 @@ void set_pmd_migration_entry(struct page_vma_mapped_walk *pvmw,
 {
 	struct vm_area_struct *vma = pvmw->vma;
 	struct mm_struct *mm = vma->vm_mm;
-	unsigned long address = pvmw->address;
+	struct mmu_notifier_range range;
 	pmd_t pmdval;
 	swp_entry_t entry;
 	pmd_t pmdswp;
@@ -2885,24 +2883,24 @@ void set_pmd_migration_entry(struct page_vma_mapped_walk *pvmw,
 	if (!(pvmw->pmd && !pvmw->pte))
 		return;
 
-	mmu_notifier_invalidate_range_start(mm, address,
-			address + HPAGE_PMD_SIZE);
+	range.start = pvmw->address;
+	range.end = range.start + HPAGE_PMD_SIZE;
+	mmu_notifier_invalidate_range_start(mm, &range);
 
-	flush_cache_range(vma, address, address + HPAGE_PMD_SIZE);
+	flush_cache_range(vma, range.start, range.end);
 	pmdval = *pvmw->pmd;
-	pmdp_invalidate(vma, address, pvmw->pmd);
+	pmdp_invalidate(vma, range.start, pvmw->pmd);
 	if (pmd_dirty(pmdval))
 		set_page_dirty(page);
 	entry = make_migration_entry(page, pmd_write(pmdval));
 	pmdswp = swp_entry_to_pmd(entry);
 	if (pmd_soft_dirty(pmdval))
 		pmdswp = pmd_swp_mksoft_dirty(pmdswp);
-	set_pmd_at(mm, address, pvmw->pmd, pmdswp);
+	set_pmd_at(mm, range.start, pvmw->pmd, pmdswp);
 	page_remove_rmap(page, true);
 	put_page(page);
 
-	mmu_notifier_invalidate_range_end(mm, address,
-			address + HPAGE_PMD_SIZE);
+	mmu_notifier_invalidate_range_end(mm, &range);
 }
 
 void remove_migration_pmd(struct page_vma_mapped_walk *pvmw, struct page *new)
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index d2f6e73e4afb..66674a20fecf 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -3236,16 +3236,15 @@ int copy_hugetlb_page_range(struct mm_struct *dst, struct mm_struct *src,
 	int cow;
 	struct hstate *h = hstate_vma(vma);
 	unsigned long sz = huge_page_size(h);
-	unsigned long mmun_start;	/* For mmu_notifiers */
-	unsigned long mmun_end;		/* For mmu_notifiers */
+	struct mmu_notifier_range range;
 	int ret = 0;
 
 	cow = (vma->vm_flags & (VM_SHARED | VM_MAYWRITE)) == VM_MAYWRITE;
 
-	mmun_start = vma->vm_start;
-	mmun_end = vma->vm_end;
+	range.start = vma->vm_start;
+	range.end = vma->vm_end;
 	if (cow)
-		mmu_notifier_invalidate_range_start(src, mmun_start, mmun_end);
+		mmu_notifier_invalidate_range_start(src, &range);
 
 	for (addr = vma->vm_start; addr < vma->vm_end; addr += sz) {
 		spinlock_t *src_ptl, *dst_ptl;
@@ -3306,7 +3305,7 @@ int copy_hugetlb_page_range(struct mm_struct *dst, struct mm_struct *src,
 	}
 
 	if (cow)
-		mmu_notifier_invalidate_range_end(src, mmun_start, mmun_end);
+		mmu_notifier_invalidate_range_end(src, &range);
 
 	return ret;
 }
@@ -3323,8 +3322,7 @@ void __unmap_hugepage_range(struct mmu_gather *tlb, struct vm_area_struct *vma,
 	struct page *page;
 	struct hstate *h = hstate_vma(vma);
 	unsigned long sz = huge_page_size(h);
-	const unsigned long mmun_start = start;	/* For mmu_notifiers */
-	const unsigned long mmun_end   = end;	/* For mmu_notifiers */
+	struct mmu_notifier_range range;
 
 	WARN_ON(!is_vm_hugetlb_page(vma));
 	BUG_ON(start & ~huge_page_mask(h));
@@ -3336,7 +3334,9 @@ void __unmap_hugepage_range(struct mmu_gather *tlb, struct vm_area_struct *vma,
 	 */
 	tlb_remove_check_page_size_change(tlb, sz);
 	tlb_start_vma(tlb, vma);
-	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end);
+	range.start = start;
+	range.end = end;
+	mmu_notifier_invalidate_range_start(mm, &range);
 	address = start;
 	for (; address < end; address += sz) {
 		ptep = huge_pte_offset(mm, address, sz);
@@ -3400,7 +3400,7 @@ void __unmap_hugepage_range(struct mmu_gather *tlb, struct vm_area_struct *vma,
 		if (ref_page)
 			break;
 	}
-	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
+	mmu_notifier_invalidate_range_end(mm, &range);
 	tlb_end_vma(tlb, vma);
 }
 
@@ -3506,8 +3506,7 @@ static int hugetlb_cow(struct mm_struct *mm, struct vm_area_struct *vma,
 	struct hstate *h = hstate_vma(vma);
 	struct page *old_page, *new_page;
 	int ret = 0, outside_reserve = 0;
-	unsigned long mmun_start;	/* For mmu_notifiers */
-	unsigned long mmun_end;		/* For mmu_notifiers */
+	struct mmu_notifier_range range;
 
 	pte = huge_ptep_get(ptep);
 	old_page = pte_page(pte);
@@ -3588,9 +3587,9 @@ static int hugetlb_cow(struct mm_struct *mm, struct vm_area_struct *vma,
 	__SetPageUptodate(new_page);
 	set_page_huge_active(new_page);
 
-	mmun_start = address & huge_page_mask(h);
-	mmun_end = mmun_start + huge_page_size(h);
-	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end);
+	range.start = address & huge_page_mask(h);
+	range.end = range.start + huge_page_size(h);
+	mmu_notifier_invalidate_range_start(mm, &range);
 
 	/*
 	 * Retake the page table lock to check for racing updates
@@ -3604,7 +3603,7 @@ static int hugetlb_cow(struct mm_struct *mm, struct vm_area_struct *vma,
 
 		/* Break COW */
 		huge_ptep_clear_flush(vma, address, ptep);
-		mmu_notifier_invalidate_range(mm, mmun_start, mmun_end);
+		mmu_notifier_invalidate_range(mm, range.start, range.end);
 		set_huge_pte_at(mm, address, ptep,
 				make_huge_pte(vma, new_page, 1));
 		page_remove_rmap(old_page, true);
@@ -3613,7 +3612,7 @@ static int hugetlb_cow(struct mm_struct *mm, struct vm_area_struct *vma,
 		new_page = old_page;
 	}
 	spin_unlock(ptl);
-	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
+	mmu_notifier_invalidate_range_end(mm, &range);
 out_release_all:
 	restore_reserve_on_error(h, vma, address, new_page);
 	put_page(new_page);
@@ -4294,7 +4293,7 @@ unsigned long hugetlb_change_protection(struct vm_area_struct *vma,
 		unsigned long address, unsigned long end, pgprot_t newprot)
 {
 	struct mm_struct *mm = vma->vm_mm;
-	unsigned long start = address;
+	struct mmu_notifier_range range;
 	pte_t *ptep;
 	pte_t pte;
 	struct hstate *h = hstate_vma(vma);
@@ -4303,7 +4302,9 @@ unsigned long hugetlb_change_protection(struct vm_area_struct *vma,
 	BUG_ON(address >= end);
 	flush_cache_range(vma, address, end);
 
-	mmu_notifier_invalidate_range_start(mm, start, end);
+	range.start = address;
+	range.end = end;
+	mmu_notifier_invalidate_range_start(mm, &range);
 	i_mmap_lock_write(vma->vm_file->f_mapping);
 	for (; address < end; address += huge_page_size(h)) {
 		spinlock_t *ptl;
@@ -4351,7 +4352,7 @@ unsigned long hugetlb_change_protection(struct vm_area_struct *vma,
 	 * once we release i_mmap_rwsem, another task can do the final put_page
 	 * and that page table be reused and filled with junk.
 	 */
-	flush_hugetlb_tlb_range(vma, start, end);
+	flush_hugetlb_tlb_range(vma, range.start, range.end);
 	/*
 	 * No need to call mmu_notifier_invalidate_range() we are downgrading
 	 * page table protection not changing it to point to a new page.
@@ -4359,7 +4360,7 @@ unsigned long hugetlb_change_protection(struct vm_area_struct *vma,
 	 * See Documentation/vm/mmu_notifier.txt
 	 */
 	i_mmap_unlock_write(vma->vm_file->f_mapping);
-	mmu_notifier_invalidate_range_end(mm, start, end);
+	mmu_notifier_invalidate_range_end(mm, &range);
 
 	return pages << h->order;
 }
diff --git a/mm/khugepaged.c b/mm/khugepaged.c
index e42568284e06..4978d21807d4 100644
--- a/mm/khugepaged.c
+++ b/mm/khugepaged.c
@@ -943,8 +943,7 @@ static void collapse_huge_page(struct mm_struct *mm,
 	int isolated = 0, result = 0;
 	struct mem_cgroup *memcg;
 	struct vm_area_struct *vma;
-	unsigned long mmun_start;	/* For mmu_notifiers */
-	unsigned long mmun_end;		/* For mmu_notifiers */
+	struct mmu_notifier_range range;
 	gfp_t gfp;
 
 	VM_BUG_ON(address & ~HPAGE_PMD_MASK);
@@ -1018,9 +1017,9 @@ static void collapse_huge_page(struct mm_struct *mm,
 	pte = pte_offset_map(pmd, address);
 	pte_ptl = pte_lockptr(mm, pmd);
 
-	mmun_start = address;
-	mmun_end   = address + HPAGE_PMD_SIZE;
-	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end);
+	range.start = address;
+	range.end = range.start + HPAGE_PMD_SIZE;
+	mmu_notifier_invalidate_range_start(mm, &range);
 	pmd_ptl = pmd_lock(mm, pmd); /* probably unnecessary */
 	/*
 	 * After this gup_fast can't run anymore. This also removes
@@ -1030,7 +1029,7 @@ static void collapse_huge_page(struct mm_struct *mm,
 	 */
 	_pmd = pmdp_collapse_flush(vma, address, pmd);
 	spin_unlock(pmd_ptl);
-	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
+	mmu_notifier_invalidate_range_end(mm, &range);
 
 	spin_lock(pte_ptl);
 	isolated = __collapse_huge_page_isolate(vma, address, pte);
diff --git a/mm/ksm.c b/mm/ksm.c
index b810839200be..d886f3dd498b 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -1013,14 +1013,13 @@ static int write_protect_page(struct vm_area_struct *vma, struct page *page,
 			      pte_t *orig_pte)
 {
 	struct mm_struct *mm = vma->vm_mm;
+	struct mmu_notifier_range range;
 	struct page_vma_mapped_walk pvmw = {
 		.page = page,
 		.vma = vma,
 	};
 	int swapped;
 	int err = -EFAULT;
-	unsigned long mmun_start;	/* For mmu_notifiers */
-	unsigned long mmun_end;		/* For mmu_notifiers */
 
 	pvmw.address = page_address_in_vma(page, vma);
 	if (pvmw.address == -EFAULT)
@@ -1028,9 +1027,9 @@ static int write_protect_page(struct vm_area_struct *vma, struct page *page,
 
 	BUG_ON(PageTransCompound(page));
 
-	mmun_start = pvmw.address;
-	mmun_end   = pvmw.address + PAGE_SIZE;
-	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end);
+	range.start = pvmw.address;
+	range.end = range.start + PAGE_SIZE;
+	mmu_notifier_invalidate_range_start(mm, &range);
 
 	if (!page_vma_mapped_walk(&pvmw))
 		goto out_mn;
@@ -1082,7 +1081,7 @@ static int write_protect_page(struct vm_area_struct *vma, struct page *page,
 out_unlock:
 	page_vma_mapped_walk_done(&pvmw);
 out_mn:
-	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
+	mmu_notifier_invalidate_range_end(mm, &range);
 out:
 	return err;
 }
@@ -1100,14 +1099,13 @@ static int replace_page(struct vm_area_struct *vma, struct page *page,
 			struct page *kpage, pte_t orig_pte)
 {
 	struct mm_struct *mm = vma->vm_mm;
+	struct mmu_notifier_range range;
 	pmd_t *pmd;
 	pte_t *ptep;
 	pte_t newpte;
 	spinlock_t *ptl;
 	unsigned long addr;
 	int err = -EFAULT;
-	unsigned long mmun_start;	/* For mmu_notifiers */
-	unsigned long mmun_end;		/* For mmu_notifiers */
 
 	addr = page_address_in_vma(page, vma);
 	if (addr == -EFAULT)
@@ -1117,9 +1115,9 @@ static int replace_page(struct vm_area_struct *vma, struct page *page,
 	if (!pmd)
 		goto out;
 
-	mmun_start = addr;
-	mmun_end   = addr + PAGE_SIZE;
-	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end);
+	range.start = addr;
+	range.end = range.start + PAGE_SIZE;
+	mmu_notifier_invalidate_range_start(mm, &range);
 
 	ptep = pte_offset_map_lock(mm, pmd, addr, &ptl);
 	if (!pte_same(*ptep, orig_pte)) {
@@ -1158,7 +1156,7 @@ static int replace_page(struct vm_area_struct *vma, struct page *page,
 	pte_unmap_unlock(ptep, ptl);
 	err = 0;
 out_mn:
-	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
+	mmu_notifier_invalidate_range_end(mm, &range);
 out:
 	return err;
 }
diff --git a/mm/madvise.c b/mm/madvise.c
index 751e97aa2210..6ef485907a30 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -458,29 +458,29 @@ static void madvise_free_page_range(struct mmu_gather *tlb,
 static int madvise_free_single_vma(struct vm_area_struct *vma,
 			unsigned long start_addr, unsigned long end_addr)
 {
-	unsigned long start, end;
 	struct mm_struct *mm = vma->vm_mm;
+	struct mmu_notifier_range range;
 	struct mmu_gather tlb;
 
 	/* MADV_FREE works for only anon vma at the moment */
 	if (!vma_is_anonymous(vma))
 		return -EINVAL;
 
-	start = max(vma->vm_start, start_addr);
-	if (start >= vma->vm_end)
+	range.start = max(vma->vm_start, start_addr);
+	if (range.start >= vma->vm_end)
 		return -EINVAL;
-	end = min(vma->vm_end, end_addr);
-	if (end <= vma->vm_start)
+	range.end = min(vma->vm_end, end_addr);
+	if (range.end <= vma->vm_start)
 		return -EINVAL;
 
 	lru_add_drain();
-	tlb_gather_mmu(&tlb, mm, start, end);
+	tlb_gather_mmu(&tlb, mm, range.start, range.end);
 	update_hiwater_rss(mm);
 
-	mmu_notifier_invalidate_range_start(mm, start, end);
-	madvise_free_page_range(&tlb, vma, start, end);
-	mmu_notifier_invalidate_range_end(mm, start, end);
-	tlb_finish_mmu(&tlb, start, end);
+	mmu_notifier_invalidate_range_start(mm, &range);
+	madvise_free_page_range(&tlb, vma, range.start, range.end);
+	mmu_notifier_invalidate_range_end(mm, &range);
+	tlb_finish_mmu(&tlb, range.start, range.end);
 
 	return 0;
 }
diff --git a/mm/memory.c b/mm/memory.c
index ba7453a66e04..020c7219d2cd 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1219,8 +1219,7 @@ int copy_page_range(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 	unsigned long next;
 	unsigned long addr = vma->vm_start;
 	unsigned long end = vma->vm_end;
-	unsigned long mmun_start;	/* For mmu_notifiers */
-	unsigned long mmun_end;		/* For mmu_notifiers */
+	struct mmu_notifier_range range;
 	bool is_cow;
 	int ret;
 
@@ -1254,11 +1253,10 @@ int copy_page_range(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 	 * is_cow_mapping() returns true.
 	 */
 	is_cow = is_cow_mapping(vma->vm_flags);
-	mmun_start = addr;
-	mmun_end   = end;
+	range.start = addr;
+	range.end = end;
 	if (is_cow)
-		mmu_notifier_invalidate_range_start(src_mm, mmun_start,
-						    mmun_end);
+		mmu_notifier_invalidate_range_start(src_mm, &range);
 
 	ret = 0;
 	dst_pgd = pgd_offset(dst_mm, addr);
@@ -1275,7 +1273,7 @@ int copy_page_range(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 	} while (dst_pgd++, src_pgd++, addr = next, addr != end);
 
 	if (is_cow)
-		mmu_notifier_invalidate_range_end(src_mm, mmun_start, mmun_end);
+		mmu_notifier_invalidate_range_end(src_mm, &range);
 	return ret;
 }
 
@@ -1581,11 +1579,14 @@ void unmap_vmas(struct mmu_gather *tlb,
 		unsigned long end_addr)
 {
 	struct mm_struct *mm = vma->vm_mm;
+	struct mmu_notifier_range range;
 
-	mmu_notifier_invalidate_range_start(mm, start_addr, end_addr);
+	range.start = start_addr;
+	range.end = end_addr;
+	mmu_notifier_invalidate_range_start(mm, &range);
 	for ( ; vma && vma->vm_start < end_addr; vma = vma->vm_next)
 		unmap_single_vma(tlb, vma, start_addr, end_addr, NULL);
-	mmu_notifier_invalidate_range_end(mm, start_addr, end_addr);
+	mmu_notifier_invalidate_range_end(mm, &range);
 }
 
 /**
@@ -1600,15 +1601,17 @@ void zap_page_range(struct vm_area_struct *vma, unsigned long start,
 		unsigned long size)
 {
 	struct mm_struct *mm = vma->vm_mm;
+	struct mmu_notifier_range range;
 	struct mmu_gather tlb;
-	unsigned long end = start + size;
 
 	lru_add_drain();
-	tlb_gather_mmu(&tlb, mm, start, end);
+	range.start = start;
+	range.end = start + size;
+	tlb_gather_mmu(&tlb, mm, range.start, range.end);
 	update_hiwater_rss(mm);
-	mmu_notifier_invalidate_range_start(mm, start, end);
-	for ( ; vma && vma->vm_start < end; vma = vma->vm_next) {
-		unmap_single_vma(&tlb, vma, start, end, NULL);
+	mmu_notifier_invalidate_range_start(mm, &range);
+	for ( ; vma && vma->vm_start < range.end; vma = vma->vm_next) {
+		unmap_single_vma(&tlb, vma, range.start, range.end, NULL);
 
 		/*
 		 * zap_page_range does not specify whether mmap_sem should be
@@ -1618,11 +1621,11 @@ void zap_page_range(struct vm_area_struct *vma, unsigned long start,
 		 * Rather than adding a complex API, ensure that no stale
 		 * TLB entries exist when this call returns.
 		 */
-		flush_tlb_range(vma, start, end);
+		flush_tlb_range(vma, range.start, range.end);
 	}
 
-	mmu_notifier_invalidate_range_end(mm, start, end);
-	tlb_finish_mmu(&tlb, start, end);
+	mmu_notifier_invalidate_range_end(mm, &range);
+	tlb_finish_mmu(&tlb, range.start, range.end);
 }
 
 /**
@@ -1638,16 +1641,18 @@ static void zap_page_range_single(struct vm_area_struct *vma, unsigned long addr
 		unsigned long size, struct zap_details *details)
 {
 	struct mm_struct *mm = vma->vm_mm;
+	struct mmu_notifier_range range;
 	struct mmu_gather tlb;
-	unsigned long end = address + size;
 
 	lru_add_drain();
-	tlb_gather_mmu(&tlb, mm, address, end);
+	range.start = address;
+	range.end = address + size;
+	tlb_gather_mmu(&tlb, mm, range.start, range.end);
 	update_hiwater_rss(mm);
-	mmu_notifier_invalidate_range_start(mm, address, end);
-	unmap_single_vma(&tlb, vma, address, end, details);
-	mmu_notifier_invalidate_range_end(mm, address, end);
-	tlb_finish_mmu(&tlb, address, end);
+	mmu_notifier_invalidate_range_start(mm, &range);
+	unmap_single_vma(&tlb, vma, range.start, range.end, details);
+	mmu_notifier_invalidate_range_end(mm, &range);
+	tlb_finish_mmu(&tlb, range.start, range.end);
 }
 
 /**
@@ -2471,11 +2476,10 @@ static int wp_page_copy(struct vm_fault *vmf)
 	struct vm_area_struct *vma = vmf->vma;
 	struct mm_struct *mm = vma->vm_mm;
 	struct page *old_page = vmf->page;
+	struct mmu_notifier_range range;
 	struct page *new_page = NULL;
 	pte_t entry;
 	int page_copied = 0;
-	const unsigned long mmun_start = vmf->address & PAGE_MASK;
-	const unsigned long mmun_end = mmun_start + PAGE_SIZE;
 	struct mem_cgroup *memcg;
 
 	if (unlikely(anon_vma_prepare(vma)))
@@ -2499,7 +2503,9 @@ static int wp_page_copy(struct vm_fault *vmf)
 
 	__SetPageUptodate(new_page);
 
-	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end);
+	range.start = vmf->address & PAGE_MASK;
+	range.end = range.start + PAGE_SIZE;
+	mmu_notifier_invalidate_range_start(mm, &range);
 
 	/*
 	 * Re-check the pte - we dropped the lock
@@ -2576,7 +2582,7 @@ static int wp_page_copy(struct vm_fault *vmf)
 	 * No need to double call mmu_notifier->invalidate_range() callback as
 	 * the above ptep_clear_flush_notify() did already call it.
 	 */
-	mmu_notifier_invalidate_range_only_end(mm, mmun_start, mmun_end);
+	mmu_notifier_invalidate_range_only_end(mm, &range);
 	if (old_page) {
 		/*
 		 * Don't let another task, with possibly unlocked vma,
@@ -4227,7 +4233,7 @@ int __pmd_alloc(struct mm_struct *mm, pud_t *pud, unsigned long address)
 #endif /* __PAGETABLE_PMD_FOLDED */
 
 static int __follow_pte_pmd(struct mm_struct *mm, unsigned long address,
-			    unsigned long *start, unsigned long *end,
+			    struct mmu_notifier_range *range,
 			    pte_t **ptepp, pmd_t **pmdpp, spinlock_t **ptlp)
 {
 	pgd_t *pgd;
@@ -4255,10 +4261,10 @@ static int __follow_pte_pmd(struct mm_struct *mm, unsigned long address,
 		if (!pmdpp)
 			goto out;
 
-		if (start && end) {
-			*start = address & PMD_MASK;
-			*end = *start + PMD_SIZE;
-			mmu_notifier_invalidate_range_start(mm, *start, *end);
+		if (range) {
+			range->start = address & PMD_MASK;
+			range->end = range->start + PMD_SIZE;
+			mmu_notifier_invalidate_range_start(mm, range);
 		}
 		*ptlp = pmd_lock(mm, pmd);
 		if (pmd_huge(*pmd)) {
@@ -4266,17 +4272,17 @@ static int __follow_pte_pmd(struct mm_struct *mm, unsigned long address,
 			return 0;
 		}
 		spin_unlock(*ptlp);
-		if (start && end)
-			mmu_notifier_invalidate_range_end(mm, *start, *end);
+		if (range)
+			mmu_notifier_invalidate_range_end(mm, range);
 	}
 
 	if (pmd_none(*pmd) || unlikely(pmd_bad(*pmd)))
 		goto out;
 
-	if (start && end) {
-		*start = address & PAGE_MASK;
-		*end = *start + PAGE_SIZE;
-		mmu_notifier_invalidate_range_start(mm, *start, *end);
+	if (range) {
+		range->start = address & PAGE_MASK;
+		range->end = range->start + PAGE_SIZE;
+		mmu_notifier_invalidate_range_start(mm, range);
 	}
 	ptep = pte_offset_map_lock(mm, pmd, address, ptlp);
 	if (!pte_present(*ptep))
@@ -4285,8 +4291,8 @@ static int __follow_pte_pmd(struct mm_struct *mm, unsigned long address,
 	return 0;
 unlock:
 	pte_unmap_unlock(ptep, *ptlp);
-	if (start && end)
-		mmu_notifier_invalidate_range_end(mm, *start, *end);
+	if (range)
+		mmu_notifier_invalidate_range_end(mm, range);
 out:
 	return -EINVAL;
 }
@@ -4298,20 +4304,20 @@ static inline int follow_pte(struct mm_struct *mm, unsigned long address,
 
 	/* (void) is needed to make gcc happy */
 	(void) __cond_lock(*ptlp,
-			   !(res = __follow_pte_pmd(mm, address, NULL, NULL,
+			   !(res = __follow_pte_pmd(mm, address, NULL,
 						    ptepp, NULL, ptlp)));
 	return res;
 }
 
 int follow_pte_pmd(struct mm_struct *mm, unsigned long address,
-			     unsigned long *start, unsigned long *end,
+			     struct mmu_notifier_range *range,
 			     pte_t **ptepp, pmd_t **pmdpp, spinlock_t **ptlp)
 {
 	int res;
 
 	/* (void) is needed to make gcc happy */
 	(void) __cond_lock(*ptlp,
-			   !(res = __follow_pte_pmd(mm, address, start, end,
+			   !(res = __follow_pte_pmd(mm, address, range,
 						    ptepp, pmdpp, ptlp)));
 	return res;
 }
diff --git a/mm/migrate.c b/mm/migrate.c
index 5d0dc7b85f90..b34407867ee4 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1967,8 +1967,7 @@ int migrate_misplaced_transhuge_page(struct mm_struct *mm,
 	int isolated = 0;
 	struct page *new_page = NULL;
 	int page_lru = page_is_file_cache(page);
-	unsigned long mmun_start = address & HPAGE_PMD_MASK;
-	unsigned long mmun_end = mmun_start + HPAGE_PMD_SIZE;
+	struct mmu_notifier_range range;
 
 	/*
 	 * Rate-limit the amount of data that is being migrated to a node.
@@ -2003,11 +2002,13 @@ int migrate_misplaced_transhuge_page(struct mm_struct *mm,
 	WARN_ON(PageLRU(new_page));
 
 	/* Recheck the target PMD */
-	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end);
+	range.start = address & HPAGE_PMD_MASK;
+	range.end = range.start + HPAGE_PMD_SIZE;
+	mmu_notifier_invalidate_range_start(mm, &range);
 	ptl = pmd_lock(mm, pmd);
 	if (unlikely(!pmd_same(*pmd, entry) || !page_ref_freeze(page, 2))) {
 		spin_unlock(ptl);
-		mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
+		mmu_notifier_invalidate_range_end(mm, &range);
 
 		/* Reverse changes made by migrate_page_copy() */
 		if (TestClearPageActive(new_page))
@@ -2037,10 +2038,10 @@ int migrate_misplaced_transhuge_page(struct mm_struct *mm,
 	 * The SetPageUptodate on the new page and page_add_new_anon_rmap
 	 * guarantee the copy is visible before the pagetable update.
 	 */
-	flush_cache_range(vma, mmun_start, mmun_end);
-	page_add_anon_rmap(new_page, vma, mmun_start, true);
-	pmdp_huge_clear_flush_notify(vma, mmun_start, pmd);
-	set_pmd_at(mm, mmun_start, pmd, entry);
+	flush_cache_range(vma, range.start, range.end);
+	page_add_anon_rmap(new_page, vma, range.start, true);
+	pmdp_huge_clear_flush_notify(vma, range.start, pmd);
+	set_pmd_at(mm, range.start, pmd, entry);
 	update_mmu_cache_pmd(vma, address, &entry);
 
 	page_ref_unfreeze(page, 2);
@@ -2053,7 +2054,7 @@ int migrate_misplaced_transhuge_page(struct mm_struct *mm,
 	 * No need to double call mmu_notifier->invalidate_range() callback as
 	 * the above pmdp_huge_clear_flush_notify() did already call it.
 	 */
-	mmu_notifier_invalidate_range_only_end(mm, mmun_start, mmun_end);
+	mmu_notifier_invalidate_range_only_end(mm, &range);
 
 	/* Take an "isolate" reference and put new page on the LRU. */
 	get_page(new_page);
@@ -2078,7 +2079,7 @@ int migrate_misplaced_transhuge_page(struct mm_struct *mm,
 	ptl = pmd_lock(mm, pmd);
 	if (pmd_same(*pmd, entry)) {
 		entry = pmd_modify(entry, vma->vm_page_prot);
-		set_pmd_at(mm, mmun_start, pmd, entry);
+		set_pmd_at(mm, range.start, pmd, entry);
 		update_mmu_cache_pmd(vma, address, &entry);
 	}
 	spin_unlock(ptl);
@@ -2311,6 +2312,7 @@ static int migrate_vma_collect_pmd(pmd_t *pmdp,
  */
 static void migrate_vma_collect(struct migrate_vma *migrate)
 {
+	struct mmu_notifier_range range;
 	struct mm_walk mm_walk;
 
 	mm_walk.pmd_entry = migrate_vma_collect_pmd;
@@ -2322,13 +2324,11 @@ static void migrate_vma_collect(struct migrate_vma *migrate)
 	mm_walk.mm = migrate->vma->vm_mm;
 	mm_walk.private = migrate;
 
-	mmu_notifier_invalidate_range_start(mm_walk.mm,
-					    migrate->start,
-					    migrate->end);
+	range.start = migrate->start;
+	range.end = migrate->end;
+	mmu_notifier_invalidate_range_start(mm_walk.mm, &range);
 	walk_page_range(migrate->start, migrate->end, &mm_walk);
-	mmu_notifier_invalidate_range_end(mm_walk.mm,
-					  migrate->start,
-					  migrate->end);
+	mmu_notifier_invalidate_range_end(mm_walk.mm, &range);
 
 	migrate->end = migrate->start + (migrate->npages << PAGE_SHIFT);
 }
@@ -2711,7 +2711,8 @@ static void migrate_vma_pages(struct migrate_vma *migrate)
 	const unsigned long start = migrate->start;
 	struct vm_area_struct *vma = migrate->vma;
 	struct mm_struct *mm = vma->vm_mm;
-	unsigned long addr, i, mmu_start;
+	struct mmu_notifier_range range;
+	unsigned long addr, i;
 	bool notified = false;
 
 	for (i = 0, addr = start; i < npages; addr += PAGE_SIZE, i++) {
@@ -2730,11 +2731,11 @@ static void migrate_vma_pages(struct migrate_vma *migrate)
 				continue;
 			}
 			if (!notified) {
-				mmu_start = addr;
+				range.start = addr;
+				range.end = addr + ((npages - i) << PAGE_SHIFT);
 				notified = true;
 				mmu_notifier_invalidate_range_start(mm,
-								mmu_start,
-								migrate->end);
+								    &range);
 			}
 			migrate_vma_insert_page(migrate, addr, newpage,
 						&migrate->src[i],
@@ -2775,8 +2776,7 @@ static void migrate_vma_pages(struct migrate_vma *migrate)
 	 * did already call it.
 	 */
 	if (notified)
-		mmu_notifier_invalidate_range_only_end(mm, mmu_start,
-						       migrate->end);
+		mmu_notifier_invalidate_range_only_end(mm, &range);
 }
 
 /*
diff --git a/mm/mmu_notifier.c b/mm/mmu_notifier.c
index eff6b88a993f..91a614b9636e 100644
--- a/mm/mmu_notifier.c
+++ b/mm/mmu_notifier.c
@@ -174,26 +174,25 @@ void __mmu_notifier_change_pte(struct mm_struct *mm, unsigned long address,
 	srcu_read_unlock(&srcu, id);
 }
 
-void __mmu_notifier_invalidate_range_start(struct mm_struct *mm,
-				  unsigned long start, unsigned long end)
+void __mmu_notifier_invalidate_range_start(struct mmu_notifier_range *range)
 {
+	struct mm_struct *mm = range->mm;
 	struct mmu_notifier *mn;
 	int id;
 
 	id = srcu_read_lock(&srcu);
 	hlist_for_each_entry_rcu(mn, &mm->mmu_notifier_mm->list, hlist) {
 		if (mn->ops->invalidate_range_start)
-			mn->ops->invalidate_range_start(mn, mm, start, end);
+			mn->ops->invalidate_range_start(mn, range);
 	}
 	srcu_read_unlock(&srcu, id);
 }
 EXPORT_SYMBOL_GPL(__mmu_notifier_invalidate_range_start);
 
-void __mmu_notifier_invalidate_range_end(struct mm_struct *mm,
-					 unsigned long start,
-					 unsigned long end,
+void __mmu_notifier_invalidate_range_end(struct mmu_notifier_range *range,
 					 bool only_end)
 {
+	struct mm_struct *mm = range->mm;
 	struct mmu_notifier *mn;
 	int id;
 
@@ -213,9 +212,10 @@ void __mmu_notifier_invalidate_range_end(struct mm_struct *mm,
 		 * already happen under page table lock.
 		 */
 		if (!only_end && mn->ops->invalidate_range)
-			mn->ops->invalidate_range(mn, mm, start, end);
+			mn->ops->invalidate_range(mn, mm, range->start,
+						  range->end);
 		if (mn->ops->invalidate_range_end)
-			mn->ops->invalidate_range_end(mn, mm, start, end);
+			mn->ops->invalidate_range_end(mn, range);
 	}
 	srcu_read_unlock(&srcu, id);
 }
diff --git a/mm/mprotect.c b/mm/mprotect.c
index e3309fcf586b..cf2661c1ad46 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -162,7 +162,7 @@ static inline unsigned long change_pmd_range(struct vm_area_struct *vma,
 	unsigned long next;
 	unsigned long pages = 0;
 	unsigned long nr_huge_updates = 0;
-	unsigned long mni_start = 0;
+	struct mmu_notifier_range range = {0};
 
 	pmd = pmd_offset(pud, addr);
 	do {
@@ -174,9 +174,10 @@ static inline unsigned long change_pmd_range(struct vm_area_struct *vma,
 			goto next;
 
 		/* invoke the mmu notifier if the pmd is populated */
-		if (!mni_start) {
-			mni_start = addr;
-			mmu_notifier_invalidate_range_start(mm, mni_start, end);
+		if (!range.start) {
+			range.start = addr;
+			range.end = end;
+			mmu_notifier_invalidate_range_start(mm, &range);
 		}
 
 		if (is_swap_pmd(*pmd) || pmd_trans_huge(*pmd) || pmd_devmap(*pmd)) {
@@ -205,8 +206,8 @@ static inline unsigned long change_pmd_range(struct vm_area_struct *vma,
 		cond_resched();
 	} while (pmd++, addr = next, addr != end);
 
-	if (mni_start)
-		mmu_notifier_invalidate_range_end(mm, mni_start, end);
+	if (range.start)
+		mmu_notifier_invalidate_range_end(mm, &range);
 
 	if (nr_huge_updates)
 		count_vm_numa_events(NUMA_HUGE_PTE_UPDATES, nr_huge_updates);
diff --git a/mm/mremap.c b/mm/mremap.c
index 049470aa1e3e..d7c25c93ebb2 100644
--- a/mm/mremap.c
+++ b/mm/mremap.c
@@ -201,15 +201,14 @@ unsigned long move_page_tables(struct vm_area_struct *vma,
 	unsigned long extent, next, old_end;
 	pmd_t *old_pmd, *new_pmd;
 	bool need_flush = false;
-	unsigned long mmun_start;	/* For mmu_notifiers */
-	unsigned long mmun_end;		/* For mmu_notifiers */
+	struct mmu_notifier_range range;
 
 	old_end = old_addr + len;
 	flush_cache_range(vma, old_addr, old_end);
 
-	mmun_start = old_addr;
-	mmun_end   = old_end;
-	mmu_notifier_invalidate_range_start(vma->vm_mm, mmun_start, mmun_end);
+	range.start = old_addr;
+	range.end = old_end;
+	mmu_notifier_invalidate_range_start(vma->vm_mm, &range);
 
 	for (; old_addr < old_end; old_addr += extent, new_addr += extent) {
 		cond_resched();
@@ -255,7 +254,7 @@ unsigned long move_page_tables(struct vm_area_struct *vma,
 	if (need_flush)
 		flush_tlb_range(vma, old_end-len, old_addr);
 
-	mmu_notifier_invalidate_range_end(vma->vm_mm, mmun_start, mmun_end);
+	mmu_notifier_invalidate_range_end(vma->vm_mm, &range);
 
 	return len + old_addr - old_end;	/* how much done */
 }
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index dfd370526909..268e00bcf988 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -557,14 +557,16 @@ static bool __oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
 		 * count elevated without a good reason.
 		 */
 		if (vma_is_anonymous(vma) || !(vma->vm_flags & VM_SHARED)) {
-			const unsigned long start = vma->vm_start;
-			const unsigned long end = vma->vm_end;
-
-			tlb_gather_mmu(&tlb, mm, start, end);
-			mmu_notifier_invalidate_range_start(mm, start, end);
-			unmap_page_range(&tlb, vma, start, end, NULL);
-			mmu_notifier_invalidate_range_end(mm, start, end);
-			tlb_finish_mmu(&tlb, start, end);
+			struct mmu_notifier_range range;
+
+			range.start = vma->vm_start;
+			range.end = vma->vm_end;
+			tlb_gather_mmu(&tlb, mm, range.start, range.end);
+			mmu_notifier_invalidate_range_start(mm, &range);
+			unmap_page_range(&tlb, vma, range.start,
+					 range.end, NULL);
+			mmu_notifier_invalidate_range_end(mm, &range);
+			tlb_finish_mmu(&tlb, range.start, range.end);
 		}
 	}
 	pr_info("oom_reaper: reaped process %d (%s), now anon-rss:%lukB, file-rss:%lukB, shmem-rss:%lukB\n",
diff --git a/mm/rmap.c b/mm/rmap.c
index 9eaa6354fe70..7fbd32966ab4 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -888,15 +888,17 @@ static bool page_mkclean_one(struct page *page, struct vm_area_struct *vma,
 		.address = address,
 		.flags = PVMW_SYNC,
 	};
-	unsigned long start = address, end;
+	struct mmu_notifier_range range;
 	int *cleaned = arg;
 
 	/*
 	 * We have to assume the worse case ie pmd for invalidation. Note that
 	 * the page can not be free from this function.
 	 */
-	end = min(vma->vm_end, start + (PAGE_SIZE << compound_order(page)));
-	mmu_notifier_invalidate_range_start(vma->vm_mm, start, end);
+	range.start = address;
+	range.end = min(vma->vm_end, range.start +
+			(PAGE_SIZE << compound_order(page)));
+	mmu_notifier_invalidate_range_start(vma->vm_mm, &range);
 
 	while (page_vma_mapped_walk(&pvmw)) {
 		unsigned long cstart;
@@ -948,7 +950,7 @@ static bool page_mkclean_one(struct page *page, struct vm_area_struct *vma,
 			(*cleaned)++;
 	}
 
-	mmu_notifier_invalidate_range_end(vma->vm_mm, start, end);
+	mmu_notifier_invalidate_range_end(vma->vm_mm, &range);
 
 	return true;
 }
@@ -1344,7 +1346,7 @@ static bool try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 	pte_t pteval;
 	struct page *subpage;
 	bool ret = true;
-	unsigned long start = address, end;
+	struct mmu_notifier_range range;
 	enum ttu_flags flags = (enum ttu_flags)arg;
 
 	/* munlock has nothing to gain from examining un-locked vmas */
@@ -1365,8 +1367,10 @@ static bool try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 	 * the page can not be free in this function as call of try_to_unmap()
 	 * must hold a reference on the page.
 	 */
-	end = min(vma->vm_end, start + (PAGE_SIZE << compound_order(page)));
-	mmu_notifier_invalidate_range_start(vma->vm_mm, start, end);
+	range.start = address;
+	range.end = min(vma->vm_end,
+			range.start + (PAGE_SIZE << compound_order(page)));
+	mmu_notifier_invalidate_range_start(vma->vm_mm, &range);
 
 	while (page_vma_mapped_walk(&pvmw)) {
 #ifdef CONFIG_ARCH_ENABLE_THP_MIGRATION
@@ -1604,7 +1608,7 @@ static bool try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 		put_page(page);
 	}
 
-	mmu_notifier_invalidate_range_end(vma->vm_mm, start, end);
+	mmu_notifier_invalidate_range_end(vma->vm_mm, &range);
 
 	return ret;
 }
diff --git a/virt/kvm/kvm_main.c b/virt/kvm/kvm_main.c
index a78ebc51294e..138ec2ea4aba 100644
--- a/virt/kvm/kvm_main.c
+++ b/virt/kvm/kvm_main.c
@@ -343,9 +343,7 @@ static void kvm_mmu_notifier_change_pte(struct mmu_notifier *mn,
 }
 
 static void kvm_mmu_notifier_invalidate_range_start(struct mmu_notifier *mn,
-						    struct mm_struct *mm,
-						    unsigned long start,
-						    unsigned long end)
+						    const struct mmu_notifier_range *range)
 {
 	struct kvm *kvm = mmu_notifier_to_kvm(mn);
 	int need_tlb_flush = 0, idx;
@@ -358,7 +356,7 @@ static void kvm_mmu_notifier_invalidate_range_start(struct mmu_notifier *mn,
 	 * count is also read inside the mmu_lock critical section.
 	 */
 	kvm->mmu_notifier_count++;
-	need_tlb_flush = kvm_unmap_hva_range(kvm, start, end);
+	need_tlb_flush = kvm_unmap_hva_range(kvm, range->start, range->end);
 	need_tlb_flush |= kvm->tlbs_dirty;
 	/* we've to flush the tlb before the pages can be freed */
 	if (need_tlb_flush)
@@ -366,15 +364,13 @@ static void kvm_mmu_notifier_invalidate_range_start(struct mmu_notifier *mn,
 
 	spin_unlock(&kvm->mmu_lock);
 
-	kvm_arch_mmu_notifier_invalidate_range(kvm, start, end);
+	kvm_arch_mmu_notifier_invalidate_range(kvm, range->start, range->end);
 
 	srcu_read_unlock(&kvm->srcu, idx);
 }
 
 static void kvm_mmu_notifier_invalidate_range_end(struct mmu_notifier *mn,
-						  struct mm_struct *mm,
-						  unsigned long start,
-						  unsigned long end)
+						  const struct mmu_notifier_range *range)
 {
 	struct kvm *kvm = mmu_notifier_to_kvm(mn);
 
-- 
2.14.3
