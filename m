From: Izik Eidus <ieidus@redhat.com>
Subject: [PATCH 4/4] MMU_NOTIFIRES: add set_pte_at_notify()
Date: Mon, 17 Nov 2008 04:20:32 +0200
Message-Id: <1226888432-3662-5-git-send-email-ieidus@redhat.com>
In-Reply-To: <1226888432-3662-4-git-send-email-ieidus@redhat.com>
References: <1226888432-3662-1-git-send-email-ieidus@redhat.com>
 <1226888432-3662-2-git-send-email-ieidus@redhat.com>
 <1226888432-3662-3-git-send-email-ieidus@redhat.com>
 <1226888432-3662-4-git-send-email-ieidus@redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kvm@vger.kernel.org, aarcange@redhat.com, chrisw@redhat.com, avi@redhat.com, dlaor@redhat.com, kamezawa.hiroyu@jp.fujitsu.com, cl@linux-foundation.org, corbet@lwn.net, ieidus@redhat.com
List-ID: <linux-mm.kvack.org>

this macro allow setting the pte in the shadow page tables directly
instead of flushing the shadow page table entry and then get vmexit in
order to set it.

This function is optimzation for kvm/users of mmu_notifiers for COW
pages, it is useful for kvm when ksm is used beacuse it allow kvm
not to have to recive VMEXIT and only then map the shared page into
the mmu shadow pages, but instead map it directly at the same time
linux map the page into the host page table.

this mmu notifer macro is working by calling to callback that will map
directly the physical page into the shadow page tables.

(users of mmu_notifiers that didnt implement the set_pte_at_notify()
call back will just recive the mmu_notifier_invalidate_page callback)

Signed-off-by: Izik Eidus <ieidus@redhat.com>
---
 arch/x86/include/asm/kvm_host.h |    1 +
 arch/x86/kvm/mmu.c              |   55 ++++++++++++++++++++++++++++++++++-----
 include/linux/mmu_notifier.h    |   34 ++++++++++++++++++++++++
 mm/memory.c                     |   12 ++++++--
 mm/mmu_notifier.c               |   20 ++++++++++++++
 virt/kvm/kvm_main.c             |   14 ++++++++++
 6 files changed, 126 insertions(+), 10 deletions(-)

diff --git a/arch/x86/include/asm/kvm_host.h b/arch/x86/include/asm/kvm_host.h
index 8346be8..f78bb8b 100644
--- a/arch/x86/include/asm/kvm_host.h
+++ b/arch/x86/include/asm/kvm_host.h
@@ -751,5 +751,6 @@ asmlinkage void kvm_handle_fault_on_reboot(void);
 #define KVM_ARCH_WANT_MMU_NOTIFIER
 int kvm_unmap_hva(struct kvm *kvm, unsigned long hva);
 int kvm_age_hva(struct kvm *kvm, unsigned long hva);
+void kvm_set_spte_hva(struct kvm *kvm, unsigned long hva, pte_t pte);
 
 #endif /* _ASM_X86_KVM_HOST_H */
diff --git a/arch/x86/kvm/mmu.c b/arch/x86/kvm/mmu.c
index f1983d9..2d8f87e 100644
--- a/arch/x86/kvm/mmu.c
+++ b/arch/x86/kvm/mmu.c
@@ -663,7 +663,8 @@ static void rmap_write_protect(struct kvm *kvm, u64 gfn)
 		kvm_flush_remote_tlbs(kvm);
 }
 
-static int kvm_unmap_rmapp(struct kvm *kvm, unsigned long *rmapp)
+static int kvm_unmap_rmapp(struct kvm *kvm, unsigned long *rmapp,
+			   unsigned long data)
 {
 	u64 *spte;
 	int need_tlb_flush = 0;
@@ -678,8 +679,41 @@ static int kvm_unmap_rmapp(struct kvm *kvm, unsigned long *rmapp)
 	return need_tlb_flush;
 }
 
