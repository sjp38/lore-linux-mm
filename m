Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 9215A6B005C
	for <linux-mm@kvack.org>; Mon, 30 Mar 2009 20:01:12 -0400 (EDT)
From: Izik Eidus <ieidus@redhat.com>
Subject: [PATCH 3/3] kvm: add support for change_pte mmu notifiers
Date: Tue, 31 Mar 2009 03:00:04 +0300
Message-Id: <1238457604-7637-4-git-send-email-ieidus@redhat.com>
In-Reply-To: <1238457604-7637-3-git-send-email-ieidus@redhat.com>
References: <1238457604-7637-1-git-send-email-ieidus@redhat.com>
 <1238457604-7637-2-git-send-email-ieidus@redhat.com>
 <1238457604-7637-3-git-send-email-ieidus@redhat.com>
Sender: owner-linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, kvm@vger.kernel.org, linux-mm@kvack.org, avi@redhat.com, aarcange@redhat.com, chrisw@redhat.com, riel@redhat.com, jeremy@goop.org, mtosatti@redhat.com, hugh@veritas.com, corbet@lwn.net, yaniv@redhat.com, dmonakhov@openvz.org, Izik Eidus <ieidus@redhat.com>
List-ID: <linux-mm.kvack.org>

this is needed for kvm if it want ksm to directly map pages into its
shadow page tables.

Signed-off-by: Izik Eidus <ieidus@redhat.com>
---
 arch/x86/include/asm/kvm_host.h |    1 +
 arch/x86/kvm/mmu.c              |   68 +++++++++++++++++++++++++++++++++++----
 virt/kvm/kvm_main.c             |   14 ++++++++
 3 files changed, 76 insertions(+), 7 deletions(-)

diff --git a/arch/x86/include/asm/kvm_host.h b/arch/x86/include/asm/kvm_host.h
index 8351c4d..9062729 100644
--- a/arch/x86/include/asm/kvm_host.h
+++ b/arch/x86/include/asm/kvm_host.h
@@ -791,5 +791,6 @@ asmlinkage void kvm_handle_fault_on_reboot(void);
 #define KVM_ARCH_WANT_MMU_NOTIFIER
 int kvm_unmap_hva(struct kvm *kvm, unsigned long hva);
 int kvm_age_hva(struct kvm *kvm, unsigned long hva);
+void kvm_set_spte_hva(struct kvm *kvm, unsigned long hva, pte_t pte);
 
 #endif /* _ASM_X86_KVM_HOST_H */
diff --git a/arch/x86/kvm/mmu.c b/arch/x86/kvm/mmu.c
index 6b4d795..f8816dd 100644
--- a/arch/x86/kvm/mmu.c
+++ b/arch/x86/kvm/mmu.c
@@ -257,6 +257,11 @@ static pfn_t spte_to_pfn(u64 pte)
 	return (pte & PT64_BASE_ADDR_MASK) >> PAGE_SHIFT;
 }
 
+static pte_t ptep_val(pte_t *ptep)
+{
+	return *ptep;
+}
+
 static gfn_t pse36_gfn_delta(u32 gpte)
 {
 	int shift = 32 - PT32_DIR_PSE36_SHIFT - PAGE_SHIFT;
@@ -678,7 +683,8 @@ static int rmap_write_protect(struct kvm *kvm, u64 gfn)
 	return write_protected;
 }
 
-static int kvm_unmap_rmapp(struct kvm *kvm, unsigned long *rmapp)
+static int kvm_unmap_rmapp(struct kvm *kvm, unsigned long *rmapp,
+			   unsigned long data)
 {
 	u64 *spte;
 	int need_tlb_flush = 0;
@@ -693,8 +699,48 @@ static int kvm_unmap_rmapp(struct kvm *kvm, unsigned long *rmapp)
 	return need_tlb_flush;
 }
 
