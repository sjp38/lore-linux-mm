Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id C20BD6B00C6
	for <linux-mm@kvack.org>; Wed,  3 Nov 2010 11:30:43 -0400 (EDT)
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Subject: [PATCH 59 of 66] mmu_notifier_test_young
Message-Id: <223f722aba68e31ab9e9.1288798114@v2.random>
In-Reply-To: <patchbomb.1288798055@v2.random>
References: <patchbomb.1288798055@v2.random>
Date: Wed, 03 Nov 2010 16:28:34 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
Cc: Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Chris Mason <chris.mason@oracle.com>, Borislav Petkov <bp@alien8.de>
List-ID: <linux-mm.kvack.org>

From: Andrea Arcangeli <aarcange@redhat.com>

For GRU and EPT, we need gup-fast to set referenced bit too (this is why it's
correct to return 0 when shadow_access_mask is zero, it requires gup-fast to
set the referenced bit). qemu-kvm access already sets the young bit in the pte
if it isn't zero-copy, if it's zero copy or a shadow paging EPT minor fault we
relay on gup-fast to signal the page is in use...

We also need to check the young bits on the secondary pagetables for NPT and
not nested shadow mmu as the data may never get accessed again by the primary
pte.

Without this closer accuracy, we'd have to remove the heuristic that avoids
collapsing hugepages in hugepage virtual regions that have not even a single
subpage in use.

->test_young is full backwards compatible with GRU and other usages that don't
have young bits in pagetables set by the hardware and that should nuke the
secondary mmu mappings when ->clear_flush_young runs just like EPT does.

Removing the heuristic that checks the young bit in
khugepaged/collapse_huge_page completely isn't so bad either probably but I
thought it was worth it and this makes it reliable.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---

diff --git a/arch/x86/include/asm/kvm_host.h b/arch/x86/include/asm/kvm_host.h
--- a/arch/x86/include/asm/kvm_host.h
+++ b/arch/x86/include/asm/kvm_host.h
@@ -788,6 +788,7 @@ asmlinkage void kvm_handle_fault_on_rebo
 #define KVM_ARCH_WANT_MMU_NOTIFIER
 int kvm_unmap_hva(struct kvm *kvm, unsigned long hva);
 int kvm_age_hva(struct kvm *kvm, unsigned long hva);
+int kvm_test_age_hva(struct kvm *kvm, unsigned long hva);
 void kvm_set_spte_hva(struct kvm *kvm, unsigned long hva, pte_t pte);
 int cpuid_maxphyaddr(struct kvm_vcpu *vcpu);
 int kvm_cpu_has_interrupt(struct kvm_vcpu *vcpu);
diff --git a/arch/x86/kvm/mmu.c b/arch/x86/kvm/mmu.c
--- a/arch/x86/kvm/mmu.c
+++ b/arch/x86/kvm/mmu.c
@@ -959,6 +959,35 @@ static int kvm_age_rmapp(struct kvm *kvm
 	return young;
 }
 
+static int kvm_test_age_rmapp(struct kvm *kvm, unsigned long *rmapp,
+			      unsigned long data)
+{
+	u64 *spte;
+	int young = 0;
+
+	/*
+	 * If there's no access bit in the secondary pte set by the
+	 * hardware it's up to gup-fast/gup to set the access bit in
+	 * the primary pte or in the page structure.
+	 */
+	if (!shadow_accessed_mask)
+		goto out;
+
+	spte = rmap_next(kvm, rmapp, NULL);
+	while (spte) {
+		u64 _spte = *spte;
+		BUG_ON(!(_spte & PT_PRESENT_MASK));
+		young = _spte & PT_ACCESSED_MASK;
+		if (young) {
+			young = 1;
+			break;
+		}
+		spte = rmap_next(kvm, rmapp, spte);
+	}
+out:
+	return young;
+}
+
 #define RMAP_RECYCLE_THRESHOLD 1000
 
 static void rmap_recycle(struct kvm_vcpu *vcpu, u64 *spte, gfn_t gfn)
@@ -979,6 +1008,11 @@ int kvm_age_hva(struct kvm *kvm, unsigne
 	return kvm_handle_hva(kvm, hva, 0, kvm_age_rmapp);
 }
 
