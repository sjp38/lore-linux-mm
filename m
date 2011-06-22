Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 1EB206B0171
	for <linux-mm@kvack.org>; Wed, 22 Jun 2011 00:44:09 -0400 (EDT)
Received: by iwn8 with SMTP id 8so504681iwn.14
        for <linux-mm@kvack.org>; Tue, 21 Jun 2011 21:44:06 -0700 (PDT)
From: Nai Xia <nai.xia@gmail.com>
Reply-To: nai.xia@gmail.com
Subject: Re: [PATCH] mmu_notifier, kvm: Introduce dirty bit tracking in spte and mmu notifier to help KSM dirty bit tracking
Date: Wed, 22 Jun 2011 12:43:49 +0800
References: <201106212055.25400.nai.xia@gmail.com> <201106212132.39311.nai.xia@gmail.com> <20110622002123.GP25383@sequoia.sous-sol.org>
In-Reply-To: <20110622002123.GP25383@sequoia.sous-sol.org>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Message-Id: <201106221243.49772.nai.xia@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris Wright <chrisw@sous-sol.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Izik Eidus <izik.eidus@ravellosystems.com>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, linux-mm <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel <linux-kernel@vger.kernel.org>, kvm <kvm@vger.kernel.org>, mtosatti@redhat.com

On Wednesday 22 June 2011 08:21:23 Chris Wright wrote:
> * Nai Xia (nai.xia@gmail.com) wrote:
> > Introduced kvm_mmu_notifier_test_and_clear_dirty(), kvm_mmu_notifier_dirty_update()
> > and their mmu_notifier interfaces to support KSM dirty bit tracking, which brings
> > significant performance gain in volatile pages scanning in KSM.
> > Currently, kvm_mmu_notifier_dirty_update() returns 0 if and only if intel EPT is
> > enabled to indicate that the dirty bits of underlying sptes are not updated by
> > hardware.
> 
> Did you test with each of EPT, NPT and shadow?

I tested in EPT and pure softmmu. I have no NPT box and Izik told me that he 
did not have one either, so help me ... :D

