Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 286536B0069
	for <linux-mm@kvack.org>; Mon, 11 Dec 2017 17:12:00 -0500 (EST)
Received: by mail-it0-f70.google.com with SMTP id 14so13475960itm.6
        for <linux-mm@kvack.org>; Mon, 11 Dec 2017 14:12:00 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a124sor503260itg.111.2017.12.11.14.11.58
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 11 Dec 2017 14:11:58 -0800 (PST)
Date: Mon, 11 Dec 2017 14:11:55 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: [patch 1/2] mm, mmu_notifier: annotate mmu notifiers with blockable
 invalidate callbacks
Message-ID: <alpine.DEB.2.10.1712111409090.196232@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.com>, Andrea Arcangeli <aarcange@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Oded Gabbay <oded.gabbay@gmail.com>, Alex Deucher <alexander.deucher@amd.com>, =?UTF-8?Q?Christian_K=C3=B6nig?= <christian.koenig@amd.com>, David Airlie <airlied@linux.ie>, Joerg Roedel <joro@8bytes.org>, Doug Ledford <dledford@redhat.com>, Jani Nikula <jani.nikula@linux.intel.com>, Mike Marciniszyn <mike.marciniszyn@intel.com>, Sean Hefty <sean.hefty@intel.com>, Dimitri Sivanich <sivanich@sgi.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, =?UTF-8?Q?J=C3=A9r=C3=B4me_Glisse?= <jglisse@redhat.com>, Paolo Bonzini <pbonzini@redhat.com>, =?UTF-8?Q?Radim_Kr=C4=8Dm=C3=A1=C5=99?= <rkrcmar@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Commit 4d4bbd8526a8 ("mm, oom_reaper: skip mm structs with mmu notifiers")
prevented the oom reaper from unmapping private anonymous memory with the
oom reaper when the oom victim mm had mmu notifiers registered.

The rationale is that doing mmu_notifier_invalidate_range_{start,end}()
around the unmap_page_range(), which is needed, can block and the oom
killer will stall forever waiting for the victim to exit, which may not
be possible without reaping.

That concern is real, but only true for mmu notifiers that have blockable
invalidate_range_{start,end}() callbacks.  This patch adds a "flags" field
for mmu notifiers that can set a bit to indicate that these callbacks do
block.

The implementation is steered toward an expensive slowpath, such as after
the oom reaper has grabbed mm->mmap_sem of a still alive oom victim.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 arch/powerpc/platforms/powernv/npu-dma.c |  1 +
 drivers/gpu/drm/amd/amdgpu/amdgpu_mn.c   |  1 +
 drivers/gpu/drm/amd/amdkfd/kfd_process.c |  1 +
 drivers/gpu/drm/i915/i915_gem_userptr.c  |  1 +
 drivers/gpu/drm/radeon/radeon_mn.c       |  5 +++--
 drivers/infiniband/core/umem_odp.c       |  1 +
 drivers/infiniband/hw/hfi1/mmu_rb.c      |  1 +
 drivers/iommu/amd_iommu_v2.c             |  1 +
 drivers/iommu/intel-svm.c                |  1 +
 drivers/misc/mic/scif/scif_dma.c         |  1 +
 drivers/misc/sgi-gru/grutlbpurge.c       |  1 +
 drivers/xen/gntdev.c                     |  1 +
 include/linux/mmu_notifier.h             | 13 +++++++++++++
 mm/hmm.c                                 |  1 +
 mm/mmu_notifier.c                        | 25 +++++++++++++++++++++++++
 virt/kvm/kvm_main.c                      |  1 +
 16 files changed, 54 insertions(+), 2 deletions(-)

