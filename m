Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f54.google.com (mail-qg0-f54.google.com [209.85.192.54])
	by kanga.kvack.org (Postfix) with ESMTP id 2973382F65
	for <linux-mm@kvack.org>; Wed, 21 Oct 2015 16:04:38 -0400 (EDT)
Received: by qgeo38 with SMTP id o38so38134553qge.0
        for <linux-mm@kvack.org>; Wed, 21 Oct 2015 13:04:37 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 39si9700738qgp.81.2015.10.21.13.04.36
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Oct 2015 13:04:36 -0700 (PDT)
From: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>
Subject: [PATCH v11 02/15] mmu_notifier: keep track of active invalidation ranges v5
Date: Wed, 21 Oct 2015 16:59:57 -0400
Message-Id: <1445461210-2605-3-git-send-email-jglisse@redhat.com>
In-Reply-To: <1445461210-2605-1-git-send-email-jglisse@redhat.com>
References: <1445461210-2605-1-git-send-email-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>, joro@8bytes.org, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, Dave Airlie <airlied@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Christophe Harle <charle@nvidia.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Haggai Eran <haggaie@mellanox.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Roland Dreier <roland@purestorage.com>, Ben Sander <ben.sander@amd.com>, Greg Stoner <Greg.Stoner@amd.com>, John Bridgman <John.Bridgman@amd.com>, Michael Mantor <Michael.Mantor@amd.com>, Paul Blinzer <Paul.Blinzer@amd.com>, Leonid Shamis <Leonid.Shamis@amd.com>, Laurent Morichetti <Laurent.Morichetti@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>

The invalidate_range_start() and invalidate_range_end() can be
considered as forming an "atomic" section for the cpu page table
update point of view. Between this two function the cpu page
table content is unreliable for the address range being
invalidated.

This patch use a structure define at all place doing range
invalidation. This structure is added to a list for the duration
of the update ie added with invalid_range_start() and removed
with invalidate_range_end().

Helpers allow querying if a range is valid and wait for it if
necessary.

For proper synchronization, user must block any new range
invalidation from inside their invalidate_range_start() callback.
Otherwise there is no guarantee that a new range invalidation will
not be added after the call to the helper function to query for
existing range.

Changed since v1:
  - Fix a possible deadlock in mmu_notifier_range_wait_active()

Changed since v2:
  - Add the range to invalid range list before calling ->range_start().
  - Del the range from invalid range list after calling ->range_end().
  - Remove useless list initialization.

Changed since v3:
  - Improved commit message.
  - Added comment to explain how helpers function are suppose to be use.
  - English syntax fixes.

Changed since v4:
  - Syntax fixes.
  - Rename from range_*_valid to range_*active|inactive.

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
Reviewed-by: Rik van Riel <riel@redhat.com>
Reviewed-by: Haggai Eran <haggaie@mellanox.com>
---
 drivers/gpu/drm/amd/amdgpu/amdgpu_mn.c  |  13 ++--
 drivers/gpu/drm/i915/i915_gem_userptr.c |  10 +--
 drivers/gpu/drm/radeon/radeon_mn.c      |  16 ++--
 drivers/infiniband/core/umem_odp.c      |  20 ++---
 drivers/misc/sgi-gru/grutlbpurge.c      |  15 ++--
 drivers/xen/gntdev.c                    |  15 ++--
 fs/proc/task_mmu.c                      |  11 ++-
 include/linux/mmu_notifier.h            |  55 +++++++-------
 kernel/events/uprobes.c                 |  13 ++--
 mm/huge_memory.c                        |  72 ++++++++----------
 mm/hugetlb.c                            |  55 +++++++-------
 mm/ksm.c                                |  28 +++----
 mm/memory.c                             |  72 ++++++++++--------
 mm/migrate.c                            |  36 ++++-----
 mm/mmu_notifier.c                       | 128 +++++++++++++++++++++++++++++---
 mm/mprotect.c                           |  18 +++--
 mm/mremap.c                             |  14 ++--
 virt/kvm/kvm_main.c                     |  14 ++--
 18 files changed, 350 insertions(+), 255 deletions(-)

