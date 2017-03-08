Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5B6576B03AD
	for <linux-mm@kvack.org>; Wed,  8 Mar 2017 02:26:48 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id 77so42590006pgc.5
        for <linux-mm@kvack.org>; Tue, 07 Mar 2017 23:26:48 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id y70si2425223plh.168.2017.03.07.23.26.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Mar 2017 23:26:47 -0800 (PST)
From: "Huang, Ying" <ying.huang@intel.com>
Subject: [PATCH -mm -v6 5/9] mm, THP, swap: Support to clear SWAP_HAS_CACHE for huge page
Date: Wed,  8 Mar 2017 15:26:09 +0800
Message-Id: <20170308072613.17634-6-ying.huang@intel.com>
In-Reply-To: <20170308072613.17634-1-ying.huang@intel.com>
References: <20170308072613.17634-1-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Ying <ying.huang@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>

From: Huang Ying <ying.huang@intel.com>

__swapcache_free() is added to support to clear the SWAP_HAS_CACHE flag
for the huge page.  This will free the specified swap cluster now.
Because now this function will be called only in the error path to free
the swap cluster just allocated.  So the corresponding swap_map[i] ==
SWAP_HAS_CACHE, that is, the swap count is 0.  This makes the
implementation simpler than that of the ordinary swap entry.

This will be used for delaying splitting THP (Transparent Huge Page)
during swapping out.  Where for one THP to swap out, we will allocate a
swap cluster, add the THP into the swap cache, then split the THP.  If
anything fails after allocating the swap cluster and before splitting
the THP successfully, the swapcache_free_trans_huge() will be used to
free the swap space allocated.

Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Hugh Dickins <hughd@google.com>
Cc: Shaohua Li <shli@kernel.org>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Rik van Riel <riel@redhat.com>
Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
---
 include/linux/swap.h |  9 +++++++--
 mm/swapfile.c        | 34 ++++++++++++++++++++++++++++++++--
 2 files changed, 39 insertions(+), 4 deletions(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index e3a7609a8989..2f2a6c0363aa 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -394,7 +394,7 @@ extern void swap_shmem_alloc(swp_entry_t);
 extern int swap_duplicate(swp_entry_t);
 extern int swapcache_prepare(swp_entry_t);
 extern void swap_free(swp_entry_t);
-extern void swapcache_free(swp_entry_t);
+extern void __swapcache_free(swp_entry_t entry, bool huge);
 extern void swapcache_free_entries(swp_entry_t *entries, int n);
 extern int free_swap_and_cache(swp_entry_t);
 extern int swap_type_of(dev_t, sector_t, struct block_device **);
@@ -456,7 +456,7 @@ static inline void swap_free(swp_entry_t swp)
 {
 }
 
-static inline void swapcache_free(swp_entry_t swp)
+static inline void __swapcache_free(swp_entry_t swp, bool huge)
 {
 }
 
@@ -544,6 +544,11 @@ static inline swp_entry_t get_huge_swap_page(void)
 }
 #endif
 
+static inline void swapcache_free(swp_entry_t entry)
+{
+	__swapcache_free(entry, false);
+}
+
 #ifdef CONFIG_MEMCG
 static inline int mem_cgroup_swappiness(struct mem_cgroup *memcg)
 {
diff --git a/mm/swapfile.c b/mm/swapfile.c
index 7241c937e52b..6019f94afbaf 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -855,6 +855,29 @@ static void swap_free_huge_cluster(struct swap_info_struct *si,
 	_swap_entry_free(si, offset, true);
 }
 
+static void swapcache_free_trans_huge(struct swap_info_struct *si,
+				      swp_entry_t entry)
+{
+	unsigned long offset = swp_offset(entry);
+	unsigned long idx = offset / SWAPFILE_CLUSTER;
+	struct swap_cluster_info *ci;
+	unsigned char *map;
+	unsigned int i;
+
+	spin_lock(&si->lock);
+	ci = lock_cluster(si, offset);
+	map = si->swap_map + offset;
+	for (i = 0; i < SWAPFILE_CLUSTER; i++) {
+		VM_BUG_ON(map[i] != SWAP_HAS_CACHE);
+		map[i] &= ~SWAP_HAS_CACHE;
+	}
+	unlock_cluster(ci);
+	/* Cluster size is same as huge pmd size */
+	mem_cgroup_uncharge_swap(entry, HPAGE_PMD_NR);
+	swap_free_huge_cluster(si, idx);
+	spin_unlock(&si->lock);
+}
+
 static int swap_alloc_huge_cluster(struct swap_info_struct *si,
 				   swp_entry_t *slot)
 {
@@ -887,6 +910,11 @@ static inline int swap_alloc_huge_cluster(struct swap_info_struct *si,
 {
 	return 0;
 }
+
+static inline void swapcache_free_trans_huge(struct swap_info_struct *si,
+					     swp_entry_t entry)
+{
+}
 #endif
 
 static unsigned long scan_swap_map(struct swap_info_struct *si,
@@ -1161,13 +1189,15 @@ void swap_free(swp_entry_t entry)
 /*
  * Called after dropping swapcache to decrease refcnt to swap entries.
  */
-void swapcache_free(swp_entry_t entry)
+void __swapcache_free(swp_entry_t entry, bool huge)
 {
 	struct swap_info_struct *p;
 
 	p = _swap_info_get(entry);
 	if (p) {
-		if (!__swap_entry_free(p, entry, SWAP_HAS_CACHE))
+		if (unlikely(huge))
+			swapcache_free_trans_huge(p, entry);
+		else if (!__swap_entry_free(p, entry, SWAP_HAS_CACHE))
 			free_swap_slot(entry);
 	}
 }
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
