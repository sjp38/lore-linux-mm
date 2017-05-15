Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id F26146B0311
	for <linux-mm@kvack.org>; Mon, 15 May 2017 07:25:42 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id 123so109204069pge.14
        for <linux-mm@kvack.org>; Mon, 15 May 2017 04:25:42 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id y64si10640992plh.78.2017.05.15.04.25.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 May 2017 04:25:42 -0700 (PDT)
From: "Huang, Ying" <ying.huang@intel.com>
Subject: [PATCH -mm -v11 5/5] mm, THP, swap: Enable THP swap optimization only if has compound map
Date: Mon, 15 May 2017 19:25:22 +0800
Message-Id: <20170515112522.32457-6-ying.huang@intel.com>
In-Reply-To: <20170515112522.32457-1-ying.huang@intel.com>
References: <20170515112522.32457-1-ying.huang@intel.com>
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
 mm/vmscan.c | 17 +++++++++++++----
 1 file changed, 13 insertions(+), 4 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index a5355022dc2f..f7e949ac9756 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1125,10 +1125,19 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		    !PageSwapCache(page)) {
 			if (!(sc->gfp_mask & __GFP_IO))
 				goto keep_locked;
-			/* cannot split THP, skip it */
-			if (PageTransHuge(page) &&
-			    !can_split_huge_page(page, NULL))
-				goto activate_locked;
+			if (PageTransHuge(page)) {
+				/* cannot split THP, skip it */
+				if (!can_split_huge_page(page, NULL))
+					goto activate_locked;
+				/*
+				 * Split pages without a PMD map right
+				 * away. Chances are some or all of the
+				 * tail pages can be freed without IO.
+				 */
+				if (!compound_mapcount(page) &&
+				    split_huge_page_to_list(page, page_list))
+					goto activate_locked;
+			}
 			if (!add_to_swap(page)) {
 				if (!PageTransHuge(page))
 					goto activate_locked;
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
