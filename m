Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 685BC6B0253
	for <linux-mm@kvack.org>; Mon, 23 Jan 2017 18:15:55 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id 194so216752448pgd.7
        for <linux-mm@kvack.org>; Mon, 23 Jan 2017 15:15:55 -0800 (PST)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id b7si17046252pli.5.2017.01.23.15.15.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Jan 2017 15:15:54 -0800 (PST)
Received: from pps.filterd (m0044010.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v0NNA7ZN004881
	for <linux-mm@kvack.org>; Mon, 23 Jan 2017 15:15:54 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 285pcrs348-2
	(version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 23 Jan 2017 15:15:54 -0800
Received: from facebook.com (2401:db00:21:603d:face:0:19:0)	by
 mx-out.facebook.com (10.102.107.97) with ESMTP	id
 e2b04df2e1c111e688020002c99331b0-d85f1a50 for <linux-mm@kvack.org>;	Mon, 23
 Jan 2017 15:15:52 -0800
From: Shaohua Li <shli@fb.com>
Subject: [PATCH] mm: write protect MADV_FREE pages
Date: Mon, 23 Jan 2017 15:15:52 -0800
Message-ID: <791151284cd6941296f08488b8cb7f1968175a0a.1485212872.git.shli@fb.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Kernel-team@fb.com, Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@surriel.com>, stable@kernel.org

The page reclaim has an assumption writting to a page with clean pte
should trigger a page fault, because there is a window between pte zero
and tlb flush where a new write could come. If the new write doesn't
trigger page fault, page reclaim will not notice it and think the page
is clean and reclaim it. The MADV_FREE pages don't comply with the rule
and the pte is just cleaned without writeprotect, so there will be no
pagefault for new write. This will cause data corruption.

Cc: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>
Cc: Rik van Riel <riel@surriel.com>
Cc: stable@kernel.org
Signed-off-by: Shaohua Li <shli@fb.com>
---
 mm/huge_memory.c | 1 +
 mm/madvise.c     | 1 +
 2 files changed, 2 insertions(+)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 9a6bd6c..9cc5de5 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1381,6 +1381,7 @@ bool madvise_free_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
 			tlb->fullmm);
 		orig_pmd = pmd_mkold(orig_pmd);
 		orig_pmd = pmd_mkclean(orig_pmd);
+		orig_pmd = pmd_wrprotect(orig_pmd);
 
 		set_pmd_at(mm, addr, pmd, orig_pmd);
 		tlb_remove_pmd_tlb_entry(tlb, pmd, addr);
diff --git a/mm/madvise.c b/mm/madvise.c
index 0e3828e..bfb6800 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -373,6 +373,7 @@ static int madvise_free_pte_range(pmd_t *pmd, unsigned long addr,
 
 			ptent = pte_mkold(ptent);
 			ptent = pte_mkclean(ptent);
+			ptent = pte_wrprotect(ptent);
 			set_pte_at(mm, addr, pte, ptent);
 			if (PageActive(page))
 				deactivate_page(page);
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
