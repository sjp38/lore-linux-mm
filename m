Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 835206B02E1
	for <linux-mm@kvack.org>; Wed, 10 May 2017 17:27:25 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id c2so5899587pfd.9
        for <linux-mm@kvack.org>; Wed, 10 May 2017 14:27:25 -0700 (PDT)
Received: from mail-pg0-x22c.google.com (mail-pg0-x22c.google.com. [2607:f8b0:400e:c05::22c])
        by mx.google.com with ESMTPS id x6si147184plm.296.2017.05.10.14.27.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 May 2017 14:27:24 -0700 (PDT)
Received: by mail-pg0-x22c.google.com with SMTP id o3so3892198pgn.2
        for <linux-mm@kvack.org>; Wed, 10 May 2017 14:27:24 -0700 (PDT)
Date: Wed, 10 May 2017 14:27:23 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch] mm, thp: copying user pages must schedule on collapse
Message-ID: <alpine.DEB.2.10.1705101426380.109808@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

We have encountered need_resched warnings in __collapse_huge_page_copy()
while doing {clear,copy}_user_highpage() over HPAGE_PMD_NR source pages.

mm->mmap_sem is held for write, but the iteration is well bounded.

Reschedule as needed.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/khugepaged.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/mm/khugepaged.c b/mm/khugepaged.c
--- a/mm/khugepaged.c
+++ b/mm/khugepaged.c
@@ -612,7 +612,8 @@ static void __collapse_huge_page_copy(pte_t *pte, struct page *page,
 				      spinlock_t *ptl)
 {
 	pte_t *_pte;
-	for (_pte = pte; _pte < pte+HPAGE_PMD_NR; _pte++) {
+	for (_pte = pte; _pte < pte + HPAGE_PMD_NR;
+				_pte++, page++, address += PAGE_SIZE) {
 		pte_t pteval = *_pte;
 		struct page *src_page;
 
@@ -651,9 +652,7 @@ static void __collapse_huge_page_copy(pte_t *pte, struct page *page,
 			spin_unlock(ptl);
 			free_page_and_swap_cache(src_page);
 		}
-
-		address += PAGE_SIZE;
-		page++;
+		cond_resched();
 	}
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
