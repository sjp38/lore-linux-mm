Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 64EFB6B00BB
	for <linux-mm@kvack.org>; Fri,  7 Jan 2011 13:54:37 -0500 (EST)
Date: Fri, 7 Jan 2011 19:54:33 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH -mm] thp: fix for KVM THP support
Message-ID: <20110107185433.GS15823@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hello Andrew,

I'm sending 3 patches to apply on top of your -mm tree.

This adjusts the KVM THP support, there was some issue with the
previous approach. This still keeps the same approach to avoid two
gup_fast for each secondary mmu page fault but I tested it (even not
exactly on top of -mm because I had some problem building it) and it
works fine so far.

======
Subject: thp: fix for KVM THP support

From: Andrea Arcangeli <aarcange@redhat.com>

There were several bugs: dirty_bitmap ignored (migration shutoff largepages),
has_wrprotect_page(directory_level) ignored, refcount taken on tail page and
refcount released on pfn head page post-adjustment (now it's being transferred
during the adjustment, that's where KSM over THP tripped inside
split_huge_page, the rest I found it by code review).

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 arch/x86/kvm/mmu.c         |   97 ++++++++++++++++++++++++++++++++-------------
 arch/x86/kvm/paging_tmpl.h |   10 +++-
 2 files changed, 79 insertions(+), 28 deletions(-)

This would become thp-kvm-mmu-transparent-hugepage-support-fix.patch

--- a/arch/x86/kvm/mmu.c
+++ b/arch/x86/kvm/mmu.c
@@ -554,14 +554,18 @@ static int host_mapping_level(struct kvm
 	return ret;
 }
 
