Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 6F4346006F5
	for <linux-mm@kvack.org>; Thu,  8 Jul 2010 12:53:13 -0400 (EDT)
Date: Thu, 8 Jul 2010 12:59:20 -0300
From: Marcelo Tosatti <mtosatti@redhat.com>
Subject: Re: [PATCH v4 08/12] Inject asynchronous page fault into a guest if
 page is swapped out.
Message-ID: <20100708155920.GA13855@amt.cnet>
References: <1278433500-29884-1-git-send-email-gleb@redhat.com>
 <1278433500-29884-9-git-send-email-gleb@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1278433500-29884-9-git-send-email-gleb@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Gleb Natapov <gleb@redhat.com>
Cc: kvm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, avi@redhat.com, mingo@elte.hu, a.p.zijlstra@chello.nl, tglx@linutronix.de, hpa@zytor.com, riel@redhat.com, cl@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 06, 2010 at 07:24:56PM +0300, Gleb Natapov wrote:
> If guest access swapped out memory do not swap it in from vcpu thread
> context. Setup slow work to do swapping and send async page fault to
> a guest.
> 
> Allow async page fault injection only when guest is in user mode since
> otherwise guest may be in non-sleepable context and will not be able to
> reschedule.
> 
> Signed-off-by: Gleb Natapov <gleb@redhat.com>
> ---
>  arch/x86/include/asm/kvm_host.h |   16 +++
>  arch/x86/kvm/Kconfig            |    2 +
>  arch/x86/kvm/mmu.c              |   35 +++++-
>  arch/x86/kvm/paging_tmpl.h      |   17 +++-
>  arch/x86/kvm/x86.c              |   63 +++++++++-
>  include/linux/kvm_host.h        |   31 +++++
>  include/trace/events/kvm.h      |   60 +++++++++
>  virt/kvm/Kconfig                |    3 +
>  virt/kvm/kvm_main.c             |  263 ++++++++++++++++++++++++++++++++++++++-
>  9 files changed, 481 insertions(+), 9 deletions(-)
> 
> +	u32 apf_memslot_ver;
>  	u64 apf_msr_val;
> +	u32 async_pf_id;
>  };
>  
>  struct kvm_arch {
> @@ -444,6 +446,8 @@ struct kvm_vcpu_stat {
>  	u32 hypercalls;
>  	u32 irq_injections;
>  	u32 nmi_injections;
> +	u32 apf_not_present;
> +	u32 apf_present;
>  };
>  
>  struct kvm_x86_ops {
> @@ -528,6 +532,10 @@ struct kvm_x86_ops {
>  	const struct trace_print_flags *exit_reasons_str;
>  };
>  
> +struct kvm_arch_async_pf {
> +	u32 token;
> +};
> +
>  extern struct kvm_x86_ops *kvm_x86_ops;
>  
>  int kvm_mmu_module_init(void);
> @@ -763,4 +771,12 @@ void kvm_set_shared_msr(unsigned index, u64 val, u64 mask);
>  
>  bool kvm_is_linear_rip(struct kvm_vcpu *vcpu, unsigned long linear_rip);
>  
> +struct kvm_async_pf;
> +
> +void kvm_arch_inject_async_page_not_present(struct kvm_vcpu *vcpu,
> +					    struct kvm_async_pf *work);
> +void kvm_arch_inject_async_page_present(struct kvm_vcpu *vcpu,
> +					struct kvm_async_pf *work);
> +bool kvm_arch_can_inject_async_page_present(struct kvm_vcpu *vcpu);
>  #endif /* _ASM_X86_KVM_HOST_H */
> +
> diff --git a/arch/x86/kvm/Kconfig b/arch/x86/kvm/Kconfig
> index 970bbd4..2461284 100644
> --- a/arch/x86/kvm/Kconfig
> +++ b/arch/x86/kvm/Kconfig
> @@ -28,6 +28,8 @@ config KVM
>  	select HAVE_KVM_IRQCHIP
>  	select HAVE_KVM_EVENTFD
>  	select KVM_APIC_ARCHITECTURE
> +	select KVM_ASYNC_PF
> +	select SLOW_WORK
>  	select USER_RETURN_NOTIFIER
>  	select KVM_MMIO
>  	---help---
> diff --git a/arch/x86/kvm/mmu.c b/arch/x86/kvm/mmu.c
> index c515753..a49565b 100644
> --- a/arch/x86/kvm/mmu.c
> +++ b/arch/x86/kvm/mmu.c
> @@ -21,6 +21,7 @@
>  #include "mmu.h"
>  #include "x86.h"
>  #include "kvm_cache_regs.h"
> +#include "x86.h"
>  
>  #include <linux/kvm_host.h>
>  #include <linux/types.h>
> @@ -2264,6 +2265,21 @@ static int nonpaging_page_fault(struct kvm_vcpu *vcpu, gva_t gva,
>  			     error_code & PFERR_WRITE_MASK, gfn);
>  }
>  
> +int kvm_arch_setup_async_pf(struct kvm_vcpu *vcpu, gva_t gva, gfn_t gfn)
> +{
> +	struct kvm_arch_async_pf arch;
> +	arch.token = (vcpu->arch.async_pf_id++ << 12) | vcpu->vcpu_id;
> +	return kvm_setup_async_pf(vcpu, gva, gfn, &arch);
> +}
> +
> +static bool can_do_async_pf(struct kvm_vcpu *vcpu)
> +{
> +	if (!vcpu->arch.apf_data || kvm_event_needs_reinjection(vcpu))
> +		return false;
> +
> +	return !!kvm_x86_ops->get_cpl(vcpu);
> +}
> +
>  static int tdp_page_fault(struct kvm_vcpu *vcpu, gva_t gpa,
>  				u32 error_code)
>  {
> @@ -2272,6 +2288,7 @@ static int tdp_page_fault(struct kvm_vcpu *vcpu, gva_t gpa,
>  	int level;
>  	gfn_t gfn = gpa >> PAGE_SHIFT;
>  	unsigned long mmu_seq;
> +	bool async;
>  
>  	ASSERT(vcpu);
>  	ASSERT(VALID_PAGE(vcpu->arch.mmu.root_hpa));
> @@ -2286,7 +2303,23 @@ static int tdp_page_fault(struct kvm_vcpu *vcpu, gva_t gpa,
>  
>  	mmu_seq = vcpu->kvm->mmu_notifier_seq;
>  	smp_rmb();
> -	pfn = gfn_to_pfn(vcpu->kvm, gfn);
> +
> +	if (can_do_async_pf(vcpu)) {
> +		pfn = gfn_to_pfn_async(vcpu->kvm, gfn, &async);
> +		trace_kvm_try_async_get_page(async, pfn);
> +	} else {
> +do_sync:
> +		async = false;
> +		pfn = gfn_to_pfn(vcpu->kvm, gfn);
> +	}
> +
> +	if (async) {
> +		if (!kvm_arch_setup_async_pf(vcpu, gpa, gfn))
> +			goto do_sync;
> +		return 0;
> +	}
> +
> +	/* mmio */
>  	if (is_error_pfn(pfn))
>  		return kvm_handle_bad_page(vcpu->kvm, gfn, pfn);
>  	spin_lock(&vcpu->kvm->mmu_lock);
> diff --git a/arch/x86/kvm/paging_tmpl.h b/arch/x86/kvm/paging_tmpl.h
> index 3350c02..26d6b74 100644
> --- a/arch/x86/kvm/paging_tmpl.h
> +++ b/arch/x86/kvm/paging_tmpl.h
> @@ -423,6 +423,7 @@ static int FNAME(page_fault)(struct kvm_vcpu *vcpu, gva_t addr,
>  	pfn_t pfn;
>  	int level = PT_PAGE_TABLE_LEVEL;
>  	unsigned long mmu_seq;
> +	bool async;
>  
>  	pgprintk("%s: addr %lx err %x\n", __func__, addr, error_code);
>  	kvm_mmu_audit(vcpu, "pre page fault");
> @@ -454,7 +455,21 @@ static int FNAME(page_fault)(struct kvm_vcpu *vcpu, gva_t addr,
>  
>  	mmu_seq = vcpu->kvm->mmu_notifier_seq;
>  	smp_rmb();
> -	pfn = gfn_to_pfn(vcpu->kvm, walker.gfn);
> +
> +	if (can_do_async_pf(vcpu)) {
> +		pfn = gfn_to_pfn_async(vcpu->kvm, walker.gfn, &async);
> +		trace_kvm_try_async_get_page(async, pfn);
> +	} else {
> +do_sync:
> +		async = false;
> +		pfn = gfn_to_pfn(vcpu->kvm, walker.gfn);
> +	}
> +
> +	if (async) {
> +		if (!kvm_arch_setup_async_pf(vcpu, addr, walker.gfn))
> +			goto do_sync;
> +		return 0;
> +	}
>  
>  	/* mmio */
>  	if (is_error_pfn(pfn))
> diff --git a/arch/x86/kvm/x86.c b/arch/x86/kvm/x86.c
> index 744f8c1..6b7542f 100644
> --- a/arch/x86/kvm/x86.c
> +++ b/arch/x86/kvm/x86.c
> @@ -118,6 +118,8 @@ static DEFINE_PER_CPU(struct kvm_shared_msrs, shared_msrs);
>  struct kvm_stats_debugfs_item debugfs_entries[] = {
>  	{ "pf_fixed", VCPU_STAT(pf_fixed) },
>  	{ "pf_guest", VCPU_STAT(pf_guest) },
> +	{ "apf_not_present", VCPU_STAT(apf_not_present) },
> +	{ "apf_present", VCPU_STAT(apf_present) },
>  	{ "tlb_flush", VCPU_STAT(tlb_flush) },
>  	{ "invlpg", VCPU_STAT(invlpg) },
>  	{ "exits", VCPU_STAT(exits) },
> @@ -1226,6 +1228,7 @@ static int kvm_pv_enable_async_pf(struct kvm_vcpu *vcpu, u64 data)
>  
>  	if (!(data & KVM_ASYNC_PF_ENABLED)) {
>  		vcpu->arch.apf_data = NULL;
> +		kvm_clear_async_pf_completion_queue(vcpu);
>  		return 0;
>  	}
>  
> @@ -1240,6 +1243,8 @@ static int kvm_pv_enable_async_pf(struct kvm_vcpu *vcpu, u64 data)
>  		vcpu->arch.apf_data = NULL;
>  		return 1;
>  	}
> +	vcpu->arch.apf_memslot_ver = vcpu->kvm->memslot_version;
> +	kvm_async_pf_wakeup_all(vcpu);
>  	return 0;
>  }
>  
> @@ -4721,6 +4726,8 @@ static int vcpu_enter_guest(struct kvm_vcpu *vcpu)
>  	if (unlikely(r))
>  		goto out;
>  
> +	kvm_check_async_pf_completion(vcpu);
> +
>  	preempt_disable();
>  
>  	kvm_x86_ops->prepare_guest_switch(vcpu);
> @@ -5393,6 +5400,8 @@ int kvm_arch_vcpu_reset(struct kvm_vcpu *vcpu)
>  	vcpu->arch.apf_data = NULL;
>  	vcpu->arch.apf_msr_val = 0;
>  
> +	kvm_clear_async_pf_completion_queue(vcpu);
> +
>  	return kvm_x86_ops->vcpu_reset(vcpu);
>  }
>  
> @@ -5534,8 +5543,10 @@ static void kvm_free_vcpus(struct kvm *kvm)
>  	/*
>  	 * Unpin any mmu pages first.
>  	 */
> -	kvm_for_each_vcpu(i, vcpu, kvm)
> +	kvm_for_each_vcpu(i, vcpu, kvm) {
> +		kvm_clear_async_pf_completion_queue(vcpu);
>  		kvm_unload_vcpu_mmu(vcpu);
> +	}
>  	kvm_for_each_vcpu(i, vcpu, kvm)
>  		kvm_arch_vcpu_free(vcpu);
>  
> @@ -5647,6 +5658,7 @@ void kvm_arch_flush_shadow(struct kvm *kvm)
>  int kvm_arch_vcpu_runnable(struct kvm_vcpu *vcpu)
>  {
>  	return vcpu->arch.mp_state == KVM_MP_STATE_RUNNABLE
> +		|| !list_empty_careful(&vcpu->async_pf_done)
>  		|| vcpu->arch.mp_state == KVM_MP_STATE_SIPI_RECEIVED
>  		|| vcpu->arch.nmi_pending ||
>  		(kvm_arch_interrupt_allowed(vcpu) &&
> @@ -5704,6 +5716,55 @@ void kvm_set_rflags(struct kvm_vcpu *vcpu, unsigned long rflags)
>  }
>  EXPORT_SYMBOL_GPL(kvm_set_rflags);
>  
> +static int apf_put_user(struct kvm_vcpu *vcpu, u32 val)
> +{
> +	if (unlikely(vcpu->arch.apf_memslot_ver !=
> +		     vcpu->kvm->memslot_version)) {
> +		u64 gpa = vcpu->arch.apf_msr_val & ~0x3f;
> +		unsigned long addr;
> +		int offset = offset_in_page(gpa);
> +
> +		addr = gfn_to_hva(vcpu->kvm, gpa >> PAGE_SHIFT);
> +		vcpu->arch.apf_data = (u32 __user*)(addr + offset);
> +		if (kvm_is_error_hva(addr)) {
> +			vcpu->arch.apf_data = NULL;
> +			return -EFAULT;
> +		}
> +	}
> +
> +	return put_user(val, vcpu->arch.apf_data);
> +}

Why not use kvm_write_guest?

> +int kvm_setup_async_pf(struct kvm_vcpu *vcpu, gva_t gva, gfn_t gfn,
> +		       struct kvm_arch_async_pf *arch)
> +{
> +	struct kvm_async_pf *work;
> +
> +	if (vcpu->async_pf_queued >= ASYNC_PF_PER_VCPU)
> +		return 0;
> +
> +	/* setup slow work */
> +
> +	/* do alloc atomic since if we are going to sleep anyway we
> +	   may as well sleep faulting in page */
> +	work = kmem_cache_zalloc(async_pf_cache, GFP_ATOMIC);
> +	if (!work)
> +		return 0;

GFP_KERNEL is fine for this context.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
