Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f50.google.com (mail-pb0-f50.google.com [209.85.160.50])
	by kanga.kvack.org (Postfix) with ESMTP id 203E26B004D
	for <linux-mm@kvack.org>; Mon,  7 Oct 2013 09:54:41 -0400 (EDT)
Received: by mail-pb0-f50.google.com with SMTP id uo5so7172176pbc.9
        for <linux-mm@kvack.org>; Mon, 07 Oct 2013 06:54:40 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv5 06/11] mm, thp: move ptl taking inside page_check_address_pmd()
Date: Mon,  7 Oct 2013 16:54:08 +0300
Message-Id: <1381154053-4848-7-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1381154053-4848-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1381154053-4848-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alex Thorlton <athorlton@sgi.com>, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: "Eric W . Biederman" <ebiederm@xmission.com>, "Paul E . McKenney" <paulmck@linux.vnet.ibm.com>, Al Viro <viro@zeniv.linux.org.uk>, Andi Kleen <ak@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Dave Jones <davej@redhat.com>, David Howells <dhowells@redhat.com>, Frederic Weisbecker <fweisbec@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Kees Cook <keescook@chromium.org>, Mel Gorman <mgorman@suse.de>, Michael Kerrisk <mtk.manpages@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Robin Holt <robinmholt@gmail.com>, Sedat Dilek <sedat.dilek@gmail.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

With split page table lock we can't know which lock we need to take
before we find the relevant pmd.

Let's move lock taking inside the function.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Tested-by: Alex Thorlton <athorlton@sgi.com>
---
 include/linux/huge_mm.h |  3 ++-
 mm/huge_memory.c        | 43 +++++++++++++++++++++++++++----------------
 mm/rmap.c               | 13 +++++--------
 3 files changed, 34 insertions(+), 25 deletions(-)

diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index 4aca0d8da1..91672e2dee 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -54,7 +54,8 @@ enum page_check_address_pmd_flag {
 extern pmd_t *page_check_address_pmd(struct page *page,
 				     struct mm_struct *mm,
 				     unsigned long address,
-				     enum page_check_address_pmd_flag flag);
+				     enum page_check_address_pmd_flag flag,
+				     spinlock_t **ptl);
 
 #define HPAGE_PMD_ORDER (HPAGE_PMD_SHIFT-PAGE_SHIFT)
 #define HPAGE_PMD_NR (1<<HPAGE_PMD_ORDER)
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index fc8137cb9a..f39fd28768 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1500,23 +1500,33 @@ int __pmd_trans_huge_lock(pmd_t *pmd, struct vm_area_struct *vma,
 	return 0;
 }
 
