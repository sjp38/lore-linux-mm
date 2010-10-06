Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 81CF46B0085
	for <linux-mm@kvack.org>; Wed,  6 Oct 2010 07:07:18 -0400 (EDT)
Date: Wed, 6 Oct 2010 13:07:04 +0200
From: Gleb Natapov <gleb@redhat.com>
Subject: Re: [PATCH v6 03/12] Retry fault before vmentry
Message-ID: <20101006110704.GW11145@redhat.com>
References: <1286207794-16120-1-git-send-email-gleb@redhat.com>
 <1286207794-16120-4-git-send-email-gleb@redhat.com>
 <20101005155409.GB28955@amt.cnet>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101005155409.GB28955@amt.cnet>
Sender: owner-linux-mm@kvack.org
To: Marcelo Tosatti <mtosatti@redhat.com>
Cc: kvm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, avi@redhat.com, mingo@elte.hu, a.p.zijlstra@chello.nl, tglx@linutronix.de, hpa@zytor.com, riel@redhat.com, cl@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Tue, Oct 05, 2010 at 12:54:09PM -0300, Marcelo Tosatti wrote:
> On Mon, Oct 04, 2010 at 05:56:25PM +0200, Gleb Natapov wrote:
> > When page is swapped in it is mapped into guest memory only after guest
> > tries to access it again and generate another fault. To save this fault
> > we can map it immediately since we know that guest is going to access
> > the page. Do it only when tdp is enabled for now. Shadow paging case is
> > more complicated. CR[034] and EFER registers should be switched before
> > doing mapping and then switched back.
> > 
> > Acked-by: Rik van Riel <riel@redhat.com>
> > Signed-off-by: Gleb Natapov <gleb@redhat.com>
> > ---
> >  arch/x86/include/asm/kvm_host.h |    4 +++-
> >  arch/x86/kvm/mmu.c              |   16 ++++++++--------
> >  arch/x86/kvm/paging_tmpl.h      |    6 +++---
> >  arch/x86/kvm/x86.c              |    7 +++++++
> >  virt/kvm/async_pf.c             |    2 ++
> >  5 files changed, 23 insertions(+), 12 deletions(-)
> > 
> > diff --git a/arch/x86/include/asm/kvm_host.h b/arch/x86/include/asm/kvm_host.h
> > index 5f154d3..b9f263e 100644
> > --- a/arch/x86/include/asm/kvm_host.h
> > +++ b/arch/x86/include/asm/kvm_host.h
> > @@ -240,7 +240,7 @@ struct kvm_mmu {
> >  	void (*new_cr3)(struct kvm_vcpu *vcpu);
> >  	void (*set_cr3)(struct kvm_vcpu *vcpu, unsigned long root);
> >  	unsigned long (*get_cr3)(struct kvm_vcpu *vcpu);
> > -	int (*page_fault)(struct kvm_vcpu *vcpu, gva_t gva, u32 err);
> > +	int (*page_fault)(struct kvm_vcpu *vcpu, gva_t gva, u32 err, bool no_apf);
> >  	void (*inject_page_fault)(struct kvm_vcpu *vcpu);
> >  	void (*free)(struct kvm_vcpu *vcpu);
> >  	gpa_t (*gva_to_gpa)(struct kvm_vcpu *vcpu, gva_t gva, u32 access,
> > @@ -838,6 +838,8 @@ void kvm_arch_async_page_not_present(struct kvm_vcpu *vcpu,
> >  				     struct kvm_async_pf *work);
> >  void kvm_arch_async_page_present(struct kvm_vcpu *vcpu,
> >  				 struct kvm_async_pf *work);
> > +void kvm_arch_async_page_ready(struct kvm_vcpu *vcpu,
> > +			       struct kvm_async_pf *work);
> >  extern bool kvm_find_async_pf_gfn(struct kvm_vcpu *vcpu, gfn_t gfn);
> >  
> >  #endif /* _ASM_X86_KVM_HOST_H */
> > diff --git a/arch/x86/kvm/mmu.c b/arch/x86/kvm/mmu.c
> > index 4d49b5e..d85fda8 100644
> > --- a/arch/x86/kvm/mmu.c
> > +++ b/arch/x86/kvm/mmu.c
> > @@ -2558,7 +2558,7 @@ static gpa_t nonpaging_gva_to_gpa_nested(struct kvm_vcpu *vcpu, gva_t vaddr,
> >  }
> >  
> >  static int nonpaging_page_fault(struct kvm_vcpu *vcpu, gva_t gva,
> > -				u32 error_code)
> > +				u32 error_code, bool no_apf)
> >  {
> >  	gfn_t gfn;
> >  	int r;
> > @@ -2594,8 +2594,8 @@ static bool can_do_async_pf(struct kvm_vcpu *vcpu)
> >  	return kvm_x86_ops->interrupt_allowed(vcpu);
> >  }
> >  
> > -static bool try_async_pf(struct kvm_vcpu *vcpu, gfn_t gfn, gva_t gva,
> > -			 pfn_t *pfn)
> > +static bool try_async_pf(struct kvm_vcpu *vcpu, bool no_apf, gfn_t gfn,
> > +			 gva_t gva, pfn_t *pfn)
> >  {
> >  	bool async;
> >  
> > @@ -2606,7 +2606,7 @@ static bool try_async_pf(struct kvm_vcpu *vcpu, gfn_t gfn, gva_t gva,
> >  
> >  	put_page(pfn_to_page(*pfn));
> >  
> > -	if (can_do_async_pf(vcpu)) {
> > +	if (!no_apf && can_do_async_pf(vcpu)) {
> >  		trace_kvm_try_async_get_page(async, *pfn);
> >  		if (kvm_find_async_pf_gfn(vcpu, gfn)) {
> >  			vcpu->async_pf.work = kvm_double_apf;
> > @@ -2620,8 +2620,8 @@ static bool try_async_pf(struct kvm_vcpu *vcpu, gfn_t gfn, gva_t gva,
> >  	return false;
> >  }
> >  
> > -static int tdp_page_fault(struct kvm_vcpu *vcpu, gva_t gpa,
> > -				u32 error_code)
> > +static int tdp_page_fault(struct kvm_vcpu *vcpu, gva_t gpa, u32 error_code,
> > +			  bool no_apf)
> >  {
> >  	pfn_t pfn;
> >  	int r;
> > @@ -2643,7 +2643,7 @@ static int tdp_page_fault(struct kvm_vcpu *vcpu, gva_t gpa,
> >  	mmu_seq = vcpu->kvm->mmu_notifier_seq;
> >  	smp_rmb();
> >  
> > -	if (try_async_pf(vcpu, gfn, gpa, &pfn))
> > +	if (try_async_pf(vcpu, no_apf, gfn, gpa, &pfn))
> >  		return 0;
> >  
> >  	/* mmio */
> > @@ -3306,7 +3306,7 @@ int kvm_mmu_page_fault(struct kvm_vcpu *vcpu, gva_t cr2, u32 error_code)
> >  	int r;
> >  	enum emulation_result er;
> >  
> > -	r = vcpu->arch.mmu.page_fault(vcpu, cr2, error_code);
> > +	r = vcpu->arch.mmu.page_fault(vcpu, cr2, error_code, false);
> >  	if (r < 0)
> >  		goto out;
> >  
> > diff --git a/arch/x86/kvm/paging_tmpl.h b/arch/x86/kvm/paging_tmpl.h
> > index 8154353..9ad90f8 100644
> > --- a/arch/x86/kvm/paging_tmpl.h
> > +++ b/arch/x86/kvm/paging_tmpl.h
> > @@ -530,8 +530,8 @@ out_gpte_changed:
> >   *  Returns: 1 if we need to emulate the instruction, 0 otherwise, or
> >   *           a negative value on error.
> >   */
> > -static int FNAME(page_fault)(struct kvm_vcpu *vcpu, gva_t addr,
> > -			       u32 error_code)
> > +static int FNAME(page_fault)(struct kvm_vcpu *vcpu, gva_t addr, u32 error_code,
> > +			     bool no_apf)
> >  {
> >  	int write_fault = error_code & PFERR_WRITE_MASK;
> >  	int user_fault = error_code & PFERR_USER_MASK;
> > @@ -574,7 +574,7 @@ static int FNAME(page_fault)(struct kvm_vcpu *vcpu, gva_t addr,
> >  	mmu_seq = vcpu->kvm->mmu_notifier_seq;
> >  	smp_rmb();
> >  
> > -	if (try_async_pf(vcpu, walker.gfn, addr, &pfn))
> > +	if (try_async_pf(vcpu, no_apf, walker.gfn, addr, &pfn))
> >  		return 0;
> >  
> >  	/* mmio */
> > diff --git a/arch/x86/kvm/x86.c b/arch/x86/kvm/x86.c
> > index 8dd9ac2..48fd59d 100644
> > --- a/arch/x86/kvm/x86.c
> > +++ b/arch/x86/kvm/x86.c
> > @@ -6123,6 +6123,13 @@ void kvm_set_rflags(struct kvm_vcpu *vcpu, unsigned long rflags)
> >  }
> >  EXPORT_SYMBOL_GPL(kvm_set_rflags);
> >  
> > +void kvm_arch_async_page_ready(struct kvm_vcpu *vcpu, struct kvm_async_pf *work)
> > +{
> > +	if (!tdp_enabled || is_error_page(work->page))
> > +		return;
> > +	vcpu->arch.mmu.page_fault(vcpu, work->gva, 0, true);
> > +}
> > +
> 
> Can't you set a bit in vcpu->requests instead, and handle it in "out:"
> at the end of vcpu_enter_guest? 
> 
> To have a single entry point for pagefaults, after vmexit handling.
Jumping to "out:" will skip vmexit handling anyway, so we will not reuse
same call site anyway. I don't see yet why the way you propose will have
an advantage.

--
			Gleb.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
