Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f178.google.com (mail-ig0-f178.google.com [209.85.213.178])
	by kanga.kvack.org (Postfix) with ESMTP id 9E2246B0259
	for <linux-mm@kvack.org>; Mon, 30 Nov 2015 01:39:37 -0500 (EST)
Received: by igcph11 with SMTP id ph11so58011942igc.1
        for <linux-mm@kvack.org>; Sun, 29 Nov 2015 22:39:37 -0800 (PST)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTPS id vt2si92469igb.70.2015.11.29.22.39.29
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Sun, 29 Nov 2015 22:39:30 -0800 (PST)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v5 04/12] mm: free swp_entry in madvise_free
Date: Mon, 30 Nov 2015 15:39:35 +0900
Message-Id: <1448865583-2446-5-git-send-email-minchan@kernel.org>
In-Reply-To: <1448865583-2446-1-git-send-email-minchan@kernel.org>
References: <1448865583-2446-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michael Kerrisk <mtk.manpages@gmail.com>, linux-api@vger.kernel.org, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Jason Evans <je@fb.com>, Daniel Micay <danielmicay@gmail.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Shaohua Li <shli@kernel.org>, Michal Hocko <mhocko@suse.cz>, yalin.wang2010@gmail.com, Andy Lutomirski <luto@amacapital.net>, Minchan Kim <minchan@kernel.org>, Michal Hocko <mhocko@suse.com>

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

Acked-by: Michal Hocko <mhocko@suse.com>
Acked-by: Hugh Dickins <hughd@google.com>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 mm/madvise.c | 25 ++++++++++++++++++++++++-
 1 file changed, 24 insertions(+), 1 deletion(-)

diff --git a/mm/madvise.c b/mm/madvise.c
index e2fe2e26f449..8de3d9a636c9 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -270,6 +270,7 @@ static int madvise_free_pte_range(pmd_t *pmd, unsigned long addr,
 	spinlock_t *ptl;
 	pte_t *orig_pte, *pte, ptent;
 	struct page *page;
+	int nr_swap = 0;
 
 	split_huge_pmd(vma, pmd, addr);
 	if (pmd_trans_unstable(pmd))
@@ -280,8 +281,24 @@ static int madvise_free_pte_range(pmd_t *pmd, unsigned long addr,
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
+			swp_entry_t entry;
+
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
@@ -353,6 +370,12 @@ static int madvise_free_pte_range(pmd_t *pmd, unsigned long addr,
 		}
 	}
 out:
+	if (nr_swap) {
+		if (current->mm == mm)
+			sync_mm_rss(mm);
+
+		add_mm_counter(mm, MM_SWAPENTS, nr_swap);
+	}
 	arch_leave_lazy_mmu_mode();
 	pte_unmap_unlock(orig_pte, ptl);
 	cond_resched();
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
