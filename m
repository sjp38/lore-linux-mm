Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id B42846B025D
	for <linux-mm@kvack.org>; Wed, 18 Nov 2015 18:25:56 -0500 (EST)
Received: by pacdm15 with SMTP id dm15so59452428pac.3
        for <linux-mm@kvack.org>; Wed, 18 Nov 2015 15:25:56 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id un9si7295761pac.89.2015.11.18.15.25.51
        for <linux-mm@kvack.org>;
        Wed, 18 Nov 2015 15:25:51 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 8/9] thp: handle file pages in split_huge_pmd()
Date: Thu, 19 Nov 2015 01:25:35 +0200
Message-Id: <1447889136-6928-9-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1447889136-6928-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1447889136-6928-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Jerome Marchand <jmarchan@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Splitting THP PMD is simple: just unmap it as in DAX case.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/huge_memory.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 661e144a619d..acd367b04730 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -2774,10 +2774,14 @@ static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
 
 	count_vm_event(THP_SPLIT_PMD);
 
-	if (vma_is_dax(vma)) {
-		pmd_t _pmd = pmdp_huge_clear_flush_notify(vma, haddr, pmd);
+	if (!vma_is_anonymous(vma)) {
+		_pmd = pmdp_huge_clear_flush_notify(vma, haddr, pmd);
 		if (is_huge_zero_pmd(_pmd))
 			put_huge_zero_page();
+		if (vma_is_dax(vma))
+			return;
+		page_remove_rmap(pmd_page(_pmd), true);
+		add_mm_counter(mm, MM_FILEPAGES, -HPAGE_PMD_NR);
 		return;
 	} else if (is_huge_zero_pmd(*pmd)) {
 		return __split_huge_zero_page_pmd(vma, haddr, pmd);
-- 
2.6.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
