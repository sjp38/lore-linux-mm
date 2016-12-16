Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f198.google.com (mail-ua0-f198.google.com [209.85.217.198])
	by kanga.kvack.org (Postfix) with ESMTP id 84F206B0266
	for <linux-mm@kvack.org>; Fri, 16 Dec 2016 13:36:03 -0500 (EST)
Received: by mail-ua0-f198.google.com with SMTP id 51so45225632uai.3
        for <linux-mm@kvack.org>; Fri, 16 Dec 2016 10:36:03 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id e10si2467047uaa.209.2016.12.16.10.36.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Dec 2016 10:36:02 -0800 (PST)
From: Mike Kravetz <mike.kravetz@oracle.com>
Subject: [RFC PATCH 06/14] sparc64: general shared context tsb creation and support
Date: Fri, 16 Dec 2016 10:35:29 -0800
Message-Id: <1481913337-9331-7-git-send-email-mike.kravetz@oracle.com>
In-Reply-To: <1481913337-9331-1-git-send-email-mike.kravetz@oracle.com>
References: <1481913337-9331-1-git-send-email-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: sparclinux@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: "David S . Miller" <davem@davemloft.net>, Bob Picco <bob.picco@oracle.com>, Nitin Gupta <nitin.m.gupta@oracle.com>, Vijay Kumar <vijay.ac.kumar@oracle.com>, Julian Calaby <julian.calaby@gmail.com>, Adam Buchbinder <adam.buchbinder@gmail.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Andrew Morton <akpm@linux-foundation.org>, Mike Kravetz <mike.kravetz@oracle.com>

Take into account the shared context TSB when creating and updating
TSBs.  Existing routines are modified to key off the TSB index or
PTE flag (_PAGE_SHR_CTX_4V) to determine this is a shared context
operation.

With shared context support the sun4v TSB descriptor array could
contain a 'hole' if there is a shared context TSB and no huge page
TSB. An array with a hole can not be bassed to the hypervisor, so
make sure no hole exists in the array.

For shared context TSBs, the context index in the hypervisor descriptor
structure is set to 1.  This indicates the context ID stored in context
register 1 should be used for TLB matching.

This commit does NOT load the shared context TSB into the hv MMU.

Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
---
 arch/sparc/mm/fault_64.c    | 10 ++++++++++
 arch/sparc/mm/hugetlbpage.c | 20 ++++++++++++++++----
 arch/sparc/mm/init_64.c     | 42 +++++++++++++++++++++++++++++++++++++++---
 arch/sparc/mm/tsb.c         | 41 ++++++++++++++++++++++++++++++++++++++++-
 4 files changed, 105 insertions(+), 8 deletions(-)

diff --git a/arch/sparc/mm/fault_64.c b/arch/sparc/mm/fault_64.c
index 643c149..2b82cdb 100644
--- a/arch/sparc/mm/fault_64.c
+++ b/arch/sparc/mm/fault_64.c
@@ -493,6 +493,16 @@ asmlinkage void __kprobes do_sparc64_fault(struct pt_regs *regs)
 			hugetlb_setup(regs);
 
 	}
+#if defined(CONFIG_SHARED_MMU_CTX)
+	mm_rss = mm->context.shared_hugetlb_pte_count * REAL_HPAGE_PER_HPAGE;
+	if (unlikely(mm_shared_ctx_val(mm) && mm_rss >
+		     mm->context.tsb_block[MM_TSB_HUGE_SHARED].tsb_rss_limit)) {
+		if (mm->context.tsb_block[MM_TSB_HUGE_SHARED].tsb)
+			tsb_grow(mm, MM_TSB_HUGE_SHARED, mm_rss);
+		else
+			hugetlb_shared_setup(regs);
+	}
+#endif
 #endif
 exit_exception:
 	exception_exit(prev_state);
