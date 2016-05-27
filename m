Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f200.google.com (mail-lb0-f200.google.com [209.85.217.200])
	by kanga.kvack.org (Postfix) with ESMTP id 351576B0260
	for <linux-mm@kvack.org>; Fri, 27 May 2016 03:59:45 -0400 (EDT)
Received: by mail-lb0-f200.google.com with SMTP id q17so50463766lbn.3
        for <linux-mm@kvack.org>; Fri, 27 May 2016 00:59:45 -0700 (PDT)
Received: from mail-wm0-x243.google.com (mail-wm0-x243.google.com. [2a00:1450:400c:c09::243])
        by mx.google.com with ESMTPS id m8si24216558wjj.170.2016.05.27.00.59.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 May 2016 00:59:43 -0700 (PDT)
Received: by mail-wm0-x243.google.com with SMTP id a136so12380692wme.0
        for <linux-mm@kvack.org>; Fri, 27 May 2016 00:59:43 -0700 (PDT)
From: Ebru Akagunduz <ebru.akagunduz@gmail.com>
Subject: [PATCH v2 3/3] mm, thp: make swapin readahead under down_read of mmap_sem
Date: Fri, 27 May 2016 10:59:24 +0300
Message-Id: <1464335964-6510-4-git-send-email-ebru.akagunduz@gmail.com>
In-Reply-To: <1464335964-6510-1-git-send-email-ebru.akagunduz@gmail.com>
References: <1464335964-6510-1-git-send-email-ebru.akagunduz@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: hughd@google.com, riel@redhat.com, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, aarcange@redhat.com, iamjoonsoo.kim@lge.com, gorcunov@openvz.org, linux-kernel@vger.kernel.org, mgorman@suse.de, rientjes@google.com, vbabka@suse.cz, aneesh.kumar@linux.vnet.ibm.com, hannes@cmpxchg.org, mhocko@suse.cz, boaz@plexistor.com, Ebru Akagunduz <ebru.akagunduz@gmail.com>

Currently khugepaged makes swapin readahead under
down_write. This patch supplies to make swapin
readahead under down_read instead of down_write.

The patch was tested with a test program that allocates
800MB of memory, writes to it, and then sleeps. The system
was forced to swap out all. Afterwards, the test program
touches the area by writing, it skips a page in each
20 pages of the area.

Signed-off-by: Ebru Akagunduz <ebru.akagunduz@gmail.com>
---
Changes in v2:
 - Keep the comment next to down_write (Andrea Arcangeli)
 - To revalidate vma, use the same check methods which is placed in
   collapse_huge_page (Andrea Arcangeli)
 - Collect the methods in a helper function and replace the content
   with function, if needed (Ebru Akagunduz)

 mm/huge_memory.c | 97 ++++++++++++++++++++++++++++++++++++++------------------
 1 file changed, 66 insertions(+), 31 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 9adf1c7..292cedd 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -2380,6 +2380,35 @@ static bool hugepage_vma_check(struct vm_area_struct *vma)
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
@@ -2387,7 +2416,7 @@ static bool hugepage_vma_check(struct vm_area_struct *vma)
  * but with mmap_sem held to protect against vma changes.
  */
 
-static void __collapse_huge_page_swapin(struct mm_struct *mm,
+static bool __collapse_huge_page_swapin(struct mm_struct *mm,
 					struct vm_area_struct *vma,
 					unsigned long address, pmd_t *pmd)
 {
@@ -2403,11 +2432,18 @@ static void __collapse_huge_page_swapin(struct mm_struct *mm,
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
@@ -2415,6 +2451,7 @@ static void __collapse_huge_page_swapin(struct mm_struct *mm,
 	pte--;
 	pte_unmap(pte);
 	trace_mm_collapse_huge_page_swapin(mm, swapped_in, 1);
+	return true;
 }
 
 static void collapse_huge_page(struct mm_struct *mm,
@@ -2429,7 +2466,7 @@ static void collapse_huge_page(struct mm_struct *mm,
 	struct page *new_page;
 	spinlock_t *pmd_ptl, *pte_ptl;
 	int isolated = 0, result = 0;
-	unsigned long hstart, hend, swap, curr_allocstall;
+	unsigned long swap, curr_allocstall;
 	struct mem_cgroup *memcg;
 	unsigned long mmun_start;	/* For mmu_notifiers */
 	unsigned long mmun_end;		/* For mmu_notifiers */
@@ -2454,33 +2491,11 @@ static void collapse_huge_page(struct mm_struct *mm,
 
 	swap = get_mm_counter(mm, MM_SWAPENTS);
 	curr_allocstall = sum_vm_event(ALLOCSTALL);
-
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
@@ -2491,8 +2506,28 @@ static void collapse_huge_page(struct mm_struct *mm,
 	 * Don't perform swapin readahead when the system is under pressure,
 	 * to avoid unnecessary resource consumption.
 	 */
-	if (allocstall == curr_allocstall && swap != 0)
-		__collapse_huge_page_swapin(mm, vma, address, pmd);
+	if (allocstall == curr_allocstall && swap != 0) {
+		/*
+		 * __collapse_huge_page_swapin always returns with mmap_sem
+		 * locked. If it fails, release mmap_sem and jump directly
+		 * label out. Continuing to collapse causes inconsistency.
+		 */
+		if (!__collapse_huge_page_swapin(mm, vma, address, pmd)) {
+			up_read(&mm->mmap_sem);
+			goto out;
+		}
+	}
+
+	up_read(&mm->mmap_sem);
+	/*
+	 * Prevent all access to pagetables with the exception of
+	 * gup_fast later hanlded by the ptep_clear_flush and the VM
+	 * handled by the anon_vma lock + PG_lock.
+	 */
+	down_write(&mm->mmap_sem);
+	result = hugepage_vma_revalidate(mm, vma, address);
+	if (result)
+		goto out;
 
 	anon_vma_lock_write(vma->anon_vma);
 
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
