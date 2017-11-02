Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id C21126B0253
	for <linux-mm@kvack.org>; Thu,  2 Nov 2017 01:42:31 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id w24so4829785pgm.7
        for <linux-mm@kvack.org>; Wed, 01 Nov 2017 22:42:31 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id a65si2561711pgc.699.2017.11.01.22.42.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Nov 2017 22:42:30 -0700 (PDT)
From: "Huang, Ying" <ying.huang@intel.com>
Subject: [PATCH -mm -V3] mm, swap: Fix false error message in __swp_swapcount()
Date: Thu,  2 Nov 2017 13:42:25 +0800
Message-Id: <20171102054225.22897-1-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Ying <huang.ying.caritas@gmail.com>, Tim Chen <tim.c.chen@linux.intel.com>, Michal Hocko <mhocko@suse.com>, stable@vger.kernel.org, "Huang, Ying" <ying.huang@intel.com>, Christian Kujau <lists@nerdbynature.de>, Minchan Kim <minchan@kernel.org>

From: Huang Ying <huang.ying.caritas@gmail.com>

When a page fault occurs for a swap entry, the physical swap readahead
(not the VMA base swap readahead) may readahead several swap entries
after the fault swap entry.  The readahead algorithm calculates some
of the swap entries to readahead via increasing the offset of the
fault swap entry without checking whether they are beyond the end of
the swap device and it relys on the __swp_swapcount() and
swapcache_prepare() to check it.  Although __swp_swapcount() checks
for the swap entry passed in, it will complain with the error message
as follow for the expected invalid swap entry.  This may make the end
users confused.

  swap_info_get: Bad swap offset entry 0200f8a7

To fix the false error message, the swap entry checking is added in
swapin_readahead() to avoid to pass the out-of-bound swap entries and
the swap entry reserved for the swap header to __swp_swapcount() and
swapcache_prepare().

Cc: Tim Chen <tim.c.chen@linux.intel.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: <stable@vger.kernel.org> # 4.11-4.13
Fixes: e8c26ab60598 ("mm/swap: skip readahead for unreferenced swap slots")
Reported-by: Christian Kujau <lists@nerdbynature.de>
Suggested-by: Minchan Kim <minchan@kernel.org>
Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
---
 mm/swap_state.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/mm/swap_state.c b/mm/swap_state.c
index 6c017ced11e6..6c33ebd193a9 100644
--- a/mm/swap_state.c
+++ b/mm/swap_state.c
@@ -558,6 +558,7 @@ struct page *swapin_readahead(swp_entry_t entry, gfp_t gfp_mask,
 	unsigned long offset = entry_offset;
 	unsigned long start_offset, end_offset;
 	unsigned long mask;
+	struct swap_info_struct *si = swp_swap_info(entry);
 	struct blk_plug plug;
 	bool do_poll = true, page_allocated;
 
@@ -571,6 +572,8 @@ struct page *swapin_readahead(swp_entry_t entry, gfp_t gfp_mask,
 	end_offset = offset | mask;
 	if (!start_offset)	/* First page is swap header. */
 		start_offset++;
+	if (end_offset >= si->max)
+		end_offset = si->max - 1;
 
 	blk_start_plug(&plug);
 	for (offset = start_offset; offset <= end_offset ; offset++) {
-- 
2.14.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
