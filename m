Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f200.google.com (mail-ot0-f200.google.com [74.125.82.200])
	by kanga.kvack.org (Postfix) with ESMTP id 26DFE6B0069
	for <linux-mm@kvack.org>; Fri, 15 Dec 2017 03:43:12 -0500 (EST)
Received: by mail-ot0-f200.google.com with SMTP id s10so4368234oth.14
        for <linux-mm@kvack.org>; Fri, 15 Dec 2017 00:43:12 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id m31si1951521otm.361.2017.12.15.00.43.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Dec 2017 00:43:11 -0800 (PST)
Subject: Re: [patch v2 1/2] mm, mmu_notifier: annotate mmu notifiers with
 blockable invalidate callbacks
References: <alpine.DEB.2.10.1712111409090.196232@chino.kir.corp.google.com>
 <alpine.DEB.2.10.1712141329500.74052@chino.kir.corp.google.com>
From: Paolo Bonzini <pbonzini@redhat.com>
Message-ID: <330d5b31-568a-f97a-e24a-54d73e07339f@redhat.com>
Date: Fri, 15 Dec 2017 09:42:59 +0100
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.10.1712141329500.74052@chino.kir.corp.google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.com>, Andrea Arcangeli <aarcange@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Oded Gabbay <oded.gabbay@gmail.com>, Alex Deucher <alexander.deucher@amd.com>, =?UTF-8?Q?Christian_K=c3=b6nig?= <christian.koenig@amd.com>, David Airlie <airlied@linux.ie>, Joerg Roedel <joro@8bytes.org>, Doug Ledford <dledford@redhat.com>, Jani Nikula <jani.nikula@linux.intel.com>, Mike Marciniszyn <mike.marciniszyn@intel.com>, Sean Hefty <sean.hefty@intel.com>, Dimitri Sivanich <sivanich@sgi.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 14/12/2017 22:30, David Rientjes wrote:
> Commit 4d4bbd8526a8 ("mm, oom_reaper: skip mm structs with mmu notifiers")
> prevented the oom reaper from unmapping private anonymous memory with the
> oom reaper when the oom victim mm had mmu notifiers registered.
> 
> The rationale is that doing mmu_notifier_invalidate_range_{start,end}()
> around the unmap_page_range(), which is needed, can block and the oom
> killer will stall forever waiting for the victim to exit, which may not
> be possible without reaping.
> 
> That concern is real, but only true for mmu notifiers that have blockable
> invalidate_range_{start,end}() callbacks.  This patch adds a "flags" field
> to mmu notifier ops that can set a bit to indicate that these callbacks do
> not block.
> 
> The implementation is steered toward an expensive slowpath, such as after
> the oom reaper has grabbed mm->mmap_sem of a still alive oom victim.
> 
> Signed-off-by: David Rientjes <rientjes@google.com>
> ---
>  v2:
>    - specifically exclude mmu_notifiers without invalidate callbacks
>    - move flags to mmu_notifier_ops per Paolo
>    - reverse flag from blockable -> not blockable per Christian
> 
>  drivers/infiniband/hw/hfi1/mmu_rb.c |  1 +
>  drivers/iommu/amd_iommu_v2.c        |  1 +
>  drivers/iommu/intel-svm.c           |  1 +
>  drivers/misc/sgi-gru/grutlbpurge.c  |  1 +
>  include/linux/mmu_notifier.h        | 21 +++++++++++++++++++++
>  mm/mmu_notifier.c                   | 31 +++++++++++++++++++++++++++++++
>  virt/kvm/kvm_main.c                 |  1 +
>  7 files changed, 57 insertions(+)
> 
> diff --git a/drivers/infiniband/hw/hfi1/mmu_rb.c b/drivers/infiniband/hw/hfi1/mmu_rb.c
> --- a/drivers/infiniband/hw/hfi1/mmu_rb.c
> +++ b/drivers/infiniband/hw/hfi1/mmu_rb.c
> @@ -77,6 +77,7 @@ static void do_remove(struct mmu_rb_handler *handler,
>  static void handle_remove(struct work_struct *work);
>  
>  static const struct mmu_notifier_ops mn_opts = {
> +	.flags = MMU_INVALIDATE_DOES_NOT_BLOCK,
>  	.invalidate_range_start = mmu_notifier_range_start,
>  };
>  
> diff --git a/drivers/iommu/amd_iommu_v2.c b/drivers/iommu/amd_iommu_v2.c
> --- a/drivers/iommu/amd_iommu_v2.c
> +++ b/drivers/iommu/amd_iommu_v2.c
> @@ -427,6 +427,7 @@ static void mn_release(struct mmu_notifier *mn, struct mm_struct *mm)
>  }
>  
>  static const struct mmu_notifier_ops iommu_mn = {
> +	.flags			= MMU_INVALIDATE_DOES_NOT_BLOCK,
>  	.release		= mn_release,
>  	.clear_flush_young      = mn_clear_flush_young,
>  	.invalidate_range       = mn_invalidate_range,
> diff --git a/drivers/iommu/intel-svm.c b/drivers/iommu/intel-svm.c
> --- a/drivers/iommu/intel-svm.c
> +++ b/drivers/iommu/intel-svm.c
> @@ -276,6 +276,7 @@ static void intel_mm_release(struct mmu_notifier *mn, struct mm_struct *mm)
>  }
>  
>  static const struct mmu_notifier_ops intel_mmuops = {
> +	.flags = MMU_INVALIDATE_DOES_NOT_BLOCK,
>  	.release = intel_mm_release,
>  	.change_pte = intel_change_pte,
>  	.invalidate_range = intel_invalidate_range,
> diff --git a/drivers/misc/sgi-gru/grutlbpurge.c b/drivers/misc/sgi-gru/grutlbpurge.c
> --- a/drivers/misc/sgi-gru/grutlbpurge.c
> +++ b/drivers/misc/sgi-gru/grutlbpurge.c
> @@ -258,6 +258,7 @@ static void gru_release(struct mmu_notifier *mn, struct mm_struct *mm)
>  
>  
>  static const struct mmu_notifier_ops gru_mmuops = {
> +	.flags			= MMU_INVALIDATE_DOES_NOT_BLOCK,
>  	.invalidate_range_start	= gru_invalidate_range_start,
>  	.invalidate_range_end	= gru_invalidate_range_end,
>  	.release		= gru_release,
> diff --git a/include/linux/mmu_notifier.h b/include/linux/mmu_notifier.h
> --- a/include/linux/mmu_notifier.h
> +++ b/include/linux/mmu_notifier.h
> @@ -10,6 +10,9 @@
>  struct mmu_notifier;
>  struct mmu_notifier_ops;
>  
> +/* mmu_notifier_ops flags */
> +#define MMU_INVALIDATE_DOES_NOT_BLOCK	(0x01)
> +
>  #ifdef CONFIG_MMU_NOTIFIER
>  
>  /*
> @@ -26,6 +29,15 @@ struct mmu_notifier_mm {
>  };
>  
>  struct mmu_notifier_ops {
> +	/*
> +	 * Flags to specify behavior of callbacks for this MMU notifier.
> +	 * Used to determine which context an operation may be called.
> +	 *
> +	 * MMU_INVALIDATE_DOES_NOT_BLOCK: invalidate_{start,end} does not
> +	 *				  block
> +	 */
> +	int flags;
> +
>  	/*
>  	 * Called either by mmu_notifier_unregister or when the mm is
>  	 * being destroyed by exit_mmap, always before all pages are
> @@ -137,6 +149,9 @@ struct mmu_notifier_ops {
>  	 * page. Pages will no longer be referenced by the linux
>  	 * address space but may still be referenced by sptes until
>  	 * the last refcount is dropped.
> +	 *
> +	 * If both of these callbacks cannot block, mmu_notifier_ops.flags
> +	 * should have MMU_INVALIDATE_DOES_NOT_BLOCK set.
>  	 */
>  	void (*invalidate_range_start)(struct mmu_notifier *mn,
>  				       struct mm_struct *mm,
> @@ -218,6 +233,7 @@ extern void __mmu_notifier_invalidate_range_end(struct mm_struct *mm,
>  				  bool only_end);
>  extern void __mmu_notifier_invalidate_range(struct mm_struct *mm,
>  				  unsigned long start, unsigned long end);
> +extern int mm_has_blockable_invalidate_notifiers(struct mm_struct *mm);
>  
>  static inline void mmu_notifier_release(struct mm_struct *mm)
>  {
> @@ -457,6 +473,11 @@ static inline void mmu_notifier_invalidate_range(struct mm_struct *mm,
>  {
>  }
>  
> +static inline int mm_has_blockable_invalidate_notifiers(struct mm_struct *mm)
> +{
> +	return 0;
> +}
> +
>  static inline void mmu_notifier_mm_init(struct mm_struct *mm)
>  {
>  }
> diff --git a/mm/mmu_notifier.c b/mm/mmu_notifier.c
> --- a/mm/mmu_notifier.c
> +++ b/mm/mmu_notifier.c
> @@ -236,6 +236,37 @@ void __mmu_notifier_invalidate_range(struct mm_struct *mm,
>  }
>  EXPORT_SYMBOL_GPL(__mmu_notifier_invalidate_range);
>  
> +/*
> + * Must be called while holding mm->mmap_sem for either read or write.
> + * The result is guaranteed to be valid until mm->mmap_sem is dropped.
> + */
> +int mm_has_blockable_invalidate_notifiers(struct mm_struct *mm)
> +{
> +	struct mmu_notifier *mn;
> +	int id;
> +	int ret = 0;
> +
> +	WARN_ON_ONCE(down_write_trylock(&mm->mmap_sem));
> +
> +	if (!mm_has_notifiers(mm))
> +		return ret;
> +
> +	id = srcu_read_lock(&srcu);
> +	hlist_for_each_entry_rcu(mn, &mm->mmu_notifier_mm->list, hlist) {
> +		if (!mn->ops->invalidate_range &&
> +		    !mn->ops->invalidate_range_start &&
> +		    !mn->ops->invalidate_range_end)
> +				continue;
> +
> +		if (!(mn->ops->flags & MMU_INVALIDATE_DOES_NOT_BLOCK)) {
> +			ret = 1;
> +			break;
> +		}
> +	}
> +	srcu_read_unlock(&srcu, id);
> +	return ret;
> +}
> +
>  static int do_mmu_notifier_register(struct mmu_notifier *mn,
>  				    struct mm_struct *mm,
>  				    int take_mmap_sem)
> diff --git a/virt/kvm/kvm_main.c b/virt/kvm/kvm_main.c
> --- a/virt/kvm/kvm_main.c
> +++ b/virt/kvm/kvm_main.c
> @@ -476,6 +476,7 @@ static void kvm_mmu_notifier_release(struct mmu_notifier *mn,
>  }
>  
>  static const struct mmu_notifier_ops kvm_mmu_notifier_ops = {
> +	.flags			= MMU_INVALIDATE_DOES_NOT_BLOCK,
>  	.invalidate_range_start	= kvm_mmu_notifier_invalidate_range_start,
>  	.invalidate_range_end	= kvm_mmu_notifier_invalidate_range_end,
>  	.clear_flush_young	= kvm_mmu_notifier_clear_flush_young,
> 

Acked-by: Paolo Bonzini <pbonzini@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
