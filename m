Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 71A346B0044
	for <linux-mm@kvack.org>; Wed, 25 Nov 2009 08:04:04 -0500 (EST)
Message-ID: <4B0D2B22.4030403@redhat.com>
Date: Wed, 25 Nov 2009 15:03:30 +0200
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 08/12] Inject asynchronous page fault into a guest
 if page is swapped out.
References: <1258985167-29178-1-git-send-email-gleb@redhat.com> <1258985167-29178-9-git-send-email-gleb@redhat.com>
In-Reply-To: <1258985167-29178-9-git-send-email-gleb@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Gleb Natapov <gleb@redhat.com>
Cc: kvm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mingo@elte.hu, a.p.zijlstra@chello.nl, tglx@linutronix.de, hpa@zytor.com, riel@redhat.com
List-ID: <linux-mm.kvack.org>

On 11/23/2009 04:06 PM, Gleb Natapov wrote:
> If guest access swapped out memory do not swap it in from vcpu thread
> context. Setup slow work to do swapping and send async page fault to
> a guest.
>
> Allow async page fault injection only when guest is in user mode since
> otherwise guest may be in non-sleepable context and will not be able to
> reschedule.
>
> +
> +void kvm_arch_inject_async_page_present(struct kvm_vcpu *vcpu,
> +					struct kvm_async_pf *work)
> +{
> +	put_user(KVM_PV_REASON_PAGE_READY, vcpu->arch.apf_data);
> +	kvm_inject_page_fault(vcpu, work->arch.token, 0);
> +	trace_kvm_send_async_pf(work->arch.token, work->gva,
> +				KVM_PV_REASON_PAGE_READY);
> +}
>    

What if the guest is now handling a previous asynv pf or ready 
notification?  We're clobbering the data structure.

> +
> +bool kvm_arch_can_inject_async_page_present(struct kvm_vcpu *vcpu)
> +{
> +	return !kvm_event_needs_reinjection(vcpu)&&
> +		kvm_x86_ops->interrupt_allowed(vcpu);
> +}
>    

Okay, so this is only allowed with interrupts disabled.  Need to make 
sure the entire pf path up to async pf executes with interrupts disabled.

-- 
error compiling committee.c: too many arguments to function

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
