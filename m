Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f181.google.com (mail-pf0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 59DBF6B0278
	for <linux-mm@kvack.org>; Wed,  6 Apr 2016 18:51:53 -0400 (EDT)
Received: by mail-pf0-f181.google.com with SMTP id c20so42402809pfc.1
        for <linux-mm@kvack.org>; Wed, 06 Apr 2016 15:51:53 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id o13si7277125pfj.73.2016.04.06.15.51.31
        for <linux-mm@kvack.org>;
        Wed, 06 Apr 2016 15:51:32 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv6 12/30] thp: skip file huge pmd on copy_huge_pmd()
Date: Thu,  7 Apr 2016 01:51:02 +0300
Message-Id: <1459983080-106718-13-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1459983080-106718-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1459983080-106718-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Jerome Marchand <jmarchan@redhat.com>, Yang Shi <yang.shi@linaro.org>, Sasha Levin <sasha.levin@oracle.com>, Andres Lagar-Cavilla <andreslc@google.com>, Ning Qu <quning@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

copy_page_range() has a check for "Don't copy ptes where a page fault
will fill them correctly." It works on VMA level. We still copy all page
table entries from private mappings, even if they map page cache.

We can simplify copy_huge_pmd() a bit by skipping file PMDs.

We don't map file private pages with PMDs, so they only can map page
cache. It's safe to skip them as they can be re-faulted later.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/huge_memory.c | 34 ++++++++++++++++------------------
 1 file changed, 16 insertions(+), 18 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 729e73356b97..a4163e023eb6 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1094,14 +1094,15 @@ int copy_huge_pmd(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 	struct page *src_page;
 	pmd_t pmd;
 	pgtable_t pgtable = NULL;
-	int ret;
+	int ret = -ENOMEM;
 
-	if (!vma_is_dax(vma)) {
-		ret = -ENOMEM;
-		pgtable = pte_alloc_one(dst_mm, addr);
-		if (unlikely(!pgtable))
-			goto out;
-	}
+	/* Skip if can be re-fill on fault */
+	if (!vma_is_anonymous(vma))
+		return 0;
+
+	pgtable = pte_alloc_one(dst_mm, addr);
+	if (unlikely(!pgtable))
+		goto out;
 
 	dst_ptl = pmd_lock(dst_mm, dst_pmd);
 	src_ptl = pmd_lockptr(src_mm, src_pmd);
@@ -1109,7 +1110,7 @@ int copy_huge_pmd(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 
 	ret = -EAGAIN;
 	pmd = *src_pmd;
-	if (unlikely(!pmd_trans_huge(pmd) && !pmd_devmap(pmd))) {
+	if (unlikely(!pmd_trans_huge(pmd))) {
 		pte_free(dst_mm, pgtable);
 		goto out_unlock;
 	}
@@ -1132,16 +1133,13 @@ int copy_huge_pmd(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 		goto out_unlock;
 	}
 
-	if (!vma_is_dax(vma)) {
-		/* thp accounting separate from pmd_devmap accounting */
-		src_page = pmd_page(pmd);
-		VM_BUG_ON_PAGE(!PageHead(src_page), src_page);
-		get_page(src_page);
-		page_dup_rmap(src_page, true);
-		add_mm_counter(dst_mm, MM_ANONPAGES, HPAGE_PMD_NR);
-		atomic_long_inc(&dst_mm->nr_ptes);
-		pgtable_trans_huge_deposit(dst_mm, dst_pmd, pgtable);
-	}
+	src_page = pmd_page(pmd);
+	VM_BUG_ON_PAGE(!PageHead(src_page), src_page);
+	get_page(src_page);
+	page_dup_rmap(src_page, true);
+	add_mm_counter(dst_mm, MM_ANONPAGES, HPAGE_PMD_NR);
+	atomic_long_inc(&dst_mm->nr_ptes);
+	pgtable_trans_huge_deposit(dst_mm, dst_pmd, pgtable);
 
 	pmdp_set_wrprotect(src_mm, addr, src_pmd);
 	pmd = pmd_mkold(pmd_wrprotect(pmd));
-- 
2.8.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
