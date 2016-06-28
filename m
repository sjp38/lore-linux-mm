Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 904D86B0253
	for <linux-mm@kvack.org>; Tue, 28 Jun 2016 13:38:14 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id e189so48471890pfa.2
        for <linux-mm@kvack.org>; Tue, 28 Jun 2016 10:38:14 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id e71si7367654pfg.248.2016.06.28.10.38.13
        for <linux-mm@kvack.org>;
        Tue, 28 Jun 2016 10:38:13 -0700 (PDT)
From: "Huang, Ying" <ying.huang@intel.com>
Subject: [PATCH 2/2] mm, THP: Clean up return value of madvise_free_huge_pmd
Date: Tue, 28 Jun 2016 10:36:30 -0700
Message-Id: <1467135452-16688-2-git-send-email-ying.huang@intel.com>
In-Reply-To: <1467135452-16688-1-git-send-email-ying.huang@intel.com>
References: <1467135452-16688-1-git-send-email-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Huang Ying <ying.huang@intel.com>, Minchan Kim <minchan@kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Jerome Marchand <jmarchan@redhat.com>, Matthew Wilcox <willy@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, Dan Williams <dan.j.williams@intel.com>, Mel Gorman <mgorman@techsingularity.net>, Andrea Arcangeli <aarcange@redhat.com>, Ebru Akagunduz <ebru.akagunduz@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

From: Huang Ying <ying.huang@intel.com>

The definition of return value of madvise_free_huge_pmd is not clear
before.  According to the suggestion of Minchan Kim, change the type of
return value to bool and return true if we do MADV_FREE successfully on
entire pmd page, otherwise, return false.  Comments are added too.

Cc: Minchan Kim <minchan@kernel.org>
Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
---
 include/linux/huge_mm.h |  2 +-
 mm/huge_memory.c        | 15 ++++++++-------
 2 files changed, 9 insertions(+), 8 deletions(-)

diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index eb81081..db97784 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -11,7 +11,7 @@ extern struct page *follow_trans_huge_pmd(struct vm_area_struct *vma,
 					  unsigned long addr,
 					  pmd_t *pmd,
 					  unsigned int flags);
-extern int madvise_free_huge_pmd(struct mmu_gather *tlb,
+extern bool madvise_free_huge_pmd(struct mmu_gather *tlb,
 			struct vm_area_struct *vma,
 			pmd_t *pmd, unsigned long addr, unsigned long next);
 extern int zap_huge_pmd(struct mmu_gather *tlb,
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 546cd21..d2a5224 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1249,25 +1249,26 @@ out:
 	return 0;
 }
 
-int madvise_free_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
+/*
+ * Return true if we do MADV_FREE successfully on entire pmd page.
+ * Otherwise, return false.
+ */
+bool madvise_free_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
 		pmd_t *pmd, unsigned long addr, unsigned long next)
-
 {
 	spinlock_t *ptl;
 	pmd_t orig_pmd;
 	struct page *page;
 	struct mm_struct *mm = tlb->mm;
-	int ret = 0;
+	bool ret = false;
 
 	ptl = pmd_trans_huge_lock(pmd, vma);
 	if (!ptl)
 		goto out_unlocked;
 
 	orig_pmd = *pmd;
-	if (is_huge_zero_pmd(orig_pmd)) {
-		ret = 1;
+	if (is_huge_zero_pmd(orig_pmd))
 		goto out;
-	}
 
 	page = pmd_page(orig_pmd);
 	/*
@@ -1309,7 +1310,7 @@ int madvise_free_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
 		set_pmd_at(mm, addr, pmd, orig_pmd);
 		tlb_remove_pmd_tlb_entry(tlb, pmd, addr);
 	}
-	ret = 1;
+	ret = true;
 out:
 	spin_unlock(ptl);
 out_unlocked:
-- 
2.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
