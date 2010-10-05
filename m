Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 6AFB56B0087
	for <linux-mm@kvack.org>; Tue,  5 Oct 2010 15:53:41 -0400 (EDT)
Date: Tue, 5 Oct 2010 16:00:51 -0300
From: Marcelo Tosatti <mtosatti@redhat.com>
Subject: Re: [PATCH v6 09/12] Inject asynchronous page fault into a PV guest
 if page is swapped out.
Message-ID: <20101005190051.GB1786@amt.cnet>
References: <1286207794-16120-1-git-send-email-gleb@redhat.com>
 <1286207794-16120-10-git-send-email-gleb@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1286207794-16120-10-git-send-email-gleb@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Gleb Natapov <gleb@redhat.com>
Cc: kvm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, avi@redhat.com, mingo@elte.hu, a.p.zijlstra@chello.nl, tglx@linutronix.de, hpa@zytor.com, riel@redhat.com, cl@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Mon, Oct 04, 2010 at 05:56:31PM +0200, Gleb Natapov wrote:
> Send async page fault to a PV guest if it accesses swapped out memory.
> Guest will choose another task to run upon receiving the fault.
> 
> Allow async page fault injection only when guest is in user mode since
> otherwise guest may be in non-sleepable context and will not be able
> to reschedule.
> 
> Vcpu will be halted if guest will fault on the same page again or if
> vcpu executes kernel code.
> 
> Signed-off-by: Gleb Natapov <gleb@redhat.com>
> ---
>  arch/x86/include/asm/kvm_host.h |    3 ++
>  arch/x86/kvm/mmu.c              |    1 +
>  arch/x86/kvm/x86.c              |   49 ++++++++++++++++++++++++++++++++------
>  include/trace/events/kvm.h      |   17 ++++++++----
>  virt/kvm/async_pf.c             |    3 +-
>  5 files changed, 58 insertions(+), 15 deletions(-)
> 
> diff --git a/arch/x86/include/asm/kvm_host.h b/arch/x86/include/asm/kvm_host.h
> index de31551..2f6fc87 100644
> --- a/arch/x86/include/asm/kvm_host.h
> +++ b/arch/x86/include/asm/kvm_host.h
> @@ -419,6 +419,7 @@ struct kvm_vcpu_arch {
>  		gfn_t gfns[roundup_pow_of_two(ASYNC_PF_PER_VCPU)];
>  		struct gfn_to_hva_cache data;
>  		u64 msr_val;
> +		u32 id;
>  	} apf;
>  };
>  
> @@ -594,6 +595,7 @@ struct kvm_x86_ops {
>  };
>  
>  struct kvm_arch_async_pf {
> +	u32 token;
>  	gfn_t gfn;
>  };
>  
> @@ -842,6 +844,7 @@ void kvm_arch_async_page_present(struct kvm_vcpu *vcpu,
>  				 struct kvm_async_pf *work);
>  void kvm_arch_async_page_ready(struct kvm_vcpu *vcpu,
>  			       struct kvm_async_pf *work);
> +bool kvm_arch_can_inject_async_page_present(struct kvm_vcpu *vcpu);
>  extern bool kvm_find_async_pf_gfn(struct kvm_vcpu *vcpu, gfn_t gfn);
>  
>  #endif /* _ASM_X86_KVM_HOST_H */
> diff --git a/arch/x86/kvm/mmu.c b/arch/x86/kvm/mmu.c
> index d85fda8..de53cab 100644
> --- a/arch/x86/kvm/mmu.c
> +++ b/arch/x86/kvm/mmu.c
> @@ -2580,6 +2580,7 @@ static int nonpaging_page_fault(struct kvm_vcpu *vcpu, gva_t gva,
>  int kvm_arch_setup_async_pf(struct kvm_vcpu *vcpu, gva_t gva, gfn_t gfn)
>  {
>  	struct kvm_arch_async_pf arch;
> +	arch.token = (vcpu->arch.apf.id++ << 12) | vcpu->vcpu_id;
>  	arch.gfn = gfn;
>  
>  	return kvm_setup_async_pf(vcpu, gva, gfn, &arch);
> diff --git a/arch/x86/kvm/x86.c b/arch/x86/kvm/x86.c
> index 3e123ab..0e69d37 100644
> --- a/arch/x86/kvm/x86.c
> +++ b/arch/x86/kvm/x86.c
> @@ -6225,25 +6225,58 @@ static void kvm_del_async_pf_gfn(struct kvm_vcpu *vcpu, gfn_t gfn)
>  	}
>  }
>  
> +static int apf_put_user(struct kvm_vcpu *vcpu, u32 val)
> +{
> +
> +	return kvm_write_guest_cached(vcpu->kvm, &vcpu->arch.apf.data, &val,
> +				      sizeof(val));
> +}
> +
>  void kvm_arch_async_page_not_present(struct kvm_vcpu *vcpu,
>  				     struct kvm_async_pf *work)
>  {
> -	vcpu->arch.mp_state = KVM_MP_STATE_HALTED;
> -
> -	if (work == kvm_double_apf)
> +	if (work == kvm_double_apf) {
>  		trace_kvm_async_pf_doublefault(kvm_rip_read(vcpu));
> -	else {
> -		trace_kvm_async_pf_not_present(work->gva);
> -
> +		vcpu->arch.mp_state = KVM_MP_STATE_HALTED;
> +	} else {
> +		trace_kvm_async_pf_not_present(work->arch.token, work->gva);
>  		kvm_add_async_pf_gfn(vcpu, work->arch.gfn);
> +
> +		if (!(vcpu->arch.apf.msr_val & KVM_ASYNC_PF_ENABLED) ||
> +		    kvm_x86_ops->get_cpl(vcpu) == 0)
> +			vcpu->arch.mp_state = KVM_MP_STATE_HALTED;
> +		else if (!apf_put_user(vcpu, KVM_PV_REASON_PAGE_NOT_PRESENT)) {
> +			vcpu->arch.fault.error_code = 0;
> +			vcpu->arch.fault.address = work->arch.token;
> +			kvm_inject_page_fault(vcpu);
> +		}

Missed !kvm_event_needs_reinjection(vcpu) ? 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
