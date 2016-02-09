Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f171.google.com (mail-qk0-f171.google.com [209.85.220.171])
	by kanga.kvack.org (Postfix) with ESMTP id C7775828E2
	for <linux-mm@kvack.org>; Mon,  8 Feb 2016 20:20:52 -0500 (EST)
Received: by mail-qk0-f171.google.com with SMTP id s68so65494042qkh.3
        for <linux-mm@kvack.org>; Mon, 08 Feb 2016 17:20:52 -0800 (PST)
Received: from e18.ny.us.ibm.com (e18.ny.us.ibm.com. [129.33.205.208])
        by mx.google.com with ESMTPS id j106si29122336qge.40.2016.02.08.17.20.51
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 08 Feb 2016 17:20:51 -0800 (PST)
Received: from localhost
	by e18.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Mon, 8 Feb 2016 20:20:51 -0500
Received: from b01cxnp22036.gho.pok.ibm.com (b01cxnp22036.gho.pok.ibm.com [9.57.198.26])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 2D6E538C8041
	for <linux-mm@kvack.org>; Mon,  8 Feb 2016 20:20:47 -0500 (EST)
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by b01cxnp22036.gho.pok.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u191Kl5I32768216
	for <linux-mm@kvack.org>; Tue, 9 Feb 2016 01:20:47 GMT
