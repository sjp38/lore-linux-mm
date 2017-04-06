Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8473F6B03E8
	for <linux-mm@kvack.org>; Thu,  6 Apr 2017 01:35:53 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id p20so25929774pgd.21
        for <linux-mm@kvack.org>; Wed, 05 Apr 2017 22:35:53 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id d76si681437pfe.306.2017.04.05.22.35.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Apr 2017 22:35:52 -0700 (PDT)
From: "Huang, Ying" <ying.huang@intel.com>
Subject: [PATCH -mm -v8 3/3] mm, THP, swap: Enable THP swap optimization only if has compound map
Date: Thu,  6 Apr 2017 13:35:15 +0800
Message-Id: <20170406053515.4842-4-ying.huang@intel.com>
In-Reply-To: <20170406053515.4842-1-ying.huang@intel.com>
References: <20170406053515.4842-1-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Ying <ying.huang@intel.com>, Johannes Weiner <hannes@cmpxchg.org>

From: Huang Ying <ying.huang@intel.com>

If there is no compound map for a THP (Transparent Huge Page), it is
possible that the map count of some sub-pages of the THP is 0.  So it
is better to split the THP before swapping out. In this way, the
sub-pages not mapped will be freed, and we can avoid the unnecessary
swap out operations for these sub-pages.

Cc: Johannes Weiner <hannes@cmpxchg.org>
Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
---
 mm/swap_state.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/mm/swap_state.c b/mm/swap_state.c
index 612fb2418df6..528af29327c9 100644
--- a/mm/swap_state.c
+++ b/mm/swap_state.c
@@ -205,7 +205,9 @@ int add_to_swap(struct page *page, struct list_head *list)
 		/* cannot split, skip it */
 		if (!can_split_huge_page(page, NULL))
 			return 0;
-		huge = true;
+		/* fallback to split huge page firstly if no PMD map */
+		if (compound_mapcount(page))
+			huge = true;
 	}
 #endif
 
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
