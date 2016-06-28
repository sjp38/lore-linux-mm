Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3779E6B0005
	for <linux-mm@kvack.org>; Tue, 28 Jun 2016 13:37:58 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id g62so48465473pfb.3
        for <linux-mm@kvack.org>; Tue, 28 Jun 2016 10:37:58 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id uc2si34590388pac.22.2016.06.28.10.37.57
        for <linux-mm@kvack.org>;
        Tue, 28 Jun 2016 10:37:57 -0700 (PDT)
From: "Huang, Ying" <ying.huang@intel.com>
Subject: [PATCH 1/2] MADVISE_FREE, THP: Fix madvise_free_huge_pmd return value after splitting
Date: Tue, 28 Jun 2016 10:36:29 -0700
Message-Id: <1467135452-16688-1-git-send-email-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Huang Ying <ying.huang@intel.com>, Minchan Kim <minchan@kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Ebru Akagunduz <ebru.akagunduz@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

From: Huang Ying <ying.huang@intel.com>

madvise_free_huge_pmd should return 0 if the fallback PTE operations are
required.  In madvise_free_huge_pmd, if part pages of THP are discarded,
the THP will be split and fallback PTE operations should be used if
splitting succeeds.  But the original code will make fallback PTE
operations skipped, after splitting succeeds.  Fix that via make
madvise_free_huge_pmd return 0 after splitting successfully, so that the
fallback PTE operations will be done.

Cc: Minchan Kim <minchan@kernel.org>
Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
---
 mm/huge_memory.c | 7 +------
 1 file changed, 1 insertion(+), 6 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 848c16c..546cd21 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1287,14 +1287,9 @@ int madvise_free_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
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
