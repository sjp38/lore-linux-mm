Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 24FFF6B0038
	for <linux-mm@kvack.org>; Fri,  2 Sep 2016 08:44:59 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id u132so12588186lff.3
        for <linux-mm@kvack.org>; Fri, 02 Sep 2016 05:44:59 -0700 (PDT)
Received: from mail-wm0-x241.google.com (mail-wm0-x241.google.com. [2a00:1450:400c:c09::241])
        by mx.google.com with ESMTPS id s21si3994582wmd.21.2016.09.02.05.44.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Sep 2016 05:44:57 -0700 (PDT)
Received: by mail-wm0-x241.google.com with SMTP id c133so2730004wmd.2
        for <linux-mm@kvack.org>; Fri, 02 Sep 2016 05:44:57 -0700 (PDT)
From: Ebru Akagunduz <ebru.akagunduz@gmail.com>
Subject: [PATCH] mm, thp: fix leaking mapped pte in __collapse_huge_page_swapin()
Date: Fri,  2 Sep 2016 15:44:36 +0300
Message-Id: <1472820276-7831-1-git-send-email-ebru.akagunduz@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: riel@redhat.com, aarcange@redhat.com, akpm@linux-foundation.org, vbabka@suse.cz, mgorman@techsingularity.net, kirill.shutemov@linux.intel.com, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, Ebru Akagunduz <ebru.akagunduz@gmail.com>

Currently, khugepaged does not let swapin, if there is no
enough young pages in a THP. The problem is when a THP does
not have enough young page, khugepaged leaks mapped ptes.

This patch prohibits leaking mapped ptes.

Signed-off-by: Ebru Akagunduz <ebru.akagunduz@gmail.com>
Suggested-by: Andrea Arcangeli <aarcange@redhat.com>
---
 mm/khugepaged.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/mm/khugepaged.c b/mm/khugepaged.c
index 79c52d0..f401e9d 100644
--- a/mm/khugepaged.c
+++ b/mm/khugepaged.c
@@ -881,6 +881,11 @@ static bool __collapse_huge_page_swapin(struct mm_struct *mm,
 		.pmd = pmd,
 	};
 
+	/* we only decide to swapin, if there is enough young ptes */
+	if (referenced < HPAGE_PMD_NR/2) {
+		trace_mm_collapse_huge_page_swapin(mm, swapped_in, referenced, 0);
+		return false;
+	}
 	fe.pte = pte_offset_map(pmd, address);
 	for (; fe.address < address + HPAGE_PMD_NR*PAGE_SIZE;
 			fe.pte++, fe.address += PAGE_SIZE) {
@@ -888,11 +893,6 @@ static bool __collapse_huge_page_swapin(struct mm_struct *mm,
 		if (!is_swap_pte(pteval))
 			continue;
 		swapped_in++;
-		/* we only decide to swapin, if there is enough young ptes */
-		if (referenced < HPAGE_PMD_NR/2) {
-			trace_mm_collapse_huge_page_swapin(mm, swapped_in, referenced, 0);
-			return false;
-		}
 		ret = do_swap_page(&fe, pteval);
 
 		/* do_swap_page returns VM_FAULT_RETRY with released mmap_sem */
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