diff --git a/arch/powerpc/platforms/powernv/npu-dma.c b/arch/powerpc/platforms/powernv/npu-dma.c
--- a/arch/powerpc/platforms/powernv/npu-dma.c
+++ b/arch/powerpc/platforms/powernv/npu-dma.c
@@ -710,6 +710,7 @@ struct npu_context *pnv_npu2_init_context(struct pci_dev *gpdev,
 
 		mm->context.npu_context = npu_context;
 		npu_context->mm = mm;
+		npu_content->mn.flags = MMU_INVALIDATE_MAY_BLOCK;
 		npu_context->mn.ops = &nv_nmmu_notifier_ops;
 		__mmu_notifier_register(&npu_context->mn, mm);
 		kref_init(&npu_context->kref);
diff --git a/drivers/gpu/drm/amd/amdgpu/amdgpu_mn.c b/drivers/gpu/drm/amd/amdgpu/amdgpu_mn.c
--- a/drivers/gpu/drm/amd/amdgpu/amdgpu_mn.c
+++ b/drivers/gpu/drm/amd/amdgpu/amdgpu_mn.c
@@ -276,6 +276,7 @@ struct amdgpu_mn *amdgpu_mn_get(struct amdgpu_device *adev)
 
 	rmn->adev = adev;
 	rmn->mm = mm;
+	rmn->mn.flags = MMU_INVALIDATE_MAY_BLOCK;
 	rmn->mn.ops = &amdgpu_mn_ops;
 	init_rwsem(&rmn->lock);
 	rmn->objects = RB_ROOT_CACHED;
diff --git a/drivers/gpu/drm/amd/amdkfd/kfd_process.c b/drivers/gpu/drm/amd/amdkfd/kfd_process.c
--- a/drivers/gpu/drm/amd/amdkfd/kfd_process.c
+++ b/drivers/gpu/drm/amd/amdkfd/kfd_process.c
@@ -282,6 +282,7 @@ static struct kfd_process *create_process(const struct task_struct *thread)
 	process->mm = thread->mm;
 
 	/* register notifier */
+	process->mmu_notifier.flags = 0;
 	process->mmu_notifier.ops = &kfd_process_mmu_notifier_ops;
 	err = __mmu_notifier_register(&process->mmu_notifier, process->mm);
 	if (err)
diff --git a/drivers/gpu/drm/i915/i915_gem_userptr.c b/drivers/gpu/drm/i915/i915_gem_userptr.c
--- a/drivers/gpu/drm/i915/i915_gem_userptr.c
+++ b/drivers/gpu/drm/i915/i915_gem_userptr.c
@@ -170,6 +170,7 @@ i915_mmu_notifier_create(struct mm_struct *mm)
 		return ERR_PTR(-ENOMEM);
 
 	spin_lock_init(&mn->lock);
+	mn->mn.flags = MMU_INVALIDATE_MAY_BLOCK;
 	mn->mn.ops = &i915_gem_userptr_notifier;
 	mn->objects = RB_ROOT_CACHED;
 	mn->wq = alloc_workqueue("i915-userptr-release",
diff --git a/drivers/gpu/drm/radeon/radeon_mn.c b/drivers/gpu/drm/radeon/radeon_mn.c
--- a/drivers/gpu/drm/radeon/radeon_mn.c
+++ b/drivers/gpu/drm/radeon/radeon_mn.c
@@ -164,7 +164,7 @@ static void radeon_mn_invalidate_range_start(struct mmu_notifier *mn,
 			radeon_bo_unreserve(bo);
 		}
 	}
-	
+
 	mutex_unlock(&rmn->lock);
 }
 
@@ -203,10 +203,11 @@ static struct radeon_mn *radeon_mn_get(struct radeon_device *rdev)
 
 	rmn->rdev = rdev;
 	rmn->mm = mm;
+	rmn->mn.flags = MMU_INVALIDATE_MAY_BLOCK;
 	rmn->mn.ops = &radeon_mn_ops;
 	mutex_init(&rmn->lock);
 	rmn->objects = RB_ROOT_CACHED;
-	
+
 	r = __mmu_notifier_register(&rmn->mn, mm);
 	if (r)
 		goto free_rmn;
