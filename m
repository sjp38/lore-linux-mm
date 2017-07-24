Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 09C286B02B4
	for <linux-mm@kvack.org>; Mon, 24 Jul 2017 01:18:51 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id 123so139893021pgj.4
        for <linux-mm@kvack.org>; Sun, 23 Jul 2017 22:18:51 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id r85si5471938pfb.477.2017.07.23.22.18.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 23 Jul 2017 22:18:49 -0700 (PDT)
From: "Huang, Ying" <ying.huang@intel.com>
Subject: [PATCH -mm -v3 01/12] mm, THP, swap: Support to clear swap cache flag for THP swapped out
Date: Mon, 24 Jul 2017 13:18:29 +0800
Message-Id: <20170724051840.2309-2-ying.huang@intel.com>
In-Reply-To: <20170724051840.2309-1-ying.huang@intel.com>
References: <20170724051840.2309-1-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Ying <ying.huang@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Rik van Riel <riel@redhat.com>

From: Huang Ying <ying.huang@intel.com>

Previously, swapcache_free_cluster() is used only in the error path of
shrink_page_list() to free the swap cluster just allocated if the
THP (Transparent Huge Page) is failed to be split.  In this patch, it
is enhanced to clear the swap cache flag (SWAP_HAS_CACHE) for the swap
cluster that holds the contents of THP swapped out.

This will be used in delaying splitting THP after swapping out
support.  Because there is no THP swapping in as a whole support yet,
after clearing the swap cache flag, the swap cluster backing the THP
swapped out will be split.  So that the swap slots in the swap cluster
can be swapped in as normal pages later.

Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Hugh Dickins <hughd@google.com>
Cc: Shaohua Li <shli@kernel.org>
Cc: Rik van Riel <riel@redhat.com>
---
 mm/swapfile.c | 32 +++++++++++++++++++++++++-------
 1 file changed, 25 insertions(+), 7 deletions(-)

diff --git a/mm/swapfile.c b/mm/swapfile.c
index 6ba4aab2db0b..c32e9b23d642 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -1168,22 +1168,40 @@ static void swapcache_free_cluster(swp_entry_t entry)
 	struct swap_cluster_info *ci;
 	struct swap_info_struct *si;
 	unsigned char *map;
-	unsigned int i;
+	unsigned int i, free_entries = 0;
+	unsigned char val;
 
-	si = swap_info_get(entry);
+	si = _swap_info_get(entry);
 	if (!si)
 		return;
 
 	ci = lock_cluster(si, offset);
 	map = si->swap_map + offset;
 	for (i = 0; i < SWAPFILE_CLUSTER; i++) {
-		VM_BUG_ON(map[i] != SWAP_HAS_CACHE);
-		map[i] = 0;
+		val = map[i];
+		VM_BUG_ON(!(val & SWAP_HAS_CACHE));
+		if (val == SWAP_HAS_CACHE)
+			free_entries++;
+	}
+	if (!free_entries) {
+		for (i = 0; i < SWAPFILE_CLUSTER; i++)
+			map[i] &= ~SWAP_HAS_CACHE;
 	}
 	unlock_cluster(ci);
-	mem_cgroup_uncharge_swap(entry, SWAPFILE_CLUSTER);
-	swap_free_cluster(si, idx);
-	spin_unlock(&si->lock);
+	if (free_entries == SWAPFILE_CLUSTER) {
+		spin_lock(&si->lock);
+		ci = lock_cluster(si, offset);
+		memset(map, 0, SWAPFILE_CLUSTER);
+		unlock_cluster(ci);
+		mem_cgroup_uncharge_swap(entry, SWAPFILE_CLUSTER);
+		swap_free_cluster(si, idx);
+		spin_unlock(&si->lock);
+	} else if (free_entries) {
+		for (i = 0; i < SWAPFILE_CLUSTER; i++, entry.val++) {
+			if (!__swap_entry_free(si, entry, SWAP_HAS_CACHE))
+				free_swap_slot(entry);
+		}
+	}
 }
 #else
 static inline void swapcache_free_cluster(swp_entry_t entry)
-- 
2.13.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
