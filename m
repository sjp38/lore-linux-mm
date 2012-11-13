Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id EBE246B0080
	for <linux-mm@kvack.org>; Tue, 13 Nov 2012 12:14:54 -0500 (EST)
Received: by mail-ee0-f41.google.com with SMTP id d41so65876eek.14
        for <linux-mm@kvack.org>; Tue, 13 Nov 2012 09:14:54 -0800 (PST)
From: Ingo Molnar <mingo@kernel.org>
Subject: [PATCH 06/31] mm/thp: Preserve pgprot across huge page split
Date: Tue, 13 Nov 2012 18:13:29 +0100
Message-Id: <1352826834-11774-7-git-send-email-mingo@kernel.org>
In-Reply-To: <1352826834-11774-1-git-send-email-mingo@kernel.org>
References: <1352826834-11774-1-git-send-email-mingo@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Thomas Gleixner <tglx@linutronix.de>

From: Peter Zijlstra <a.p.zijlstra@chello.nl>

We're going to play games with page-protections, ensure we don't lose
them over a THP split.

Collapse seems to always allocate a new (huge) page which should
already end up on the new target node so loosing protections there
isn't a problem.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Reviewed-by: Rik van Riel <riel@redhat.com>
Cc: Paul Turner <pjt@google.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Link: http://lkml.kernel.org/n/tip-eyi25t4eh3l4cd2zp4k3bj6c@git.kernel.org
Signed-off-by: Ingo Molnar <mingo@kernel.org>
---
 arch/x86/include/asm/pgtable.h |   1 +
 mm/huge_memory.c               | 103 ++++++++++++++++++++---------------------
 2 files changed, 50 insertions(+), 54 deletions(-)

diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtable.h
index a1f780d..f85dccd 100644
--- a/arch/x86/include/asm/pgtable.h
+++ b/arch/x86/include/asm/pgtable.h
@@ -349,6 +349,7 @@ static inline pgprot_t pgprot_modify(pgprot_t oldprot, pgprot_t newprot)
 }
 
 #define pte_pgprot(x) __pgprot(pte_flags(x) & PTE_FLAGS_MASK)