diff --git a/drivers/infiniband/core/umem_odp.c b/drivers/infiniband/core/umem_odp.c
--- a/drivers/infiniband/core/umem_odp.c
+++ b/drivers/infiniband/core/umem_odp.c
@@ -411,6 +411,7 @@ int ib_umem_odp_get(struct ib_ucontext *context, struct ib_umem *umem,
 		 */
 		atomic_set(&context->notifier_count, 0);
 		INIT_HLIST_NODE(&context->mn.hlist);
+		context->mn.flags = MMU_INVALIDATE_MAY_BLOCK;
 		context->mn.ops = &ib_umem_notifiers;
 		/*
 		 * Lock-dep detects a false positive for mmap_sem vs.
diff --git a/drivers/infiniband/hw/hfi1/mmu_rb.c b/drivers/infiniband/hw/hfi1/mmu_rb.c
--- a/drivers/infiniband/hw/hfi1/mmu_rb.c
+++ b/drivers/infiniband/hw/hfi1/mmu_rb.c
@@ -110,6 +110,7 @@ int hfi1_mmu_rb_register(void *ops_arg, struct mm_struct *mm,
 	handlr->ops_arg = ops_arg;
 	INIT_HLIST_NODE(&handlr->mn.hlist);
 	spin_lock_init(&handlr->lock);
+	handlr->mn.flags = 0;
 	handlr->mn.ops = &mn_opts;
 	handlr->mm = mm;
 	INIT_WORK(&handlr->del_work, handle_remove);
diff --git a/drivers/iommu/amd_iommu_v2.c b/drivers/iommu/amd_iommu_v2.c
--- a/drivers/iommu/amd_iommu_v2.c
+++ b/drivers/iommu/amd_iommu_v2.c
@@ -671,6 +671,7 @@ int amd_iommu_bind_pasid(struct pci_dev *pdev, int pasid,
 	pasid_state->pasid        = pasid;
 	pasid_state->invalid      = true; /* Mark as valid only if we are
 					     done with setting up the pasid */
+	pasid_state->mn.flags     = 0;
 	pasid_state->mn.ops       = &iommu_mn;
 
 	if (pasid_state->mm == NULL)
diff --git a/drivers/iommu/intel-svm.c b/drivers/iommu/intel-svm.c
--- a/drivers/iommu/intel-svm.c
+++ b/drivers/iommu/intel-svm.c
@@ -382,6 +382,7 @@ int intel_svm_bind_mm(struct device *dev, int *pasid, int flags, struct svm_dev_
 			goto out;
 		}
 		svm->pasid = ret;
+		svm->notifier.flags = 0;
 		svm->notifier.ops = &intel_mmuops;
 		svm->mm = mm;
 		svm->flags = flags;
diff --git a/drivers/misc/mic/scif/scif_dma.c b/drivers/misc/mic/scif/scif_dma.c
--- a/drivers/misc/mic/scif/scif_dma.c
+++ b/drivers/misc/mic/scif/scif_dma.c
@@ -249,6 +249,7 @@ static void scif_init_mmu_notifier(struct scif_mmu_notif *mmn,
 {
 	mmn->ep = ep;
 	mmn->mm = mm;
+	mmn->ep_mmu_notifier.flags = MMU_INVALIDATE_MAY_BLOCK;
 	mmn->ep_mmu_notifier.ops = &scif_mmu_notifier_ops;
 	INIT_LIST_HEAD(&mmn->list);
 	INIT_LIST_HEAD(&mmn->tc_reg_list);
diff --git a/drivers/misc/sgi-gru/grutlbpurge.c b/drivers/misc/sgi-gru/grutlbpurge.c
--- a/drivers/misc/sgi-gru/grutlbpurge.c
+++ b/drivers/misc/sgi-gru/grutlbpurge.c
@@ -298,6 +298,7 @@ struct gru_mm_struct *gru_register_mmu_notifier(void)
 			return ERR_PTR(-ENOMEM);
 		STAT(gms_alloc);
 		spin_lock_init(&gms->ms_asid_lock);
+		gms->ms_notifier.flags = 0;
 		gms->ms_notifier.ops = &gru_mmuops;
 		atomic_set(&gms->ms_refcnt, 1);
 		init_waitqueue_head(&gms->ms_wait_queue);
diff --git a/drivers/xen/gntdev.c b/drivers/xen/gntdev.c
--- a/drivers/xen/gntdev.c
+++ b/drivers/xen/gntdev.c
@@ -539,6 +539,7 @@ static int gntdev_open(struct inode *inode, struct file *flip)
 			kfree(priv);
 			return -ENOMEM;
 		}
+		priv->mn.flags = MMU_INVALIDATE_MAY_BLOCK;
 		priv->mn.ops = &gntdev_mmu_ops;
 		ret = mmu_notifier_register(&priv->mn, priv->mm);
 		mmput(priv->mm);
diff --git a/include/linux/mmu_notifier.h b/include/linux/mmu_notifier.h
--- a/include/linux/mmu_notifier.h
+++ b/include/linux/mmu_notifier.h
@@ -10,6 +10,9 @@
 struct mmu_notifier;
 struct mmu_notifier_ops;
 
+/* This mmu notifier's invalidate_{start,end}() callbacks may block */
+#define MMU_INVALIDATE_MAY_BLOCK	(0x01)
+
 #ifdef CONFIG_MMU_NOTIFIER
 
 /*
@@ -137,6 +140,9 @@ struct mmu_notifier_ops {
 	 * page. Pages will no longer be referenced by the linux
 	 * address space but may still be referenced by sptes until
 	 * the last refcount is dropped.
+	 *
+	 * If either of these callbacks can block, the mmu_notifier.flags
+	 * must have MMU_INVALIDATE_MAY_BLOCK set.
 	 */
 	void (*invalidate_range_start)(struct mmu_notifier *mn,
 				       struct mm_struct *mm,
@@ -182,6 +188,7 @@ struct mmu_notifier_ops {
  * 3. No other concurrent thread can access the list (release)
  */
 struct mmu_notifier {
+	int flags;
 	struct hlist_node hlist;
 	const struct mmu_notifier_ops *ops;
 };
@@ -218,6 +225,7 @@ extern void __mmu_notifier_invalidate_range_end(struct mm_struct *mm,
 				  bool only_end);
 extern void __mmu_notifier_invalidate_range(struct mm_struct *mm,
 				  unsigned long start, unsigned long end);
+extern int mm_has_blockable_invalidate_notifiers(struct mm_struct *mm);
 
 static inline void mmu_notifier_release(struct mm_struct *mm)
 {
@@ -457,6 +465,11 @@ static inline void mmu_notifier_invalidate_range(struct mm_struct *mm,
 {
 }
 
+static inline int mm_has_blockable_invalidate_notifiers(struct mm_struct *mm)
+{
+	return 0;
+}
+
 static inline void mmu_notifier_mm_init(struct mm_struct *mm)
 {
 }
diff --git a/mm/hmm.c b/mm/hmm.c
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -104,6 +104,7 @@ static struct hmm *hmm_register(struct mm_struct *mm)
 	 * We should only get here if hold the mmap_sem in write mode ie on
 	 * registration of first mirror through hmm_mirror_register()
 	 */
+	hmm->mmu_notifier.flags = MMU_INVALIDATE_MAY_BLOCK;
 	hmm->mmu_notifier.ops = &hmm_mmu_notifier_ops;
 	if (__mmu_notifier_register(&hmm->mmu_notifier, mm)) {
 		kfree(hmm);
diff --git a/mm/mmu_notifier.c b/mm/mmu_notifier.c
--- a/mm/mmu_notifier.c
+++ b/mm/mmu_notifier.c
@@ -236,6 +236,31 @@ void __mmu_notifier_invalidate_range(struct mm_struct *mm,
 }
 EXPORT_SYMBOL_GPL(__mmu_notifier_invalidate_range);
 
+/*
+ * Must be called while holding mm->mmap_sem for either read or write.
+ * The result is guaranteed to be valid until mm->mmap_sem is dropped.
+ */
+int mm_has_blockable_invalidate_notifiers(struct mm_struct *mm)
+{
+	struct mmu_notifier *mn;
+	int id;
+	int ret = 0;
+
+	WARN_ON_ONCE(down_write_trylock(&mm->mmap_sem));
+
+	if (!mm_has_notifiers(mm))
+		return ret;
+
+	id = srcu_read_lock(&srcu);
+	hlist_for_each_entry_rcu(mn, &mm->mmu_notifier_mm->list, hlist)
+		if (mn->flags & MMU_INVALIDATE_MAY_BLOCK) {
+			ret = 1;
+			break;
+		}
+	srcu_read_unlock(&srcu, id);
+	return ret;
+}
+
 static int do_mmu_notifier_register(struct mmu_notifier *mn,
 				    struct mm_struct *mm,
 				    int take_mmap_sem)
diff --git a/virt/kvm/kvm_main.c b/virt/kvm/kvm_main.c
--- a/virt/kvm/kvm_main.c
+++ b/virt/kvm/kvm_main.c
@@ -487,6 +487,7 @@ static const struct mmu_notifier_ops kvm_mmu_notifier_ops = {
 
 static int kvm_init_mmu_notifier(struct kvm *kvm)
 {
+	kvm->mmu_notifier.flags = 0;
 	kvm->mmu_notifier.ops = &kvm_mmu_notifier_ops;
 	return mmu_notifier_register(&kvm->mmu_notifier, current->mm);
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
