Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 93CD26B0259
	for <linux-mm@kvack.org>; Thu, 11 Feb 2016 09:22:31 -0500 (EST)
Received: by mail-pa0-f44.google.com with SMTP id yy13so29569861pab.3
        for <linux-mm@kvack.org>; Thu, 11 Feb 2016 06:22:31 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id d69si12929982pfj.73.2016.02.11.06.22.09
        for <linux-mm@kvack.org>;
        Thu, 11 Feb 2016 06:22:09 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv2 14/28] thp: handle file pages in split_huge_pmd()
Date: Thu, 11 Feb 2016 17:21:42 +0300
Message-Id: <1455200516-132137-15-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1455200516-132137-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1455200516-132137-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Jerome Marchand <jmarchan@redhat.com>, Yang Shi <yang.shi@linaro.org>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Splitting THP PMD is simple: just unmap it as in DAX case.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/huge_memory.c | 10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 8fd5a3c58353..4da4e915af61 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -2900,10 +2900,16 @@ static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
 
 	count_vm_event(THP_SPLIT_PMD);
 
-	if (vma_is_dax(vma)) {
-		pmd_t _pmd = pmdp_huge_clear_flush_notify(vma, haddr, pmd);
+	if (!vma_is_anonymous(vma)) {
+		_pmd = pmdp_huge_clear_flush_notify(vma, haddr, pmd);
 		if (is_huge_zero_pmd(_pmd))
 			put_huge_zero_page();
+		if (vma_is_dax(vma))
+			return;
+		page = pmd_page(_pmd);
+		page_remove_rmap(page, true);
+		put_page(page);
+		add_mm_counter(mm, MM_FILEPAGES, -HPAGE_PMD_NR);
 		return;
 	} else if (is_huge_zero_pmd(*pmd)) {
 		return __split_huge_zero_page_pmd(vma, haddr, pmd);
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
