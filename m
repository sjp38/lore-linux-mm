Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1D9F36B0262
	for <linux-mm@kvack.org>; Wed, 15 Jun 2016 16:07:06 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id b13so49996264pat.3
        for <linux-mm@kvack.org>; Wed, 15 Jun 2016 13:07:06 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id w6si5441185pac.26.2016.06.15.13.06.59
        for <linux-mm@kvack.org>;
        Wed, 15 Jun 2016 13:06:59 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv9-rebased2 05/37] khugepaged: recheck pmd after mmap_sem re-acquired
Date: Wed, 15 Jun 2016 23:06:10 +0300
Message-Id: <1466021202-61880-6-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1466021202-61880-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1465222029-45942-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1466021202-61880-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Jerome Marchand <jmarchan@redhat.com>, Yang Shi <yang.shi@linaro.org>, Sasha Levin <sasha.levin@oracle.com>, Andres Lagar-Cavilla <andreslc@google.com>, Ning Qu <quning@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Ebru Akagunduz <ebru.akagunduz@gmail.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Vlastimil noted[1] that pmd can be no longer valid after we drop
mmap_sem. We need recheck it once mmap_sem taken again.

[1] http://lkml.kernel.org/r/12918dcd-a695-c6f4-e06f-69141c5f357f@suse.cz

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/huge_memory.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index d7ccc8558187..0efdad975659 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -2437,6 +2437,9 @@ static bool __collapse_huge_page_swapin(struct mm_struct *mm,
 			/* vma is no longer available, don't continue to swapin */
 			if (hugepage_vma_revalidate(mm, address))
 				return false;
+			/* check if the pmd is still valid */
+			if (mm_find_pmd(mm, address) != pmd)
+				return false;
 		}
 		if (ret & VM_FAULT_ERROR) {
 			trace_mm_collapse_huge_page_swapin(mm, swapped_in, 0);
@@ -2522,6 +2525,9 @@ static void collapse_huge_page(struct mm_struct *mm,
 	result = hugepage_vma_revalidate(mm, address);
 	if (result)
 		goto out;
+	/* check if the pmd is still valid */
+	if (mm_find_pmd(mm, address) != pmd)
+		goto out;
 
 	anon_vma_lock_write(vma->anon_vma);
 
-- 
2.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
