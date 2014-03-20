Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f48.google.com (mail-pb0-f48.google.com [209.85.160.48])
	by kanga.kvack.org (Postfix) with ESMTP id 7DB3D6B0195
	for <linux-mm@kvack.org>; Thu, 20 Mar 2014 02:39:49 -0400 (EDT)
Received: by mail-pb0-f48.google.com with SMTP id md12so485486pbc.21
        for <linux-mm@kvack.org>; Wed, 19 Mar 2014 23:39:49 -0700 (PDT)
Received: from LGEAMRELO01.lge.com (lgeamrelo01.lge.com. [156.147.1.125])
        by mx.google.com with ESMTP id uk5si712438pab.191.2014.03.19.23.39.43
        for <linux-mm@kvack.org>;
        Wed, 19 Mar 2014 23:39:45 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [RFC v2 3/3] mm: deactivate lazyfree pages
Date: Thu, 20 Mar 2014 15:38:58 +0900
Message-Id: <1395297538-10491-4-git-send-email-minchan@kernel.org>
In-Reply-To: <1395297538-10491-1-git-send-email-minchan@kernel.org>
References: <1395297538-10491-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, John Stultz <john.stultz@linaro.org>, Jason Evans <je@fb.com>, Minchan Kim <minchan@kernel.org>

MADV_FREEed pages should be discarded before working set pages
are reclaimed because most of users(ex, tcmalloc and jemalloc)
have used it instead of MADV_DONTNEED which zap pages instantly.

Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 mm/memory.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/mm/memory.c b/mm/memory.c
index 6f221225f62b..76b683e7d087 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1298,6 +1298,7 @@ static unsigned long lazyfree_pte_range(struct mmu_gather *tlb,
 		ptent = pte_mkclean(ptent);
 		set_pte_at(mm, addr, pte, ptent);
 		tlb_remove_tlb_entry(tlb, pte, addr);
+		deactivate_page(page);
 	} while (pte++, addr += PAGE_SIZE, addr != end);
 	arch_leave_lazy_mmu_mode();
 	pte_unmap_unlock(start_pte, ptl);
-- 
1.9.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
