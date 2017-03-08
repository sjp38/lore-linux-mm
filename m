Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 169476B03AC
	for <linux-mm@kvack.org>; Wed,  8 Mar 2017 02:26:46 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id v190so44145215pfb.5
        for <linux-mm@kvack.org>; Tue, 07 Mar 2017 23:26:46 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id y70si2425223plh.168.2017.03.07.23.26.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Mar 2017 23:26:45 -0800 (PST)
From: "Huang, Ying" <ying.huang@intel.com>
Subject: [PATCH -mm -v6 4/9] mm, THP, swap: Add get_huge_swap_page()
Date: Wed,  8 Mar 2017 15:26:08 +0800
Message-Id: <20170308072613.17634-5-ying.huang@intel.com>
In-Reply-To: <20170308072613.17634-1-ying.huang@intel.com>
References: <20170308072613.17634-1-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Ying <ying.huang@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>

From: Huang Ying <ying.huang@intel.com>

A variation of get_swap_page(), get_huge_swap_page(), is added to
allocate a swap cluster (HPAGE_PMD_NR swap slots) based on the swap
cluster allocation function.  A fair simple algorithm is used, that is,
only the first swap device in priority list will be tried to allocate
the swap cluster.  The function will fail if the trying is not
successful, and the caller will fallback to allocate a single swap slot
instead.  This works good enough for normal cases.

This will be used for the THP (Transparent Huge Page) swap support.
Where get_huge_swap_page() will be used to allocate one swap cluster for
each THP swapped out.

Because of the algorithm adopted, if the difference of the number of the
free swap clusters among multiple swap devices is significant, it is
possible that some THPs are split earlier than necessary.  For example,
this could be caused by big size difference among multiple swap devices.

Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Hugh Dickins <hughd@google.com>
Cc: Shaohua Li <shli@kernel.org>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Rik van Riel <riel@redhat.com>
Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
---
 include/linux/swap.h | 19 ++++++++++++++++++-
 mm/swap_slots.c      |  5 +++--
 mm/swapfile.c        | 16 ++++++++++++----
 3 files changed, 33 insertions(+), 7 deletions(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index 278e1349a424..e3a7609a8989 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -388,7 +388,7 @@ static inline long get_nr_swap_pages(void)
 extern void si_swapinfo(struct sysinfo *);
 extern swp_entry_t get_swap_page(void);
 extern swp_entry_t get_swap_page_of_type(int);
-extern int get_swap_pages(int n, swp_entry_t swp_entries[]);
+extern int get_swap_pages(int n, swp_entry_t swp_entries[], bool huge);
 extern int add_swap_count_continuation(swp_entry_t, gfp_t);
 extern void swap_shmem_alloc(swp_entry_t);
 extern int swap_duplicate(swp_entry_t);
@@ -527,6 +527,23 @@ static inline swp_entry_t get_swap_page(void)
 
 #endif /* CONFIG_SWAP */
 
+#ifdef CONFIG_THP_SWAP_CLUSTER
+static inline swp_entry_t get_huge_swap_page(void)
+{
+	swp_entry_t entry;
+
+	if (get_swap_pages(1, &entry, true))
+		return entry;
+	else
+		return (swp_entry_t) {0};
+}
+#else
+static inline swp_entry_t get_huge_swap_page(void)
+{
+	return (swp_entry_t) {0};
+}
+#endif
+
 #ifdef CONFIG_MEMCG
 static inline int mem_cgroup_swappiness(struct mem_cgroup *memcg)
 {
diff --git a/mm/swap_slots.c b/mm/swap_slots.c
index 9b5bc86f96ad..075bb39e03c5 100644
--- a/mm/swap_slots.c
+++ b/mm/swap_slots.c
@@ -258,7 +258,8 @@ static int refill_swap_slots_cache(struct swap_slots_cache *cache)
 
 	cache->cur = 0;
 	if (swap_slot_cache_active)
-		cache->nr = get_swap_pages(SWAP_SLOTS_CACHE_SIZE, cache->slots);
+		cache->nr = get_swap_pages(SWAP_SLOTS_CACHE_SIZE, cache->slots,
+					   false);
 
 	return cache->nr;
 }
@@ -334,7 +335,7 @@ swp_entry_t get_swap_page(void)
 			return entry;
 	}
 
-	get_swap_pages(1, &entry);
+	get_swap_pages(1, &entry, false);
 
 	return entry;
 }
diff --git a/mm/swapfile.c b/mm/swapfile.c
index 91876c33114b..7241c937e52b 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -904,11 +904,12 @@ static unsigned long scan_swap_map(struct swap_info_struct *si,
 
 }
 
-int get_swap_pages(int n_goal, swp_entry_t swp_entries[])
+int get_swap_pages(int n_goal, swp_entry_t swp_entries[], bool huge)
 {
 	struct swap_info_struct *si, *next;
 	long avail_pgs;
 	int n_ret = 0;
+	int nr_pages = huge_cluster_nr_entries(huge);
 
 	avail_pgs = atomic_long_read(&nr_swap_pages);
 	if (avail_pgs <= 0)
@@ -920,6 +921,10 @@ int get_swap_pages(int n_goal, swp_entry_t swp_entries[])
 	if (n_goal > avail_pgs)
 		n_goal = avail_pgs;
 
+	n_goal *= nr_pages;
+	if (avail_pgs < n_goal)
+		goto noswap;
+
 	atomic_long_sub(n_goal, &nr_swap_pages);
 
 	spin_lock(&swap_avail_lock);
@@ -946,10 +951,13 @@ int get_swap_pages(int n_goal, swp_entry_t swp_entries[])
 			spin_unlock(&si->lock);
 			goto nextsi;
 		}
-		n_ret = scan_swap_map_slots(si, SWAP_HAS_CACHE,
-					    n_goal, swp_entries);
+		if (likely(nr_pages == 1))
+			n_ret = scan_swap_map_slots(si, SWAP_HAS_CACHE,
+						    n_goal, swp_entries);
+		else
+			n_ret = swap_alloc_huge_cluster(si, swp_entries);
 		spin_unlock(&si->lock);
-		if (n_ret)
+		if (n_ret || unlikely(nr_pages != 1))
 			goto check_out;
 		pr_debug("scan_swap_map of si %d failed to find offset\n",
 			si->type);
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
