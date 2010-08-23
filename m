Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 5E1CA6B03C5
	for <linux-mm@kvack.org>; Mon, 23 Aug 2010 12:17:37 -0400 (EDT)
Message-ID: <4C729F10.40005@redhat.com>
Date: Mon, 23 Aug 2010 19:17:20 +0300
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH v5 08/12] Inject asynchronous page fault into a guest
 if page is swapped out.
References: <1279553462-7036-1-git-send-email-gleb@redhat.com> <1279553462-7036-9-git-send-email-gleb@redhat.com>
In-Reply-To: <1279553462-7036-9-git-send-email-gleb@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Gleb Natapov <gleb@redhat.com>
Cc: kvm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mingo@elte.hu, a.p.zijlstra@chello.nl, tglx@linutronix.de, hpa@zytor.com, riel@redhat.com, cl@linux-foundation.org, mtosatti@redhat.com
List-ID: <linux-mm.kvack.org>

  On 07/19/2010 06:30 PM, Gleb Natapov wrote:
> If guest access swapped out memory do not swap it in from vcpu thread
> context. Setup slow work to do swapping and send async page fault to
> a guest.
>
> Allow async page fault injection only when guest is in user mode since
> otherwise guest may be in non-sleepable context and will not be able to
> reschedule.
>
>
>
>   struct kvm_arch {
> @@ -444,6 +446,8 @@ struct kvm_vcpu_stat {
>   	u32 hypercalls;
>   	u32 irq_injections;
>   	u32 nmi_injections;
> +	u32 apf_not_present;
> +	u32 apf_present;
>   };

Please don't add more stats, instead add tracepoints which can be 
converted to stats by userspace.

Would be good to have both guest and host tracepoints.

> @@ -2345,6 +2346,21 @@ static int nonpaging_page_fault(struct kvm_vcpu *vcpu, gva_t gva,
>   			     error_code&  PFERR_WRITE_MASK, gfn);
>   }
>
> +int kvm_arch_setup_async_pf(struct kvm_vcpu *vcpu, gva_t gva, gfn_t gfn)
> +{
> +	struct kvm_arch_async_pf arch;
> +	arch.token = (vcpu->arch.async_pf_id++<<  12) | vcpu->vcpu_id;
> +	return kvm_setup_async_pf(vcpu, gva, gfn,&arch);
> +}

Ok.  so token is globally unique.  We're limited to 4096 vcpus, I guess 
that's fine.  Wraparound at 1M faults/vcpu, what's the impact?  failure 
if we have 1M faulting processes on one vcpu?

I guess that's fine too.

