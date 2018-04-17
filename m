Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id C19F96B000D
	for <linux-mm@kvack.org>; Mon, 16 Apr 2018 22:02:58 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id u11-v6so11329016pls.22
        for <linux-mm@kvack.org>; Mon, 16 Apr 2018 19:02:58 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id b7si2783831pfh.257.2018.04.16.19.02.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Apr 2018 19:02:57 -0700 (PDT)
From: "Huang, Ying" <ying.huang@intel.com>
Subject: [PATCH -mm 07/21] mm, THP, swap: Support PMD swap mapping in split_swap_cluster()
Date: Tue, 17 Apr 2018 10:02:16 +0800
Message-Id: <20180417020230.26412-8-ying.huang@intel.com>
In-Reply-To: <20180417020230.26412-1-ying.huang@intel.com>
References: <20180417020230.26412-1-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tim Chen <tim.c.chen@intel.com>, Andi Kleen <ak@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Ying <ying.huang@intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Zi Yan <zi.yan@cs.rutgers.edu>

From: Huang Ying <ying.huang@intel.com>

When splitting a THP in swap cache or failing to allocate a THP when
swapin a huge swap cluster, the huge swap cluster will be split.  In
addition to clear the huge flag of the swap cluster, the PMD swap
mapping count recorded in cluster_count() will be set to 0.  But we
will not touch PMD swap mappings themselves, because it is hard to
find them all sometimes.  When the PMD swap mappings are operated
later, it will be found that the huge swap cluster has been split and
the PMD swap mappings will be split at that time.

Unless splitting a THP in swap cache (specified via "force"
parameter), split_swap_cluster() will return -EEXIST if there is
SWAP_HAS_CACHE flag in swap_map[offset].  Because this indicates there
is a THP corresponds to this huge swap cluster, and it isn't desired
to split the THP.

When splitting a THP in swap cache, the position to call
split_swap_cluster() is changed to before unlocking sub-pages.  So
that all sub-pages will be kept locked from the THP has been split to
the huge swap cluster is split.  This makes the code much easier to be
reasoned.

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
 include/linux/swap.h |  4 ++--
 mm/huge_memory.c     | 18 ++++++++++++------
 mm/swapfile.c        | 45 +++++++++++++++++++++++++++++---------------
 3 files changed, 44 insertions(+), 23 deletions(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index b5762b526719..42e962b9ad3c 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -617,10 +617,10 @@ static inline swp_entry_t get_swap_page(struct page *page)
 #endif /* CONFIG_SWAP */
 
 #ifdef CONFIG_THP_SWAP
-extern int split_swap_cluster(swp_entry_t entry);
+extern int split_swap_cluster(swp_entry_t entry, bool force);
 extern int split_swap_cluster_map(swp_entry_t entry);
 #else
-static inline int split_swap_cluster(swp_entry_t entry)
+static inline int split_swap_cluster(swp_entry_t entry, bool force)
 {
 	return 0;
 }
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 7342ad88de5d..a2124f0a0454 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -2501,6 +2501,17 @@ static void __split_huge_page(struct page *page, struct list_head *list,
 
 	unfreeze_page(head);
 
+	/*
+	 * Split swap cluster before unlocking sub-pages.  So all
+	 * sub-pages will be kept locked from THP has been split to
+	 * swap cluster is split.
+	 */
+	if (PageSwapCache(head)) {
+		swp_entry_t entry = { .val = page_private(head) };
+
+		split_swap_cluster(entry, true);
+	}
+
 	for (i = 0; i < HPAGE_PMD_NR; i++) {
 		struct page *subpage = head + i;
 		if (subpage == page)
@@ -2727,12 +2738,7 @@ int split_huge_page_to_list(struct page *page, struct list_head *list)
 			__dec_node_page_state(page, NR_SHMEM_THPS);
 		spin_unlock(&pgdata->split_queue_lock);
 		__split_huge_page(page, list, flags);
-		if (PageSwapCache(head)) {
-			swp_entry_t entry = { .val = page_private(head) };
-
-			ret = split_swap_cluster(entry);
-		} else
-			ret = 0;
+		ret = 0;
 	} else {
 		if (IS_ENABLED(CONFIG_DEBUG_VM) && mapcount) {
 			pr_alert("total_mapcount: %u, page_count(): %u\n",
diff --git a/mm/swapfile.c b/mm/swapfile.c
index 2be757548c97..cad3f416cb0a 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -1414,21 +1414,6 @@ static void swapcache_free_cluster(swp_entry_t entry)
 		}
 	}
 }
-
-int split_swap_cluster(swp_entry_t entry)
-{
-	struct swap_info_struct *si;
-	struct swap_cluster_info *ci;
-	unsigned long offset = swp_offset(entry);
-
-	si = _swap_info_get(entry);
-	if (!si)
-		return -EBUSY;
-	ci = lock_cluster(si, offset);
-	cluster_clear_huge(ci);
-	unlock_cluster(ci);
-	return 0;
-}
 #else
 static inline void swapcache_free_cluster(swp_entry_t entry)
 {
@@ -4067,6 +4052,36 @@ int split_swap_cluster_map(swp_entry_t entry)
 	unlock_cluster(ci);
 	return 0;
 }
+
+int split_swap_cluster(swp_entry_t entry, bool force)
+{
+	struct swap_info_struct *si;
+	struct swap_cluster_info *ci;
+	unsigned long offset = swp_offset(entry);
+	int ret = 0;
+
+	si = get_swap_device(entry);
+	if (!si)
+		return -EINVAL;
+	ci = lock_cluster(si, offset);
+	/* The swap cluster has been split by someone else */
+	if (!cluster_is_huge(ci))
+		goto out;
+	VM_BUG_ON(!is_cluster_offset(offset));
+	VM_BUG_ON(cluster_count(ci) < SWAPFILE_CLUSTER);
+	/* If not forced, don't split swap cluster has swap cache */
+	if (!force && si->swap_map[offset] & SWAP_HAS_CACHE) {
+		ret = -EEXIST;
+		goto out;
+	}
+	cluster_set_count(ci, SWAPFILE_CLUSTER);
+	cluster_clear_huge(ci);
+
+out:
+	unlock_cluster(ci);
+	put_swap_device(si);
+	return ret;
+}
 #endif
 
 static int __init swapfile_init(void)
-- 
2.17.0
