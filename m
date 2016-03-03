Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 26FA4828E2
	for <linux-mm@kvack.org>; Thu,  3 Mar 2016 11:53:11 -0500 (EST)
Received: by mail-pa0-f53.google.com with SMTP id bj10so17717676pad.2
        for <linux-mm@kvack.org>; Thu, 03 Mar 2016 08:53:11 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTP id w13si28173078pas.206.2016.03.03.08.52.54
        for <linux-mm@kvack.org>;
        Thu, 03 Mar 2016 08:52:54 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv3 16/29] thp: skip file huge pmd on copy_huge_pmd()
Date: Thu,  3 Mar 2016 19:52:06 +0300
Message-Id: <1457023939-98083-17-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1457023939-98083-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1457023939-98083-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Jerome Marchand <jmarchan@redhat.com>, Yang Shi <yang.shi@linaro.org>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

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
index 985041c453bf..c0ffa6a7803a 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1052,14 +1052,15 @@ int copy_huge_pmd(struct mm_struct *dst_mm, struct mm_struct *src_mm,
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
@@ -1067,7 +1068,7 @@ int copy_huge_pmd(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 
 	ret = -EAGAIN;
 	pmd = *src_pmd;
-	if (unlikely(!pmd_trans_huge(pmd) && !pmd_devmap(pmd))) {
+	if (unlikely(!pmd_trans_huge(pmd))) {
 		pte_free(dst_mm, pgtable);
 		goto out_unlock;
 	}
@@ -1090,16 +1091,13 @@ int copy_huge_pmd(struct mm_struct *dst_mm, struct mm_struct *src_mm,
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
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