diff --git a/drivers/gpu/drm/amd/amdgpu/amdgpu_mn.c b/drivers/gpu/drm/amd/amdgpu/amdgpu_mn.c
index 7ca805c..7c9eb1b 100644
--- a/drivers/gpu/drm/amd/amdgpu/amdgpu_mn.c
+++ b/drivers/gpu/drm/amd/amdgpu/amdgpu_mn.c
@@ -119,27 +119,24 @@ static void amdgpu_mn_release(struct mmu_notifier *mn,
  * unmap them by move them into system domain again.
  */
 static void amdgpu_mn_invalidate_range_start(struct mmu_notifier *mn,
-					     struct mm_struct *mm,
-					     unsigned long start,
-					     unsigned long end,
-					     enum mmu_event event)
+					struct mm_struct *mm,
+					const struct mmu_notifier_range *range)
 {
 	struct amdgpu_mn *rmn = container_of(mn, struct amdgpu_mn, mn);
 	struct interval_tree_node *it;
-
 	/* notification is exclusive, but interval is inclusive */
-	end -= 1;
+	unsigned long end = range->end - 1;
 
 	mutex_lock(&rmn->lock);
 
-	it = interval_tree_iter_first(&rmn->objects, start, end);
+	it = interval_tree_iter_first(&rmn->objects, range->start, end);
 	while (it) {
 		struct amdgpu_mn_node *node;
 		struct amdgpu_bo *bo;
 		long r;
 
 		node = container_of(it, struct amdgpu_mn_node, it);
-		it = interval_tree_iter_next(it, start, end);
+		it = interval_tree_iter_next(it, range->start, end);
 
 		list_for_each_entry(bo, &node->bos, mn_list) {
 
diff --git a/drivers/gpu/drm/i915/i915_gem_userptr.c b/drivers/gpu/drm/i915/i915_gem_userptr.c
index adc5480..40ae9c1 100644
--- a/drivers/gpu/drm/i915/i915_gem_userptr.c
+++ b/drivers/gpu/drm/i915/i915_gem_userptr.c
@@ -130,17 +130,17 @@ restart:
 }
 
 static void i915_gem_userptr_mn_invalidate_range_start(struct mmu_notifier *_mn,
-						       struct mm_struct *mm,
-						       unsigned long start,
-						       unsigned long end,
-						       enum mmu_event event)
+					struct mm_struct *mm,
+					const struct mmu_notifier_range *range)
 {
 	struct i915_mmu_notifier *mn = container_of(_mn, struct i915_mmu_notifier, mn);
 	struct interval_tree_node *it = NULL;
+	unsigned long start = range->start;
 	unsigned long next = start;
+	/* interval ranges are inclusive, but invalidate range is exclusive */
+	unsigned long end = range->end - 1;
 	unsigned long serial = 0;
 
-	end--; /* interval ranges are inclusive, but invalidate range is exclusive */
 	while (next < end) {
 		struct drm_i915_gem_object *obj = NULL;
 
diff --git a/drivers/gpu/drm/radeon/radeon_mn.c b/drivers/gpu/drm/radeon/radeon_mn.c
index 3a9615b..5276f01 100644
--- a/drivers/gpu/drm/radeon/radeon_mn.c
+++ b/drivers/gpu/drm/radeon/radeon_mn.c
@@ -112,34 +112,30 @@ static void radeon_mn_release(struct mmu_notifier *mn,
  *
  * @mn: our notifier
  * @mn: the mm this callback is about
- * @start: start of updated range
- * @end: end of updated range
+ * @range: Address range information.
  *
  * We block for all BOs between start and end to be idle and
  * unmap them by move them into system domain again.
  */
 static void radeon_mn_invalidate_range_start(struct mmu_notifier *mn,
-					     struct mm_struct *mm,
-					     unsigned long start,
-					     unsigned long end,
-					     enum mmu_event event)
+					struct mm_struct *mm,
+					const struct mmu_notifier_range *range)
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
index 6ed69fa..58d9a00 100644
--- a/drivers/infiniband/core/umem_odp.c
+++ b/drivers/infiniband/core/umem_odp.c
@@ -191,10 +191,8 @@ static int invalidate_range_start_trampoline(struct ib_umem *item, u64 start,
 }
 
 static void ib_umem_notifier_invalidate_range_start(struct mmu_notifier *mn,
-						    struct mm_struct *mm,
-						    unsigned long start,
-						    unsigned long end,
-						    enum mmu_event event)
+					struct mm_struct *mm,
+					const struct mmu_notifier_range *range)
 {
 	struct ib_ucontext *context = container_of(mn, struct ib_ucontext, mn);
 
@@ -203,8 +201,8 @@ static void ib_umem_notifier_invalidate_range_start(struct mmu_notifier *mn,
 
 	ib_ucontext_notifier_start_account(context);
 	down_read(&context->umem_rwsem);
-	rbt_ib_umem_for_each_in_range(&context->umem_tree, start,
-				      end,
+	rbt_ib_umem_for_each_in_range(&context->umem_tree, range->start,
+				      range->end,
 				      invalidate_range_start_trampoline, NULL);
 	up_read(&context->umem_rwsem);
 }
@@ -217,10 +215,8 @@ static int invalidate_range_end_trampoline(struct ib_umem *item, u64 start,
 }
 
 static void ib_umem_notifier_invalidate_range_end(struct mmu_notifier *mn,
-						  struct mm_struct *mm,
-						  unsigned long start,
-						  unsigned long end,
-						  enum mmu_event event)
+					struct mm_struct *mm,
+					const struct mmu_notifier_range *range)
 {
 	struct ib_ucontext *context = container_of(mn, struct ib_ucontext, mn);
 
@@ -228,8 +224,8 @@ static void ib_umem_notifier_invalidate_range_end(struct mmu_notifier *mn,
 		return;
 
 	down_read(&context->umem_rwsem);
-	rbt_ib_umem_for_each_in_range(&context->umem_tree, start,
-				      end,
+	rbt_ib_umem_for_each_in_range(&context->umem_tree, range->start,
+				      range->end,
 				      invalidate_range_end_trampoline, NULL);
 	up_read(&context->umem_rwsem);
 	ib_ucontext_notifier_end_account(context);
diff --git a/drivers/misc/sgi-gru/grutlbpurge.c b/drivers/misc/sgi-gru/grutlbpurge.c
index e67fed1..44b41b7 100644
--- a/drivers/misc/sgi-gru/grutlbpurge.c
+++ b/drivers/misc/sgi-gru/grutlbpurge.c
@@ -221,8 +221,7 @@ void gru_flush_all_tlb(struct gru_state *gru)
  */
 static void gru_invalidate_range_start(struct mmu_notifier *mn,
 				       struct mm_struct *mm,
-				       unsigned long start, unsigned long end,
-				       enum mmu_event event)
+				       const struct mmu_notifier_range *range)
 {
 	struct gru_mm_struct *gms = container_of(mn, struct gru_mm_struct,
 						 ms_notifier);
@@ -230,14 +229,13 @@ static void gru_invalidate_range_start(struct mmu_notifier *mn,
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
-				     unsigned long end,
-				     enum mmu_event event)
+				     struct mm_struct *mm,
+				     const struct mmu_notifier_range *range)
 {
 	struct gru_mm_struct *gms = container_of(mn, struct gru_mm_struct,
 						 ms_notifier);
@@ -246,7 +244,8 @@ static void gru_invalidate_range_end(struct mmu_notifier *mn,
 	(void)atomic_dec_and_test(&gms->ms_range_active);
 
 	wake_up_all(&gms->ms_wait_queue);
-	gru_dbg(grudev, "gms %p, start 0x%lx, end 0x%lx\n", gms, start, end);
+	gru_dbg(grudev, "gms %p, start 0x%lx, end 0x%lx\n", gms,
+		range->start, range->end);
 }
 
 static void gru_invalidate_page(struct mmu_notifier *mn, struct mm_struct *mm,
diff --git a/drivers/xen/gntdev.c b/drivers/xen/gntdev.c
index 60491fc..71c526c 100644
--- a/drivers/xen/gntdev.c
+++ b/drivers/xen/gntdev.c
@@ -467,19 +467,17 @@ static void unmap_if_in_range(struct grant_map *map,
 
 static void mn_invl_range_start(struct mmu_notifier *mn,
 				struct mm_struct *mm,
-				unsigned long start,
-				unsigned long end,
-				enum mmu_event event)
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
@@ -489,7 +487,12 @@ static void mn_invl_page(struct mmu_notifier *mn,
 			 unsigned long address,
 			 enum mmu_event event)
 {
-	mn_invl_range_start(mn, mm, address, address + PAGE_SIZE, event);
+	struct mmu_notifier_range range;
+
+	range.start = address;
+	range.end = address + PAGE_SIZE;
+	range.event = event;
+	mn_invl_range_start(mn, mm, &range);
 }
 
 static void mn_release(struct mmu_notifier *mn,
diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index a3b15d4..65ef71f 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -903,6 +903,11 @@ static ssize_t clear_refs_write(struct file *file, const char __user *buf,
 			.mm = mm,
 			.private = &cp,
 		};
+		struct mmu_notifier_range range = {
+			.start = 0,
+			.end = ~0UL,
+			.event = MMU_CLEAR_SOFT_DIRTY,
+		};
 
 		if (type == CLEAR_REFS_MM_HIWATER_RSS) {
 			/*
@@ -929,13 +934,11 @@ static ssize_t clear_refs_write(struct file *file, const char __user *buf,
 				downgrade_write(&mm->mmap_sem);
 				break;
 			}
-			mmu_notifier_invalidate_range_start(mm, 0, -1,
-							MMU_CLEAR_SOFT_DIRTY);
+			mmu_notifier_invalidate_range_start(mm, &range);
 		}
 		walk_page_range(0, ~0UL, &clear_refs_walk);
 		if (type == CLEAR_REFS_SOFT_DIRTY)
-			mmu_notifier_invalidate_range_end(mm, 0, -1,
-							MMU_CLEAR_SOFT_DIRTY);
+			mmu_notifier_invalidate_range_end(mm, &range);
 		flush_tlb_mm(mm);
 		up_read(&mm->mmap_sem);
 out_mm:
diff --git a/include/linux/mmu_notifier.h b/include/linux/mmu_notifier.h
index e92c52e..4ac1930 100644
--- a/include/linux/mmu_notifier.h
+++ b/include/linux/mmu_notifier.h
@@ -70,6 +70,13 @@ enum mmu_event {
 	MMU_KSM_WRITE_PROTECT,
 };
 
+struct mmu_notifier_range {
+	struct list_head list;
+	unsigned long start;
+	unsigned long end;
+	enum mmu_event event;
+};
+
 #ifdef CONFIG_MMU_NOTIFIER
 
 /*
@@ -83,6 +90,12 @@ struct mmu_notifier_mm {
 	struct hlist_head list;
 	/* to serialize the list modifications and hlist_unhashed */
 	spinlock_t lock;
+	/* List of all active range invalidations. */
+	struct list_head ranges;
+	/* Number of active range invalidations. */
+	int nranges;
+	/* For threads waiting on range invalidations. */
+	wait_queue_head_t wait_queue;
 };
 
 struct mmu_notifier_ops {
@@ -213,14 +226,10 @@ struct mmu_notifier_ops {
 	 */
 	void (*invalidate_range_start)(struct mmu_notifier *mn,
 				       struct mm_struct *mm,
-				       unsigned long start,
-				       unsigned long end,
-				       enum mmu_event event);
+				       const struct mmu_notifier_range *range);
 	void (*invalidate_range_end)(struct mmu_notifier *mn,
 				     struct mm_struct *mm,
-				     unsigned long start,
-				     unsigned long end,
-				     enum mmu_event event);
+				     const struct mmu_notifier_range *range);
 
 	/*
 	 * invalidate_range() is either called between
@@ -293,15 +302,17 @@ extern void __mmu_notifier_invalidate_page(struct mm_struct *mm,
 					  unsigned long address,
 					  enum mmu_event event);
 extern void __mmu_notifier_invalidate_range_start(struct mm_struct *mm,
-						  unsigned long start,
-						  unsigned long end,
-						  enum mmu_event event);
+					struct mmu_notifier_range *range);
 extern void __mmu_notifier_invalidate_range_end(struct mm_struct *mm,
-						unsigned long start,
-						unsigned long end,
-						enum mmu_event event);
+					struct mmu_notifier_range *range);
 extern void __mmu_notifier_invalidate_range(struct mm_struct *mm,
 				  unsigned long start, unsigned long end);
+extern bool mmu_notifier_range_inactive(struct mm_struct *mm,
+					unsigned long start,
+					unsigned long end);
+extern void mmu_notifier_range_wait_active(struct mm_struct *mm,
+					  unsigned long start,
+					  unsigned long end);
 
 static inline void mmu_notifier_release(struct mm_struct *mm)
 {
@@ -353,21 +364,17 @@ static inline void mmu_notifier_invalidate_page(struct mm_struct *mm,
 }
 
 static inline void mmu_notifier_invalidate_range_start(struct mm_struct *mm,
-						       unsigned long start,
-						       unsigned long end,
-						       enum mmu_event event)
+					struct mmu_notifier_range *range)
 {
 	if (mm_has_notifiers(mm))
-		__mmu_notifier_invalidate_range_start(mm, start, end, event);
+		__mmu_notifier_invalidate_range_start(mm, range);
 }
 
 static inline void mmu_notifier_invalidate_range_end(struct mm_struct *mm,
-						     unsigned long start,
-						     unsigned long end,
-						     enum mmu_event event)
+					struct mmu_notifier_range *range)
 {
 	if (mm_has_notifiers(mm))
-		__mmu_notifier_invalidate_range_end(mm, start, end, event);
+		__mmu_notifier_invalidate_range_end(mm, range);
 }
 
 static inline void mmu_notifier_invalidate_range(struct mm_struct *mm,
@@ -531,16 +538,12 @@ static inline void mmu_notifier_invalidate_page(struct mm_struct *mm,
 }
 
 static inline void mmu_notifier_invalidate_range_start(struct mm_struct *mm,
-						       unsigned long start,
-						       unsigned long end,
-						       enum mmu_event event)
+					struct mmu_notifier_range *range)
 {
 }
 
 static inline void mmu_notifier_invalidate_range_end(struct mm_struct *mm,
-						     unsigned long start,
-						     unsigned long end,
-						     enum mmu_event event)
+					struct mmu_notifier_range *range)
 {
 }
 
diff --git a/kernel/events/uprobes.c b/kernel/events/uprobes.c
index eafa177..60d3d3c 100644
--- a/kernel/events/uprobes.c
+++ b/kernel/events/uprobes.c
@@ -156,9 +156,7 @@ static int __replace_page(struct vm_area_struct *vma, unsigned long addr,
 	spinlock_t *ptl;
 	pte_t *ptep;
 	int err;
-	/* For mmu_notifiers */
-	const unsigned long mmun_start = addr;
-	const unsigned long mmun_end   = addr + PAGE_SIZE;
+	struct mmu_notifier_range range;
 	struct mem_cgroup *memcg;
 
 	err = mem_cgroup_try_charge(kpage, vma->vm_mm, GFP_KERNEL, &memcg);
@@ -168,8 +166,10 @@ static int __replace_page(struct vm_area_struct *vma, unsigned long addr,
 	/* For try_to_free_swap() and munlock_vma_page() below */
 	lock_page(page);
 
-	mmu_notifier_invalidate_range_start(mm, mmun_start,
-					    mmun_end, MMU_MIGRATE);
+	range.start = addr;
+	range.end = addr + PAGE_SIZE;
+	range.event = MMU_MIGRATE;
+	mmu_notifier_invalidate_range_start(mm, &range);
 	err = -EAGAIN;
 	ptep = page_check_address(page, mm, addr, &ptl, 0);
 	if (!ptep)
@@ -203,8 +203,7 @@ static int __replace_page(struct vm_area_struct *vma, unsigned long addr,
 	err = 0;
  unlock:
 	mem_cgroup_cancel_charge(kpage, memcg);
-	mmu_notifier_invalidate_range_end(mm, mmun_start,
-					  mmun_end, MMU_MIGRATE);
+	mmu_notifier_invalidate_range_end(mm, &range);
 	unlock_page(page);
 	return err;
 }
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 2e1e746..e73c84c 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1052,8 +1052,7 @@ static int do_huge_pmd_wp_page_fallback(struct mm_struct *mm,
 	pmd_t _pmd;
 	int ret = 0, i;
 	struct page **pages;
-	unsigned long mmun_start;	/* For mmu_notifiers */
-	unsigned long mmun_end;		/* For mmu_notifiers */
+	struct mmu_notifier_range range;
 
 	pages = kmalloc(sizeof(struct page *) * HPAGE_PMD_NR,
 			GFP_KERNEL);
@@ -1091,10 +1090,10 @@ static int do_huge_pmd_wp_page_fallback(struct mm_struct *mm,
 		cond_resched();
 	}
 
-	mmun_start = haddr;
-	mmun_end   = haddr + HPAGE_PMD_SIZE;
-	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end,
-					    MMU_MIGRATE);
+	range.start = haddr;
+	range.end = haddr + HPAGE_PMD_SIZE;
+	range.event = MMU_MIGRATE;
+	mmu_notifier_invalidate_range_start(mm, &range);
 
 	ptl = pmd_lock(mm, pmd);
 	if (unlikely(!pmd_same(*pmd, orig_pmd)))
@@ -1128,8 +1127,7 @@ static int do_huge_pmd_wp_page_fallback(struct mm_struct *mm,
 	page_remove_rmap(page);
 	spin_unlock(ptl);
 
-	mmu_notifier_invalidate_range_end(mm, mmun_start,
-					  mmun_end, MMU_MIGRATE);
+	mmu_notifier_invalidate_range_end(mm, &range);
 
 	ret |= VM_FAULT_WRITE;
 	put_page(page);
@@ -1139,8 +1137,7 @@ out:
 
 out_free_pages:
 	spin_unlock(ptl);
-	mmu_notifier_invalidate_range_end(mm, mmun_start,
-					  mmun_end, MMU_MIGRATE);
+	mmu_notifier_invalidate_range_end(mm, &range);
 	for (i = 0; i < HPAGE_PMD_NR; i++) {
 		memcg = (void *)page_private(pages[i]);
 		set_page_private(pages[i], 0);
@@ -1159,9 +1156,8 @@ int do_huge_pmd_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	struct page *page = NULL, *new_page;
 	struct mem_cgroup *memcg;
 	unsigned long haddr;
-	unsigned long mmun_start;	/* For mmu_notifiers */
-	unsigned long mmun_end;		/* For mmu_notifiers */
 	gfp_t huge_gfp;			/* for allocation and charge */
+	struct mmu_notifier_range range;
 
 	ptl = pmd_lockptr(mm, pmd);
 	VM_BUG_ON_VMA(!vma->anon_vma, vma);
@@ -1230,10 +1226,10 @@ alloc:
 		copy_user_huge_page(new_page, page, haddr, vma, HPAGE_PMD_NR);
 	__SetPageUptodate(new_page);
 
-	mmun_start = haddr;
-	mmun_end   = haddr + HPAGE_PMD_SIZE;
-	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end,
-					    MMU_MIGRATE);
+	range.start = haddr;
+	range.end = haddr + HPAGE_PMD_SIZE;
+	range.event = MMU_MIGRATE;
+	mmu_notifier_invalidate_range_start(mm, &range);
 
 	spin_lock(ptl);
 	if (page)
@@ -1265,8 +1261,7 @@ alloc:
 	}
 	spin_unlock(ptl);
 out_mn:
-	mmu_notifier_invalidate_range_end(mm, mmun_start,
-					  mmun_end, MMU_MIGRATE);
+	mmu_notifier_invalidate_range_end(mm, &range);
 out:
 	return ret;
 out_unlock:
@@ -1681,12 +1676,12 @@ static int __split_huge_page_splitting(struct page *page,
 	spinlock_t *ptl;
 	pmd_t *pmd;
 	int ret = 0;
-	/* For mmu_notifiers */
-	const unsigned long mmun_start = address;
-	const unsigned long mmun_end   = address + HPAGE_PMD_SIZE;
+	struct mmu_notifier_range range;
 
-	mmu_notifier_invalidate_range_start(mm, mmun_start,
-					    mmun_end, MMU_HUGE_PAGE_SPLIT);
+	range.start = address;
+	range.end = address + HPAGE_PMD_SIZE;
+	range.event = MMU_HUGE_PAGE_SPLIT;
+	mmu_notifier_invalidate_range_start(mm, &range);
 	pmd = page_check_address_pmd(page, mm, address,
 			PAGE_CHECK_ADDRESS_PMD_NOTSPLITTING_FLAG, &ptl);
 	if (pmd) {
@@ -1702,8 +1697,7 @@ static int __split_huge_page_splitting(struct page *page,
 		ret = 1;
 		spin_unlock(ptl);
 	}
-	mmu_notifier_invalidate_range_end(mm, mmun_start,
-					  mmun_end, MMU_HUGE_PAGE_SPLIT);
+	mmu_notifier_invalidate_range_end(mm, &range);
 
 	return ret;
 }
@@ -2525,8 +2519,7 @@ static void collapse_huge_page(struct mm_struct *mm,
 	int isolated;
 	unsigned long hstart, hend;
 	struct mem_cgroup *memcg;
-	unsigned long mmun_start;	/* For mmu_notifiers */
-	unsigned long mmun_end;		/* For mmu_notifiers */
+	struct mmu_notifier_range range;
 	gfp_t gfp;
 
 	VM_BUG_ON(address & ~HPAGE_PMD_MASK);
@@ -2571,10 +2564,10 @@ static void collapse_huge_page(struct mm_struct *mm,
 	pte = pte_offset_map(pmd, address);
 	pte_ptl = pte_lockptr(mm, pmd);
 
-	mmun_start = address;
-	mmun_end   = address + HPAGE_PMD_SIZE;
-	mmu_notifier_invalidate_range_start(mm, mmun_start,
-					    mmun_end, MMU_MIGRATE);
+	range.start = address;
+	range.end = address + HPAGE_PMD_SIZE;
+	range.event = MMU_MIGRATE;
+	mmu_notifier_invalidate_range_start(mm, &range);
 	pmd_ptl = pmd_lock(mm, pmd); /* probably unnecessary */
 	/*
 	 * After this gup_fast can't run anymore. This also removes
@@ -2584,8 +2577,7 @@ static void collapse_huge_page(struct mm_struct *mm,
 	 */
 	_pmd = pmdp_collapse_flush(vma, address, pmd);
 	spin_unlock(pmd_ptl);
-	mmu_notifier_invalidate_range_end(mm, mmun_start,
-					  mmun_end, MMU_MIGRATE);
+	mmu_notifier_invalidate_range_end(mm, &range);
 
 	spin_lock(pte_ptl);
 	isolated = __collapse_huge_page_isolate(vma, address, pte);
@@ -2976,16 +2968,15 @@ void __split_huge_page_pmd(struct vm_area_struct *vma, unsigned long address,
 	struct page *page = NULL;
 	struct mm_struct *mm = vma->vm_mm;
 	unsigned long haddr = address & HPAGE_PMD_MASK;
-	unsigned long mmun_start;	/* For mmu_notifiers */
-	unsigned long mmun_end;		/* For mmu_notifiers */
+	struct mmu_notifier_range range;
 
 	BUG_ON(vma->vm_start > haddr || vma->vm_end < haddr + HPAGE_PMD_SIZE);
 
-	mmun_start = haddr;
-	mmun_end   = haddr + HPAGE_PMD_SIZE;
+	range.start = haddr;
+	range.end = haddr + HPAGE_PMD_SIZE;
+	range.event = MMU_MIGRATE;
 again:
-	mmu_notifier_invalidate_range_start(mm, mmun_start,
-					    mmun_end, MMU_MIGRATE);
+	mmu_notifier_invalidate_range_start(mm, &range);
 	ptl = pmd_lock(mm, pmd);
 	if (unlikely(!pmd_trans_huge(*pmd)))
 		goto unlock;
@@ -3002,8 +2993,7 @@ again:
 	}
  unlock:
 	spin_unlock(ptl);
-	mmu_notifier_invalidate_range_end(mm, mmun_start,
-					  mmun_end, MMU_MIGRATE);
+	mmu_notifier_invalidate_range_end(mm, &range);
 
 	if (!page)
 		return;
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 62c3ad8..dae64fd 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -2968,17 +2968,16 @@ int copy_hugetlb_page_range(struct mm_struct *dst, struct mm_struct *src,
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
+	range.event = MMU_MIGRATE;
 	if (cow)
-		mmu_notifier_invalidate_range_start(src, mmun_start,
-						    mmun_end, MMU_MIGRATE);
+		mmu_notifier_invalidate_range_start(src, &range);
 
 	for (addr = vma->vm_start; addr < vma->vm_end; addr += sz) {
 		spinlock_t *src_ptl, *dst_ptl;
@@ -3018,8 +3017,8 @@ int copy_hugetlb_page_range(struct mm_struct *dst, struct mm_struct *src,
 		} else {
 			if (cow) {
 				huge_ptep_set_wrprotect(src, addr, src_pte);
-				mmu_notifier_invalidate_range(src, mmun_start,
-								   mmun_end);
+				mmu_notifier_invalidate_range(src, range.start,
+								   range.end);
 			}
 			entry = huge_ptep_get(src_pte);
 			ptepage = pte_page(entry);
@@ -3032,8 +3031,7 @@ int copy_hugetlb_page_range(struct mm_struct *dst, struct mm_struct *src,
 	}
 
 	if (cow)
-		mmu_notifier_invalidate_range_end(src, mmun_start,
-						  mmun_end, MMU_MIGRATE);
+		mmu_notifier_invalidate_range_end(src, &range);
 
 	return ret;
 }
@@ -3051,16 +3049,17 @@ void __unmap_hugepage_range(struct mmu_gather *tlb, struct vm_area_struct *vma,
 	struct page *page;
 	struct hstate *h = hstate_vma(vma);
 	unsigned long sz = huge_page_size(h);
-	const unsigned long mmun_start = start;	/* For mmu_notifiers */
-	const unsigned long mmun_end   = end;	/* For mmu_notifiers */
+	struct mmu_notifier_range range;
 
 	WARN_ON(!is_vm_hugetlb_page(vma));
 	BUG_ON(start & ~huge_page_mask(h));
 	BUG_ON(end & ~huge_page_mask(h));
 
+	range.start = start;
+	range.end = end;
+	range.event = MMU_MIGRATE;
 	tlb_start_vma(tlb, vma);
-	mmu_notifier_invalidate_range_start(mm, mmun_start,
-					    mmun_end, MMU_MIGRATE);
+	mmu_notifier_invalidate_range_start(mm, &range);
 	address = start;
 again:
 	for (; address < end; address += sz) {
@@ -3134,8 +3133,7 @@ unlock:
 		if (address < end && !ref_page)
 			goto again;
 	}
-	mmu_notifier_invalidate_range_end(mm, mmun_start,
-					  mmun_end, MMU_MIGRATE);
+	mmu_notifier_invalidate_range_end(mm, &range);
 	tlb_end_vma(tlb, vma);
 }
 
@@ -3240,8 +3238,7 @@ static int hugetlb_cow(struct mm_struct *mm, struct vm_area_struct *vma,
 	struct hstate *h = hstate_vma(vma);
 	struct page *old_page, *new_page;
 	int ret = 0, outside_reserve = 0;
-	unsigned long mmun_start;	/* For mmu_notifiers */
-	unsigned long mmun_end;		/* For mmu_notifiers */
+	struct mmu_notifier_range range;
 
 	old_page = pte_page(pte);
 
@@ -3320,10 +3317,11 @@ retry_avoidcopy:
 	__SetPageUptodate(new_page);
 	set_page_huge_active(new_page);
 
-	mmun_start = address & huge_page_mask(h);
-	mmun_end = mmun_start + huge_page_size(h);
-	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end,
-					    MMU_MIGRATE);
+	range.start = address & huge_page_mask(h);
+	range.end = range.start + huge_page_size(h);
+	range.event = MMU_MIGRATE;
+	mmu_notifier_invalidate_range_start(mm, &range);
+
 	/*
 	 * Retake the page table lock to check for racing updates
 	 * before the page tables are altered
@@ -3335,7 +3333,7 @@ retry_avoidcopy:
 
 		/* Break COW */
 		huge_ptep_clear_flush(vma, address, ptep);
-		mmu_notifier_invalidate_range(mm, mmun_start, mmun_end);
+		mmu_notifier_invalidate_range(mm, range.start, range.end);
 		set_huge_pte_at(mm, address, ptep,
 				make_huge_pte(vma, new_page, 1));
 		page_remove_rmap(old_page);
@@ -3344,8 +3342,7 @@ retry_avoidcopy:
 		new_page = old_page;
 	}
 	spin_unlock(ptl);
-	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end,
-					  MMU_MIGRATE);
+	mmu_notifier_invalidate_range_end(mm, &range);
 out_release_all:
 	page_cache_release(new_page);
 out_release_old:
@@ -3823,11 +3820,15 @@ unsigned long hugetlb_change_protection(struct vm_area_struct *vma,
 	pte_t pte;
 	struct hstate *h = hstate_vma(vma);
 	unsigned long pages = 0;
+	struct mmu_notifier_range range;
 
 	BUG_ON(address >= end);
 	flush_cache_range(vma, address, end);
 
-	mmu_notifier_invalidate_range_start(mm, start, end, MMU_MPROT);
+	range.start = start;
+	range.end = end;
+	range.event = MMU_MPROT;
+	mmu_notifier_invalidate_range_start(mm, &range);
 	i_mmap_lock_write(vma->vm_file->f_mapping);
 	for (; address < end; address += huge_page_size(h)) {
 		spinlock_t *ptl;
@@ -3877,7 +3878,7 @@ unsigned long hugetlb_change_protection(struct vm_area_struct *vma,
 	flush_tlb_range(vma, start, end);
 	mmu_notifier_invalidate_range(mm, start, end);
 	i_mmap_unlock_write(vma->vm_file->f_mapping);
-	mmu_notifier_invalidate_range_end(mm, start, end, MMU_MPROT);
+	mmu_notifier_invalidate_range_end(mm, &range);
 
 	return pages << h->order;
 }
diff --git a/mm/ksm.c b/mm/ksm.c
index eb1b2b5..e384a97 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -855,14 +855,13 @@ static inline int pages_identical(struct page *page1, struct page *page2)
 static int write_protect_page(struct vm_area_struct *vma, struct page *page,
 			      pte_t *orig_pte)
 {
+	struct mmu_notifier_range range;
 	struct mm_struct *mm = vma->vm_mm;
 	unsigned long addr;
 	pte_t *ptep;
 	spinlock_t *ptl;
 	int swapped;
 	int err = -EFAULT;
-	unsigned long mmun_start;	/* For mmu_notifiers */
-	unsigned long mmun_end;		/* For mmu_notifiers */
 
 	addr = page_address_in_vma(page, vma);
 	if (addr == -EFAULT)
@@ -870,10 +869,10 @@ static int write_protect_page(struct vm_area_struct *vma, struct page *page,
 
 	BUG_ON(PageTransCompound(page));
 
-	mmun_start = addr;
-	mmun_end   = addr + PAGE_SIZE;
-	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end,
-					    MMU_KSM_WRITE_PROTECT);
+	range.start = addr;
+	range.end = addr + PAGE_SIZE;
+	range.event = MMU_KSM_WRITE_PROTECT;
+	mmu_notifier_invalidate_range_start(mm, &range);
 
 	ptep = page_check_address(page, mm, addr, &ptl, 0);
 	if (!ptep)
@@ -913,8 +912,7 @@ static int write_protect_page(struct vm_area_struct *vma, struct page *page,
 out_unlock:
 	pte_unmap_unlock(ptep, ptl);
 out_mn:
-	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end,
-					  MMU_KSM_WRITE_PROTECT);
+	mmu_notifier_invalidate_range_end(mm, &range);
 out:
 	return err;
 }
@@ -937,8 +935,7 @@ static int replace_page(struct vm_area_struct *vma, struct page *page,
 	spinlock_t *ptl;
 	unsigned long addr;
 	int err = -EFAULT;
-	unsigned long mmun_start;	/* For mmu_notifiers */
-	unsigned long mmun_end;		/* For mmu_notifiers */
+	struct mmu_notifier_range range;
 
 	addr = page_address_in_vma(page, vma);
 	if (addr == -EFAULT)
@@ -948,10 +945,10 @@ static int replace_page(struct vm_area_struct *vma, struct page *page,
 	if (!pmd)
 		goto out;
 
-	mmun_start = addr;
-	mmun_end   = addr + PAGE_SIZE;
-	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end,
-					    MMU_MIGRATE);
+	range.start = addr;
+	range.end = addr + PAGE_SIZE;
+	range.event = MMU_MIGRATE;
+	mmu_notifier_invalidate_range_start(mm, &range);
 
 	ptep = pte_offset_map_lock(mm, pmd, addr, &ptl);
 	if (!pte_same(*ptep, orig_pte)) {
@@ -976,8 +973,7 @@ static int replace_page(struct vm_area_struct *vma, struct page *page,
 	pte_unmap_unlock(ptep, ptl);
 	err = 0;
 out_mn:
-	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end,
-					  MMU_MIGRATE);
+	mmu_notifier_invalidate_range_end(mm, &range);
 out:
 	return err;
 }
diff --git a/mm/memory.c b/mm/memory.c
index 8281b4b..77bbbf3 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1010,8 +1010,7 @@ int copy_page_range(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 	unsigned long next;
 	unsigned long addr = vma->vm_start;
 	unsigned long end = vma->vm_end;
-	unsigned long mmun_start;	/* For mmu_notifiers */
-	unsigned long mmun_end;		/* For mmu_notifiers */
+	struct mmu_notifier_range range;
 	bool is_cow;
 	int ret;
 
@@ -1045,11 +1044,11 @@ int copy_page_range(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 	 * is_cow_mapping() returns true.
 	 */
 	is_cow = is_cow_mapping(vma->vm_flags);
-	mmun_start = addr;
-	mmun_end   = end;
+	range.start = addr;
+	range.end = end;
+	range.event = MMU_FORK;
 	if (is_cow)
-		mmu_notifier_invalidate_range_start(src_mm, mmun_start,
-						    mmun_end, MMU_FORK);
+		mmu_notifier_invalidate_range_start(src_mm, &range);
 
 	ret = 0;
 	dst_pgd = pgd_offset(dst_mm, addr);
@@ -1066,8 +1065,7 @@ int copy_page_range(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 	} while (dst_pgd++, src_pgd++, addr = next, addr != end);
 
 	if (is_cow)
-		mmu_notifier_invalidate_range_end(src_mm, mmun_start,
-						  mmun_end, MMU_FORK);
+		mmu_notifier_invalidate_range_end(src_mm, &range);
 	return ret;
 }
 
@@ -1336,13 +1334,16 @@ void unmap_vmas(struct mmu_gather *tlb,
 		unsigned long end_addr)
 {
 	struct mm_struct *mm = vma->vm_mm;
+	struct mmu_notifier_range range = {
+		.start = start_addr,
+		.end = end_addr,
+		.event = MMU_MUNMAP,
+	};
 
-	mmu_notifier_invalidate_range_start(mm, start_addr,
-					    end_addr, MMU_MUNMAP);
+	mmu_notifier_invalidate_range_start(mm, &range);
 	for ( ; vma && vma->vm_start < end_addr; vma = vma->vm_next)
 		unmap_single_vma(tlb, vma, start_addr, end_addr, NULL);
-	mmu_notifier_invalidate_range_end(mm, start_addr,
-					  end_addr, MMU_MUNMAP);
+	mmu_notifier_invalidate_range_end(mm, &range);
 }
 
 /**
@@ -1359,16 +1360,20 @@ void zap_page_range(struct vm_area_struct *vma, unsigned long start,
 {
 	struct mm_struct *mm = vma->vm_mm;
 	struct mmu_gather tlb;
-	unsigned long end = start + size;
+	struct mmu_notifier_range range = {
+		.start = start,
+		.end = start + size,
+		.event = MMU_MIGRATE,
+	};
 
 	lru_add_drain();
-	tlb_gather_mmu(&tlb, mm, start, end);
+	tlb_gather_mmu(&tlb, mm, start, range.end);
 	update_hiwater_rss(mm);
-	mmu_notifier_invalidate_range_start(mm, start, end, MMU_MIGRATE);
-	for ( ; vma && vma->vm_start < end; vma = vma->vm_next)
-		unmap_single_vma(&tlb, vma, start, end, details);
-	mmu_notifier_invalidate_range_end(mm, start, end, MMU_MIGRATE);
-	tlb_finish_mmu(&tlb, start, end);
+	mmu_notifier_invalidate_range_start(mm, &range);
+	for ( ; vma && vma->vm_start < range.end; vma = vma->vm_next)
+		unmap_single_vma(&tlb, vma, start, range.end, details);
+	mmu_notifier_invalidate_range_end(mm, &range);
+	tlb_finish_mmu(&tlb, start, range.end);
 }
 
 /**
@@ -1385,15 +1390,19 @@ static void zap_page_range_single(struct vm_area_struct *vma, unsigned long addr
 {
 	struct mm_struct *mm = vma->vm_mm;
 	struct mmu_gather tlb;
-	unsigned long end = address + size;
+	struct mmu_notifier_range range = {
+		.start = address,
+		.end = address + size,
+		.event = MMU_MUNMAP,
+	};
 
 	lru_add_drain();
-	tlb_gather_mmu(&tlb, mm, address, end);
+	tlb_gather_mmu(&tlb, mm, address, range.end);
 	update_hiwater_rss(mm);
-	mmu_notifier_invalidate_range_start(mm, address, end, MMU_MUNMAP);
-	unmap_single_vma(&tlb, vma, address, end, details);
-	mmu_notifier_invalidate_range_end(mm, address, end, MMU_MUNMAP);
-	tlb_finish_mmu(&tlb, address, end);
+	mmu_notifier_invalidate_range_start(mm, &range);
+	unmap_single_vma(&tlb, vma, address, range.end, details);
+	mmu_notifier_invalidate_range_end(mm, &range);
+	tlb_finish_mmu(&tlb, address, range.end);
 }
 
 /**
@@ -2001,6 +2010,7 @@ static inline int wp_page_reuse(struct mm_struct *mm,
 	__releases(ptl)
 {
 	pte_t entry;
+
 	/*
 	 * Clear the pages cpupid information as the existing
 	 * information potentially belongs to a now completely
@@ -2068,9 +2078,8 @@ static int wp_page_copy(struct mm_struct *mm, struct vm_area_struct *vma,
 	spinlock_t *ptl = NULL;
 	pte_t entry;
 	int page_copied = 0;
-	const unsigned long mmun_start = address & PAGE_MASK;	/* For mmu_notifiers */
-	const unsigned long mmun_end = mmun_start + PAGE_SIZE;	/* For mmu_notifiers */
 	struct mem_cgroup *memcg;
+	struct mmu_notifier_range range;
 
 	if (unlikely(anon_vma_prepare(vma)))
 		goto oom;
@@ -2091,8 +2100,10 @@ static int wp_page_copy(struct mm_struct *mm, struct vm_area_struct *vma,
 
 	__SetPageUptodate(new_page);
 
-	mmu_notifier_invalidate_range_start(mm, mmun_start,
-					    mmun_end, MMU_MIGRATE);
+	range.start = address & PAGE_MASK;
+	range.end = range.start + PAGE_SIZE;
+	range.event = MMU_MIGRATE;
+	mmu_notifier_invalidate_range_start(mm, &range);
 
 	/*
 	 * Re-check the pte - we dropped the lock
@@ -2164,8 +2175,7 @@ static int wp_page_copy(struct mm_struct *mm, struct vm_area_struct *vma,
 		page_cache_release(new_page);
 
 	pte_unmap_unlock(page_table, ptl);
-	mmu_notifier_invalidate_range_end(mm, mmun_start,
-					  mmun_end, MMU_MIGRATE);
+	mmu_notifier_invalidate_range_end(mm, &range);
 	if (old_page) {
 		/*
 		 * Don't let another task, with possibly unlocked vma,
diff --git a/mm/migrate.c b/mm/migrate.c
index d49a3af..144a19c 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1736,10 +1736,13 @@ int migrate_misplaced_transhuge_page(struct mm_struct *mm,
 	int isolated = 0;
 	struct page *new_page = NULL;
 	int page_lru = page_is_file_cache(page);
-	unsigned long mmun_start = address & HPAGE_PMD_MASK;
-	unsigned long mmun_end = mmun_start + HPAGE_PMD_SIZE;
+	struct mmu_notifier_range range;
 	pmd_t orig_entry;
 
+	range.start = address & HPAGE_PMD_MASK;
+	range.end = range.start + HPAGE_PMD_SIZE;
+	range.event = MMU_MIGRATE;
+
 	/*
 	 * Rate-limit the amount of data that is being migrated to a node.
 	 * Optimal placement is no good if the memory bus is saturated and
@@ -1761,7 +1764,7 @@ int migrate_misplaced_transhuge_page(struct mm_struct *mm,
 	}
 
 	if (mm_tlb_flush_pending(mm))
-		flush_tlb_range(vma, mmun_start, mmun_end);
+		flush_tlb_range(vma, range.start, range.end);
 
 	/* Prepare a page as a migration target */
 	__set_page_locked(new_page);
@@ -1774,14 +1777,12 @@ int migrate_misplaced_transhuge_page(struct mm_struct *mm,
 	WARN_ON(PageLRU(new_page));
 
 	/* Recheck the target PMD */
-	mmu_notifier_invalidate_range_start(mm, mmun_start,
-					    mmun_end, MMU_MIGRATE);
+	mmu_notifier_invalidate_range_start(mm, &range);
 	ptl = pmd_lock(mm, pmd);
 	if (unlikely(!pmd_same(*pmd, entry) || page_count(page) != 2)) {
 fail_putback:
 		spin_unlock(ptl);
-		mmu_notifier_invalidate_range_end(mm, mmun_start,
-						  mmun_end, MMU_MIGRATE);
+		mmu_notifier_invalidate_range_end(mm, &range);
 
 		/* Reverse changes made by migrate_page_copy() */
 		if (TestClearPageActive(new_page))
@@ -1814,17 +1815,17 @@ fail_putback:
 	 * The SetPageUptodate on the new page and page_add_new_anon_rmap
 	 * guarantee the copy is visible before the pagetable update.
 	 */
-	flush_cache_range(vma, mmun_start, mmun_end);
-	page_add_anon_rmap(new_page, vma, mmun_start);
-	pmdp_huge_clear_flush_notify(vma, mmun_start, pmd);
-	set_pmd_at(mm, mmun_start, pmd, entry);
-	flush_tlb_range(vma, mmun_start, mmun_end);
+	flush_cache_range(vma, range.start, range.end);
+	page_add_anon_rmap(new_page, vma, range.start);
+	pmdp_huge_clear_flush_notify(vma, range.start, pmd);
+	set_pmd_at(mm, range.start, pmd, entry);
+	flush_tlb_range(vma, range.start, range.end);
 	update_mmu_cache_pmd(vma, address, &entry);
 
 	if (page_count(page) != 2) {
-		set_pmd_at(mm, mmun_start, pmd, orig_entry);
-		flush_tlb_range(vma, mmun_start, mmun_end);
-		mmu_notifier_invalidate_range(mm, mmun_start, mmun_end);
+		set_pmd_at(mm, range.start, pmd, orig_entry);
+		flush_tlb_range(vma, range.start, range.end);
+		mmu_notifier_invalidate_range(mm, range.start, range.end);
 		update_mmu_cache_pmd(vma, address, &entry);
 		page_remove_rmap(new_page);
 		goto fail_putback;
@@ -1835,8 +1836,7 @@ fail_putback:
 	page_remove_rmap(page);
 
 	spin_unlock(ptl);
-	mmu_notifier_invalidate_range_end(mm, mmun_start,
-					  mmun_end, MMU_MIGRATE);
+	mmu_notifier_invalidate_range_end(mm, &range);
 
 	/* Take an "isolate" reference and put new page on the LRU. */
 	get_page(new_page);
@@ -1861,7 +1861,7 @@ out_dropref:
 	ptl = pmd_lock(mm, pmd);
 	if (pmd_same(*pmd, entry)) {
 		entry = pmd_modify(entry, vma->vm_page_prot);
-		set_pmd_at(mm, mmun_start, pmd, entry);
+		set_pmd_at(mm, range.start, pmd, entry);
 		update_mmu_cache_pmd(vma, address, &entry);
 	}
 	spin_unlock(ptl);
diff --git a/mm/mmu_notifier.c b/mm/mmu_notifier.c
index b806bdb..c43c851 100644
--- a/mm/mmu_notifier.c
+++ b/mm/mmu_notifier.c
@@ -191,28 +191,28 @@ void __mmu_notifier_invalidate_page(struct mm_struct *mm,
 }
 
 void __mmu_notifier_invalidate_range_start(struct mm_struct *mm,
-					   unsigned long start,
-					   unsigned long end,
-					   enum mmu_event event)
+					   struct mmu_notifier_range *range)
 
 {
 	struct mmu_notifier *mn;
 	int id;
 
+	spin_lock(&mm->mmu_notifier_mm->lock);
+	list_add_tail(&range->list, &mm->mmu_notifier_mm->ranges);
+	mm->mmu_notifier_mm->nranges++;
+	spin_unlock(&mm->mmu_notifier_mm->lock);
+
 	id = srcu_read_lock(&srcu);
 	hlist_for_each_entry_rcu(mn, &mm->mmu_notifier_mm->list, hlist) {
 		if (mn->ops->invalidate_range_start)
-			mn->ops->invalidate_range_start(mn, mm, start,
-							end, event);
+			mn->ops->invalidate_range_start(mn, mm, range);
 	}
 	srcu_read_unlock(&srcu, id);
 }
 EXPORT_SYMBOL_GPL(__mmu_notifier_invalidate_range_start);
 
 void __mmu_notifier_invalidate_range_end(struct mm_struct *mm,
-					 unsigned long start,
-					 unsigned long end,
-					 enum mmu_event event)
+					 struct mmu_notifier_range *range)
 {
 	struct mmu_notifier *mn;
 	int id;
@@ -228,12 +228,23 @@ void __mmu_notifier_invalidate_range_end(struct mm_struct *mm,
 		 * (besides the pointer check).
 		 */
 		if (mn->ops->invalidate_range)
-			mn->ops->invalidate_range(mn, mm, start, end);
+			mn->ops->invalidate_range(mn, mm,
+						  range->start, range->end);
 		if (mn->ops->invalidate_range_end)
-			mn->ops->invalidate_range_end(mn, mm, start,
-						      end, event);
+			mn->ops->invalidate_range_end(mn, mm, range);
 	}
 	srcu_read_unlock(&srcu, id);
+
+	spin_lock(&mm->mmu_notifier_mm->lock);
+	list_del_init(&range->list);
+	mm->mmu_notifier_mm->nranges--;
+	spin_unlock(&mm->mmu_notifier_mm->lock);
+
+	/*
+	 * Wakeup after callback so they can do their job before any of the
+	 * waiters resume.
+	 */
+	wake_up(&mm->mmu_notifier_mm->wait_queue);
 }
 EXPORT_SYMBOL_GPL(__mmu_notifier_invalidate_range_end);
 
@@ -252,6 +263,98 @@ void __mmu_notifier_invalidate_range(struct mm_struct *mm,
 }
 EXPORT_SYMBOL_GPL(__mmu_notifier_invalidate_range);
 
+/* mmu_notifier_range_inactive_locked() - test if range overlaps with active
+ * invalidation.
+ *
+ * @mm: The mm struct.
+ * @start: Start address of the range (inclusive).
+ * @end: End address of the range (exclusive).
+ * Returns: false if overlaps with an active invalidation, true otherwise.
+ *
+ * This function tests whether any active invalidation range conflicts with a
+ * given range ([start, end[), active invalidations are added to a list inside
+ * __mmu_notifier_invalidate_range_start() and removed from that list inside
+ * __mmu_notifier_invalidate_range_end().
+ */
+static bool mmu_notifier_range_inactive_locked(struct mm_struct *mm,
+					       unsigned long start,
+					       unsigned long end)
+{
+	struct mmu_notifier_range *range;
+
+	list_for_each_entry(range, &mm->mmu_notifier_mm->ranges, list) {
+		if (range->end > start && range->start < end)
+			return false;
+	}
+	return true;
+}
+
+/* mmu_notifier_range_inactive() - test if range overlaps with active
+ * invalidation.
+ *
+ * @mm: The mm struct.
+ * @start: Start address of the range (inclusive).
+ * @end: End address of the range (exclusive).
+ *
+ * Same as mmu_notifier_range_inactive_locked() but take the mmu_notifier lock.
+ */
+bool mmu_notifier_range_inactive(struct mm_struct *mm,
+				 unsigned long start,
+				 unsigned long end)
+{
+	bool valid;
+
+	spin_lock(&mm->mmu_notifier_mm->lock);
+	valid = mmu_notifier_range_inactive_locked(mm, start, end);
+	spin_unlock(&mm->mmu_notifier_mm->lock);
+	return valid;
+}
+EXPORT_SYMBOL_GPL(mmu_notifier_range_inactive);
+
+/* mmu_notifier_range_wait_active() - wait for a range to have no conflict with
+ * active invalidation.
+ *
+ * @mm: The mm struct.
+ * @start: Start address of the range (inclusive).
+ * @end: End address of the range (exclusive).
+ *
+ * This function wait for any active range invalidation that conflict with the
+ * given range, to end.
+ *
+ * Note by the time this function return a new range invalidation that conflict
+ * might have started. So you need to atomically block new range and query
+ * again if range is still valid with mmu_notifier_range_inactive(). So call
+ * sequence should be :
+ *
+ * again:
+ * mmu_notifier_range_wait_active()
+ * // Stop new invalidation using common lock with your range_start callback.
+ * lock_block_new_invalidation()
+ * if (!mmu_notifier_range_inactive()) {
+ *     unlock_block_new_invalidation();
+ *     goto again;
+ * }
+ * // Here you can safely access CPU page table for the range, knowing that you
+ * // will see valid entry and no one can change them.
+ * unlock_block_new_invalidation()
+ */
+void mmu_notifier_range_wait_active(struct mm_struct *mm,
+				    unsigned long start,
+				    unsigned long end)
+{
+	spin_lock(&mm->mmu_notifier_mm->lock);
+	while (!mmu_notifier_range_inactive_locked(mm, start, end)) {
+		int nranges = mm->mmu_notifier_mm->nranges;
+
+		spin_unlock(&mm->mmu_notifier_mm->lock);
+		wait_event(mm->mmu_notifier_mm->wait_queue,
+			   nranges != mm->mmu_notifier_mm->nranges);
+		spin_lock(&mm->mmu_notifier_mm->lock);
+	}
+	spin_unlock(&mm->mmu_notifier_mm->lock);
+}
+EXPORT_SYMBOL_GPL(mmu_notifier_range_wait_active);
+
 static int do_mmu_notifier_register(struct mmu_notifier *mn,
 				    struct mm_struct *mm,
 				    int take_mmap_sem)
@@ -281,6 +384,9 @@ static int do_mmu_notifier_register(struct mmu_notifier *mn,
 	if (!mm_has_notifiers(mm)) {
 		INIT_HLIST_HEAD(&mmu_notifier_mm->list);
 		spin_lock_init(&mmu_notifier_mm->lock);
+		INIT_LIST_HEAD(&mmu_notifier_mm->ranges);
+		mmu_notifier_mm->nranges = 0;
+		init_waitqueue_head(&mmu_notifier_mm->wait_queue);
 
 		mm->mmu_notifier_mm = mmu_notifier_mm;
 		mmu_notifier_mm = NULL;
diff --git a/mm/mprotect.c b/mm/mprotect.c
index f63b022..d1b6f87 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -142,7 +142,9 @@ static inline unsigned long change_pmd_range(struct vm_area_struct *vma,
 	unsigned long next;
 	unsigned long pages = 0;
 	unsigned long nr_huge_updates = 0;
-	unsigned long mni_start = 0;
+	struct mmu_notifier_range range = {
+		.start = 0,
+	};
 
 	pmd = pmd_offset(pud, addr);
 	do {
@@ -153,10 +155,11 @@ static inline unsigned long change_pmd_range(struct vm_area_struct *vma,
 			continue;
 
 		/* invoke the mmu notifier if the pmd is populated */
-		if (!mni_start) {
-			mni_start = addr;
-			mmu_notifier_invalidate_range_start(mm, mni_start,
-							    end, MMU_MPROT);
+		if (!range.start) {
+			range.start = addr;
+			range.end = end;
+			range.event = MMU_MPROT;
+			mmu_notifier_invalidate_range_start(mm, &range);
 		}
 
 		if (pmd_trans_huge(*pmd)) {
@@ -183,9 +186,8 @@ static inline unsigned long change_pmd_range(struct vm_area_struct *vma,
 		pages += this_pages;
 	} while (pmd++, addr = next, addr != end);
 
-	if (mni_start)
-		mmu_notifier_invalidate_range_end(mm, mni_start, end,
-						  MMU_MPROT);
+	if (range.start)
+		mmu_notifier_invalidate_range_end(mm, &range);
 
 	if (nr_huge_updates)
 		count_vm_numa_events(NUMA_HUGE_PTE_UPDATES, nr_huge_updates);
diff --git a/mm/mremap.c b/mm/mremap.c
index eea73a3..eb1a43f 100644
--- a/mm/mremap.c
+++ b/mm/mremap.c
@@ -166,18 +166,17 @@ unsigned long move_page_tables(struct vm_area_struct *vma,
 		bool need_rmap_locks)
 {
 	unsigned long extent, next, old_end;
+	struct mmu_notifier_range range;
 	pmd_t *old_pmd, *new_pmd;
 	bool need_flush = false;
-	unsigned long mmun_start;	/* For mmu_notifiers */
-	unsigned long mmun_end;		/* For mmu_notifiers */
 
 	old_end = old_addr + len;
 	flush_cache_range(vma, old_addr, old_end);
 
-	mmun_start = old_addr;
-	mmun_end   = old_end;
-	mmu_notifier_invalidate_range_start(vma->vm_mm, mmun_start,
-					    mmun_end, MMU_MIGRATE);
+	range.start = old_addr;
+	range.end = old_end;
+	range.event = MMU_MIGRATE;
+	mmu_notifier_invalidate_range_start(vma->vm_mm, &range);
 
 	for (; old_addr < old_end; old_addr += extent, new_addr += extent) {
 		cond_resched();
@@ -229,8 +228,7 @@ unsigned long move_page_tables(struct vm_area_struct *vma,
 	if (likely(need_flush))
 		flush_tlb_range(vma, old_end-len, old_addr);
 
-	mmu_notifier_invalidate_range_end(vma->vm_mm, mmun_start,
-					  mmun_end, MMU_MIGRATE);
+	mmu_notifier_invalidate_range_end(vma->vm_mm, &range);
 
 	return len + old_addr - old_end;	/* how much done */
 }
diff --git a/virt/kvm/kvm_main.c b/virt/kvm/kvm_main.c
index 9f6acd0..fa2418f3 100644
--- a/virt/kvm/kvm_main.c
+++ b/virt/kvm/kvm_main.c
@@ -327,10 +327,8 @@ static void kvm_mmu_notifier_change_pte(struct mmu_notifier *mn,
 }
 
 static void kvm_mmu_notifier_invalidate_range_start(struct mmu_notifier *mn,
-						    struct mm_struct *mm,
-						    unsigned long start,
-						    unsigned long end,
-						    enum mmu_event event)
+					struct mm_struct *mm,
+					const struct mmu_notifier_range *range)
 {
 	struct kvm *kvm = mmu_notifier_to_kvm(mn);
 	int need_tlb_flush = 0, idx;
@@ -343,7 +341,7 @@ static void kvm_mmu_notifier_invalidate_range_start(struct mmu_notifier *mn,
 	 * count is also read inside the mmu_lock critical section.
 	 */
 	kvm->mmu_notifier_count++;
-	need_tlb_flush = kvm_unmap_hva_range(kvm, start, end);
+	need_tlb_flush = kvm_unmap_hva_range(kvm, range->start, range->end);
 	need_tlb_flush |= kvm->tlbs_dirty;
 	/* we've to flush the tlb before the pages can be freed */
 	if (need_tlb_flush)
@@ -354,10 +352,8 @@ static void kvm_mmu_notifier_invalidate_range_start(struct mmu_notifier *mn,
 }
 
 static void kvm_mmu_notifier_invalidate_range_end(struct mmu_notifier *mn,
-						  struct mm_struct *mm,
-						  unsigned long start,
-						  unsigned long end,
-						  enum mmu_event event)
+					struct mm_struct *mm,
+					const struct mmu_notifier_range *range)
 {
 	struct kvm *kvm = mmu_notifier_to_kvm(mn);
 
-- 
2.4.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
