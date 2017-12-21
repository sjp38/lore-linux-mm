Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 997AB6B0033
	for <linux-mm@kvack.org>; Thu, 21 Dec 2017 16:34:24 -0500 (EST)
Received: by mail-it0-f72.google.com with SMTP id x32so12288672ita.1
        for <linux-mm@kvack.org>; Thu, 21 Dec 2017 13:34:24 -0800 (PST)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id y4si5987426ite.139.2017.12.21.13.34.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Dec 2017 13:34:22 -0800 (PST)
Subject: Re: [RFC PATCH v4 04/18] kvm: x86: add
 kvm_mmu_nested_guest_page_fault() and kvmi_mmu_fault_gla()
References: <20171218190642.7790-1-alazar@bitdefender.com>
 <20171218190642.7790-5-alazar@bitdefender.com>
From: Patrick Colp <patrick.colp@oracle.com>
Message-ID: <d8c86eea-fca2-b13c-bdea-e09522843317@oracle.com>
Date: Thu, 21 Dec 2017 16:29:23 -0500
MIME-Version: 1.0
In-Reply-To: <20171218190642.7790-5-alazar@bitdefender.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?Q?Adalber_Laz=c4=83r?= <alazar@bitdefender.com>, kvm@vger.kernel.org
Cc: linux-mm@kvack.org, Paolo Bonzini <pbonzini@redhat.com>, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Xiao Guangrong <guangrong.xiao@linux.intel.com>, =?UTF-8?Q?Mihai_Don=c8=9bu?= <mdontu@bitdefender.com>

