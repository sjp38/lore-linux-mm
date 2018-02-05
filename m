Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id EE7B56B0297
	for <linux-mm@kvack.org>; Sun,  4 Feb 2018 20:29:37 -0500 (EST)
Received: by mail-pl0-f70.google.com with SMTP id 3so7805055pla.1
        for <linux-mm@kvack.org>; Sun, 04 Feb 2018 17:29:37 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 1-v6si1340399ple.726.2018.02.04.17.28.08
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 04 Feb 2018 17:28:08 -0800 (PST)
From: Davidlohr Bueso <dbueso@suse.de>
Subject: [PATCH 57/64] drivers/gpu: use mm locking wrappers
Date: Mon,  5 Feb 2018 02:27:47 +0100
Message-Id: <20180205012754.23615-58-dbueso@wotan.suse.de>
In-Reply-To: <20180205012754.23615-1-dbueso@wotan.suse.de>
References: <20180205012754.23615-1-dbueso@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mingo@kernel.org
Cc: peterz@infradead.org, ldufour@linux.vnet.ibm.com, jack@suse.cz, mhocko@kernel.org, kirill.shutemov@linux.intel.com, mawilcox@microsoft.com, mgorman@techsingularity.net, dave@stgolabs.net, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Davidlohr Bueso <dbueso@suse.de>

From: Davidlohr Bueso <dave@stgolabs.net>

This becomes quite straightforward with the mmrange in place.
Those mmap_sem users that don't know about mmrange are updated
trivially as the sem is used in the same context of the caller.

Signed-off-by: Davidlohr Bueso <dbueso@suse.de>
---
 drivers/gpu/drm/amd/amdgpu/amdgpu_mn.c  | 7 ++++---
 drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.c | 8 ++++----
 drivers/gpu/drm/amd/amdkfd/kfd_events.c | 5 +++--
 drivers/gpu/drm/i915/i915_gem.c         | 5 +++--
 drivers/gpu/drm/i915/i915_gem_userptr.c | 9 +++++----
 drivers/gpu/drm/radeon/radeon_cs.c      | 5 +++--
 drivers/gpu/drm/radeon/radeon_gem.c     | 7 ++++---
 drivers/gpu/drm/radeon/radeon_mn.c      | 7 ++++---
 drivers/gpu/drm/ttm/ttm_bo_vm.c         | 4 ++--
 9 files changed, 32 insertions(+), 25 deletions(-)

diff --git a/drivers/gpu/drm/amd/amdgpu/amdgpu_mn.c b/drivers/gpu/drm/amd/amdgpu/amdgpu_mn.c
index bd67f4cb8e6c..cda7ea8503b7 100644
--- a/drivers/gpu/drm/amd/amdgpu/amdgpu_mn.c
+++ b/drivers/gpu/drm/amd/amdgpu/amdgpu_mn.c
@@ -257,9 +257,10 @@ struct amdgpu_mn *amdgpu_mn_get(struct amdgpu_device *adev)
 	struct mm_struct *mm = current->mm;
 	struct amdgpu_mn *rmn;
 	int r;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	mutex_lock(&adev->mn_lock);
