Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id 1DC076B0031
	for <linux-mm@kvack.org>; Mon, 10 Jun 2013 13:11:17 -0400 (EDT)
Date: Mon, 10 Jun 2013 20:11:11 +0300
From: Gleb Natapov <gleb@redhat.com>
Subject: Re: [PATCH 3/4] PF: Additional flag for direct page fault inject
Message-ID: <20130610171111.GK29022@redhat.com>
References: <1370865828-2053-1-git-send-email-dingel@linux.vnet.ibm.com>
 <1370865828-2053-4-git-send-email-dingel@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1370865828-2053-4-git-send-email-dingel@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dominik Dingel <dingel@linux.vnet.ibm.com>
Cc: Paolo Bonzini <pbonzini@redhat.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, kvm@vger.kernel.org, linux-s390@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Jun 10, 2013 at 02:03:47PM +0200, Dominik Dingel wrote:
> On some architectures, as on s390x we may want to be able to directly inject
> notifications to the guest in case of a swapped in page. Also on s390x
> there is no need to go from gfn to hva as by calling gmap_fault we already
> have the needed address.
> 
> Due to a possible race, we now always have to insert the page to the queue.
> So if we are not able to schedule the async page, we have to remove it from
> the list again. As this is only when we also have to page in synchronously,
> the overhead is not really important.
> 
> Signed-off-by: Dominik Dingel <dingel@linux.vnet.ibm.com>
> ---
>  arch/x86/kvm/mmu.c       |  2 +-
>  include/linux/kvm_host.h |  3 ++-
>  virt/kvm/async_pf.c      | 33 +++++++++++++++++++++++++++------
>  3 files changed, 30 insertions(+), 8 deletions(-)
> 
> diff --git a/arch/x86/kvm/mmu.c b/arch/x86/kvm/mmu.c
> index 956ca35..02a49a9 100644
> --- a/arch/x86/kvm/mmu.c
> +++ b/arch/x86/kvm/mmu.c
> @@ -3223,7 +3223,7 @@ static int kvm_arch_setup_async_pf(struct kvm_vcpu *vcpu, gva_t gva, gfn_t gfn)
>  	arch.direct_map = vcpu->arch.mmu.direct_map;
>  	arch.cr3 = vcpu->arch.mmu.get_cr3(vcpu);
>  
> -	return kvm_setup_async_pf(vcpu, gva, gfn, &arch);
> +	return kvm_setup_async_pf(vcpu, gva, gfn, &arch, false);
>  }
>  
>  static bool can_do_async_pf(struct kvm_vcpu *vcpu)
> diff --git a/include/linux/kvm_host.h b/include/linux/kvm_host.h
> index 9bd29ef..a798deb 100644
> --- a/include/linux/kvm_host.h
> +++ b/include/linux/kvm_host.h
> @@ -165,12 +165,13 @@ struct kvm_async_pf {
>  	struct kvm_arch_async_pf arch;
>  	struct page *page;
>  	bool done;
> +	bool direct_inject;
This will be true or false for all apfs for a given arch, so it is
better to do it as compile time switch.

>  };
>  
>  void kvm_clear_async_pf_completion_queue(struct kvm_vcpu *vcpu);
>  void kvm_check_async_pf_completion(struct kvm_vcpu *vcpu);
>  int kvm_setup_async_pf(struct kvm_vcpu *vcpu, gva_t gva, gfn_t gfn,
> -		       struct kvm_arch_async_pf *arch);
> +		       struct kvm_arch_async_pf *arch, bool is_direct);
>  int kvm_async_pf_wakeup_all(struct kvm_vcpu *vcpu);
>  #endif
>  
> diff --git a/virt/kvm/async_pf.c b/virt/kvm/async_pf.c
> index ea475cd..a4a6483 100644
> --- a/virt/kvm/async_pf.c
> +++ b/virt/kvm/async_pf.c
> @@ -73,9 +73,17 @@ static void async_pf_execute(struct work_struct *work)
>  	unuse_mm(mm);
>  
>  	spin_lock(&vcpu->async_pf.lock);
> -	list_add_tail(&apf->link, &vcpu->async_pf.done);
>  	apf->page = page;
>  	apf->done = true;
> +	if (apf->direct_inject) {
> +		kvm_arch_async_page_present(vcpu, apf);
> +		list_del(&apf->queue);
> +		vcpu->async_pf.queued--;
> +		kvm_release_page_clean(apf->page);
> +		kmem_cache_free(async_pf_cache, apf);
kvm_clear_async_pf_completion_queue() walks async_pf.queue without
holding vcpu->async_pf.lock and I do not think we can take it there
either since cancel_work_sync() will probably deadlock.

> +	} else {
> +		list_add_tail(&apf->link, &vcpu->async_pf.done);
> +	}
>  	spin_unlock(&vcpu->async_pf.lock);
>  
>  	/*
> @@ -145,7 +153,7 @@ void kvm_check_async_pf_completion(struct kvm_vcpu *vcpu)
>  }
>  
>  int kvm_setup_async_pf(struct kvm_vcpu *vcpu, gva_t gva, gfn_t gfn,
> -		       struct kvm_arch_async_pf *arch)
> +		       struct kvm_arch_async_pf *arch, bool is_direct)
>  {
>  	struct kvm_async_pf *work;
>  
> @@ -165,13 +173,24 @@ int kvm_setup_async_pf(struct kvm_vcpu *vcpu, gva_t gva, gfn_t gfn,
>  	work->page = NULL;
>  	work->done = false;
>  	work->vcpu = vcpu;
> -	work->gva = gva;
> -	work->addr = gfn_to_hva(vcpu->kvm, gfn);
> +	if (gfn == -1) {
Just change kvm_setup_async_pf() to receive addr as a parameter and do
gfn_to_hva() in the caller if needed.

> +		work->gva = -1;
> +		work->addr = gva;
> +	} else {
> +		work->gva = gva;
> +		work->addr = gfn_to_hva(vcpu->kvm, gfn);
> +	}
> +	work->direct_inject = is_direct;
>  	work->arch = *arch;
>  	work->mm = current->mm;
>  	atomic_inc(&work->mm->mm_count);
>  	kvm_get_kvm(work->vcpu->kvm);
>  
> +	spin_lock(&vcpu->async_pf.lock);
> +	list_add_tail(&work->queue, &vcpu->async_pf.queue);
> +	vcpu->async_pf.queued++;
> +	spin_unlock(&vcpu->async_pf.lock);
> +
>  	/* this can't really happen otherwise gfn_to_pfn_async
>  	   would succeed */
>  	if (unlikely(kvm_is_error_hva(work->addr)))
> @@ -181,11 +200,13 @@ int kvm_setup_async_pf(struct kvm_vcpu *vcpu, gva_t gva, gfn_t gfn,
>  	if (!schedule_work(&work->work))
>  		goto retry_sync;
>  
> -	list_add_tail(&work->queue, &vcpu->async_pf.queue);
> -	vcpu->async_pf.queued++;
>  	kvm_arch_async_page_not_present(vcpu, work);
>  	return 1;
>  retry_sync:
> +	spin_lock(&vcpu->async_pf.lock);
> +	list_del(&work->queue);
> +	vcpu->async_pf.queued--;
> +	spin_unlock(&vcpu->async_pf.lock);
>  	kvm_put_kvm(work->vcpu->kvm);
>  	mmdrop(work->mm);
>  	kmem_cache_free(async_pf_cache, work);
> -- 
> 1.8.1.6

--
			Gleb.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