+#define pmd_pgprot(x) __pgprot(pmd_val(x) & ~_HPAGE_CHG_MASK)
 
 #define canon_pgprot(p) __pgprot(massage_pgprot(p))
 
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 40f17c3..176fe3d 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1343,63 +1343,60 @@ static int __split_huge_page_map(struct page *page,
 	int ret = 0, i;
 	pgtable_t pgtable;
 	unsigned long haddr;
+	pgprot_t prot;
 
 	spin_lock(&mm->page_table_lock);
 	pmd = page_check_address_pmd(page, mm, address,
 				     PAGE_CHECK_ADDRESS_PMD_SPLITTING_FLAG);
-	if (pmd) {
-		pgtable = pgtable_trans_huge_withdraw(mm);
-		pmd_populate(mm, &_pmd, pgtable);
-
-		haddr = address;
-		for (i = 0; i < HPAGE_PMD_NR; i++, haddr += PAGE_SIZE) {
-			pte_t *pte, entry;
-			BUG_ON(PageCompound(page+i));
-			entry = mk_pte(page + i, vma->vm_page_prot);
-			entry = maybe_mkwrite(pte_mkdirty(entry), vma);
-			if (!pmd_write(*pmd))
-				entry = pte_wrprotect(entry);
-			else
-				BUG_ON(page_mapcount(page) != 1);
-			if (!pmd_young(*pmd))
-				entry = pte_mkold(entry);
-			pte = pte_offset_map(&_pmd, haddr);
-			BUG_ON(!pte_none(*pte));
-			set_pte_at(mm, haddr, pte, entry);
-			pte_unmap(pte);
-		}
+	if (!pmd)
+		goto unlock;
 
-		smp_wmb(); /* make pte visible before pmd */
-		/*
-		 * Up to this point the pmd is present and huge and
-		 * userland has the whole access to the hugepage
-		 * during the split (which happens in place). If we
-		 * overwrite the pmd with the not-huge version
-		 * pointing to the pte here (which of course we could
-		 * if all CPUs were bug free), userland could trigger
-		 * a small page size TLB miss on the small sized TLB
-		 * while the hugepage TLB entry is still established
-		 * in the huge TLB. Some CPU doesn't like that. See
-		 * http://support.amd.com/us/Processor_TechDocs/41322.pdf,
-		 * Erratum 383 on page 93. Intel should be safe but is
-		 * also warns that it's only safe if the permission
-		 * and cache attributes of the two entries loaded in
-		 * the two TLB is identical (which should be the case
-		 * here). But it is generally safer to never allow
-		 * small and huge TLB entries for the same virtual
-		 * address to be loaded simultaneously. So instead of
-		 * doing "pmd_populate(); flush_tlb_range();" we first
-		 * mark the current pmd notpresent (atomically because
-		 * here the pmd_trans_huge and pmd_trans_splitting
-		 * must remain set at all times on the pmd until the
-		 * split is complete for this pmd), then we flush the
-		 * SMP TLB and finally we write the non-huge version
-		 * of the pmd entry with pmd_populate.
-		 */
-		pmdp_invalidate(vma, address, pmd);
-		pmd_populate(mm, pmd, pgtable);
-		ret = 1;
+	prot = pmd_pgprot(*pmd);
+	pgtable = pgtable_trans_huge_withdraw(mm);
+	pmd_populate(mm, &_pmd, pgtable);
+
+	for (i = 0, haddr = address; i < HPAGE_PMD_NR; i++, haddr += PAGE_SIZE) {
+		pte_t *pte, entry;
+
+		BUG_ON(PageCompound(page+i));
+		entry = mk_pte(page + i, prot);
+		entry = pte_mkdirty(entry);
+		if (!pmd_young(*pmd))
+			entry = pte_mkold(entry);
+		pte = pte_offset_map(&_pmd, haddr);
+		BUG_ON(!pte_none(*pte));
+		set_pte_at(mm, haddr, pte, entry);
+		pte_unmap(pte);
 	}
+
+	smp_wmb(); /* make ptes visible before pmd, see __pte_alloc */
+	/*
+	 * Up to this point the pmd is present and huge.
+	 *
+	 * If we overwrite the pmd with the not-huge version, we could trigger
+	 * a small page size TLB miss on the small sized TLB while the hugepage
+	 * TLB entry is still established in the huge TLB.
+	 *
+	 * Some CPUs don't like that. See
+	 * http://support.amd.com/us/Processor_TechDocs/41322.pdf, Erratum 383
+	 * on page 93.
+	 *
+	 * Thus it is generally safer to never allow small and huge TLB entries
+	 * for overlapping virtual addresses to be loaded. So we first mark the
+	 * current pmd not present, then we flush the TLB and finally we write
+	 * the non-huge version of the pmd entry with pmd_populate.
+	 *
+	 * The above needs to be done under the ptl because pmd_trans_huge and
+	 * pmd_trans_splitting must remain set on the pmd until the split is
+	 * complete. The ptl also protects against concurrent faults due to
+	 * making the pmd not-present.
+	 */
+	set_pmd_at(mm, address, pmd, pmd_mknotpresent(*pmd));
+	flush_tlb_range(vma, address, address + HPAGE_PMD_SIZE);
+	pmd_populate(mm, pmd, pgtable);
+	ret = 1;
+
+unlock:
 	spin_unlock(&mm->page_table_lock);
 
 	return ret;
@@ -2287,10 +2284,8 @@ static void khugepaged_do_scan(void)
 {
 	struct page *hpage = NULL;
 	unsigned int progress = 0, pass_through_head = 0;
-	unsigned int pages = khugepaged_pages_to_scan;
 	bool wait = true;
-
-	barrier(); /* write khugepaged_pages_to_scan to local stack */
+	unsigned int pages = ACCESS_ONCE(khugepaged_pages_to_scan);
 
 	while (progress < pages) {
 		if (!khugepaged_prealloc_page(&hpage, &wait))
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
