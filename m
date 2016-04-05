Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id C71086B02AB
	for <linux-mm@kvack.org>; Tue,  5 Apr 2016 17:41:17 -0400 (EDT)
Received: by mail-pa0-f54.google.com with SMTP id zm5so18477832pac.0
        for <linux-mm@kvack.org>; Tue, 05 Apr 2016 14:41:17 -0700 (PDT)
Received: from mail-pf0-x22d.google.com (mail-pf0-x22d.google.com. [2607:f8b0:400e:c00::22d])
        by mx.google.com with ESMTPS id kv12si10100214pab.194.2016.04.05.14.41.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Apr 2016 14:41:16 -0700 (PDT)
Received: by mail-pf0-x22d.google.com with SMTP id e128so18709256pfe.3
        for <linux-mm@kvack.org>; Tue, 05 Apr 2016 14:41:16 -0700 (PDT)
Date: Tue, 5 Apr 2016 14:41:14 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 17/31] kvm: teach kvm to map page teams as huge pages.
In-Reply-To: <alpine.LSU.2.11.1604051403210.5965@eggly.anvils>
Message-ID: <alpine.LSU.2.11.1604051439340.5965@eggly.anvils>
References: <alpine.LSU.2.11.1604051403210.5965@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Andres Lagar-Cavilla <andreslc@google.com>, Yang Shi <yang.shi@linaro.org>, Ning Qu <quning@gmail.com>, linux-kernel@vger.kernel.org, kvm@vger.kernel.org, linux-mm@kvack.org

From: Andres Lagar-Cavilla <andreslc@google.com>

Include a small treatise on the locking rules around page teams.

Signed-off-by: Andres Lagar-Cavilla <andreslc@google.com>
Signed-off-by: Hugh Dickins <hughd@google.com>
---
Cc'ed to kvm@vger.kernel.org as an FYI: this patch is not expected to
go into the tree in the next few weeks, and depends upon a pageteam.h
not yet available outside this patchset.  The context is a huge tmpfs
patchset which implements huge pagecache transparently on tmpfs,
using a team of small pages rather than one compound page:
please refer to linux-mm or linux-kernel for more context.

 arch/x86/kvm/mmu.c         |  130 ++++++++++++++++++++++++++++++-----
 arch/x86/kvm/paging_tmpl.h |    3 
 2 files changed, 117 insertions(+), 16 deletions(-)

--- a/arch/x86/kvm/mmu.c
+++ b/arch/x86/kvm/mmu.c
@@ -32,6 +32,7 @@
 #include <linux/module.h>
 #include <linux/swap.h>
 #include <linux/hugetlb.h>
+#include <linux/pageteam.h>
 #include <linux/compiler.h>
 #include <linux/srcu.h>
 #include <linux/slab.h>
@@ -2799,33 +2800,132 @@ static int kvm_handle_bad_page(struct kv
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
+ *           __split_huge_pmd or zap_huge_pmd
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
+ */
+static bool is_huge_tmpfs(struct kvm_vcpu *vcpu,
+			  unsigned long address, struct page *page)
+{
+	pgd_t *pgd;
+	pud_t *pud;
+	pmd_t *pmd;
+	struct page *head;
+
+	if (!PageTeam(page))
+		return false;
+	/*
+	 * This strictly assumes PMD-level huge-ing.
+	 * Which is the only thing KVM can handle here.
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
+	if (!team_pmd_mapped(head))
+		return false;
+	/*
+	 * Copied from page_check_address_transhuge, to avoid making it
+	 * a module-visible symbol. Simplify it. No need for page table lock,
+	 * as mmu notifier serialization ensures we are on either side of
+	 * unmap_team_by_pmd or remap_team_by_ptes.
+	 */
+	address &= HPAGE_PMD_MASK;
+	pgd = pgd_offset(vcpu->kvm->mm, address);
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
+static bool is_transparent_hugepage(struct kvm_vcpu *vcpu,
+				    unsigned long address, kvm_pfn_t pfn)
+{
+	struct page *page = pfn_to_page(pfn);
+
+	return PageTransCompound(page) || is_huge_tmpfs(vcpu, address, page);
+}
+
 static void transparent_hugepage_adjust(struct kvm_vcpu *vcpu,
-					gfn_t *gfnp, kvm_pfn_t *pfnp,
-					int *levelp)
+					unsigned long address, gfn_t *gfnp,
+					kvm_pfn_t *pfnp, int *levelp)
 {
 	kvm_pfn_t pfn = *pfnp;
 	gfn_t gfn = *gfnp;
 	int level = *levelp;
 
 	/*
-	 * Check if it's a transparent hugepage. If this would be an
-	 * hugetlbfs page, level wouldn't be set to
-	 * PT_PAGE_TABLE_LEVEL and there would be no adjustment done
-	 * here.
+	 * Check if it's a transparent hugepage, either anon or huge tmpfs.
+	 * If this were a hugetlbfs page, level wouldn't be set to
+	 * PT_PAGE_TABLE_LEVEL and no adjustment would be done here.
 	 */
 	if (!is_error_noslot_pfn(pfn) && !kvm_is_reserved_pfn(pfn) &&
 	    level == PT_PAGE_TABLE_LEVEL &&
-	    PageTransCompound(pfn_to_page(pfn)) &&
+	    is_transparent_hugepage(vcpu, address, pfn) &&
 	    !mmu_gfn_lpage_is_disallowed(vcpu, gfn, PT_DIRECTORY_LEVEL)) {
 		unsigned long mask;
 		/*
 		 * mmu_notifier_retry was successful and we hold the
-		 * mmu_lock here, so the pmd can't become splitting
-		 * from under us, and in turn
-		 * __split_huge_page_refcount() can't run from under
-		 * us and we can safely transfer the refcount from
-		 * PG_tail to PG_head as we switch the pfn to tail to
-		 * head.
+		 * mmu_lock here, so the pmd can't be split under us,
+		 * so we can safely transfer the refcount from PG_tail
+		 * to PG_head as we switch the pfn from tail to head.
 		 */
 		*levelp = level = PT_DIRECTORY_LEVEL;
 		mask = KVM_PAGES_PER_HPAGE(level) - 1;
@@ -3038,7 +3138,7 @@ static int nonpaging_map(struct kvm_vcpu
 		goto out_unlock;
 	make_mmu_pages_available(vcpu);
 	if (likely(!force_pt_level))
-		transparent_hugepage_adjust(vcpu, &gfn, &pfn, &level);
+		transparent_hugepage_adjust(vcpu, hva, &gfn, &pfn, &level);
 	r = __direct_map(vcpu, write, map_writable, level, gfn, pfn, prefault);
 	spin_unlock(&vcpu->kvm->mmu_lock);
 
@@ -3578,7 +3678,7 @@ static int tdp_page_fault(struct kvm_vcp
 		goto out_unlock;
 	make_mmu_pages_available(vcpu);
 	if (likely(!force_pt_level))
-		transparent_hugepage_adjust(vcpu, &gfn, &pfn, &level);
+		transparent_hugepage_adjust(vcpu, hva, &gfn, &pfn, &level);
 	r = __direct_map(vcpu, write, map_writable, level, gfn, pfn, prefault);
 	spin_unlock(&vcpu->kvm->mmu_lock);
 
--- a/arch/x86/kvm/paging_tmpl.h
+++ b/arch/x86/kvm/paging_tmpl.h
@@ -800,7 +800,8 @@ static int FNAME(page_fault)(struct kvm_
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
