Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 60DDE6B02F4
	for <linux-mm@kvack.org>; Mon, 24 Jul 2017 01:18:56 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id z74so29715777pfi.8
        for <linux-mm@kvack.org>; Sun, 23 Jul 2017 22:18:56 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id r85si5471938pfb.477.2017.07.23.22.18.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 23 Jul 2017 22:18:55 -0700 (PDT)
From: "Huang, Ying" <ying.huang@intel.com>
Subject: [PATCH -mm -v3 04/12] mm, THP, swap: Don't allocate huge cluster for file backed swap device
Date: Mon, 24 Jul 2017 13:18:32 +0800
Message-Id: <20170724051840.2309-5-ying.huang@intel.com>
In-Reply-To: <20170724051840.2309-1-ying.huang@intel.com>
References: <20170724051840.2309-1-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Ying <ying.huang@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Rik van Riel <riel@redhat.com>

From: Huang Ying <ying.huang@intel.com>

It's hard to write a whole transparent huge page (THP) to a file
backed swap device during swapping out and the file backed swap device
isn't very popular.  So the huge cluster allocation for the file
backed swap device is disabled.

Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Hugh Dickins <hughd@google.com>
Cc: Shaohua Li <shli@kernel.org>
Cc: Rik van Riel <riel@redhat.com>
---
 mm/swapfile.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/mm/swapfile.c b/mm/swapfile.c
index b110faf3c82a..21cbdecbc19a 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -948,9 +948,10 @@ int get_swap_pages(int n_goal, bool cluster, swp_entry_t swp_entries[])
 			spin_unlock(&si->lock);
 			goto nextsi;
 		}
-		if (cluster)
-			n_ret = swap_alloc_cluster(si, swp_entries);
-		else
+		if (cluster) {
+			if (!(si->flags & SWP_FILE))
+				n_ret = swap_alloc_cluster(si, swp_entries);
+		} else
 			n_ret = scan_swap_map_slots(si, SWAP_HAS_CACHE,
 						    n_goal, swp_entries);
 		spin_unlock(&si->lock);
-- 
2.13.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
