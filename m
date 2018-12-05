Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id AB1E26B72B5
	for <linux-mm@kvack.org>; Wed,  5 Dec 2018 00:37:10 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id q33so19385581qte.23
        for <linux-mm@kvack.org>; Tue, 04 Dec 2018 21:37:10 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id d13si3921692qtr.234.2018.12.04.21.37.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Dec 2018 21:37:09 -0800 (PST)
From: jglisse@redhat.com
Subject: [PATCH v2 1/3] mm/mmu_notifier: use structure for invalidate_range_start/end callback
Date: Wed,  5 Dec 2018 00:36:26 -0500
Message-Id: <20181205053628.3210-2-jglisse@redhat.com>
In-Reply-To: <20181205053628.3210-1-jglisse@redhat.com>
References: <20181205053628.3210-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Matthew Wilcox <mawilcox@microsoft.com>, Ross Zwisler <zwisler@kernel.org>, Jan Kara <jack@suse.cz>, Dan Williams <dan.j.williams@intel.com>, Paolo Bonzini <pbonzini@redhat.com>, =?UTF-8?q?Radim=20Kr=C4=8Dm=C3=A1=C5=99?= <rkrcmar@redhat.com>, Michal Hocko <mhocko@kernel.org>, Christian Koenig <christian.koenig@amd.com>, Felix Kuehling <felix.kuehling@amd.com>, Ralph Campbell <rcampbell@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, kvm@vger.kernel.org, dri-devel@lists.freedesktop.org, linux-rdma@vger.kernel.org, linux-fsdevel@vger.kernel.org

From: Jérôme Glisse <jglisse@redhat.com>

To avoid having to change many callback definition everytime we want
to add a parameter use a structure to group all parameters for the
mmu_notifier invalidate_range_start/end callback. No functional changes
with this patch.

Signed-off-by: Jérôme Glisse <jglisse@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <mawilcox@microsoft.com>
Cc: Ross Zwisler <zwisler@kernel.org>
Cc: Jan Kara <jack@suse.cz>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Paolo Bonzini <pbonzini@redhat.com>
Cc: Radim Krčmář <rkrcmar@redhat.com>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Christian Koenig <christian.koenig@amd.com>
Cc: Felix Kuehling <felix.kuehling@amd.com>
Cc: Ralph Campbell <rcampbell@nvidia.com>
Cc: John Hubbard <jhubbard@nvidia.com>
Cc: kvm@vger.kernel.org
Cc: dri-devel@lists.freedesktop.org
Cc: linux-rdma@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org
---
 drivers/gpu/drm/amd/amdgpu/amdgpu_mn.c  | 43 +++++++++++--------------
 drivers/gpu/drm/i915/i915_gem_userptr.c | 14 ++++----
 drivers/gpu/drm/radeon/radeon_mn.c      | 16 ++++-----
 drivers/infiniband/core/umem_odp.c      | 20 +++++-------
 drivers/infiniband/hw/hfi1/mmu_rb.c     | 13 +++-----
 drivers/misc/mic/scif/scif_dma.c        | 11 ++-----
 drivers/misc/sgi-gru/grutlbpurge.c      | 14 ++++----
 drivers/xen/gntdev.c                    | 12 +++----
 include/linux/mmu_notifier.h            | 14 +++++---
 mm/hmm.c                                | 23 ++++++-------
 mm/mmu_notifier.c                       | 21 ++++++++++--
 virt/kvm/kvm_main.c                     | 14 +++-----
 12 files changed, 102 insertions(+), 113 deletions(-)

