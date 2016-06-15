Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id E80C46B0260
	for <linux-mm@kvack.org>; Wed, 15 Jun 2016 16:07:01 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id a64so40674905oii.1
        for <linux-mm@kvack.org>; Wed, 15 Jun 2016 13:07:01 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id xr1si9588968pab.95.2016.06.15.13.06.55
        for <linux-mm@kvack.org>;
        Wed, 15 Jun 2016 13:06:55 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv9-rebased2 01/37] mm, thp: make swapin readahead under down_read of mmap_sem
Date: Wed, 15 Jun 2016 23:06:06 +0300
Message-Id: <1466021202-61880-2-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1466021202-61880-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1465222029-45942-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1466021202-61880-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Jerome Marchand <jmarchan@redhat.com>, Yang Shi <yang.shi@linaro.org>, Sasha Levin <sasha.levin@oracle.com>, Andres Lagar-Cavilla <andreslc@google.com>, Ning Qu <quning@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Ebru Akagunduz <ebru.akagunduz@gmail.com>, Rik van Riel <riel@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Minchan Kim <minchan.kim@gmail.com>

From: Ebru Akagunduz <ebru.akagunduz@gmail.com>

Currently khugepaged makes swapin readahead under down_write.  This patch
supplies to make swapin readahead under down_read instead of down_write.

The patch was tested with a test program that allocates 800MB of memory,
writes to it, and then sleeps.  The system was forced to swap out all.
Afterwards, the test program touches the area by writing, it skips a page
in each 20 pages of the area.

Link: http://lkml.kernel.org/r/1464335964-6510-4-git-send-email-ebru.akagunduz@gmail.com
Signed-off-by: Ebru Akagunduz <ebru.akagunduz@gmail.com>
Cc: Hugh Dickins <hughd@google.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Cyrill Gorcunov <gorcunov@openvz.org>
Cc: Mel Gorman <mgorman@suse.de>
Cc: David Rientjes <rientjes@google.com>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.cz>
Cc: Minchan Kim <minchan.kim@gmail.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---
 mm/huge_memory.c | 92 ++++++++++++++++++++++++++++++++++++++------------------
 1 file changed, 63 insertions(+), 29 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index f2bc57c45d2f..96dfe3f09bf6 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -2378,6 +2378,35 @@ static bool hugepage_vma_check(struct vm_area_struct *vma)
 }
 
 /*
+ * If mmap_sem temporarily dropped, revalidate vma
+ * before taking mmap_sem.
+ * Return 0 if succeeds, otherwise return none-zero
+ * value (scan code).
+ */
+
+static int hugepage_vma_revalidate(struct mm_struct *mm,
+				   struct vm_area_struct *vma,
+				   unsigned long address)
+{
+	unsigned long hstart, hend;
+
+	if (unlikely(khugepaged_test_exit(mm)))
+		return SCAN_ANY_PROCESS;
+
+	vma = find_vma(mm, address);
+	if (!vma)
+		return SCAN_VMA_NULL;
+
+	hstart = (vma->vm_start + ~HPAGE_PMD_MASK) & HPAGE_PMD_MASK;
+	hend = vma->vm_end & HPAGE_PMD_MASK;
+	if (address < hstart || address + HPAGE_PMD_SIZE > hend)
+		return SCAN_ADDRESS_RANGE;
+	if (!hugepage_vma_check(vma))
+		return SCAN_VMA_CHECK;
+	return 0;
+}
+
+/*
  * Bring missing pages in from swap, to complete THP collapse.
  * Only done if khugepaged_scan_pmd believes it is worthwhile.
  *
@@ -2385,7 +2414,7 @@ static bool hugepage_vma_check(struct vm_area_struct *vma)
  * but with mmap_sem held to protect against vma changes.
  */
 