> +
> +static bool can_do_async_pf(struct kvm_vcpu *vcpu)
> +{
> +	if (!vcpu->arch.apf_data || kvm_event_needs_reinjection(vcpu))
> +		return false;
> +
> +	return !!kvm_x86_ops->get_cpl(vcpu);

!! !needed, bool autoconverts.  But > 0 is more readable.

> +}
> +
>   static int tdp_page_fault(struct kvm_vcpu *vcpu, gva_t gpa,
>   				u32 error_code)
>   {
> @@ -2353,6 +2369,7 @@ static int tdp_page_fault(struct kvm_vcpu *vcpu, gva_t gpa,
>   	int level;
>   	gfn_t gfn = gpa>>  PAGE_SHIFT;
>   	unsigned long mmu_seq;
> +	bool async;
>
>   	ASSERT(vcpu);
>   	ASSERT(VALID_PAGE(vcpu->arch.mmu.root_hpa));
> @@ -2367,7 +2384,23 @@ static int tdp_page_fault(struct kvm_vcpu *vcpu, gva_t gpa,
>
>   	mmu_seq = vcpu->kvm->mmu_notifier_seq;
>   	smp_rmb();
> -	pfn = gfn_to_pfn(vcpu->kvm, gfn);
> +
> +	if (can_do_async_pf(vcpu)) {
> +		pfn = gfn_to_pfn_async(vcpu->kvm, gfn,&async);
> +		trace_kvm_try_async_get_page(async, pfn);
> +	} else {
> +do_sync:
> +		async = false;
> +		pfn = gfn_to_pfn(vcpu->kvm, gfn);
> +	}
> +
> +	if (async) {
> +		if (!kvm_arch_setup_async_pf(vcpu, gpa, gfn))
> +			goto do_sync;
> +		return 0;
> +	}
> +

This goto is pretty ugly.  How about:

     async = false;
     if (can_do_async_pf(&async)) {
     }
     if (async && !setup())
           async = false;
     if (async)
           ...

or something.

> @@ -459,7 +460,21 @@ static int FNAME(page_fault)(struct kvm_vcpu *vcpu, gva_t addr,
>
>   	mmu_seq = vcpu->kvm->mmu_notifier_seq;
>   	smp_rmb();
> -	pfn = gfn_to_pfn(vcpu->kvm, walker.gfn);
> +
> +	if (can_do_async_pf(vcpu)) {
> +		pfn = gfn_to_pfn_async(vcpu->kvm, walker.gfn,&async);
> +		trace_kvm_try_async_get_page(async, pfn);
> +	} else {
> +do_sync:
> +		async = false;
> +		pfn = gfn_to_pfn(vcpu->kvm, walker.gfn);
> +	}
> +
> +	if (async) {
> +		if (!kvm_arch_setup_async_pf(vcpu, addr, walker.gfn))
> +			goto do_sync;
> +		return 0;
> +	}
>

This repetition is ugly too.

>
> +static int apf_put_user(struct kvm_vcpu *vcpu, u32 val)
> +{
> +	if (unlikely(vcpu->arch.apf_memslot_ver !=
> +		     vcpu->kvm->memslot_version)) {
> +		u64 gpa = vcpu->arch.apf_msr_val&  ~0x3f;
> +		unsigned long addr;
> +		int offset = offset_in_page(gpa);
> +
> +		addr = gfn_to_hva(vcpu->kvm, gpa>>  PAGE_SHIFT);
> +		vcpu->arch.apf_data = (u32 __user *)(addr + offset);
> +		if (kvm_is_error_hva(addr)) {
> +			vcpu->arch.apf_data = NULL;
> +			return -EFAULT;
> +		}
> +	}
> +
> +	return put_user(val, vcpu->arch.apf_data);
> +}

This nice cache needs to be outside apf to reduce complexity for 
reviewers and since it is useful for others.

Would be good to have memslot-cached kvm_put_guest() and kvm_get_guest().

> diff --git a/virt/kvm/kvm_main.c b/virt/kvm/kvm_main.c
> index 292514c..f56e8ac 100644
> --- a/virt/kvm/kvm_main.c
> +++ b/virt/kvm/kvm_main.c
> @@ -78,6 +78,11 @@ static atomic_t hardware_enable_failed;
>   struct kmem_cache *kvm_vcpu_cache;
>   EXPORT_SYMBOL_GPL(kvm_vcpu_cache);
>
> +#ifdef CONFIG_KVM_ASYNC_PF
> +#define ASYNC_PF_PER_VCPU 100
> +static struct kmem_cache *async_pf_cache;
> +#endif

All those #ifdefs can be eliminated with virt/kvm/apf.[ch].

> +
>   static __read_mostly struct preempt_ops kvm_preempt_ops;
>
>   struct dentry *kvm_debugfs_dir;
> @@ -186,6 +191,11 @@ int kvm_vcpu_init(struct kvm_vcpu *vcpu, struct kvm *kvm, unsigned id)
>   	vcpu->kvm = kvm;
>   	vcpu->vcpu_id = id;
>   	init_waitqueue_head(&vcpu->wq);
> +#ifdef CONFIG_KVM_ASYNC_PF
> +	INIT_LIST_HEAD(&vcpu->async_pf_done);
> +	INIT_LIST_HEAD(&vcpu->async_pf_queue);
> +	spin_lock_init(&vcpu->async_pf_lock);
> +#endif

  kvm_apf_init() etc.

> +		       struct kvm_arch_async_pf *arch)
> +{
> +	struct kvm_async_pf *work;
> +
> +	if (vcpu->async_pf_queued>= ASYNC_PF_PER_VCPU)
> +		return 0;

100 == too high.  At 16 vcpus, this allows 1600 kernel threads to wait 
for I/O.

Would have been best if we could ask for a page to be paged in 
asynchronously.

> +
> +	/* setup slow work */
> +
> +	/* do alloc nowait since if we are going to sleep anyway we
> +	   may as well sleep faulting in page */
> +	work = kmem_cache_zalloc(async_pf_cache, GFP_NOWAIT);
> +	if (!work)
> +		return 0;
> +
> +	atomic_set(&work->used, 1);
> +	work->page = NULL;
> +	work->vcpu = vcpu;
> +	work->gva = gva;
> +	work->addr = gfn_to_hva(vcpu->kvm, gfn);
> +	work->arch = *arch;
> +	work->mm = current->mm;
> +	atomic_inc(&work->mm->mm_count);
> +	kvm_get_kvm(work->vcpu->kvm);
> +
> +	/* this can't really happen otherwise gfn_to_pfn_async
> +	   would succeed */
> +	if (unlikely(kvm_is_error_hva(work->addr)))
> +		goto retry_sync;
> +
> +	slow_work_init(&work->work,&async_pf_ops);
> +	if (slow_work_enqueue(&work->work) != 0)
> +		goto retry_sync;
> +
> +	vcpu->async_pf_work = work;
> +	list_add_tail(&work->queue,&vcpu->async_pf_queue);
> +	vcpu->async_pf_queued++;
> +	return 1;
> +retry_sync:
> +	kvm_put_kvm(work->vcpu->kvm);
> +	mmdrop(work->mm);
> +	kmem_cache_free(async_pf_cache, work);
> +	return 0;
> +}
> +
> +

-- 
error compiling committee.c: too many arguments to function

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