diff --git a/arch/sparc/mm/hugetlbpage.c b/arch/sparc/mm/hugetlbpage.c
index 988acc8b..2039d45 100644
--- a/arch/sparc/mm/hugetlbpage.c
+++ b/arch/sparc/mm/hugetlbpage.c
@@ -162,8 +162,14 @@ void set_huge_pte_at(struct mm_struct *mm, unsigned long addr,
 {
 	pte_t orig;
 
-	if (!pte_present(*ptep) && pte_present(entry))
-		mm->context.hugetlb_pte_count++;
+	if (!pte_present(*ptep) && pte_present(entry)) {
+#if defined(CONFIG_SHARED_MMU_CTX)
+		if (pte_val(entry) | _PAGE_SHR_CTX_4V)
+			mm->context.shared_hugetlb_pte_count++;
+		else
+#endif
+			mm->context.hugetlb_pte_count++;
+	}
 
 	addr &= HPAGE_MASK;
 	orig = *ptep;
@@ -180,8 +186,14 @@ pte_t huge_ptep_get_and_clear(struct mm_struct *mm, unsigned long addr,
 	pte_t entry;
 
 	entry = *ptep;
-	if (pte_present(entry))
-		mm->context.hugetlb_pte_count--;
+	if (pte_present(entry)) {
+#if defined(CONFIG_SHARED_MMU_CTX)
+		if (pte_val(entry) | _PAGE_SHR_CTX_4V)
+			mm->context.shared_hugetlb_pte_count--;
+		else
+#endif
+			mm->context.hugetlb_pte_count--;
+	}
 
 	addr &= HPAGE_MASK;
 	*ptep = __pte(0UL);
diff --git a/arch/sparc/mm/init_64.c b/arch/sparc/mm/init_64.c
index bb9a6ee..2b310e5 100644
--- a/arch/sparc/mm/init_64.c
+++ b/arch/sparc/mm/init_64.c
@@ -346,6 +346,21 @@ void update_mmu_cache(struct vm_area_struct *vma, unsigned long address, pte_t *
 	spin_lock_irqsave(&mm->context.lock, flags);
 
 #if defined(CONFIG_HUGETLB_PAGE) || defined(CONFIG_TRANSPARENT_HUGEPAGE)
+#if defined(CONFIG_SHARED_MMU_CTX)
+	if ((mm->context.hugetlb_pte_count || mm->context.thp_pte_count ||
+	    mm->context.shared_hugetlb_pte_count) && is_hugetlb_pte(pte)) {
+		/* We are fabricating 8MB pages using 4MB real hw pages.  */
+		pte_val(pte) |= (address & (1UL << REAL_HPAGE_SHIFT));
+		if (is_sharedctx_pte(pte))
+			__update_mmu_tsb_insert(mm, MM_TSB_HUGE_SHARED,
+					REAL_HPAGE_SHIFT, address,
+					pte_val(pte));
+		else
+			__update_mmu_tsb_insert(mm, MM_TSB_HUGE,
+					REAL_HPAGE_SHIFT, address,
+					pte_val(pte));
+	} else
+#else
 	if ((mm->context.hugetlb_pte_count || mm->context.thp_pte_count) &&
 	    is_hugetlb_pte(pte)) {
 		/* We are fabricating 8MB pages using 4MB real hw pages.  */
@@ -354,6 +369,7 @@ void update_mmu_cache(struct vm_area_struct *vma, unsigned long address, pte_t *
 					address, pte_val(pte));
 	} else
 #endif
+#endif
 		__update_mmu_tsb_insert(mm, MM_TSB_BASE, PAGE_SHIFT,
 					address, pte_val(pte));
 
@@ -2915,7 +2931,7 @@ static void context_reload(void *__data)
 		load_secondary_context(mm);
 }
 
-void hugetlb_setup(struct pt_regs *regs)
+static void __hugetlb_setup_common(struct pt_regs *regs, unsigned long tsb_idx)
 {
 	struct mm_struct *mm = current->mm;
 	struct tsb_config *tp;
@@ -2933,15 +2949,18 @@ void hugetlb_setup(struct pt_regs *regs)
 		die_if_kernel("HugeTSB in atomic", regs);
 	}
 
-	tp = &mm->context.tsb_block[MM_TSB_HUGE];
+	tp = &mm->context.tsb_block[tsb_idx];
 	if (likely(tp->tsb == NULL))
-		tsb_grow(mm, MM_TSB_HUGE, 0);
+		tsb_grow(mm, tsb_idx, 0);
 
 	tsb_context_switch(mm);
 	smp_tsb_sync(mm);
 
 	/* On UltraSPARC-III+ and later, configure the second half of
 	 * the Data-TLB for huge pages.
+	 *
+	 * Note that the following does not execute on platforms where
+	 * shared context is supported.
 	 */
 	if (tlb_type == cheetah_plus) {
 		bool need_context_reload = false;
@@ -2974,6 +2993,23 @@ void hugetlb_setup(struct pt_regs *regs)
 			on_each_cpu(context_reload, mm, 0);
 	}
 }
+
+void hugetlb_setup(struct pt_regs *regs)
+{
+	__hugetlb_setup_common(regs, MM_TSB_HUGE);
+}
+
+#if defined(CONFIG_SHARED_MMU_CTX)
+void hugetlb_shared_setup(struct pt_regs *regs)
+{
+	__hugetlb_setup_common(regs, MM_TSB_HUGE_SHARED);
+}
+#else
+void hugetlb_shared_setup(struct pt_regs *regs)
+{
+	BUG();
+}
+#endif
 #endif
 
 static struct resource code_resource = {
diff --git a/arch/sparc/mm/tsb.c b/arch/sparc/mm/tsb.c
index 8c2d148..0b684de 100644
--- a/arch/sparc/mm/tsb.c
+++ b/arch/sparc/mm/tsb.c
@@ -108,6 +108,12 @@ void flush_tsb_user(struct tlb_batch *tb)
 			base = __pa(base);
 		__flush_tsb_one(tb, REAL_HPAGE_SHIFT, base, nentries);
 	}
+
+	/*
+	 * FIXME
+	 * I don't "think" we want to flush shared context tsb entries here.
+	 * There should at least be a comment.
+	 */
 #endif
 	spin_unlock_irqrestore(&mm->context.lock, flags);
 }
@@ -133,6 +139,11 @@ void flush_tsb_user_page(struct mm_struct *mm, unsigned long vaddr, bool huge)
 			base = __pa(base);
 		__flush_tsb_one_entry(base, vaddr, REAL_HPAGE_SHIFT, nentries);
 	}