-static void __collapse_huge_page_swapin(struct mm_struct *mm,
+static bool __collapse_huge_page_swapin(struct mm_struct *mm,
 					struct vm_area_struct *vma,
 					unsigned long address, pmd_t *pmd)
 {
@@ -2401,11 +2430,18 @@ static void __collapse_huge_page_swapin(struct mm_struct *mm,
 			continue;
 		swapped_in++;
 		ret = do_swap_page(mm, vma, _address, pte, pmd,
-				   FAULT_FLAG_ALLOW_RETRY|FAULT_FLAG_RETRY_NOWAIT,
+				   FAULT_FLAG_ALLOW_RETRY,
 				   pteval);
+		/* do_swap_page returns VM_FAULT_RETRY with released mmap_sem */
+		if (ret & VM_FAULT_RETRY) {
+			down_read(&mm->mmap_sem);
+			/* vma is no longer available, don't continue to swapin */
+			if (hugepage_vma_revalidate(mm, vma, address))
+				return false;
+		}
 		if (ret & VM_FAULT_ERROR) {
 			trace_mm_collapse_huge_page_swapin(mm, swapped_in, 0);
-			return;
+			return false;
 		}
 		/* pte is unmapped now, we need to map it */
 		pte = pte_offset_map(pmd, _address);
@@ -2413,6 +2449,7 @@ static void __collapse_huge_page_swapin(struct mm_struct *mm,
 	pte--;
 	pte_unmap(pte);
 	trace_mm_collapse_huge_page_swapin(mm, swapped_in, 1);
+	return true;
 }
 
 static void collapse_huge_page(struct mm_struct *mm,
@@ -2427,7 +2464,6 @@ static void collapse_huge_page(struct mm_struct *mm,
 	struct page *new_page;
 	spinlock_t *pmd_ptl, *pte_ptl;
 	int isolated = 0, result = 0;
-	unsigned long hstart, hend;
 	struct mem_cgroup *memcg;
 	unsigned long mmun_start;	/* For mmu_notifiers */
 	unsigned long mmun_end;		/* For mmu_notifiers */
@@ -2450,39 +2486,37 @@ static void collapse_huge_page(struct mm_struct *mm,
 		goto out_nolock;
 	}
 
-	/*
-	 * Prevent all access to pagetables with the exception of
-	 * gup_fast later hanlded by the ptep_clear_flush and the VM
-	 * handled by the anon_vma lock + PG_lock.
-	 */
-	down_write(&mm->mmap_sem);
-	if (unlikely(khugepaged_test_exit(mm))) {
-		result = SCAN_ANY_PROCESS;
+	down_read(&mm->mmap_sem);
+	result = hugepage_vma_revalidate(mm, vma, address);
+	if (result)
 		goto out;
-	}
 
-	vma = find_vma(mm, address);
-	if (!vma) {
-		result = SCAN_VMA_NULL;
-		goto out;
-	}
-	hstart = (vma->vm_start + ~HPAGE_PMD_MASK) & HPAGE_PMD_MASK;
-	hend = vma->vm_end & HPAGE_PMD_MASK;
-	if (address < hstart || address + HPAGE_PMD_SIZE > hend) {
-		result = SCAN_ADDRESS_RANGE;
-		goto out;
-	}
-	if (!hugepage_vma_check(vma)) {
-		result = SCAN_VMA_CHECK;
-		goto out;
-	}
 	pmd = mm_find_pmd(mm, address);
 	if (!pmd) {
 		result = SCAN_PMD_NULL;
 		goto out;
 	}
 
-	__collapse_huge_page_swapin(mm, vma, address, pmd);
+	/*
+	 * __collapse_huge_page_swapin always returns with mmap_sem
+	 * locked. If it fails, release mmap_sem and jump directly
+	 * label out. Continuing to collapse causes inconsistency.
+	 */
+	if (!__collapse_huge_page_swapin(mm, vma, address, pmd)) {
+		up_read(&mm->mmap_sem);
+		goto out;
+	}
+
+	up_read(&mm->mmap_sem);
+	/*
+	 * Prevent all access to pagetables with the exception of
+	 * gup_fast later handled by the ptep_clear_flush and the VM
+	 * handled by the anon_vma lock + PG_lock.
+	 */
+	down_write(&mm->mmap_sem);
+	result = hugepage_vma_revalidate(mm, vma, address);
+	if (result)
+		goto out;
 
 	anon_vma_lock_write(vma->anon_vma);
 
-- 
2.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