+static int kvm_set_pte_rmapp(struct kvm *kvm, unsigned long *rmapp,
+			     unsigned long data)
+{
+	u64 *spte, new_spte;
+	u64 *cur_spte;
+	pte_t *ptep = (pte_t *)data;
+	pte_t pte;
+	struct page *new_page;
+	struct page *old_page;
+
+	pte = *ptep;
+	new_page = pfn_to_page(pte_pfn(pte));
+	cur_spte = rmap_next(kvm, rmapp, NULL);
+	while (cur_spte) {
+		spte = cur_spte;
+		BUG_ON(!(*spte & PT_PRESENT_MASK));
+		rmap_printk("kvm_set_pte_rmapp: spte %p %llx\n", spte, *spte);
+		new_spte = *spte &~ (PT64_BASE_ADDR_MASK);
+		new_spte |= pte_pfn(pte);
+		if (!pte_write(pte))
+			new_spte &= ~PT_WRITABLE_MASK;
+		old_page = pfn_to_page((*spte & PT64_BASE_ADDR_MASK) >> PAGE_SHIFT);
+		get_page(new_page);
+		cur_spte = rmap_next(kvm, rmapp, spte);
+		set_shadow_pte(spte, new_spte);
+		kvm_flush_remote_tlbs(kvm);
+		put_page(old_page);
+	}
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
@@ -700,11 +734,12 @@ static int kvm_handle_hva(struct kvm *kvm, unsigned long hva,
 		end = start + (memslot->npages << PAGE_SHIFT);
 		if (hva >= start && hva < end) {
 			gfn_t gfn_offset = (hva - start) >> PAGE_SHIFT;
-			retval |= handler(kvm, &memslot->rmap[gfn_offset]);
+			retval |= handler(kvm, &memslot->rmap[gfn_offset], data);
 			retval |= handler(kvm,
 					  &memslot->lpage_info[
 						  gfn_offset /
-						  KVM_PAGES_PER_HPAGE].rmap_pde);
+						  KVM_PAGES_PER_HPAGE].rmap_pde,
+						  data);
 		}
 	}
 