-static int mapping_level(struct kvm_vcpu *vcpu, gfn_t large_gfn)
+static bool mapping_level_dirty_bitmap(struct kvm_vcpu *vcpu, gfn_t large_gfn)
 {
 	struct kvm_memory_slot *slot;
-	int host_level, level, max_level;
-
 	slot = gfn_to_memslot(vcpu->kvm, large_gfn);
 	if (slot && slot->dirty_bitmap)
-		return PT_PAGE_TABLE_LEVEL;
+		return true;
+	return false;
+}
+
+static int mapping_level(struct kvm_vcpu *vcpu, gfn_t large_gfn)
+{
+	int host_level, level, max_level;
 
 	host_level = host_mapping_level(vcpu->kvm, large_gfn);
 
@@ -2315,15 +2319,45 @@ static int kvm_handle_bad_page(struct kv
 	return 1;
 }
 
-static void transparent_hugepage_adjust(gfn_t *gfn, pfn_t *pfn, int * level)
+static void transparent_hugepage_adjust(struct kvm_vcpu *vcpu,
+					gfn_t *gfnp, pfn_t *pfnp, int *levelp)
 {
-	/* check if it's a transparent hugepage */
-	if (!is_error_pfn(*pfn) && !kvm_is_mmio_pfn(*pfn) &&
-	    *level == PT_PAGE_TABLE_LEVEL &&
-	    PageTransCompound(pfn_to_page(*pfn))) {
-		*level = PT_DIRECTORY_LEVEL;
-		*gfn = *gfn & ~(KVM_PAGES_PER_HPAGE(*level) - 1);
-		*pfn = *pfn & ~(KVM_PAGES_PER_HPAGE(*level) - 1);
+	pfn_t pfn = *pfnp;
+	gfn_t gfn = *gfnp;
+	int level = *levelp;
+
+	/*
+	 * Check if it's a transparent hugepage. If this would be an
+	 * hugetlbfs page, level wouldn't be set to
+	 * PT_PAGE_TABLE_LEVEL and there would be no adjustment done
+	 * here.
+	 */
+	if (!is_error_pfn(pfn) && !kvm_is_mmio_pfn(pfn) &&
+	    level == PT_PAGE_TABLE_LEVEL &&
+	    PageTransCompound(pfn_to_page(pfn)) &&
+	    !has_wrprotected_page(vcpu->kvm, gfn, PT_DIRECTORY_LEVEL)) {
+		unsigned long mask;
+		/*
+		 * mmu_notifier_retry was successful and we hold the
+		 * mmu_lock here, so the pmd can't become splitting
+		 * from under us, and in turn
+		 * __split_huge_page_refcount() can't run from under
+		 * us and we can safely transfer the refcount from
+		 * PG_tail to PG_head as we switch the pfn to tail to
+		 * head.
+		 */
+		*levelp = level = PT_DIRECTORY_LEVEL;
+		mask = KVM_PAGES_PER_HPAGE(level) - 1;
+		VM_BUG_ON((gfn & mask) != (pfn & mask));
+		if (pfn & mask) {
+			gfn &= ~mask;
+			*gfnp = gfn;
+			kvm_release_pfn_clean(pfn);
+			pfn &= ~mask;
+			if (!get_page_unless_zero(pfn_to_page(pfn)))
+				BUG();
+			*pfnp = pfn;
+		}
 	}
 }
 
@@ -2335,27 +2369,31 @@ static int nonpaging_map(struct kvm_vcpu
 {
 	int r;
 	int level;
+	int force_pt_level;
 	pfn_t pfn;
 	unsigned long mmu_seq;
 	bool map_writable;
 
-	level = mapping_level(vcpu, gfn);
-
-	/*
-	 * This path builds a PAE pagetable - so we can map 2mb pages at
-	 * maximum. Therefore check if the level is larger than that.
-	 */
-	if (level > PT_DIRECTORY_LEVEL)
-		level = PT_DIRECTORY_LEVEL;
+	force_pt_level = mapping_level_dirty_bitmap(vcpu, gfn);
+	if (likely(!force_pt_level)) {
+		level = mapping_level(vcpu, gfn);
+		/*
+		 * This path builds a PAE pagetable - so we can map
+		 * 2mb pages at maximum. Therefore check if the level
+		 * is larger than that.
+		 */
+		if (level > PT_DIRECTORY_LEVEL)
+			level = PT_DIRECTORY_LEVEL;
 
-	gfn &= ~(KVM_PAGES_PER_HPAGE(level) - 1);
+		gfn &= ~(KVM_PAGES_PER_HPAGE(level) - 1);
+	} else
+		level = PT_PAGE_TABLE_LEVEL;
 
 	mmu_seq = vcpu->kvm->mmu_notifier_seq;
 	smp_rmb();
 
 	if (try_async_pf(vcpu, prefault, gfn, v, &pfn, write, &map_writable))
 		return 0;
-	transparent_hugepage_adjust(&gfn, &pfn, &level);
 
 	/* mmio */
 	if (is_error_pfn(pfn))
@@ -2365,6 +2403,8 @@ static int nonpaging_map(struct kvm_vcpu
 	if (mmu_notifier_retry(vcpu, mmu_seq))
 		goto out_unlock;
 	kvm_mmu_free_some_pages(vcpu);
+	if (likely(!force_pt_level))
+		transparent_hugepage_adjust(vcpu, &gfn, &pfn, &level);
 	r = __direct_map(vcpu, v, write, map_writable, level, gfn, pfn,
 			 prefault);
 	spin_unlock(&vcpu->kvm->mmu_lock);
@@ -2701,6 +2741,7 @@ static int tdp_page_fault(struct kvm_vcp
 	pfn_t pfn;
 	int r;
 	int level;
+	int force_pt_level;
 	gfn_t gfn = gpa >> PAGE_SHIFT;
 	unsigned long mmu_seq;
 	int write = error_code & PFERR_WRITE_MASK;
@@ -2713,16 +2754,18 @@ static int tdp_page_fault(struct kvm_vcp
 	if (r)
 		return r;
 
-	level = mapping_level(vcpu, gfn);
-
-	gfn &= ~(KVM_PAGES_PER_HPAGE(level) - 1);
+	force_pt_level = mapping_level_dirty_bitmap(vcpu, gfn);
+	if (likely(!force_pt_level)) {
+		level = mapping_level(vcpu, gfn);
+		gfn &= ~(KVM_PAGES_PER_HPAGE(level) - 1);
+	} else
+		level = PT_PAGE_TABLE_LEVEL;
 
 	mmu_seq = vcpu->kvm->mmu_notifier_seq;
 	smp_rmb();
 
 	if (try_async_pf(vcpu, prefault, gfn, gpa, &pfn, write, &map_writable))
 		return 0;
-	transparent_hugepage_adjust(&gfn, &pfn, &level);
 
 	/* mmio */
 	if (is_error_pfn(pfn))
@@ -2731,6 +2774,8 @@ static int tdp_page_fault(struct kvm_vcp
 	if (mmu_notifier_retry(vcpu, mmu_seq))
 		goto out_unlock;
 	kvm_mmu_free_some_pages(vcpu);
+	if (likely(!force_pt_level))
+		transparent_hugepage_adjust(vcpu, &gfn, &pfn, &level);
 	r = __direct_map(vcpu, gpa, write, map_writable,
 			 level, gfn, pfn, prefault);
 	spin_unlock(&vcpu->kvm->mmu_lock);
--- a/arch/x86/kvm/paging_tmpl.h
+++ b/arch/x86/kvm/paging_tmpl.h
@@ -553,6 +553,7 @@ static int FNAME(page_fault)(struct kvm_
 	int r;
 	pfn_t pfn;
 	int level = PT_PAGE_TABLE_LEVEL;
+	int force_pt_level;
 	unsigned long mmu_seq;
 	bool map_writable;
 
@@ -580,7 +581,11 @@ static int FNAME(page_fault)(struct kvm_
 		return 0;
 	}
 
-	if (walker.level >= PT_DIRECTORY_LEVEL) {
+	if (walker.level >= PT_DIRECTORY_LEVEL)
+		force_pt_level = mapping_level_dirty_bitmap(vcpu, walker.gfn);
+	else
+		force_pt_level = 1;
+	if (!force_pt_level) {
 		level = min(walker.level, mapping_level(vcpu, walker.gfn));
 		walker.gfn = walker.gfn & ~(KVM_PAGES_PER_HPAGE(level) - 1);
 	}
@@ -591,7 +596,6 @@ static int FNAME(page_fault)(struct kvm_
 	if (try_async_pf(vcpu, prefault, walker.gfn, addr, &pfn, write_fault,
 			 &map_writable))
 		return 0;
-	transparent_hugepage_adjust(&walker.gfn, &pfn, &level);
 
 	/* mmio */
 	if (is_error_pfn(pfn))
@@ -603,6 +607,8 @@ static int FNAME(page_fault)(struct kvm_
 
 	trace_kvm_mmu_audit(vcpu, AUDIT_PRE_PAGE_FAULT);
 	kvm_mmu_free_some_pages(vcpu);
+	if (!force_pt_level)
+		transparent_hugepage_adjust(vcpu, &walker.gfn, &pfn, &level);
 	sptep = FNAME(fetch)(vcpu, addr, &walker, user_fault, write_fault,
 			     level, &write_pt, pfn, map_writable, prefault);
 	(void)sptep;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
