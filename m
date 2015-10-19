Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id A6B9282F67
	for <linux-mm@kvack.org>; Mon, 19 Oct 2015 02:28:44 -0400 (EDT)
Received: by pabrc13 with SMTP id rc13so181337489pab.0
        for <linux-mm@kvack.org>; Sun, 18 Oct 2015 23:28:44 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTPS id xc2si50298383pbc.187.2015.10.18.23.28.40
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 18 Oct 2015 23:28:41 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH 2/5] mm: skip huge zero page in MADV_FREE
Date: Mon, 19 Oct 2015 15:31:44 +0900
Message-Id: <1445236307-895-3-git-send-email-minchan@kernel.org>
In-Reply-To: <1445236307-895-1-git-send-email-minchan@kernel.org>
References: <1445236307-895-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, Vlastimil Babka <vbabka@suse.cz>, Minchan Kim <minchan@kernel.org>

It is pointless to mark huge zero page as freeable.
Let's skip it.

Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 mm/huge_memory.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index f1de4ce583a6..269ed99493f0 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1542,6 +1542,9 @@ int madvise_free_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
 		struct page *page;
 		pmd_t orig_pmd;
 
+		if (is_huge_zero_pmd(*pmd))
+			goto out;
+
 		orig_pmd = pmdp_huge_get_and_clear(mm, addr, pmd);
 
 		/* No hugepage in swapcache */
@@ -1553,6 +1556,7 @@ int madvise_free_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
 
 		set_pmd_at(mm, addr, pmd, orig_pmd);
 		tlb_remove_pmd_tlb_entry(tlb, pmd, addr);
+out:
 		spin_unlock(ptl);
 		ret = 0;
 	}
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