Received: from d01av01.pok.ibm.com (localhost [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u191KkSI030131
	for <linux-mm@kvack.org>; Mon, 8 Feb 2016 20:20:46 -0500
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH V3] powerpc/mm: Fix Multi hit ERAT cause by recent THP update
Date: Tue,  9 Feb 2016 06:50:31 +0530
Message-Id: <1454980831-16631-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, akpm@linux-foundation.org, Mel Gorman <mgorman@techsingularity.net>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

With ppc64 we use the deposited pgtable_t to store the hash pte slot
information. We should not withdraw the deposited pgtable_t without
marking the pmd none. This ensure that low level hash fault handling
will skip this huge pte and we will handle them at upper levels.

Recent change to pmd splitting changed the above in order to handle the
race between pmd split and exit_mmap. The race is explained below.

Consider following race:

		CPU0				CPU1
shrink_page_list()
  add_to_swap()
    split_huge_page_to_list()
      __split_huge_pmd_locked()
        pmdp_huge_clear_flush_notify()
	// pmd_none() == true
					exit_mmap()
					  unmap_vmas()
					    zap_pmd_range()
					      // no action on pmd since pmd_none() == true
	pmd_populate()

As result the THP will not be freed. The leak is detected by check_mm():

	BUG: Bad rss-counter state mm:ffff880058d2e580 idx:1 val:512

The above required us to not mark pmd none during a pmd split.

The fix for ppc is to clear the huge pte of _PAGE_USER, so that low
level fault handling code skip this pte. At higher level we do take ptl
lock. That should serialze us against the pmd split. Once the lock is
acquired we do check the pmd again using pmd_same. That should always
return false for us and hence we should retry the access. We do the
pmd_same check in all case after taking plt with
THP (do_huge_pmd_wp_page, do_huge_pmd_numa_page and
huge_pmd_set_accessed)

Also make sure we wait for irq disable section in other cpus to finish
before flipping a huge pte entry with a regular pmd entry. Code paths
like find_linux_pte_or_hugepte depend on irq disable to get
a stable pte_t pointer. A parallel thp split need to make sure we
don't convert a pmd pte to a regular pmd entry without waiting for the
irq disable section to finish.

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 arch/powerpc/include/asm/book3s/64/pgtable.h |  4 ++++
 arch/powerpc/mm/pgtable_64.c                 | 35 +++++++++++++++++++++++++++-
 include/asm-generic/pgtable.h                |  8 +++++++
 mm/huge_memory.c                             |  1 +
 4 files changed, 47 insertions(+), 1 deletion(-)

diff --git a/arch/powerpc/include/asm/book3s/64/pgtable.h b/arch/powerpc/include/asm/book3s/64/pgtable.h
index 8d1c41d28318..ac07a30a7934 100644
--- a/arch/powerpc/include/asm/book3s/64/pgtable.h
+++ b/arch/powerpc/include/asm/book3s/64/pgtable.h
@@ -281,6 +281,10 @@ extern pgtable_t pgtable_trans_huge_withdraw(struct mm_struct *mm, pmd_t *pmdp);
 extern void pmdp_invalidate(struct vm_area_struct *vma, unsigned long address,
 			    pmd_t *pmdp);
 
+#define __HAVE_ARCH_PMDP_HUGE_SPLIT_PREPARE
+extern void pmdp_huge_split_prepare(struct vm_area_struct *vma,
+				    unsigned long address, pmd_t *pmdp);
+
 #define pmd_move_must_withdraw pmd_move_must_withdraw
 struct spinlock;
 static inline int pmd_move_must_withdraw(struct spinlock *new_pmd_ptl,
diff --git a/arch/powerpc/mm/pgtable_64.c b/arch/powerpc/mm/pgtable_64.c
index 3124a20d0fab..c8a00da39969 100644
--- a/arch/powerpc/mm/pgtable_64.c
+++ b/arch/powerpc/mm/pgtable_64.c
@@ -646,6 +646,30 @@ pgtable_t pgtable_trans_huge_withdraw(struct mm_struct *mm, pmd_t *pmdp)
 	return pgtable;
 }
 
+void pmdp_huge_split_prepare(struct vm_area_struct *vma,
+			     unsigned long address, pmd_t *pmdp)
+{
+	VM_BUG_ON(address & ~HPAGE_PMD_MASK);
+
+#ifdef CONFIG_DEBUG_VM
+	BUG_ON(REGION_ID(address) != USER_REGION_ID);
+#endif
+	/*
+	 * We can't mark the pmd none here, because that will cause a race
+	 * against exit_mmap. We need to continue mark pmd TRANS HUGE, while
+	 * we spilt, but at the same time we wan't rest of the ppc64 code
+	 * not to insert hash pte on this, because we will be modifying
+	 * the deposited pgtable in the caller of this function. Hence
+	 * clear the _PAGE_USER so that we move the fault handling to
+	 * higher level function and that will serialize against ptl.
+	 * We need to flush existing hash pte entries here even though,
+	 * the translation is still valid, because we will withdraw
+	 * pgtable_t after this.
+	 */
+	pmd_hugepage_update(vma->vm_mm, address, pmdp, _PAGE_USER, 0);
+}
+
+
 /*
  * set a new huge pmd. We should not be called for updating
  * an existing pmd entry. That should go via pmd_hugepage_update.
@@ -663,10 +687,19 @@ void set_pmd_at(struct mm_struct *mm, unsigned long addr,
 	return set_pte_at(mm, addr, pmdp_ptep(pmdp), pmd_pte(pmd));
 }
 
+/*
+ * We use this to invalidate a pmdp entry before switching from a
+ * hugepte to regular pmd entry.
+ */
 void pmdp_invalidate(struct vm_area_struct *vma, unsigned long address,
 		     pmd_t *pmdp)
 {
-	pmd_hugepage_update(vma->vm_mm, address, pmdp, _PAGE_PRESENT, 0);
+	pmd_hugepage_update(vma->vm_mm, address, pmdp, ~0UL, 0);
+	/*
+	 * This ensures that generic code that rely on IRQ disabling
+	 * to prevent a parallel THP split work as expected.
+	 */
+	kick_all_cpus_sync();
 }
 
 /*
diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
index 0b3c0d39ef75..c370b261c720 100644
--- a/include/asm-generic/pgtable.h
+++ b/include/asm-generic/pgtable.h
@@ -239,6 +239,14 @@ extern void pmdp_invalidate(struct vm_area_struct *vma, unsigned long address,
 			    pmd_t *pmdp);
 #endif
 
+#ifndef __HAVE_ARCH_PMDP_HUGE_SPLIT_PREPARE
+static inline void pmdp_huge_split_prepare(struct vm_area_struct *vma,
+					   unsigned long address, pmd_t *pmdp)
+{
+
+}
+#endif
+
 #ifndef __HAVE_ARCH_PTE_SAME
 static inline int pte_same(pte_t pte_a, pte_t pte_b)
 {
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 36c070167b71..cd26f3f14cab 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -2860,6 +2860,7 @@ static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
 	young = pmd_young(*pmd);
 	dirty = pmd_dirty(*pmd);
 
+	pmdp_huge_split_prepare(vma, haddr, pmd);
 	pgtable = pgtable_trans_huge_withdraw(mm, pmd);
 	pmd_populate(mm, &_pmd, pgtable);
 
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
