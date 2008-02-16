Date: Sat, 16 Feb 2008 11:48:27 +0100
From: Andrea Arcangeli <andrea@qumranet.com>
Subject: [PATCH] KVM swapping with MMU Notifiers V7
Message-ID: <20080216104827.GI11732@v2.random>
References: <20080215064859.384203497@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080215064859.384203497@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@linux-foundation.org, Robin Holt <holt@sgi.com>, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, kvm-devel@lists.sourceforge.net, Peter Zijlstra <a.p.zijlstra@chello.nl>, general@lists.openfabrics.org, Steve Wise <swise@opengridcomputing.com>, Roland Dreier <rdreier@cisco.com>, Kanoj Sarcar <kanojsarcar@yahoo.com>, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com
List-ID: <linux-mm.kvack.org>

Those below two patches enable KVM to swap the guest physical memory
through Christoph's V7.

There's one last _purely_theoretical_ race condition I figured out and
that I'm wondering how to best fix. The race condition worst case is
that a few guest physical pages could remain pinned by sptes. The race
can materialize if the linux pte is zapped after get_user_pages
returns but before the page is mapped by the spte and tracked by
rmap. The invalidate_ calls can also likely be optimized further but
it's not a fast path so it's not urgent.

Signed-off-by: Andrea Arcangeli <andrea@qumranet.com>

diff --git a/arch/x86/kvm/Kconfig b/arch/x86/kvm/Kconfig
index 41962e7..e1287ab 100644
--- a/arch/x86/kvm/Kconfig
+++ b/arch/x86/kvm/Kconfig
@@ -21,6 +21,7 @@ config KVM
 	tristate "Kernel-based Virtual Machine (KVM) support"
 	depends on HAVE_KVM && EXPERIMENTAL
 	select PREEMPT_NOTIFIERS
+	select MMU_NOTIFIER
 	select ANON_INODES
 	---help---
 	  Support hosting fully virtualized guest machines using hardware
diff --git a/arch/x86/kvm/mmu.c b/arch/x86/kvm/mmu.c
index fd39cd1..b56e388 100644
--- a/arch/x86/kvm/mmu.c
+++ b/arch/x86/kvm/mmu.c
@@ -533,6 +533,110 @@ static void rmap_write_protect(struct kvm *kvm, u64 gfn)
 		kvm_flush_remote_tlbs(kvm);
 }
 
+static void kvm_unmap_spte(struct kvm *kvm, u64 *spte)
+{
+	struct page *page = pfn_to_page((*spte & PT64_BASE_ADDR_MASK) >> PAGE_SHIFT);
+	get_page(page);
+	rmap_remove(kvm, spte);
+	set_shadow_pte(spte, shadow_trap_nonpresent_pte);
+	kvm_flush_remote_tlbs(kvm);
+	__free_page(page);
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
+			kvm_unmap_rmapp(kvm, &memslot->rmap[gfn_offset]);
+		}
+	}
+	spin_unlock(&kvm->mmu_lock);
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
diff --git a/arch/x86/kvm/x86.c b/arch/x86/kvm/x86.c
index 0c910c7..2b2398f 100644
--- a/arch/x86/kvm/x86.c
+++ b/arch/x86/kvm/x86.c
@@ -3185,6 +3185,46 @@ void kvm_arch_vcpu_uninit(struct kvm_vcpu *vcpu)
 	free_page((unsigned long)vcpu->arch.pio_data);
 }
 