+static int kvm_set_pte_rmapp(struct kvm *kvm, unsigned long *rmapp,
+			     unsigned long data)
+{
+	int need_flush = 0;
+	u64 *spte, new_spte;
+	pte_t *ptep = (pte_t *)data;
+	pfn_t new_pfn;
+
+	new_pfn = pte_pfn(ptep_val(ptep));
+	spte = rmap_next(kvm, rmapp, NULL);
+	while (spte) {
+		BUG_ON(!is_shadow_present_pte(*spte));
+		rmap_printk("kvm_set_pte_rmapp: spte %p %llx\n", spte, *spte);
+		need_flush = 1;
+		if (pte_write(ptep_val(ptep))) {
+			rmap_remove(kvm, spte);
+			set_shadow_pte(spte, shadow_trap_nonpresent_pte);
+			spte = rmap_next(kvm, rmapp, NULL);
+		} else {
+			new_spte = *spte &~ (PT64_BASE_ADDR_MASK);
+			new_spte |= new_pfn << PAGE_SHIFT;
+
+			if (!pte_write(ptep_val(ptep))) {
+				new_spte &= ~PT_WRITABLE_MASK;
+				new_spte &= ~SPTE_HOST_WRITEABLE;
+				if (is_writeble_pte(*spte))
+					kvm_set_pfn_dirty(spte_to_pfn(*spte));
+			}
+			set_shadow_pte(spte, new_spte);
+			spte = rmap_next(kvm, rmapp, spte);
+		}
+	}
+	if (need_flush)
+		kvm_flush_remote_tlbs(kvm);
+
+	return 0;
+}
+
 static int kvm_handle_hva(struct kvm *kvm, unsigned long hva,
-			  int (*handler)(struct kvm *kvm, unsigned long *rmapp))
+			  unsigned long data,
+			  int (*handler)(struct kvm *kvm, unsigned long *rmapp,
+					 unsigned long data))
 {
 	int i;
 	int retval = 0;
@@ -715,11 +761,13 @@ static int kvm_handle_hva(struct kvm *kvm, unsigned long hva,
 		end = start + (memslot->npages << PAGE_SHIFT);
 		if (hva >= start && hva < end) {
 			gfn_t gfn_offset = (hva - start) >> PAGE_SHIFT;
-			retval |= handler(kvm, &memslot->rmap[gfn_offset]);
+			retval |= handler(kvm, &memslot->rmap[gfn_offset],
+					  data);
 			retval |= handler(kvm,
 					  &memslot->lpage_info[
 						  gfn_offset /
-						  KVM_PAGES_PER_HPAGE].rmap_pde);
+						  KVM_PAGES_PER_HPAGE].rmap_pde,
+						  data);
 		}
 	}
 
@@ -728,10 +776,16 @@ static int kvm_handle_hva(struct kvm *kvm, unsigned long hva,
 
 int kvm_unmap_hva(struct kvm *kvm, unsigned long hva)
 {
-	return kvm_handle_hva(kvm, hva, kvm_unmap_rmapp);
+	return kvm_handle_hva(kvm, hva, 0, kvm_unmap_rmapp);
+}
+
+void kvm_set_spte_hva(struct kvm *kvm, unsigned long hva, pte_t pte)
+{
+	kvm_handle_hva(kvm, hva, (unsigned long)&pte, kvm_set_pte_rmapp);
 }
 
-static int kvm_age_rmapp(struct kvm *kvm, unsigned long *rmapp)
+static int kvm_age_rmapp(struct kvm *kvm, unsigned long *rmapp,
+			 unsigned long data)
 {
 	u64 *spte;
 	int young = 0;
@@ -757,7 +811,7 @@ static int kvm_age_rmapp(struct kvm *kvm, unsigned long *rmapp)
 
 int kvm_age_hva(struct kvm *kvm, unsigned long hva)
 {
-	return kvm_handle_hva(kvm, hva, kvm_age_rmapp);
+	return kvm_handle_hva(kvm, hva, 0, kvm_age_rmapp);
 }
 
 #ifdef MMU_DEBUG
diff --git a/virt/kvm/kvm_main.c b/virt/kvm/kvm_main.c
index 8aa3b95..3d340e9 100644
--- a/virt/kvm/kvm_main.c
+++ b/virt/kvm/kvm_main.c
@@ -846,6 +846,19 @@ static void kvm_mmu_notifier_invalidate_page(struct mmu_notifier *mn,
 
 }
 
+static void kvm_mmu_notifier_change_pte(struct mmu_notifier *mn,
+					struct mm_struct *mm,
+					unsigned long address,
+					pte_t pte)
+{
+	struct kvm *kvm = mmu_notifier_to_kvm(mn);
+
+	spin_lock(&kvm->mmu_lock);
+	kvm->mmu_notifier_seq++;
+	kvm_set_spte_hva(kvm, address, pte);
+	spin_unlock(&kvm->mmu_lock);
+}
+
 static void kvm_mmu_notifier_invalidate_range_start(struct mmu_notifier *mn,
 						    struct mm_struct *mm,
 						    unsigned long start,
@@ -925,6 +938,7 @@ static const struct mmu_notifier_ops kvm_mmu_notifier_ops = {
 	.invalidate_range_start	= kvm_mmu_notifier_invalidate_range_start,
 	.invalidate_range_end	= kvm_mmu_notifier_invalidate_range_end,
 	.clear_flush_young	= kvm_mmu_notifier_clear_flush_young,
+	.change_pte		= kvm_mmu_notifier_change_pte,
 	.release		= kvm_mmu_notifier_release,
 };
 #endif /* CONFIG_MMU_NOTIFIER && KVM_ARCH_WANT_MMU_NOTIFIER */
-- 
1.5.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
