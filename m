Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 18F346B004A
	for <linux-mm@kvack.org>; Thu,  7 Oct 2010 13:48:29 -0400 (EDT)
Date: Thu, 7 Oct 2010 19:48:16 +0200
From: Gleb Natapov <gleb@redhat.com>
Subject: Re: [PATCH v6 02/12] Halt vcpu if page it tries to access is
 swapped out.
Message-ID: <20101007174816.GE2397@redhat.com>
References: <1286207794-16120-1-git-send-email-gleb@redhat.com>
 <1286207794-16120-3-git-send-email-gleb@redhat.com>
 <20101005145916.GA28955@amt.cnet>
 <4CAC5459.3060004@redhat.com>
 <20101006105203.GU11145@redhat.com>
 <4CAD98CE.7020502@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4CAD98CE.7020502@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Avi Kivity <avi@redhat.com>
Cc: Marcelo Tosatti <mtosatti@redhat.com>, kvm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mingo@elte.hu, a.p.zijlstra@chello.nl, tglx@linutronix.de, hpa@zytor.com, riel@redhat.com, cl@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Thu, Oct 07, 2010 at 11:54:22AM +0200, Avi Kivity wrote:
>  On 10/06/2010 12:52 PM, Gleb Natapov wrote:
> >On Wed, Oct 06, 2010 at 12:50:01PM +0200, Avi Kivity wrote:
> >>   On 10/05/2010 04:59 PM, Marcelo Tosatti wrote:
> >>  >On Mon, Oct 04, 2010 at 05:56:24PM +0200, Gleb Natapov wrote:
> >>  >>   If a guest accesses swapped out memory do not swap it in from vcpu thread
> >>  >>   context. Schedule work to do swapping and put vcpu into halted state
> >>  >>   instead.
> >>  >>
> >>  >>   Interrupts will still be delivered to the guest and if interrupt will
> >>  >>   cause reschedule guest will continue to run another task.
> >>  >>
> >>  >>   Signed-off-by: Gleb Natapov<gleb@redhat.com>
> >>  >>   ---
> >>  >>    arch/x86/include/asm/kvm_host.h |   17 +++
> >>  >>    arch/x86/kvm/Kconfig            |    1 +
> >>  >>    arch/x86/kvm/Makefile           |    1 +
> >>  >>    arch/x86/kvm/mmu.c              |   51 +++++++++-
> >>  >>    arch/x86/kvm/paging_tmpl.h      |    4 +-
> >>  >>    arch/x86/kvm/x86.c              |  109 +++++++++++++++++++-
> >>  >>    include/linux/kvm_host.h        |   31 ++++++
> >>  >>    include/trace/events/kvm.h      |   88 ++++++++++++++++
> >>  >>    virt/kvm/Kconfig                |    3 +
> >>  >>    virt/kvm/async_pf.c             |  220 +++++++++++++++++++++++++++++++++++++++
> >>  >>    virt/kvm/async_pf.h             |   36 +++++++
> >>  >>    virt/kvm/kvm_main.c             |   57 ++++++++--
> >>  >>    12 files changed, 603 insertions(+), 15 deletions(-)
> >>  >>    create mode 100644 virt/kvm/async_pf.c
> >>  >>    create mode 100644 virt/kvm/async_pf.h
> >>  >>
> >>  >
> >>  >>   +	async_pf_cache = NULL;
> >>  >>   +}
> >>  >>   +
> >>  >>   +void kvm_async_pf_vcpu_init(struct kvm_vcpu *vcpu)
> >>  >>   +{
> >>  >>   +	INIT_LIST_HEAD(&vcpu->async_pf.done);
> >>  >>   +	INIT_LIST_HEAD(&vcpu->async_pf.queue);
> >>  >>   +	spin_lock_init(&vcpu->async_pf.lock);
> >>  >>   +}
> >>  >>   +
> >>  >>   +static void async_pf_execute(struct work_struct *work)
> >>  >>   +{
> >>  >>   +	struct page *page;
> >>  >>   +	struct kvm_async_pf *apf =
> >>  >>   +		container_of(work, struct kvm_async_pf, work);
> >>  >>   +	struct mm_struct *mm = apf->mm;
> >>  >>   +	struct kvm_vcpu *vcpu = apf->vcpu;
> >>  >>   +	unsigned long addr = apf->addr;
> >>  >>   +	gva_t gva = apf->gva;
> >>  >>   +
> >>  >>   +	might_sleep();
> >>  >>   +
> >>  >>   +	use_mm(mm);
> >>  >>   +	down_read(&mm->mmap_sem);
> >>  >>   +	get_user_pages(current, mm, addr, 1, 1, 0,&page, NULL);
> >>  >>   +	up_read(&mm->mmap_sem);
> >>  >>   +	unuse_mm(mm);
> >>  >>   +
> >>  >>   +	spin_lock(&vcpu->async_pf.lock);
> >>  >>   +	list_add_tail(&apf->link,&vcpu->async_pf.done);
> >>  >>   +	apf->page = page;
> >>  >>   +	spin_unlock(&vcpu->async_pf.lock);
> >>  >
> >>  >This can fail, and apf->page become NULL.
> >>
> >>  Does it even become NULL?  On error, get_user_pages() won't update
> >>  the pages argument, so page becomes garbage here.
> >>
> >apf is allocated with kmem_cache_zalloc() and ->page is set to NULL in
> >kvm_setup_async_pf() to be extra sure.
> >
> 
> But you assign apf->page = page;, overriding it with garbage here.
> 
Ah, right you are.

--
			Gleb.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
