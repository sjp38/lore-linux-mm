Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id A4D8290013A
	for <linux-mm@kvack.org>; Tue, 21 Jun 2011 09:33:06 -0400 (EDT)
Received: by iwn8 with SMTP id 8so2474870iwn.14
        for <linux-mm@kvack.org>; Tue, 21 Jun 2011 06:33:04 -0700 (PDT)
From: Nai Xia <nai.xia@gmail.com>
Reply-To: nai.xia@gmail.com
Subject: [PATCH] mmu_notifier, kvm: Introduce dirty bit tracking in spte and mmu notifier to help KSM dirty bit tracking
Date: Tue, 21 Jun 2011 21:32:39 +0800
References: <201106212055.25400.nai.xia@gmail.com>
In-Reply-To: <201106212055.25400.nai.xia@gmail.com>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Message-Id: <201106212132.39311.nai.xia@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Izik Eidus <izik.eidus@ravellosystems.com>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Chris Wright <chrisw@sous-sol.org>, Rik van Riel <riel@redhat.com>, linux-mm <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel <linux-kernel@vger.kernel.org>, kvm <kvm@vger.kernel.org>

Introduced kvm_mmu_notifier_test_and_clear_dirty(), kvm_mmu_notifier_dirty_update()
and their mmu_notifier interfaces to support KSM dirty bit tracking, which brings
significant performance gain in volatile pages scanning in KSM.
Currently, kvm_mmu_notifier_dirty_update() returns 0 if and only if intel EPT is
enabled to indicate that the dirty bits of underlying sptes are not updated by
hardware.

Signed-off-by: Nai Xia <nai.xia@gmail.com>
Acked-by: Izik Eidus <izik.eidus@ravellosystems.com>
---
 arch/x86/include/asm/kvm_host.h |    1 +
 arch/x86/kvm/mmu.c              |   36 +++++++++++++++++++++++++++++
 arch/x86/kvm/mmu.h              |    3 +-
 arch/x86/kvm/vmx.c              |    1 +
 include/linux/kvm_host.h        |    2 +-
 include/linux/mmu_notifier.h    |   48 +++++++++++++++++++++++++++++++++++++++
 mm/mmu_notifier.c               |   33 ++++++++++++++++++++++++++
 virt/kvm/kvm_main.c             |   27 ++++++++++++++++++++++
 8 files changed, 149 insertions(+), 2 deletions(-)

diff --git a/arch/x86/include/asm/kvm_host.h b/arch/x86/include/asm/kvm_host.h
index d2ac8e2..f0d7aa0 100644
--- a/arch/x86/include/asm/kvm_host.h
+++ b/arch/x86/include/asm/kvm_host.h
@@ -848,6 +848,7 @@ extern bool kvm_rebooting;
 int kvm_unmap_hva(struct kvm *kvm, unsigned long hva);
 int kvm_age_hva(struct kvm *kvm, unsigned long hva);
 int kvm_test_age_hva(struct kvm *kvm, unsigned long hva);
+int kvm_test_and_clear_dirty_hva(struct kvm *kvm, unsigned long hva);
 void kvm_set_spte_hva(struct kvm *kvm, unsigned long hva, pte_t pte);
 int cpuid_maxphyaddr(struct kvm_vcpu *vcpu);
 int kvm_cpu_has_interrupt(struct kvm_vcpu *vcpu);
diff --git a/arch/x86/kvm/mmu.c b/arch/x86/kvm/mmu.c
index aee3862..a5a0c51 100644
--- a/arch/x86/kvm/mmu.c
+++ b/arch/x86/kvm/mmu.c
@@ -979,6 +979,37 @@ out:
 	return young;
 }
 