-	if (down_write_killable(&mm->mmap_sem)) {
+	if (mm_write_lock_killable(mm, &mmrange)) {
 		mutex_unlock(&adev->mn_lock);
 		return ERR_PTR(-EINTR);
 	}
@@ -289,13 +290,13 @@ struct amdgpu_mn *amdgpu_mn_get(struct amdgpu_device *adev)
 	hash_add(adev->mn_hash, &rmn->node, (unsigned long)mm);
 
 release_locks:
-	up_write(&mm->mmap_sem);
+	mm_write_unlock(mm, &mmrange);
 	mutex_unlock(&adev->mn_lock);
 
 	return rmn;
 
 free_rmn:
-	up_write(&mm->mmap_sem);
+	mm_write_unlock(mm, &mmrange);
 	mutex_unlock(&adev->mn_lock);
 	kfree(rmn);
 
diff --git a/drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.c b/drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.c
index bd464a599341..95467ef0df45 100644
--- a/drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.c
+++ b/drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.c
@@ -696,7 +696,7 @@ int amdgpu_ttm_tt_get_user_pages(struct ttm_tt *ttm, struct page **pages)
 	if (!(gtt->userflags & AMDGPU_GEM_USERPTR_READONLY))
 		flags |= FOLL_WRITE;
 
-	down_read(&current->mm->mmap_sem);
+	mm_read_lock(current->mm, &mmrange);
 
 	if (gtt->userflags & AMDGPU_GEM_USERPTR_ANONONLY) {
 		/* check that we only use anonymous memory
@@ -706,7 +706,7 @@ int amdgpu_ttm_tt_get_user_pages(struct ttm_tt *ttm, struct page **pages)
 
 		vma = find_vma(gtt->usermm, gtt->userptr);
 		if (!vma || vma->vm_file || vma->vm_end < end) {
-			up_read(&current->mm->mmap_sem);
+			mm_read_unlock(current->mm, &mmrange);
 			return -EPERM;
 		}
 	}
@@ -735,12 +735,12 @@ int amdgpu_ttm_tt_get_user_pages(struct ttm_tt *ttm, struct page **pages)
 
 	} while (pinned < ttm->num_pages);
 
-	up_read(&current->mm->mmap_sem);
+	mm_read_unlock(current->mm, &mmrange);
 	return 0;
 
 release_pages:
 	release_pages(pages, pinned);
-	up_read(&current->mm->mmap_sem);
+	mm_read_unlock(current->mm, &mmrange);
 	return r;
 }
 
diff --git a/drivers/gpu/drm/amd/amdkfd/kfd_events.c b/drivers/gpu/drm/amd/amdkfd/kfd_events.c
index 93aae5c1e78b..ca516482b145 100644
--- a/drivers/gpu/drm/amd/amdkfd/kfd_events.c
+++ b/drivers/gpu/drm/amd/amdkfd/kfd_events.c
@@ -851,6 +851,7 @@ void kfd_signal_iommu_event(struct kfd_dev *dev, unsigned int pasid,
 	 */
 	struct kfd_process *p = kfd_lookup_process_by_pasid(pasid);
 	struct mm_struct *mm;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	if (!p)
 		return; /* Presumably process exited. */
@@ -866,7 +867,7 @@ void kfd_signal_iommu_event(struct kfd_dev *dev, unsigned int pasid,
 
 	memset(&memory_exception_data, 0, sizeof(memory_exception_data));
 
-	down_read(&mm->mmap_sem);
+	mm_read_lock(mm, &mmrange);
 	vma = find_vma(mm, address);
 
 	memory_exception_data.gpu_id = dev->id;
@@ -893,7 +894,7 @@ void kfd_signal_iommu_event(struct kfd_dev *dev, unsigned int pasid,
 		}
 	}
 
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &mmrange);
 	mmput(mm);
 
 	mutex_lock(&p->event_mutex);
diff --git a/drivers/gpu/drm/i915/i915_gem.c b/drivers/gpu/drm/i915/i915_gem.c
index dd89abd2263d..61d958934efd 100644
--- a/drivers/gpu/drm/i915/i915_gem.c
+++ b/drivers/gpu/drm/i915/i915_gem.c
@@ -1758,8 +1758,9 @@ i915_gem_mmap_ioctl(struct drm_device *dev, void *data,
 	if (args->flags & I915_MMAP_WC) {
 		struct mm_struct *mm = current->mm;
 		struct vm_area_struct *vma;
+		DEFINE_RANGE_LOCK_FULL(mmrange);
 
-		if (down_write_killable(&mm->mmap_sem)) {
+		if (mm_write_lock_killable(mm, &mmrange)) {
 			i915_gem_object_put(obj);
 			return -EINTR;
 		}
@@ -1769,7 +1770,7 @@ i915_gem_mmap_ioctl(struct drm_device *dev, void *data,
 				pgprot_writecombine(vm_get_page_prot(vma->vm_flags));
 		else
 			addr = -ENOMEM;
-		up_write(&mm->mmap_sem);
+		mm_write_unlock(mm, &mmrange);
 
 		/* This may race, but that's ok, it only gets set */
 		WRITE_ONCE(obj->frontbuffer_ggtt_origin, ORIGIN_CPU);
diff --git a/drivers/gpu/drm/i915/i915_gem_userptr.c b/drivers/gpu/drm/i915/i915_gem_userptr.c
index 881bcc7d663a..3886b74638f7 100644
--- a/drivers/gpu/drm/i915/i915_gem_userptr.c
+++ b/drivers/gpu/drm/i915/i915_gem_userptr.c
@@ -205,6 +205,7 @@ i915_mmu_notifier_find(struct i915_mm_struct *mm)
 {
 	struct i915_mmu_notifier *mn;
 	int err = 0;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	mn = mm->mn;
 	if (mn)
@@ -214,7 +215,7 @@ i915_mmu_notifier_find(struct i915_mm_struct *mm)
 	if (IS_ERR(mn))
 		err = PTR_ERR(mn);
 
-	down_write(&mm->mm->mmap_sem);
+	mm_write_lock(mm->mm, &mmrange);
 	mutex_lock(&mm->i915->mm_lock);
 	if (mm->mn == NULL && !err) {
 		/* Protected by mmap_sem (write-lock) */
@@ -231,7 +232,7 @@ i915_mmu_notifier_find(struct i915_mm_struct *mm)
 		err = 0;
 	}
 	mutex_unlock(&mm->i915->mm_lock);
-	up_write(&mm->mm->mmap_sem);
+	mm_write_unlock(mm->mm, &mmrange);
 
 	if (mn && !IS_ERR(mn)) {
 		destroy_workqueue(mn->wq);
@@ -514,7 +515,7 @@ __i915_gem_userptr_get_pages_worker(struct work_struct *_work)
 		if (mmget_not_zero(mm)) {
 			DEFINE_RANGE_LOCK_FULL(mmrange);
 
-			down_read(&mm->mmap_sem);
+			mm_read_lock(mm, &mmrange);
 			while (pinned < npages) {
 				ret = get_user_pages_remote
 					(work->task, mm,
@@ -527,7 +528,7 @@ __i915_gem_userptr_get_pages_worker(struct work_struct *_work)
 
 				pinned += ret;
 			}
-			up_read(&mm->mmap_sem);
+			mm_read_unlock(mm, &mmrange);
 			mmput(mm);
 		}
 	}
diff --git a/drivers/gpu/drm/radeon/radeon_cs.c b/drivers/gpu/drm/radeon/radeon_cs.c
index 1ae31dbc61c6..71a19881b04a 100644
--- a/drivers/gpu/drm/radeon/radeon_cs.c
+++ b/drivers/gpu/drm/radeon/radeon_cs.c
@@ -79,6 +79,7 @@ static int radeon_cs_parser_relocs(struct radeon_cs_parser *p)
 	unsigned i;
 	bool need_mmap_lock = false;
 	int r;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	if (p->chunk_relocs == NULL) {
 		return 0;
@@ -190,12 +191,12 @@ static int radeon_cs_parser_relocs(struct radeon_cs_parser *p)
 		p->vm_bos = radeon_vm_get_bos(p->rdev, p->ib.vm,
 					      &p->validated);
 	if (need_mmap_lock)
-		down_read(&current->mm->mmap_sem);
+		mm_read_lock(current->mm, &mmrange);
 
 	r = radeon_bo_list_validate(p->rdev, &p->ticket, &p->validated, p->ring);
 
 	if (need_mmap_lock)
-		up_read(&current->mm->mmap_sem);
+		mm_read_unlock(current->mm, &mmrange);
 
 	return r;
 }
diff --git a/drivers/gpu/drm/radeon/radeon_gem.c b/drivers/gpu/drm/radeon/radeon_gem.c
index a9962ffba720..3e169fa1750e 100644
--- a/drivers/gpu/drm/radeon/radeon_gem.c
+++ b/drivers/gpu/drm/radeon/radeon_gem.c
@@ -292,6 +292,7 @@ int radeon_gem_userptr_ioctl(struct drm_device *dev, void *data,
 	struct radeon_bo *bo;
 	uint32_t handle;
 	int r;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	if (offset_in_page(args->addr | args->size))
 		return -EINVAL;
@@ -336,17 +337,17 @@ int radeon_gem_userptr_ioctl(struct drm_device *dev, void *data,
 	}
 
 	if (args->flags & RADEON_GEM_USERPTR_VALIDATE) {
-		down_read(&current->mm->mmap_sem);
+		mm_read_lock(current->mm, &mmrange);
 		r = radeon_bo_reserve(bo, true);
 		if (r) {
-			up_read(&current->mm->mmap_sem);
+			mm_read_unlock(current->mm, &mmrange);
 			goto release_object;
 		}
 
 		radeon_ttm_placement_from_domain(bo, RADEON_GEM_DOMAIN_GTT);
 		r = ttm_bo_validate(&bo->tbo, &bo->placement, &ctx);
 		radeon_bo_unreserve(bo);
-		up_read(&current->mm->mmap_sem);
+		mm_read_unlock(current->mm, &mmrange);
 		if (r)
 			goto release_object;
 	}
diff --git a/drivers/gpu/drm/radeon/radeon_mn.c b/drivers/gpu/drm/radeon/radeon_mn.c
index abd24975c9b1..9b10cacc5b14 100644
--- a/drivers/gpu/drm/radeon/radeon_mn.c
+++ b/drivers/gpu/drm/radeon/radeon_mn.c
@@ -186,8 +186,9 @@ static struct radeon_mn *radeon_mn_get(struct radeon_device *rdev)
 	struct mm_struct *mm = current->mm;
 	struct radeon_mn *rmn;
 	int r;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
-	if (down_write_killable(&mm->mmap_sem))
+	if (mm_write_lock_killable(mm, &mmrange))
 		return ERR_PTR(-EINTR);
 
 	mutex_lock(&rdev->mn_lock);
@@ -216,13 +217,13 @@ static struct radeon_mn *radeon_mn_get(struct radeon_device *rdev)
 
 release_locks:
 	mutex_unlock(&rdev->mn_lock);
-	up_write(&mm->mmap_sem);
+	mm_write_unlock(mm, &mmrange);
 
 	return rmn;
 
 free_rmn:
 	mutex_unlock(&rdev->mn_lock);
-	up_write(&mm->mmap_sem);
+	mm_write_unlock(mm, &mmrange);
 	kfree(rmn);
 
 	return ERR_PTR(r);
diff --git a/drivers/gpu/drm/ttm/ttm_bo_vm.c b/drivers/gpu/drm/ttm/ttm_bo_vm.c
index 08a3c324242e..2b2a1668fbe3 100644
--- a/drivers/gpu/drm/ttm/ttm_bo_vm.c
+++ b/drivers/gpu/drm/ttm/ttm_bo_vm.c
@@ -67,7 +67,7 @@ static int ttm_bo_vm_fault_idle(struct ttm_buffer_object *bo,
 			goto out_unlock;
 
 		ttm_bo_reference(bo);
-		up_read(&vmf->vma->vm_mm->mmap_sem);
+		mm_read_unlock(vmf->vma->vm_mm, vmf->lockrange);
 		(void) dma_fence_wait(bo->moving, true);
 		ttm_bo_unreserve(bo);
 		ttm_bo_unref(&bo);
@@ -137,7 +137,7 @@ static int ttm_bo_vm_fault(struct vm_fault *vmf)
 		if (vmf->flags & FAULT_FLAG_ALLOW_RETRY) {
 			if (!(vmf->flags & FAULT_FLAG_RETRY_NOWAIT)) {
 				ttm_bo_reference(bo);
-				up_read(&vmf->vma->vm_mm->mmap_sem);
+				mm_read_unlock(vmf->vma->vm_mm, vmf->lockrange);
 				(void) ttm_bo_wait_unreserved(bo);
 				ttm_bo_unref(&bo);
 			}
-- 
2.13.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