diff --git a/drivers/gpu/drm/amd/amdgpu/amdgpu_mn.c b/drivers/gpu/drm/amd/amdgpu/amdgpu_mn.c
index e55508b39496..5bc7e59a05a1 100644
--- a/drivers/gpu/drm/amd/amdgpu/amdgpu_mn.c
+++ b/drivers/gpu/drm/amd/amdgpu/amdgpu_mn.c
@@ -246,36 +246,34 @@ static void amdgpu_mn_invalidate_node(struct amdgpu_mn_node *node,
  * potentially dirty.
  */
 static int amdgpu_mn_invalidate_range_start_gfx(struct mmu_notifier *mn,
-						 struct mm_struct *mm,
-						 unsigned long start,
-						 unsigned long end,
-						 bool blockable)
+			const struct mmu_notifier_range *range)
 {
 	struct amdgpu_mn *amn = container_of(mn, struct amdgpu_mn, mn);
 	struct interval_tree_node *it;
+	unsigned long end;
 
 	/* notification is exclusive, but interval is inclusive */
-	end -= 1;
+	end = range->end - 1;
 
 	/* TODO we should be able to split locking for interval tree and
 	 * amdgpu_mn_invalidate_node
 	 */
-	if (amdgpu_mn_read_lock(amn, blockable))
+	if (amdgpu_mn_read_lock(amn, range->blockable))
 		return -EAGAIN;
 
-	it = interval_tree_iter_first(&amn->objects, start, end);
+	it = interval_tree_iter_first(&amn->objects, range->start, end);
 	while (it) {
 		struct amdgpu_mn_node *node;
 
-		if (!blockable) {
+		if (!range->blockable) {
 			amdgpu_mn_read_unlock(amn);
 			return -EAGAIN;
 		}
 
 		node = container_of(it, struct amdgpu_mn_node, it);
-		it = interval_tree_iter_next(it, start, end);
+		it = interval_tree_iter_next(it, range->start, end);
 
-		amdgpu_mn_invalidate_node(node, start, end);
+		amdgpu_mn_invalidate_node(node, range->start, end);
 	}
 
 	return 0;
@@ -294,39 +292,38 @@ static int amdgpu_mn_invalidate_range_start_gfx(struct mmu_notifier *mn,
  * are restorted in amdgpu_mn_invalidate_range_end_hsa.
  */
 static int amdgpu_mn_invalidate_range_start_hsa(struct mmu_notifier *mn,
-						 struct mm_struct *mm,
-						 unsigned long start,
-						 unsigned long end,
-						 bool blockable)
+			const struct mmu_notifier_range *range)
 {
 	struct amdgpu_mn *amn = container_of(mn, struct amdgpu_mn, mn);
 	struct interval_tree_node *it;
+	unsigned long end;
 
 	/* notification is exclusive, but interval is inclusive */
-	end -= 1;
+	end = range->end - 1;
 
-	if (amdgpu_mn_read_lock(amn, blockable))
+	if (amdgpu_mn_read_lock(amn, range->blockable))
 		return -EAGAIN;
 
-	it = interval_tree_iter_first(&amn->objects, start, end);
+	it = interval_tree_iter_first(&amn->objects, range->start, end);
 	while (it) {
 		struct amdgpu_mn_node *node;
 		struct amdgpu_bo *bo;
 
-		if (!blockable) {
+		if (!range->blockable) {
 			amdgpu_mn_read_unlock(amn);
 			return -EAGAIN;
 		}
 
 		node = container_of(it, struct amdgpu_mn_node, it);
-		it = interval_tree_iter_next(it, start, end);
+		it = interval_tree_iter_next(it, range->start, end);
 
 		list_for_each_entry(bo, &node->bos, mn_list) {
 			struct kgd_mem *mem = bo->kfd_bo;
 
 			if (amdgpu_ttm_tt_affect_userptr(bo->tbo.ttm,
-							 start, end))
-				amdgpu_amdkfd_evict_userptr(mem, mm);
+							 range->start,
+							 end))
+				amdgpu_amdkfd_evict_userptr(mem, range->mm);
 		}
 	}
 
@@ -344,9 +341,7 @@ static int amdgpu_mn_invalidate_range_start_hsa(struct mmu_notifier *mn,
  * Release the lock again to allow new command submissions.
  */
 static void amdgpu_mn_invalidate_range_end(struct mmu_notifier *mn,
-					   struct mm_struct *mm,
-					   unsigned long start,
-					   unsigned long end)
+			const struct mmu_notifier_range *range)
 {
 	struct amdgpu_mn *amn = container_of(mn, struct amdgpu_mn, mn);
 
diff --git a/drivers/gpu/drm/i915/i915_gem_userptr.c b/drivers/gpu/drm/i915/i915_gem_userptr.c
index 2c9b284036d1..3df77020aada 100644
--- a/drivers/gpu/drm/i915/i915_gem_userptr.c
+++ b/drivers/gpu/drm/i915/i915_gem_userptr.c
@@ -113,27 +113,25 @@ static void del_object(struct i915_mmu_object *mo)
 }
 
 static int i915_gem_userptr_mn_invalidate_range_start(struct mmu_notifier *_mn,
-						       struct mm_struct *mm,
-						       unsigned long start,
-						       unsigned long end,
-						       bool blockable)
+			const struct mmu_notifier_range *range)
 {
 	struct i915_mmu_notifier *mn =
 		container_of(_mn, struct i915_mmu_notifier, mn);
 	struct i915_mmu_object *mo;
 	struct interval_tree_node *it;
 	LIST_HEAD(cancelled);
+	unsigned long end;
 
 	if (RB_EMPTY_ROOT(&mn->objects.rb_root))
 		return 0;
 
 	/* interval ranges are inclusive, but invalidate range is exclusive */
-	end--;
+	end = range->end - 1;
 
 	spin_lock(&mn->lock);
-	it = interval_tree_iter_first(&mn->objects, start, end);
+	it = interval_tree_iter_first(&mn->objects, range->start, end);
 	while (it) {
-		if (!blockable) {
+		if (!range->blockable) {
 			spin_unlock(&mn->lock);
 			return -EAGAIN;
 		}
@@ -151,7 +149,7 @@ static int i915_gem_userptr_mn_invalidate_range_start(struct mmu_notifier *_mn,
 			queue_work(mn->wq, &mo->work);
 
 		list_add(&mo->link, &cancelled);
-		it = interval_tree_iter_next(it, start, end);
+		it = interval_tree_iter_next(it, range->start, end);
 	}
 	list_for_each_entry(mo, &cancelled, link)
 		del_object(mo);
diff --git a/drivers/gpu/drm/radeon/radeon_mn.c b/drivers/gpu/drm/radeon/radeon_mn.c
index f8b35df44c60..b3019505065a 100644
--- a/drivers/gpu/drm/radeon/radeon_mn.c
+++ b/drivers/gpu/drm/radeon/radeon_mn.c
@@ -119,40 +119,38 @@ static void radeon_mn_release(struct mmu_notifier *mn,
  * unmap them by move them into system domain again.
  */
 static int radeon_mn_invalidate_range_start(struct mmu_notifier *mn,
-					     struct mm_struct *mm,
-					     unsigned long start,
-					     unsigned long end,
-					     bool blockable)
+				const struct mmu_notifier_range *range)
 {
 	struct radeon_mn *rmn = container_of(mn, struct radeon_mn, mn);
 	struct ttm_operation_ctx ctx = { false, false };
 	struct interval_tree_node *it;
+	unsigned long end;
 	int ret = 0;
 
 	/* notification is exclusive, but interval is inclusive */
-	end -= 1;
+	end = range->end - 1;
 
 	/* TODO we should be able to split locking for interval tree and
 	 * the tear down.
 	 */
-	if (blockable)
+	if (range->blockable)
 		mutex_lock(&rmn->lock);
 	else if (!mutex_trylock(&rmn->lock))
 		return -EAGAIN;
 
-	it = interval_tree_iter_first(&rmn->objects, start, end);
+	it = interval_tree_iter_first(&rmn->objects, range->start, end);
 	while (it) {
 		struct radeon_mn_node *node;
 		struct radeon_bo *bo;
 		long r;
 
-		if (!blockable) {
+		if (!range->blockable) {
 			ret = -EAGAIN;
 			goto out_unlock;
 		}
 
 		node = container_of(it, struct radeon_mn_node, it);
-		it = interval_tree_iter_next(it, start, end);
+		it = interval_tree_iter_next(it, range->start, end);
 
 		list_for_each_entry(bo, &node->bos, mn_list) {
 
diff --git a/drivers/infiniband/core/umem_odp.c b/drivers/infiniband/core/umem_odp.c
index 676c1fd1119d..25db6ff68c70 100644
--- a/drivers/infiniband/core/umem_odp.c
+++ b/drivers/infiniband/core/umem_odp.c
@@ -146,15 +146,12 @@ static int invalidate_range_start_trampoline(struct ib_umem_odp *item,
 }
 
 static int ib_umem_notifier_invalidate_range_start(struct mmu_notifier *mn,
-						    struct mm_struct *mm,
-						    unsigned long start,
-						    unsigned long end,
-						    bool blockable)
+				const struct mmu_notifier_range *range)
 {
 	struct ib_ucontext_per_mm *per_mm =
 		container_of(mn, struct ib_ucontext_per_mm, mn);
 
-	if (blockable)
+	if (range->blockable)
 		down_read(&per_mm->umem_rwsem);
 	else if (!down_read_trylock(&per_mm->umem_rwsem))
 		return -EAGAIN;
@@ -169,9 +166,10 @@ static int ib_umem_notifier_invalidate_range_start(struct mmu_notifier *mn,
 		return 0;
 	}
 
-	return rbt_ib_umem_for_each_in_range(&per_mm->umem_tree, start, end,
+	return rbt_ib_umem_for_each_in_range(&per_mm->umem_tree, range->start,
+					     range->end,
 					     invalidate_range_start_trampoline,
-					     blockable, NULL);
+					     range->blockable, NULL);
 }
 
 static int invalidate_range_end_trampoline(struct ib_umem_odp *item, u64 start,
@@ -182,9 +180,7 @@ static int invalidate_range_end_trampoline(struct ib_umem_odp *item, u64 start,
 }
 
 static void ib_umem_notifier_invalidate_range_end(struct mmu_notifier *mn,
-						  struct mm_struct *mm,
-						  unsigned long start,
-						  unsigned long end)
+				const struct mmu_notifier_range *range)
 {
 	struct ib_ucontext_per_mm *per_mm =
 		container_of(mn, struct ib_ucontext_per_mm, mn);
@@ -192,8 +188,8 @@ static void ib_umem_notifier_invalidate_range_end(struct mmu_notifier *mn,
 	if (unlikely(!per_mm->active))
 		return;
 
-	rbt_ib_umem_for_each_in_range(&per_mm->umem_tree, start,
-				      end,
+	rbt_ib_umem_for_each_in_range(&per_mm->umem_tree, range->start,
+				      range->end,
 				      invalidate_range_end_trampoline, true, NULL);
 	up_read(&per_mm->umem_rwsem);
 }
diff --git a/drivers/infiniband/hw/hfi1/mmu_rb.c b/drivers/infiniband/hw/hfi1/mmu_rb.c
index 475b769e120c..14d2a90964c3 100644
--- a/drivers/infiniband/hw/hfi1/mmu_rb.c
+++ b/drivers/infiniband/hw/hfi1/mmu_rb.c
@@ -68,8 +68,7 @@ struct mmu_rb_handler {
 static unsigned long mmu_node_start(struct mmu_rb_node *);
 static unsigned long mmu_node_last(struct mmu_rb_node *);
 static int mmu_notifier_range_start(struct mmu_notifier *,
-				     struct mm_struct *,
-				     unsigned long, unsigned long, bool);
+		const struct mmu_notifier_range *);
 static struct mmu_rb_node *__mmu_rb_search(struct mmu_rb_handler *,
 					   unsigned long, unsigned long);
 static void do_remove(struct mmu_rb_handler *handler,
@@ -284,10 +283,7 @@ void hfi1_mmu_rb_remove(struct mmu_rb_handler *handler,
 }
 
 static int mmu_notifier_range_start(struct mmu_notifier *mn,
-				     struct mm_struct *mm,
-				     unsigned long start,
-				     unsigned long end,
-				     bool blockable)
+		const struct mmu_notifier_range *range)
 {
 	struct mmu_rb_handler *handler =
 		container_of(mn, struct mmu_rb_handler, mn);
@@ -297,10 +293,11 @@ static int mmu_notifier_range_start(struct mmu_notifier *mn,
 	bool added = false;
 
 	spin_lock_irqsave(&handler->lock, flags);
-	for (node = __mmu_int_rb_iter_first(root, start, end - 1);
+	for (node = __mmu_int_rb_iter_first(root, range->start, range->end-1);
 	     node; node = ptr) {
 		/* Guard against node removal. */
-		ptr = __mmu_int_rb_iter_next(node, start, end - 1);
+		ptr = __mmu_int_rb_iter_next(node, range->start,
+					     range->end - 1);
 		trace_hfi1_mmu_mem_invalidate(node->addr, node->len);
 		if (handler->ops->invalidate(handler->ops_arg, node)) {
 			__mmu_int_rb_remove(node, root);
diff --git a/drivers/misc/mic/scif/scif_dma.c b/drivers/misc/mic/scif/scif_dma.c
index 18b8ed57c4ac..e0d97044d0e9 100644
--- a/drivers/misc/mic/scif/scif_dma.c
+++ b/drivers/misc/mic/scif/scif_dma.c
@@ -201,23 +201,18 @@ static void scif_mmu_notifier_release(struct mmu_notifier *mn,
 }
 
 static int scif_mmu_notifier_invalidate_range_start(struct mmu_notifier *mn,
-						     struct mm_struct *mm,
-						     unsigned long start,
-						     unsigned long end,
-						     bool blockable)
+					const struct mmu_notifier_range *range)
 {
 	struct scif_mmu_notif	*mmn;
 
 	mmn = container_of(mn, struct scif_mmu_notif, ep_mmu_notifier);
-	scif_rma_destroy_tcw(mmn, start, end - start);
+	scif_rma_destroy_tcw(mmn, range->start, range->end - range->start);
 
 	return 0;
 }
 
 static void scif_mmu_notifier_invalidate_range_end(struct mmu_notifier *mn,
-						   struct mm_struct *mm,
-						   unsigned long start,
-						   unsigned long end)
+			const struct mmu_notifier_range *range)
 {
 	/*
 	 * Nothing to do here, everything needed was done in
diff --git a/drivers/misc/sgi-gru/grutlbpurge.c b/drivers/misc/sgi-gru/grutlbpurge.c
index 03b49d52092e..ca2032afe035 100644
--- a/drivers/misc/sgi-gru/grutlbpurge.c
+++ b/drivers/misc/sgi-gru/grutlbpurge.c
@@ -220,9 +220,7 @@ void gru_flush_all_tlb(struct gru_state *gru)
  * MMUOPS notifier callout functions
  */
 static int gru_invalidate_range_start(struct mmu_notifier *mn,
-				       struct mm_struct *mm,
-				       unsigned long start, unsigned long end,
-				       bool blockable)
+			const struct mmu_notifier_range *range)
 {
 	struct gru_mm_struct *gms = container_of(mn, struct gru_mm_struct,
 						 ms_notifier);
@@ -230,15 +228,14 @@ static int gru_invalidate_range_start(struct mmu_notifier *mn,
 	STAT(mmu_invalidate_range);
 	atomic_inc(&gms->ms_range_active);
 	gru_dbg(grudev, "gms %p, start 0x%lx, end 0x%lx, act %d\n", gms,
-		start, end, atomic_read(&gms->ms_range_active));
-	gru_flush_tlb_range(gms, start, end - start);
+		range->start, range->end, atomic_read(&gms->ms_range_active));
+	gru_flush_tlb_range(gms, range->start, range->end - range->start);
 
 	return 0;
 }
 
 static void gru_invalidate_range_end(struct mmu_notifier *mn,
-				     struct mm_struct *mm, unsigned long start,
-				     unsigned long end)
+			const struct mmu_notifier_range *range)
 {
 	struct gru_mm_struct *gms = container_of(mn, struct gru_mm_struct,
 						 ms_notifier);
@@ -247,7 +244,8 @@ static void gru_invalidate_range_end(struct mmu_notifier *mn,
 	(void)atomic_dec_and_test(&gms->ms_range_active);
 
 	wake_up_all(&gms->ms_wait_queue);
-	gru_dbg(grudev, "gms %p, start 0x%lx, end 0x%lx\n", gms, start, end);
+	gru_dbg(grudev, "gms %p, start 0x%lx, end 0x%lx\n",
+		gms, range->start, range->end);
 }
 
 static void gru_release(struct mmu_notifier *mn, struct mm_struct *mm)
diff --git a/drivers/xen/gntdev.c b/drivers/xen/gntdev.c
index b0b02a501167..5efc5eee9544 100644
--- a/drivers/xen/gntdev.c
+++ b/drivers/xen/gntdev.c
@@ -520,26 +520,26 @@ static int unmap_if_in_range(struct gntdev_grant_map *map,
 }
 
 static int mn_invl_range_start(struct mmu_notifier *mn,
-				struct mm_struct *mm,
-				unsigned long start, unsigned long end,
-				bool blockable)
+			       const struct mmu_notifier_range *range)
 {
 	struct gntdev_priv *priv = container_of(mn, struct gntdev_priv, mn);
 	struct gntdev_grant_map *map;
 	int ret = 0;
 
-	if (blockable)
+	if (range->blockable)
 		mutex_lock(&priv->lock);
 	else if (!mutex_trylock(&priv->lock))
 		return -EAGAIN;
 
 	list_for_each_entry(map, &priv->maps, next) {
-		ret = unmap_if_in_range(map, start, end, blockable);
+		ret = unmap_if_in_range(map, range->start, range->end,
+					range->blockable);
 		if (ret)
 			goto out_unlock;
 	}
 	list_for_each_entry(map, &priv->freeable_maps, next) {
-		ret = unmap_if_in_range(map, start, end, blockable);
+		ret = unmap_if_in_range(map, range->start, range->end,
+					range->blockable);
 		if (ret)
 			goto out_unlock;
 	}
diff --git a/include/linux/mmu_notifier.h b/include/linux/mmu_notifier.h
index 9893a6432adf..368f0c1a049d 100644
--- a/include/linux/mmu_notifier.h
+++ b/include/linux/mmu_notifier.h
@@ -25,6 +25,13 @@ struct mmu_notifier_mm {
 	spinlock_t lock;
 };
 
+struct mmu_notifier_range {
+	struct mm_struct *mm;
+	unsigned long start;
+	unsigned long end;
+	bool blockable;
+};
+
 struct mmu_notifier_ops {
 	/*
 	 * Called either by mmu_notifier_unregister or when the mm is
@@ -146,12 +153,9 @@ struct mmu_notifier_ops {
 	 *
 	 */
 	int (*invalidate_range_start)(struct mmu_notifier *mn,
-				       struct mm_struct *mm,
-				       unsigned long start, unsigned long end,
-				       bool blockable);
+				      const struct mmu_notifier_range *range);
 	void (*invalidate_range_end)(struct mmu_notifier *mn,
-				     struct mm_struct *mm,
-				     unsigned long start, unsigned long end);
+				     const struct mmu_notifier_range *range);
 
 	/*
 	 * invalidate_range() is either called between
diff --git a/mm/hmm.c b/mm/hmm.c
index 90c34f3d1243..1965f2caf5eb 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -189,35 +189,30 @@ static void hmm_release(struct mmu_notifier *mn, struct mm_struct *mm)
 }
 
 static int hmm_invalidate_range_start(struct mmu_notifier *mn,
-				      struct mm_struct *mm,
-				      unsigned long start,
-				      unsigned long end,
-				      bool blockable)
+			const struct mmu_notifier_range *range)
 {
 	struct hmm_update update;
-	struct hmm *hmm = mm->hmm;
+	struct hmm *hmm = range->mm->hmm;
 
 	VM_BUG_ON(!hmm);
 
-	update.start = start;
-	update.end = end;
+	update.start = range->start;
+	update.end = range->end;
 	update.event = HMM_UPDATE_INVALIDATE;
-	update.blockable = blockable;
+	update.blockable = range->blockable;
 	return hmm_invalidate_range(hmm, true, &update);
 }
 
 static void hmm_invalidate_range_end(struct mmu_notifier *mn,
-				     struct mm_struct *mm,
-				     unsigned long start,
-				     unsigned long end)
+			const struct mmu_notifier_range *range)
 {
 	struct hmm_update update;
-	struct hmm *hmm = mm->hmm;
+	struct hmm *hmm = range->mm->hmm;
 
 	VM_BUG_ON(!hmm);
 
-	update.start = start;
-	update.end = end;
+	update.start = range->start;
+	update.end = range->end;
 	update.event = HMM_UPDATE_INVALIDATE;
 	update.blockable = true;
 	hmm_invalidate_range(hmm, false, &update);
diff --git a/mm/mmu_notifier.c b/mm/mmu_notifier.c
index 5119ff846769..5f6665ae3ee2 100644
--- a/mm/mmu_notifier.c
+++ b/mm/mmu_notifier.c
@@ -178,14 +178,20 @@ int __mmu_notifier_invalidate_range_start(struct mm_struct *mm,
 				  unsigned long start, unsigned long end,
 				  bool blockable)
 {
+	struct mmu_notifier_range _range, *range = &_range;
 	struct mmu_notifier *mn;
 	int ret = 0;
 	int id;
 
+	range->blockable = blockable;
+	range->start = start;
+	range->end = end;
+	range->mm = mm;
+
 	id = srcu_read_lock(&srcu);
 	hlist_for_each_entry_rcu(mn, &mm->mmu_notifier_mm->list, hlist) {
 		if (mn->ops->invalidate_range_start) {
-			int _ret = mn->ops->invalidate_range_start(mn, mm, start, end, blockable);
+			int _ret = mn->ops->invalidate_range_start(mn, range);
 			if (_ret) {
 				pr_info("%pS callback failed with %d in %sblockable context.\n",
 						mn->ops->invalidate_range_start, _ret,
@@ -205,9 +211,20 @@ void __mmu_notifier_invalidate_range_end(struct mm_struct *mm,
 					 unsigned long end,
 					 bool only_end)
 {
+	struct mmu_notifier_range _range, *range = &_range;
 	struct mmu_notifier *mn;
 	int id;
 
+	/*
+	 * The end call back will never be call if the start refused to go
+	 * through because of blockable was false so here assume that we
+	 * can block.
+	 */
+	range->blockable = true;
+	range->start = start;
+	range->end = end;
+	range->mm = mm;
+
 	id = srcu_read_lock(&srcu);
 	hlist_for_each_entry_rcu(mn, &mm->mmu_notifier_mm->list, hlist) {
 		/*
@@ -226,7 +243,7 @@ void __mmu_notifier_invalidate_range_end(struct mm_struct *mm,
 		if (!only_end && mn->ops->invalidate_range)
 			mn->ops->invalidate_range(mn, mm, start, end);
 		if (mn->ops->invalidate_range_end)
-			mn->ops->invalidate_range_end(mn, mm, start, end);
+			mn->ops->invalidate_range_end(mn, range);
 	}
 	srcu_read_unlock(&srcu, id);
 }
diff --git a/virt/kvm/kvm_main.c b/virt/kvm/kvm_main.c
index 2679e476b6c3..f829f63f2b16 100644
--- a/virt/kvm/kvm_main.c
+++ b/virt/kvm/kvm_main.c
@@ -360,10 +360,7 @@ static void kvm_mmu_notifier_change_pte(struct mmu_notifier *mn,
 }
 
 static int kvm_mmu_notifier_invalidate_range_start(struct mmu_notifier *mn,
-						    struct mm_struct *mm,
-						    unsigned long start,
-						    unsigned long end,
-						    bool blockable)
+					const struct mmu_notifier_range *range)
 {
 	struct kvm *kvm = mmu_notifier_to_kvm(mn);
 	int need_tlb_flush = 0, idx;
@@ -377,7 +374,7 @@ static int kvm_mmu_notifier_invalidate_range_start(struct mmu_notifier *mn,
 	 * count is also read inside the mmu_lock critical section.
 	 */
 	kvm->mmu_notifier_count++;
-	need_tlb_flush = kvm_unmap_hva_range(kvm, start, end);
+	need_tlb_flush = kvm_unmap_hva_range(kvm, range->start, range->end);
 	need_tlb_flush |= kvm->tlbs_dirty;
 	/* we've to flush the tlb before the pages can be freed */
 	if (need_tlb_flush)
@@ -385,7 +382,8 @@ static int kvm_mmu_notifier_invalidate_range_start(struct mmu_notifier *mn,
 
 	spin_unlock(&kvm->mmu_lock);
 
-	ret = kvm_arch_mmu_notifier_invalidate_range(kvm, start, end, blockable);
+	ret = kvm_arch_mmu_notifier_invalidate_range(kvm, range->start,
+					range->end, range->blockable);
 
 	srcu_read_unlock(&kvm->srcu, idx);
 
@@ -393,9 +391,7 @@ static int kvm_mmu_notifier_invalidate_range_start(struct mmu_notifier *mn,
 }
 
 static void kvm_mmu_notifier_invalidate_range_end(struct mmu_notifier *mn,
-						  struct mm_struct *mm,
-						  unsigned long start,
-						  unsigned long end)
+					const struct mmu_notifier_range *range)
 {
 	struct kvm *kvm = mmu_notifier_to_kvm(mn);
 
-- 
2.17.2
