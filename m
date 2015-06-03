Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 2AA30900016
	for <linux-mm@kvack.org>; Wed,  3 Jun 2015 02:15:53 -0400 (EDT)
Received: by padj3 with SMTP id j3so186521pad.0
        for <linux-mm@kvack.org>; Tue, 02 Jun 2015 23:15:52 -0700 (PDT)
Received: from lgeamrelo02.lge.com (lgeamrelo02.lge.com. [156.147.1.126])
        by mx.google.com with ESMTP id ua7si30051773pab.105.2015.06.02.23.15.51
        for <linux-mm@kvack.org>;
        Tue, 02 Jun 2015 23:15:52 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [RFC 4/6] mm: mark dirty bit on unuse_pte
Date: Wed,  3 Jun 2015 15:15:43 +0900
Message-Id: <1433312145-19386-5-git-send-email-minchan@kernel.org>
In-Reply-To: <1433312145-19386-1-git-send-email-minchan@kernel.org>
References: <1433312145-19386-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Minchan Kim <minchan@kernel.org>

Basically, MADV_FREE relys on the dirty bit in page table entry
to decide whether VM allows to discard the page or not.
IOW, if page table entry includes marked dirty bit, VM shouldn't
discard the page.

However, if swapoff happens, page table entry point out the page
doesn't have marked dirty bit so MADV_FREE might discard the page
wrongly.

To fix the problem, this patch marks page table entry of page
as dirty when swapoff hanppens VM shouldn't discard the page
suddenly under us.

With MADV_FREE point of view, marking dirty unconditionally is
no problem because we dropped swapped page in MADV_FREE sycall
context(ie, Look at madvise_free_pte_range) so every swapping-in
pages are no MADV_FREE hinted pages.

Cc: Hugh Dickins <hughd@google.com>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 mm/swapfile.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/mm/swapfile.c b/mm/swapfile.c
index a7e72103f23b..cc8b79ab2190 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -1118,8 +1118,12 @@ static int unuse_pte(struct vm_area_struct *vma, pmd_t *pmd,
 	dec_mm_counter(vma->vm_mm, MM_SWAPENTS);
 	inc_mm_counter(vma->vm_mm, MM_ANONPAGES);
 	get_page(page);
+	/*
+	 * For preventing sudden freeing by MADV_FREE, pte must have a
+	 * dirty flag.
+	 */
 	set_pte_at(vma->vm_mm, addr, pte,
-		   pte_mkold(mk_pte(page, vma->vm_page_prot)));
+		   pte_mkdirty(pte_mkold(mk_pte(page, vma->vm_page_prot))));
 	if (page == swapcache) {
 		page_add_anon_rmap(page, vma, addr);
 		mem_cgroup_commit_charge(page, memcg, true);
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
