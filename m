Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 7FF45828DF
	for <linux-mm@kvack.org>; Fri, 11 Mar 2016 17:59:51 -0500 (EST)
Received: by mail-pa0-f45.google.com with SMTP id tt10so110440091pab.3
        for <linux-mm@kvack.org>; Fri, 11 Mar 2016 14:59:51 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTP id w13si6174544pas.67.2016.03.11.14.59.32
        for <linux-mm@kvack.org>;
        Fri, 11 Mar 2016 14:59:32 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv4 09/25] thp: handle file pages in split_huge_pmd()
Date: Sat, 12 Mar 2016 01:59:01 +0300
Message-Id: <1457737157-38573-10-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1457737157-38573-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1457737157-38573-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Jerome Marchand <jmarchan@redhat.com>, Yang Shi <yang.shi@linaro.org>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Splitting THP PMD is simple: just unmap it as in DAX case.
Unlike DAX, we also remove the page from rmap and drop reference.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/huge_memory.c | 10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index c22144e3fe11..51c54d5a945b 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -2930,10 +2930,16 @@ static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
 
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
