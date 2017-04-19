Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id F0CEA6B03AD
	for <linux-mm@kvack.org>; Wed, 19 Apr 2017 03:06:50 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id g23so8162237pfj.10
        for <linux-mm@kvack.org>; Wed, 19 Apr 2017 00:06:50 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id a101si1528678pli.74.2017.04.19.00.06.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Apr 2017 00:06:50 -0700 (PDT)
From: "Huang, Ying" <ying.huang@intel.com>
Subject: [PATCH -mm -v9 3/3] mm, THP, swap: Enable THP swap optimization only if has compound map
Date: Wed, 19 Apr 2017 15:06:25 +0800
Message-Id: <20170419070625.19776-4-ying.huang@intel.com>
In-Reply-To: <20170419070625.19776-1-ying.huang@intel.com>
References: <20170419070625.19776-1-ying.huang@intel.com>
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
 mm/swap_state.c | 12 +++++++++---
 1 file changed, 9 insertions(+), 3 deletions(-)

diff --git a/mm/swap_state.c b/mm/swap_state.c
index 3a3217f68937..b025c9878e5e 100644
--- a/mm/swap_state.c
+++ b/mm/swap_state.c
@@ -192,9 +192,15 @@ int add_to_swap(struct page *page, struct list_head *list)
 	VM_BUG_ON_PAGE(!PageLocked(page), page);
 	VM_BUG_ON_PAGE(!PageUptodate(page), page);
 
-	/* cannot split, skip it */
-	if (unlikely(PageTransHuge(page)) && !can_split_huge_page(page, NULL))
-		return 0;
+	if (unlikely(PageTransHuge(page))) {
+		/* cannot split, skip it */
+		if (!can_split_huge_page(page, NULL))
+			return 0;
+		/* fallback to split huge page firstly if no PMD map */
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
