Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2287F6B02B4
	for <linux-mm@kvack.org>; Mon,  7 Aug 2017 01:42:02 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id 83so88064007pgb.14
        for <linux-mm@kvack.org>; Sun, 06 Aug 2017 22:42:02 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id s15si4202877pgs.640.2017.08.06.22.42.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 06 Aug 2017 22:42:01 -0700 (PDT)
From: "Huang, Ying" <ying.huang@intel.com>
Subject: [PATCH -mm -v4 2/5] mm, swap: Fix swap readahead marking
Date: Mon,  7 Aug 2017 13:40:35 +0800
Message-Id: <20170807054038.1843-3-ying.huang@intel.com>
In-Reply-To: <20170807054038.1843-1-ying.huang@intel.com>
References: <20170807054038.1843-1-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Ying <ying.huang@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Fengguang Wu <fengguang.wu@intel.com>, Tim Chen <tim.c.chen@intel.com>, Dave Hansen <dave.hansen@intel.com>

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
Cc: Johannes Weiner <hannes@cmpxchg.org>
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
index d1bdb31cab13..a901afe9da61 100644
--- a/mm/swap_state.c
+++ b/mm/swap_state.c
@@ -498,7 +498,7 @@ struct page *swapin_readahead(swp_entry_t entry, gfp_t gfp_mask,
 	unsigned long start_offset, end_offset;
 	unsigned long mask;
 	struct blk_plug plug;
-	bool do_poll = true;
+	bool do_poll = true, page_allocated;
 
 	mask = swapin_nr_pages(offset) - 1;
 	if (!mask)
@@ -514,14 +514,18 @@ struct page *swapin_readahead(swp_entry_t entry, gfp_t gfp_mask,
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
-			count_vm_event(SWAP_RA);
+		if (page_allocated) {
+			swap_readpage(page, false);
+			if (offset != entry_offset &&
+			    likely(!PageTransCompound(page))) {
+				SetPageReadahead(page);
+				count_vm_event(SWAP_RA);
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
