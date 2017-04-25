Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7C51C6B02FA
	for <linux-mm@kvack.org>; Tue, 25 Apr 2017 08:57:16 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id 72so30703895pge.10
        for <linux-mm@kvack.org>; Tue, 25 Apr 2017 05:57:16 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id a90si22400448plc.67.2017.04.25.05.57.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Apr 2017 05:57:15 -0700 (PDT)
From: "Huang, Ying" <ying.huang@intel.com>
Subject: [PATCH -mm -v10 3/3] mm, THP, swap: Enable THP swap optimization only if has compound map
Date: Tue, 25 Apr 2017 20:56:58 +0800
Message-Id: <20170425125658.28684-4-ying.huang@intel.com>
In-Reply-To: <20170425125658.28684-1-ying.huang@intel.com>
References: <20170425125658.28684-1-ying.huang@intel.com>
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
 mm/swap_state.c | 16 +++++++++++++---
 1 file changed, 13 insertions(+), 3 deletions(-)

diff --git a/mm/swap_state.c b/mm/swap_state.c
index 006d91d8fc53..13f83c6bb1b4 100644
--- a/mm/swap_state.c
+++ b/mm/swap_state.c
@@ -192,9 +192,19 @@ int add_to_swap(struct page *page, struct list_head *list)
 	VM_BUG_ON_PAGE(!PageLocked(page), page);
 	VM_BUG_ON_PAGE(!PageUptodate(page), page);
 
-	/* cannot split, skip it */
-	if (PageTransHuge(page) && !can_split_huge_page(page, NULL))
-		return 0;
+	if (PageTransHuge(page)) {
+		/* cannot split, skip it */
+		if (!can_split_huge_page(page, NULL))
+			return 0;
+		/*
+		 * Split pages without a PMD map right away. Chances
+		 * are some or all of the tail pages can be freed
+		 * without IO.
+		 */
+		if (!compound_mapcount(page) &&
+		    split_huge_page_to_list(page, list))
+			return 0;
+	}
 
 retry:
 	entry = get_swap_page(page);
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
