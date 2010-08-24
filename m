Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 7B7536B01F0
	for <linux-mm@kvack.org>; Tue, 24 Aug 2010 05:39:03 -0400 (EDT)
Message-ID: <4C73932A.3030709@redhat.com>
Date: Tue, 24 Aug 2010 12:38:50 +0300
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH v5 09/12] Retry fault before vmentry
References: <1279553462-7036-1-git-send-email-gleb@redhat.com> <1279553462-7036-10-git-send-email-gleb@redhat.com> <4C73900D.1080404@redhat.com> <20100824093356.GY10499@redhat.com>
In-Reply-To: <20100824093356.GY10499@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Gleb Natapov <gleb@redhat.com>
Cc: kvm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mingo@elte.hu, a.p.zijlstra@chello.nl, tglx@linutronix.de, hpa@zytor.com, riel@redhat.com, cl@linux-foundation.org, mtosatti@redhat.com
List-ID: <linux-mm.kvack.org>

  On 08/24/2010 12:33 PM, Gleb Natapov wrote:
>
>
>>> @@ -505,6 +506,37 @@ out_unlock:
>>>   	return 0;
>>>   }
>>>
>>> +static int FNAME(page_fault_other_cr3)(struct kvm_vcpu *vcpu, gpa_t cr3,
>>> +				       gva_t addr, u32 error_code)
>>> +{
>>> +	int r = 0;
>>> +	gpa_t curr_cr3 = vcpu->arch.cr3;
>>> +
>>> +	if (curr_cr3 != cr3) {
>>> +		/*
>>> +		 * We do page fault on behalf of a process that is sleeping
>>> +		 * because of async PF. PV guest takes reference to mm that cr3
>>> +		 * belongs too, so it has to be valid here.
>>> +		 */
>>> +		kvm_set_cr3(vcpu, cr3);
>>> +		if (kvm_mmu_reload(vcpu))
>>> +			goto switch_cr3;
>>> +	}
>> With nested virtualization, we need to switch cr0, cr4, and efer as well...
>>
> On SVM or VMX or both?

Both.  Let's defer this patch since it's an optimization, this is really 
complicated.

>>> +
>>> +	r = FNAME(page_fault)(vcpu, addr, error_code, true);
>>> +
>>> +	if (kvm_check_request(KVM_REQ_MMU_SYNC, vcpu))
>>> +		kvm_mmu_sync_roots(vcpu);
>> Why is this needed?
>>
> http://www.mail-archive.com/kvm@vger.kernel.org/msg37827.html
>
>   KVM_REQ_MMU_SYNC request generated here must be processed before
>   switching to a different cr3 (otherwise vcpu_enter_guest will process it
>   with the wrong cr3 in place).

Ah, it should be part of the cr3 switch block above.

>>> +
>>> +switch_cr3:
>>> +	if (curr_cr3 != vcpu->arch.cr3) {
>>> +		kvm_set_cr3(vcpu, curr_cr3);
>>> +		kvm_mmu_reload(vcpu);
>>> +	}
>>> +
>>> +	return r;
>>> +}
>> This has the nasty effect of flushing the TLB on AMD.
>>
> What is more expansive reenter the guest and handle one more fault, or
> flash TLB here?

No idea.  Probably the reentry.  On Intel the tlb is flushed anyway.

-- 
error compiling committee.c: too many arguments to function

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
