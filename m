Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 12CBF6B006A
	for <linux-mm@kvack.org>; Sun, 10 Oct 2010 12:16:39 -0400 (EDT)
Date: Sun, 10 Oct 2010 18:16:19 +0200
From: Gleb Natapov <gleb@redhat.com>
Subject: Re: [PATCH v6 02/12] Halt vcpu if page it tries to access is
 swapped out.
Message-ID: <20101010161619.GS2397@redhat.com>
References: <1286207794-16120-1-git-send-email-gleb@redhat.com>
 <1286207794-16120-3-git-send-email-gleb@redhat.com>
 <4CAD97D0.70100@redhat.com>
 <20101007174716.GD2397@redhat.com>
 <4CB0B4BA.5010901@redhat.com>
 <20101010072946.GJ2397@redhat.com>
 <4CB1E1ED.6050405@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4CB1E1ED.6050405@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Avi Kivity <avi@redhat.com>
Cc: kvm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mingo@elte.hu, a.p.zijlstra@chello.nl, tglx@linutronix.de, hpa@zytor.com, riel@redhat.com, cl@linux-foundation.org, mtosatti@redhat.com
List-ID: <linux-mm.kvack.org>

On Sun, Oct 10, 2010 at 05:55:25PM +0200, Avi Kivity wrote:
> >>
> >>  >>   >@@ -5112,6 +5122,13 @@ static int vcpu_enter_guest(struct kvm_vcpu *vcpu)
> >>  >>   >    	if (unlikely(r))
> >>  >>   >    		goto out;
> >>  >>   >
> >>  >>   >+	kvm_check_async_pf_completion(vcpu);
> >>  >>   >+	if (vcpu->arch.mp_state == KVM_MP_STATE_HALTED) {
> >>  >>   >+		/* Page is swapped out. Do synthetic halt */
> >>  >>   >+		r = 1;
> >>  >>   >+		goto out;
> >>  >>   >+	}
> >>  >>   >+
> >>  >>
> >>  >>   Why do it here in the fast path?  Can't you halt the cpu when
> >>  >>   starting the page fault?
> >>  >Page fault may complete before guest re-entry. We do not want to halt vcpu
> >>  >in this case.
> >>
> >>  So unhalt on completion.
> >>
> >I want to avoid touching vcpu state from work if possible. Work code does
> >not contain arch dependent code right now and mp_state is x86 thing
> >
> 
> Use a KVM_REQ.
> 
Completion happens asynchronously. CPU may not be even halted at that
point. Actually completion does unhalt vcpu. It puts completed work into
vcpu->async_pf.done list and wakes vcpu thread if it sleeps. Next
invocation of kvm_arch_vcpu_runnable() will return true since vcpu->async_pf.done
is not empty and vcpu will be unhalted in usual way by kvm_vcpu_block().

> 
> >>  >>
> >>  >>   I guess the apf threads can't touch mp_state, but they can have a
> >>  >>   KVM_REQ to trigger the check.
> >>  >This will require KVM_REQ check on fast path, so what's the difference
> >>  >performance wise.
> >>
> >>  We already have a KVM_REQ check (if (vcpu->requests)) so it doesn't
> >>  cost anything extra.
> >if (vcpu->requests) does not clear req bit, so what will have to be added
> >is: if (kvm_check_request(KVM_REQ_APF_HLT, vcpu)) which is even more
> >expensive then my check (but not so expensive to worry about).
> 
> It's only expensive when it happens.  Most entries will have the bit clear.
kvm_check_async_pf_completion() (the one that detects if vcpu should be
halted) is called after vcpu->requests processing. It is done in order
to delay completion checking as far as possible in hope to get
completion before next vcpu entry and skip sending apf, so I do it at
the last possible moment before event injection.

> >>
> >>  >>   >+
> >>  >>   >+TRACE_EVENT(
> >>  >>   >+	kvm_async_pf_not_present,
> >>  >>   >+	TP_PROTO(u64 gva),
> >>  >>   >+	TP_ARGS(gva),
> >>  >>
> >>  >>   Do you actually have a gva with tdp?  With nested virtualization,
> >>  >>   how do you interpret this gva?
> >>  >With tdp it is gpa just like tdp_page_fault gets gpa where shadow page
> >>  >version gets gva. Nested virtualization is too complex to interpret.
> >>
> >>  It's not good to have a tracepoint that depends on cpu mode (without
> >>  recording that mode). I think we have the same issue in
> >>  trace_kvm_page_fault though.
> >We have mmu_is_nested(). I'll just disable apf while vcpu is in nested
> >mode for now.
> 
> What if we get the apf in non-nested mode and it completes in nested mode?
> 
I am not yet sure we have any problem with nested mode at all. I am
looking at it. If we have we can skip prefault if in nested.

> >>
> >>  >>   >+
> >>  >>   >+	/* do alloc nowait since if we are going to sleep anyway we
> >>  >>   >+	   may as well sleep faulting in page */
> >>  >>   /*
> >>  >>    * multi
> >>  >>    * line
> >>  >>    * comment
> >>  >>    */
> >>  >>
> >>  >>   (but a good one, this is subtle)
> >>  >>
> >>  >>   I missed where you halt the vcpu.  Can you point me at the function?
> >>  >>
> >>  >>   Note this is a synthetic halt and must not be visible to live
> >>  >>   migration, or we risk live migrating a halted state which doesn't
> >>  >>   really exist.
> >>  >>
> >>  >>   Might be simplest to drain the apf queue on any of the save/restore ioctls.
> >>  >>
> >>  >So that "info cpu" will interfere with apf? Migration should work
> >>  >in regular way. apf state should not be migrated since it has no meaning
> >>  >on the destination. I'll make sure synthetic halt state will not
> >>  >interfere with migration.
> >>
> >>  If you deliver an apf, the guest expects a completion.
> >>
> >There is special completion that tells guest to wake all sleeping tasks
> >on vcpu. It is delivered after migration on the destination.
> >
> 
> Yes, I saw.
> 
> What if you can't deliver it?  is it possible that some other vcpu
How can this happen? If I can't deliverer it I can't deliver
non-broadcast apfs too.

> will start receiving apfs that alias the old ones?  Or is the
> broadcast global?
> 
Broadcast is not global but tokens are unique per cpu so other vcpu will
not be able to receiving apfs that alias the old ones (if I understand
what you mean correctly). 

--
			Gleb.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
