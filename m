Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 5D0766006F5
	for <linux-mm@kvack.org>; Thu,  8 Jul 2010 14:05:44 -0400 (EDT)
Date: Thu, 8 Jul 2010 21:05:25 +0300
From: Gleb Natapov <gleb@redhat.com>
Subject: Re: [PATCH v4 08/12] Inject asynchronous page fault into a guest
 if page is swapped out.
Message-ID: <20100708180525.GA11885@redhat.com>
References: <1278433500-29884-1-git-send-email-gleb@redhat.com>
 <1278433500-29884-9-git-send-email-gleb@redhat.com>
 <20100708155920.GA13855@amt.cnet>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100708155920.GA13855@amt.cnet>
Sender: owner-linux-mm@kvack.org
To: Marcelo Tosatti <mtosatti@redhat.com>
Cc: kvm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, avi@redhat.com, mingo@elte.hu, a.p.zijlstra@chello.nl, tglx@linutronix.de, hpa@zytor.com, riel@redhat.com, cl@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Thu, Jul 08, 2010 at 12:59:20PM -0300, Marcelo Tosatti wrote:
> > +static int apf_put_user(struct kvm_vcpu *vcpu, u32 val)
> > +{
> > +	if (unlikely(vcpu->arch.apf_memslot_ver !=
> > +		     vcpu->kvm->memslot_version)) {
> > +		u64 gpa = vcpu->arch.apf_msr_val & ~0x3f;
> > +		unsigned long addr;
> > +		int offset = offset_in_page(gpa);
> > +
> > +		addr = gfn_to_hva(vcpu->kvm, gpa >> PAGE_SHIFT);
> > +		vcpu->arch.apf_data = (u32 __user*)(addr + offset);
> > +		if (kvm_is_error_hva(addr)) {
> > +			vcpu->arch.apf_data = NULL;
> > +			return -EFAULT;
> > +		}
> > +	}
> > +
> > +	return put_user(val, vcpu->arch.apf_data);
> > +}
> 
> Why not use kvm_write_guest?
Because I want to cache gfn_to_hva() translation, so this code tracks
memslot changes and does translation only when needed (almost never).

> 
> > +int kvm_setup_async_pf(struct kvm_vcpu *vcpu, gva_t gva, gfn_t gfn,
> > +		       struct kvm_arch_async_pf *arch)
> > +{
> > +	struct kvm_async_pf *work;
> > +
> > +	if (vcpu->async_pf_queued >= ASYNC_PF_PER_VCPU)
> > +		return 0;
> > +
> > +	/* setup slow work */
> > +
> > +	/* do alloc atomic since if we are going to sleep anyway we
> > +	   may as well sleep faulting in page */
> > +	work = kmem_cache_zalloc(async_pf_cache, GFP_ATOMIC);
> > +	if (!work)
> > +		return 0;
> 
> GFP_KERNEL is fine for this context.
But it can sleep, no? The comment explains why I don't want to sleep
here.

--
			Gleb.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
