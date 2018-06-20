Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id A682C6B0003
	for <linux-mm@kvack.org>; Wed, 20 Jun 2018 09:03:47 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id w21-v6so2147320wmc.4
        for <linux-mm@kvack.org>; Wed, 20 Jun 2018 06:03:47 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t13-v6si1274308edd.412.2018.06.20.06.03.42
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 20 Jun 2018 06:03:42 -0700 (PDT)
Date: Wed, 20 Jun 2018 15:03:11 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [patch] mm, oom: fix unnecessary killing of additional processes
Message-ID: <20180620130311.GM13685@dhcp22.suse.cz>
References: <alpine.DEB.2.21.1805241422070.182300@chino.kir.corp.google.com>
 <alpine.DEB.2.21.1806141339580.4543@chino.kir.corp.google.com>
 <20180615065541.GA24039@dhcp22.suse.cz>
 <alpine.DEB.2.21.1806151559360.49038@chino.kir.corp.google.com>
 <20180619083316.GB13685@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180619083316.GB13685@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue 19-06-18 10:33:16, Michal Hocko wrote:
[...]
> As I've said, if you are not willing to work on a proper solution, I
> will, but my nack holds for this patch until we see no other way around
> existing and real world problems.

OK, so I gave it a quick try and it doesn't look all that bad to me.
This is only for blockable mmu notifiers.  I didn't really try to
address all the problems down the road - I mean some of the blocking
notifiers can check the range in their interval tree without blocking
locks. It is quite probable that only few ranges will be of interest,
right?

So this is only to give an idea about the change. It probably even
doesn't compile. Does that sound sane?
---
diff --git a/arch/x86/kvm/x86.c b/arch/x86/kvm/x86.c
index 6bcecc325e7e..ac08f5d711be 100644
--- a/arch/x86/kvm/x86.c
+++ b/arch/x86/kvm/x86.c
@@ -7203,8 +7203,9 @@ static void vcpu_load_eoi_exitmap(struct kvm_vcpu *vcpu)
 	kvm_x86_ops->load_eoi_exitmap(vcpu, eoi_exit_bitmap);
 }
 