@@ -713,10 +748,16 @@ static int kvm_handle_hva(struct kvm *kvm, unsigned long hva,
 
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
@@ -742,7 +783,7 @@ static int kvm_age_rmapp(struct kvm *kvm, unsigned long *rmapp)
 
 int kvm_age_hva(struct kvm *kvm, unsigned long hva)
 {
-	return kvm_handle_hva(kvm, hva, kvm_age_rmapp);
+	return kvm_handle_hva(kvm, hva, 0, kvm_age_rmapp);
 }
 
 #ifdef MMU_DEBUG
diff --git a/include/linux/mmu_notifier.h b/include/linux/mmu_notifier.h
index b77486d..8bb245f 100644
--- a/include/linux/mmu_notifier.h
+++ b/include/linux/mmu_notifier.h
@@ -61,6 +61,15 @@ struct mmu_notifier_ops {
 				 struct mm_struct *mm,
 				 unsigned long address);
 
+	/* 
+	* change_pte is called in cases that pte mapping into page is changed
+	* for example when ksm mapped pte to point into a new shared page.
+	*/
+	void (*change_pte)(struct mmu_notifier *mn,
+			   struct mm_struct *mm,
+			   unsigned long address,
+			   pte_t pte);
+
 	/*
 	 * Before this is invoked any secondary MMU is still ok to
 	 * read/write to the page previously pointed to by the Linux
@@ -154,6 +163,8 @@ extern void __mmu_notifier_mm_destroy(struct mm_struct *mm);
 extern void __mmu_notifier_release(struct mm_struct *mm);
 extern int __mmu_notifier_clear_flush_young(struct mm_struct *mm,
 					  unsigned long address);
+extern void __mmu_notifier_change_pte(struct mm_struct *mm, 
+				      unsigned long address, pte_t pte);
 extern void __mmu_notifier_invalidate_page(struct mm_struct *mm,
 					  unsigned long address);
 extern void __mmu_notifier_invalidate_range_start(struct mm_struct *mm,
@@ -175,6 +186,13 @@ static inline int mmu_notifier_clear_flush_young(struct mm_struct *mm,
 	return 0;
 }
 
+static inline void mmu_notifier_change_pte(struct mm_struct *mm,
+					   unsigned long address, pte_t pte)
+{
+	if (mm_has_notifiers(mm))
+		__mmu_notifier_change_pte(mm, address, pte);
+}
+
 static inline void mmu_notifier_invalidate_page(struct mm_struct *mm,
 					  unsigned long address)
 {
@@ -236,6 +254,16 @@ static inline void mmu_notifier_mm_destroy(struct mm_struct *mm)
 	__young;							\
 })
 
+#define set_pte_at_notify(__mm, __address, __ptep, __pte)		\
+({									\
+	struct mm_struct *___mm = __mm;					\
+	unsigned long ___address = __address;				\
+	pte_t ___pte = __pte;						\
+									\
+	set_pte_at(__mm, __address, __ptep, ___pte);			\
+	mmu_notifier_change_pte(___mm, ___address, ___pte);		\
+})
+
 #else /* CONFIG_MMU_NOTIFIER */
 
 static inline void mmu_notifier_release(struct mm_struct *mm)
@@ -248,6 +276,11 @@ static inline int mmu_notifier_clear_flush_young(struct mm_struct *mm,
 	return 0;
 }
 
+static inline void mmu_notifier_change_pte(struct mm_struct *mm,
+					   unsigned long address, pte_t pte)
+{
+}
+
 static inline void mmu_notifier_invalidate_page(struct mm_struct *mm,
 					  unsigned long address)
 {
@@ -273,6 +306,7 @@ static inline void mmu_notifier_mm_destroy(struct mm_struct *mm)
 
 #define ptep_clear_flush_young_notify ptep_clear_flush_young
 #define ptep_clear_flush_notify ptep_clear_flush
+#define set_pte_at_notify set_pte_at
 
 #endif /* CONFIG_MMU_NOTIFIER */
 
diff --git a/mm/memory.c b/mm/memory.c
index ac5de33..09724ed 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1534,7 +1534,7 @@ int replace_page(struct vm_area_struct *vma, struct page *oldpage,
 
 	flush_cache_page(vma, addr, pte_pfn(*ptep));
 	ptep_clear_flush(vma, addr, ptep);
-	set_pte_at(mm, addr, ptep, mk_pte(newpage, prot));
+	set_pte_at_notify(mm, addr, ptep, mk_pte(newpage, prot));
 
 	page_remove_rmap(oldpage, vma);
 	if (PageAnon(oldpage)) {
@@ -1993,13 +1993,19 @@ gotten:
 		 * seen in the presence of one thread doing SMC and another
 		 * thread doing COW.
 		 */
-		ptep_clear_flush_notify(vma, address, page_table);
+		ptep_clear_flush(vma, address, page_table);
 		SetPageSwapBacked(new_page);
 		lru_cache_add_active_or_unevictable(new_page, vma);
 		page_add_new_anon_rmap(new_page, vma, address);
 
 //TODO:  is this safe?  do_anonymous_page() does it this way.
-		set_pte_at(mm, address, page_table, entry);
+		/*
+		 * we call here for the notify macro beacuse in cases of using
+		 * secondary mmu page table like kvm shadow page tables
+		 * we want the new page to be mapped directly into the second
+		 * page table.
+		 */
+		set_pte_at_notify(mm, address, page_table, entry);
 		update_mmu_cache(vma, address, entry);
 		if (old_page) {
 			/*
diff --git a/mm/mmu_notifier.c b/mm/mmu_notifier.c
index 5f4ef02..c3e8779 100644
--- a/mm/mmu_notifier.c
+++ b/mm/mmu_notifier.c
@@ -99,6 +99,26 @@ int __mmu_notifier_clear_flush_young(struct mm_struct *mm,
 	return young;
 }
 
+void __mmu_notifier_change_pte(struct mm_struct *mm, unsigned long address,
+			       pte_t pte)
+{
+	struct mmu_notifier *mn;
+	struct hlist_node *n;
+
+	rcu_read_lock();
+	hlist_for_each_entry_rcu(mn, n, &mm->mmu_notifier_mm->list, hlist) {
+		if (mn->ops->change_pte)
+			mn->ops->change_pte(mn, mm, address, pte);
+		/* 
+		 * some drivers dont have change_pte and therefor we must call
+		 * for invalidate_page in that case
+		 */
+		else if (mn->ops->invalidate_page)
+			mn->ops->invalidate_page(mn, mm, address);
+	}
+	rcu_read_unlock();
+}
+
 void __mmu_notifier_invalidate_page(struct mm_struct *mm,
 					  unsigned long address)
 {
diff --git a/virt/kvm/kvm_main.c b/virt/kvm/kvm_main.c
index a87f45e..5f92c2b 100644
--- a/virt/kvm/kvm_main.c
+++ b/virt/kvm/kvm_main.c
@@ -486,6 +486,19 @@ static void kvm_mmu_notifier_invalidate_page(struct mmu_notifier *mn,
 
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
@@ -558,6 +571,7 @@ static const struct mmu_notifier_ops kvm_mmu_notifier_ops = {
 	.invalidate_range_start	= kvm_mmu_notifier_invalidate_range_start,
 	.invalidate_range_end	= kvm_mmu_notifier_invalidate_range_end,
 	.clear_flush_young	= kvm_mmu_notifier_clear_flush_young,
+	.change_pte             = kvm_mmu_notifier_change_pte,
 };
 #endif /* CONFIG_MMU_NOTIFIER && KVM_ARCH_WANT_MMU_NOTIFIER */
 
-- 
1.6.0.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
