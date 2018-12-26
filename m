Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id CB2E98E0001
	for <linux-mm@kvack.org>; Wed, 26 Dec 2018 00:15:03 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id v2so13255563plg.6
        for <linux-mm@kvack.org>; Tue, 25 Dec 2018 21:15:03 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id x8si30051856pll.187.2018.12.25.21.15.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Dec 2018 21:15:02 -0800 (PST)
From: Huang Ying <ying.huang@intel.com>
Subject: [PATCH] mm, swap: Fix swapoff with KSM pages
Date: Wed, 26 Dec 2018 13:15:22 +0800
Message-Id: <20181226051522.28442-1-ying.huang@intel.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Ying <ying.huang@intel.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Shaohua Li <shli@kernel.org>, Daniel Jordan <daniel.m.jordan@oracle.com>, Hugh Dickins <hughd@google.com>

KSM pages may be mapped to the multiple VMAs that cannot be reached
from one anon_vma.  So during swapin, a new copy of the page need to
be generated if a different anon_vma is needed, please refer to
comments of ksm_might_need_to_copy() for details.

During swapoff, unuse_vma() uses anon_vma (if available) to locate VMA
and virtual address mapped to the page, so not all mappings to a
swapped out KSM page could be found.  So in try_to_unuse(), even if
the swap count of a swap entry isn't zero, the page needs to be
deleted from swap cache, so that, in the next round a new page could
be allocated and swapin for the other mappings of the swapped out KSM
page.

But this contradicts with the THP swap support.  Where the THP could
be deleted from swap cache only after the swap count of every swap
entry in the huge swap cluster backing the THP has reach 0.  So
try_to_unuse() is changed in commit e07098294adf ("mm, THP, swap:
support to reclaim swap space for THP swapped out") to check that
before delete a page from swap cache, but this has broken KSM swapoff
too.

Fortunately, KSM is for the normal pages only, so the original
behavior for KSM pages could be restored easily via checking
PageTransCompound().  That is how this patch works.

Fixes: e07098294adf ("mm, THP, swap: support to reclaim swap space for THP swapped out")
Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
Reported-and-Tested-and-Acked-by: Hugh Dickins <hughd@google.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Shaohua Li <shli@kernel.org>
Cc: Daniel Jordan <daniel.m.jordan@oracle.com>
---
 mm/swapfile.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/mm/swapfile.c b/mm/swapfile.c
index 8688ae65ef58..20d3c0f47a5f 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -2197,7 +2197,8 @@ int try_to_unuse(unsigned int type, bool frontswap,
 		 */
 		if (PageSwapCache(page) &&
 		    likely(page_private(page) == entry.val) &&
-		    !page_swapped(page))
+		    (!PageTransCompound(page) ||
+		     !swap_page_trans_huge_swapped(si, entry)))
 			delete_from_swap_cache(compound_head(page));
 
 		/*
-- 
2.19.2