-void kvm_arch_mmu_notifier_invalidate_range(struct kvm *kvm,
-		unsigned long start, unsigned long end)
+int kvm_arch_mmu_notifier_invalidate_range(struct kvm *kvm,
+		unsigned long start, unsigned long end,
+		bool blockable)
 {
 	unsigned long apic_address;
 
@@ -7215,6 +7216,8 @@ void kvm_arch_mmu_notifier_invalidate_range(struct kvm *kvm,
 	apic_address = gfn_to_hva(kvm, APIC_DEFAULT_PHYS_BASE >> PAGE_SHIFT);
 	if (start <= apic_address && apic_address < end)
 		kvm_make_all_cpus_request(kvm, KVM_REQ_APIC_PAGE_RELOAD);
+
+	return 0;
 }
 
 void kvm_vcpu_reload_apic_access_page(struct kvm_vcpu *vcpu)
diff --git a/drivers/gpu/drm/amd/amdgpu/amdgpu_mn.c b/drivers/gpu/drm/amd/amdgpu/amdgpu_mn.c
index 83e344fbb50a..d138a526feff 100644
--- a/drivers/gpu/drm/amd/amdgpu/amdgpu_mn.c
+++ b/drivers/gpu/drm/amd/amdgpu/amdgpu_mn.c
@@ -136,12 +136,18 @@ void amdgpu_mn_unlock(struct amdgpu_mn *mn)
  *
  * Take the rmn read side lock.
  */
-static void amdgpu_mn_read_lock(struct amdgpu_mn *rmn)
+static int amdgpu_mn_read_lock(struct amdgpu_mn *rmn, bool blockable)
 {
-	mutex_lock(&rmn->read_lock);
+	if (blockable)
+		mutex_lock(&rmn->read_lock);
+	else if (!mutex_trylock(&rmn->read_lock))
+		return -EAGAIN;
+
 	if (atomic_inc_return(&rmn->recursion) == 1)
 		down_read_non_owner(&rmn->lock);
 	mutex_unlock(&rmn->read_lock);
+
+	return 0;
 }
 
 /**
@@ -197,10 +203,11 @@ static void amdgpu_mn_invalidate_node(struct amdgpu_mn_node *node,
  * We block for all BOs between start and end to be idle and
  * unmap them by move them into system domain again.
  */
-static void amdgpu_mn_invalidate_range_start_gfx(struct mmu_notifier *mn,
+static int amdgpu_mn_invalidate_range_start_gfx(struct mmu_notifier *mn,
 						 struct mm_struct *mm,
 						 unsigned long start,
-						 unsigned long end)
+						 unsigned long end,
+						 bool blockable)
 {
 	struct amdgpu_mn *rmn = container_of(mn, struct amdgpu_mn, mn);
 	struct interval_tree_node *it;
@@ -208,7 +215,11 @@ static void amdgpu_mn_invalidate_range_start_gfx(struct mmu_notifier *mn,
 	/* notification is exclusive, but interval is inclusive */
 	end -= 1;
 
-	amdgpu_mn_read_lock(rmn);
+	/* TODO we should be able to split locking for interval tree and
+	 * amdgpu_mn_invalidate_node
+	 */
+	if (amdgpu_mn_read_lock(rmn, blockable))
+		return -EAGAIN;
 
 	it = interval_tree_iter_first(&rmn->objects, start, end);
 	while (it) {
@@ -219,6 +230,8 @@ static void amdgpu_mn_invalidate_range_start_gfx(struct mmu_notifier *mn,
 
 		amdgpu_mn_invalidate_node(node, start, end);
 	}
+
+	return 0;
 }
 
 /**
@@ -233,10 +246,11 @@ static void amdgpu_mn_invalidate_range_start_gfx(struct mmu_notifier *mn,
  * necessitates evicting all user-mode queues of the process. The BOs
  * are restorted in amdgpu_mn_invalidate_range_end_hsa.
  */
-static void amdgpu_mn_invalidate_range_start_hsa(struct mmu_notifier *mn,
+static int amdgpu_mn_invalidate_range_start_hsa(struct mmu_notifier *mn,
 						 struct mm_struct *mm,
 						 unsigned long start,
-						 unsigned long end)
+						 unsigned long end,
+						 bool blockable)
 {
 	struct amdgpu_mn *rmn = container_of(mn, struct amdgpu_mn, mn);
 	struct interval_tree_node *it;
@@ -244,7 +258,8 @@ static void amdgpu_mn_invalidate_range_start_hsa(struct mmu_notifier *mn,
 	/* notification is exclusive, but interval is inclusive */
 	end -= 1;
 
-	amdgpu_mn_read_lock(rmn);
+	if (amdgpu_mn_read_lock(rmn, blockable))
+		return -EAGAIN;
 
 	it = interval_tree_iter_first(&rmn->objects, start, end);
 	while (it) {
@@ -262,6 +277,8 @@ static void amdgpu_mn_invalidate_range_start_hsa(struct mmu_notifier *mn,
 				amdgpu_amdkfd_evict_userptr(mem, mm);
 		}
 	}
+
+	return 0;
 }
 
 /**
diff --git a/drivers/gpu/drm/i915/i915_gem_userptr.c b/drivers/gpu/drm/i915/i915_gem_userptr.c
index 854bd51b9478..5285df9331fa 100644
--- a/drivers/gpu/drm/i915/i915_gem_userptr.c
+++ b/drivers/gpu/drm/i915/i915_gem_userptr.c
@@ -112,10 +112,11 @@ static void del_object(struct i915_mmu_object *mo)
 	mo->attached = false;
 }
 
-static void i915_gem_userptr_mn_invalidate_range_start(struct mmu_notifier *_mn,
+static int i915_gem_userptr_mn_invalidate_range_start(struct mmu_notifier *_mn,
 						       struct mm_struct *mm,
 						       unsigned long start,
-						       unsigned long end)
+						       unsigned long end,
+						       bool blockable)
 {
 	struct i915_mmu_notifier *mn =
 		container_of(_mn, struct i915_mmu_notifier, mn);
@@ -124,7 +125,7 @@ static void i915_gem_userptr_mn_invalidate_range_start(struct mmu_notifier *_mn,
 	LIST_HEAD(cancelled);
 
 	if (RB_EMPTY_ROOT(&mn->objects.rb_root))
-		return;
+		return 0;
 
 	/* interval ranges are inclusive, but invalidate range is exclusive */
 	end--;
@@ -152,7 +153,8 @@ static void i915_gem_userptr_mn_invalidate_range_start(struct mmu_notifier *_mn,
 		del_object(mo);
 	spin_unlock(&mn->lock);
 
-	if (!list_empty(&cancelled))
+	/* TODO: can we skip waiting here? */
+	if (!list_empty(&cancelled) && blockable)
 		flush_workqueue(mn->wq);
 }
 
diff --git a/drivers/gpu/drm/radeon/radeon_mn.c b/drivers/gpu/drm/radeon/radeon_mn.c
index abd24975c9b1..b47e828b725d 100644
--- a/drivers/gpu/drm/radeon/radeon_mn.c
+++ b/drivers/gpu/drm/radeon/radeon_mn.c
@@ -118,10 +118,11 @@ static void radeon_mn_release(struct mmu_notifier *mn,
  * We block for all BOs between start and end to be idle and
  * unmap them by move them into system domain again.
  */
-static void radeon_mn_invalidate_range_start(struct mmu_notifier *mn,
+static int radeon_mn_invalidate_range_start(struct mmu_notifier *mn,
 					     struct mm_struct *mm,
 					     unsigned long start,
-					     unsigned long end)
+					     unsigned long end,
+					     bool blockable)
 {
 	struct radeon_mn *rmn = container_of(mn, struct radeon_mn, mn);
 	struct ttm_operation_ctx ctx = { false, false };
@@ -130,7 +131,13 @@ static void radeon_mn_invalidate_range_start(struct mmu_notifier *mn,
 	/* notification is exclusive, but interval is inclusive */
 	end -= 1;
 
-	mutex_lock(&rmn->lock);
+	/* TODO we should be able to split locking for interval tree and
+	 * the tear down.
+	 */
+	if (blockable)
+		mutex_lock(&rmn->lock);
+	else if (!mutex_trylock(&rmn->lock))
+		return -EAGAIN;
 
 	it = interval_tree_iter_first(&rmn->objects, start, end);
 	while (it) {
@@ -167,6 +174,8 @@ static void radeon_mn_invalidate_range_start(struct mmu_notifier *mn,
 	}
 	
 	mutex_unlock(&rmn->lock);
+
+	return 0;
 }
 
 static const struct mmu_notifier_ops radeon_mn_ops = {
diff --git a/drivers/infiniband/core/umem_odp.c b/drivers/infiniband/core/umem_odp.c
index 182436b92ba9..f65f6a29daae 100644
--- a/drivers/infiniband/core/umem_odp.c
+++ b/drivers/infiniband/core/umem_odp.c
@@ -207,22 +207,29 @@ static int invalidate_range_start_trampoline(struct ib_umem *item, u64 start,
 	return 0;
 }
 
-static void ib_umem_notifier_invalidate_range_start(struct mmu_notifier *mn,
+static int ib_umem_notifier_invalidate_range_start(struct mmu_notifier *mn,
 						    struct mm_struct *mm,
 						    unsigned long start,
-						    unsigned long end)
+						    unsigned long end,
+						    bool blockable)
 {
 	struct ib_ucontext *context = container_of(mn, struct ib_ucontext, mn);
 
 	if (!context->invalidate_range)
-		return;
+		return 0;
+
+	if (blockable)
+		down_read(&context->umem_rwsem);
+	else if (!down_read_trylock(&context->umem_rwsem))
+		return -EAGAIN;
 
 	ib_ucontext_notifier_start_account(context);
-	down_read(&context->umem_rwsem);
 	rbt_ib_umem_for_each_in_range(&context->umem_tree, start,
 				      end,
 				      invalidate_range_start_trampoline, NULL);
 	up_read(&context->umem_rwsem);
+
+	return 0;
 }
 
 static int invalidate_range_end_trampoline(struct ib_umem *item, u64 start,
diff --git a/drivers/infiniband/hw/hfi1/mmu_rb.c b/drivers/infiniband/hw/hfi1/mmu_rb.c
index 70aceefe14d5..8780560d1623 100644
--- a/drivers/infiniband/hw/hfi1/mmu_rb.c
+++ b/drivers/infiniband/hw/hfi1/mmu_rb.c
@@ -284,10 +284,11 @@ void hfi1_mmu_rb_remove(struct mmu_rb_handler *handler,
 	handler->ops->remove(handler->ops_arg, node);
 }
 
-static void mmu_notifier_range_start(struct mmu_notifier *mn,
+static int mmu_notifier_range_start(struct mmu_notifier *mn,
 				     struct mm_struct *mm,
 				     unsigned long start,
-				     unsigned long end)
+				     unsigned long end,
+				     bool blockable)
 {
 	struct mmu_rb_handler *handler =
 		container_of(mn, struct mmu_rb_handler, mn);
@@ -313,6 +314,8 @@ static void mmu_notifier_range_start(struct mmu_notifier *mn,
 
 	if (added)
 		queue_work(handler->wq, &handler->del_work);
+
+	return 0;
 }
 
 /*
diff --git a/drivers/misc/mic/scif/scif_dma.c b/drivers/misc/mic/scif/scif_dma.c
index 63d6246d6dff..d940568bed87 100644
--- a/drivers/misc/mic/scif/scif_dma.c
+++ b/drivers/misc/mic/scif/scif_dma.c
@@ -200,15 +200,18 @@ static void scif_mmu_notifier_release(struct mmu_notifier *mn,
 	schedule_work(&scif_info.misc_work);
 }
 
-static void scif_mmu_notifier_invalidate_range_start(struct mmu_notifier *mn,
+static int scif_mmu_notifier_invalidate_range_start(struct mmu_notifier *mn,
 						     struct mm_struct *mm,
 						     unsigned long start,
-						     unsigned long end)
+						     unsigned long end,
+						     bool blockable)
 {
 	struct scif_mmu_notif	*mmn;
 
 	mmn = container_of(mn, struct scif_mmu_notif, ep_mmu_notifier);
 	scif_rma_destroy_tcw(mmn, start, end - start);
+
+	return 0
 }
 
 static void scif_mmu_notifier_invalidate_range_end(struct mmu_notifier *mn,
diff --git a/drivers/misc/sgi-gru/grutlbpurge.c b/drivers/misc/sgi-gru/grutlbpurge.c
index a3454eb56fbf..be28f05bfafa 100644
--- a/drivers/misc/sgi-gru/grutlbpurge.c
+++ b/drivers/misc/sgi-gru/grutlbpurge.c
@@ -219,9 +219,10 @@ void gru_flush_all_tlb(struct gru_state *gru)
 /*
  * MMUOPS notifier callout functions
  */
-static void gru_invalidate_range_start(struct mmu_notifier *mn,
+static int gru_invalidate_range_start(struct mmu_notifier *mn,
 				       struct mm_struct *mm,
-				       unsigned long start, unsigned long end)
+				       unsigned long start, unsigned long end,
+				       bool blockable)
 {
 	struct gru_mm_struct *gms = container_of(mn, struct gru_mm_struct,
 						 ms_notifier);
@@ -231,6 +232,8 @@ static void gru_invalidate_range_start(struct mmu_notifier *mn,
 	gru_dbg(grudev, "gms %p, start 0x%lx, end 0x%lx, act %d\n", gms,
 		start, end, atomic_read(&gms->ms_range_active));
 	gru_flush_tlb_range(gms, start, end - start);
+
+	return 0;
 }
 
 static void gru_invalidate_range_end(struct mmu_notifier *mn,
diff --git a/drivers/xen/gntdev.c b/drivers/xen/gntdev.c
index bd56653b9bbc..50724d09fe5c 100644
--- a/drivers/xen/gntdev.c
+++ b/drivers/xen/gntdev.c
@@ -465,14 +465,20 @@ static void unmap_if_in_range(struct grant_map *map,
 	WARN_ON(err);
 }
 
-static void mn_invl_range_start(struct mmu_notifier *mn,
+static int mn_invl_range_start(struct mmu_notifier *mn,
 				struct mm_struct *mm,
-				unsigned long start, unsigned long end)
+				unsigned long start, unsigned long end,
+				bool blockable)
 {
 	struct gntdev_priv *priv = container_of(mn, struct gntdev_priv, mn);
 	struct grant_map *map;
 
-	mutex_lock(&priv->lock);
+	/* TODO do we really need a mutex here? */
+	if (blockable)
+		mutex_lock(&priv->lock);
+	else if (!mutex_trylock(&priv->lock))
+		return -EAGAIN;
+
 	list_for_each_entry(map, &priv->maps, next) {
 		unmap_if_in_range(map, start, end);
 	}
@@ -480,6 +486,8 @@ static void mn_invl_range_start(struct mmu_notifier *mn,
 		unmap_if_in_range(map, start, end);
 	}
 	mutex_unlock(&priv->lock);
+
+	return true;
 }
 
 static void mn_release(struct mmu_notifier *mn,
diff --git a/include/linux/kvm_host.h b/include/linux/kvm_host.h
index 4ee7bc548a83..e4181063e755 100644
--- a/include/linux/kvm_host.h
+++ b/include/linux/kvm_host.h
@@ -1275,7 +1275,7 @@ static inline long kvm_arch_vcpu_async_ioctl(struct file *filp,
 }
 #endif /* CONFIG_HAVE_KVM_VCPU_ASYNC_IOCTL */
 
-void kvm_arch_mmu_notifier_invalidate_range(struct kvm *kvm,
+int kvm_arch_mmu_notifier_invalidate_range(struct kvm *kvm,
 		unsigned long start, unsigned long end);
 
 #ifdef CONFIG_HAVE_KVM_VCPU_RUN_PID_CHANGE
diff --git a/include/linux/mmu_notifier.h b/include/linux/mmu_notifier.h
index 392e6af82701..369867501bed 100644
--- a/include/linux/mmu_notifier.h
+++ b/include/linux/mmu_notifier.h
@@ -230,7 +230,8 @@ extern int __mmu_notifier_test_young(struct mm_struct *mm,
 extern void __mmu_notifier_change_pte(struct mm_struct *mm,
 				      unsigned long address, pte_t pte);
 extern void __mmu_notifier_invalidate_range_start(struct mm_struct *mm,
-				  unsigned long start, unsigned long end);
+				  unsigned long start, unsigned long end,
+				  bool blockable);
 extern void __mmu_notifier_invalidate_range_end(struct mm_struct *mm,
 				  unsigned long start, unsigned long end,
 				  bool only_end);
@@ -281,7 +282,17 @@ static inline void mmu_notifier_invalidate_range_start(struct mm_struct *mm,
 				  unsigned long start, unsigned long end)
 {
 	if (mm_has_notifiers(mm))
-		__mmu_notifier_invalidate_range_start(mm, start, end);
+		__mmu_notifier_invalidate_range_start(mm, start, end, true);
+}
+
+static inline int mmu_notifier_invalidate_range_start_nonblock(struct mm_struct *mm,
+				  unsigned long start, unsigned long end)
+{
+	int ret = 0;
+	if (mm_has_notifiers(mm))
+		ret = __mmu_notifier_invalidate_range_start(mm, start, end, false);
+
+	return ret;
 }
 
 static inline void mmu_notifier_invalidate_range_end(struct mm_struct *mm,
diff --git a/mm/hmm.c b/mm/hmm.c
index de7b6bf77201..81fd57bd2634 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -177,16 +177,19 @@ static void hmm_release(struct mmu_notifier *mn, struct mm_struct *mm)
 	up_write(&hmm->mirrors_sem);
 }
 
-static void hmm_invalidate_range_start(struct mmu_notifier *mn,
+static int hmm_invalidate_range_start(struct mmu_notifier *mn,
 				       struct mm_struct *mm,
 				       unsigned long start,
-				       unsigned long end)
+				       unsigned long end,
+				       bool blockable)
 {
 	struct hmm *hmm = mm->hmm;
 
 	VM_BUG_ON(!hmm);
 
 	atomic_inc(&hmm->sequence);
+
+	return 0;
 }
 
 static void hmm_invalidate_range_end(struct mmu_notifier *mn,
diff --git a/mm/mmu_notifier.c b/mm/mmu_notifier.c
index eff6b88a993f..30cc43121da9 100644
--- a/mm/mmu_notifier.c
+++ b/mm/mmu_notifier.c
@@ -174,18 +174,25 @@ void __mmu_notifier_change_pte(struct mm_struct *mm, unsigned long address,
 	srcu_read_unlock(&srcu, id);
 }
 
-void __mmu_notifier_invalidate_range_start(struct mm_struct *mm,
-				  unsigned long start, unsigned long end)
+int __mmu_notifier_invalidate_range_start(struct mm_struct *mm,
+				  unsigned long start, unsigned long end,
+				  bool blockable)
 {
 	struct mmu_notifier *mn;
+	int ret = 0;
 	int id;
 
 	id = srcu_read_lock(&srcu);
 	hlist_for_each_entry_rcu(mn, &mm->mmu_notifier_mm->list, hlist) {
-		if (mn->ops->invalidate_range_start)
-			mn->ops->invalidate_range_start(mn, mm, start, end);
+		if (mn->ops->invalidate_range_start) {
+			int _ret = mn->ops->invalidate_range_start(mn, mm, start, end, blockable);
+			if (_ret)
+				ret = _ret;
+		}
 	}
 	srcu_read_unlock(&srcu, id);
+
+	return ret;
 }
 EXPORT_SYMBOL_GPL(__mmu_notifier_invalidate_range_start);
 
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 84081e77bc51..7e0c6e78ae5c 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -479,9 +479,10 @@ static DECLARE_WAIT_QUEUE_HEAD(oom_reaper_wait);
 static struct task_struct *oom_reaper_list;
 static DEFINE_SPINLOCK(oom_reaper_lock);
 
-void __oom_reap_task_mm(struct mm_struct *mm)
+bool __oom_reap_task_mm(struct mm_struct *mm)
 {
 	struct vm_area_struct *vma;
+	bool ret = true;
 
 	/*
 	 * Tell all users of get_user/copy_from_user etc... that the content
@@ -511,12 +512,17 @@ void __oom_reap_task_mm(struct mm_struct *mm)
 			struct mmu_gather tlb;
 
 			tlb_gather_mmu(&tlb, mm, start, end);
-			mmu_notifier_invalidate_range_start(mm, start, end);
+			if (mmu_notifier_invalidate_range_start_nonblock(mm, start, end)) {
+				ret = false;
+				continue;
+			}
 			unmap_page_range(&tlb, vma, start, end, NULL);
 			mmu_notifier_invalidate_range_end(mm, start, end);
 			tlb_finish_mmu(&tlb, start, end);
 		}
 	}
+
+	return ret;
 }
 
 static bool oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
@@ -545,18 +551,6 @@ static bool oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
 		goto unlock_oom;
 	}
 
-	/*
-	 * If the mm has invalidate_{start,end}() notifiers that could block,
-	 * sleep to give the oom victim some more time.
-	 * TODO: we really want to get rid of this ugly hack and make sure that
-	 * notifiers cannot block for unbounded amount of time
-	 */
-	if (mm_has_blockable_invalidate_notifiers(mm)) {
-		up_read(&mm->mmap_sem);
-		schedule_timeout_idle(HZ);
-		goto unlock_oom;
-	}
-
 	/*
 	 * MMF_OOM_SKIP is set by exit_mmap when the OOM reaper can't
 	 * work on the mm anymore. The check for MMF_OOM_SKIP must run
@@ -571,7 +565,12 @@ static bool oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
 
 	trace_start_task_reaping(tsk->pid);
 
-	__oom_reap_task_mm(mm);
+	/* failed to reap part of the address space. Try again later */
+	if (!__oom_reap_task_mm(mm)) {
+		up_read(&mm->mmap_sem);
+		ret = false;
+		goto out_unlock;
+	}
 
 	pr_info("oom_reaper: reaped process %d (%s), now anon-rss:%lukB, file-rss:%lukB, shmem-rss:%lukB\n",
 			task_pid_nr(tsk), tsk->comm,
diff --git a/virt/kvm/kvm_main.c b/virt/kvm/kvm_main.c
index ada21f47f22b..6f7e709d2944 100644
--- a/virt/kvm/kvm_main.c
+++ b/virt/kvm/kvm_main.c
@@ -135,7 +135,7 @@ static void kvm_uevent_notify_change(unsigned int type, struct kvm *kvm);
 static unsigned long long kvm_createvm_count;
 static unsigned long long kvm_active_vms;
 
-__weak void kvm_arch_mmu_notifier_invalidate_range(struct kvm *kvm,
+__weak int kvm_arch_mmu_notifier_invalidate_range(struct kvm *kvm,
 		unsigned long start, unsigned long end)
 {
 }
@@ -354,13 +354,15 @@ static void kvm_mmu_notifier_change_pte(struct mmu_notifier *mn,
 	srcu_read_unlock(&kvm->srcu, idx);
 }
 
-static void kvm_mmu_notifier_invalidate_range_start(struct mmu_notifier *mn,
+static int kvm_mmu_notifier_invalidate_range_start(struct mmu_notifier *mn,
 						    struct mm_struct *mm,
 						    unsigned long start,
-						    unsigned long end)
+						    unsigned long end,
+						    bool blockable)
 {
 	struct kvm *kvm = mmu_notifier_to_kvm(mn);
 	int need_tlb_flush = 0, idx;
+	int ret;
 
 	idx = srcu_read_lock(&kvm->srcu);
 	spin_lock(&kvm->mmu_lock);
@@ -378,9 +380,11 @@ static void kvm_mmu_notifier_invalidate_range_start(struct mmu_notifier *mn,
 
 	spin_unlock(&kvm->mmu_lock);
 
-	kvm_arch_mmu_notifier_invalidate_range(kvm, start, end);
+	ret = kvm_arch_mmu_notifier_invalidate_range(kvm, start, end, blockable);
 
 	srcu_read_unlock(&kvm->srcu, idx);
+
+	return ret;
 }
 
 static void kvm_mmu_notifier_invalidate_range_end(struct mmu_notifier *mn,
-- 
Michal Hocko
SUSE Labs
