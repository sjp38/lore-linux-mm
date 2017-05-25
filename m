Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 37B416B0314
	for <linux-mm@kvack.org>; Thu, 25 May 2017 02:47:08 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id e7so211189436pfk.9
        for <linux-mm@kvack.org>; Wed, 24 May 2017 23:47:08 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id u69si26530689pgb.168.2017.05.24.23.47.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 May 2017 23:47:07 -0700 (PDT)
From: "Huang, Ying" <ying.huang@intel.com>
Subject: [PATCH -mm 08/13] mm, THP, swap: Support to split THP for THP swapped out
Date: Thu, 25 May 2017 14:46:30 +0800
Message-Id: <20170525064635.2832-9-ying.huang@intel.com>
In-Reply-To: <20170525064635.2832-1-ying.huang@intel.com>
References: <20170525064635.2832-1-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Ying <ying.huang@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>

From: Huang Ying <ying.huang@intel.com>

After adding swapping out support for THP (Transparent Huge Page), it
is possible that a THP in swap cache (partly swapped out) need to be
split.  To split such a THP, the swap cluster backing the THP need to
be split too, that is, the CLUSTER_FLAG_HUGE flag need to be cleared
for the swap cluster.  The patch implemented this.

And because the THP swap writing needs the THP keeps as huge page
during writing.  The PageWriteback flag is checked before splitting.

Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Hugh Dickins <hughd@google.com>
Cc: Shaohua Li <shli@kernel.org>
Cc: Rik van Riel <riel@redhat.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>
---
 include/linux/swap.h |  9 +++++++++
 mm/huge_memory.c     | 10 +++++++++-
 mm/swapfile.c        | 15 +++++++++++++++
 3 files changed, 33 insertions(+), 1 deletion(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index ed51d5e699e0..fbe75245971e 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -525,6 +525,15 @@ static inline swp_entry_t get_swap_page(struct page *page)
 
 #endif /* CONFIG_SWAP */
 
+#ifdef CONFIG_THP_SWAP
+extern int split_swap_cluster(swp_entry_t entry);
+#else
+static inline int split_swap_cluster(swp_entry_t entry)
+{
+	return 0;
+}
+#endif
+
 #ifdef CONFIG_MEMCG
 static inline int mem_cgroup_swappiness(struct mem_cgroup *memcg)
 {
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 0eb1251f924a..0aefc90c6573 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -2446,6 +2446,9 @@ int split_huge_page_to_list(struct page *page, struct list_head *list)
 	VM_BUG_ON_PAGE(!PageLocked(page), page);
 	VM_BUG_ON_PAGE(!PageCompound(page), page);
 
+	if (PageWriteback(page))
+		return -EBUSY;
+
 	if (PageAnon(head)) {
 		/*
 		 * The caller does not necessarily hold an mmap_sem that would
@@ -2523,7 +2526,12 @@ int split_huge_page_to_list(struct page *page, struct list_head *list)
 			__dec_node_page_state(page, NR_SHMEM_THPS);
 		spin_unlock(&pgdata->split_queue_lock);
 		__split_huge_page(page, list, flags);
-		ret = 0;
+		if (PageSwapCache(head)) {
+			swp_entry_t entry = { .val = page_private(head) };
+
+			ret = split_swap_cluster(entry);
+		} else
+			ret = 0;
 	} else {
 		if (IS_ENABLED(CONFIG_DEBUG_VM) && mapcount) {
 			pr_alert("total_mapcount: %u, page_count(): %u\n",
diff --git a/mm/swapfile.c b/mm/swapfile.c
index 2a2f5d08f0a9..d4fd80be2e2d 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -1215,6 +1215,21 @@ static void swapcache_free_cluster(swp_entry_t entry)
 		}
 	}
 }
+
+int split_swap_cluster(swp_entry_t entry)
+{
+	struct swap_info_struct *si;
+	struct swap_cluster_info *ci;
+	unsigned long offset = swp_offset(entry);
+
+	si = _swap_info_get(entry);
+	if (!si)
+		return -EBUSY;
+	ci = lock_cluster(si, offset);
+	cluster_clear_huge(ci);
+	unlock_cluster(ci);
+	return 0;
+}
 #else
 static inline void swapcache_free_cluster(swp_entry_t entry)
 {
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
