Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 985826B0032
	for <linux-mm@kvack.org>; Fri, 20 Feb 2015 23:31:41 -0500 (EST)
Received: by pabkq14 with SMTP id kq14so13006511pab.3
        for <linux-mm@kvack.org>; Fri, 20 Feb 2015 20:31:41 -0800 (PST)
Received: from mail-pd0-x22e.google.com (mail-pd0-x22e.google.com. [2607:f8b0:400e:c02::22e])
        by mx.google.com with ESMTPS id nx11si15188356pdb.157.2015.02.20.20.31.40
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Feb 2015 20:31:40 -0800 (PST)
Received: by pdev10 with SMTP id v10so12072231pde.10
        for <linux-mm@kvack.org>; Fri, 20 Feb 2015 20:31:40 -0800 (PST)
Date: Fri, 20 Feb 2015 20:31:38 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 24/24] kvm: teach kvm to map page teams as huge pages.
In-Reply-To: <alpine.LSU.2.11.1502201941340.14414@eggly.anvils>
Message-ID: <alpine.LSU.2.11.1502202029340.14414@eggly.anvils>
References: <alpine.LSU.2.11.1502201941340.14414@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Ning Qu <quning@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Andres Lagar-Cavilla <andreslc@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

From: Andres Lagar-Cavilla <andreslc@google.com>

Include a small treatise on the locking rules around page teams.

Signed-off-by: Andres Lagar-Cavilla <andreslc@google.com>
Signed-off-by: Hugh Dickins <hughd@google.com>
---
 arch/x86/kvm/mmu.c         |  155 +++++++++++++++++++++++++++++------
 arch/x86/kvm/paging_tmpl.h |    3 
 2 files changed, 132 insertions(+), 26 deletions(-)

--- thpfs.orig/arch/x86/kvm/mmu.c	2015-02-20 19:35:20.095835839 -0800
+++ thpfs/arch/x86/kvm/mmu.c	2015-02-20 19:35:24.775825138 -0800
@@ -32,6 +32,7 @@
 #include <linux/module.h>
 #include <linux/swap.h>
 #include <linux/hugetlb.h>
+#include <linux/pageteam.h>
 #include <linux/compiler.h>
 #include <linux/srcu.h>
 #include <linux/slab.h>
@@ -2723,7 +2724,106 @@ static int kvm_handle_bad_page(struct kv
 	return -EFAULT;
 }
 
