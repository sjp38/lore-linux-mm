Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id F1B556B02F3
	for <linux-mm@kvack.org>; Thu, 29 Jun 2017 21:44:55 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id e3so102924145pfc.4
        for <linux-mm@kvack.org>; Thu, 29 Jun 2017 18:44:55 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id l5si4691214pgu.532.2017.06.29.18.44.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Jun 2017 18:44:55 -0700 (PDT)
From: "Huang, Ying" <ying.huang@intel.com>
Subject: [PATCH -mm -v2 3/6] mm, swap: Fix swap readahead marking
Date: Fri, 30 Jun 2017 09:44:40 +0800
Message-Id: <20170630014443.23983-4-ying.huang@intel.com>
In-Reply-To: <20170630014443.23983-1-ying.huang@intel.com>
References: <20170630014443.23983-1-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Ying <ying.huang@intel.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Fengguang Wu <fengguang.wu@intel.com>, Tim Chen <tim.c.chen@intel.com>, Dave Hansen <dave.hansen@intel.com>

From: Huang Ying <ying.huang@intel.com>

In the original implementation, it is possible that the existing pages
in the swap cache (not newly readahead) could be marked as the
readahead pages.  This will cause the statistics of swap readahead be
wrong and influence the swap readahead algorithm too.

This is fixed via marking a page as the readahead page only if it is
newly allocated and read from the disk.

When testing with linpack, after the fixing the swap readahead hit
rate increased from ~66% to ~86%.

Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Rik van Riel <riel@redhat.com>
Cc: Shaohua Li <shli@kernel.org>
Cc: Hugh Dickins <hughd@google.com>
Cc: Fengguang Wu <fengguang.wu@intel.com>
Cc: Tim Chen <tim.c.chen@intel.com>
Cc: Dave Hansen <dave.hansen@intel.com>
---
 mm/swap_state.c | 18 +++++++++++-------
 1 file changed, 11 insertions(+), 7 deletions(-)

diff --git a/mm/swap_state.c b/mm/swap_state.c
index 6739343a3695..b40fb227021d 100644
--- a/mm/swap_state.c
+++ b/mm/swap_state.c
@@ -500,7 +500,7 @@ struct page *swapin_readahead(swp_entry_t entry, gfp_t gfp_mask,
 	unsigned long start_offset, end_offset;
 	unsigned long mask;
 	struct blk_plug plug;
-	bool do_poll = true;
+	bool do_poll = true, page_allocated;
 
 	mask = swapin_nr_pages(offset) - 1;
 	if (!mask)
@@ -516,14 +516,18 @@ struct page *swapin_readahead(swp_entry_t entry, gfp_t gfp_mask,
 	blk_start_plug(&plug);
 	for (offset = start_offset; offset <= end_offset ; offset++) {
 		/* Ok, do the async read-ahead now */
-		page = read_swap_cache_async(swp_entry(swp_type(entry), offset),
-						gfp_mask, vma, addr, false);
+		page = __read_swap_cache_async(
+			swp_entry(swp_type(entry), offset),
+			gfp_mask, vma, addr, &page_allocated);
 		if (!page)
 			continue;
-		if (offset != entry_offset &&
-		    likely(!PageTransCompound(page))) {
-			SetPageReadahead(page);
-			atomic_long_inc(&swapin_readahead_total);
+		if (page_allocated) {
+			swap_readpage(page, false);
+			if (offset != entry_offset &&
+			    likely(!PageTransCompound(page))) {
+				SetPageReadahead(page);
+				atomic_long_inc(&swapin_readahead_total);
+			}
 		}
 		put_page(page);
 	}
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
