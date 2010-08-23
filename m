Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 11C1D6007E9
	for <linux-mm@kvack.org>; Mon, 23 Aug 2010 11:22:19 -0400 (EDT)
Message-ID: <4C72921A.8000308@redhat.com>
Date: Mon, 23 Aug 2010 18:22:02 +0300
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH v5 02/12] Add PV MSR to enable asynchronous page faults
 delivery.
References: <1279553462-7036-1-git-send-email-gleb@redhat.com> <1279553462-7036-3-git-send-email-gleb@redhat.com>
In-Reply-To: <1279553462-7036-3-git-send-email-gleb@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Gleb Natapov <gleb@redhat.com>
Cc: kvm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mingo@elte.hu, a.p.zijlstra@chello.nl, tglx@linutronix.de, hpa@zytor.com, riel@redhat.com, cl@linux-foundation.org, mtosatti@redhat.com
List-ID: <linux-mm.kvack.org>

  On 07/19/2010 06:30 PM, Gleb Natapov wrote:
> Guess enables async PF vcpu functionality using this MSR.
>
>
>
> +static int kvm_pv_enable_async_pf(struct kvm_vcpu *vcpu, u64 data)
> +{
> +	u64 gpa = data&  ~0x3f;
> +	int offset = offset_in_page(gpa);
> +	unsigned long addr;
> +
> +	/* Bits 1:5 are resrved, Should be zero */
> +	if (data&  0x3e)
> +		return 1;
> +
> +	vcpu->arch.apf_msr_val = data;
> +
> +	if (!(data&  KVM_ASYNC_PF_ENABLED)) {
> +		vcpu->arch.apf_data = NULL;
> +		return 0;
> +	}
> +
> +	addr = gfn_to_hva(vcpu->kvm, gpa>>  PAGE_SHIFT);
> +	if (kvm_is_error_hva(addr))
> +		return 1;
> +
> +	vcpu->arch.apf_data = (u32 __user*)(addr + offset);

This can be invalidated by host userspace playing with memory regions.  
It needs to be recalculated on memory map changes, and it may disappear 
from under the guest's feet (in which case we're allowed to 
KVM_REQ_TRIPLE_FAULT it).

(note: this is a much better approach than kvmclock's and vapic's, we 
should copy it there)

> +
> +	/* check if address is mapped */
> +	if (get_user(offset, vcpu->arch.apf_data)) {
> +		vcpu->arch.apf_data = NULL;
> +		return 1;
> +	}

So, this check can succeed today but fail tomorrow.

> +	return 0;
> +}
> +

-- 
error compiling committee.c: too many arguments to function

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