+int kvm_test_age_hva(struct kvm *kvm, unsigned long hva)
+{
+	return kvm_handle_hva(kvm, hva, 0, kvm_test_age_rmapp);
+}
+
 #ifdef MMU_DEBUG
 static int is_empty_shadow_page(u64 *spt)
 {
diff --git a/arch/x86/mm/gup.c b/arch/x86/mm/gup.c
--- a/arch/x86/mm/gup.c
+++ b/arch/x86/mm/gup.c
@@ -8,6 +8,7 @@
 #include <linux/mm.h>
 #include <linux/vmstat.h>
 #include <linux/highmem.h>
+#include <linux/swap.h>
 
 #include <asm/pgtable.h>
 
@@ -89,6 +90,7 @@ static noinline int gup_pte_range(pmd_t 
 		VM_BUG_ON(!pfn_valid(pte_pfn(pte)));
 		page = pte_page(pte);
 		get_page(page);
+		SetPageReferenced(page);
 		pages[*nr] = page;
 		(*nr)++;
 
@@ -103,6 +105,7 @@ static inline void get_head_page_multipl
 	VM_BUG_ON(page != compound_head(page));
 	VM_BUG_ON(page_count(page) == 0);
 	atomic_add(nr, &page->_count);
+	SetPageReferenced(page);
 }
 
 static inline void pin_huge_page_tail(struct page *page)
diff --git a/include/linux/mmu_notifier.h b/include/linux/mmu_notifier.h
--- a/include/linux/mmu_notifier.h
+++ b/include/linux/mmu_notifier.h
@@ -62,6 +62,16 @@ struct mmu_notifier_ops {
 				 unsigned long address);
 
 	/*
+	 * test_young is called to check the young/accessed bitflag in
+	 * the secondary pte. This is used to know if the page is
+	 * frequently used without actually clearing the flag or tearing
+	 * down the secondary mapping on the page.
+	 */
+	int (*test_young)(struct mmu_notifier *mn,
+			  struct mm_struct *mm,
+			  unsigned long address);
+
+	/*
 	 * change_pte is called in cases that pte mapping to page is changed:
 	 * for example, when ksm remaps pte to point to a new shared page.
 	 */
@@ -163,6 +173,8 @@ extern void __mmu_notifier_mm_destroy(st
 extern void __mmu_notifier_release(struct mm_struct *mm);
 extern int __mmu_notifier_clear_flush_young(struct mm_struct *mm,
 					  unsigned long address);
+extern int __mmu_notifier_test_young(struct mm_struct *mm,
+				     unsigned long address);
 extern void __mmu_notifier_change_pte(struct mm_struct *mm,
 				      unsigned long address, pte_t pte);
 extern void __mmu_notifier_invalidate_page(struct mm_struct *mm,
@@ -186,6 +198,14 @@ static inline int mmu_notifier_clear_flu
 	return 0;
 }
 
+static inline int mmu_notifier_test_young(struct mm_struct *mm,
+					  unsigned long address)
+{
+	if (mm_has_notifiers(mm))
+		return __mmu_notifier_test_young(mm, address);
+	return 0;
+}
+
 static inline void mmu_notifier_change_pte(struct mm_struct *mm,
 					   unsigned long address, pte_t pte)
 {
@@ -313,6 +333,12 @@ static inline int mmu_notifier_clear_flu
 	return 0;
 }
 
+static inline int mmu_notifier_test_young(struct mm_struct *mm,
+					  unsigned long address)
+{
+	return 0;
+}
+
 static inline void mmu_notifier_change_pte(struct mm_struct *mm,
 					   unsigned long address, pte_t pte)
 {
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1626,7 +1626,8 @@ static int __collapse_huge_page_isolate(
 		VM_BUG_ON(PageLRU(page));
 
 		/* If there is no mapped pte young don't collapse the page */
-		if (pte_young(pteval))
+		if (pte_young(pteval) || PageReferenced(page) ||
+		    mmu_notifier_test_young(vma->vm_mm, address))
 			referenced = 1;
 	}
 	if (unlikely(!referenced))
@@ -1869,7 +1870,8 @@ static int khugepaged_scan_pmd(struct mm
 		/* cannot use mapcount: can't collapse if there's a gup pin */
 		if (page_count(page) != 1)
 			goto out_unmap;
-		if (pte_young(pteval))
+		if (pte_young(pteval) || PageReferenced(page) ||
+		    mmu_notifier_test_young(vma->vm_mm, address))
 			referenced = 1;
 	}
 	if (referenced)
diff --git a/mm/mmu_notifier.c b/mm/mmu_notifier.c
--- a/mm/mmu_notifier.c
+++ b/mm/mmu_notifier.c
@@ -100,6 +100,26 @@ int __mmu_notifier_clear_flush_young(str
 	return young;
 }
 
+int __mmu_notifier_test_young(struct mm_struct *mm,
+			      unsigned long address)
+{
+	struct mmu_notifier *mn;
+	struct hlist_node *n;
+	int young = 0;
+
+	rcu_read_lock();
+	hlist_for_each_entry_rcu(mn, n, &mm->mmu_notifier_mm->list, hlist) {
+		if (mn->ops->test_young) {
+			young = mn->ops->test_young(mn, mm, address);
+			if (young)
+				break;
+		}
+	}
+	rcu_read_unlock();
+
+	return young;
+}
+
 void __mmu_notifier_change_pte(struct mm_struct *mm, unsigned long address,
 			       pte_t pte)
 {
diff --git a/virt/kvm/kvm_main.c b/virt/kvm/kvm_main.c
--- a/virt/kvm/kvm_main.c
+++ b/virt/kvm/kvm_main.c
@@ -372,6 +372,22 @@ static int kvm_mmu_notifier_clear_flush_
 	return young;
 }
 
+static int kvm_mmu_notifier_test_young(struct mmu_notifier *mn,
+				       struct mm_struct *mm,
+				       unsigned long address)
+{
+	struct kvm *kvm = mmu_notifier_to_kvm(mn);
+	int young, idx;
+
+	idx = srcu_read_lock(&kvm->srcu);
+	spin_lock(&kvm->mmu_lock);
+	young = kvm_test_age_hva(kvm, address);
+	spin_unlock(&kvm->mmu_lock);
+	srcu_read_unlock(&kvm->srcu, idx);
+
+	return young;
+}
+
 static void kvm_mmu_notifier_release(struct mmu_notifier *mn,
 				     struct mm_struct *mm)
 {
@@ -388,6 +404,7 @@ static const struct mmu_notifier_ops kvm
 	.invalidate_range_start	= kvm_mmu_notifier_invalidate_range_start,
 	.invalidate_range_end	= kvm_mmu_notifier_invalidate_range_end,
 	.clear_flush_young	= kvm_mmu_notifier_clear_flush_young,
+	.test_young		= kvm_mmu_notifier_test_young,
 	.change_pte		= kvm_mmu_notifier_change_pte,
 	.release		= kvm_mmu_notifier_release,
 };

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