+static inline struct kvm *mmu_notifier_to_kvm(struct mmu_notifier *mn)
+{
+	struct kvm_arch *kvm_arch;
+	kvm_arch = container_of(mn, struct kvm_arch, mmu_notifier);
+	return container_of(kvm_arch, struct kvm, arch);
+}
+
+void kvm_mmu_notifier_invalidate_page(struct mmu_notifier *mn,
+				      struct mm_struct *mm,
+				      unsigned long address)
+{
+	struct kvm *kvm = mmu_notifier_to_kvm(mn);
+	BUG_ON(mm != kvm->mm);
+	kvm_unmap_hva(kvm, address);
+}
+
+int kvm_mmu_notifier_age_page(struct mmu_notifier *mn,
+			      struct mm_struct *mm,
+			      unsigned long address)
+{
+	struct kvm *kvm = mmu_notifier_to_kvm(mn);
+	BUG_ON(mm != kvm->mm);
+	return kvm_age_hva(kvm, address);
+}
+
+void kvm_mmu_notifier_invalidate_range_end(struct mmu_notifier *mn,
+					   struct mm_struct *mm,
+					   unsigned long start, unsigned long end,
+					   int lock)
+{
+	for (; start < end; start += PAGE_SIZE)
+		kvm_mmu_notifier_invalidate_page(mn, mm, start);
+}
+
+static const struct mmu_notifier_ops kvm_mmu_notifier_ops = {
+	.invalidate_page	= kvm_mmu_notifier_invalidate_page,
+	.age_page		= kvm_mmu_notifier_age_page,
+	.invalidate_range_end	= kvm_mmu_notifier_invalidate_range_end,
+};
+
 struct  kvm *kvm_arch_create_vm(void)
 {
 	struct kvm *kvm = kzalloc(sizeof(struct kvm), GFP_KERNEL);
@@ -3194,6 +3234,9 @@ struct  kvm *kvm_arch_create_vm(void)
 
 	INIT_LIST_HEAD(&kvm->arch.active_mmu_pages);
 
+	kvm->arch.mmu_notifier.ops = &kvm_mmu_notifier_ops;
+	mmu_notifier_register(&kvm->arch.mmu_notifier, current->mm);
+
 	return kvm;
 }
 
diff --git a/include/asm-x86/kvm_host.h b/include/asm-x86/kvm_host.h
index da61255..11976c8 100644
--- a/include/asm-x86/kvm_host.h
+++ b/include/asm-x86/kvm_host.h
@@ -13,6 +13,7 @@
 
 #include <linux/types.h>
 #include <linux/mm.h>
+#include <linux/mmu_notifier.h>
 
 #include <linux/kvm.h>
 #include <linux/kvm_para.h>
@@ -287,6 +288,8 @@ struct kvm_arch{
 	int round_robin_prev_vcpu;
 	unsigned int tss_addr;
 	struct page *apic_access_page;
+
+	struct mmu_notifier mmu_notifier;
 };
 
 struct kvm_vm_stat {
@@ -404,6 +407,8 @@ int kvm_mmu_create(struct kvm_vcpu *vcpu);
 int kvm_mmu_setup(struct kvm_vcpu *vcpu);
 void kvm_mmu_set_nonpresent_ptes(u64 trap_pte, u64 notrap_pte);
 
+void kvm_unmap_hva(struct kvm *kvm, unsigned long hva);
+int kvm_age_hva(struct kvm *kvm, unsigned long hva);
 int kvm_mmu_reset_context(struct kvm_vcpu *vcpu);
 void kvm_mmu_slot_remove_write_access(struct kvm *kvm, int slot);
 void kvm_mmu_zap_all(struct kvm *kvm);


This allows to browse the memslots with only the mmu_lock hold and
it should be applied along the above patch:

Signed-off-by: Andrea Arcangeli <andrea@qumranet.com>

diff --git a/arch/x86/kvm/x86.c b/arch/x86/kvm/x86.c
index 0c910c7..80b719d 100644
--- a/arch/x86/kvm/x86.c
+++ b/arch/x86/kvm/x86.c
@@ -3245,16 +3245,23 @@ int kvm_arch_set_memory_region(struct kvm *kvm,
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
index cf6df51..743c5c5 100644
--- a/virt/kvm/kvm_main.c
+++ b/virt/kvm/kvm_main.c
@@ -299,7 +299,15 @@ int __kvm_set_memory_region(struct kvm *kvm,
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
 
 	/* Allocate page dirty bitmap if needed */
@@ -312,14 +320,18 @@ int __kvm_set_memory_region(struct kvm *kvm,
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
