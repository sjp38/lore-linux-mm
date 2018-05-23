Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 907FE6B000C
	for <linux-mm@kvack.org>; Wed, 23 May 2018 04:26:44 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id q15-v6so12672689pff.17
        for <linux-mm@kvack.org>; Wed, 23 May 2018 01:26:44 -0700 (PDT)
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id y16-v6si17687140pfm.140.2018.05.23.01.26.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 May 2018 01:26:43 -0700 (PDT)
From: "Huang, Ying" <ying.huang@intel.com>
Subject: [PATCH -mm -V3 04/21] mm, THP, swap: Support PMD swap mapping in swapcache_free_cluster()
Date: Wed, 23 May 2018 16:26:08 +0800
Message-Id: <20180523082625.6897-5-ying.huang@intel.com>
In-Reply-To: <20180523082625.6897-1-ying.huang@intel.com>
References: <20180523082625.6897-1-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Ying <ying.huang@intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Zi Yan <zi.yan@cs.rutgers.edu>

From: Huang Ying <ying.huang@intel.com>

Previously, during swapout, all PMD page mapping will be split and
replaced with PTE swap mapping.  And when clearing the SWAP_HAS_CACHE
flag for the huge swap cluster in swapcache_free_cluster(), the huge
swap cluster will be split.  Now, during swapout, the PMD page mapping
will be changed to PMD swap mapping.  So when clearing the
SWAP_HAS_CACHE flag, the huge swap cluster will only be split if the
PMD swap mapping count is 0.  Otherwise, we will keep it as the huge
swap cluster.  So that we can swapin a THP as a whole later.

Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Shaohua Li <shli@kernel.org>
Cc: Hugh Dickins <hughd@google.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Rik van Riel <riel@redhat.com>
Cc: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Zi Yan <zi.yan@cs.rutgers.edu>
---
 mm/swapfile.c | 41 ++++++++++++++++++++++++++++++-----------
 1 file changed, 30 insertions(+), 11 deletions(-)

diff --git a/mm/swapfile.c b/mm/swapfile.c
index 075048032383..8dbc0f9b2f90 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -514,6 +514,18 @@ static void dec_cluster_info_page(struct swap_info_struct *p,
 		free_cluster(p, idx);
 }
 
+#ifdef CONFIG_THP_SWAP
+static inline int cluster_swapcount(struct swap_cluster_info *ci)
+{
+	if (!ci || !cluster_is_huge(ci))
+		return 0;
+
+	return cluster_count(ci) - SWAPFILE_CLUSTER;
+}
+#else
+#define cluster_swapcount(ci)			0
+#endif
+
 /*
  * It's possible scan_swap_map() uses a free cluster in the middle of free
  * cluster list. Avoiding such abuse to avoid list corruption.
@@ -905,6 +917,7 @@ static void swap_free_cluster(struct swap_info_struct *si, unsigned long idx)
 	struct swap_cluster_info *ci;
 
 	ci = lock_cluster(si, offset);
+	memset(si->swap_map + offset, 0, SWAPFILE_CLUSTER);
 	cluster_set_count_flag(ci, 0, 0);
 	free_cluster(si, idx);
 	unlock_cluster(ci);
@@ -1288,24 +1301,30 @@ static void swapcache_free_cluster(swp_entry_t entry)
 
 	ci = lock_cluster(si, offset);
 	VM_BUG_ON(!cluster_is_huge(ci));
+	VM_BUG_ON(!is_cluster_offset(offset));
+	VM_BUG_ON(cluster_count(ci) < SWAPFILE_CLUSTER);
 	map = si->swap_map + offset;
-	for (i = 0; i < SWAPFILE_CLUSTER; i++) {
-		val = map[i];
-		VM_BUG_ON(!(val & SWAP_HAS_CACHE));
-		if (val == SWAP_HAS_CACHE)
-			free_entries++;
+	if (!cluster_swapcount(ci)) {
+		for (i = 0; i < SWAPFILE_CLUSTER; i++) {
+			val = map[i];
+			VM_BUG_ON(!(val & SWAP_HAS_CACHE));
+			if (val == SWAP_HAS_CACHE)
+				free_entries++;
+		}
+		if (free_entries != SWAPFILE_CLUSTER)
+			cluster_clear_huge(ci);
 	}
 	if (!free_entries) {
-		for (i = 0; i < SWAPFILE_CLUSTER; i++)
-			map[i] &= ~SWAP_HAS_CACHE;
+		for (i = 0; i < SWAPFILE_CLUSTER; i++) {
+			val = map[i];
+			VM_BUG_ON(!(val & SWAP_HAS_CACHE) ||
+				  val == SWAP_HAS_CACHE);
+			map[i] = val & ~SWAP_HAS_CACHE;
+		}
 	}
-	cluster_clear_huge(ci);
 	unlock_cluster(ci);
 	if (free_entries == SWAPFILE_CLUSTER) {
 		spin_lock(&si->lock);
-		ci = lock_cluster(si, offset);
-		memset(map, 0, SWAPFILE_CLUSTER);
-		unlock_cluster(ci);
 		mem_cgroup_uncharge_swap(entry, SWAPFILE_CLUSTER);
 		swap_free_cluster(si, idx);
 		spin_unlock(&si->lock);
-- 
2.16.1
