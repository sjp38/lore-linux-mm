Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id A1AE6828DF
	for <linux-mm@kvack.org>; Fri, 15 Apr 2016 20:24:46 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id vv3so153338567pab.2
        for <linux-mm@kvack.org>; Fri, 15 Apr 2016 17:24:46 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id q76si5201007pfa.60.2016.04.15.17.24.37
        for <linux-mm@kvack.org>;
        Fri, 15 Apr 2016 17:24:37 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv7 09/29] thp: handle file pages in split_huge_pmd()
Date: Sat, 16 Apr 2016 03:23:40 +0300
Message-Id: <1460766240-84565-10-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1460766240-84565-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1460766240-84565-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Jerome Marchand <jmarchan@redhat.com>, Yang Shi <yang.shi@linaro.org>, Sasha Levin <sasha.levin@oracle.com>, Andres Lagar-Cavilla <andreslc@google.com>, Ning Qu <quning@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Splitting THP PMD is simple: just unmap it as in DAX case.
Unlike DAX, we also remove the page from rmap and drop reference.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/huge_memory.c | 10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 29ba922a9c26..67830a6ed8b0 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -2940,10 +2940,16 @@ static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
 
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
2.8.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
