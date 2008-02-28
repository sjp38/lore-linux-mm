Message-ID: <47C673DE.6000902@qumranet.com>
Date: Thu, 28 Feb 2008 10:42:06 +0200
From: izik eidus <izike@qumranet.com>
MIME-Version: 1.0
Subject: Re: [PATCH] KVM swapping with mmu notifiers #v7
References: <20080219084357.GA22249@wotan.suse.de> <20080219135851.GI7128@v2.random> <20080219231157.GC18912@wotan.suse.de> <20080220010941.GR7128@v2.random> <20080220103942.GU7128@v2.random> <20080220104517.GV7128@v2.random> <20080227220656.GJ28483@v2.random>
In-Reply-To: <20080227220656.GJ28483@v2.random>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <andrea@qumranet.com>
Cc: Nick Piggin <npiggin@suse.de>, akpm@linux-foundation.org, Robin Holt <holt@sgi.com>, Avi Kivity <avi@qumranet.com>, kvm-devel@lists.sourceforge.net, Peter Zijlstra <a.p.zijlstra@chello.nl>, general@lists.openfabrics.org, Steve Wise <swise@opengridcomputing.com>, Roland Dreier <rdreier@cisco.com>, Kanoj Sarcar <kanojsarcar@yahoo.com>, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

=?ISO-8859-1?Q?=D7=A6=D7=99=D7=98=D7=95=D7=98?= Andrea Arcangeli:
Return-Path: <owner-linux-mm@kvack.org>
X-Envelope-To: <"|/home/majordomo/wrapper archive -f /home/ftp/pub/archives/linux-mm/linux-mm -m -a"> (uid 0)
X-Orcpt: rfc822;linux-mm-outgoing
Original-Recipient: rfc822;linux-mm-outgoing

