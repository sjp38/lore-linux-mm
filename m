Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx110.postini.com [74.125.245.110])
	by kanga.kvack.org (Postfix) with SMTP id 19A8E6B0002
	for <linux-mm@kvack.org>; Sun, 31 Mar 2013 19:46:46 -0400 (EDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH] THP: Use explicit memory barrier
Date: Mon,  1 Apr 2013 08:45:35 +0900
Message-Id: <1364773535-26264-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>

__do_huge_pmd_anonymous_page depends on page_add_new_anon_rmap's
spinlock for making sure that clear_huge_page write become visible
after set set_pmd_at() write.

But lru_cache_add_lru uses pagevec so it could miss spinlock
easily so above rule was broken so user may see inconsistent data.

This patch fixes it with using explict barrier rather than depending
on lru spinlock.

Cc: Mel Gorman <mgorman@suse.de>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Hugh Dickins <hughd@google.com>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 mm/huge_memory.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index bfa142e..fad800e 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -725,11 +725,10 @@ static int __do_huge_pmd_anonymous_page(struct mm_struct *mm,
 		pmd_t entry;
 		entry = mk_huge_pmd(page, vma);
 		/*
-		 * The spinlocking to take the lru_lock inside
-		 * page_add_new_anon_rmap() acts as a full memory
-		 * barrier to be sure clear_huge_page writes become
-		 * visible after the set_pmd_at() write.
+		 * clear_huge_page write become visible after the
+		 * set_pmd_at() write.
 		 */
+		smp_wmb();
 		page_add_new_anon_rmap(page, vma, haddr);
 		set_pmd_at(mm, haddr, pmd, entry);
 		pgtable_trans_huge_deposit(mm, pgtable);
-- 
1.8.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