+/*
+ * Caller is supposed to SetPageDirty(), it's not done inside this.
+ */
+static
+int kvm_test_and_clear_dirty_rmapp(struct kvm *kvm, unsigned long *rmapp,
+				   unsigned long data)
+{
+	u64 *spte;
+	int dirty = 0;
+
+	if (!shadow_dirty_mask) {
+		WARN(1, "KVM: do NOT try to test dirty bit in EPT\n");
+		goto out;
+	}
+
+	spte = rmap_next(kvm, rmapp, NULL);
+	while (spte) {
+		int _dirty;
+		u64 _spte = *spte;
+		BUG_ON(!(_spte & PT_PRESENT_MASK));
+		_dirty = _spte & PT_DIRTY_MASK;
+		if (_dirty) {
+			dirty = 1;
+			clear_bit(PT_DIRTY_SHIFT, (unsigned long *)spte);
+		}
+		spte = rmap_next(kvm, rmapp, spte);
+	}
+out:
+	return dirty;
+}
+
 #define RMAP_RECYCLE_THRESHOLD 1000
 
 static void rmap_recycle(struct kvm_vcpu *vcpu, u64 *spte, gfn_t gfn)
@@ -1004,6 +1035,11 @@ int kvm_test_age_hva(struct kvm *kvm, unsigned long hva)
 	return kvm_handle_hva(kvm, hva, 0, kvm_test_age_rmapp);
 }
 
+int kvm_test_and_clear_dirty_hva(struct kvm *kvm, unsigned long hva)
+{
+	return kvm_handle_hva(kvm, hva, 0, kvm_test_and_clear_dirty_rmapp);
+}
+
 #ifdef MMU_DEBUG
 static int is_empty_shadow_page(u64 *spt)
 {
diff --git a/arch/x86/kvm/mmu.h b/arch/x86/kvm/mmu.h
index 7086ca8..b8d01c3 100644
--- a/arch/x86/kvm/mmu.h
+++ b/arch/x86/kvm/mmu.h
@@ -18,7 +18,8 @@
 #define PT_PCD_MASK (1ULL << 4)
 #define PT_ACCESSED_SHIFT 5
 #define PT_ACCESSED_MASK (1ULL << PT_ACCESSED_SHIFT)
-#define PT_DIRTY_MASK (1ULL << 6)
+#define PT_DIRTY_SHIFT 6
+#define PT_DIRTY_MASK (1ULL << PT_DIRTY_SHIFT)
 #define PT_PAGE_SIZE_MASK (1ULL << 7)
 #define PT_PAT_MASK (1ULL << 7)
 #define PT_GLOBAL_MASK (1ULL << 8)
diff --git a/arch/x86/kvm/vmx.c b/arch/x86/kvm/vmx.c
index d48ec60..b407a69 100644
--- a/arch/x86/kvm/vmx.c
+++ b/arch/x86/kvm/vmx.c
@@ -4674,6 +4674,7 @@ static int __init vmx_init(void)
 		kvm_mmu_set_mask_ptes(0ull, 0ull, 0ull, 0ull,
 				VMX_EPT_EXECUTABLE_MASK);
 		kvm_enable_tdp();
+		kvm_dirty_update = 0;
 	} else
 		kvm_disable_tdp();
 
diff --git a/include/linux/kvm_host.h b/include/linux/kvm_host.h
index 31ebb59..2036bae 100644
--- a/include/linux/kvm_host.h
+++ b/include/linux/kvm_host.h
@@ -53,7 +53,7 @@
 struct kvm;
 struct kvm_vcpu;
 extern struct kmem_cache *kvm_vcpu_cache;
-
+extern int kvm_dirty_update;
 /*
  * It would be nice to use something smarter than a linear search, TBD...
  * Thankfully we dont expect many devices to register (famous last words :),
diff --git a/include/linux/mmu_notifier.h b/include/linux/mmu_notifier.h
index 1d1b1e1..bd6ba2d 100644
--- a/include/linux/mmu_notifier.h
+++ b/include/linux/mmu_notifier.h
@@ -24,6 +24,9 @@ struct mmu_notifier_mm {
 };
 
 struct mmu_notifier_ops {
+	int (*dirty_update)(struct mmu_notifier *mn,
+			     struct mm_struct *mm);
+
 	/*
 	 * Called either by mmu_notifier_unregister or when the mm is
 	 * being destroyed by exit_mmap, always before all pages are
@@ -72,6 +75,16 @@ struct mmu_notifier_ops {
 			  unsigned long address);
 
 	/*
+	 * clear_flush_dirty is called after the VM is
+	 * test-and-clearing the dirty/modified bitflag in the
+	 * pte. This way the VM will provide proper volatile page
+	 * testing to ksm.
+	 */
+	int (*test_and_clear_dirty)(struct mmu_notifier *mn,
+				    struct mm_struct *mm,
+				    unsigned long address);
+
+	/*
 	 * change_pte is called in cases that pte mapping to page is changed:
 	 * for example, when ksm remaps pte to point to a new shared page.
 	 */
