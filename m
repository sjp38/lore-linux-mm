Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 38A496B006A
	for <linux-mm@kvack.org>; Thu,  7 Oct 2010 05:50:29 -0400 (EDT)
Message-ID: <4CAD97D0.70100@redhat.com>
Date: Thu, 07 Oct 2010 11:50:08 +0200
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH v6 02/12] Halt vcpu if page it tries to access is swapped
 out.
References: <1286207794-16120-1-git-send-email-gleb@redhat.com> <1286207794-16120-3-git-send-email-gleb@redhat.com>
In-Reply-To: <1286207794-16120-3-git-send-email-gleb@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Gleb Natapov <gleb@redhat.com>
Cc: kvm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mingo@elte.hu, a.p.zijlstra@chello.nl, tglx@linutronix.de, hpa@zytor.com, riel@redhat.com, cl@linux-foundation.org, mtosatti@redhat.com
List-ID: <linux-mm.kvack.org>

  On 10/04/2010 05:56 PM, Gleb Natapov wrote:
> If a guest accesses swapped out memory do not swap it in from vcpu thread
> context. Schedule work to do swapping and put vcpu into halted state
> instead.
>
> Interrupts will still be delivered to the guest and if interrupt will
> cause reschedule guest will continue to run another task.
>
>
> +
> +static bool can_do_async_pf(struct kvm_vcpu *vcpu)
> +{
> +	if (unlikely(!irqchip_in_kernel(vcpu->kvm) ||
> +		     kvm_event_needs_reinjection(vcpu)))
> +		return false;
> +
> +	return kvm_x86_ops->interrupt_allowed(vcpu);
> +}

Strictly speaking, if the cpu can handle NMIs it can take an apf?

> @@ -5112,6 +5122,13 @@ static int vcpu_enter_guest(struct kvm_vcpu *vcpu)
>   	if (unlikely(r))
>   		goto out;
>
> +	kvm_check_async_pf_completion(vcpu);
> +	if (vcpu->arch.mp_state == KVM_MP_STATE_HALTED) {
> +		/* Page is swapped out. Do synthetic halt */
> +		r = 1;
> +		goto out;
> +	}
> +

Why do it here in the fast path?  Can't you halt the cpu when starting 
the page fault?

I guess the apf threads can't touch mp_state, but they can have a 
KVM_REQ to trigger the check.

>   	if (kvm_check_request(KVM_REQ_EVENT, vcpu) || req_int_win) {
>   		inject_pending_event(vcpu);
>
> @@ -5781,6 +5798,9 @@ int kvm_arch_vcpu_reset(struct kvm_vcpu *vcpu)
>
>   	kvm_make_request(KVM_REQ_EVENT, vcpu);
>
> +	kvm_clear_async_pf_completion_queue(vcpu);
> +	memset(vcpu->arch.apf.gfns, 0xff, sizeof vcpu->arch.apf.gfns);

An ordinary for loop is less tricky, even if it means one more line.

>
> @@ -6040,6 +6064,7 @@ void kvm_arch_flush_shadow(struct kvm *kvm)
>   int kvm_arch_vcpu_runnable(struct kvm_vcpu *vcpu)
>   {
>   	return vcpu->arch.mp_state == KVM_MP_STATE_RUNNABLE
> +		|| !list_empty_careful(&vcpu->async_pf.done)
>   		|| vcpu->arch.mp_state == KVM_MP_STATE_SIPI_RECEIVED
>   		|| vcpu->arch.nmi_pending ||
>   		(kvm_arch_interrupt_allowed(vcpu)&&

Unrelated, shouldn't kvm_arch_vcpu_runnable() look at vcpu->requests?  
Specifically KVM_REQ_EVENT?

> +static void kvm_add_async_pf_gfn(struct kvm_vcpu *vcpu, gfn_t gfn)
> +{
> +	u32 key = kvm_async_pf_hash_fn(gfn);
> +
> +	while (vcpu->arch.apf.gfns[key] != -1)
> +		key = kvm_async_pf_next_probe(key);

Not sure what that -1 converts to on i386 where gfn_t is u64.
> +
> +void kvm_arch_async_page_not_present(struct kvm_vcpu *vcpu,
> +				     struct kvm_async_pf *work)
> +{
> +	vcpu->arch.mp_state = KVM_MP_STATE_HALTED;
> +
> +	if (work == kvm_double_apf)
> +		trace_kvm_async_pf_doublefault(kvm_rip_read(vcpu));
> +	else {
> +		trace_kvm_async_pf_not_present(work->gva);
> +
> +		kvm_add_async_pf_gfn(vcpu, work->arch.gfn);
> +	}
> +}

Just have vcpu as the argument for tracepoints to avoid unconditional 
kvm_rip_read (slow on Intel), and call kvm_rip_read() in 
tp_fast_assign().  Similarly you can pass work instead of work->gva, 
though that's not nearly as important.

> +
> +TRACE_EVENT(
> +	kvm_async_pf_not_present,
> +	TP_PROTO(u64 gva),
> +	TP_ARGS(gva),

Do you actually have a gva with tdp?  With nested virtualization, how do 
you interpret this gva?
> +
> +TRACE_EVENT(
> +	kvm_async_pf_completed,
> +	TP_PROTO(unsigned long address, struct page *page, u64 gva),
> +	TP_ARGS(address, page, gva),

What does address mean?  There's also gva?

> +
> +	TP_STRUCT__entry(
> +		__field(unsigned long, address)
> +		__field(struct page*, page)
> +		__field(u64, gva)
> +		),
> +
> +	TP_fast_assign(
> +		__entry->address = address;
> +		__entry->page = page;
> +		__entry->gva = gva;
> +		),

Recording a struct page * in a tracepoint?  Userspace can read this 
entry, better to the page_to_pfn() here.


> +void kvm_clear_async_pf_completion_queue(struct kvm_vcpu *vcpu)
> +{
> +	/* cancel outstanding work queue item */
> +	while (!list_empty(&vcpu->async_pf.queue)) {
> +		struct kvm_async_pf *work =
> +			list_entry(vcpu->async_pf.queue.next,
> +				   typeof(*work), queue);
> +		cancel_work_sync(&work->work);
> +		list_del(&work->queue);
> +		if (!work->page) /* work was canceled */
> +			kmem_cache_free(async_pf_cache, work);
> +	}

Are you holding any lock here?

If not, what protects vcpu->async_pf.queue?
If yes, cancel_work_sync() will need to aquire it too (in case work is 
running now and needs to take the lock, and cacncel_work_sync() needs to 
wait for it) -> deadlock.

> +
> +	/* do alloc nowait since if we are going to sleep anyway we
> +	   may as well sleep faulting in page */
/*
  * multi
  * line
  * comment
  */

(but a good one, this is subtle)

I missed where you halt the vcpu.  Can you point me at the function?

Note this is a synthetic halt and must not be visible to live migration, 
or we risk live migrating a halted state which doesn't really exist.

Might be simplest to drain the apf queue on any of the save/restore ioctls.

-- 
I have a truly marvellous patch that fixes the bug which this
signature is too narrow to contain.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