+/*
+ * This function returns whether a given @page is mapped onto the @address
+ * in the virtual space of @mm.
+ *
+ * When it's true, this function returns *pmd with holding the page table lock
+ * and passing it back to the caller via @ptl.
+ * If it's false, returns NULL without holding the page table lock.
+ */
 pmd_t *page_check_address_pmd(struct page *page,
 			      struct mm_struct *mm,
 			      unsigned long address,
-			      enum page_check_address_pmd_flag flag)
+			      enum page_check_address_pmd_flag flag,
+			      spinlock_t **ptl)
 {
-	pmd_t *pmd, *ret = NULL;
+	pmd_t *pmd;
 
 	if (address & ~HPAGE_PMD_MASK)
-		goto out;
+		return NULL;
 
 	pmd = mm_find_pmd(mm, address);
 	if (!pmd)
-		goto out;
+		return NULL;
+	*ptl = pmd_lock(mm, pmd);
 	if (pmd_none(*pmd))
-		goto out;
+		goto unlock;
 	if (pmd_page(*pmd) != page)
-		goto out;
+		goto unlock;
 	/*
 	 * split_vma() may create temporary aliased mappings. There is
 	 * no risk as long as all huge pmd are found and have their
@@ -1526,14 +1536,15 @@ pmd_t *page_check_address_pmd(struct page *page,
 	 */
 	if (flag == PAGE_CHECK_ADDRESS_PMD_NOTSPLITTING_FLAG &&
 	    pmd_trans_splitting(*pmd))
-		goto out;
+		goto unlock;
 	if (pmd_trans_huge(*pmd)) {
 		VM_BUG_ON(flag == PAGE_CHECK_ADDRESS_PMD_SPLITTING_FLAG &&
 			  !pmd_trans_splitting(*pmd));
-		ret = pmd;
+		return pmd;
 	}
-out:
-	return ret;
+unlock:
+	spin_unlock(*ptl);
+	return NULL;
 }
 
 static int __split_huge_page_splitting(struct page *page,
@@ -1541,6 +1552,7 @@ static int __split_huge_page_splitting(struct page *page,
 				       unsigned long address)
 {
 	struct mm_struct *mm = vma->vm_mm;
+	spinlock_t *ptl;
 	pmd_t *pmd;
 	int ret = 0;
 	/* For mmu_notifiers */
@@ -1548,9 +1560,8 @@ static int __split_huge_page_splitting(struct page *page,
 	const unsigned long mmun_end   = address + HPAGE_PMD_SIZE;
 
 	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end);
-	spin_lock(&mm->page_table_lock);
 	pmd = page_check_address_pmd(page, mm, address,
-				     PAGE_CHECK_ADDRESS_PMD_NOTSPLITTING_FLAG);
+			PAGE_CHECK_ADDRESS_PMD_NOTSPLITTING_FLAG, &ptl);
 	if (pmd) {
 		/*
 		 * We can't temporarily set the pmd to null in order
@@ -1561,8 +1572,8 @@ static int __split_huge_page_splitting(struct page *page,
 		 */
 		pmdp_splitting_flush(vma, address, pmd);
 		ret = 1;
+		spin_unlock(ptl);
 	}
-	spin_unlock(&mm->page_table_lock);
 	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
 
 	return ret;
@@ -1693,14 +1704,14 @@ static int __split_huge_page_map(struct page *page,
 				 unsigned long address)
 {
 	struct mm_struct *mm = vma->vm_mm;
+	spinlock_t *ptl;
 	pmd_t *pmd, _pmd;
 	int ret = 0, i;
 	pgtable_t pgtable;
 	unsigned long haddr;
 
-	spin_lock(&mm->page_table_lock);
 	pmd = page_check_address_pmd(page, mm, address,
-				     PAGE_CHECK_ADDRESS_PMD_SPLITTING_FLAG);
+			PAGE_CHECK_ADDRESS_PMD_SPLITTING_FLAG, &ptl);
 	if (pmd) {
 		pgtable = pgtable_trans_huge_withdraw(mm, pmd);
 		pmd_populate(mm, &_pmd, pgtable);
@@ -1755,8 +1766,8 @@ static int __split_huge_page_map(struct page *page,
 		pmdp_invalidate(vma, address, pmd);
 		pmd_populate(mm, pmd, pgtable);
 		ret = 1;
+		spin_unlock(ptl);
 	}
-	spin_unlock(&mm->page_table_lock);
 
 	return ret;
 }
diff --git a/mm/rmap.c b/mm/rmap.c
index fd3ee7a54a..b59d741dcf 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -665,25 +665,23 @@ int page_referenced_one(struct page *page, struct vm_area_struct *vma,
 			unsigned long *vm_flags)
 {
 	struct mm_struct *mm = vma->vm_mm;
+	spinlock_t *ptl;
 	int referenced = 0;
 
 	if (unlikely(PageTransHuge(page))) {
 		pmd_t *pmd;
 
-		spin_lock(&mm->page_table_lock);
 		/*
 		 * rmap might return false positives; we must filter
 		 * these out using page_check_address_pmd().
 		 */
 		pmd = page_check_address_pmd(page, mm, address,
-					     PAGE_CHECK_ADDRESS_PMD_FLAG);
-		if (!pmd) {
-			spin_unlock(&mm->page_table_lock);
+					     PAGE_CHECK_ADDRESS_PMD_FLAG, &ptl);
+		if (!pmd)
 			goto out;
-		}
 
 		if (vma->vm_flags & VM_LOCKED) {
-			spin_unlock(&mm->page_table_lock);
+			spin_unlock(ptl);
 			*mapcount = 0;	/* break early from loop */
 			*vm_flags |= VM_LOCKED;
 			goto out;
@@ -692,10 +690,9 @@ int page_referenced_one(struct page *page, struct vm_area_struct *vma,
 		/* go ahead even if the pmd is pmd_trans_splitting() */
 		if (pmdp_clear_flush_young_notify(vma, address, pmd))
 			referenced++;
-		spin_unlock(&mm->page_table_lock);
+		spin_unlock(ptl);
 	} else {
 		pte_t *pte;
-		spinlock_t *ptl;
 
 		/*
 		 * rmap might return false positives; we must filter
-- 
1.8.4.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
