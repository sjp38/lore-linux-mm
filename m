Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 24CE26B007D
	for <linux-mm@kvack.org>; Mon,  2 Nov 2009 10:41:22 -0500 (EST)
Date: Mon, 2 Nov 2009 17:41:17 +0200
From: Gleb Natapov <gleb@redhat.com>
Subject: Re: [PATCH 06/11] Inject asynchronous page fault into a guest if
 page is swapped out.
Message-ID: <20091102154117.GD27911@redhat.com>
References: <1257076590-29559-1-git-send-email-gleb@redhat.com>
 <1257076590-29559-7-git-send-email-gleb@redhat.com>
 <4AEED70E.4050007@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4AEED70E.4050007@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Avi Kivity <avi@redhat.com>
Cc: kvm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Nov 02, 2009 at 02:56:46PM +0200, Avi Kivity wrote:
> On 11/01/2009 01:56 PM, Gleb Natapov wrote:
> >If guest access swapped out memory do not swap it in from vcpu thread
> >context. Setup slow work to do swapping and send async page fault to
> >a guest.
> >
> >Allow async page fault injection only when guest is in user mode since
> >otherwise guest may be in non-sleepable context and will not be able to
> >reschedule.
> 
> That loses us page cache accesses, which may be the majority of
> accesses in some workloads.
> 
This is addressed later in the patch series.

> If we allow the guest to ignore a fault, and ensure that a second
> access to an apf page from the same vcpu doesn't trigger another
> apf, we can simply ignore the apf in a guest when we can't schedule.
> 
> Probably best done with an enable bit for kernel-mode apfs.
> 
> >Signed-off-by: Gleb Natapov<gleb@redhat.com>
> >---
> >  arch/x86/include/asm/kvm_host.h |   20 +++
> >  arch/x86/kvm/mmu.c              |  243 ++++++++++++++++++++++++++++++++++++++-
> >  arch/x86/kvm/mmutrace.h         |   60 ++++++++++
> >  arch/x86/kvm/paging_tmpl.h      |   16 +++-
> >  arch/x86/kvm/x86.c              |   22 +++-
> 
> Much of the code is generic, please move it to virt/kvm.
> 
OK, Will move generic part to virt.

> >+static void async_pf_execute(struct slow_work *work)
> >+{
> >+	struct page *page[1];
> 
> No need to make it an array, just pass its address.
> 
OK

> >+	struct kvm_mmu_async_pf *apf =
> >+		container_of(work, struct kvm_mmu_async_pf, work);
> >+	wait_queue_head_t *q =&apf->vcpu->wq;
> >+
> >+	might_sleep();
> >+
> >+	down_read(&apf->mm->mmap_sem);
> >+	get_user_pages(current, apf->mm, apf->addr, 1, 1, 0, page, NULL);
> >+	up_read(&apf->mm->mmap_sem);
> >+
> >+	spin_lock(&apf->vcpu->arch.mmu_async_pf_lock);
> >+	list_add_tail(&apf->link,&apf->vcpu->arch.mmu_async_pf_done);
> >+	apf->page = page[0];
> >+	spin_unlock(&apf->vcpu->arch.mmu_async_pf_lock);
> >+
> >+	trace_kvm_mmu_async_pf_executed(apf->addr, apf->page, apf->token,
> >+					apf->gva);
> 
> _completed, but maybe better placed in vcpu context.
> 
> >+
> >+static bool can_do_async_pf(struct kvm_vcpu *vcpu)
> >+{
> >+	struct kvm_segment kvm_seg;
> >+
> >+	if (!vcpu->arch.pv_shm ||
> >+	    !(vcpu->arch.pv_shm->features&  KVM_PV_SHM_FEATURES_ASYNC_PF) ||
> >+	    kvm_event_needs_reinjection(vcpu))
> >+		return false;
> >+
> >+	kvm_get_segment(vcpu,&kvm_seg, VCPU_SREG_CS);
> >+
> >+	/* is userspace code? TODO check VM86 mode */
> >+	return !!(kvm_seg.selector&  3);
> 
> There's a ->get_cpl() which is slightly faster.  Note vm86 is
> perfectly fine for async pf.
> 
OK. But the code is removed by following patches anyway.

> >+static int setup_async_pf(struct kvm_vcpu *vcpu, gva_t gva, gfn_t gfn)
> >+{
> >+	struct kvm_mmu_async_pf *work;
> >+
> >+	/* setup slow work */
> >+
> >+	/* do alloc atomic since if we are going to sleep anyway we
> >+	   may as well sleep faulting in page */
> >+	work = kmem_cache_zalloc(mmu_async_pf_cache, GFP_ATOMIC);
> >+	if (!work)
> >+		return 0;
> >+
> >+	atomic_set(&work->used, 1);
> >+	work->page = NULL;
> >+	work->vcpu = vcpu;
> >+	work->gva = gva;
> >+	work->addr = gfn_to_hva(vcpu->kvm, gfn);
> >+	work->token = (vcpu->arch.async_pf_id++<<  12) | vcpu->vcpu_id;
> 
> The shift truncates async_pf_id.
> 
Will fix.

--
			Gleb.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
