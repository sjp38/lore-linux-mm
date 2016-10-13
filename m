Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6BD926B0265
	for <linux-mm@kvack.org>; Thu, 13 Oct 2016 06:41:24 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id d186so46146807lfg.7
        for <linux-mm@kvack.org>; Thu, 13 Oct 2016 03:41:24 -0700 (PDT)
Received: from mail-lf0-x241.google.com (mail-lf0-x241.google.com. [2a00:1450:4010:c07::241])
        by mx.google.com with ESMTPS id t142si725620lff.106.2016.10.13.03.41.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Oct 2016 03:41:22 -0700 (PDT)
Received: by mail-lf0-x241.google.com with SMTP id x79so12028941lff.2
        for <linux-mm@kvack.org>; Thu, 13 Oct 2016 03:41:22 -0700 (PDT)
Subject: Re: [RFC PATCH v1 20/28] KVM: SVM: prepare for SEV guest management
 API support
References: <147190820782.9523.4967724730957229273.stgit@brijesh-build-machine>
 <147190848221.9523.931142742439444357.stgit@brijesh-build-machine>
From: Paolo Bonzini <pbonzini@redhat.com>
Message-ID: <66baf736-d2c7-4c66-8bed-997244fb8f73@redhat.com>
Date: Thu, 13 Oct 2016 12:41:16 +0200
MIME-Version: 1.0
In-Reply-To: <147190848221.9523.931142742439444357.stgit@brijesh-build-machine>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Brijesh Singh <brijesh.singh@amd.com>, simon.guinot@sequanux.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, rkrcmar@redhat.com, matt@codeblueprint.co.uk, linus.walleij@linaro.org, linux-mm@kvack.org, paul.gortmaker@windriver.com, hpa@zytor.com, dan.j.williams@intel.com, aarcange@redhat.com, sfr@canb.auug.org.au, andriy.shevchenko@linux.intel.com, herbert@gondor.apana.org.au, bhe@redhat.com, xemul@parallels.com, joro@8bytes.org, x86@kernel.org, mingo@redhat.com, msalter@redhat.com, ross.zwisler@linux.intel.com, bp@suse.de, dyoung@redhat.com, thomas.lendacky@amd.com, jroedel@suse.de, keescook@chromium.org, toshi.kani@hpe.com, mathieu.desnoyers@efficios.com, devel@linuxdriverproject.org, tglx@linutronix.de, mchehab@kernel.org, iamjoonsoo.kim@lge.com, labbott@fedoraproject.org, tony.luck@intel.com



