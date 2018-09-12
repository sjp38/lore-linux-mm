Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 281DB8E0001
	for <linux-mm@kvack.org>; Tue, 11 Sep 2018 20:44:36 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id 90-v6so101879pla.18
        for <linux-mm@kvack.org>; Tue, 11 Sep 2018 17:44:36 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id p21-v6si20648717plq.338.2018.09.11.17.44.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Sep 2018 17:44:34 -0700 (PDT)
From: Huang Ying <ying.huang@intel.com>
Subject: [PATCH -V5 RESEND 07/21] swap: Support PMD swap mapping in split_swap_cluster()
Date: Wed, 12 Sep 2018 08:44:00 +0800
Message-Id: <20180912004414.22583-8-ying.huang@intel.com>
In-Reply-To: <20180912004414.22583-1-ying.huang@intel.com>
References: <20180912004414.22583-1-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Ying <ying.huang@intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Zi Yan <zi.yan@cs.rutgers.edu>, Daniel Jordan <daniel.m.jordan@oracle.com>

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
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Shaohua Li <shli@kernel.org>
Cc: Hugh Dickins <hughd@google.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Rik van Riel <riel@redhat.com>
Cc: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Zi Yan <zi.yan@cs.rutgers.edu>
Cc: Daniel Jordan <daniel.m.jordan@oracle.com>
---
 include/linux/swap.h |  6 ++++--
 mm/huge_memory.c     | 18 ++++++++++------
 mm/swapfile.c        | 58 +++++++++++++++++++++++++++++++++++++---------------
 3 files changed, 57 insertions(+), 25 deletions(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index a2a3d85decd9..c0c3b3c077d7 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -616,11 +616,13 @@ static inline swp_entry_t get_swap_page(struct page *page)
 
 #endif /* CONFIG_SWAP */
 
+#define SSC_SPLIT_CACHED	0x1
+
 #ifdef CONFIG_THP_SWAP
-extern int split_swap_cluster(swp_entry_t entry);
+extern int split_swap_cluster(swp_entry_t entry, unsigned long flags);
 extern int split_swap_cluster_map(swp_entry_t entry);
 #else
-static inline int split_swap_cluster(swp_entry_t entry)
+static inline int split_swap_cluster(swp_entry_t entry, unsigned long flags)
 {
 	return 0;
 }
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index b8b61a0879f6..64123cefa978 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -2502,6 +2502,17 @@ static void __split_huge_page(struct page *page, struct list_head *list,
 
 	unfreeze_page(head);
 
+	/*
+	 * Split swap cluster before unlocking sub-pages.  So all
+	 * sub-pages will be kept locked from THP has been split to
+	 * swap cluster is split.
+	 */
+	if (PageSwapCache(head)) {
+		swp_entry_t entry = { .val = page_private(head) };
+
+		split_swap_cluster(entry, SSC_SPLIT_CACHED);
+	}
+
 	for (i = 0; i < HPAGE_PMD_NR; i++) {
 		struct page *subpage = head + i;
 		if (subpage == page)
@@ -2728,12 +2739,7 @@ int split_huge_page_to_list(struct page *page, struct list_head *list)
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
index 16723b9d971a..ef2b42c199c0 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -1469,23 +1469,6 @@ void put_swap_page(struct page *page, swp_entry_t entry)
 	unlock_cluster_or_swap_info(si, ci);
 }
 
-#ifdef CONFIG_THP_SWAP
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
-#endif
-
 static int swp_entry_cmp(const void *ent1, const void *ent2)
 {
 	const swp_entry_t *e1 = ent1, *e2 = ent2;
@@ -4064,6 +4047,47 @@ int split_swap_cluster_map(swp_entry_t entry)
 	unlock_cluster(ci);
 	return 0;
 }
+
+/*
+ * We will not try to split all PMD swap mappings to the swap cluster,
+ * because we haven't enough information available for that.  Later,
+ * when the PMD swap mapping is duplicated or swapin, etc, the PMD
+ * swap mapping will be split and fallback to the PTE operations.
+ */
+int split_swap_cluster(swp_entry_t entry, unsigned long flags)
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
+	/* The swap cluster has been split by someone else, we are done */
+	if (!cluster_is_huge(ci))
+		goto out;
+	VM_BUG_ON(!IS_ALIGNED(offset, SWAPFILE_CLUSTER));
+	VM_BUG_ON(cluster_count(ci) < SWAPFILE_CLUSTER);
+	/*
+	 * If not requested, don't split swap cluster that has SWAP_HAS_CACHE
+	 * flag.  When the flag is cleared later, the huge swap cluster will
+	 * be split if there is no PMD swap mapping.
+	 */
+	if (!(flags & SSC_SPLIT_CACHED) &&
+	    si->swap_map[offset] & SWAP_HAS_CACHE) {
+		ret = -EEXIST;
+		goto out;
+	}
+	cluster_set_swapcount(ci, 0);
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
2.16.4