+	/*
+	 * FIXME
+	 * Again, we should give more thought to the need for flushing
+	 * shared context pages.  At least a comment is needed.
+	 */
 #endif
 	spin_unlock_irqrestore(&mm->context.lock, flags);
 }
@@ -159,6 +170,7 @@ static void setup_tsb_params(struct mm_struct *mm, unsigned long tsb_idx, unsign
 		break;
 #if defined(CONFIG_HUGETLB_PAGE) || defined(CONFIG_TRANSPARENT_HUGEPAGE)
 	case MM_TSB_HUGE:
+	case MM_TSB_HUGE_SHARED:
 		base = TSBMAP_4M_BASE;
 		break;
 #endif
@@ -251,6 +263,7 @@ static void setup_tsb_params(struct mm_struct *mm, unsigned long tsb_idx, unsign
 			break;
 #if defined(CONFIG_HUGETLB_PAGE) || defined(CONFIG_TRANSPARENT_HUGEPAGE)
 		case MM_TSB_HUGE:
+		case MM_TSB_HUGE_SHARED:
 			hp->pgsz_idx = HV_PGSZ_IDX_HUGE;
 			break;
 #endif
@@ -260,12 +273,21 @@ static void setup_tsb_params(struct mm_struct *mm, unsigned long tsb_idx, unsign
 		hp->assoc = 1;
 		hp->num_ttes = tsb_bytes / 16;
 		hp->ctx_idx = 0;
+
+#if defined(CONFIG_SHARED_MMU_CTX)
+		/*
+		 * For shared context TSBs, adjust the context register index
+		 */
+		if (mm->context.shared_ctx && tsb_idx == MM_TSB_HUGE_SHARED)
+			hp->ctx_idx = 1;
+#endif
 		switch (tsb_idx) {
 		case MM_TSB_BASE:
 			hp->pgsz_mask = HV_PGSZ_MASK_BASE;
 			break;
 #if defined(CONFIG_HUGETLB_PAGE) || defined(CONFIG_TRANSPARENT_HUGEPAGE)
 		case MM_TSB_HUGE:
+		case MM_TSB_HUGE_SHARED:
 			hp->pgsz_mask = HV_PGSZ_MASK_HUGE;
 			break;
 #endif
@@ -520,12 +542,18 @@ int init_new_context(struct task_struct *tsk, struct mm_struct *mm)
 #if defined(CONFIG_HUGETLB_PAGE) || defined(CONFIG_TRANSPARENT_HUGEPAGE)
 	unsigned long saved_hugetlb_pte_count;
 	unsigned long saved_thp_pte_count;
+#if defined(CONFIG_SHARED_MMU_CTX)
+	unsigned long saved_shared_hugetlb_pte_count;
+#endif
 #endif
 	unsigned int i;
 
 	spin_lock_init(&mm->context.lock);
 
 	mm->context.sparc64_ctx_val = 0UL;
+#if defined(CONFIG_SHARED_MMU_CTX)
+	mm->context.shared_ctx = NULL;
+#endif
 
 #if defined(CONFIG_HUGETLB_PAGE) || defined(CONFIG_TRANSPARENT_HUGEPAGE)
 	/* We reset them to zero because the fork() page copying
@@ -536,6 +564,10 @@ int init_new_context(struct task_struct *tsk, struct mm_struct *mm)
 	saved_thp_pte_count = mm->context.thp_pte_count;
 	mm->context.hugetlb_pte_count = 0;
 	mm->context.thp_pte_count = 0;
+#if defined(CONFIG_SHARED_MMU_CTX)
+	saved_shared_hugetlb_pte_count = mm->context.shared_hugetlb_pte_count;
+	mm->context.shared_hugetlb_pte_count = 0;
+#endif
 
 	mm_rss -= saved_thp_pte_count * (HPAGE_SIZE / PAGE_SIZE);
 #endif
@@ -544,8 +576,10 @@ int init_new_context(struct task_struct *tsk, struct mm_struct *mm)
 	 * us, so we need to zero out the TSB pointer or else tsb_grow()
 	 * will be confused and think there is an older TSB to free up.
 	 */
-	for (i = 0; i < MM_NUM_TSBS; i++)
+	for (i = 0; i < MM_NUM_TSBS; i++) {
 		mm->context.tsb_block[i].tsb = NULL;
+		mm->context.tsb_descr[i].tsb_base = 0UL;
+	}
 
 	/* If this is fork, inherit the parent's TSB size.  We would
 	 * grow it to that size on the first page fault anyways.
@@ -557,6 +591,11 @@ int init_new_context(struct task_struct *tsk, struct mm_struct *mm)
 		tsb_grow(mm, MM_TSB_HUGE,
 			 (saved_hugetlb_pte_count + saved_thp_pte_count) *
 			 REAL_HPAGE_PER_HPAGE);
+#if defined(CONFIG_SHARED_MMU_CTX)
+	if (unlikely(saved_shared_hugetlb_pte_count))
+		tsb_grow(mm, MM_TSB_HUGE_SHARED,
+			saved_shared_hugetlb_pte_count * REAL_HPAGE_PER_HPAGE);
+#endif
 #endif
 
 	if (unlikely(!mm->context.tsb_block[MM_TSB_BASE].tsb))
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
