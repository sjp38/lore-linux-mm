Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 9532182F64
	for <linux-mm@kvack.org>; Fri, 30 Oct 2015 03:01:23 -0400 (EDT)
Received: by pacfv9 with SMTP id fv9so68231421pac.3
        for <linux-mm@kvack.org>; Fri, 30 Oct 2015 00:01:23 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTPS id if5si8663715pbb.200.2015.10.30.00.01.20
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 30 Oct 2015 00:01:20 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH 4/8] mm: free swp_entry in madvise_free
Date: Fri, 30 Oct 2015 16:01:40 +0900
Message-Id: <1446188504-28023-5-git-send-email-minchan@kernel.org>
In-Reply-To: <1446188504-28023-1-git-send-email-minchan@kernel.org>
References: <1446188504-28023-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michael Kerrisk <mtk.manpages@gmail.com>, linux-api@vger.kernel.org, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, zhangyanfei@cn.fujitsu.com, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Jason Evans <je@fb.com>, Daniel Micay <danielmicay@gmail.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Michal Hocko <mhocko@suse.cz>, yalin.wang2010@gmail.com, Shaohua Li <shli@kernel.org>, Minchan Kim <minchan@kernel.org>

When I test below piece of code with 12 processes(ie, 512M * 12 = 6G
consume) on my (3G ram + 12 cpu + 8G swap, the madvise_free is siginficat
slower (ie, 2x times) than madvise_dontneed.

loop = 5;
mmap(512M);
while (loop--) {
        memset(512M);
        madvise(MADV_FREE or MADV_DONTNEED);
}

The reason is lots of swapin.

1) dontneed: 1,612 swapin
2) madvfree: 879,585 swapin

If we find hinted pages were already swapped out when syscall is called,
it's pointless to keep the swapped-out pages in pte.
Instead, let's free the cold page because swapin is more expensive
than (alloc page + zeroing).

With this patch, it reduced swapin from 879,585 to 1,878 so elapsed time

1) dontneed: 6.10user 233.50system 0:50.44elapsed
2) madvfree: 6.03user 401.17system 1:30.67elapsed
2) madvfree + below patch: 6.70user 339.14system 1:04.45elapsed

Acked-by: Hugh Dickins <hughd@google.com>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 mm/madvise.c | 26 +++++++++++++++++++++++++-
 1 file changed, 25 insertions(+), 1 deletion(-)

diff --git a/mm/madvise.c b/mm/madvise.c
index 640311704e31..663bd9fa0ae0 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -270,6 +270,8 @@ static int madvise_free_pte_range(pmd_t *pmd, unsigned long addr,
 	spinlock_t *ptl;
 	pte_t *pte, ptent;
 	struct page *page;
+	swp_entry_t entry;
+	int nr_swap = 0;
 
 	split_huge_page_pmd(vma, addr, pmd);
 	if (pmd_trans_unstable(pmd))
@@ -280,8 +282,22 @@ static int madvise_free_pte_range(pmd_t *pmd, unsigned long addr,
 	for (; addr != end; pte++, addr += PAGE_SIZE) {
 		ptent = *pte;
 
-		if (!pte_present(ptent))
+		if (pte_none(ptent))
 			continue;
+		/*
+		 * If the pte has swp_entry, just clear page table to
+		 * prevent swap-in which is more expensive rather than
+		 * (page allocation + zeroing).
+		 */
+		if (!pte_present(ptent)) {
+			entry = pte_to_swp_entry(ptent);
+			if (non_swap_entry(entry))
+				continue;
+			nr_swap--;
+			free_swap_and_cache(entry);
+			pte_clear_not_present_full(mm, addr, pte, tlb->fullmm);
+			continue;
+		}
 
 		page = vm_normal_page(vma, addr, ptent);
 		if (!page)
@@ -313,6 +329,14 @@ static int madvise_free_pte_range(pmd_t *pmd, unsigned long addr,
 		set_pte_at(mm, addr, pte, ptent);
 		tlb_remove_tlb_entry(tlb, pte, addr);
 	}
+
+	if (nr_swap) {
+		if (current->mm == mm)
+			sync_mm_rss(mm);
+
+		add_mm_counter(mm, MM_SWAPENTS, nr_swap);
+	}
+
 	arch_leave_lazy_mmu_mode();
 	pte_unmap_unlock(pte - 1, ptl);
 	cond_resched();
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
