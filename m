Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id A287A6B02F3
	for <linux-mm@kvack.org>; Mon, 15 May 2017 07:25:39 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id p29so109542005pgn.3
        for <linux-mm@kvack.org>; Mon, 15 May 2017 04:25:39 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id y64si10640992plh.78.2017.05.15.04.25.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 May 2017 04:25:38 -0700 (PDT)
From: "Huang, Ying" <ying.huang@intel.com>
Subject: [PATCH -mm -v11 2/5] mm, THP, swap: Unify swap slot free functions to put_swap_page
Date: Mon, 15 May 2017 19:25:19 +0800
Message-Id: <20170515112522.32457-3-ying.huang@intel.com>
In-Reply-To: <20170515112522.32457-1-ying.huang@intel.com>
References: <20170515112522.32457-1-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Minchan Kim <minchan@kernel.org>, "Huang, Ying" <ying.huang@intel.com>

From: Minchan Kim <minchan@kernel.org>

Now, get_swap_page takes struct page and allocates swap space
according to page size(ie, normal or THP) so it would be more
cleaner to introduce put_swap_page which is a counter function
of get_swap_page. Then, it calls right swap slot free function
depending on page's size.

[ying.huang@intel.com: minor cleanup and fix]
Acked-by: Johannes Weiner <hannes@cmpxchg.org>
Signed-off-by: Minchan Kim <minchan@kernel.org>
Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
---
 include/linux/swap.h | 12 ++----------
 mm/shmem.c           |  2 +-
 mm/swap_state.c      | 13 +++----------
 mm/swapfile.c        | 16 ++++++++++++++--
 mm/vmscan.c          |  2 +-
 5 files changed, 21 insertions(+), 24 deletions(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index d18876384de0..ead6fd7966b4 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -387,6 +387,7 @@ static inline long get_nr_swap_pages(void)
 
 extern void si_swapinfo(struct sysinfo *);
 extern swp_entry_t get_swap_page(struct page *page);
+extern void put_swap_page(struct page *page, swp_entry_t entry);
 extern swp_entry_t get_swap_page_of_type(int);
 extern int get_swap_pages(int n, bool cluster, swp_entry_t swp_entries[]);
 extern int add_swap_count_continuation(swp_entry_t, gfp_t);
@@ -394,7 +395,6 @@ extern void swap_shmem_alloc(swp_entry_t);
 extern int swap_duplicate(swp_entry_t);
 extern int swapcache_prepare(swp_entry_t);
 extern void swap_free(swp_entry_t);
-extern void swapcache_free(swp_entry_t);
 extern void swapcache_free_entries(swp_entry_t *entries, int n);
 extern int free_swap_and_cache(swp_entry_t);
 extern int swap_type_of(dev_t, sector_t, struct block_device **);
@@ -453,7 +453,7 @@ static inline void swap_free(swp_entry_t swp)
 {
 }
 
-static inline void swapcache_free(swp_entry_t swp)
+static inline void put_swap_page(struct page *page, swp_entry_t swp)
 {
 }
 
@@ -578,13 +578,5 @@ static inline bool mem_cgroup_swap_full(struct page *page)
 }
 #endif
 
-#ifdef CONFIG_THP_SWAP
-extern void swapcache_free_cluster(swp_entry_t entry);
-#else
-static inline void swapcache_free_cluster(swp_entry_t entry)
-{
-}
-#endif
-
 #endif /* __KERNEL__*/
 #endif /* _LINUX_SWAP_H */
diff --git a/mm/shmem.c b/mm/shmem.c
index 29948d7da172..82158edaefdb 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -1326,7 +1326,7 @@ static int shmem_writepage(struct page *page, struct writeback_control *wbc)
 
 	mutex_unlock(&shmem_swaplist_mutex);
 free_swap:
-	swapcache_free(swap);
+	put_swap_page(page, swap);
 redirty:
 	set_page_dirty(page);
 	if (wbc->for_reclaim)
diff --git a/mm/swap_state.c b/mm/swap_state.c
index 16ff89d058f4..0ad214d7a7ad 100644
--- a/mm/swap_state.c
+++ b/mm/swap_state.c
@@ -231,10 +231,7 @@ int add_to_swap(struct page *page, struct list_head *list)
 	return 1;
 
 fail_free:
-	if (PageTransHuge(page))
-		swapcache_free_cluster(entry);
-	else
-		swapcache_free(entry);
+	put_swap_page(page, entry);
 fail:
 	if (PageTransHuge(page) && !split_huge_page_to_list(page, list))
 		goto retry;
@@ -259,11 +256,7 @@ void delete_from_swap_cache(struct page *page)
 	__delete_from_swap_cache(page);
 	spin_unlock_irq(&address_space->tree_lock);
 
-	if (PageTransHuge(page))
-		swapcache_free_cluster(entry);
-	else
-		swapcache_free(entry);
-
+	put_swap_page(page, entry);
 	page_ref_sub(page, hpage_nr_pages(page));
 }
 
@@ -415,7 +408,7 @@ struct page *__read_swap_cache_async(swp_entry_t entry, gfp_t gfp_mask,
 		 * add_to_swap_cache() doesn't return -EEXIST, so we can safely
 		 * clear SWAP_HAS_CACHE flag.
 		 */
-		swapcache_free(entry);
+		put_swap_page(new_page, entry);
 	} while (err != -ENOMEM);
 
 	if (new_page)
diff --git a/mm/swapfile.c b/mm/swapfile.c
index f4c0f2a92bf0..90b91f48d401 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -1148,7 +1148,7 @@ void swap_free(swp_entry_t entry)
 /*
  * Called after dropping swapcache to decrease refcnt to swap entries.
  */
-void swapcache_free(swp_entry_t entry)
+static void swapcache_free(swp_entry_t entry)
 {
 	struct swap_info_struct *p;
 
@@ -1160,7 +1160,7 @@ void swapcache_free(swp_entry_t entry)
 }
 
 #ifdef CONFIG_THP_SWAP
-void swapcache_free_cluster(swp_entry_t entry)
+static void swapcache_free_cluster(swp_entry_t entry)
 {
 	unsigned long offset = swp_offset(entry);
 	unsigned long idx = offset / SWAPFILE_CLUSTER;
@@ -1184,8 +1184,20 @@ void swapcache_free_cluster(swp_entry_t entry)
 	swap_free_cluster(si, idx);
 	spin_unlock(&si->lock);
 }
+#else
+static inline void swapcache_free_cluster(swp_entry_t entry)
+{
+}
 #endif /* CONFIG_THP_SWAP */
 
+void put_swap_page(struct page *page, swp_entry_t entry)
+{
+	if (!PageTransHuge(page))
+		swapcache_free(entry);
+	else
+		swapcache_free_cluster(entry);
+}
+
 void swapcache_free_entries(swp_entry_t *entries, int n)
 {
 	struct swap_info_struct *p, *prev;
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 9f6c7ae5857f..b39ccabbe2dc 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -708,7 +708,7 @@ static int __remove_mapping(struct address_space *mapping, struct page *page,
 		mem_cgroup_swapout(page, swap);
 		__delete_from_swap_cache(page);
 		spin_unlock_irqrestore(&mapping->tree_lock, flags);
-		swapcache_free(swap);
+		put_swap_page(page, swap);
 	} else {
 		void (*freepage)(struct page *);
 		void *shadow = NULL;
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
