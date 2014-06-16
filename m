Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f53.google.com (mail-yh0-f53.google.com [209.85.213.53])
	by kanga.kvack.org (Postfix) with ESMTP id B5A916B0037
	for <linux-mm@kvack.org>; Mon, 16 Jun 2014 15:36:04 -0400 (EDT)
Received: by mail-yh0-f53.google.com with SMTP id b6so4714893yha.26
        for <linux-mm@kvack.org>; Mon, 16 Jun 2014 12:36:04 -0700 (PDT)
Received: from g5t1627.atlanta.hp.com (g5t1627.atlanta.hp.com. [15.192.137.10])
        by mx.google.com with ESMTPS id h13si18975992yha.163.2014.06.16.12.36.04
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 16 Jun 2014 12:36:04 -0700 (PDT)
From: Waiman Long <Waiman.Long@hp.com>
Subject: [PATCH] mm, thp: move invariant bug check out of loop in __split_huge_page_map
Date: Mon, 16 Jun 2014 15:35:48 -0400
Message-Id: <1402947348-60655-1-git-send-email-Waiman.Long@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <peterz@infradead.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Scott J Norton <scott.norton@hp.com>, Waiman Long <Waiman.Long@hp.com>

In the __split_huge_page_map() function, the check for
page_mapcount(page) is invariant within the for loop. Because of the
fact that the macro is implemented using atomic_read(), the redundant
check cannot be optimized away by the compiler leading to unnecessary
read to the page structure.

This patch move the invariant bug check out of the loop so that it
will be done only once.

Signed-off-by: Waiman Long <Waiman.Long@hp.com>
---
 mm/huge_memory.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index b4b1feb..b8bb16c 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1744,6 +1744,8 @@ static int __split_huge_page_map(struct page *page,
 	if (pmd) {
 		pgtable = pgtable_trans_huge_withdraw(mm, pmd);
 		pmd_populate(mm, &_pmd, pgtable);
+		if (pmd_write(*pmd))
+			BUG_ON(page_mapcount(page) != 1);
 
 		haddr = address;
 		for (i = 0; i < HPAGE_PMD_NR; i++, haddr += PAGE_SIZE) {
@@ -1753,8 +1755,6 @@ static int __split_huge_page_map(struct page *page,
 			entry = maybe_mkwrite(pte_mkdirty(entry), vma);
 			if (!pmd_write(*pmd))
 				entry = pte_wrprotect(entry);
-			else
-				BUG_ON(page_mapcount(page) != 1);
 			if (!pmd_young(*pmd))
 				entry = pte_mkold(entry);
 			if (pmd_numa(*pmd))
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
