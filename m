Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx109.postini.com [74.125.245.109])
	by kanga.kvack.org (Postfix) with SMTP id BBAF66B0062
	for <linux-mm@kvack.org>; Tue,  6 Nov 2012 04:15:07 -0500 (EST)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 07/19] mm: numa: split_huge_page: transfer the NUMA type from the pmd to the pte
Date: Tue,  6 Nov 2012 09:14:43 +0000
Message-Id: <1352193295-26815-8-git-send-email-mgorman@suse.de>
In-Reply-To: <1352193295-26815-1-git-send-email-mgorman@suse.de>
References: <1352193295-26815-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Ingo Molnar <mingo@kernel.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

From: Andrea Arcangeli <aarcange@redhat.com>

When we split a transparent hugepage, transfer the NUMA type from the
pmd to the pte if needed.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/huge_memory.c |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 40f17c3..3aaf242 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1363,6 +1363,8 @@ static int __split_huge_page_map(struct page *page,
 				BUG_ON(page_mapcount(page) != 1);
 			if (!pmd_young(*pmd))
 				entry = pte_mkold(entry);
+			if (pmd_numa(*pmd))
+				entry = pte_mknuma(entry);
 			pte = pte_offset_map(&_pmd, haddr);
 			BUG_ON(!pte_none(*pte));
 			set_pte_at(mm, haddr, pte, entry);
-- 
1.7.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
