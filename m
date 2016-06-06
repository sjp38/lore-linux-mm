Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 15D2B828E1
	for <linux-mm@kvack.org>; Mon,  6 Jun 2016 10:08:07 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id s73so232234815pfs.0
        for <linux-mm@kvack.org>; Mon, 06 Jun 2016 07:08:07 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id p186si21552150pfb.113.2016.06.06.07.07.42
        for <linux-mm@kvack.org>;
        Mon, 06 Jun 2016 07:07:42 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv9 11/32] thp: skip file huge pmd on copy_huge_pmd()
Date: Mon,  6 Jun 2016 17:06:48 +0300
Message-Id: <1465222029-45942-12-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1465222029-45942-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1465222029-45942-1-git-send-email-kirill.shutemov@linux.intel.com>
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
index 6631c89b4bfc..32974dee4250 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1099,14 +1099,15 @@ int copy_huge_pmd(struct mm_struct *dst_mm, struct mm_struct *src_mm,
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
@@ -1114,7 +1115,7 @@ int copy_huge_pmd(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 
 	ret = -EAGAIN;
 	pmd = *src_pmd;
-	if (unlikely(!pmd_trans_huge(pmd) && !pmd_devmap(pmd))) {
+	if (unlikely(!pmd_trans_huge(pmd))) {
 		pte_free(dst_mm, pgtable);
 		goto out_unlock;
 	}
@@ -1137,16 +1138,13 @@ int copy_huge_pmd(struct mm_struct *dst_mm, struct mm_struct *src_mm,
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
2.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
