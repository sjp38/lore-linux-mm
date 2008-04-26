Date: Sat, 26 Apr 2008 18:46:38 +0200
From: Andrea Arcangeli <andrea@qumranet.com>
Subject: mmu notifier #v14
Message-ID: <20080426164511.GJ9514@duo.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rusty Russell <rusty@rustcorp.com.au>, Robin Holt <holt@sgi.com>, Jack Steiner <steiner@sgi.com>, Christoph Lameter <clameter@sgi.com>
Cc: akpm@linux-foundation.org, Nick Piggin <npiggin@suse.de>, Steve Wise <swise@opengridcomputing.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, Kanoj Sarcar <kanojsarcar@yahoo.com>, Roland Dreier <rdreier@cisco.com>, linux-kernel@vger.kernel.org, Avi Kivity <avi@qumranet.com>, kvm-devel@lists.sourceforge.net, general@lists.openfabrics.org, Hugh Dickins <hugh@veritas.com>, Anthony Liguori <aliguori@us.ibm.com>, Chris Wright <chrisw@redhat.com>, Marcelo Tosatti <marcelo@kvack.org>
List-ID: <linux-mm.kvack.org>

Hello everyone,

here it is the mmu notifier #v14.

	http://www.kernel.org/pub/linux/kernel/people/andrea/patches/v2.6/2.6.25/mmu-notifier-v14/

Please everyone involved review and (hopefully ;) ack that this is
safe to go in 2.6.26, the most important is to verify that this is a
noop when disarmed regardless of MMU_NOTIFIER=y or =n.

	http://www.kernel.org/pub/linux/kernel/people/andrea/patches/v2.6/2.6.25/mmu-notifier-v14/mmu-notifier-core

I'll be sending that patch to Andrew inbox.

Signed-off-by: Andrea Arcangeli <andrea@qumranet.com>

diff --git a/arch/x86/kvm/Kconfig b/arch/x86/kvm/Kconfig
index 8d45fab..ce3251c 100644
--- a/arch/x86/kvm/Kconfig
+++ b/arch/x86/kvm/Kconfig
@@ -21,6 +21,7 @@ config KVM
 	tristate "Kernel-based Virtual Machine (KVM) support"
 	depends on HAVE_KVM
 	select PREEMPT_NOTIFIERS
+	select MMU_NOTIFIER
 	select ANON_INODES
 	---help---
 	  Support hosting fully virtualized guest machines using hardware
diff --git a/arch/x86/kvm/mmu.c b/arch/x86/kvm/mmu.c
index 2ad6f54..853087a 100644
--- a/arch/x86/kvm/mmu.c
+++ b/arch/x86/kvm/mmu.c
@@ -663,6 +663,108 @@ static void rmap_write_protect(struct kvm *kvm, u64 gfn)
 	account_shadowed(kvm, gfn);
 }
 
