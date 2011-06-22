Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 800946B0166
	for <linux-mm@kvack.org>; Tue, 21 Jun 2011 20:21:42 -0400 (EDT)
Date: Tue, 21 Jun 2011 17:21:23 -0700
From: Chris Wright <chrisw@sous-sol.org>
Subject: Re: [PATCH] mmu_notifier, kvm: Introduce dirty bit tracking in spte
 and mmu notifier to help KSM dirty bit tracking
Message-ID: <20110622002123.GP25383@sequoia.sous-sol.org>
References: <201106212055.25400.nai.xia@gmail.com>
 <201106212132.39311.nai.xia@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201106212132.39311.nai.xia@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nai Xia <nai.xia@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Izik Eidus <izik.eidus@ravellosystems.com>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Chris Wright <chrisw@sous-sol.org>, Rik van Riel <riel@redhat.com>, linux-mm <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel <linux-kernel@vger.kernel.org>, kvm <kvm@vger.kernel.org>, mtosatti@redhat.com

* Nai Xia (nai.xia@gmail.com) wrote:
> Introduced kvm_mmu_notifier_test_and_clear_dirty(), kvm_mmu_notifier_dirty_update()
> and their mmu_notifier interfaces to support KSM dirty bit tracking, which brings
> significant performance gain in volatile pages scanning in KSM.
> Currently, kvm_mmu_notifier_dirty_update() returns 0 if and only if intel EPT is
> enabled to indicate that the dirty bits of underlying sptes are not updated by
> hardware.

Did you test with each of EPT, NPT and shadow?

