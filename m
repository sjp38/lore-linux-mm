Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6C7996B0008
	for <linux-mm@kvack.org>; Mon,  2 Jul 2018 05:15:18 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id d189-v6so13052976iog.13
        for <linux-mm@kvack.org>; Mon, 02 Jul 2018 02:15:18 -0700 (PDT)
Received: from NAM02-BL2-obe.outbound.protection.outlook.com (mail-bl2nam02on0065.outbound.protection.outlook.com. [104.47.38.65])
        by mx.google.com with ESMTPS id x82-v6si10390420iod.64.2018.07.02.02.15.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 02 Jul 2018 02:15:16 -0700 (PDT)
Subject: Re: [RFC PATCH] mm, oom: distinguish blockable mode for mmu notifiers
References: <20180622150242.16558-1-mhocko@kernel.org>
 <20180627074421.GF32348@dhcp22.suse.cz>
From: =?UTF-8?Q?Christian_K=c3=b6nig?= <christian.koenig@amd.com>
Message-ID: <71f4184c-21ea-5af1-eeb6-bf7787614e2d@amd.com>
Date: Mon, 2 Jul 2018 11:14:58 +0200
MIME-Version: 1.0
In-Reply-To: <20180627074421.GF32348@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, LKML <linux-kernel@vger.kernel.org>
Cc: "David (ChunMing) Zhou" <David1.Zhou@amd.com>, Paolo Bonzini <pbonzini@redhat.com>, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Alex Deucher <alexander.deucher@amd.com>, David Airlie <airlied@linux.ie>, Jani Nikula <jani.nikula@linux.intel.com>, Joonas Lahtinen <joonas.lahtinen@linux.intel.com>, Rodrigo Vivi <rodrigo.vivi@intel.com>, Doug Ledford <dledford@redhat.com>, Jason Gunthorpe <jgg@ziepe.ca>, Mike Marciniszyn <mike.marciniszyn@intel.com>, Dennis Dalessandro <dennis.dalessandro@intel.com>, Sudeep Dutt <sudeep.dutt@intel.com>, Ashutosh Dixit <ashutosh.dixit@intel.com>, Dimitri Sivanich <sivanich@sgi.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, kvm@vger.kernel.org, amd-gfx@lists.freedesktop.org, dri-devel@lists.freedesktop.org, intel-gfx@lists.freedesktop.org, linux-rdma@vger.kernel.org, xen-devel@lists.xenproject.org, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Felix Kuehling <felix.kuehling@amd.com>

Am 27.06.2018 um 09:44 schrieb Michal Hocko:
> This is the v2 of RFC based on the feedback I've received so far. The
> code even compiles as a bonus ;) I haven't runtime tested it yet, mostly
> because I have no idea how.
>
> Any further feedback is highly appreciated of course.

That sounds like it should work and at least the amdgpu changes now look 
good to me on first glance.

Can you split that up further in the usual way? E.g. adding the 
blockable flag in one patch and fixing all implementations of the MMU 
notifier in follow up patches.

This way I'm pretty sure Felix and I can give an rb on the amdgpu/amdkfd 
changes.

Thanks,
Christian.

