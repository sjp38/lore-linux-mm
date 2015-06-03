Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 4D21B900016
	for <linux-mm@kvack.org>; Wed,  3 Jun 2015 02:16:00 -0400 (EDT)
Received: by payr10 with SMTP id r10so161010pay.1
        for <linux-mm@kvack.org>; Tue, 02 Jun 2015 23:16:00 -0700 (PDT)
Received: from lgeamrelo02.lge.com (lgeamrelo02.lge.com. [156.147.1.126])
        by mx.google.com with ESMTP id fu16si1736678pdb.173.2015.06.02.23.15.54
        for <linux-mm@kvack.org>;
        Tue, 02 Jun 2015 23:15:55 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [RFC 3/6] mm: mark dirty bit on swapped-in page
Date: Wed,  3 Jun 2015 15:15:42 +0900
Message-Id: <1433312145-19386-4-git-send-email-minchan@kernel.org>
In-Reply-To: <1433312145-19386-1-git-send-email-minchan@kernel.org>
References: <1433312145-19386-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Minchan Kim <minchan@kernel.org>, Cyrill Gorcunov <gorcunov@gmail.com>, Pavel Emelyanov <xemul@parallels.com>, Yalin Wang <yalin.wang@sonymobile.com>

Basically, MADV_FREE relys on the dirty bit in page table entry
to decide whether VM allows to discard the page or not.
IOW, if page table entry includes marked dirty bit, VM shouldn't
discard the page.

However, if swap-in by read fault happens, page table entry
point out the page doesn't have marked dirty bit so MADV_FREE
might discard the page wrongly.

To fix the problem, this patch marks page table entry of page
swapping-in as dirty so VM shouldn't discard the page suddenly
under us.

With MADV_FREE point of view, marking dirty unconditionally is
no problem because we dropped swapped page in MADV_FREE sycall
context(ie, Look at madvise_free_pte_range) so every swapping-in
pages are no MADV_FREE hinted pages.

Cc: Hugh Dickins <hughd@google.com>
Cc: Cyrill Gorcunov <gorcunov@gmail.com>
Cc: Pavel Emelyanov <xemul@parallels.com>
Reported-by: Yalin Wang <yalin.wang@sonymobile.com>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 mm/memory.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index 8a2fc9945b46..d1709f763152 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2557,9 +2557,11 @@ static int do_swap_page(struct mm_struct *mm, struct vm_area_struct *vma,
 
 	inc_mm_counter_fast(mm, MM_ANONPAGES);
 	dec_mm_counter_fast(mm, MM_SWAPENTS);
-	pte = mk_pte(page, vma->vm_page_prot);
+
+	/* Mark dirty bit of page table because MADV_FREE relies on it */
+	pte = pte_mkdirty(mk_pte(page, vma->vm_page_prot));
 	if ((flags & FAULT_FLAG_WRITE) && reuse_swap_page(page)) {
-		pte = maybe_mkwrite(pte_mkdirty(pte), vma);
+		pte = maybe_mkwrite(pte, vma);
 		flags &= ~FAULT_FLAG_WRITE;
 		ret |= VM_FAULT_WRITE;
 		exclusive = 1;
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
