Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id B1ADF6B0343
	for <linux-mm@kvack.org>; Sun,  7 May 2017 06:18:24 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id c2so41042322pfd.9
        for <linux-mm@kvack.org>; Sun, 07 May 2017 03:18:24 -0700 (PDT)
Received: from mail-pg0-x243.google.com (mail-pg0-x243.google.com. [2607:f8b0:400e:c05::243])
        by mx.google.com with ESMTPS id y5si6951631pgc.212.2017.05.07.03.18.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 07 May 2017 03:18:23 -0700 (PDT)
Received: by mail-pg0-x243.google.com with SMTP id s62so6547648pgc.0
        for <linux-mm@kvack.org>; Sun, 07 May 2017 03:18:23 -0700 (PDT)
From: SeongJae Park <sj38.park@gmail.com>
Subject: [PATCH] mm/khugepaged: Add missed tracepoint for collapse_huge_page_swapin
Date: Sun,  7 May 2017 19:18:13 +0900
Message-Id: <20170507101813.30187-1-sj38.park@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, kirill.shutemov@linux.intel.com
Cc: hannes@cmpxchg.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, SeongJae Park <sj38.park@gmail.com>

One return case of `__collapse_huge_page_swapin()` does not invoke
tracepoint while every other return case does.  This commit adds a
tracepoint invocation for the case.

Signed-off-by: SeongJae Park <sj38.park@gmail.com>
---
 mm/khugepaged.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/mm/khugepaged.c b/mm/khugepaged.c
index ba40b7f673f4..9aad377c67a8 100644
--- a/mm/khugepaged.c
+++ b/mm/khugepaged.c
@@ -909,8 +909,10 @@ static bool __collapse_huge_page_swapin(struct mm_struct *mm,
 				return false;
 			}
 			/* check if the pmd is still valid */
-			if (mm_find_pmd(mm, address) != pmd)
+			if (mm_find_pmd(mm, address) != pmd) {
+				trace_mm_collapse_huge_page_swapin(mm, swapped_in, referenced, 0);
 				return false;
+			}
 		}
 		if (ret & VM_FAULT_ERROR) {
 			trace_mm_collapse_huge_page_swapin(mm, swapped_in, referenced, 0);
-- 
2.12.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