@@ -170,11 +183,14 @@ extern int __mmu_notifier_register(struct mmu_notifier *mn,
 extern void mmu_notifier_unregister(struct mmu_notifier *mn,
 				    struct mm_struct *mm);
 extern void __mmu_notifier_mm_destroy(struct mm_struct *mm);
+extern int __mmu_notifier_dirty_update(struct mm_struct *mm);
 extern void __mmu_notifier_release(struct mm_struct *mm);
 extern int __mmu_notifier_clear_flush_young(struct mm_struct *mm,
 					  unsigned long address);
 extern int __mmu_notifier_test_young(struct mm_struct *mm,
 				     unsigned long address);
+extern int __mmu_notifier_test_and_clear_dirty(struct mm_struct *mm,
+					       unsigned long address);
 extern void __mmu_notifier_change_pte(struct mm_struct *mm,
 				      unsigned long address, pte_t pte);
 extern void __mmu_notifier_invalidate_page(struct mm_struct *mm,
@@ -184,6 +200,19 @@ extern void __mmu_notifier_invalidate_range_start(struct mm_struct *mm,
 extern void __mmu_notifier_invalidate_range_end(struct mm_struct *mm,
 				  unsigned long start, unsigned long end);
 
+/*
+ * For ksm to make use of dirty bit, it wants to make sure that the dirty bits
+ * in sptes really carry the dirty information. Currently only intel EPT is
+ * not for ksm dirty bit tracking.
+ */
+static inline int mmu_notifier_dirty_update(struct mm_struct *mm)
+{
+	if (mm_has_notifiers(mm))
+		return __mmu_notifier_dirty_update(mm);
+
+	return 1;
+}
+
 static inline void mmu_notifier_release(struct mm_struct *mm)
 {
 	if (mm_has_notifiers(mm))
@@ -206,6 +235,14 @@ static inline int mmu_notifier_test_young(struct mm_struct *mm,
 	return 0;
 }
 
+static inline int mmu_notifier_test_and_clear_dirty(struct mm_struct *mm,
+						    unsigned long address)
+{
+	if (mm_has_notifiers(mm))
+		return __mmu_notifier_test_and_clear_dirty(mm, address);
+	return 0;
+}
+
 static inline void mmu_notifier_change_pte(struct mm_struct *mm,
 					   unsigned long address, pte_t pte)
 {
@@ -323,6 +360,11 @@ static inline void mmu_notifier_mm_destroy(struct mm_struct *mm)
 
 #else /* CONFIG_MMU_NOTIFIER */
 
+static inline int mmu_notifier_dirty_update(struct mm_struct *mm)
+{
+	return 1;
+}
+
 static inline void mmu_notifier_release(struct mm_struct *mm)
 {
 }
@@ -339,6 +381,12 @@ static inline int mmu_notifier_test_young(struct mm_struct *mm,
 	return 0;
 }
 
+static inline int mmu_notifier_test_and_clear_dirty(struct mm_struct *mm,
+						    unsigned long address)
+{
+	return 0;
+}
+
 static inline void mmu_notifier_change_pte(struct mm_struct *mm,
 					   unsigned long address, pte_t pte)
 {
diff --git a/mm/mmu_notifier.c b/mm/mmu_notifier.c
index 8d032de..a4a1467 100644
--- a/mm/mmu_notifier.c
+++ b/mm/mmu_notifier.c
@@ -18,6 +18,22 @@
 #include <linux/sched.h>
 #include <linux/slab.h>
 
+int __mmu_notifier_dirty_update(struct mm_struct *mm)
+{
+	struct mmu_notifier *mn;
+	struct hlist_node *n;
+	int dirty_update = 0;
+
+	rcu_read_lock();
+	hlist_for_each_entry_rcu(mn, n, &mm->mmu_notifier_mm->list, hlist) {
+		if (mn->ops->dirty_update)
+			dirty_update |= mn->ops->dirty_update(mn, mm);
+	}
+	rcu_read_unlock();
+
+	return dirty_update;
+}
+
 /*
  * This function can't run concurrently against mmu_notifier_register
  * because mm->mm_users > 0 during mmu_notifier_register and exit_mmap
@@ -120,6 +136,23 @@ int __mmu_notifier_test_young(struct mm_struct *mm,
 	return young;
 }
 
+int __mmu_notifier_test_and_clear_dirty(struct mm_struct *mm,
+					unsigned long address)
+{
+	struct mmu_notifier *mn;
+	struct hlist_node *n;
+	int dirty = 0;
+
+	rcu_read_lock();
+	hlist_for_each_entry_rcu(mn, n, &mm->mmu_notifier_mm->list, hlist) {
+		if (mn->ops->test_and_clear_dirty)
+			dirty |= mn->ops->test_and_clear_dirty(mn, mm, address);
+	}
+	rcu_read_unlock();
+
+	return dirty;
+}
+
 void __mmu_notifier_change_pte(struct mm_struct *mm, unsigned long address,
 			       pte_t pte)
 {
diff --git a/virt/kvm/kvm_main.c b/virt/kvm/kvm_main.c
index 96ebc06..22967c8 100644
--- a/virt/kvm/kvm_main.c
+++ b/virt/kvm/kvm_main.c
@@ -78,6 +78,8 @@ static atomic_t hardware_enable_failed;
 struct kmem_cache *kvm_vcpu_cache;
 EXPORT_SYMBOL_GPL(kvm_vcpu_cache);
 
+int kvm_dirty_update = 1;
+
 static __read_mostly struct preempt_ops kvm_preempt_ops;
 
 struct dentry *kvm_debugfs_dir;
@@ -398,6 +400,23 @@ static int kvm_mmu_notifier_test_young(struct mmu_notifier *mn,
 	return young;
 }
 
+/* Caller should SetPageDirty(), no need to flush tlb */
+static int kvm_mmu_notifier_test_and_clear_dirty(struct mmu_notifier *mn,
+						 struct mm_struct *mm,
+						 unsigned long address)
+{
+	struct kvm *kvm = mmu_notifier_to_kvm(mn);
+	int dirty, idx;
+
+	idx = srcu_read_lock(&kvm->srcu);
+	spin_lock(&kvm->mmu_lock);
+	dirty = kvm_test_and_clear_dirty_hva(kvm, address);
+	spin_unlock(&kvm->mmu_lock);
+	srcu_read_unlock(&kvm->srcu, idx);
+
+	return dirty;
+}
+
 static void kvm_mmu_notifier_release(struct mmu_notifier *mn,
 				     struct mm_struct *mm)
 {
@@ -409,14 +428,22 @@ static void kvm_mmu_notifier_release(struct mmu_notifier *mn,
 	srcu_read_unlock(&kvm->srcu, idx);
 }
 
+static int kvm_mmu_notifier_dirty_update(struct mmu_notifier *mn,
+					 struct mm_struct *mm)
+{
+	return kvm_dirty_update;
+}
+
 static const struct mmu_notifier_ops kvm_mmu_notifier_ops = {
 	.invalidate_page	= kvm_mmu_notifier_invalidate_page,
 	.invalidate_range_start	= kvm_mmu_notifier_invalidate_range_start,
 	.invalidate_range_end	= kvm_mmu_notifier_invalidate_range_end,
 	.clear_flush_young	= kvm_mmu_notifier_clear_flush_young,
 	.test_young		= kvm_mmu_notifier_test_young,
+	.test_and_clear_dirty	= kvm_mmu_notifier_test_and_clear_dirty,
 	.change_pte		= kvm_mmu_notifier_change_pte,
 	.release		= kvm_mmu_notifier_release,
+	.dirty_update		= kvm_mmu_notifier_dirty_update,
 };
 
 static int kvm_init_mmu_notifier(struct kvm *kvm)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