> ---
>  From ec9a7241bf422b908532c4c33953b0da2655ad05 Mon Sep 17 00:00:00 2001
> From: Michal Hocko <mhocko@suse.com>
> Date: Wed, 20 Jun 2018 15:03:20 +0200
> Subject: [PATCH] mm, oom: distinguish blockable mode for mmu notifiers
> MIME-Version: 1.0
> Content-Type: text/plain; charset=UTF-8
> Content-Transfer-Encoding: 8bit
>
> There are several blockable mmu notifiers which might sleep in
> mmu_notifier_invalidate_range_start and that is a problem for the
> oom_reaper because it needs to guarantee a forward progress so it cannot
> depend on any sleepable locks.
>
> Currently we simply back off and mark an oom victim with blockable mmu
> notifiers as done after a short sleep. That can result in selecting a
> new oom victim prematurely because the previous one still hasn't torn
> its memory down yet.
>
> We can do much better though. Even if mmu notifiers use sleepable locks
> there is no reason to automatically assume those locks are held.
> Moreover majority of notifiers only care about a portion of the address
> space and there is absolutely zero reason to fail when we are unmapping an
> unrelated range. Many notifiers do really block and wait for HW which is
> harder to handle and we have to bail out though.
>
> This patch handles the low hanging fruid. __mmu_notifier_invalidate_range_start
> gets a blockable flag and callbacks are not allowed to sleep if the
> flag is set to false. This is achieved by using trylock instead of the
> sleepable lock for most callbacks and continue as long as we do not
> block down the call chain.
>
> I think we can improve that even further because there is a common
> pattern to do a range lookup first and then do something about that.
> The first part can be done without a sleeping lock in most cases AFAICS.
>
> The oom_reaper end then simply retries if there is at least one notifier
> which couldn't make any progress in !blockable mode. A retry loop is
> already implemented to wait for the mmap_sem and this is basically the
> same thing.
>
> Changes since rfc v1
> - gpu notifiers can sleep while waiting for HW (evict_process_queues_cpsch
>    on a lock and amdgpu_mn_invalidate_node on unbound timeout) make sure
>    we bail out when we have an intersecting range for starter
> - note that a notifier failed to the log for easier debugging
> - back off early in ib_umem_notifier_invalidate_range_start if the
>    callback is called
> - mn_invl_range_start waits for completion down the unmap_grant_pages
>    path so we have to back off early on overlapping ranges
>
> Cc: "David (ChunMing) Zhou" <David1.Zhou@amd.com>
> Cc: Paolo Bonzini <pbonzini@redhat.com>
> Cc: "Radim KrA?mA!A?" <rkrcmar@redhat.com>
> Cc: Alex Deucher <alexander.deucher@amd.com>
> Cc: "Christian KA?nig" <christian.koenig@amd.com>
> Cc: David Airlie <airlied@linux.ie>
> Cc: Jani Nikula <jani.nikula@linux.intel.com>
> Cc: Joonas Lahtinen <joonas.lahtinen@linux.intel.com>
> Cc: Rodrigo Vivi <rodrigo.vivi@intel.com>
> Cc: Doug Ledford <dledford@redhat.com>
> Cc: Jason Gunthorpe <jgg@ziepe.ca>
> Cc: Mike Marciniszyn <mike.marciniszyn@intel.com>
> Cc: Dennis Dalessandro <dennis.dalessandro@intel.com>
> Cc: Sudeep Dutt <sudeep.dutt@intel.com>
> Cc: Ashutosh Dixit <ashutosh.dixit@intel.com>
> Cc: Dimitri Sivanich <sivanich@sgi.com>
> Cc: Boris Ostrovsky <boris.ostrovsky@oracle.com>
> Cc: Juergen Gross <jgross@suse.com>
> Cc: "JA(C)rA'me Glisse" <jglisse@redhat.com>
> Cc: Andrea Arcangeli <aarcange@redhat.com>
> Cc: Felix Kuehling <felix.kuehling@amd.com>
> Cc: kvm@vger.kernel.org (open list:KERNEL VIRTUAL MACHINE FOR X86 (KVM/x86))
> Cc: linux-kernel@vger.kernel.org (open list:X86 ARCHITECTURE (32-BIT AND 64-BIT))
> Cc: amd-gfx@lists.freedesktop.org (open list:RADEON and AMDGPU DRM DRIVERS)
> Cc: dri-devel@lists.freedesktop.org (open list:DRM DRIVERS)
> Cc: intel-gfx@lists.freedesktop.org (open list:INTEL DRM DRIVERS (excluding Poulsbo, Moorestow...)
> Cc: linux-rdma@vger.kernel.org (open list:INFINIBAND SUBSYSTEM)
> Cc: xen-devel@lists.xenproject.org (moderated list:XEN HYPERVISOR INTERFACE)
> Cc: linux-mm@kvack.org (open list:HMM - Heterogeneous Memory Management)
> Reported-by: David Rientjes <rientjes@google.com>
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---
>   arch/x86/kvm/x86.c                      |  7 ++--
>   drivers/gpu/drm/amd/amdgpu/amdgpu_mn.c  | 43 +++++++++++++++++++-----
>   drivers/gpu/drm/i915/i915_gem_userptr.c | 13 ++++++--
>   drivers/gpu/drm/radeon/radeon_mn.c      | 22 +++++++++++--
>   drivers/infiniband/core/umem_odp.c      | 33 +++++++++++++++----
>   drivers/infiniband/hw/hfi1/mmu_rb.c     | 11 ++++---
>   drivers/infiniband/hw/mlx5/odp.c        |  2 +-
>   drivers/misc/mic/scif/scif_dma.c        |  7 ++--
>   drivers/misc/sgi-gru/grutlbpurge.c      |  7 ++--
>   drivers/xen/gntdev.c                    | 44 ++++++++++++++++++++-----
>   include/linux/kvm_host.h                |  4 +--
>   include/linux/mmu_notifier.h            | 35 +++++++++++++++-----
>   include/linux/oom.h                     |  2 +-
>   include/rdma/ib_umem_odp.h              |  3 +-
>   mm/hmm.c                                |  7 ++--
>   mm/mmap.c                               |  2 +-
>   mm/mmu_notifier.c                       | 19 ++++++++---
>   mm/oom_kill.c                           | 29 ++++++++--------
>   virt/kvm/kvm_main.c                     | 15 ++++++---
>   19 files changed, 225 insertions(+), 80 deletions(-)
>
> diff --git a/arch/x86/kvm/x86.c b/arch/x86/kvm/x86.c
> index 6bcecc325e7e..ac08f5d711be 100644
> --- a/arch/x86/kvm/x86.c
> +++ b/arch/x86/kvm/x86.c
> @@ -7203,8 +7203,9 @@ static void vcpu_load_eoi_exitmap(struct kvm_vcpu *vcpu)
>   	kvm_x86_ops->load_eoi_exitmap(vcpu, eoi_exit_bitmap);
>   }
>   
> -void kvm_arch_mmu_notifier_invalidate_range(struct kvm *kvm,
> -		unsigned long start, unsigned long end)
> +int kvm_arch_mmu_notifier_invalidate_range(struct kvm *kvm,
> +		unsigned long start, unsigned long end,
> +		bool blockable)
>   {
>   	unsigned long apic_address;
>   
> @@ -7215,6 +7216,8 @@ void kvm_arch_mmu_notifier_invalidate_range(struct kvm *kvm,
>   	apic_address = gfn_to_hva(kvm, APIC_DEFAULT_PHYS_BASE >> PAGE_SHIFT);
>   	if (start <= apic_address && apic_address < end)
>   		kvm_make_all_cpus_request(kvm, KVM_REQ_APIC_PAGE_RELOAD);
> +
> +	return 0;
>   }
>   
>   void kvm_vcpu_reload_apic_access_page(struct kvm_vcpu *vcpu)
> diff --git a/drivers/gpu/drm/amd/amdgpu/amdgpu_mn.c b/drivers/gpu/drm/amd/amdgpu/amdgpu_mn.c
> index 83e344fbb50a..3399a4a927fb 100644
> --- a/drivers/gpu/drm/amd/amdgpu/amdgpu_mn.c
> +++ b/drivers/gpu/drm/amd/amdgpu/amdgpu_mn.c
> @@ -136,12 +136,18 @@ void amdgpu_mn_unlock(struct amdgpu_mn *mn)
>    *
>    * Take the rmn read side lock.
>    */
> -static void amdgpu_mn_read_lock(struct amdgpu_mn *rmn)
> +static int amdgpu_mn_read_lock(struct amdgpu_mn *rmn, bool blockable)
>   {
> -	mutex_lock(&rmn->read_lock);
> +	if (blockable)
> +		mutex_lock(&rmn->read_lock);
> +	else if (!mutex_trylock(&rmn->read_lock))
> +		return -EAGAIN;
> +
>   	if (atomic_inc_return(&rmn->recursion) == 1)
>   		down_read_non_owner(&rmn->lock);
>   	mutex_unlock(&rmn->read_lock);
> +
> +	return 0;
>   }
>   
>   /**
> @@ -197,10 +203,11 @@ static void amdgpu_mn_invalidate_node(struct amdgpu_mn_node *node,
>    * We block for all BOs between start and end to be idle and
>    * unmap them by move them into system domain again.
>    */
> -static void amdgpu_mn_invalidate_range_start_gfx(struct mmu_notifier *mn,
> +static int amdgpu_mn_invalidate_range_start_gfx(struct mmu_notifier *mn,
>   						 struct mm_struct *mm,
>   						 unsigned long start,
> -						 unsigned long end)
> +						 unsigned long end,
> +						 bool blockable)
>   {
>   	struct amdgpu_mn *rmn = container_of(mn, struct amdgpu_mn, mn);
>   	struct interval_tree_node *it;
> @@ -208,17 +215,28 @@ static void amdgpu_mn_invalidate_range_start_gfx(struct mmu_notifier *mn,
>   	/* notification is exclusive, but interval is inclusive */
>   	end -= 1;
>   
> -	amdgpu_mn_read_lock(rmn);
> +	/* TODO we should be able to split locking for interval tree and
> +	 * amdgpu_mn_invalidate_node
> +	 */
> +	if (amdgpu_mn_read_lock(rmn, blockable))
> +		return -EAGAIN;
>   
>   	it = interval_tree_iter_first(&rmn->objects, start, end);
>   	while (it) {
>   		struct amdgpu_mn_node *node;
>   
> +		if (!blockable) {
> +			amdgpu_mn_read_unlock(rmn);
> +			return -EAGAIN;
> +		}
> +
>   		node = container_of(it, struct amdgpu_mn_node, it);
>   		it = interval_tree_iter_next(it, start, end);
>   
>   		amdgpu_mn_invalidate_node(node, start, end);
>   	}
> +
> +	return 0;
>   }
>   
>   /**
> @@ -233,10 +251,11 @@ static void amdgpu_mn_invalidate_range_start_gfx(struct mmu_notifier *mn,
>    * necessitates evicting all user-mode queues of the process. The BOs
>    * are restorted in amdgpu_mn_invalidate_range_end_hsa.
>    */
> -static void amdgpu_mn_invalidate_range_start_hsa(struct mmu_notifier *mn,
> +static int amdgpu_mn_invalidate_range_start_hsa(struct mmu_notifier *mn,
>   						 struct mm_struct *mm,
>   						 unsigned long start,
> -						 unsigned long end)
> +						 unsigned long end,
> +						 bool blockable)
>   {
>   	struct amdgpu_mn *rmn = container_of(mn, struct amdgpu_mn, mn);
>   	struct interval_tree_node *it;
> @@ -244,13 +263,19 @@ static void amdgpu_mn_invalidate_range_start_hsa(struct mmu_notifier *mn,
>   	/* notification is exclusive, but interval is inclusive */
>   	end -= 1;
>   
> -	amdgpu_mn_read_lock(rmn);
> +	if (amdgpu_mn_read_lock(rmn, blockable))
> +		return -EAGAIN;
>   
>   	it = interval_tree_iter_first(&rmn->objects, start, end);
>   	while (it) {
>   		struct amdgpu_mn_node *node;
>   		struct amdgpu_bo *bo;
>   
> +		if (!blockable) {
> +			amdgpu_mn_read_unlock(rmn);
> +			return -EAGAIN;
> +		}
> +
>   		node = container_of(it, struct amdgpu_mn_node, it);
>   		it = interval_tree_iter_next(it, start, end);
>   
> @@ -262,6 +287,8 @@ static void amdgpu_mn_invalidate_range_start_hsa(struct mmu_notifier *mn,
>   				amdgpu_amdkfd_evict_userptr(mem, mm);
>   		}
>   	}
> +
> +	return 0;
>   }
>   
>   /**
> diff --git a/drivers/gpu/drm/i915/i915_gem_userptr.c b/drivers/gpu/drm/i915/i915_gem_userptr.c
> index 854bd51b9478..9cbff68f6b41 100644
> --- a/drivers/gpu/drm/i915/i915_gem_userptr.c
> +++ b/drivers/gpu/drm/i915/i915_gem_userptr.c
> @@ -112,10 +112,11 @@ static void del_object(struct i915_mmu_object *mo)
>   	mo->attached = false;
>   }
>   
> -static void i915_gem_userptr_mn_invalidate_range_start(struct mmu_notifier *_mn,
> +static int i915_gem_userptr_mn_invalidate_range_start(struct mmu_notifier *_mn,
>   						       struct mm_struct *mm,
>   						       unsigned long start,
> -						       unsigned long end)
> +						       unsigned long end,
> +						       bool blockable)
>   {
>   	struct i915_mmu_notifier *mn =
>   		container_of(_mn, struct i915_mmu_notifier, mn);
> @@ -124,7 +125,7 @@ static void i915_gem_userptr_mn_invalidate_range_start(struct mmu_notifier *_mn,
>   	LIST_HEAD(cancelled);
>   
>   	if (RB_EMPTY_ROOT(&mn->objects.rb_root))
> -		return;
> +		return 0;
>   
>   	/* interval ranges are inclusive, but invalidate range is exclusive */
>   	end--;
> @@ -132,6 +133,10 @@ static void i915_gem_userptr_mn_invalidate_range_start(struct mmu_notifier *_mn,
>   	spin_lock(&mn->lock);
>   	it = interval_tree_iter_first(&mn->objects, start, end);
>   	while (it) {
> +		if (!blockable) {
> +			spin_unlock(&mn->lock);
> +			return -EAGAIN;
> +		}
>   		/* The mmu_object is released late when destroying the
>   		 * GEM object so it is entirely possible to gain a
>   		 * reference on an object in the process of being freed
> @@ -154,6 +159,8 @@ static void i915_gem_userptr_mn_invalidate_range_start(struct mmu_notifier *_mn,
>   
>   	if (!list_empty(&cancelled))
>   		flush_workqueue(mn->wq);
> +
> +	return 0;
>   }
>   
>   static const struct mmu_notifier_ops i915_gem_userptr_notifier = {
> diff --git a/drivers/gpu/drm/radeon/radeon_mn.c b/drivers/gpu/drm/radeon/radeon_mn.c
> index abd24975c9b1..f8b35df44c60 100644
> --- a/drivers/gpu/drm/radeon/radeon_mn.c
> +++ b/drivers/gpu/drm/radeon/radeon_mn.c
> @@ -118,19 +118,27 @@ static void radeon_mn_release(struct mmu_notifier *mn,
>    * We block for all BOs between start and end to be idle and
>    * unmap them by move them into system domain again.
>    */
> -static void radeon_mn_invalidate_range_start(struct mmu_notifier *mn,
> +static int radeon_mn_invalidate_range_start(struct mmu_notifier *mn,
>   					     struct mm_struct *mm,
>   					     unsigned long start,
> -					     unsigned long end)
> +					     unsigned long end,
> +					     bool blockable)
>   {
>   	struct radeon_mn *rmn = container_of(mn, struct radeon_mn, mn);
>   	struct ttm_operation_ctx ctx = { false, false };
>   	struct interval_tree_node *it;
> +	int ret = 0;
>   
>   	/* notification is exclusive, but interval is inclusive */
>   	end -= 1;
>   
> -	mutex_lock(&rmn->lock);
> +	/* TODO we should be able to split locking for interval tree and
> +	 * the tear down.
> +	 */
> +	if (blockable)
> +		mutex_lock(&rmn->lock);
> +	else if (!mutex_trylock(&rmn->lock))
> +		return -EAGAIN;
>   
>   	it = interval_tree_iter_first(&rmn->objects, start, end);
>   	while (it) {
> @@ -138,6 +146,11 @@ static void radeon_mn_invalidate_range_start(struct mmu_notifier *mn,
>   		struct radeon_bo *bo;
>   		long r;
>   
> +		if (!blockable) {
> +			ret = -EAGAIN;
> +			goto out_unlock;
> +		}
> +
>   		node = container_of(it, struct radeon_mn_node, it);
>   		it = interval_tree_iter_next(it, start, end);
>   
> @@ -166,7 +179,10 @@ static void radeon_mn_invalidate_range_start(struct mmu_notifier *mn,
>   		}
>   	}
>   	
> +out_unlock:
>   	mutex_unlock(&rmn->lock);
> +
> +	return ret;
>   }
>   
>   static const struct mmu_notifier_ops radeon_mn_ops = {
> diff --git a/drivers/infiniband/core/umem_odp.c b/drivers/infiniband/core/umem_odp.c
> index 182436b92ba9..6ec748eccff7 100644
> --- a/drivers/infiniband/core/umem_odp.c
> +++ b/drivers/infiniband/core/umem_odp.c
> @@ -186,6 +186,7 @@ static void ib_umem_notifier_release(struct mmu_notifier *mn,
>   	rbt_ib_umem_for_each_in_range(&context->umem_tree, 0,
>   				      ULLONG_MAX,
>   				      ib_umem_notifier_release_trampoline,
> +				      true,
>   				      NULL);
>   	up_read(&context->umem_rwsem);
>   }
> @@ -207,22 +208,31 @@ static int invalidate_range_start_trampoline(struct ib_umem *item, u64 start,
>   	return 0;
>   }
>   
> -static void ib_umem_notifier_invalidate_range_start(struct mmu_notifier *mn,
> +static int ib_umem_notifier_invalidate_range_start(struct mmu_notifier *mn,
>   						    struct mm_struct *mm,
>   						    unsigned long start,
> -						    unsigned long end)
> +						    unsigned long end,
> +						    bool blockable)
>   {
>   	struct ib_ucontext *context = container_of(mn, struct ib_ucontext, mn);
> +	int ret;
>   
>   	if (!context->invalidate_range)
> -		return;
> +		return 0;
> +
> +	if (blockable)
> +		down_read(&context->umem_rwsem);
> +	else if (!down_read_trylock(&context->umem_rwsem))
> +		return -EAGAIN;
>   
>   	ib_ucontext_notifier_start_account(context);
> -	down_read(&context->umem_rwsem);
> -	rbt_ib_umem_for_each_in_range(&context->umem_tree, start,
> +	ret = rbt_ib_umem_for_each_in_range(&context->umem_tree, start,
>   				      end,
> -				      invalidate_range_start_trampoline, NULL);
> +				      invalidate_range_start_trampoline,
> +				      blockable, NULL);
>   	up_read(&context->umem_rwsem);
> +
> +	return ret;
>   }
>   
>   static int invalidate_range_end_trampoline(struct ib_umem *item, u64 start,
> @@ -242,10 +252,15 @@ static void ib_umem_notifier_invalidate_range_end(struct mmu_notifier *mn,
>   	if (!context->invalidate_range)
>   		return;
>   
> +	/*
> +	 * TODO: we currently bail out if there is any sleepable work to be done
> +	 * in ib_umem_notifier_invalidate_range_start so we shouldn't really block
> +	 * here. But this is ugly and fragile.
> +	 */
>   	down_read(&context->umem_rwsem);
>   	rbt_ib_umem_for_each_in_range(&context->umem_tree, start,
>   				      end,
> -				      invalidate_range_end_trampoline, NULL);
> +				      invalidate_range_end_trampoline, true, NULL);
>   	up_read(&context->umem_rwsem);
>   	ib_ucontext_notifier_end_account(context);
>   }
> @@ -798,6 +813,7 @@ EXPORT_SYMBOL(ib_umem_odp_unmap_dma_pages);
>   int rbt_ib_umem_for_each_in_range(struct rb_root_cached *root,
>   				  u64 start, u64 last,
>   				  umem_call_back cb,
> +				  bool blockable,
>   				  void *cookie)
>   {
>   	int ret_val = 0;
> @@ -809,6 +825,9 @@ int rbt_ib_umem_for_each_in_range(struct rb_root_cached *root,
>   
>   	for (node = rbt_ib_umem_iter_first(root, start, last - 1);
>   			node; node = next) {
> +		/* TODO move the blockable decision up to the callback */
> +		if (!blockable)
> +			return -EAGAIN;
>   		next = rbt_ib_umem_iter_next(node, start, last - 1);
>   		umem = container_of(node, struct ib_umem_odp, interval_tree);
>   		ret_val = cb(umem->umem, start, last, cookie) || ret_val;
> diff --git a/drivers/infiniband/hw/hfi1/mmu_rb.c b/drivers/infiniband/hw/hfi1/mmu_rb.c
> index 70aceefe14d5..e1c7996c018e 100644
> --- a/drivers/infiniband/hw/hfi1/mmu_rb.c
> +++ b/drivers/infiniband/hw/hfi1/mmu_rb.c
> @@ -67,9 +67,9 @@ struct mmu_rb_handler {
>   
>   static unsigned long mmu_node_start(struct mmu_rb_node *);
>   static unsigned long mmu_node_last(struct mmu_rb_node *);
> -static void mmu_notifier_range_start(struct mmu_notifier *,
> +static int mmu_notifier_range_start(struct mmu_notifier *,
>   				     struct mm_struct *,
> -				     unsigned long, unsigned long);
> +				     unsigned long, unsigned long, bool);
>   static struct mmu_rb_node *__mmu_rb_search(struct mmu_rb_handler *,
>   					   unsigned long, unsigned long);
>   static void do_remove(struct mmu_rb_handler *handler,
> @@ -284,10 +284,11 @@ void hfi1_mmu_rb_remove(struct mmu_rb_handler *handler,
>   	handler->ops->remove(handler->ops_arg, node);
>   }
>   
> -static void mmu_notifier_range_start(struct mmu_notifier *mn,
> +static int mmu_notifier_range_start(struct mmu_notifier *mn,
>   				     struct mm_struct *mm,
>   				     unsigned long start,
> -				     unsigned long end)
> +				     unsigned long end,
> +				     bool blockable)
>   {
>   	struct mmu_rb_handler *handler =
>   		container_of(mn, struct mmu_rb_handler, mn);
> @@ -313,6 +314,8 @@ static void mmu_notifier_range_start(struct mmu_notifier *mn,
>   
>   	if (added)
>   		queue_work(handler->wq, &handler->del_work);
> +
> +	return 0;
>   }
>   
>   /*
> diff --git a/drivers/infiniband/hw/mlx5/odp.c b/drivers/infiniband/hw/mlx5/odp.c
> index f1a87a690a4c..d216e0d2921d 100644
> --- a/drivers/infiniband/hw/mlx5/odp.c
> +++ b/drivers/infiniband/hw/mlx5/odp.c
> @@ -488,7 +488,7 @@ void mlx5_ib_free_implicit_mr(struct mlx5_ib_mr *imr)
>   
>   	down_read(&ctx->umem_rwsem);
>   	rbt_ib_umem_for_each_in_range(&ctx->umem_tree, 0, ULLONG_MAX,
> -				      mr_leaf_free, imr);
> +				      mr_leaf_free, true, imr);
>   	up_read(&ctx->umem_rwsem);
>   
>   	wait_event(imr->q_leaf_free, !atomic_read(&imr->num_leaf_free));
> diff --git a/drivers/misc/mic/scif/scif_dma.c b/drivers/misc/mic/scif/scif_dma.c
> index 63d6246d6dff..6369aeaa7056 100644
> --- a/drivers/misc/mic/scif/scif_dma.c
> +++ b/drivers/misc/mic/scif/scif_dma.c
> @@ -200,15 +200,18 @@ static void scif_mmu_notifier_release(struct mmu_notifier *mn,
>   	schedule_work(&scif_info.misc_work);
>   }
>   
> -static void scif_mmu_notifier_invalidate_range_start(struct mmu_notifier *mn,
> +static int scif_mmu_notifier_invalidate_range_start(struct mmu_notifier *mn,
>   						     struct mm_struct *mm,
>   						     unsigned long start,
> -						     unsigned long end)
> +						     unsigned long end,
> +						     bool blockable)
>   {
>   	struct scif_mmu_notif	*mmn;
>   
>   	mmn = container_of(mn, struct scif_mmu_notif, ep_mmu_notifier);
>   	scif_rma_destroy_tcw(mmn, start, end - start);
> +
> +	return 0;
>   }
>   
>   static void scif_mmu_notifier_invalidate_range_end(struct mmu_notifier *mn,
> diff --git a/drivers/misc/sgi-gru/grutlbpurge.c b/drivers/misc/sgi-gru/grutlbpurge.c
> index a3454eb56fbf..be28f05bfafa 100644
> --- a/drivers/misc/sgi-gru/grutlbpurge.c
> +++ b/drivers/misc/sgi-gru/grutlbpurge.c
> @@ -219,9 +219,10 @@ void gru_flush_all_tlb(struct gru_state *gru)
>   /*
>    * MMUOPS notifier callout functions
>    */
> -static void gru_invalidate_range_start(struct mmu_notifier *mn,
> +static int gru_invalidate_range_start(struct mmu_notifier *mn,
>   				       struct mm_struct *mm,
> -				       unsigned long start, unsigned long end)
> +				       unsigned long start, unsigned long end,
> +				       bool blockable)
>   {
>   	struct gru_mm_struct *gms = container_of(mn, struct gru_mm_struct,
>   						 ms_notifier);
> @@ -231,6 +232,8 @@ static void gru_invalidate_range_start(struct mmu_notifier *mn,
>   	gru_dbg(grudev, "gms %p, start 0x%lx, end 0x%lx, act %d\n", gms,
>   		start, end, atomic_read(&gms->ms_range_active));
>   	gru_flush_tlb_range(gms, start, end - start);
> +
> +	return 0;
>   }
>   
>   static void gru_invalidate_range_end(struct mmu_notifier *mn,
> diff --git a/drivers/xen/gntdev.c b/drivers/xen/gntdev.c
> index bd56653b9bbc..55b4f0e3f4d6 100644
> --- a/drivers/xen/gntdev.c
> +++ b/drivers/xen/gntdev.c
> @@ -441,18 +441,25 @@ static const struct vm_operations_struct gntdev_vmops = {
>   
>   /* ------------------------------------------------------------------ */
>   
> +static bool in_range(struct grant_map *map,
> +			      unsigned long start, unsigned long end)
> +{
> +	if (!map->vma)
> +		return false;
> +	if (map->vma->vm_start >= end)
> +		return false;
> +	if (map->vma->vm_end <= start)
> +		return false;
> +
> +	return true;
> +}
> +
>   static void unmap_if_in_range(struct grant_map *map,
>   			      unsigned long start, unsigned long end)
>   {
>   	unsigned long mstart, mend;
>   	int err;
>   
> -	if (!map->vma)
> -		return;
> -	if (map->vma->vm_start >= end)
> -		return;
> -	if (map->vma->vm_end <= start)
> -		return;
>   	mstart = max(start, map->vma->vm_start);
>   	mend   = min(end,   map->vma->vm_end);
>   	pr_debug("map %d+%d (%lx %lx), range %lx %lx, mrange %lx %lx\n",
> @@ -465,21 +472,40 @@ static void unmap_if_in_range(struct grant_map *map,
>   	WARN_ON(err);
>   }
>   
> -static void mn_invl_range_start(struct mmu_notifier *mn,
> +static int mn_invl_range_start(struct mmu_notifier *mn,
>   				struct mm_struct *mm,
> -				unsigned long start, unsigned long end)
> +				unsigned long start, unsigned long end,
> +				bool blockable)
>   {
>   	struct gntdev_priv *priv = container_of(mn, struct gntdev_priv, mn);
>   	struct grant_map *map;
> +	int ret = 0;
> +
> +	/* TODO do we really need a mutex here? */
> +	if (blockable)
> +		mutex_lock(&priv->lock);
> +	else if (!mutex_trylock(&priv->lock))
> +		return -EAGAIN;
>   
> -	mutex_lock(&priv->lock);
>   	list_for_each_entry(map, &priv->maps, next) {
> +		if (in_range(map, start, end)) {
> +			ret = -EAGAIN;
> +			goto out_unlock;
> +		}
>   		unmap_if_in_range(map, start, end);
>   	}
>   	list_for_each_entry(map, &priv->freeable_maps, next) {
> +		if (in_range(map, start, end)) {
> +			ret = -EAGAIN;
> +			goto out_unlock;
> +		}
>   		unmap_if_in_range(map, start, end);
>   	}
> +
> +out_unlock:
>   	mutex_unlock(&priv->lock);
> +
> +	return ret;
>   }
>   
>   static void mn_release(struct mmu_notifier *mn,
> diff --git a/include/linux/kvm_host.h b/include/linux/kvm_host.h
> index 4ee7bc548a83..148935085194 100644
> --- a/include/linux/kvm_host.h
> +++ b/include/linux/kvm_host.h
> @@ -1275,8 +1275,8 @@ static inline long kvm_arch_vcpu_async_ioctl(struct file *filp,
>   }
>   #endif /* CONFIG_HAVE_KVM_VCPU_ASYNC_IOCTL */
>   
> -void kvm_arch_mmu_notifier_invalidate_range(struct kvm *kvm,
> -		unsigned long start, unsigned long end);
> +int kvm_arch_mmu_notifier_invalidate_range(struct kvm *kvm,
> +		unsigned long start, unsigned long end, bool blockable);
>   
>   #ifdef CONFIG_HAVE_KVM_VCPU_RUN_PID_CHANGE
>   int kvm_arch_vcpu_run_pid_change(struct kvm_vcpu *vcpu);
> diff --git a/include/linux/mmu_notifier.h b/include/linux/mmu_notifier.h
> index 392e6af82701..2eb1a2d01759 100644
> --- a/include/linux/mmu_notifier.h
> +++ b/include/linux/mmu_notifier.h
> @@ -151,13 +151,15 @@ struct mmu_notifier_ops {
>   	 * address space but may still be referenced by sptes until
>   	 * the last refcount is dropped.
>   	 *
> -	 * If both of these callbacks cannot block, and invalidate_range
> -	 * cannot block, mmu_notifier_ops.flags should have
> -	 * MMU_INVALIDATE_DOES_NOT_BLOCK set.
> +	 * If blockable argument is set to false then the callback cannot
> +	 * sleep and has to return with -EAGAIN. 0 should be returned
> +	 * otherwise.
> +	 *
>   	 */
> -	void (*invalidate_range_start)(struct mmu_notifier *mn,
> +	int (*invalidate_range_start)(struct mmu_notifier *mn,
>   				       struct mm_struct *mm,
> -				       unsigned long start, unsigned long end);
> +				       unsigned long start, unsigned long end,
> +				       bool blockable);
>   	void (*invalidate_range_end)(struct mmu_notifier *mn,
>   				     struct mm_struct *mm,
>   				     unsigned long start, unsigned long end);
> @@ -229,8 +231,9 @@ extern int __mmu_notifier_test_young(struct mm_struct *mm,
>   				     unsigned long address);
>   extern void __mmu_notifier_change_pte(struct mm_struct *mm,
>   				      unsigned long address, pte_t pte);
> -extern void __mmu_notifier_invalidate_range_start(struct mm_struct *mm,
> -				  unsigned long start, unsigned long end);
> +extern int __mmu_notifier_invalidate_range_start(struct mm_struct *mm,
> +				  unsigned long start, unsigned long end,
> +				  bool blockable);
>   extern void __mmu_notifier_invalidate_range_end(struct mm_struct *mm,
>   				  unsigned long start, unsigned long end,
>   				  bool only_end);
> @@ -281,7 +284,17 @@ static inline void mmu_notifier_invalidate_range_start(struct mm_struct *mm,
>   				  unsigned long start, unsigned long end)
>   {
>   	if (mm_has_notifiers(mm))
> -		__mmu_notifier_invalidate_range_start(mm, start, end);
> +		__mmu_notifier_invalidate_range_start(mm, start, end, true);
> +}
> +
> +static inline int mmu_notifier_invalidate_range_start_nonblock(struct mm_struct *mm,
> +				  unsigned long start, unsigned long end)
> +{
> +	int ret = 0;
> +	if (mm_has_notifiers(mm))
> +		ret = __mmu_notifier_invalidate_range_start(mm, start, end, false);
> +
> +	return ret;
>   }
>   
>   static inline void mmu_notifier_invalidate_range_end(struct mm_struct *mm,
> @@ -461,6 +474,12 @@ static inline void mmu_notifier_invalidate_range_start(struct mm_struct *mm,
>   {
>   }
>   
> +static inline int mmu_notifier_invalidate_range_start_nonblock(struct mm_struct *mm,
> +				  unsigned long start, unsigned long end)
> +{
> +	return 0;
> +}
> +
>   static inline void mmu_notifier_invalidate_range_end(struct mm_struct *mm,
>   				  unsigned long start, unsigned long end)
>   {
> diff --git a/include/linux/oom.h b/include/linux/oom.h
> index 6adac113e96d..92f70e4c6252 100644
> --- a/include/linux/oom.h
> +++ b/include/linux/oom.h
> @@ -95,7 +95,7 @@ static inline int check_stable_address_space(struct mm_struct *mm)
>   	return 0;
>   }
>   
> -void __oom_reap_task_mm(struct mm_struct *mm);
> +bool __oom_reap_task_mm(struct mm_struct *mm);
>   
>   extern unsigned long oom_badness(struct task_struct *p,
>   		struct mem_cgroup *memcg, const nodemask_t *nodemask,
> diff --git a/include/rdma/ib_umem_odp.h b/include/rdma/ib_umem_odp.h
> index 6a17f856f841..381cdf5a9bd1 100644
> --- a/include/rdma/ib_umem_odp.h
> +++ b/include/rdma/ib_umem_odp.h
> @@ -119,7 +119,8 @@ typedef int (*umem_call_back)(struct ib_umem *item, u64 start, u64 end,
>    */
>   int rbt_ib_umem_for_each_in_range(struct rb_root_cached *root,
>   				  u64 start, u64 end,
> -				  umem_call_back cb, void *cookie);
> +				  umem_call_back cb,
> +				  bool blockable, void *cookie);
>   
>   /*
>    * Find first region intersecting with address range.
> diff --git a/mm/hmm.c b/mm/hmm.c
> index de7b6bf77201..81fd57bd2634 100644
> --- a/mm/hmm.c
> +++ b/mm/hmm.c
> @@ -177,16 +177,19 @@ static void hmm_release(struct mmu_notifier *mn, struct mm_struct *mm)
>   	up_write(&hmm->mirrors_sem);
>   }
>   
> -static void hmm_invalidate_range_start(struct mmu_notifier *mn,
> +static int hmm_invalidate_range_start(struct mmu_notifier *mn,
>   				       struct mm_struct *mm,
>   				       unsigned long start,
> -				       unsigned long end)
> +				       unsigned long end,
> +				       bool blockable)
>   {
>   	struct hmm *hmm = mm->hmm;
>   
>   	VM_BUG_ON(!hmm);
>   
>   	atomic_inc(&hmm->sequence);
> +
> +	return 0;
>   }
>   
>   static void hmm_invalidate_range_end(struct mmu_notifier *mn,
> diff --git a/mm/mmap.c b/mm/mmap.c
> index d1eb87ef4b1a..336bee8c4e25 100644
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -3074,7 +3074,7 @@ void exit_mmap(struct mm_struct *mm)
>   		 * reliably test it.
>   		 */
>   		mutex_lock(&oom_lock);
> -		__oom_reap_task_mm(mm);
> +		(void)__oom_reap_task_mm(mm);
>   		mutex_unlock(&oom_lock);
>   
>   		set_bit(MMF_OOM_SKIP, &mm->flags);
> diff --git a/mm/mmu_notifier.c b/mm/mmu_notifier.c
> index eff6b88a993f..103b2b450043 100644
> --- a/mm/mmu_notifier.c
> +++ b/mm/mmu_notifier.c
> @@ -174,18 +174,29 @@ void __mmu_notifier_change_pte(struct mm_struct *mm, unsigned long address,
>   	srcu_read_unlock(&srcu, id);
>   }
>   
> -void __mmu_notifier_invalidate_range_start(struct mm_struct *mm,
> -				  unsigned long start, unsigned long end)
> +int __mmu_notifier_invalidate_range_start(struct mm_struct *mm,
> +				  unsigned long start, unsigned long end,
> +				  bool blockable)
>   {
>   	struct mmu_notifier *mn;
> +	int ret = 0;
>   	int id;
>   
>   	id = srcu_read_lock(&srcu);
>   	hlist_for_each_entry_rcu(mn, &mm->mmu_notifier_mm->list, hlist) {
> -		if (mn->ops->invalidate_range_start)
> -			mn->ops->invalidate_range_start(mn, mm, start, end);
> +		if (mn->ops->invalidate_range_start) {
> +			int _ret = mn->ops->invalidate_range_start(mn, mm, start, end, blockable);
> +			if (_ret) {
> +				pr_info("%pS callback failed with %d in %sblockable context.\n",
> +						mn->ops->invalidate_range_start, _ret,
> +						!blockable ? "non-": "");
> +				ret = _ret;
> +			}
> +		}
>   	}
>   	srcu_read_unlock(&srcu, id);
> +
> +	return ret;
>   }
>   EXPORT_SYMBOL_GPL(__mmu_notifier_invalidate_range_start);
>   
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 84081e77bc51..5a936cf24d79 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -479,9 +479,10 @@ static DECLARE_WAIT_QUEUE_HEAD(oom_reaper_wait);
>   static struct task_struct *oom_reaper_list;
>   static DEFINE_SPINLOCK(oom_reaper_lock);
>   
> -void __oom_reap_task_mm(struct mm_struct *mm)
> +bool __oom_reap_task_mm(struct mm_struct *mm)
>   {
>   	struct vm_area_struct *vma;
> +	bool ret = true;
>   
>   	/*
>   	 * Tell all users of get_user/copy_from_user etc... that the content
> @@ -511,12 +512,17 @@ void __oom_reap_task_mm(struct mm_struct *mm)
>   			struct mmu_gather tlb;
>   
>   			tlb_gather_mmu(&tlb, mm, start, end);
> -			mmu_notifier_invalidate_range_start(mm, start, end);
> +			if (mmu_notifier_invalidate_range_start_nonblock(mm, start, end)) {
> +				ret = false;
> +				continue;
> +			}
>   			unmap_page_range(&tlb, vma, start, end, NULL);
>   			mmu_notifier_invalidate_range_end(mm, start, end);
>   			tlb_finish_mmu(&tlb, start, end);
>   		}
>   	}
> +
> +	return ret;
>   }
>   
>   static bool oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
> @@ -545,18 +551,6 @@ static bool oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
>   		goto unlock_oom;
>   	}
>   
> -	/*
> -	 * If the mm has invalidate_{start,end}() notifiers that could block,
> -	 * sleep to give the oom victim some more time.
> -	 * TODO: we really want to get rid of this ugly hack and make sure that
> -	 * notifiers cannot block for unbounded amount of time
> -	 */
> -	if (mm_has_blockable_invalidate_notifiers(mm)) {
> -		up_read(&mm->mmap_sem);
> -		schedule_timeout_idle(HZ);
> -		goto unlock_oom;
> -	}
> -
>   	/*
>   	 * MMF_OOM_SKIP is set by exit_mmap when the OOM reaper can't
>   	 * work on the mm anymore. The check for MMF_OOM_SKIP must run
> @@ -571,7 +565,12 @@ static bool oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
>   
>   	trace_start_task_reaping(tsk->pid);
>   
> -	__oom_reap_task_mm(mm);
> +	/* failed to reap part of the address space. Try again later */
> +	if (!__oom_reap_task_mm(mm)) {
> +		up_read(&mm->mmap_sem);
> +		ret = false;
> +		goto unlock_oom;
> +	}
>   
>   	pr_info("oom_reaper: reaped process %d (%s), now anon-rss:%lukB, file-rss:%lukB, shmem-rss:%lukB\n",
>   			task_pid_nr(tsk), tsk->comm,
> diff --git a/virt/kvm/kvm_main.c b/virt/kvm/kvm_main.c
> index ada21f47f22b..16ce38f178d1 100644
> --- a/virt/kvm/kvm_main.c
> +++ b/virt/kvm/kvm_main.c
> @@ -135,9 +135,10 @@ static void kvm_uevent_notify_change(unsigned int type, struct kvm *kvm);
>   static unsigned long long kvm_createvm_count;
>   static unsigned long long kvm_active_vms;
>   
> -__weak void kvm_arch_mmu_notifier_invalidate_range(struct kvm *kvm,
> -		unsigned long start, unsigned long end)
> +__weak int kvm_arch_mmu_notifier_invalidate_range(struct kvm *kvm,
> +		unsigned long start, unsigned long end, bool blockable)
>   {
> +	return 0;
>   }
>   
>   bool kvm_is_reserved_pfn(kvm_pfn_t pfn)
> @@ -354,13 +355,15 @@ static void kvm_mmu_notifier_change_pte(struct mmu_notifier *mn,
>   	srcu_read_unlock(&kvm->srcu, idx);
>   }
>   
> -static void kvm_mmu_notifier_invalidate_range_start(struct mmu_notifier *mn,
> +static int kvm_mmu_notifier_invalidate_range_start(struct mmu_notifier *mn,
>   						    struct mm_struct *mm,
>   						    unsigned long start,
> -						    unsigned long end)
> +						    unsigned long end,
> +						    bool blockable)
>   {
>   	struct kvm *kvm = mmu_notifier_to_kvm(mn);
>   	int need_tlb_flush = 0, idx;
> +	int ret;
>   
>   	idx = srcu_read_lock(&kvm->srcu);
>   	spin_lock(&kvm->mmu_lock);
> @@ -378,9 +381,11 @@ static void kvm_mmu_notifier_invalidate_range_start(struct mmu_notifier *mn,
>   
>   	spin_unlock(&kvm->mmu_lock);
>   
> -	kvm_arch_mmu_notifier_invalidate_range(kvm, start, end);
> +	ret = kvm_arch_mmu_notifier_invalidate_range(kvm, start, end, blockable);
>   
>   	srcu_read_unlock(&kvm->srcu, idx);
> +
> +	return ret;
>   }
>   
>   static void kvm_mmu_notifier_invalidate_range_end(struct mmu_notifier *mn,
