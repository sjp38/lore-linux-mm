Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 825EC6B026B
	for <linux-mm@kvack.org>; Mon, 16 Jul 2018 20:55:54 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id s3-v6so25683527plp.21
        for <linux-mm@kvack.org>; Mon, 16 Jul 2018 17:55:54 -0700 (PDT)
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id bc5-v6si30619643plb.413.2018.07.16.17.55.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Jul 2018 17:55:53 -0700 (PDT)
From: "Huang, Ying" <ying.huang@intel.com>
Subject: [PATCH v2 3/7] swap: Use swap_count() in swap_page_trans_huge_swapped()
Date: Tue, 17 Jul 2018 08:55:52 +0800
Message-Id: <20180717005556.29758-4-ying.huang@intel.com>
In-Reply-To: <20180717005556.29758-1-ying.huang@intel.com>
References: <20180717005556.29758-1-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dave Hansen <dave.hansen@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Dan Williams <dan.j.williams@intel.com>, Daniel Jordan <daniel.m.jordan@oracle.com>

In swap_page_trans_huge_swapped(), to identify whether there's any
page table mapping for a 4k sized swap entry, "si->swap_map[i] !=
SWAP_HAS_CACHE" is used.  This works correctly now, because all users
of the function will only call it after checking SWAP_HAS_CACHE.  But
as pointed out by Daniel, it is better to use "swap_count(map[i])"
here, because it works for "map[i] == 0" case too.

And this makes the implementation more consistent between normal and
huge swap entry.

Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
Suggested-by: Daniel Jordan <daniel.m.jordan@oracle.com>
Cc: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Shaohua Li <shli@kernel.org>
Cc: Hugh Dickins <hughd@google.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Rik van Riel <riel@redhat.com>
Cc: Dan Williams <dan.j.williams@intel.com>
---
 mm/swapfile.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/swapfile.c b/mm/swapfile.c
index dd9263411f11..92c24402706c 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -1494,12 +1494,12 @@ static bool swap_page_trans_huge_swapped(struct swap_info_struct *si,
 
 	ci = lock_cluster_or_swap_info(si, offset);
 	if (!ci || !cluster_is_huge(ci)) {
-		if (map[roffset] != SWAP_HAS_CACHE)
+		if (swap_count(map[roffset]))
 			ret = true;
 		goto unlock_out;
 	}
 	for (i = 0; i < SWAPFILE_CLUSTER; i++) {
-		if (map[offset + i] != SWAP_HAS_CACHE) {
+		if (swap_count(map[offset + i])) {
 			ret = true;
 			break;
 		}
-- 
2.16.4