+static void kvm_unmap_spte(struct kvm *kvm, u64 *spte)
+{
+	struct page *page = pfn_to_page((*spte & PT64_BASE_ADDR_MASK) >> PAGE_SHIFT);
+	get_page(page);
+	rmap_remove(kvm, spte);
+	set_shadow_pte(spte, shadow_trap_nonpresent_pte);
+	kvm_flush_remote_tlbs(kvm);
+	put_page(page);
+}
+
+static void kvm_unmap_rmapp(struct kvm *kvm, unsigned long *rmapp)
+{
+	u64 *spte, *curr_spte;
+
+	spte = rmap_next(kvm, rmapp, NULL);
+	while (spte) {
+		BUG_ON(!(*spte & PT_PRESENT_MASK));
+		rmap_printk("kvm_rmap_unmap_hva: spte %p %llx\n", spte, *spte);
+		curr_spte = spte;
+		spte = rmap_next(kvm, rmapp, spte);
+		kvm_unmap_spte(kvm, curr_spte);
+	}
+}
+
+void kvm_unmap_hva(struct kvm *kvm, unsigned long hva)
+{
+	int i;
+
+	/*
+	 * If mmap_sem isn't taken, we can look the memslots with only
+	 * the mmu_lock by skipping over the slots with userspace_addr == 0.
+	 */
+	for (i = 0; i < kvm->nmemslots; i++) {
+		struct kvm_memory_slot *memslot = &kvm->memslots[i];
+		unsigned long start = memslot->userspace_addr;
+		unsigned long end;
+
+		/* mmu_lock protects userspace_addr */
+		if (!start)
+			continue;
+
+		end = start + (memslot->npages << PAGE_SHIFT);
+		if (hva >= start && hva < end) {
+			gfn_t gfn_offset = (hva - start) >> PAGE_SHIFT;
+			kvm_unmap_rmapp(kvm, &memslot->rmap[gfn_offset]);
+		}
+	}
+}
+
+static int kvm_age_rmapp(struct kvm *kvm, unsigned long *rmapp)
+{
+	u64 *spte;
+	int young = 0;
+
+	spte = rmap_next(kvm, rmapp, NULL);
+	while (spte) {
+		int _young;
+		u64 _spte = *spte;
+		BUG_ON(!(_spte & PT_PRESENT_MASK));
+		_young = _spte & PT_ACCESSED_MASK;
+		if (_young) {
+			young = !!_young;
+			set_shadow_pte(spte, _spte & ~PT_ACCESSED_MASK);
+		}
+		spte = rmap_next(kvm, rmapp, spte);
+	}
+	return young;
+}
+
+int kvm_age_hva(struct kvm *kvm, unsigned long hva)
+{
+	int i;
+	int young = 0;
+
+	/*
+	 * If mmap_sem isn't taken, we can look the memslots with only
+	 * the mmu_lock by skipping over the slots with userspace_addr == 0.
+	 */
+	spin_lock(&kvm->mmu_lock);
+	for (i = 0; i < kvm->nmemslots; i++) {
+		struct kvm_memory_slot *memslot = &kvm->memslots[i];
+		unsigned long start = memslot->userspace_addr;
+		unsigned long end;
+
+		/* mmu_lock protects userspace_addr */
+		if (!start)
+			continue;
+
+		end = start + (memslot->npages << PAGE_SHIFT);
+		if (hva >= start && hva < end) {
+			gfn_t gfn_offset = (hva - start) >> PAGE_SHIFT;
+			young |= kvm_age_rmapp(kvm, &memslot->rmap[gfn_offset]);
+		}
+	}
+	spin_unlock(&kvm->mmu_lock);
+
+	if (young)
+		kvm_flush_remote_tlbs(kvm);
+
+	return young;
+}
+
 #ifdef MMU_DEBUG
 static int is_empty_shadow_page(u64 *spt)
 {
@@ -1200,6 +1302,7 @@ static int nonpaging_map(struct kvm_vcpu *vcpu, gva_t v, int write, gfn_t gfn)
 	int r;
 	int largepage = 0;
 	pfn_t pfn;
+	int mmu_seq;
 
 	down_read(&current->mm->mmap_sem);
 	if (is_largepage_backed(vcpu, gfn & ~(KVM_PAGES_PER_HPAGE-1))) {
@@ -1207,6 +1310,8 @@ static int nonpaging_map(struct kvm_vcpu *vcpu, gva_t v, int write, gfn_t gfn)
 		largepage = 1;
 	}
 
+	mmu_seq = atomic_read(&vcpu->kvm->arch.mmu_notifier_seq);
+	/* implicit mb(), we'll read before PT lock is unlocked */
 	pfn = gfn_to_pfn(vcpu->kvm, gfn);
 	up_read(&current->mm->mmap_sem);
 
@@ -1217,6 +1322,11 @@ static int nonpaging_map(struct kvm_vcpu *vcpu, gva_t v, int write, gfn_t gfn)
 	}
 
 	spin_lock(&vcpu->kvm->mmu_lock);
+	if (unlikely(atomic_read(&vcpu->kvm->arch.mmu_notifier_count)))
+		goto out_unlock;
+	smp_rmb();
+	if (unlikely(atomic_read(&vcpu->kvm->arch.mmu_notifier_seq) != mmu_seq))
+		goto out_unlock;
 	kvm_mmu_free_some_pages(vcpu);
 	r = __direct_map(vcpu, v, write, largepage, gfn, pfn,
 			 PT32E_ROOT_LEVEL);