On 23/08/2016 01:28, Brijesh Singh wrote:
> The patch adds initial support required for Secure Encrypted
> Virtualization (SEV) guest management API's.
> 
> ASID management:
>  - Reserve asid range for SEV guest, SEV asid range is obtained
>    through CPUID Fn8000_001f[ECX]. A non-SEV guest can use any
>    asid outside the SEV asid range.
>  - SEV guest must have asid value within asid range obtained
>    through CPUID.
>  - SEV guest must have the same asid for all vcpu's. A TLB flush
>    is required if different vcpu for the same ASID is to be run
>    on the same host CPU.
> 
> - save SEV private structure in kvm_arch.
> 
> - If SEV is available then initialize PSP firmware during hardware probe
> 
> Signed-off-by: Brijesh Singh <brijesh.singh@amd.com>
> ---
>  arch/x86/include/asm/kvm_host.h |    9 ++
>  arch/x86/kvm/svm.c              |  213 +++++++++++++++++++++++++++++++++++++++
>  2 files changed, 221 insertions(+), 1 deletion(-)
> 
> diff --git a/arch/x86/include/asm/kvm_host.h b/arch/x86/include/asm/kvm_host.h
> index b1dd673..9b885fc 100644
> --- a/arch/x86/include/asm/kvm_host.h
> +++ b/arch/x86/include/asm/kvm_host.h
> @@ -715,6 +715,12 @@ struct kvm_hv {
>  	u64 hv_crash_ctl;
>  };
>  
> +struct kvm_sev_info {
> +	unsigned int asid;	/* asid for this guest */
> +	unsigned int handle;	/* firmware handle */
> +	unsigned int ref_count; /* number of active vcpus */
> +};
> +
>  struct kvm_arch {
>  	unsigned int n_used_mmu_pages;
>  	unsigned int n_requested_mmu_pages;
> @@ -799,6 +805,9 @@ struct kvm_arch {
>  
>  	bool x2apic_format;
>  	bool x2apic_broadcast_quirk_disabled;
> +
> +	/* struct for SEV guest */
> +	struct kvm_sev_info sev_info;
>  };
>  
>  struct kvm_vm_stat {
> diff --git a/arch/x86/kvm/svm.c b/arch/x86/kvm/svm.c
> index f010b23..dcee635 100644
> --- a/arch/x86/kvm/svm.c
> +++ b/arch/x86/kvm/svm.c
> @@ -34,6 +34,7 @@
>  #include <linux/sched.h>
>  #include <linux/trace_events.h>
>  #include <linux/slab.h>
> +#include <linux/ccp-psp.h>
>  
>  #include <asm/apic.h>
>  #include <asm/perf_event.h>
> @@ -186,6 +187,9 @@ struct vcpu_svm {
>  	struct page *avic_backing_page;
>  	u64 *avic_physical_id_cache;
>  	bool avic_is_running;
> +
> +	/* which host cpu was used for running this vcpu */
> +	bool last_cpuid;
>  };
>  
>  #define AVIC_LOGICAL_ID_ENTRY_GUEST_PHYSICAL_ID_MASK	(0xFF)
> @@ -243,6 +247,25 @@ static int avic;
>  module_param(avic, int, S_IRUGO);
>  #endif
>  
> +/* Secure Encrypted Virtualization */
> +static bool sev_enabled;

You can check max_sev_asid != 0 instead (wrapped in a sev_enabled()
function).

> +static unsigned long max_sev_asid;

Need not be 64-bit.

> +static unsigned long *sev_asid_bitmap;

Please note what lock protects this, and modify it with __set_bit and
__clear_bit.

> +#define kvm_sev_guest()		(kvm->arch.sev_info.handle)
> +#define kvm_sev_handle()	(kvm->arch.sev_info.handle)
> +#define kvm_sev_ref()		(kvm->arch.sev_info.ref_count++)
> +#define kvm_sev_unref()		(kvm->arch.sev_info.ref_count--)
> +#define svm_sev_handle()	(svm->vcpu.kvm->arch.sev_info.handle)
> +#define svm_sev_asid()		(svm->vcpu.kvm->arch.sev_info.asid)
> +#define svm_sev_ref()		(svm->vcpu.kvm->arch.sev_info.ref_count++)
> +#define svm_sev_unref()		(svm->vcpu.kvm->arch.sev_info.ref_count--)
> +#define svm_sev_guest()		(svm->vcpu.kvm->arch.sev_info.handle)
> +#define svm_sev_ref_count()	(svm->vcpu.kvm->arch.sev_info.ref_count)

Why is the reference count necessary?  Could you use the kvm refcount
instead and free the ASID in kvm_x86_ops->vm_destroy?  Also, what lock
protects the reference count?

Also please remove the macros in general.  If there is only a struct
vcpu_svm*, use

    struct kvm_arch *vm_data = &svm->vcpu.kvm->arch;

as done for example in avic_init_vmcb.

> +
> +static int sev_asid_new(void);
> +static void sev_asid_free(int asid);
> +
>  static void svm_set_cr0(struct kvm_vcpu *vcpu, unsigned long cr0);
>  static void svm_flush_tlb(struct kvm_vcpu *vcpu);
>  static void svm_complete_interrupts(struct vcpu_svm *svm);
> @@ -474,6 +497,8 @@ struct svm_cpu_data {
>  	struct kvm_ldttss_desc *tss_desc;
>  
>  	struct page *save_area;
> +
> +	void **sev_vmcb;  /* index = sev_asid, value = vmcb pointer */

It's not a void**, it's a struct vmcb**.  Please rename it to sev_vmcbs,
too, so that it's clear that it's an array.

>  };
>  
>  static DEFINE_PER_CPU(struct svm_cpu_data *, svm_data);
> @@ -727,7 +752,10 @@ static int svm_hardware_enable(void)
>  	sd->asid_generation = 1;
>  	sd->max_asid = cpuid_ebx(SVM_CPUID_FUNC) - 1;
>  	sd->next_asid = sd->max_asid + 1;
> -	sd->min_asid = 1;
> +	sd->min_asid = max_sev_asid + 1;
> +
> +	if (sev_enabled)
> +		memset(sd->sev_vmcb, 0, (max_sev_asid + 1) * sizeof(void *));

This seems strange.  You should clear the field, for each possible CPU,
in sev_asid_free, not in sev_uninit_vcpu.  Then when you reuse the ASID,
sev_vmcbs[asid] will be NULL everywhere.

> @@ -931,6 +968,74 @@ static void svm_disable_lbrv(struct vcpu_svm *svm)
>  	set_msr_interception(msrpm, MSR_IA32_LASTINTTOIP, 0, 0);
>  }
>  
> +static __init void sev_hardware_setup(void)
> +{
> +	int ret, psp_ret;
> +	struct psp_data_init *init;
> +	struct psp_data_status *status;
> +
> +	/*
> +	 * Check SEV Feature Support: Fn8001_001F[EAX]
> +	 * 	Bit 1: Secure Memory Virtualization supported
> +	 */
> +	if (!(cpuid_eax(0x8000001F) & 0x2))
> +		return;
> +
> +	/*
> +	 * Get maximum number of encrypted guest supported: Fn8001_001F[ECX]
> +	 * 	Bit 31:0: Number of supported guest
> +	 */
> +	max_sev_asid = cpuid_ecx(0x8000001F);
> +	if (!max_sev_asid)
> +		return;
> +
> +	init = kzalloc(sizeof(*init), GFP_KERNEL);
> +	if (!init)
> +		return;
> +
> +	status = kzalloc(sizeof(*status), GFP_KERNEL);
> +	if (!status)
> +		goto err_1;
> +
> +	/* Initialize PSP firmware */
> +	init->hdr.buffer_len = sizeof(*init);
> +	init->flags = 0;
> +	ret = psp_platform_init(init, &psp_ret);
> +	if (ret) {
> +		printk(KERN_ERR "SEV: PSP_INIT ret=%d (%#x)\n", ret, psp_ret);
> +		goto err_2;
> +	}
> +
> +	/* Initialize SEV ASID bitmap */
> +	sev_asid_bitmap = kmalloc(max(sizeof(unsigned long),
> +				      max_sev_asid/8 + 1), GFP_KERNEL);

What you want here is

	kcalloc(BITS_TO_LONGS(max_sev_asid), sizeof(unsigned long),
		GFP_KERNEL);

> +	if (IS_ERR(sev_asid_bitmap)) {
> +		psp_platform_shutdown(&psp_ret);
> +		goto err_2;
> +	}
> +	bitmap_zero(sev_asid_bitmap, max_sev_asid);

... and then no need for the bitmap_zero.

> +	set_bit(0, sev_asid_bitmap);  /* mark ASID 0 as used */
> +
> +	sev_enabled = 1;
> +	printk(KERN_INFO "kvm: SEV enabled\n");
> +
> +	/* Query the platform status and print API version */
> +	status->hdr.buffer_len = sizeof(*status);
> +	ret = psp_platform_status(status, &psp_ret);
> +	if (ret) {
> +		printk(KERN_ERR "SEV: PLATFORM_STATUS ret=%#x\n", psp_ret);
> +		goto err_2;
> +	}
> +
> +	printk(KERN_INFO "SEV API: %d.%d\n",
> +			status->api_major, status->api_minor);
> +err_2:
> +	kfree(status);
> +err_1:
> +	kfree(init);
> +	return;
> +}
> +
>  static __init int svm_hardware_setup(void)
>  {
>  	int cpu;
> @@ -966,6 +1071,8 @@ static __init int svm_hardware_setup(void)
>  		kvm_enable_efer_bits(EFER_SVME | EFER_LMSLE);
>  	}
>  
> +	sev_hardware_setup();
> +
>  	for_each_possible_cpu(cpu) {
>  		r = svm_cpu_init(cpu);
>  		if (r)
> @@ -1003,10 +1110,25 @@ err:
>  	return r;
>  }
>  
> +static __exit void sev_hardware_unsetup(void)
> +{
> +	int ret, psp_ret;
> +
> +	ret = psp_platform_shutdown(&psp_ret);
> +	if (ret)
> +		printk(KERN_ERR "failed to shutdown PSP rc=%d (%#0x10x)\n",
> +		ret, psp_ret);
> +
> +	kfree(sev_asid_bitmap);
> +}
> +
>  static __exit void svm_hardware_unsetup(void)
>  {
>  	int cpu;
>  
> +	if (sev_enabled)
> +		sev_hardware_unsetup();
> +
>  	for_each_possible_cpu(cpu)
>  		svm_cpu_uninit(cpu);
>  
> @@ -1088,6 +1210,11 @@ static void avic_init_vmcb(struct vcpu_svm *svm)
>  	svm->vcpu.arch.apicv_active = true;
>  }
>  
> +static void sev_init_vmcb(struct vcpu_svm *svm)
> +{
> +	svm->vmcb->control.nested_ctl |= SVM_NESTED_CTL_SEV_ENABLE;
> +}
> +
>  static void init_vmcb(struct vcpu_svm *svm)
>  {
>  	struct vmcb_control_area *control = &svm->vmcb->control;
> @@ -1202,6 +1329,10 @@ static void init_vmcb(struct vcpu_svm *svm)
>  	if (avic)
>  		avic_init_vmcb(svm);
>  
> +	if (svm_sev_guest())
> +		sev_init_vmcb(svm);
> +
> +
>  	mark_all_dirty(svm->vmcb);
>  
>  	enable_gif(svm);
> @@ -1413,6 +1544,14 @@ static void svm_vcpu_reset(struct kvm_vcpu *vcpu, bool init_event)
>  		avic_update_vapic_bar(svm, APIC_DEFAULT_PHYS_BASE);
>  }
>  
> +static void sev_init_vcpu(struct vcpu_svm *svm)
> +{
> +	if (!svm_sev_guest())
> +		return;
> +
> +	svm_sev_ref();
> +}
> +
>  static struct kvm_vcpu *svm_create_vcpu(struct kvm *kvm, unsigned int id)
>  {
>  	struct vcpu_svm *svm;
> @@ -1475,6 +1614,7 @@ static struct kvm_vcpu *svm_create_vcpu(struct kvm *kvm, unsigned int id)
>  	init_vmcb(svm);
>  
>  	svm_init_osvw(&svm->vcpu);
> +	sev_init_vcpu(svm);
>  
>  	return &svm->vcpu;
>  
> @@ -1494,6 +1634,23 @@ out:
>  	return ERR_PTR(err);
>  }
>  
> +static void sev_uninit_vcpu(struct vcpu_svm *svm)
> +{
> +	int cpu;
> +	int asid = svm_sev_asid();
> +	struct svm_cpu_data *sd;
> +
> +	if (!svm_sev_guest())
> +		return;
> +
> +	svm_sev_unref();
> +
> +	for_each_possible_cpu(cpu) {
> +		sd = per_cpu(svm_data, cpu);
> +		sd->sev_vmcb[asid] = NULL;
> +	}
> +}
> +
>  static void svm_free_vcpu(struct kvm_vcpu *vcpu)
>  {
>  	struct vcpu_svm *svm = to_svm(vcpu);
> @@ -1502,6 +1659,7 @@ static void svm_free_vcpu(struct kvm_vcpu *vcpu)
>  	__free_pages(virt_to_page(svm->msrpm), MSRPM_ALLOC_ORDER);
>  	__free_page(virt_to_page(svm->nested.hsave));
>  	__free_pages(virt_to_page(svm->nested.msrpm), MSRPM_ALLOC_ORDER);
> +	sev_uninit_vcpu(svm);
>  	kvm_vcpu_uninit(vcpu);
>  	kmem_cache_free(kvm_vcpu_cache, svm);
>  }
> @@ -1945,6 +2103,11 @@ static int pf_interception(struct vcpu_svm *svm)
>  	default:
>  		error_code = svm->vmcb->control.exit_info_1;
>  
> +		/* In SEV mode, the guest physical address will have C-bit
> +		 * set. C-bit must be cleared before handling the fault.
> +		 */
> +		if (svm_sev_guest())
> +			fault_address &= ~sme_me_mask;
>  		trace_kvm_page_fault(fault_address, error_code);
>  		if (!npt_enabled && kvm_event_needs_reinjection(&svm->vcpu))
>  			kvm_mmu_unprotect_page_virt(&svm->vcpu, fault_address);
> @@ -4131,12 +4294,40 @@ static void reload_tss(struct kvm_vcpu *vcpu)
>  	load_TR_desc();
>  }
>  
> +static void pre_sev_run(struct vcpu_svm *svm)
> +{
> +	int asid = svm_sev_asid();
> +	int cpu = raw_smp_processor_id();
> +	struct svm_cpu_data *sd = per_cpu(svm_data, cpu);
> +
> +	/* Assign the asid allocated for this SEV guest */
> +	svm->vmcb->control.asid = svm_sev_asid();
> +
> +	/* Flush guest TLB:
> +	 * - when different VMCB for the same ASID is to be run on the
> +	 *   same host CPU
> +	 *   or 
> +	 * - this VMCB was executed on different host cpu in previous VMRUNs.
> +	 */
> +	if (sd->sev_vmcb[asid] != (void *)svm->vmcb ||
> +		svm->last_cpuid != cpu)
> +		svm->vmcb->control.tlb_ctl = TLB_CONTROL_FLUSH_ALL_ASID;
> +
> +	svm->last_cpuid = cpu;
> +	sd->sev_vmcb[asid] = (void *)svm->vmcb;
> +
> +	mark_dirty(svm->vmcb, VMCB_ASID);
> +}
> +
>  static void pre_svm_run(struct vcpu_svm *svm)
>  {
>  	int cpu = raw_smp_processor_id();
>  
>  	struct svm_cpu_data *sd = per_cpu(svm_data, cpu);
>  
> +	if (svm_sev_guest())
> +		return pre_sev_run(svm);
> +
>  	/* FIXME: handle wraparound of asid_generation */
>  	if (svm->asid_generation != sd->asid_generation)
>  		new_asid(svm, sd);
> @@ -4985,6 +5176,26 @@ static inline void avic_post_state_restore(struct kvm_vcpu *vcpu)
>  	avic_handle_ldr_update(vcpu);
>  }
>  
> +static int sev_asid_new(void)
> +{
> +	int pos;
> +
> +	if (!sev_enabled)
> +		return -ENOTTY;
> +
> +	pos = find_first_zero_bit(sev_asid_bitmap, max_sev_asid);
> +	if (pos >= max_sev_asid)
> +		return -EBUSY;
> +
> +	set_bit(pos, sev_asid_bitmap);
> +	return pos;
> +}
> +
> +static void sev_asid_free(int asid)
> +{
> +	clear_bit(asid, sev_asid_bitmap);
> +}

Please move these (and sev_asid_bitmap) to patch 22 where they're first
used.

Paolo

>  static struct kvm_x86_ops svm_x86_ops __ro_after_init = {
>  	.cpu_has_kvm_support = has_svm,
>  	.disabled_by_bios = is_disabled,
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