> 
> > Signed-off-by: Nai Xia <nai.xia@gmail.com>
> > Acked-by: Izik Eidus <izik.eidus@ravellosystems.com>
> > ---
> >  arch/x86/include/asm/kvm_host.h |    1 +
> >  arch/x86/kvm/mmu.c              |   36 +++++++++++++++++++++++++++++
> >  arch/x86/kvm/mmu.h              |    3 +-
> >  arch/x86/kvm/vmx.c              |    1 +
> >  include/linux/kvm_host.h        |    2 +-
> >  include/linux/mmu_notifier.h    |   48 +++++++++++++++++++++++++++++++++++++++
> >  mm/mmu_notifier.c               |   33 ++++++++++++++++++++++++++
> >  virt/kvm/kvm_main.c             |   27 ++++++++++++++++++++++
> >  8 files changed, 149 insertions(+), 2 deletions(-)
> > 
> > diff --git a/arch/x86/include/asm/kvm_host.h b/arch/x86/include/asm/kvm_host.h
> > index d2ac8e2..f0d7aa0 100644
> > --- a/arch/x86/include/asm/kvm_host.h
> > +++ b/arch/x86/include/asm/kvm_host.h
> > @@ -848,6 +848,7 @@ extern bool kvm_rebooting;
> >  int kvm_unmap_hva(struct kvm *kvm, unsigned long hva);
> >  int kvm_age_hva(struct kvm *kvm, unsigned long hva);
> >  int kvm_test_age_hva(struct kvm *kvm, unsigned long hva);
> > +int kvm_test_and_clear_dirty_hva(struct kvm *kvm, unsigned long hva);
> >  void kvm_set_spte_hva(struct kvm *kvm, unsigned long hva, pte_t pte);
> >  int cpuid_maxphyaddr(struct kvm_vcpu *vcpu);
> >  int kvm_cpu_has_interrupt(struct kvm_vcpu *vcpu);
> > diff --git a/arch/x86/kvm/mmu.c b/arch/x86/kvm/mmu.c
> > index aee3862..a5a0c51 100644
> > --- a/arch/x86/kvm/mmu.c
> > +++ b/arch/x86/kvm/mmu.c
> > @@ -979,6 +979,37 @@ out:
> >  	return young;
> >  }
> >  
> > +/*
> > + * Caller is supposed to SetPageDirty(), it's not done inside this.
> > + */
> > +static
> > +int kvm_test_and_clear_dirty_rmapp(struct kvm *kvm, unsigned long *rmapp,
> > +				   unsigned long data)
> > +{
> > +	u64 *spte;
> > +	int dirty = 0;
> > +
> > +	if (!shadow_dirty_mask) {
> > +		WARN(1, "KVM: do NOT try to test dirty bit in EPT\n");
> > +		goto out;
> > +	}
> 
> This should never fire with the dirty_update() notifier test, right?
> And that means that this whole optimization is for the shadow mmu case,
> arguably the legacy case.

Yes, right. Actually I wrote this for potential abuse of this interface
since its name only does not suggest this. It can be a comment to save
some .text allocation and to compete with the "10k/3lines optimization"
in the list :P

> 
> > +
> > +	spte = rmap_next(kvm, rmapp, NULL);
> > +	while (spte) {
> > +		int _dirty;
> > +		u64 _spte = *spte;
> > +		BUG_ON(!(_spte & PT_PRESENT_MASK));
> > +		_dirty = _spte & PT_DIRTY_MASK;
> > +		if (_dirty) {
> > +			dirty = 1;
> > +			clear_bit(PT_DIRTY_SHIFT, (unsigned long *)spte);
> 
> Is this sufficient (not losing dirty state ever)?

This does lose some dirty state. Not flushing TLB may prevent CPU update
the dirty bit back to spte(I referred the Intel's manual x86 does not update 
in this case). But we(Izik & me) think it ok, because it seems currently the 
only user of dirty bit information is KSM. It's not critical to lose some 
information. And if we do found problem with it in the future, we can add the
flushing. How do you think?

> 
> > +		}
> > +		spte = rmap_next(kvm, rmapp, spte);
> > +	}
> > +out:
> > +	return dirty;
> > +}
> > +
> >  #define RMAP_RECYCLE_THRESHOLD 1000
> >  
> >  static void rmap_recycle(struct kvm_vcpu *vcpu, u64 *spte, gfn_t gfn)
> > @@ -1004,6 +1035,11 @@ int kvm_test_age_hva(struct kvm *kvm, unsigned long hva)
> >  	return kvm_handle_hva(kvm, hva, 0, kvm_test_age_rmapp);
> >  
> >  
> > +int kvm_test_and_clear_dirty_hva(struct kvm *kvm, unsigned long hva)
> > +{
> > +	return kvm_handle_hva(kvm, hva, 0, kvm_test_and_clear_dirty_rmapp);
> > +}
> > +
> >  #ifdef MMU_DEBUG
> >  static int is_empty_shadow_page(u64 *spt)
> >  {
> > diff --git a/arch/x86/kvm/mmu.h b/arch/x86/kvm/mmu.h
> > index 7086ca8..b8d01c3 100644
> > --- a/arch/x86/kvm/mmu.h
> > +++ b/arch/x86/kvm/mmu.h
> > @@ -18,7 +18,8 @@
> >  #define PT_PCD_MASK (1ULL << 4)
> >  #define PT_ACCESSED_SHIFT 5
> >  #define PT_ACCESSED_MASK (1ULL << PT_ACCESSED_SHIFT)
> > -#define PT_DIRTY_MASK (1ULL << 6)
> > +#define PT_DIRTY_SHIFT 6
> > +#define PT_DIRTY_MASK (1ULL << PT_DIRTY_SHIFT)
> >  #define PT_PAGE_SIZE_MASK (1ULL << 7)
> >  #define PT_PAT_MASK (1ULL << 7)
> >  #define PT_GLOBAL_MASK (1ULL << 8)
> > diff --git a/arch/x86/kvm/vmx.c b/arch/x86/kvm/vmx.c
> > index d48ec60..b407a69 100644
> > --- a/arch/x86/kvm/vmx.c
> > +++ b/arch/x86/kvm/vmx.c
> > @@ -4674,6 +4674,7 @@ static int __init vmx_init(void)
> >  		kvm_mmu_set_mask_ptes(0ull, 0ull, 0ull, 0ull,
> >  				VMX_EPT_EXECUTABLE_MASK);
> >  		kvm_enable_tdp();
> > +		kvm_dirty_update = 0;
> 
> Doesn't the above shadow_dirty_mask==0ull tell us this same info?

Yes, it's nasty. I am not sure about making shadow_dirty_mask global or not
actually since all other similar state var are all static. 

> 
> >  	} else
> >  		kvm_disable_tdp();
> >  
> > diff --git a/include/linux/kvm_host.h b/include/linux/kvm_host.h
> > index 31ebb59..2036bae 100644
> > --- a/include/linux/kvm_host.h
> > +++ b/include/linux/kvm_host.h
> > @@ -53,7 +53,7 @@
> >  struct kvm;
> >  struct kvm_vcpu;
> >  extern struct kmem_cache *kvm_vcpu_cache;
> > -
> > +extern int kvm_dirty_update;
> >  /*
> >   * It would be nice to use something smarter than a linear search, TBD...
> >   * Thankfully we dont expect many devices to register (famous last words :),
> > diff --git a/include/linux/mmu_notifier.h b/include/linux/mmu_notifier.h
> > index 1d1b1e1..bd6ba2d 100644
> > --- a/include/linux/mmu_notifier.h
> > +++ b/include/linux/mmu_notifier.h
> > @@ -24,6 +24,9 @@ struct mmu_notifier_mm {
> >  };
> >  
> >  struct mmu_notifier_ops {
> 
> Need to add a comment to describe it.  And why is it not next to
> test_and_clear_dirty()?  I see how it's used, but seems as if the
> test_and_clear_dirty() code could return -1 (as in dirty state unknown)
> for the case where it can't track dirty bit and fall back to checksum.

Actually I did consider this option. But I thought it's weird to test
a bit as its name suggests and return -1 as a result. Should it be the 
first one in human history to do so ? :D

Thanks,
Nai

> 
> > +	int (*dirty_update)(struct mmu_notifier *mn,
> > +			     struct mm_struct *mm);
> > +
> >  	/*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
