Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 395AF6B0044
	for <linux-mm@kvack.org>; Wed, 25 Nov 2009 07:32:54 -0500 (EST)
Message-ID: <4B0D23E8.3060508@redhat.com>
Date: Wed, 25 Nov 2009 14:32:40 +0200
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 02/12] Add PV MSR to enable asynchronous page faults
 delivery.
References: <1258985167-29178-1-git-send-email-gleb@redhat.com> <1258985167-29178-3-git-send-email-gleb@redhat.com>
In-Reply-To: <1258985167-29178-3-git-send-email-gleb@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Gleb Natapov <gleb@redhat.com>
Cc: kvm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mingo@elte.hu, a.p.zijlstra@chello.nl, tglx@linutronix.de, hpa@zytor.com, riel@redhat.com
List-ID: <linux-mm.kvack.org>

On 11/23/2009 04:05 PM, Gleb Natapov wrote:
> Signed-off-by: Gleb Natapov<gleb@redhat.com>
> ---
>   arch/x86/include/asm/kvm_host.h |    3 ++
>   arch/x86/include/asm/kvm_para.h |    2 +
>   arch/x86/kvm/x86.c              |   42 +++++++++++++++++++++++++++++++++++++-
>   include/linux/kvm.h             |    1 +
>   4 files changed, 46 insertions(+), 2 deletions(-)
>
>   #define MSR_KVM_WALL_CLOCK  0x11
>   #define MSR_KVM_SYSTEM_TIME 0x12
> +#define MSR_KVM_ASYNC_PF_EN 0x13
>    

Please use MSRs from the range 0x4b564dxx.  The numbers below are 
reserved by Intel (and in fact used by the old Pentiums).

Need documentation for the new MSR, say in Documentation/kvm/msr.txt.

> +static int kvm_pv_enable_async_pf(struct kvm_vcpu *vcpu, u64 data)
> +{
> +	u64 gpa = data&  ~0x3f;
> +	int offset = offset_in_page(gpa);
> +	unsigned long addr;
> +
> +	addr = gfn_to_hva(vcpu->kvm, gpa>>  PAGE_SHIFT);
> +	if (kvm_is_error_hva(addr))
> +		return 1;
> +
> +	vcpu->arch.apf_data = (u32 __user*)(addr + offset);
> +
> +	/* check if address is mapped */
> +	if (get_user(offset, vcpu->arch.apf_data)) {
> +		vcpu->arch.apf_data = NULL;
> +		return 1;
> +	}
>    

What if the memory slot arrangement changes?  This needs to be 
revalidated (and gfn_to_hva() called again).

> +	return 0;
> +}
> +
>   int kvm_set_msr_common(struct kvm_vcpu *vcpu, u32 msr, u64 data)
>   {
>   	switch (msr) {
> @@ -1029,6 +1049,14 @@ int kvm_set_msr_common(struct kvm_vcpu *vcpu, u32 msr, u64 data)
>   		kvm_request_guest_time_update(vcpu);
>   		break;
>   	}
> +	case MSR_KVM_ASYNC_PF_EN:
> +		vcpu->arch.apf_msr_val = data;
> +		if (data&  1) {
> +			if (kvm_pv_enable_async_pf(vcpu, data))
> +				return 1;
>    

Need to check before setting the msr value, so subsequent reads return 
the old value.

> +		} else
> +			vcpu->arch.apf_data = NULL;
>    

Need to check that bits 1:5 are zero.  I think it's cleaner to move all 
of the code to kvm_pv_enable_async_pf(), to have everything in one place.


-- 
error compiling committee.c: too many arguments to function

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
