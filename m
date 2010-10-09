Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id DBDF16B006A
	for <linux-mm@kvack.org>; Sat,  9 Oct 2010 14:30:39 -0400 (EDT)
Message-ID: <4CB0B4BA.5010901@redhat.com>
Date: Sat, 09 Oct 2010 20:30:18 +0200
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH v6 02/12] Halt vcpu if page it tries to access is swapped
 out.
References: <1286207794-16120-1-git-send-email-gleb@redhat.com> <1286207794-16120-3-git-send-email-gleb@redhat.com> <4CAD97D0.70100@redhat.com> <20101007174716.GD2397@redhat.com>
In-Reply-To: <20101007174716.GD2397@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Gleb Natapov <gleb@redhat.com>
Cc: kvm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mingo@elte.hu, a.p.zijlstra@chello.nl, tglx@linutronix.de, hpa@zytor.com, riel@redhat.com, cl@linux-foundation.org, mtosatti@redhat.com
List-ID: <linux-mm.kvack.org>

  On 10/07/2010 07:47 PM, Gleb Natapov wrote:
> On Thu, Oct 07, 2010 at 11:50:08AM +0200, Avi Kivity wrote:
> >   On 10/04/2010 05:56 PM, Gleb Natapov wrote:
> >  >If a guest accesses swapped out memory do not swap it in from vcpu thread
> >  >context. Schedule work to do swapping and put vcpu into halted state
> >  >instead.
> >  >
> >  >Interrupts will still be delivered to the guest and if interrupt will
> >  >cause reschedule guest will continue to run another task.
> >  >
> >  >
> >  >+
> >  >+static bool can_do_async_pf(struct kvm_vcpu *vcpu)
> >  >+{
> >  >+	if (unlikely(!irqchip_in_kernel(vcpu->kvm) ||
> >  >+		     kvm_event_needs_reinjection(vcpu)))
> >  >+		return false;
> >  >+
> >  >+	return kvm_x86_ops->interrupt_allowed(vcpu);
> >  >+}
> >
> >  Strictly speaking, if the cpu can handle NMIs it can take an apf?
> >
> We can always do apf, but if vcpu can't do anything hwy bother. For NMI
> watchdog yes, may be it is worth to allow apf if nmi is allowed.

Actually it's very dangerous - the IRET from APF will re-enable NMIs.  
So without the guest enabling apf-in-nmi we shouldn't allow it.

Not worth the complexity IMO.

> >  >@@ -5112,6 +5122,13 @@ static int vcpu_enter_guest(struct kvm_vcpu *vcpu)
> >  >   	if (unlikely(r))
> >  >   		goto out;
> >  >
> >  >+	kvm_check_async_pf_completion(vcpu);
> >  >+	if (vcpu->arch.mp_state == KVM_MP_STATE_HALTED) {
> >  >+		/* Page is swapped out. Do synthetic halt */
> >  >+		r = 1;
> >  >+		goto out;
> >  >+	}
> >  >+
> >
> >  Why do it here in the fast path?  Can't you halt the cpu when
> >  starting the page fault?
> Page fault may complete before guest re-entry. We do not want to halt vcpu
> in this case.

So unhalt on completion.

> >
> >  I guess the apf threads can't touch mp_state, but they can have a
> >  KVM_REQ to trigger the check.
> This will require KVM_REQ check on fast path, so what's the difference
> performance wise.

We already have a KVM_REQ check (if (vcpu->requests)) so it doesn't cost 
anything extra.

> >  >
> >  >@@ -6040,6 +6064,7 @@ void kvm_arch_flush_shadow(struct kvm *kvm)
> >  >   int kvm_arch_vcpu_runnable(struct kvm_vcpu *vcpu)
> >  >   {
> >  >   	return vcpu->arch.mp_state == KVM_MP_STATE_RUNNABLE
> >  >+		|| !list_empty_careful(&vcpu->async_pf.done)
> >  >   		|| vcpu->arch.mp_state == KVM_MP_STATE_SIPI_RECEIVED
> >  >   		|| vcpu->arch.nmi_pending ||
> >  >   		(kvm_arch_interrupt_allowed(vcpu)&&
> >
> >  Unrelated, shouldn't kvm_arch_vcpu_runnable() look at
> >  vcpu->requests?  Specifically KVM_REQ_EVENT?
> I think KVM_REQ_EVENT is covered by checking nmi and interrupt queue
> here.

No, the nmi and interrupt queues are only filled when the lapic is 
polled via KVM_REQ_EVENT.  I'll prepare a patch.

> >  >+
> >  >+TRACE_EVENT(
> >  >+	kvm_async_pf_not_present,
> >  >+	TP_PROTO(u64 gva),
> >  >+	TP_ARGS(gva),
> >
> >  Do you actually have a gva with tdp?  With nested virtualization,
> >  how do you interpret this gva?
> With tdp it is gpa just like tdp_page_fault gets gpa where shadow page
> version gets gva. Nested virtualization is too complex to interpret.

It's not good to have a tracepoint that depends on cpu mode (without 
recording that mode). I think we have the same issue in 
trace_kvm_page_fault though.

> >  >+
> >  >+TRACE_EVENT(
> >  >+	kvm_async_pf_completed,
> >  >+	TP_PROTO(unsigned long address, struct page *page, u64 gva),
> >  >+	TP_ARGS(address, page, gva),
> >
> >  What does address mean?  There's also gva?
> >
> hva.

Is hva helpful here?  Generally gpa is better, but may not be available 
since it's ambiguous.

>
> >
> >  >+void kvm_clear_async_pf_completion_queue(struct kvm_vcpu *vcpu)
> >  >+{
> >  >+	/* cancel outstanding work queue item */
> >  >+	while (!list_empty(&vcpu->async_pf.queue)) {
> >  >+		struct kvm_async_pf *work =
> >  >+			list_entry(vcpu->async_pf.queue.next,
> >  >+				   typeof(*work), queue);
> >  >+		cancel_work_sync(&work->work);
> >  >+		list_del(&work->queue);
> >  >+		if (!work->page) /* work was canceled */
> >  >+			kmem_cache_free(async_pf_cache, work);
> >  >+	}
> >
> >  Are you holding any lock here?
> >
> >  If not, what protects vcpu->async_pf.queue?
> Nothing. It is accessed only from vcpu thread.
>
> >  If yes, cancel_work_sync() will need to aquire it too (in case work
> >  is running now and needs to take the lock, and cacncel_work_sync()
> >  needs to wait for it) ->  deadlock.
> >
> Work never touches this list.

So, an apf is always in ->queue and when completed also in ->done?

Is it not cleaner to list_move the apf from ->queue to ->done?  saves a 
->link.

Can be done later.

> >  >+
> >  >+	/* do alloc nowait since if we are going to sleep anyway we
> >  >+	   may as well sleep faulting in page */
> >  /*
> >   * multi
> >   * line
> >   * comment
> >   */
> >
> >  (but a good one, this is subtle)
> >
> >  I missed where you halt the vcpu.  Can you point me at the function?
> >
> >  Note this is a synthetic halt and must not be visible to live
> >  migration, or we risk live migrating a halted state which doesn't
> >  really exist.
> >
> >  Might be simplest to drain the apf queue on any of the save/restore ioctls.
> >
> So that "info cpu" will interfere with apf? Migration should work
> in regular way. apf state should not be migrated since it has no meaning
> on the destination. I'll make sure synthetic halt state will not
> interfere with migration.

If you deliver an apf, the guest expects a completion.

-- 
I have a truly marvellous patch that fixes the bug which this
signature is too narrow to contain.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
