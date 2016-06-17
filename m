Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5B2186B0005
	for <linux-mm@kvack.org>; Thu, 16 Jun 2016 23:04:43 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id l5so146940724ioa.0
        for <linux-mm@kvack.org>; Thu, 16 Jun 2016 20:04:43 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id al10si11491839pad.148.2016.06.16.20.04.42
        for <linux-mm@kvack.org>;
        Thu, 16 Jun 2016 20:04:42 -0700 (PDT)
From: "Huang, Ying" <ying.huang@intel.com>
Subject: [PATCH] MADVISE_FREE, THP: Fix madvise_free_huge_pmd return value after splitting
Date: Thu, 16 Jun 2016 20:03:54 -0700
Message-Id: <1466132640-18932-1-git-send-email-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Huang Ying <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Ebru Akagunduz <ebru.akagunduz@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

From: Huang Ying <ying.huang@intel.com>

madvise_free_huge_pmd should return 0 if the fallback PTE operations are
required.  In madvise_free_huge_pmd, if part pages of THP are discarded,
the THP will be split and fallback PTE operations should be used if
splitting succeeds.  But the original code will make fallback PTE
operations skipped, after splitting succeeds.  Fix that via make
madvise_free_huge_pmd return 0 after splitting successfully, so that the
fallback PTE operations will be done.

Know issues: if my understanding were correct, return 1 from
madvise_free_huge_pmd means the following processing for the PMD should
be skipped, while return 0 means the following processing is still
needed.  So the function should return 0 only if the THP is split
successfully or the PMD is not trans huge.  But the pmd_trans_unstable
after madvise_free_huge_pmd guarantee the following processing will be
skipped for huge PMD.  So current code can run properly.  But if my
understanding were correct, we can clean up return code of
madvise_free_huge_pmd accordingly.

Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
---
 mm/huge_memory.c | 7 +------
 1 file changed, 1 insertion(+), 6 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 2ad52d5..64dc95d 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1655,14 +1655,9 @@ int madvise_free_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
 	if (next - addr != HPAGE_PMD_SIZE) {
 		get_page(page);
 		spin_unlock(ptl);
-		if (split_huge_page(page)) {
-			put_page(page);
-			unlock_page(page);
-			goto out_unlocked;
-		}
+		split_huge_page(page);
 		put_page(page);
 		unlock_page(page);
-		ret = 1;
 		goto out_unlocked;
 	}
 
-- 
2.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
