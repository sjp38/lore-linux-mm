Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 24FD06B009E
	for <linux-mm@kvack.org>; Wed, 20 Oct 2010 07:29:05 -0400 (EDT)
Message-ID: <4CBED271.9000103@siemens.com>
Date: Wed, 20 Oct 2010 13:28:49 +0200
From: Jan Kiszka <jan.kiszka@siemens.com>
MIME-Version: 1.0
Subject: Re: [PATCH v7 02/12] Halt vcpu if page it tries to access is swapped
 out.
References: <1287048176-2563-1-git-send-email-gleb@redhat.com> <1287048176-2563-3-git-send-email-gleb@redhat.com>
In-Reply-To: <1287048176-2563-3-git-send-email-gleb@redhat.com>
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Gleb Natapov <gleb@redhat.com>
Cc: kvm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, avi@redhat.com, mingo@elte.hu, a.p.zijlstra@chello.nl, tglx@linutronix.de, hpa@zytor.com, riel@redhat.com, cl@linux-foundation.org, mtosatti@redhat.com
List-ID: <linux-mm.kvack.org>

Am 14.10.2010 11:22, Gleb Natapov wrote:
> If a guest accesses swapped out memory do not swap it in from vcpu thread
> context. Schedule work to do swapping and put vcpu into halted state
> instead.
> 
> Interrupts will still be delivered to the guest and if interrupt will
> cause reschedule guest will continue to run another task.
> 
> Acked-by: Rik van Riel <riel@redhat.com>
> Signed-off-by: Gleb Natapov <gleb@redhat.com>
> ---
>  arch/x86/include/asm/kvm_host.h |   18 ++++
>  arch/x86/kvm/Kconfig            |    1 +
>  arch/x86/kvm/Makefile           |    1 +
>  arch/x86/kvm/mmu.c              |   52 +++++++++++-
>  arch/x86/kvm/paging_tmpl.h      |    4 +-
>  arch/x86/kvm/x86.c              |  112 ++++++++++++++++++++++-
>  include/linux/kvm_host.h        |   31 +++++++
>  include/trace/events/kvm.h      |   90 ++++++++++++++++++
>  virt/kvm/Kconfig                |    3 +
>  virt/kvm/async_pf.c             |  190 +++++++++++++++++++++++++++++++++++++++
>  virt/kvm/async_pf.h             |   36 ++++++++
>  virt/kvm/kvm_main.c             |   57 +++++++++---
>  12 files changed, 578 insertions(+), 17 deletions(-)
>  create mode 100644 virt/kvm/async_pf.c
>  create mode 100644 virt/kvm/async_pf.h
> 
> diff --git a/arch/x86/include/asm/kvm_host.h b/arch/x86/include/asm/kvm_host.h
> index e209078..043e29e 100644
> --- a/arch/x86/include/asm/kvm_host.h
> +++ b/arch/x86/include/asm/kvm_host.h
> @@ -83,11 +83,14 @@
>  #define KVM_NR_FIXED_MTRR_REGION 88
>  #define KVM_NR_VAR_MTRR 8
>  
> +#define ASYNC_PF_PER_VCPU 64
> +
>  extern spinlock_t kvm_lock;
>  extern struct list_head vm_list;
>  
>  struct kvm_vcpu;
>  struct kvm;
> +struct kvm_async_pf;
>  
>  enum kvm_reg {
>  	VCPU_REGS_RAX = 0,
> @@ -412,6 +415,11 @@ struct kvm_vcpu_arch {
>  	u64 hv_vapic;
>  
>  	cpumask_var_t wbinvd_dirty_mask;
> +
> +	struct {
> +		bool halted;
> +		gfn_t gfns[roundup_pow_of_two(ASYNC_PF_PER_VCPU)];
> +	} apf;
>  };
>  
>  struct kvm_arch {
> @@ -585,6 +593,10 @@ struct kvm_x86_ops {
>  	const struct trace_print_flags *exit_reasons_str;
>  };
>  
> +struct kvm_arch_async_pf {
> +	gfn_t gfn;
> +};
> +
>  extern struct kvm_x86_ops *kvm_x86_ops;
>  
>  int kvm_mmu_module_init(void);
> @@ -823,4 +835,10 @@ void kvm_set_shared_msr(unsigned index, u64 val, u64 mask);
>  
>  bool kvm_is_linear_rip(struct kvm_vcpu *vcpu, unsigned long linear_rip);
>  
> +void kvm_arch_async_page_not_present(struct kvm_vcpu *vcpu,
> +				     struct kvm_async_pf *work);
> +void kvm_arch_async_page_present(struct kvm_vcpu *vcpu,
> +				 struct kvm_async_pf *work);
> +extern bool kvm_find_async_pf_gfn(struct kvm_vcpu *vcpu, gfn_t gfn);
> +
>  #endif /* _ASM_X86_KVM_HOST_H */
> diff --git a/arch/x86/kvm/Kconfig b/arch/x86/kvm/Kconfig
> index ddc131f..50f6364 100644
> --- a/arch/x86/kvm/Kconfig
> +++ b/arch/x86/kvm/Kconfig
> @@ -28,6 +28,7 @@ config KVM
>  	select HAVE_KVM_IRQCHIP
>  	select HAVE_KVM_EVENTFD
>  	select KVM_APIC_ARCHITECTURE
> +	select KVM_ASYNC_PF
>  	select USER_RETURN_NOTIFIER
>  	select KVM_MMIO
>  	---help---
> diff --git a/arch/x86/kvm/Makefile b/arch/x86/kvm/Makefile
> index 31a7035..c53bf19 100644
> --- a/arch/x86/kvm/Makefile
> +++ b/arch/x86/kvm/Makefile
> @@ -9,6 +9,7 @@ kvm-y			+= $(addprefix ../../../virt/kvm/, kvm_main.o ioapic.o \
>  				coalesced_mmio.o irq_comm.o eventfd.o \
>  				assigned-dev.o)
>  kvm-$(CONFIG_IOMMU_API)	+= $(addprefix ../../../virt/kvm/, iommu.o)
> +kvm-$(CONFIG_KVM_ASYNC_PF)	+= $(addprefix ../../../virt/kvm/, async_pf.o)
>  
>  kvm-y			+= x86.o mmu.o emulate.o i8259.o irq.o lapic.o \
>  			   i8254.o timer.o
> diff --git a/arch/x86/kvm/mmu.c b/arch/x86/kvm/mmu.c
> index 908ea54..f01e89a 100644
> --- a/arch/x86/kvm/mmu.c
> +++ b/arch/x86/kvm/mmu.c
> @@ -18,9 +18,11 @@
>   *
>   */
>  
> +#include "irq.h"
>  #include "mmu.h"
>  #include "x86.h"
>  #include "kvm_cache_regs.h"
> +#include "x86.h"
>  
>  #include <linux/kvm_host.h>
>  #include <linux/types.h>
> @@ -2585,6 +2587,50 @@ static int nonpaging_page_fault(struct kvm_vcpu *vcpu, gva_t gva,
>  			     error_code & PFERR_WRITE_MASK, gfn);
>  }
>  
> +int kvm_arch_setup_async_pf(struct kvm_vcpu *vcpu, gva_t gva, gfn_t gfn)
> +{
> +	struct kvm_arch_async_pf arch;
> +	arch.gfn = gfn;
> +
> +	return kvm_setup_async_pf(vcpu, gva, gfn, &arch);
> +}
> +
> +static bool can_do_async_pf(struct kvm_vcpu *vcpu)
> +{
> +	if (unlikely(!irqchip_in_kernel(vcpu->kvm) ||
> +		     kvm_event_needs_reinjection(vcpu)))
> +		return false;
> +
> +	return kvm_x86_ops->interrupt_allowed(vcpu);
> +}
> +
> +static bool try_async_pf(struct kvm_vcpu *vcpu, gfn_t gfn, gva_t gva,
> +			 pfn_t *pfn)
> +{
> +	bool async;
> +
> +	*pfn = gfn_to_pfn_async(vcpu->kvm, gfn, &async);
> +
> +	if (!async)
> +		return false; /* *pfn has correct page already */
> +
> +	put_page(pfn_to_page(*pfn));
> +
> +	if (can_do_async_pf(vcpu)) {
> +		trace_kvm_try_async_get_page(async, *pfn);
> +		if (kvm_find_async_pf_gfn(vcpu, gfn)) {
> +			trace_kvm_async_pf_doublefault(gva, gfn);
> +			kvm_make_request(KVM_REQ_APF_HALT, vcpu);
> +			return true;
> +		} else if (kvm_arch_setup_async_pf(vcpu, gva, gfn))
> +			return true;
> +	}
> +
> +	*pfn = gfn_to_pfn(vcpu->kvm, gfn);
> +	
> +	return false;
> +}
> +
>  static int tdp_page_fault(struct kvm_vcpu *vcpu, gva_t gpa,
>  				u32 error_code)
>  {
> @@ -2607,7 +2653,11 @@ static int tdp_page_fault(struct kvm_vcpu *vcpu, gva_t gpa,
>  
>  	mmu_seq = vcpu->kvm->mmu_notifier_seq;
>  	smp_rmb();
> -	pfn = gfn_to_pfn(vcpu->kvm, gfn);
> +
> +	if (try_async_pf(vcpu, gfn, gpa, &pfn))
> +		return 0;
> +
> +	/* mmio */
>  	if (is_error_pfn(pfn))
>  		return kvm_handle_bad_page(vcpu->kvm, gfn, pfn);
>  	spin_lock(&vcpu->kvm->mmu_lock);
> diff --git a/arch/x86/kvm/paging_tmpl.h b/arch/x86/kvm/paging_tmpl.h
> index cd7a833..c45376d 100644
> --- a/arch/x86/kvm/paging_tmpl.h
> +++ b/arch/x86/kvm/paging_tmpl.h
> @@ -568,7 +568,9 @@ static int FNAME(page_fault)(struct kvm_vcpu *vcpu, gva_t addr,
>  
>  	mmu_seq = vcpu->kvm->mmu_notifier_seq;
>  	smp_rmb();
> -	pfn = gfn_to_pfn(vcpu->kvm, walker.gfn);
> +
> +	if (try_async_pf(vcpu, walker.gfn, addr, &pfn))
> +		return 0;
>  
>  	/* mmio */
>  	if (is_error_pfn(pfn))
> diff --git a/arch/x86/kvm/x86.c b/arch/x86/kvm/x86.c
> index 7127a13..09e72fc 100644
> --- a/arch/x86/kvm/x86.c
> +++ b/arch/x86/kvm/x86.c
> @@ -43,6 +43,7 @@
>  #include <linux/slab.h>
>  #include <linux/perf_event.h>
>  #include <linux/uaccess.h>
> +#include <linux/hash.h>
>  #include <trace/events/kvm.h>
>  
>  #define CREATE_TRACE_POINTS
> @@ -155,6 +156,13 @@ struct kvm_stats_debugfs_item debugfs_entries[] = {
>  
>  u64 __read_mostly host_xcr0;
>  
> +static inline void kvm_async_pf_hash_reset(struct kvm_vcpu *vcpu)
> +{
> +	int i;
> +	for (i = 0; i < roundup_pow_of_two(ASYNC_PF_PER_VCPU); i++)
> +		vcpu->arch.apf.gfns[i] = ~0;
> +}
> +
>  static inline u32 bit(int bitno)
>  {
>  	return 1 << (bitno & 31);
> @@ -5110,6 +5118,12 @@ static int vcpu_enter_guest(struct kvm_vcpu *vcpu)
>  			vcpu->fpu_active = 0;
>  			kvm_x86_ops->fpu_deactivate(vcpu);
>  		}
> +		if (kvm_check_request(KVM_REQ_APF_HALT, vcpu)) {
> +			/* Page is swapped out. Do synthetic halt */
> +			vcpu->arch.apf.halted = true;
> +			r = 1;
> +			goto out;
> +		}
>  	}
>  
>  	r = kvm_mmu_reload(vcpu);
> @@ -5238,7 +5252,8 @@ static int __vcpu_run(struct kvm_vcpu *vcpu)
>  
>  	r = 1;
>  	while (r > 0) {
> -		if (vcpu->arch.mp_state == KVM_MP_STATE_RUNNABLE)
> +		if (vcpu->arch.mp_state == KVM_MP_STATE_RUNNABLE &&
> +		    !vcpu->arch.apf.halted)
>  			r = vcpu_enter_guest(vcpu);
>  		else {
>  			srcu_read_unlock(&kvm->srcu, vcpu->srcu_idx);
> @@ -5251,6 +5266,7 @@ static int __vcpu_run(struct kvm_vcpu *vcpu)
>  					vcpu->arch.mp_state =
>  						KVM_MP_STATE_RUNNABLE;
>  				case KVM_MP_STATE_RUNNABLE:
> +					vcpu->arch.apf.halted = false;
>  					break;
>  				case KVM_MP_STATE_SIPI_RECEIVED:
>  				default:
> @@ -5272,6 +5288,9 @@ static int __vcpu_run(struct kvm_vcpu *vcpu)
>  			vcpu->run->exit_reason = KVM_EXIT_INTR;
>  			++vcpu->stat.request_irq_exits;
>  		}
> +		
> +		kvm_check_async_pf_completion(vcpu);
> +
>  		if (signal_pending(current)) {
>  			r = -EINTR;
>  			vcpu->run->exit_reason = KVM_EXIT_INTR;
> @@ -5785,6 +5804,10 @@ int kvm_arch_vcpu_reset(struct kvm_vcpu *vcpu)
>  
>  	kvm_make_request(KVM_REQ_EVENT, vcpu);
>  
> +	kvm_clear_async_pf_completion_queue(vcpu);
> +	kvm_async_pf_hash_reset(vcpu);
> +	vcpu->arch.apf.halted = false;
> +
>  	return kvm_x86_ops->vcpu_reset(vcpu);
>  }
>  
> @@ -5873,6 +5896,8 @@ int kvm_arch_vcpu_init(struct kvm_vcpu *vcpu)
>  	if (!zalloc_cpumask_var(&vcpu->arch.wbinvd_dirty_mask, GFP_KERNEL))
>  		goto fail_free_mce_banks;
>  
> +	kvm_async_pf_hash_reset(vcpu);
> +
>  	return 0;
>  fail_free_mce_banks:
>  	kfree(vcpu->arch.mce_banks);
> @@ -5931,8 +5956,10 @@ static void kvm_free_vcpus(struct kvm *kvm)
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
> @@ -6043,7 +6070,9 @@ void kvm_arch_flush_shadow(struct kvm *kvm)
>  
>  int kvm_arch_vcpu_runnable(struct kvm_vcpu *vcpu)
>  {
> -	return vcpu->arch.mp_state == KVM_MP_STATE_RUNNABLE
> +	return (vcpu->arch.mp_state == KVM_MP_STATE_RUNNABLE &&
> +		!vcpu->arch.apf.halted)
> +		|| !list_empty_careful(&vcpu->async_pf.done)
>  		|| vcpu->arch.mp_state == KVM_MP_STATE_SIPI_RECEIVED
>  		|| vcpu->arch.nmi_pending ||
>  		(kvm_arch_interrupt_allowed(vcpu) &&
> @@ -6102,6 +6131,83 @@ void kvm_set_rflags(struct kvm_vcpu *vcpu, unsigned long rflags)
>  }
>  EXPORT_SYMBOL_GPL(kvm_set_rflags);
>  
> +static inline u32 kvm_async_pf_hash_fn(gfn_t gfn)
> +{
> +	return hash_32(gfn & 0xffffffff, order_base_2(ASYNC_PF_PER_VCPU));
> +}
> +
> +static inline u32 kvm_async_pf_next_probe(u32 key)
> +{
> +	return (key + 1) & (roundup_pow_of_two(ASYNC_PF_PER_VCPU) - 1);
> +}
> +
> +static void kvm_add_async_pf_gfn(struct kvm_vcpu *vcpu, gfn_t gfn)
> +{
> +	u32 key = kvm_async_pf_hash_fn(gfn);
> +
> +	while (vcpu->arch.apf.gfns[key] != ~0)
> +		key = kvm_async_pf_next_probe(key);
> +
> +	vcpu->arch.apf.gfns[key] = gfn;
> +}
> +
> +static u32 kvm_async_pf_gfn_slot(struct kvm_vcpu *vcpu, gfn_t gfn)
> +{
> +	int i;
> +	u32 key = kvm_async_pf_hash_fn(gfn);
> +
> +	for (i = 0; i < roundup_pow_of_two(ASYNC_PF_PER_VCPU) &&
> +		     (vcpu->arch.apf.gfns[key] != gfn ||
> +		      vcpu->arch.apf.gfns[key] == ~0); i++)
> +		key = kvm_async_pf_next_probe(key);
> +
> +	return key;
> +}
> +
> +bool kvm_find_async_pf_gfn(struct kvm_vcpu *vcpu, gfn_t gfn)
> +{
> +	return vcpu->arch.apf.gfns[kvm_async_pf_gfn_slot(vcpu, gfn)] == gfn;
> +}
> +
> +static void kvm_del_async_pf_gfn(struct kvm_vcpu *vcpu, gfn_t gfn)
> +{
> +	u32 i, j, k;
> +
> +	i = j = kvm_async_pf_gfn_slot(vcpu, gfn);
> +	while (true) {
> +		vcpu->arch.apf.gfns[i] = ~0;
> +		do {
> +			j = kvm_async_pf_next_probe(j);
> +			if (vcpu->arch.apf.gfns[j] == ~0)
> +				return;
> +			k = kvm_async_pf_hash_fn(vcpu->arch.apf.gfns[j]);
> +			/*
> +			 * k lies cyclically in ]i,j]
> +			 * |    i.k.j |
> +			 * |....j i.k.| or  |.k..j i...|
> +			 */
> +		} while ((i <= j) ? (i < k && k <= j) : (i < k || k <= j));
> +		vcpu->arch.apf.gfns[i] = vcpu->arch.apf.gfns[j];
> +		i = j;
> +	}
> +}
> +
> +void kvm_arch_async_page_not_present(struct kvm_vcpu *vcpu,
> +				     struct kvm_async_pf *work)
> +{
> +	trace_kvm_async_pf_not_present(work->gva);
> +
> +	kvm_make_request(KVM_REQ_APF_HALT, vcpu);
> +	kvm_add_async_pf_gfn(vcpu, work->arch.gfn);
> +}
> +
> +void kvm_arch_async_page_present(struct kvm_vcpu *vcpu,
> +				 struct kvm_async_pf *work)
> +{
> +	trace_kvm_async_pf_ready(work->gva);
> +	kvm_del_async_pf_gfn(vcpu, work->arch.gfn);
> +}
> +
>  EXPORT_TRACEPOINT_SYMBOL_GPL(kvm_exit);
>  EXPORT_TRACEPOINT_SYMBOL_GPL(kvm_inj_virq);
>  EXPORT_TRACEPOINT_SYMBOL_GPL(kvm_page_fault);
> diff --git a/include/linux/kvm_host.h b/include/linux/kvm_host.h
> index 0b89d00..9a9b017 100644
> --- a/include/linux/kvm_host.h
> +++ b/include/linux/kvm_host.h
> @@ -40,6 +40,7 @@
>  #define KVM_REQ_KICK               9
>  #define KVM_REQ_DEACTIVATE_FPU    10
>  #define KVM_REQ_EVENT             11
> +#define KVM_REQ_APF_HALT          12
>  
>  #define KVM_USERSPACE_IRQ_SOURCE_ID	0
>  
> @@ -74,6 +75,26 @@ int kvm_io_bus_register_dev(struct kvm *kvm, enum kvm_bus bus_idx,
>  int kvm_io_bus_unregister_dev(struct kvm *kvm, enum kvm_bus bus_idx,
>  			      struct kvm_io_device *dev);
>  
> +#ifdef CONFIG_KVM_ASYNC_PF
> +struct kvm_async_pf {
> +	struct work_struct work;
> +	struct list_head link;
> +	struct list_head queue;
> +	struct kvm_vcpu *vcpu;
> +	struct mm_struct *mm;
> +	gva_t gva;
> +	unsigned long addr;
> +	struct kvm_arch_async_pf arch;
> +	struct page *page;
> +	bool done;
> +};
> +
> +void kvm_clear_async_pf_completion_queue(struct kvm_vcpu *vcpu);
> +void kvm_check_async_pf_completion(struct kvm_vcpu *vcpu);
> +int kvm_setup_async_pf(struct kvm_vcpu *vcpu, gva_t gva, gfn_t gfn,
> +		       struct kvm_arch_async_pf *arch);
> +#endif
> +

Based on early kvm-kmod experiments, it looks like this (and maybe more)
breaks the build in arch/x86/kvm/x86.c if CONFIG_KVM_ASYNC_PF is
disabled. Please have a look.

Jan

-- 
Siemens AG, Corporate Technology, CT T DE IT 1
Corporate Competence Center Embedded Linux

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