@@ -1224,6 +1334,11 @@ static int nonpaging_map(struct kvm_vcpu *vcpu, gva_t v, int write, gfn_t gfn)
 
 
 	return r;
+
+out_unlock:
+	spin_unlock(&vcpu->kvm->mmu_lock);
+	kvm_release_pfn_clean(pfn);
+	return 0;
 }
 
 
@@ -1355,6 +1470,7 @@ static int tdp_page_fault(struct kvm_vcpu *vcpu, gva_t gpa,
 	int r;
 	int largepage = 0;
 	gfn_t gfn = gpa >> PAGE_SHIFT;
+	int mmu_seq;
 
 	ASSERT(vcpu);
 	ASSERT(VALID_PAGE(vcpu->arch.mmu.root_hpa));
@@ -1368,6 +1484,8 @@ static int tdp_page_fault(struct kvm_vcpu *vcpu, gva_t gpa,
 		gfn &= ~(KVM_PAGES_PER_HPAGE-1);
 		largepage = 1;
 	}
+	mmu_seq = atomic_read(&vcpu->kvm->arch.mmu_notifier_seq);
+	/* implicit mb(), we'll read before PT lock is unlocked */
 	pfn = gfn_to_pfn(vcpu->kvm, gfn);
 	up_read(&current->mm->mmap_sem);
 	if (is_error_pfn(pfn)) {
@@ -1375,12 +1493,22 @@ static int tdp_page_fault(struct kvm_vcpu *vcpu, gva_t gpa,
 		return 1;
 	}
 	spin_lock(&vcpu->kvm->mmu_lock);
+	if (unlikely(atomic_read(&vcpu->kvm->arch.mmu_notifier_count)))
+		goto out_unlock;
+	smp_rmb();
+	if (unlikely(atomic_read(&vcpu->kvm->arch.mmu_notifier_seq) != mmu_seq))
+		goto out_unlock;
 	kvm_mmu_free_some_pages(vcpu);
 	r = __direct_map(vcpu, gpa, error_code & PFERR_WRITE_MASK,
 			 largepage, gfn, pfn, TDP_ROOT_LEVEL);
 	spin_unlock(&vcpu->kvm->mmu_lock);
 
 	return r;
+
+out_unlock:
+	spin_unlock(&vcpu->kvm->mmu_lock);
+	kvm_release_pfn_clean(pfn);
+	return 0;
 }
 
 static void nonpaging_free(struct kvm_vcpu *vcpu)
@@ -1643,11 +1771,11 @@ static void mmu_guess_page_from_pte_write(struct kvm_vcpu *vcpu, gpa_t gpa,
 	int r;
 	u64 gpte = 0;
 	pfn_t pfn;
-
-	vcpu->arch.update_pte.largepage = 0;
+	int mmu_seq;
+	int largepage;
 
 	if (bytes != 4 && bytes != 8)
-		return;
+		goto out_lock;
 
 	/*
 	 * Assume that the pte write on a page table of the same type
@@ -1660,7 +1788,7 @@ static void mmu_guess_page_from_pte_write(struct kvm_vcpu *vcpu, gpa_t gpa,
 		if ((bytes == 4) && (gpa % 4 == 0)) {
 			r = kvm_read_guest(vcpu->kvm, gpa & ~(u64)7, &gpte, 8);
 			if (r)
-				return;
+				goto out_lock;
 			memcpy((void *)&gpte + (gpa % 8), new, 4);
 		} else if ((bytes == 8) && (gpa % 8 == 0)) {
 			memcpy((void *)&gpte, new, 8);
@@ -1670,23 +1798,35 @@ static void mmu_guess_page_from_pte_write(struct kvm_vcpu *vcpu, gpa_t gpa,
 			memcpy((void *)&gpte, new, 4);
 	}
 	if (!is_present_pte(gpte))
-		return;
+		goto out_lock;
 	gfn = (gpte & PT64_BASE_ADDR_MASK) >> PAGE_SHIFT;
 
+	largepage = 0;
 	down_read(&current->mm->mmap_sem);
 	if (is_large_pte(gpte) && is_largepage_backed(vcpu, gfn)) {
 		gfn &= ~(KVM_PAGES_PER_HPAGE-1);
-		vcpu->arch.update_pte.largepage = 1;
+		largepage = 1;
 	}
+	mmu_seq = atomic_read(&vcpu->kvm->arch.mmu_notifier_seq);
+	/* implicit mb(), we'll read before PT lock is unlocked */
 	pfn = gfn_to_pfn(vcpu->kvm, gfn);
 	up_read(&current->mm->mmap_sem);
 
-	if (is_error_pfn(pfn)) {
-		kvm_release_pfn_clean(pfn);
-		return;
-	}
+	if (is_error_pfn(pfn))
+		goto out_release_and_lock;
+
+	spin_lock(&vcpu->kvm->mmu_lock);
+	BUG_ON(!is_error_pfn(vcpu->arch.update_pte.pfn));
 	vcpu->arch.update_pte.gfn = gfn;
 	vcpu->arch.update_pte.pfn = pfn;
+	vcpu->arch.update_pte.largepage = largepage;
+	vcpu->arch.update_pte.mmu_seq = mmu_seq;
+	return;
+
+out_release_and_lock:
+	kvm_release_pfn_clean(pfn);
+out_lock:
+	spin_lock(&vcpu->kvm->mmu_lock);
 }
 
 void kvm_mmu_pte_write(struct kvm_vcpu *vcpu, gpa_t gpa,
@@ -1711,7 +1851,6 @@ void kvm_mmu_pte_write(struct kvm_vcpu *vcpu, gpa_t gpa,
 
 	pgprintk("%s: gpa %llx bytes %d\n", __func__, gpa, bytes);
 	mmu_guess_page_from_pte_write(vcpu, gpa, new, bytes);
-	spin_lock(&vcpu->kvm->mmu_lock);
 	kvm_mmu_free_some_pages(vcpu);
 	++vcpu->kvm->stat.mmu_pte_write;
 	kvm_mmu_audit(vcpu, "pre pte write");
@@ -1790,11 +1929,11 @@ void kvm_mmu_pte_write(struct kvm_vcpu *vcpu, gpa_t gpa,
 		}
 	}
 	kvm_mmu_audit(vcpu, "post pte write");
-	spin_unlock(&vcpu->kvm->mmu_lock);
 	if (!is_error_pfn(vcpu->arch.update_pte.pfn)) {
 		kvm_release_pfn_clean(vcpu->arch.update_pte.pfn);
 		vcpu->arch.update_pte.pfn = bad_pfn;
 	}
+	spin_unlock(&vcpu->kvm->mmu_lock);
 }
 
 int kvm_mmu_unprotect_page_virt(struct kvm_vcpu *vcpu, gva_t gva)
diff --git a/arch/x86/kvm/paging_tmpl.h b/arch/x86/kvm/paging_tmpl.h
index 156fe10..4ac73a6 100644
--- a/arch/x86/kvm/paging_tmpl.h
+++ b/arch/x86/kvm/paging_tmpl.h
@@ -263,6 +263,12 @@ static void FNAME(update_pte)(struct kvm_vcpu *vcpu, struct kvm_mmu_page *page,
 	pfn = vcpu->arch.update_pte.pfn;
 	if (is_error_pfn(pfn))
 		return;
+	if (unlikely(atomic_read(&vcpu->kvm->arch.mmu_notifier_count)))
+		return;
+	smp_rmb();
+	if (unlikely(atomic_read(&vcpu->kvm->arch.mmu_notifier_seq) !=
+		     vcpu->arch.update_pte.mmu_seq))
+		return;
 	kvm_get_pfn(pfn);
 	mmu_set_spte(vcpu, spte, page->role.access, pte_access, 0, 0,
 		     gpte & PT_DIRTY_MASK, NULL, largepage, gpte_to_gfn(gpte),
@@ -380,6 +386,7 @@ static int FNAME(page_fault)(struct kvm_vcpu *vcpu, gva_t addr,
 	int r;
 	pfn_t pfn;
 	int largepage = 0;
+	int mmu_seq;
 
 	pgprintk("%s: addr %lx err %x\n", __func__, addr, error_code);
 	kvm_mmu_audit(vcpu, "pre page fault");
@@ -413,6 +420,8 @@ static int FNAME(page_fault)(struct kvm_vcpu *vcpu, gva_t addr,
 			largepage = 1;
 		}
 	}
+	mmu_seq = atomic_read(&vcpu->kvm->arch.mmu_notifier_seq);
+	/* implicit mb(), we'll read before PT lock is unlocked */
 	pfn = gfn_to_pfn(vcpu->kvm, walker.gfn);
 	up_read(&current->mm->mmap_sem);
 
@@ -424,6 +433,11 @@ static int FNAME(page_fault)(struct kvm_vcpu *vcpu, gva_t addr,
 	}
 
 	spin_lock(&vcpu->kvm->mmu_lock);
+	if (unlikely(atomic_read(&vcpu->kvm->arch.mmu_notifier_count)))
+		goto out_unlock;
+	smp_rmb();
+	if (unlikely(atomic_read(&vcpu->kvm->arch.mmu_notifier_seq) != mmu_seq))
+		goto out_unlock;
 	kvm_mmu_free_some_pages(vcpu);
 	shadow_pte = FNAME(fetch)(vcpu, addr, &walker, user_fault, write_fault,
 				  largepage, &write_pt, pfn);
@@ -439,6 +453,11 @@ static int FNAME(page_fault)(struct kvm_vcpu *vcpu, gva_t addr,
 	spin_unlock(&vcpu->kvm->mmu_lock);
 
 	return write_pt;
+
+out_unlock:
+	spin_unlock(&vcpu->kvm->mmu_lock);
+	kvm_release_pfn_clean(pfn);
+	return 0;
 }
 
 static gpa_t FNAME(gva_to_gpa)(struct kvm_vcpu *vcpu, gva_t vaddr)
diff --git a/arch/x86/kvm/x86.c b/arch/x86/kvm/x86.c
index 0ce5563..860559a 100644
--- a/arch/x86/kvm/x86.c
+++ b/arch/x86/kvm/x86.c
@@ -27,6 +27,7 @@
 #include <linux/module.h>
 #include <linux/mman.h>
 #include <linux/highmem.h>
+#include <linux/mmu_notifier.h>
 
 #include <asm/uaccess.h>
 #include <asm/msr.h>
@@ -3859,15 +3860,152 @@ void kvm_arch_vcpu_uninit(struct kvm_vcpu *vcpu)
 	free_page((unsigned long)vcpu->arch.pio_data);
 }
 
+static inline struct kvm *mmu_notifier_to_kvm(struct mmu_notifier *mn)
+{
+	struct kvm_arch *kvm_arch;
+	kvm_arch = container_of(mn, struct kvm_arch, mmu_notifier);
+	return container_of(kvm_arch, struct kvm, arch);
+}
+
+static void kvm_mmu_notifier_invalidate_page(struct mmu_notifier *mn,
+					     struct mm_struct *mm,
+					     unsigned long address)
+{
+	struct kvm *kvm = mmu_notifier_to_kvm(mn);
+	/*
+	 * When ->invalidate_page runs, the linux pte has been zapped
+	 * already but the page is still allocated until
+	 * ->invalidate_page returns. So if we increase the sequence
+	 * here the kvm page fault will notice if the spte can't be
+	 * established because the page is going to be freed. If
+	 * instead the kvm page fault establishes the spte before
+	 * ->invalidate_page runs, kvm_unmap_hva will release it
+	 * before returning.
+
+	 * No need of memory barriers as the sequence increase only
+	 * need to be seen at spin_unlock time, and not at spin_lock
+	 * time.
+	 *
+	 * Increasing the sequence after the spin_unlock would be
+	 * unsafe because the kvm page fault could then establish the
+	 * pte after kvm_unmap_hva returned, without noticing the page
+	 * is going to be freed.
+	 */
+	atomic_inc(&kvm->arch.mmu_notifier_seq);
+	spin_lock(&kvm->mmu_lock);
+	kvm_unmap_hva(kvm, address);
+	spin_unlock(&kvm->mmu_lock);
+}
+
+static void kvm_mmu_notifier_invalidate_range_start(struct mmu_notifier *mn,
+						    struct mm_struct *mm,
+						    unsigned long start,
+						    unsigned long end)
+{
+	struct kvm *kvm = mmu_notifier_to_kvm(mn);
+
+	/*
+	 * The count increase must become visible at unlock time as no
+	 * spte can be established without taking the mmu_lock and
+	 * count is also read inside the mmu_lock critical section.
+	 */
+	atomic_inc(&kvm->arch.mmu_notifier_count);
+
+	spin_lock(&kvm->mmu_lock);
+	for (; start < end; start += PAGE_SIZE)
+		kvm_unmap_hva(kvm, start);
+	spin_unlock(&kvm->mmu_lock);
+}
+
+static void kvm_mmu_notifier_invalidate_range_end(struct mmu_notifier *mn,
+						  struct mm_struct *mm,
+						  unsigned long start,
+						  unsigned long end)
+{
+	struct kvm *kvm = mmu_notifier_to_kvm(mn);
+	/*
+	 *
+	 * This sequence increase will notify the kvm page fault that
+	 * the page that is going to be mapped in the spte could have
+	 * been freed.
+	 *
+	 * There's also an implicit mb() here in this comment,
+	 * provided by the last PT lock taken to zap pagetables, and
+	 * that the read side has to take too in follow_page(). The
+	 * sequence increase in the worst case will become visible to
+	 * the kvm page fault after the spin_lock of the last PT lock
+	 * of the last PT-lock-protected critical section preceeding
+	 * invalidate_range_end. So if the kvm page fault is about to
+	 * establish the spte inside the mmu_lock, while we're freeing
+	 * the pages, it will have to backoff and when it retries, it
+	 * will have to take the PT lock before it can check the
+	 * pagetables again. And after taking the PT lock it will
+	 * re-establish the pte even if it will see the already
+	 * increased sequence number before calling gfn_to_pfn.
+	 */
+	atomic_inc(&kvm->arch.mmu_notifier_seq);
+	/*
+	 * The sequence increase must be visible before count
+	 * decrease. The page fault has to read count before sequence
+	 * for this write order to be effective.
+	 */
+	wmb();
+	atomic_dec(&kvm->arch.mmu_notifier_count);
+	BUG_ON(atomic_read(&kvm->arch.mmu_notifier_count) < 0);
+}
+
+static int kvm_mmu_notifier_clear_flush_young(struct mmu_notifier *mn,
+					      struct mm_struct *mm,
+					      unsigned long address)
+{
+	struct kvm *kvm = mmu_notifier_to_kvm(mn);
+	return kvm_age_hva(kvm, address);
+}
+
+static void kvm_free_vcpus(struct kvm *kvm);
+/* This must zap all the sptes because all pages will be freed then */
+static void kvm_mmu_notifier_release(struct mmu_notifier *mn,
+				     struct mm_struct *mm)
+{
+	struct kvm *kvm = mmu_notifier_to_kvm(mn);
+	BUG_ON(mm != kvm->mm);
+
+	kvm_destroy_common_vm(kvm);
+
+	kvm_free_pit(kvm);
+	kfree(kvm->arch.vpic);
+	kfree(kvm->arch.vioapic);
+	kvm_free_vcpus(kvm);
+	kvm_free_physmem(kvm);
+	if (kvm->arch.apic_access_page)
+		put_page(kvm->arch.apic_access_page);
+}
+
+static const struct mmu_notifier_ops kvm_mmu_notifier_ops = {
+	.release		= kvm_mmu_notifier_release,
+	.invalidate_page	= kvm_mmu_notifier_invalidate_page,
+	.invalidate_range_start	= kvm_mmu_notifier_invalidate_range_start,
+	.invalidate_range_end	= kvm_mmu_notifier_invalidate_range_end,
+	.clear_flush_young	= kvm_mmu_notifier_clear_flush_young,
+};
+
 struct  kvm *kvm_arch_create_vm(void)
 {
 	struct kvm *kvm = kzalloc(sizeof(struct kvm), GFP_KERNEL);
+	int err;
 
 	if (!kvm)
 		return ERR_PTR(-ENOMEM);
 
 	INIT_LIST_HEAD(&kvm->arch.active_mmu_pages);
 
+	kvm->arch.mmu_notifier.ops = &kvm_mmu_notifier_ops;
+	err = mmu_notifier_register(&kvm->arch.mmu_notifier, current->mm);
+	if (err) {
+		kfree(kvm);
+		return ERR_PTR(err);
+	}
+
 	return kvm;
 }
 
@@ -3899,13 +4037,12 @@ static void kvm_free_vcpus(struct kvm *kvm)
 
 void kvm_arch_destroy_vm(struct kvm *kvm)
 {
-	kvm_free_pit(kvm);
-	kfree(kvm->arch.vpic);
-	kfree(kvm->arch.vioapic);
-	kvm_free_vcpus(kvm);
-	kvm_free_physmem(kvm);
-	if (kvm->arch.apic_access_page)
-		put_page(kvm->arch.apic_access_page);
+	/*
+	 * kvm_mmu_notifier_release() will be called before
+	 * mmu_notifier_unregister returns, if it didn't run
+	 * already.
+	 */
+	mmu_notifier_unregister(&kvm->arch.mmu_notifier, kvm->mm);
 	kfree(kvm);
 }
 
diff --git a/include/asm-x86/kvm_host.h b/include/asm-x86/kvm_host.h
index 9d963cd..f07e321 100644
--- a/include/asm-x86/kvm_host.h
+++ b/include/asm-x86/kvm_host.h
@@ -13,6 +13,7 @@
 
 #include <linux/types.h>
 #include <linux/mm.h>
+#include <linux/mmu_notifier.h>
 
 #include <linux/kvm.h>
 #include <linux/kvm_para.h>
@@ -247,6 +248,7 @@ struct kvm_vcpu_arch {
 		gfn_t gfn;	/* presumed gfn during guest pte update */
 		pfn_t pfn;	/* pfn corresponding to that gfn */
 		int largepage;
+		int mmu_seq;
 	} update_pte;
 
 	struct i387_fxsave_struct host_fx_image;
@@ -314,6 +316,10 @@ struct kvm_arch{
 	struct page *apic_access_page;
 
 	gpa_t wall_clock;
+
+	struct mmu_notifier mmu_notifier;
+	atomic_t mmu_notifier_seq;
+	atomic_t mmu_notifier_count;
 };
 
 struct kvm_vm_stat {
@@ -434,6 +440,8 @@ int kvm_mmu_create(struct kvm_vcpu *vcpu);
 int kvm_mmu_setup(struct kvm_vcpu *vcpu);
 void kvm_mmu_set_nonpresent_ptes(u64 trap_pte, u64 notrap_pte);
 
+void kvm_unmap_hva(struct kvm *kvm, unsigned long hva);
+int kvm_age_hva(struct kvm *kvm, unsigned long hva);
 int kvm_mmu_reset_context(struct kvm_vcpu *vcpu);
 void kvm_mmu_slot_remove_write_access(struct kvm *kvm, int slot);
 void kvm_mmu_zap_all(struct kvm *kvm);
diff --git a/include/linux/kvm_host.h b/include/linux/kvm_host.h
index 4e16682..f089edc 100644
--- a/include/linux/kvm_host.h
+++ b/include/linux/kvm_host.h
@@ -267,6 +267,7 @@ void kvm_arch_check_processor_compat(void *rtn);
 int kvm_arch_vcpu_runnable(struct kvm_vcpu *vcpu);
 
 void kvm_free_physmem(struct kvm *kvm);
+void kvm_destroy_common_vm(struct kvm *kvm);
 
 struct  kvm *kvm_arch_create_vm(void);
 void kvm_arch_destroy_vm(struct kvm *kvm);
diff --git a/virt/kvm/kvm_main.c b/virt/kvm/kvm_main.c
index f095b73..4beae7a 100644
--- a/virt/kvm/kvm_main.c
+++ b/virt/kvm/kvm_main.c
@@ -231,15 +231,19 @@ void kvm_free_physmem(struct kvm *kvm)
 		kvm_free_physmem_slot(&kvm->memslots[i], NULL);
 }
 
-static void kvm_destroy_vm(struct kvm *kvm)
+void kvm_destroy_common_vm(struct kvm *kvm)
 {
-	struct mm_struct *mm = kvm->mm;
-
 	spin_lock(&kvm_lock);
 	list_del(&kvm->vm_list);
 	spin_unlock(&kvm_lock);
 	kvm_io_bus_destroy(&kvm->pio_bus);
 	kvm_io_bus_destroy(&kvm->mmio_bus);
+}
+
+static void kvm_destroy_vm(struct kvm *kvm)
+{
+	struct mm_struct *mm = kvm->mm;
+
 	kvm_arch_destroy_vm(kvm);
 	mmdrop(mm);
 }


As usual you also need the kvm-mmu-notifier-lock patch to read the
memslots with only the mmu_lock.

Signed-off-by: Andrea Arcangeli <andrea@qumranet.com>

diff --git a/arch/x86/kvm/x86.c b/arch/x86/kvm/x86.c
index c7ad235..8be6551 100644
--- a/arch/x86/kvm/x86.c
+++ b/arch/x86/kvm/x86.c
@@ -3871,16 +3871,23 @@ int kvm_arch_set_memory_region(struct kvm *kvm,
 	 */
 	if (!user_alloc) {
 		if (npages && !old.rmap) {
+			unsigned long userspace_addr;
+
 			down_write(&current->mm->mmap_sem);
-			memslot->userspace_addr = do_mmap(NULL, 0,
-						     npages * PAGE_SIZE,
-						     PROT_READ | PROT_WRITE,
-						     MAP_SHARED | MAP_ANONYMOUS,
-						     0);
+			userspace_addr = do_mmap(NULL, 0,
+						 npages * PAGE_SIZE,
+						 PROT_READ | PROT_WRITE,
+						 MAP_SHARED | MAP_ANONYMOUS,
+						 0);
 			up_write(&current->mm->mmap_sem);
 
-			if (IS_ERR((void *)memslot->userspace_addr))
-				return PTR_ERR((void *)memslot->userspace_addr);
+			if (IS_ERR((void *)userspace_addr))
+				return PTR_ERR((void *)userspace_addr);
+
+			/* set userspace_addr atomically for kvm_hva_to_rmapp */
+			spin_lock(&kvm->mmu_lock);
+			memslot->userspace_addr = userspace_addr;
+			spin_unlock(&kvm->mmu_lock);
 		} else {
 			if (!old.user_alloc && old.rmap) {
 				int ret;
diff --git a/virt/kvm/kvm_main.c b/virt/kvm/kvm_main.c
index 6a52c08..97bcc8d 100644
--- a/virt/kvm/kvm_main.c
+++ b/virt/kvm/kvm_main.c
@@ -342,7 +342,15 @@ int __kvm_set_memory_region(struct kvm *kvm,
 		memset(new.rmap, 0, npages * sizeof(*new.rmap));
 
 		new.user_alloc = user_alloc;
-		new.userspace_addr = mem->userspace_addr;
+		/*
+		 * hva_to_rmmap() serialzies with the mmu_lock and to be
+		 * safe it has to ignore memslots with !user_alloc &&
+		 * !userspace_addr.
+		 */
+		if (user_alloc)
+			new.userspace_addr = mem->userspace_addr;
+		else
+			new.userspace_addr = 0;
 	}
 	if (npages && !new.lpage_info) {
 		int largepages = npages / KVM_PAGES_PER_HPAGE;
@@ -374,14 +382,18 @@ int __kvm_set_memory_region(struct kvm *kvm,
 		memset(new.dirty_bitmap, 0, dirty_bytes);
 	}
 
+	spin_lock(&kvm->mmu_lock);
 	if (mem->slot >= kvm->nmemslots)
 		kvm->nmemslots = mem->slot + 1;
 
 	*memslot = new;
+	spin_unlock(&kvm->mmu_lock);
 
 	r = kvm_arch_set_memory_region(kvm, mem, old, user_alloc);
 	if (r) {
+		spin_lock(&kvm->mmu_lock);
 		*memslot = old;
+		spin_unlock(&kvm->mmu_lock);
 		goto out_free;
 	}
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