> Same as before but one one hand ported to #v7 API and on the other
> hand ported to latest kvm.git.
>
> Signed-off-by: Andrea Arcangeli <andrea@qumranet.com>
>
> diff --git a/arch/x86/kvm/Kconfig b/arch/x86/kvm/Kconfig
> index 41962e7..e1287ab 100644
> --- a/arch/x86/kvm/Kconfig
> +++ b/arch/x86/kvm/Kconfig
> @@ -21,6 +21,7 @@ config KVM
>  	tristate "Kernel-based Virtual Machine (KVM) support"
>  	depends on HAVE_KVM && EXPERIMENTAL
>  	select PREEMPT_NOTIFIERS
> +	select MMU_NOTIFIER
>  	select ANON_INODES
>  	---help---
>  	  Support hosting fully virtualized guest machines using hardware
> diff --git a/arch/x86/kvm/mmu.c b/arch/x86/kvm/mmu.c
> index 4583329..4067b0f 100644
> --- a/arch/x86/kvm/mmu.c
> +++ b/arch/x86/kvm/mmu.c
> @@ -642,6 +642,110 @@ static void rmap_write_protect(struct kvm *kvm, u64 gfn)
>  	account_shadowed(kvm, gfn);
>  }
>  
> +static void kvm_unmap_spte(struct kvm *kvm, u64 *spte)
> +{
> +	struct page *page = pfn_to_page((*spte & PT64_BASE_ADDR_MASK) >> PAGE_SHIFT);
> +	get_page(page);
> +	rmap_remove(kvm, spte);
> +	set_shadow_pte(spte, shadow_trap_nonpresent_pte);
> +	kvm_flush_remote_tlbs(kvm);
> +	__free_page(page);
>   

with large page support i think we need here put_page...

> +}
> +
> +static void kvm_unmap_rmapp(struct kvm *kvm, unsigned long *rmapp)
> +{
> +	u64 *spte, *curr_spte;
> +
> +	spte = rmap_next(kvm, rmapp, NULL);
> +	while (spte) {
> +		BUG_ON(!(*spte & PT_PRESENT_MASK));
> +		rmap_printk("kvm_rmap_unmap_hva: spte %p %llx\n", spte, *spte);
> +		curr_spte = spte;
> +		spte = rmap_next(kvm, rmapp, spte);
> +		kvm_unmap_spte(kvm, curr_spte);
> +	}
> +}
> +
> +void kvm_unmap_hva(struct kvm *kvm, unsigned long hva)
> +{
> +	int i;
> +
> +	/*
> +	 * If mmap_sem isn't taken, we can look the memslots with only
> +	 * the mmu_lock by skipping over the slots with userspace_addr == 0.
> +	 */
> +	spin_lock(&kvm->mmu_lock);
> +	for (i = 0; i < kvm->nmemslots; i++) {
> +		struct kvm_memory_slot *memslot = &kvm->memslots[i];
> +		unsigned long start = memslot->userspace_addr;
> +		unsigned long end;
> +
> +		/* mmu_lock protects userspace_addr */
> +		if (!start)
> +			continue;
> +
> +		end = start + (memslot->npages << PAGE_SHIFT);
> +		if (hva >= start && hva < end) {
> +			gfn_t gfn_offset = (hva - start) >> PAGE_SHIFT;
> +			kvm_unmap_rmapp(kvm, &memslot->rmap[gfn_offset]);
> +		}
> +	}
> +	spin_unlock(&kvm->mmu_lock);
> +}
> +
> +static int kvm_age_rmapp(struct kvm *kvm, unsigned long *rmapp)
> +{
> +	u64 *spte;
> +	int young = 0;
> +
> +	spte = rmap_next(kvm, rmapp, NULL);
> +	while (spte) {
> +		int _young;
> +		u64 _spte = *spte;
> +		BUG_ON(!(_spte & PT_PRESENT_MASK));
> +		_young = _spte & PT_ACCESSED_MASK;
> +		if (_young) {
> +			young = !!_young;
> +			set_shadow_pte(spte, _spte & ~PT_ACCESSED_MASK);
> +		}
> +		spte = rmap_next(kvm, rmapp, spte);
> +	}
> +	return young;
> +}
> +
> +int kvm_age_hva(struct kvm *kvm, unsigned long hva)
> +{
> +	int i;
> +	int young = 0;
> +
> +	/*
> +	 * If mmap_sem isn't taken, we can look the memslots with only
> +	 * the mmu_lock by skipping over the slots with userspace_addr == 0.
> +	 */
> +	spin_lock(&kvm->mmu_lock);
> +	for (i = 0; i < kvm->nmemslots; i++) {
> +		struct kvm_memory_slot *memslot = &kvm->memslots[i];
> +		unsigned long start = memslot->userspace_addr;
> +		unsigned long end;
> +
> +		/* mmu_lock protects userspace_addr */
> +		if (!start)
> +			continue;
> +
> +		end = start + (memslot->npages << PAGE_SHIFT);
> +		if (hva >= start && hva < end) {
> +			gfn_t gfn_offset = (hva - start) >> PAGE_SHIFT;
> +			young |= kvm_age_rmapp(kvm, &memslot->rmap[gfn_offset]);
> +		}
> +	}
> +	spin_unlock(&kvm->mmu_lock);
> +
> +	if (young)
> +		kvm_flush_remote_tlbs(kvm);
> +
> +	return young;
> +}
> +
>  #ifdef MMU_DEBUG
>  static int is_empty_shadow_page(u64 *spt)
>  {
> diff --git a/arch/x86/kvm/paging_tmpl.h b/arch/x86/kvm/paging_tmpl.h
> index 17f9d16..b014b19 100644
> --- a/arch/x86/kvm/paging_tmpl.h
> +++ b/arch/x86/kvm/paging_tmpl.h
> @@ -380,6 +380,7 @@ static int FNAME(page_fault)(struct kvm_vcpu *vcpu, gva_t addr,
>  	int r;
>  	struct page *page;
>  	int largepage = 0;
> +	unsigned mmu_seq;
>  
>  	pgprintk("%s: addr %lx err %x\n", __FUNCTION__, addr, error_code);
>  	kvm_mmu_audit(vcpu, "pre page fault");
> @@ -415,6 +416,7 @@ static int FNAME(page_fault)(struct kvm_vcpu *vcpu, gva_t addr,
>  			largepage = 1;
>  		}
>  	}
> +	mmu_seq = read_seqbegin(&vcpu->kvm->arch.mmu_notifier_invalidate_lock);
>  	page = gfn_to_page(vcpu->kvm, walker.gfn);
>  	up_read(&current->mm->mmap_sem);
>  
> @@ -440,6 +442,15 @@ static int FNAME(page_fault)(struct kvm_vcpu *vcpu, gva_t addr,
>  	++vcpu->stat.pf_fixed;
>  	kvm_mmu_audit(vcpu, "post page fault (fixed)");
>  	spin_unlock(&vcpu->kvm->mmu_lock);
> +
> +	if (read_seqretry(&vcpu->kvm->arch.mmu_notifier_invalidate_lock, mmu_seq)) {
> +		down_read(&current->mm->mmap_sem);
> +		if (page != gfn_to_page(vcpu->kvm, walker.gfn))
> +			BUG();
> +		up_read(&current->mm->mmap_sem);
> +		kvm_release_page_clean(page);
> +	}
> +
>  	up_read(&vcpu->kvm->slots_lock);
>  
>  	return write_pt;
> diff --git a/arch/x86/kvm/x86.c b/arch/x86/kvm/x86.c
> index 6f09840..6eafb74 100644
> --- a/arch/x86/kvm/x86.c
> +++ b/arch/x86/kvm/x86.c
> @@ -3319,6 +3319,47 @@ void kvm_arch_vcpu_uninit(struct kvm_vcpu *vcpu)
>  	free_page((unsigned long)vcpu->arch.pio_data);
>  }
>  
> +static inline struct kvm *mmu_notifier_to_kvm(struct mmu_notifier *mn)
> +{
> +	struct kvm_arch *kvm_arch;
> +	kvm_arch = container_of(mn, struct kvm_arch, mmu_notifier);
> +	return container_of(kvm_arch, struct kvm, arch);
> +}
> +
> +void kvm_mmu_notifier_invalidate_page(struct mmu_notifier *mn,
> +				      struct mm_struct *mm,
> +				      unsigned long address)
> +{
> +	struct kvm *kvm = mmu_notifier_to_kvm(mn);
> +	BUG_ON(mm != kvm->mm);
> +	write_seqlock(&kvm->arch.mmu_notifier_invalidate_lock);
> +	kvm_unmap_hva(kvm, address);
> +	write_sequnlock(&kvm->arch.mmu_notifier_invalidate_lock);
> +}
> +
> +void kvm_mmu_notifier_invalidate_range_end(struct mmu_notifier *mn,
> +					   struct mm_struct *mm,
> +					   unsigned long start, unsigned long end)
> +{
> +	for (; start < end; start += PAGE_SIZE)
> +		kvm_mmu_notifier_invalidate_page(mn, mm, start);
> +}
> +
> +int kvm_mmu_notifier_age_page(struct mmu_notifier *mn,
> +			      struct mm_struct *mm,
> +			      unsigned long address)
> +{
> +	struct kvm *kvm = mmu_notifier_to_kvm(mn);
> +	BUG_ON(mm != kvm->mm);
> +	return kvm_age_hva(kvm, address);
> +}
> +
> +static const struct mmu_notifier_ops kvm_mmu_notifier_ops = {
> +	.invalidate_page	= kvm_mmu_notifier_invalidate_page,
> +	.invalidate_range_end	= kvm_mmu_notifier_invalidate_range_end,
> +	.age_page		= kvm_mmu_notifier_age_page,
> +};
> +
>  struct  kvm *kvm_arch_create_vm(void)
>  {
>  	struct kvm *kvm = kzalloc(sizeof(struct kvm), GFP_KERNEL);
> @@ -3328,6 +3369,10 @@ struct  kvm *kvm_arch_create_vm(void)
>  
>  	INIT_LIST_HEAD(&kvm->arch.active_mmu_pages);
>  
> +	kvm->arch.mmu_notifier.ops = &kvm_mmu_notifier_ops;
> +	mmu_notifier_register(&kvm->arch.mmu_notifier, current->mm);
> +	seqlock_init(&kvm->arch.mmu_notifier_invalidate_lock);
> +
>  	return kvm;
>  }
>  
> diff --git a/include/asm-x86/kvm_host.h b/include/asm-x86/kvm_host.h
> index 024b57c..305b7c3 100644
> --- a/include/asm-x86/kvm_host.h
> +++ b/include/asm-x86/kvm_host.h
> @@ -13,6 +13,7 @@
>  
>  #include <linux/types.h>
>  #include <linux/mm.h>
> +#include <linux/mmu_notifier.h>
>  
>  #include <linux/kvm.h>
>  #include <linux/kvm_para.h>
> @@ -303,6 +304,9 @@ struct kvm_arch{
>  	struct page *apic_access_page;
>  
>  	gpa_t wall_clock;
> +
> +	struct mmu_notifier mmu_notifier;
> +	seqlock_t mmu_notifier_invalidate_lock;
>  };
>  
>  struct kvm_vm_stat {
> @@ -422,6 +426,8 @@ int kvm_mmu_create(struct kvm_vcpu *vcpu);
>  int kvm_mmu_setup(struct kvm_vcpu *vcpu);
>  void kvm_mmu_set_nonpresent_ptes(u64 trap_pte, u64 notrap_pte);
>  
> +void kvm_unmap_hva(struct kvm *kvm, unsigned long hva);
> +int kvm_age_hva(struct kvm *kvm, unsigned long hva);
>  int kvm_mmu_reset_context(struct kvm_vcpu *vcpu);
>  void kvm_mmu_slot_remove_write_access(struct kvm *kvm, int slot);
>  void kvm_mmu_zap_all(struct kvm *kvm);
>
>
> As usual (for completeness) I append the change to the memslot
> readonly locking through kvm->mmu_lock:
>
> Signed-off-by: Andrea Arcangeli <andrea@qumranet.com>
>
> diff --git a/arch/x86/kvm/x86.c b/arch/x86/kvm/x86.c
> index 6f09840..a519fd8 100644
> --- a/arch/x86/kvm/x86.c
> +++ b/arch/x86/kvm/x86.c
> @@ -3379,16 +3379,23 @@ int kvm_arch_set_memory_region(struct kvm *kvm,
>  	 */
>  	if (!user_alloc) {
>  		if (npages && !old.rmap) {
> +			unsigned long userspace_addr;
> +
>  			down_write(&current->mm->mmap_sem);
> -			memslot->userspace_addr = do_mmap(NULL, 0,
> -						     npages * PAGE_SIZE,
> -						     PROT_READ | PROT_WRITE,
> -						     MAP_SHARED | MAP_ANONYMOUS,
> -						     0);
> +			userspace_addr = do_mmap(NULL, 0,
> +						 npages * PAGE_SIZE,
> +						 PROT_READ | PROT_WRITE,
> +						 MAP_SHARED | MAP_ANONYMOUS,
> +						 0);
>  			up_write(&current->mm->mmap_sem);
>  
> -			if (IS_ERR((void *)memslot->userspace_addr))
> -				return PTR_ERR((void *)memslot->userspace_addr);
> +			if (IS_ERR((void *)userspace_addr))
> +				return PTR_ERR((void *)userspace_addr);
> +
> +			/* set userspace_addr atomically for kvm_hva_to_rmapp */
> +			spin_lock(&kvm->mmu_lock);
> +			memslot->userspace_addr = userspace_addr;
> +			spin_unlock(&kvm->mmu_lock);
>  		} else {
>  			if (!old.user_alloc && old.rmap) {
>  				int ret;
> diff --git a/virt/kvm/kvm_main.c b/virt/kvm/kvm_main.c
> index 30bf832..8f3b6d6 100644
> --- a/virt/kvm/kvm_main.c
> +++ b/virt/kvm/kvm_main.c
> @@ -326,7 +326,15 @@ int __kvm_set_memory_region(struct kvm *kvm,
>  		memset(new.rmap, 0, npages * sizeof(*new.rmap));
>  
>  		new.user_alloc = user_alloc;
> -		new.userspace_addr = mem->userspace_addr;
> +		/*
> +		 * hva_to_rmmap() serialzies with the mmu_lock and to be
> +		 * safe it has to ignore memslots with !user_alloc &&
> +		 * !userspace_addr.
> +		 */
> +		if (user_alloc)
> +			new.userspace_addr = mem->userspace_addr;
> +		else
> +			new.userspace_addr = 0;
>  	}
>  	if (npages && !new.lpage_info) {
>  		int largepages = npages / KVM_PAGES_PER_HPAGE;
> @@ -355,14 +363,18 @@ int __kvm_set_memory_region(struct kvm *kvm,
>  		memset(new.dirty_bitmap, 0, dirty_bytes);
>  	}
>  
> +	spin_lock(&kvm->mmu_lock);
>  	if (mem->slot >= kvm->nmemslots)
>  		kvm->nmemslots = mem->slot + 1;
>  
>  	*memslot = new;
> +	spin_unlock(&kvm->mmu_lock);
>  
>  	r = kvm_arch_set_memory_region(kvm, mem, old, user_alloc);
>  	if (r) {
> +		spin_lock(&kvm->mmu_lock);
>  		*memslot = old;
> +		spin_unlock(&kvm->mmu_lock);
>  		goto out_free;
>  	}
>  
>   

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
