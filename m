Message-ID: <48137B8B.7010202@us.ibm.com>
Date: Sat, 26 Apr 2008 13:59:23 -0500
From: Anthony Liguori <aliguori@us.ibm.com>
MIME-Version: 1.0
Subject: Re: mmu notifier #v14
References: <20080426164511.GJ9514@duo.random>
In-Reply-To: <20080426164511.GJ9514@duo.random>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@qumranet.com>
Cc: Rusty Russell <rusty@rustcorp.com.au>, Robin Holt <holt@sgi.com>, Jack Steiner <steiner@sgi.com>, Christoph Lameter <clameter@sgi.com>, akpm@linux-foundation.org, Nick Piggin <npiggin@suse.de>, Steve Wise <swise@opengridcomputing.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, Kanoj Sarcar <kanojsarcar@yahoo.com>, Roland Dreier <rdreier@cisco.com>, linux-kernel@vger.kernel.org, Avi Kivity <avi@qumranet.com>, kvm-devel@lists.sourceforge.net, general@lists.openfabrics.org, Hugh Dickins <hugh@veritas.com>, Chris Wright <chrisw@redhat.com>, Marcelo Tosatti <marcelo@kvack.org>
List-ID: <linux-mm.kvack.org>

Andrea Arcangeli wrote:
> Hello everyone,
>
> here it is the mmu notifier #v14.
>
> 	http://www.kernel.org/pub/linux/kernel/people/andrea/patches/v2.6/2.6.25/mmu-notifier-v14/
>
> Please everyone involved review and (hopefully ;) ack that this is
> safe to go in 2.6.26, the most important is to verify that this is a
> noop when disarmed regardless of MMU_NOTIFIER=y or =n.
>
> 	http://www.kernel.org/pub/linux/kernel/people/andrea/patches/v2.6/2.6.25/mmu-notifier-v14/mmu-notifier-core
>
> I'll be sending that patch to Andrew inbox.
>
> Signed-off-by: Andrea Arcangeli <andrea@qumranet.com>
>
> diff --git a/arch/x86/kvm/Kconfig b/arch/x86/kvm/Kconfig
> index 8d45fab..ce3251c 100644
> --- a/arch/x86/kvm/Kconfig
> +++ b/arch/x86/kvm/Kconfig
> @@ -21,6 +21,7 @@ config KVM
>  	tristate "Kernel-based Virtual Machine (KVM) support"
>  	depends on HAVE_KVM
>  	select PREEMPT_NOTIFIERS
> +	select MMU_NOTIFIER
>  	select ANON_INODES
>  	---help---
>  	  Support hosting fully virtualized guest machines using hardware
> diff --git a/arch/x86/kvm/mmu.c b/arch/x86/kvm/mmu.c
> index 2ad6f54..853087a 100644
> --- a/arch/x86/kvm/mmu.c
> +++ b/arch/x86/kvm/mmu.c
> @@ -663,6 +663,108 @@ static void rmap_write_protect(struct kvm *kvm, u64 gfn)
>  	account_shadowed(kvm, gfn);
>  }
>
> +static void kvm_unmap_spte(struct kvm *kvm, u64 *spte)
> +{
> +	struct page *page = pfn_to_page((*spte & PT64_BASE_ADDR_MASK) >> PAGE_SHIFT);
> +	get_page(page);
>   

You should not assume a struct page exists for any given spte. Instead, 
use kvm_get_pfn() and kvm_release_pfn_clean().

>  static void nonpaging_free(struct kvm_vcpu *vcpu)
> @@ -1643,11 +1771,11 @@ static void mmu_guess_page_from_pte_write(struct kvm_vcpu *vcpu, gpa_t gpa,
>  	int r;
>  	u64 gpte = 0;
>  	pfn_t pfn;
> -
> -	vcpu->arch.update_pte.largepage = 0;
> +	int mmu_seq;
> +	int largepage;
>
>  	if (bytes != 4 && bytes != 8)
> -		return;
> +		goto out_lock;
>
>  	/*
>  	 * Assume that the pte write on a page table of the same type
> @@ -1660,7 +1788,7 @@ static void mmu_guess_page_from_pte_write(struct kvm_vcpu *vcpu, gpa_t gpa,
>  		if ((bytes == 4) && (gpa % 4 == 0)) {
>  			r = kvm_read_guest(vcpu->kvm, gpa & ~(u64)7, &gpte, 8);
>  			if (r)
> -				return;
> +				goto out_lock;
>  			memcpy((void *)&gpte + (gpa % 8), new, 4);
>  		} else if ((bytes == 8) && (gpa % 8 == 0)) {
>  			memcpy((void *)&gpte, new, 8);
> @@ -1670,23 +1798,35 @@ static void mmu_guess_page_from_pte_write(struct kvm_vcpu *vcpu, gpa_t gpa,
>  			memcpy((void *)&gpte, new, 4);
>  	}
>  	if (!is_present_pte(gpte))
> -		return;
> +		goto out_lock;
>  	gfn = (gpte & PT64_BASE_ADDR_MASK) >> PAGE_SHIFT;
>
> +	largepage = 0;
>  	down_read(&current->mm->mmap_sem);
>  	if (is_large_pte(gpte) && is_largepage_backed(vcpu, gfn)) {
>  		gfn &= ~(KVM_PAGES_PER_HPAGE-1);
> -		vcpu->arch.update_pte.largepage = 1;
> +		largepage = 1;
>  	}
> +	mmu_seq = atomic_read(&vcpu->kvm->arch.mmu_notifier_seq);
> +	/* implicit mb(), we'll read before PT lock is unlocked */
>  	pfn = gfn_to_pfn(vcpu->kvm, gfn);
>  	up_read(&current->mm->mmap_sem);
>
> -	if (is_error_pfn(pfn)) {
> -		kvm_release_pfn_clean(pfn);
> -		return;
> -	}
> +	if (is_error_pfn(pfn))
> +		goto out_release_and_lock;
> +
> +	spin_lock(&vcpu->kvm->mmu_lock);
> +	BUG_ON(!is_error_pfn(vcpu->arch.update_pte.pfn));
>  	vcpu->arch.update_pte.gfn = gfn;
>  	vcpu->arch.update_pte.pfn = pfn;
> +	vcpu->arch.update_pte.largepage = largepage;
> +	vcpu->arch.update_pte.mmu_seq = mmu_seq;
> +	return;
> +
> +out_release_and_lock:
> +	kvm_release_pfn_clean(pfn);
> +out_lock:
> +	spin_lock(&vcpu->kvm->mmu_lock);
>  }
>   

Perhaps I just have a weak stomach but I am uneasy having a function 
that takes a lock on exit. I walked through the logic and it doesn't 
appear to be wrong but it also is pretty clear that you could defer the 
acquisition of the lock to the caller (in this case, kvm_mmu_pte_write) 
by moving the update_pte assignment into kvm_mmu_pte_write.

>  void kvm_mmu_pte_write(struct kvm_vcpu *vcpu, gpa_t gpa,
> @@ -1711,7 +1851,6 @@ void kvm_mmu_pte_write(struct kvm_vcpu *vcpu, gpa_t gpa,
>
>  	pgprintk("%s: gpa %llx bytes %d\n", __func__, gpa, bytes);
>  	mmu_guess_page_from_pte_write(vcpu, gpa, new, bytes);
>   

Worst case, you pass 4 more pointer arguments here and, take the spin 
lock, and then depending on the result of mmu_guess_page_from_pte_write, 
update vcpu->arch.update_pte.

> @@ -3899,13 +4037,12 @@ static void kvm_free_vcpus(struct kvm *kvm)
>
>  void kvm_arch_destroy_vm(struct kvm *kvm)
>  {
> -	kvm_free_pit(kvm);
> -	kfree(kvm->arch.vpic);
> -	kfree(kvm->arch.vioapic);
> -	kvm_free_vcpus(kvm);
> -	kvm_free_physmem(kvm);
> -	if (kvm->arch.apic_access_page)
> -		put_page(kvm->arch.apic_access_page);
> +	/*
> +	 * kvm_mmu_notifier_release() will be called before
> +	 * mmu_notifier_unregister returns, if it didn't run
> +	 * already.
> +	 */
> +	mmu_notifier_unregister(&kvm->arch.mmu_notifier, kvm->mm);
>  	kfree(kvm);
>  }
>   

Why move the destruction of the vm to the MMU notifier unregister hook? 
Does anything else ever call mmu_notifier_unregister that would 
implicitly destroy the VM?

Regards,

Anthony Liguori

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
