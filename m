Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 30DDD828E1
	for <linux-mm@kvack.org>; Tue,  7 Jun 2016 07:06:19 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id z189so24758181itg.2
        for <linux-mm@kvack.org>; Tue, 07 Jun 2016 04:06:19 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id fj5si32701263pad.96.2016.06.07.04.01.04
        for <linux-mm@kvack.org>;
        Tue, 07 Jun 2016 04:01:05 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv9-rebased 27/32] khugepaged: move up_read(mmap_sem) out of khugepaged_alloc_page()
Date: Tue,  7 Jun 2016 14:00:41 +0300
Message-Id: <1465297246-98985-28-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1465297246-98985-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1465222029-45942-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1465297246-98985-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Jerome Marchand <jmarchan@redhat.com>, Yang Shi <yang.shi@linaro.org>, Sasha Levin <sasha.levin@oracle.com>, Andres Lagar-Cavilla <andreslc@google.com>, Ning Qu <quning@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Both variants of khugepaged_alloc_page() do up_read(&mm->mmap_sem)
first: no point keep it inside the function.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/khugepaged.c | 25 ++++++++++---------------
 1 file changed, 10 insertions(+), 15 deletions(-)

diff --git a/mm/khugepaged.c b/mm/khugepaged.c
index 1b08a5c57140..84c2bf01ae42 100644
--- a/mm/khugepaged.c
+++ b/mm/khugepaged.c
@@ -746,19 +746,10 @@ static bool khugepaged_prealloc_page(struct page **hpage, bool *wait)
 }
 
 static struct page *
-khugepaged_alloc_page(struct page **hpage, gfp_t gfp, struct mm_struct *mm,
-		       unsigned long address, int node)
+khugepaged_alloc_page(struct page **hpage, gfp_t gfp, int node)
 {
 	VM_BUG_ON_PAGE(*hpage, *hpage);
 
-	/*
-	 * Before allocating the hugepage, release the mmap_sem read lock.
-	 * The allocation can take potentially a long time if it involves
-	 * sync compaction, and we do not need to hold the mmap_sem during
-	 * that. We will recheck the vma after taking it again in write mode.
-	 */
-	up_read(&mm->mmap_sem);
-
 	*hpage = __alloc_pages_node(node, gfp, HPAGE_PMD_ORDER);
 	if (unlikely(!*hpage)) {
 		count_vm_event(THP_COLLAPSE_ALLOC_FAILED);
@@ -819,10 +810,8 @@ static bool khugepaged_prealloc_page(struct page **hpage, bool *wait)
 }
 
 static struct page *
-khugepaged_alloc_page(struct page **hpage, gfp_t gfp, struct mm_struct *mm,
-		       unsigned long address, int node)
+khugepaged_alloc_page(struct page **hpage, gfp_t gfp, int node)
 {
-	up_read(&mm->mmap_sem);
 	VM_BUG_ON(!*hpage);
 
 	return  *hpage;
@@ -941,8 +930,14 @@ static void collapse_huge_page(struct mm_struct *mm,
 	/* Only allocate from the target node */
 	gfp = alloc_hugepage_khugepaged_gfpmask() | __GFP_OTHER_NODE | __GFP_THISNODE;
 
-	/* release the mmap_sem read lock. */
-	new_page = khugepaged_alloc_page(hpage, gfp, mm, address, node);
+	/*
+	 * Before allocating the hugepage, release the mmap_sem read lock.
+	 * The allocation can take potentially a long time if it involves
+	 * sync compaction, and we do not need to hold the mmap_sem during
+	 * that. We will recheck the vma after taking it again in write mode.
+	 */
+	up_read(&mm->mmap_sem);
+	new_page = khugepaged_alloc_page(hpage, gfp, node);
 	if (!new_page) {
 		result = SCAN_ALLOC_HUGE_PAGE_FAIL;
 		goto out_nolock;
-- 
2.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