On 2017-12-18 02:06 PM, Adalber LazA?r wrote:
> From: Adalbert Lazar <alazar@bitdefender.com>
> 
> These are helper functions used by the VM introspection subsytem on the
> PF call path.
> 
> Signed-off-by: Mihai DonE?u <mdontu@bitdefender.com>
> ---
>   arch/x86/include/asm/kvm_host.h |  7 +++++++
>   arch/x86/include/asm/vmx.h      |  2 ++
>   arch/x86/kvm/mmu.c              | 10 ++++++++++
>   arch/x86/kvm/svm.c              |  8 ++++++++
>   arch/x86/kvm/vmx.c              |  9 +++++++++
>   5 files changed, 36 insertions(+)
> 
> diff --git a/arch/x86/include/asm/kvm_host.h b/arch/x86/include/asm/kvm_host.h
> index 8842d8e1e4ee..239eb628f8fb 100644
> --- a/arch/x86/include/asm/kvm_host.h
> +++ b/arch/x86/include/asm/kvm_host.h
> @@ -692,6 +692,9 @@ struct kvm_vcpu_arch {
>   	/* set at EPT violation at this point */
>   	unsigned long exit_qualification;
>   
> +	/* #PF translated error code from EPT/NPT exit reason */
> +	u64 error_code;
> +
>   	/* pv related host specific info */
>   	struct {
>   		bool pv_unhalted;
> @@ -1081,6 +1084,7 @@ struct kvm_x86_ops {
>   	int (*enable_smi_window)(struct kvm_vcpu *vcpu);
>   
>   	void (*msr_intercept)(struct kvm_vcpu *vcpu, unsigned int msr, bool enable);
> +	u64 (*fault_gla)(struct kvm_vcpu *vcpu);
>   };
>   
>   struct kvm_arch_async_pf {
> @@ -1455,4 +1459,7 @@ void kvm_arch_mmu_notifier_invalidate_range(struct kvm *kvm,
>   
>   void kvm_arch_msr_intercept(struct kvm_vcpu *vcpu, unsigned int msr,
>   				bool enable);
> +u64 kvm_mmu_fault_gla(struct kvm_vcpu *vcpu);
> +bool kvm_mmu_nested_guest_page_fault(struct kvm_vcpu *vcpu);
> +
>   #endif /* _ASM_X86_KVM_HOST_H */
> diff --git a/arch/x86/include/asm/vmx.h b/arch/x86/include/asm/vmx.h
> index 8b6780751132..7036125349dd 100644
> --- a/arch/x86/include/asm/vmx.h
> +++ b/arch/x86/include/asm/vmx.h
> @@ -530,6 +530,7 @@ struct vmx_msr_entry {
>   #define EPT_VIOLATION_READABLE_BIT	3
>   #define EPT_VIOLATION_WRITABLE_BIT	4
>   #define EPT_VIOLATION_EXECUTABLE_BIT	5
> +#define EPT_VIOLATION_GLA_VALID_BIT	7
>   #define EPT_VIOLATION_GVA_TRANSLATED_BIT 8
>   #define EPT_VIOLATION_ACC_READ		(1 << EPT_VIOLATION_ACC_READ_BIT)
>   #define EPT_VIOLATION_ACC_WRITE		(1 << EPT_VIOLATION_ACC_WRITE_BIT)
> @@ -537,6 +538,7 @@ struct vmx_msr_entry {
>   #define EPT_VIOLATION_READABLE		(1 << EPT_VIOLATION_READABLE_BIT)
>   #define EPT_VIOLATION_WRITABLE		(1 << EPT_VIOLATION_WRITABLE_BIT)
>   #define EPT_VIOLATION_EXECUTABLE	(1 << EPT_VIOLATION_EXECUTABLE_BIT)
> +#define EPT_VIOLATION_GLA_VALID		(1 << EPT_VIOLATION_GLA_VALID_BIT)
>   #define EPT_VIOLATION_GVA_TRANSLATED	(1 << EPT_VIOLATION_GVA_TRANSLATED_BIT)
>   
>   /*
> diff --git a/arch/x86/kvm/mmu.c b/arch/x86/kvm/mmu.c
> index c4deb1f34faa..55fcb0292724 100644
> --- a/arch/x86/kvm/mmu.c
> +++ b/arch/x86/kvm/mmu.c
> @@ -5530,3 +5530,13 @@ void kvm_mmu_module_exit(void)
>   	unregister_shrinker(&mmu_shrinker);
>   	mmu_audit_disable();
>   }
> +
> +u64 kvm_mmu_fault_gla(struct kvm_vcpu *vcpu)
> +{
> +	return kvm_x86_ops->fault_gla(vcpu);
> +}
> +
> +bool kvm_mmu_nested_guest_page_fault(struct kvm_vcpu *vcpu)
> +{
> +	return !!(vcpu->arch.error_code & PFERR_GUEST_PAGE_MASK);
> +}
> diff --git a/arch/x86/kvm/svm.c b/arch/x86/kvm/svm.c
> index 5f7482851223..f41e4d7008d7 100644
> --- a/arch/x86/kvm/svm.c
> +++ b/arch/x86/kvm/svm.c
> @@ -2145,6 +2145,8 @@ static int pf_interception(struct vcpu_svm *svm)
>   	u64 fault_address = svm->vmcb->control.exit_info_2;
>   	u64 error_code = svm->vmcb->control.exit_info_1;
>   
> +	svm->vcpu.arch.error_code = error_code;
> +
>   	return kvm_handle_page_fault(&svm->vcpu, error_code, fault_address,
>   			svm->vmcb->control.insn_bytes,
>   			svm->vmcb->control.insn_len);
> @@ -5514,6 +5516,11 @@ static void svm_msr_intercept(struct kvm_vcpu *vcpu, unsigned int msr,
>   	set_msr_interception(msrpm, msr, enable, enable);
>   }
>   
> +static u64 svm_fault_gla(struct kvm_vcpu *vcpu)
> +{
> +	return ~0ull;
> +}
> +
>   static struct kvm_x86_ops svm_x86_ops __ro_after_init = {
>   	.cpu_has_kvm_support = has_svm,
>   	.disabled_by_bios = is_disabled,
> @@ -5631,6 +5638,7 @@ static struct kvm_x86_ops svm_x86_ops __ro_after_init = {
>   	.enable_smi_window = enable_smi_window,
>   
>   	.msr_intercept = svm_msr_intercept,
> +	.fault_gla = svm_fault_gla

Minor nit, it seems like this line should probably end with a "," so 
that future additions don't need to modify this line.

>   };
>   
>   static int __init svm_init(void)
> diff --git a/arch/x86/kvm/vmx.c b/arch/x86/kvm/vmx.c
> index 9c984bbe263e..5487e0242030 100644
> --- a/arch/x86/kvm/vmx.c
> +++ b/arch/x86/kvm/vmx.c
> @@ -6541,6 +6541,7 @@ static int handle_ept_violation(struct kvm_vcpu *vcpu)
>   	       PFERR_GUEST_FINAL_MASK : PFERR_GUEST_PAGE_MASK;
>   
>   	vcpu->arch.exit_qualification = exit_qualification;
> +	vcpu->arch.error_code = error_code;
>   	return kvm_mmu_page_fault(vcpu, gpa, error_code, NULL, 0);
>   }
>   
> @@ -12120,6 +12121,13 @@ static void vmx_msr_intercept(struct kvm_vcpu *vcpu, unsigned int msr,
>   	}
>   }
>   
> +static u64 vmx_fault_gla(struct kvm_vcpu *vcpu)
> +{
> +	if (vcpu->arch.exit_qualification & EPT_VIOLATION_GLA_VALID)
> +		return vmcs_readl(GUEST_LINEAR_ADDRESS);
> +	return ~0ul;

Should this not be "return ~0ull" (like in svm_fault_gla())?

> +}
> +
>   static struct kvm_x86_ops vmx_x86_ops __ro_after_init = {
>   	.cpu_has_kvm_support = cpu_has_kvm_support,
>   	.disabled_by_bios = vmx_disabled_by_bios,
> @@ -12252,6 +12260,7 @@ static struct kvm_x86_ops vmx_x86_ops __ro_after_init = {
>   	.enable_smi_window = enable_smi_window,
>   
>   	.msr_intercept = vmx_msr_intercept,
> +	.fault_gla = vmx_fault_gla

Same deal here with the trailing ","

>   };
>   
>   static int __init vmx_init(void)
> 


Patrick

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
