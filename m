Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id B1DD66B3F6A
	for <linux-mm@kvack.org>; Mon, 27 Aug 2018 03:55:49 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id d22-v6so11293122pfn.3
        for <linux-mm@kvack.org>; Mon, 27 Aug 2018 00:55:49 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id j5-v6si13565094plk.406.2018.08.27.00.55.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Aug 2018 00:55:48 -0700 (PDT)
From: Huang Ying <ying.huang@intel.com>
Subject: [PATCH 3/3] swap: Clear si->swap_map[] in swap_free_cluster()
Date: Mon, 27 Aug 2018 15:55:35 +0800
Message-Id: <20180827075535.17406-4-ying.huang@intel.com>
In-Reply-To: <20180827075535.17406-1-ying.huang@intel.com>
References: <20180827075535.17406-1-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Ying <ying.huang@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>

si->swap_map[] of the swap entries in cluster needs to be cleared
during freeing.  Previously, this is done in the caller of
swap_free_cluster().  This may cause code duplication (one user now,
will add more users later) and lock/unlock cluster unnecessarily.  In
this patch, the clearing code is moved to swap_free_cluster() to avoid
the downside.

Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
Cc: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Shaohua Li <shli@kernel.org>
Cc: Hugh Dickins <hughd@google.com>
Cc: Minchan Kim <minchan@kernel.org>
---
 mm/swapfile.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/mm/swapfile.c b/mm/swapfile.c
index ef974bbd7715..97a1bd1a7c9a 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -933,6 +933,7 @@ static void swap_free_cluster(struct swap_info_struct *si, unsigned long idx)
 	struct swap_cluster_info *ci;
 
 	ci = lock_cluster(si, offset);
+	memset(si->swap_map + offset, 0, SWAPFILE_CLUSTER);
 	cluster_set_count_flag(ci, 0, 0);
 	free_cluster(si, idx);
 	unlock_cluster(ci);
@@ -1309,9 +1310,6 @@ void put_swap_page(struct page *page, swp_entry_t entry)
 		if (free_entries == SWAPFILE_CLUSTER) {
 			unlock_cluster_or_swap_info(si, ci);
 			spin_lock(&si->lock);
-			ci = lock_cluster(si, offset);
-			memset(map, 0, SWAPFILE_CLUSTER);
-			unlock_cluster(ci);
 			mem_cgroup_uncharge_swap(entry, SWAPFILE_CLUSTER);
 			swap_free_cluster(si, idx);
 			spin_unlock(&si->lock);
-- 
2.16.4