+/*
+ * We are holding kvm->mmu_lock, serializing against mmu notifiers.
+ * We have a ref on page.
+ *
+ * A team of tmpfs 512 pages can be mapped as an integral hugepage as long as
+ * the team is not disbanded. The head page is !PageTeam if disbanded.
+ *
+ * Huge tmpfs pages are disbanded for page freeing, shrinking, or swap out.
+ *
+ * Freeing (punch hole, truncation):
+ *  shmem_undo_range
+ *     disband
+ *       lock head page
+ *       unmap_mapping_range
+ *         zap_page_range_single
+ *           mmu_notifier_invalidate_range_start
+ *           split_huge_page_pmd or zap_huge_pmd
+ *             remap_team_by_ptes
+ *           mmu_notifier_invalidate_range_end
+ *       unlock head page
+ *     pagevec_release
+ *        pages are freed
+ * If we race with disband MMUN will fix us up. The head page lock also
+ * serializes any gup() against resolving the page team.
+ *
+ * Shrinker, disbands, but once a page team is fully banded up it no longer is
+ * tagged as shrinkable in the radix tree and hence can't be shrunk.
+ *  shmem_shrink_hugehole
+ *     shmem_choose_hugehole
+ *        disband
+ *     migrate_pages
+ *        try_to_unmap
+ *           mmu_notifier_invalidate_page
+ * Double-indemnity: if we race with disband, MMUN will fix us up.
+ *
+ * Swap out:
+ *  shrink_page_list
+ *    try_to_unmap
+ *      unmap_team_by_pmd
+ *         mmu_notifier_invalidate_range
+ *    pageout
+ *      shmem_writepage
+ *         disband
+ *    free_hot_cold_page_list
+ *       pages are freed
+ * If we race with disband, no one will come to fix us up. So, we check for a
+ * pmd mapping, serializing against the MMUN in unmap_team_by_pmd, which will
+ * break the pmd mapping if it runs before us (or invalidate our mapping if ran
+ * after).
+ *
+ * N.B. migration requires further thought all around.
+ */
+static bool is_huge_tmpfs(struct mm_struct *mm, struct page *page,
+			  unsigned long address)
+{
+	pgd_t *pgd;
+	pud_t *pud;
+	pmd_t *pmd;
+	struct page *head;
+
+	if (PageAnon(page) || !PageTeam(page))
+		return false;
+	/*
+	 * This strictly assumes PMD-level huge-ing.
+	 * Which is the only thing KVM can handle here.
+	 * N.B. Assume (like everywhere else) PAGE_SIZE == PAGE_CACHE_SIZE.
+	 */
+	if (((address & (HPAGE_PMD_SIZE - 1)) >> PAGE_SHIFT) !=
+	    (page->index & (HPAGE_PMD_NR-1)))
+		return false;
+	head = team_head(page);
+	if (!PageTeam(head))
+		return false;
+	/*
+	 * Attempt at early discard. If the head races into becoming SwapCache,
+	 * and thus having a bogus team_usage, we'll know for sure next.
+	 */
+	if (!team_hugely_mapped(head))
+		return false;
+	/*
+	 * Open code page_check_address_pmd, otherwise we'd have to make it
+	 * a module-visible symbol. Simplify it. No need for page table lock,
+	 * as mmu notifier serialization ensures we are on either side of
+	 * unmap_team_by_pmd or remap_team_by_ptes.
+	 */
+	address &= HPAGE_PMD_MASK;
+	pgd = pgd_offset(mm, address);
+	if (!pgd_present(*pgd))
+		return false;
+	pud = pud_offset(pgd, address);
+	if (!pud_present(*pud))
+		return false;
+	pmd = pmd_offset(pud, address);
+	if (!pmd_trans_huge(*pmd))
+		return false;
+	return pmd_page(*pmd) == head;
+}
+
 static void transparent_hugepage_adjust(struct kvm_vcpu *vcpu,
+					unsigned long address,
 					gfn_t *gfnp, pfn_t *pfnp, int *levelp)
 {
 	pfn_t pfn = *pfnp;
@@ -2737,29 +2837,34 @@ static void transparent_hugepage_adjust(
 	 * here.
 	 */
 	if (!is_error_noslot_pfn(pfn) && !kvm_is_reserved_pfn(pfn) &&
-	    level == PT_PAGE_TABLE_LEVEL &&
-	    PageTransCompound(pfn_to_page(pfn)) &&
-	    !has_wrprotected_page(vcpu->kvm, gfn, PT_DIRECTORY_LEVEL)) {
-		unsigned long mask;
-		/*
-		 * mmu_notifier_retry was successful and we hold the
-		 * mmu_lock here, so the pmd can't become splitting
-		 * from under us, and in turn
-		 * __split_huge_page_refcount() can't run from under
-		 * us and we can safely transfer the refcount from
-		 * PG_tail to PG_head as we switch the pfn to tail to
-		 * head.
-		 */
-		*levelp = level = PT_DIRECTORY_LEVEL;
-		mask = KVM_PAGES_PER_HPAGE(level) - 1;
-		VM_BUG_ON((gfn & mask) != (pfn & mask));
-		if (pfn & mask) {
-			gfn &= ~mask;
-			*gfnp = gfn;
-			kvm_release_pfn_clean(pfn);
-			pfn &= ~mask;
-			kvm_get_pfn(pfn);
-			*pfnp = pfn;
+	    level == PT_PAGE_TABLE_LEVEL) {
+		struct page *page = pfn_to_page(pfn);
+
+		if ((PageTransCompound(page) ||
+		     is_huge_tmpfs(vcpu->kvm->mm, page, address)) &&
+		    !has_wrprotected_page(vcpu->kvm, gfn,
+					  PT_DIRECTORY_LEVEL)) {
+			unsigned long mask;
+			/*
+			 * mmu_notifier_retry was successful and we hold the
+			 * mmu_lock here, so the pmd can't become splitting
+			 * from under us, and in turn
+			 * __split_huge_page_refcount() can't run from under
+			 * us and we can safely transfer the refcount from
+			 * PG_tail to PG_head as we switch the pfn to tail to
+			 * head.
+			 */
+			*levelp = level = PT_DIRECTORY_LEVEL;
+			mask = KVM_PAGES_PER_HPAGE(level) - 1;
+			VM_BUG_ON((gfn & mask) != (pfn & mask));
+			if (pfn & mask) {
+				gfn &= ~mask;
+				*gfnp = gfn;
+				kvm_release_pfn_clean(pfn);
+				pfn &= ~mask;
+				kvm_get_pfn(pfn);
+				*pfnp = pfn;
+			}
 		}
 	}
 }
@@ -2955,7 +3060,7 @@ static int nonpaging_map(struct kvm_vcpu
 		goto out_unlock;
 	make_mmu_pages_available(vcpu);
 	if (likely(!force_pt_level))
-		transparent_hugepage_adjust(vcpu, &gfn, &pfn, &level);
+		transparent_hugepage_adjust(vcpu, hva, &gfn, &pfn, &level);
 	r = __direct_map(vcpu, v, write, map_writable, level, gfn, pfn,
 			 prefault);
 	spin_unlock(&vcpu->kvm->mmu_lock);
@@ -3440,7 +3545,7 @@ static int tdp_page_fault(struct kvm_vcp
 		goto out_unlock;
 	make_mmu_pages_available(vcpu);
 	if (likely(!force_pt_level))
-		transparent_hugepage_adjust(vcpu, &gfn, &pfn, &level);
+		transparent_hugepage_adjust(vcpu, hva, &gfn, &pfn, &level);
 	r = __direct_map(vcpu, gpa, write, map_writable,
 			 level, gfn, pfn, prefault);
 	spin_unlock(&vcpu->kvm->mmu_lock);
--- thpfs.orig/arch/x86/kvm/paging_tmpl.h	2015-02-20 19:35:20.095835839 -0800
+++ thpfs/arch/x86/kvm/paging_tmpl.h	2015-02-20 19:35:24.775825138 -0800
@@ -794,7 +794,8 @@ static int FNAME(page_fault)(struct kvm_
 	kvm_mmu_audit(vcpu, AUDIT_PRE_PAGE_FAULT);
 	make_mmu_pages_available(vcpu);
 	if (!force_pt_level)
-		transparent_hugepage_adjust(vcpu, &walker.gfn, &pfn, &level);
+		transparent_hugepage_adjust(vcpu, hva, &walker.gfn, &pfn,
+					    &level);
 	r = FNAME(fetch)(vcpu, addr, &walker, write_fault,
 			 level, pfn, map_writable, prefault);
 	++vcpu->stat.pf_fixed;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
