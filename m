Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 57F616B006A
	for <linux-mm@kvack.org>; Sun, 10 Oct 2010 11:55:45 -0400 (EDT)
Message-ID: <4CB1E1ED.6050405@redhat.com>
Date: Sun, 10 Oct 2010 17:55:25 +0200
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH v6 02/12] Halt vcpu if page it tries to access is swapped
 out.
References: <1286207794-16120-1-git-send-email-gleb@redhat.com> <1286207794-16120-3-git-send-email-gleb@redhat.com> <4CAD97D0.70100@redhat.com> <20101007174716.GD2397@redhat.com> <4CB0B4BA.5010901@redhat.com> <20101010072946.GJ2397@redhat.com>
In-Reply-To: <20101010072946.GJ2397@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Gleb Natapov <gleb@redhat.com>
Cc: kvm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mingo@elte.hu, a.p.zijlstra@chello.nl, tglx@linutronix.de, hpa@zytor.com, riel@redhat.com, cl@linux-foundation.org, mtosatti@redhat.com
List-ID: <linux-mm.kvack.org>

  On 10/10/2010 09:29 AM, Gleb Natapov wrote:
> On Sat, Oct 09, 2010 at 08:30:18PM +0200, Avi Kivity wrote:
> >   On 10/07/2010 07:47 PM, Gleb Natapov wrote:
> >  >On Thu, Oct 07, 2010 at 11:50:08AM +0200, Avi Kivity wrote:
> >  >>    On 10/04/2010 05:56 PM, Gleb Natapov wrote:
> >  >>   >If a guest accesses swapped out memory do not swap it in from vcpu thread
> >  >>   >context. Schedule work to do swapping and put vcpu into halted state
> >  >>   >instead.
> >  >>   >
> >  >>   >Interrupts will still be delivered to the guest and if interrupt will
> >  >>   >cause reschedule guest will continue to run another task.
> >  >>   >
> >  >>   >
> >  >>   >+
> >  >>   >+static bool can_do_async_pf(struct kvm_vcpu *vcpu)
> >  >>   >+{
> >  >>   >+	if (unlikely(!irqchip_in_kernel(vcpu->kvm) ||
> >  >>   >+		     kvm_event_needs_reinjection(vcpu)))
> >  >>   >+		return false;
> >  >>   >+
> >  >>   >+	return kvm_x86_ops->interrupt_allowed(vcpu);
> >  >>   >+}
> >  >>
> >  >>   Strictly speaking, if the cpu can handle NMIs it can take an apf?
> >  >>
> >  >We can always do apf, but if vcpu can't do anything hwy bother. For NMI
> >  >watchdog yes, may be it is worth to allow apf if nmi is allowed.
> >
> >  Actually it's very dangerous - the IRET from APF will re-enable
> >  NMIs.  So without the guest enabling apf-in-nmi we shouldn't allow
> >  it.
> >
> Good point.
>
> >  Not worth the complexity IMO.
> >
> >  >>   >@@ -5112,6 +5122,13 @@ static int vcpu_enter_guest(struct kvm_vcpu *vcpu)
> >  >>   >    	if (unlikely(r))
> >  >>   >    		goto out;
> >  >>   >
> >  >>   >+	kvm_check_async_pf_completion(vcpu);
> >  >>   >+	if (vcpu->arch.mp_state == KVM_MP_STATE_HALTED) {
> >  >>   >+		/* Page is swapped out. Do synthetic halt */
> >  >>   >+		r = 1;
> >  >>   >+		goto out;
> >  >>   >+	}
> >  >>   >+
> >  >>
> >  >>   Why do it here in the fast path?  Can't you halt the cpu when
> >  >>   starting the page fault?
> >  >Page fault may complete before guest re-entry. We do not want to halt vcpu
> >  >in this case.
> >
> >  So unhalt on completion.
> >
> I want to avoid touching vcpu state from work if possible. Work code does
> not contain arch dependent code right now and mp_state is x86 thing
>

Use a KVM_REQ.


