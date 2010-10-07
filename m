Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 002E56B004A
	for <linux-mm@kvack.org>; Thu,  7 Oct 2010 08:45:15 -0400 (EDT)
Message-ID: <4CADC01E.3060409@redhat.com>
Date: Thu, 07 Oct 2010 14:42:06 +0200
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH v6 06/12] Add PV MSR to enable asynchronous page faults
 delivery.
References: <1286207794-16120-1-git-send-email-gleb@redhat.com> <1286207794-16120-7-git-send-email-gleb@redhat.com>
In-Reply-To: <1286207794-16120-7-git-send-email-gleb@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Gleb Natapov <gleb@redhat.com>
Cc: kvm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mingo@elte.hu, a.p.zijlstra@chello.nl, tglx@linutronix.de, hpa@zytor.com, riel@redhat.com, cl@linux-foundation.org, mtosatti@redhat.com
List-ID: <linux-mm.kvack.org>

  On 10/04/2010 05:56 PM, Gleb Natapov wrote:
> Guest enables async PF vcpu functionality using this MSR.
>
>   			return NON_PRESENT;
> +
> +MSR_KVM_ASYNC_PF_EN: 0x4b564d02
> +	data: Bits 63-6 hold 64-byte aligned physical address of a 32bit memory

Given that it must be aligned anyway, we can require it to be a 64-byte 
region and also require that the guest zero it before writing the MSR.  
That will give us a little more flexibility in the future.

> +	area which must be in guest RAM. Bits 5-1 are reserved and should be
> +	zero. Bit 0 is 1 when asynchronous page faults are enabled on the vcpu
> +	0 when disabled.
> +
> +	Physical address points to 32 bit memory location that will be written
> +	to by the hypervisor at the time of asynchronous page fault injection to
> +	indicate type of asynchronous page fault. Value of 1 means that the page
> +	referred to by the page fault is not present. Value 2 means that the
> +	page is now available.
> diff --git a/arch/x86/include/asm/kvm_host.h b/arch/x86/include/asm/kvm_host.h
> index b9f263e..de31551 100644
> --- a/arch/x86/include/asm/kvm_host.h
> +++ b/arch/x86/include/asm/kvm_host.h
> @@ -417,6 +417,8 @@ struct kvm_vcpu_arch {
>
>   	struct {
>   		gfn_t gfns[roundup_pow_of_two(ASYNC_PF_PER_VCPU)];
> +		struct gfn_to_hva_cache data;
> +		u64 msr_val;
>   	} apf;
>   };
>
> diff --git a/arch/x86/include/asm/kvm_para.h b/arch/x86/include/asm/kvm_para.h
> index e3faaaf..8662ae0 100644
> --- a/arch/x86/include/asm/kvm_para.h
> +++ b/arch/x86/include/asm/kvm_para.h
> @@ -20,6 +20,7 @@
>    * are available. The use of 0x11 and 0x12 is deprecated
>    */
>   #define KVM_FEATURE_CLOCKSOURCE2        3
> +#define KVM_FEATURE_ASYNC_PF		4
>
>   /* The last 8 bits are used to indicate how to interpret the flags field
>    * in pvclock structure. If no bits are set, all flags are ignored.
> @@ -32,9 +33,12 @@
>   /* Custom MSRs falls in the range 0x4b564d00-0x4b564dff */
>   #define MSR_KVM_WALL_CLOCK_NEW  0x4b564d00
>   #define MSR_KVM_SYSTEM_TIME_NEW 0x4b564d01
> +#define MSR_KVM_ASYNC_PF_EN 0x4b564d02
>
>   #define KVM_MAX_MMU_OP_BATCH           32
>
> +#define KVM_ASYNC_PF_ENABLED			(1<<  0)
> +
>   /* Operations for KVM_HC_MMU_OP */
>   #define KVM_MMU_OP_WRITE_PTE            1
>   #define KVM_MMU_OP_FLUSH_TLB	        2
> diff --git a/arch/x86/kvm/x86.c b/arch/x86/kvm/x86.c
> index 48fd59d..3e123ab 100644
> --- a/arch/x86/kvm/x86.c
> +++ b/arch/x86/kvm/x86.c
> @@ -782,12 +782,12 @@ EXPORT_SYMBOL_GPL(kvm_get_dr);
>    * kvm-specific. Those are put in the beginning of the list.
>    */
>
> -#define KVM_SAVE_MSRS_BEGIN	7
> +#define KVM_SAVE_MSRS_BEGIN	8
>   static u32 msrs_to_save[] = {
>   	MSR_KVM_SYSTEM_TIME, MSR_KVM_WALL_CLOCK,
>   	MSR_KVM_SYSTEM_TIME_NEW, MSR_KVM_WALL_CLOCK_NEW,
>   	HV_X64_MSR_GUEST_OS_ID, HV_X64_MSR_HYPERCALL,
> -	HV_X64_MSR_APIC_ASSIST_PAGE,
> +	HV_X64_MSR_APIC_ASSIST_PAGE, MSR_KVM_ASYNC_PF_EN,
>   	MSR_IA32_SYSENTER_CS, MSR_IA32_SYSENTER_ESP, MSR_IA32_SYSENTER_EIP,
>   	MSR_STAR,
>   #ifdef CONFIG_X86_64
> @@ -1425,6 +1425,29 @@ static int set_msr_hyperv(struct kvm_vcpu *vcpu, u32 msr, u64 data)
>   	return 0;
>   }
>
> +static int kvm_pv_enable_async_pf(struct kvm_vcpu *vcpu, u64 data)
> +{
> +	gpa_t gpa = data&  ~0x3f;
> +
> +	/* Bits 1:5 are resrved, Should be zero */
> +	if (data&  0x3e)
> +		return 1;
> +
> +	vcpu->arch.apf.msr_val = data;
> +
> +	if (!(data&  KVM_ASYNC_PF_ENABLED)) {
> +		kvm_clear_async_pf_completion_queue(vcpu);

May be a lengthy synchronous operation.  I guess we don't care.

> +		memset(vcpu->arch.apf.gfns, 0xff, sizeof vcpu->arch.apf.gfns);

That memset again.

> +		return 0;
> +	}
> +
> +	if (kvm_gfn_to_hva_cache_init(vcpu->kvm,&vcpu->arch.apf.data, gpa))
> +		return 1;

Note: we need to handle the memory being removed from underneath 
kvm_gfn_to_hve_cache().  Given that, we can just make 
kvm_gfn_to_hva_cache_init() return void.  "success" means nothing when 
future changes can invalidate it.

> +
> +	kvm_async_pf_wakeup_all(vcpu);

Why is this needed?  If all apfs are flushed at disable time, what do we 
need to wake up?

Need to list the MSR for save/restore/reset.


-- 
I have a truly marvellous patch that fixes the bug which this
signature is too narrow to contain.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