> Signed-off-by: Nai Xia <nai.xia@gmail.com>
> Acked-by: Izik Eidus <izik.eidus@ravellosystems.com>
> ---
>  arch/x86/include/asm/kvm_host.h |    1 +
>  arch/x86/kvm/mmu.c              |   36 +++++++++++++++++++++++++++++
>  arch/x86/kvm/mmu.h              |    3 +-
>  arch/x86/kvm/vmx.c              |    1 +
>  include/linux/kvm_host.h        |    2 +-
>  include/linux/mmu_notifier.h    |   48 +++++++++++++++++++++++++++++++++++++++
>  mm/mmu_notifier.c               |   33 ++++++++++++++++++++++++++
>  virt/kvm/kvm_main.c             |   27 ++++++++++++++++++++++
>  8 files changed, 149 insertions(+), 2 deletions(-)
> 
> diff --git a/arch/x86/include/asm/kvm_host.h b/arch/x86/include/asm/kvm_host.h
> index d2ac8e2..f0d7aa0 100644
> --- a/arch/x86/include/asm/kvm_host.h
> +++ b/arch/x86/include/asm/kvm_host.h
> @@ -848,6 +848,7 @@ extern bool kvm_rebooting;
>  int kvm_unmap_hva(struct kvm *kvm, unsigned long hva);
>  int kvm_age_hva(struct kvm *kvm, unsigned long hva);
>  int kvm_test_age_hva(struct kvm *kvm, unsigned long hva);
> +int kvm_test_and_clear_dirty_hva(struct kvm *kvm, unsigned long hva);
>  void kvm_set_spte_hva(struct kvm *kvm, unsigned long hva, pte_t pte);
>  int cpuid_maxphyaddr(struct kvm_vcpu *vcpu);
>  int kvm_cpu_has_interrupt(struct kvm_vcpu *vcpu);
> diff --git a/arch/x86/kvm/mmu.c b/arch/x86/kvm/mmu.c
> index aee3862..a5a0c51 100644
> --- a/arch/x86/kvm/mmu.c
> +++ b/arch/x86/kvm/mmu.c
> @@ -979,6 +979,37 @@ out:
>  	return young;
>  }
>  
> +/*
> + * Caller is supposed to SetPageDirty(), it's not done inside this.
> + */
> +static
> +int kvm_test_and_clear_dirty_rmapp(struct kvm *kvm, unsigned long *rmapp,
> +				   unsigned long data)
> +{
> +	u64 *spte;
> +	int dirty = 0;
> +
> +	if (!shadow_dirty_mask) {
> +		WARN(1, "KVM: do NOT try to test dirty bit in EPT\n");
> +		goto out;
> +	}

This should never fire with the dirty_update() notifier test, right?
And that means that this whole optimization is for the shadow mmu case,
arguably the legacy case.

> +
> +	spte = rmap_next(kvm, rmapp, NULL);
> +	while (spte) {
> +		int _dirty;
> +		u64 _spte = *spte;
> +		BUG_ON(!(_spte & PT_PRESENT_MASK));
> +		_dirty = _spte & PT_DIRTY_MASK;
> +		if (_dirty) {
> +			dirty = 1;
> +			clear_bit(PT_DIRTY_SHIFT, (unsigned long *)spte);

Is this sufficient (not losing dirty state ever)?

> +		}
> +		spte = rmap_next(kvm, rmapp, spte);
> +	}
> +out:
> +	return dirty;
> +}
> +
>  #define RMAP_RECYCLE_THRESHOLD 1000
>  
>  static void rmap_recycle(struct kvm_vcpu *vcpu, u64 *spte, gfn_t gfn)
> @@ -1004,6 +1035,11 @@ int kvm_test_age_hva(struct kvm *kvm, unsigned long hva)
>  	return kvm_handle_hva(kvm, hva, 0, kvm_test_age_rmapp);
>  
>  
> +int kvm_test_and_clear_dirty_hva(struct kvm *kvm, unsigned long hva)
> +{
> +	return kvm_handle_hva(kvm, hva, 0, kvm_test_and_clear_dirty_rmapp);
> +}
> +
>  #ifdef MMU_DEBUG
>  static int is_empty_shadow_page(u64 *spt)
>  {
> diff --git a/arch/x86/kvm/mmu.h b/arch/x86/kvm/mmu.h
> index 7086ca8..b8d01c3 100644
> --- a/arch/x86/kvm/mmu.h
> +++ b/arch/x86/kvm/mmu.h
> @@ -18,7 +18,8 @@
>  #define PT_PCD_MASK (1ULL << 4)
>  #define PT_ACCESSED_SHIFT 5
>  #define PT_ACCESSED_MASK (1ULL << PT_ACCESSED_SHIFT)
> -#define PT_DIRTY_MASK (1ULL << 6)
> +#define PT_DIRTY_SHIFT 6
> +#define PT_DIRTY_MASK (1ULL << PT_DIRTY_SHIFT)
>  #define PT_PAGE_SIZE_MASK (1ULL << 7)
>  #define PT_PAT_MASK (1ULL << 7)
>  #define PT_GLOBAL_MASK (1ULL << 8)
> diff --git a/arch/x86/kvm/vmx.c b/arch/x86/kvm/vmx.c
> index d48ec60..b407a69 100644
> --- a/arch/x86/kvm/vmx.c
> +++ b/arch/x86/kvm/vmx.c
> @@ -4674,6 +4674,7 @@ static int __init vmx_init(void)
>  		kvm_mmu_set_mask_ptes(0ull, 0ull, 0ull, 0ull,
>  				VMX_EPT_EXECUTABLE_MASK);
>  		kvm_enable_tdp();
> +		kvm_dirty_update = 0;

Doesn't the above shadow_dirty_mask==0ull tell us this same info?

>  	} else
>  		kvm_disable_tdp();
>  
> diff --git a/include/linux/kvm_host.h b/include/linux/kvm_host.h
> index 31ebb59..2036bae 100644
> --- a/include/linux/kvm_host.h
> +++ b/include/linux/kvm_host.h
> @@ -53,7 +53,7 @@
>  struct kvm;
>  struct kvm_vcpu;
>  extern struct kmem_cache *kvm_vcpu_cache;
> -
> +extern int kvm_dirty_update;
>  /*
>   * It would be nice to use something smarter than a linear search, TBD...
>   * Thankfully we dont expect many devices to register (famous last words :),
> diff --git a/include/linux/mmu_notifier.h b/include/linux/mmu_notifier.h
> index 1d1b1e1..bd6ba2d 100644
> --- a/include/linux/mmu_notifier.h
> +++ b/include/linux/mmu_notifier.h
> @@ -24,6 +24,9 @@ struct mmu_notifier_mm {
>  };
>  
>  struct mmu_notifier_ops {

Need to add a comment to describe it.  And why is it not next to
test_and_clear_dirty()?  I see how it's used, but seems as if the
test_and_clear_dirty() code could return -1 (as in dirty state unknown)
for the case where it can't track dirty bit and fall back to checksum.

> +	int (*dirty_update)(struct mmu_notifier *mn,
> +			     struct mm_struct *mm);
> +
>  	/*
>  	 * Called either by mmu_notifier_unregister or when the mm is
>  	 * being destroyed by exit_mmap, always before all pages are
> @@ -72,6 +75,16 @@ struct mmu_notifier_ops {
>  			  unsigned long address);
>  
>  	/*
> +	 * clear_flush_dirty is called after the VM is
> +	 * test-and-clearing the dirty/modified bitflag in the
> +	 * pte. This way the VM will provide proper volatile page
> +	 * testing to ksm.
> +	 */
> +	int (*test_and_clear_dirty)(struct mmu_notifier *mn,
> +				    struct mm_struct *mm,
> +				    unsigned long address);
> +
> +	/*
>  	 * change_pte is called in cases that pte mapping to page is changed:
>  	 * for example, when ksm remaps pte to point to a new shared page.
>  	 */
> @@ -170,11 +183,14 @@ extern int __mmu_notifier_register(struct mmu_notifier *mn,
>  extern void mmu_notifier_unregister(struct mmu_notifier *mn,
>  				    struct mm_struct *mm);
>  extern void __mmu_notifier_mm_destroy(struct mm_struct *mm);
> +extern int __mmu_notifier_dirty_update(struct mm_struct *mm);
>  extern void __mmu_notifier_release(struct mm_struct *mm);
>  extern int __mmu_notifier_clear_flush_young(struct mm_struct *mm,
>  					  unsigned long address);
>  extern int __mmu_notifier_test_young(struct mm_struct *mm,
>  				     unsigned long address);
> +extern int __mmu_notifier_test_and_clear_dirty(struct mm_struct *mm,
> +					       unsigned long address);
>  extern void __mmu_notifier_change_pte(struct mm_struct *mm,
>  				      unsigned long address, pte_t pte);
>  extern void __mmu_notifier_invalidate_page(struct mm_struct *mm,
> @@ -184,6 +200,19 @@ extern void __mmu_notifier_invalidate_range_start(struct mm_struct *mm,
>  extern void __mmu_notifier_invalidate_range_end(struct mm_struct *mm,
>  				  unsigned long start, unsigned long end);
>  
> +/*
> + * For ksm to make use of dirty bit, it wants to make sure that the dirty bits
> + * in sptes really carry the dirty information. Currently only intel EPT is
> + * not for ksm dirty bit tracking.
> + */
> +static inline int mmu_notifier_dirty_update(struct mm_struct *mm)
> +{
> +	if (mm_has_notifiers(mm))
> +		return __mmu_notifier_dirty_update(mm);
> +

No need for extra newline.

> +	return 1;
> +}
> +

> diff --git a/virt/kvm/kvm_main.c b/virt/kvm/kvm_main.c
> index 96ebc06..22967c8 100644
> --- a/virt/kvm/kvm_main.c
> +++ b/virt/kvm/kvm_main.c
> @@ -78,6 +78,8 @@ static atomic_t hardware_enable_failed;
>  struct kmem_cache *kvm_vcpu_cache;
>  EXPORT_SYMBOL_GPL(kvm_vcpu_cache);
>  
> +int kvm_dirty_update = 1;
> +
>  static __read_mostly struct preempt_ops kvm_preempt_ops;
>  
>  struct dentry *kvm_debugfs_dir;
> @@ -398,6 +400,23 @@ static int kvm_mmu_notifier_test_young(struct mmu_notifier *mn,
>  	return young;
>  }
>  
> +/* Caller should SetPageDirty(), no need to flush tlb */
> +static int kvm_mmu_notifier_test_and_clear_dirty(struct mmu_notifier *mn,
> +						 struct mm_struct *mm,
> +						 unsigned long address)
> +{
> +	struct kvm *kvm = mmu_notifier_to_kvm(mn);
> +	int dirty, idx;

Perhaps something like:

	if (!shadow_dirty_mask)
		return -1;

And adjust caller logic accordingly?

> +     idx = srcu_read_lock(&kvm->srcu);
> +     spin_lock(&kvm->mmu_lock);
> +     dirty = kvm_test_and_clear_dirty_hva(kvm, address);
> +     spin_unlock(&kvm->mmu_lock);
> +     srcu_read_unlock(&kvm->srcu, idx);
> +
> +     return dirty;
> +}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
