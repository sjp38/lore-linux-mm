Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 85388280850
	for <linux-mm@kvack.org>; Sun, 21 May 2017 22:18:27 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id j28so110254792pfk.14
        for <linux-mm@kvack.org>; Sun, 21 May 2017 19:18:27 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id b76si15739303pfd.382.2017.05.21.19.18.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 21 May 2017 19:18:26 -0700 (PDT)
From: "Huang, Ying" <ying.huang@intel.com>
Subject: [PATCH] mm, THP, swap: Check whether CONFIG_THP_SWAP enabled earlier
Date: Mon, 22 May 2017 10:18:14 +0800
Message-Id: <20170522021814.17891-1-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Ying <ying.huang@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>

From: Huang Ying <ying.huang@intel.com>

This patch is only a code clean up patch without functionality
changes.  It moves CONFIG_THP_SWAP checking from inside swap slot
allocation to before we start swapping the THP.  This makes the code
path a little easier to be followed and understood.

Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Minchan Kim <minchan@kernel.org>
---
 mm/swap_slots.c | 3 +--
 mm/vmscan.c     | 3 ++-
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/mm/swap_slots.c b/mm/swap_slots.c
index 90c1032a8ac3..14c2a91289e5 100644
--- a/mm/swap_slots.c
+++ b/mm/swap_slots.c
@@ -310,8 +310,7 @@ swp_entry_t get_swap_page(struct page *page)
 	entry.val = 0;
 
 	if (PageTransHuge(page)) {
-		if (IS_ENABLED(CONFIG_THP_SWAP))
-			get_swap_pages(1, true, &entry);
+		get_swap_pages(1, true, &entry);
 		return entry;
 	}
 
diff --git a/mm/vmscan.c b/mm/vmscan.c
index f7e949ac9756..90722afd4916 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1134,7 +1134,8 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 				 * away. Chances are some or all of the
 				 * tail pages can be freed without IO.
 				 */
-				if (!compound_mapcount(page) &&
+				if ((!IS_ENABLED(CONFIG_THP_SWAP) ||
+				     !compound_mapcount(page)) &&
 				    split_huge_page_to_list(page, page_list))
 					goto activate_locked;
 			}
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