> >  >>
> >  >>   I guess the apf threads can't touch mp_state, but they can have a
> >  >>   KVM_REQ to trigger the check.
> >  >This will require KVM_REQ check on fast path, so what's the difference
> >  >performance wise.
> >
> >  We already have a KVM_REQ check (if (vcpu->requests)) so it doesn't
> >  cost anything extra.
> if (vcpu->requests) does not clear req bit, so what will have to be added
> is: if (kvm_check_request(KVM_REQ_APF_HLT, vcpu)) which is even more
> expensive then my check (but not so expensive to worry about).

It's only expensive when it happens.  Most entries will have the bit clear.

> >
> >  >>   >
> >  >>   >@@ -6040,6 +6064,7 @@ void kvm_arch_flush_shadow(struct kvm *kvm)
> >  >>   >    int kvm_arch_vcpu_runnable(struct kvm_vcpu *vcpu)
> >  >>   >    {
> >  >>   >    	return vcpu->arch.mp_state == KVM_MP_STATE_RUNNABLE
> >  >>   >+		|| !list_empty_careful(&vcpu->async_pf.done)
> >  >>   >    		|| vcpu->arch.mp_state == KVM_MP_STATE_SIPI_RECEIVED
> >  >>   >    		|| vcpu->arch.nmi_pending ||
> >  >>   >    		(kvm_arch_interrupt_allowed(vcpu)&&
> >  >>
> >  >>   Unrelated, shouldn't kvm_arch_vcpu_runnable() look at
> >  >>   vcpu->requests?  Specifically KVM_REQ_EVENT?
> >  >I think KVM_REQ_EVENT is covered by checking nmi and interrupt queue
> >  >here.
> >
> >  No, the nmi and interrupt queues are only filled when the lapic is
> >  polled via KVM_REQ_EVENT.  I'll prepare a patch.
> I don't think you are correct. nmi_pending is filled before setting
> KVM_REQ_EVENT and kvm_cpu_has_interrupt() checks directly in apic/pic.

Right.

> >
> >  >>   >+
> >  >>   >+TRACE_EVENT(
> >  >>   >+	kvm_async_pf_not_present,
> >  >>   >+	TP_PROTO(u64 gva),
> >  >>   >+	TP_ARGS(gva),
> >  >>
> >  >>   Do you actually have a gva with tdp?  With nested virtualization,
> >  >>   how do you interpret this gva?
> >  >With tdp it is gpa just like tdp_page_fault gets gpa where shadow page
> >  >version gets gva. Nested virtualization is too complex to interpret.
> >
> >  It's not good to have a tracepoint that depends on cpu mode (without
> >  recording that mode). I think we have the same issue in
> >  trace_kvm_page_fault though.
> We have mmu_is_nested(). I'll just disable apf while vcpu is in nested
> mode for now.

What if we get the apf in non-nested mode and it completes in nested mode?

> >
> >  >>   >+
> >  >>   >+	/* do alloc nowait since if we are going to sleep anyway we
> >  >>   >+	   may as well sleep faulting in page */
> >  >>   /*
> >  >>    * multi
> >  >>    * line
> >  >>    * comment
> >  >>    */
> >  >>
> >  >>   (but a good one, this is subtle)
> >  >>
> >  >>   I missed where you halt the vcpu.  Can you point me at the function?
> >  >>
> >  >>   Note this is a synthetic halt and must not be visible to live
> >  >>   migration, or we risk live migrating a halted state which doesn't
> >  >>   really exist.
> >  >>
> >  >>   Might be simplest to drain the apf queue on any of the save/restore ioctls.
> >  >>
> >  >So that "info cpu" will interfere with apf? Migration should work
> >  >in regular way. apf state should not be migrated since it has no meaning
> >  >on the destination. I'll make sure synthetic halt state will not
> >  >interfere with migration.
> >
> >  If you deliver an apf, the guest expects a completion.
> >
> There is special completion that tells guest to wake all sleeping tasks
> on vcpu. It is delivered after migration on the destination.
>

Yes, I saw.

What if you can't deliver it?  is it possible that some other vcpu will 
start receiving apfs that alias the old ones?  Or is the broadcast global?

-- 
error compiling committee.c: too many arguments to function

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
