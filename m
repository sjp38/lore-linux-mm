Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 281C86B0038
	for <linux-mm@kvack.org>; Thu, 11 May 2017 22:21:28 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id d11so36701918pgn.9
        for <linux-mm@kvack.org>; Thu, 11 May 2017 19:21:28 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id x76si1886796pfj.11.2017.05.11.19.21.26
        for <linux-mm@kvack.org>;
        Thu, 11 May 2017 19:21:27 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH 1/2] mm: swap: unify swap slot free functions to put_swap_page
Date: Fri, 12 May 2017 11:21:23 +0900
Message-ID: <1494555684-11982-1-git-send-email-minchan@kernel.org>
In-Reply-To: <87h90sb4jq.fsf@yhuang-dev.intel.com>
References: <87h90sb4jq.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Huang Ying <ying.huang@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Minchan Kim <minchan@kernel.org>

Now, get_swap_page takes struct page and allocates swap space
according to page size(ie, normal or THP) so it would be more
cleaner to introduce put_swap_page which is a counter function
of get_swap_page. Then, it calls right swap slot free function
depending on page's size.

Cc: Johannes Weiner <hannes@cmpxchg.org>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 include/linux/swap.h |  4 ++--
 mm/shmem.c           |  2 +-
 mm/swap_state.c      | 13 +++----------
 mm/swapfile.c        |  8 ++++++++
 mm/vmscan.c          |  2 +-
 5 files changed, 15 insertions(+), 14 deletions(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index b60fea3748f8..8f12f67e869f 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -393,6 +393,7 @@ static inline long get_nr_swap_pages(void)
 
 extern void si_swapinfo(struct sysinfo *);
 extern swp_entry_t get_swap_page(struct page *page);
+extern void put_swap_page(struct page *page, swp_entry_t entry);
 extern swp_entry_t get_swap_page_of_type(int);
 extern int get_swap_pages(int n, bool cluster, swp_entry_t swp_entries[]);
 extern int add_swap_count_continuation(swp_entry_t, gfp_t);
@@ -400,7 +401,6 @@ extern void swap_shmem_alloc(swp_entry_t);
 extern int swap_duplicate(swp_entry_t);
 extern int swapcache_prepare(swp_entry_t);
 extern void swap_free(swp_entry_t);
-extern void swapcache_free(swp_entry_t);
 extern void swapcache_free_entries(swp_entry_t *entries, int n);
 extern int free_swap_and_cache(swp_entry_t);
 extern int swap_type_of(dev_t, sector_t, struct block_device **);
@@ -459,7 +459,7 @@ static inline void swap_free(swp_entry_t swp)
 {
 }
 
-static inline void swapcache_free(swp_entry_t swp)
+static inline void put_swap_page(struct page *page, swp_entry_t swp)
 {
 }
 
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
index 596306272059..b65e49428090 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -1182,6 +1182,14 @@ void swapcache_free_cluster(swp_entry_t entry)
 }
 #endif /* CONFIG_THP_SWAP */
 
+void put_swap_page(struct page *page, swp_entry_t entry)
+{
+	if (!PageTransHuge(page))
+		swapcache_free(entry);
+	else
+		swapcache_free_cluster(entry);
+}
+
 static int swp_entry_cmp(const void *ent1, const void *ent2)
 {
 	const swp_entry_t *e1 = ent1, *e2 = ent2;
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 5ebf468c5429..57268c0c8fcf 100644
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
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
