Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id 977A36B0073
	for <linux-mm@kvack.org>; Wed,  2 Jan 2013 23:28:13 -0500 (EST)
From: Minchan Kim <minchan@kernel.org>
Subject: [RFC 4/8] add page_locked parameter in free_swap_and_cache
Date: Thu,  3 Jan 2013 13:28:02 +0900
Message-Id: <1357187286-18759-5-git-send-email-minchan@kernel.org>
In-Reply-To: <1357187286-18759-1-git-send-email-minchan@kernel.org>
References: <1357187286-18759-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Minchan Kim <minchan@kernel.org>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>

Add page_locked parameter for avoiding trylock_page.
Next patch will use it.

Cc: Hugh Dickins <hughd@google.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Rik van Riel <riel@redhat.com>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 include/linux/swap.h |    6 +++---
 mm/fremap.c          |    2 +-
 mm/memory.c          |    2 +-
 mm/shmem.c           |    2 +-
 mm/swapfile.c        |    7 ++++---
 5 files changed, 10 insertions(+), 9 deletions(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index 68df9c1..5cf2191 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -357,7 +357,7 @@ extern int swap_duplicate(swp_entry_t);
 extern int swapcache_prepare(swp_entry_t);
 extern void swap_free(swp_entry_t);
 extern void swapcache_free(swp_entry_t, struct page *page);
-extern int free_swap_and_cache(swp_entry_t);
+extern int free_swap_and_cache(swp_entry_t, bool);
 extern int swap_type_of(dev_t, sector_t, struct block_device **);
 extern unsigned int count_swap_pages(int, int);
 extern sector_t map_swap_page(struct page *, struct block_device **);
@@ -397,8 +397,8 @@ static inline void show_swap_cache_info(void)
 {
 }
 
-#define free_swap_and_cache(swp)	is_migration_entry(swp)
-#define swapcache_prepare(swp)		is_migration_entry(swp)
+#define free_swap_and_cache(swp, page_locked)	is_migration_entry(swp)
+#define swapcache_prepare(swp)			is_migration_entry(swp)
 
 static inline int add_swap_count_continuation(swp_entry_t swp, gfp_t gfp_mask)
 {
diff --git a/mm/fremap.c b/mm/fremap.c
index a0aaf0e..a300508 100644
--- a/mm/fremap.c
+++ b/mm/fremap.c
@@ -44,7 +44,7 @@ static void zap_pte(struct mm_struct *mm, struct vm_area_struct *vma,
 		}
 	} else {
 		if (!pte_file(pte))
-			free_swap_and_cache(pte_to_swp_entry(pte));
+			free_swap_and_cache(pte_to_swp_entry(pte), false);
 		pte_clear_not_present_full(mm, addr, ptep, 0);
 	}
 }
diff --git a/mm/memory.c b/mm/memory.c
index 221fc9f..c475cc1 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1198,7 +1198,7 @@ again:
 				else
 					rss[MM_FILEPAGES]--;
 			}
-			if (unlikely(!free_swap_and_cache(entry)))
+			if (unlikely(!free_swap_and_cache(entry, false)))
 				print_bad_pte(vma, addr, ptent, NULL);
 		}
 		pte_clear_not_present_full(mm, addr, pte, tlb->fullmm);
diff --git a/mm/shmem.c b/mm/shmem.c
index 50c5b8f..33ec719 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -391,7 +391,7 @@ static int shmem_free_swap(struct address_space *mapping,
 	error = shmem_radix_tree_replace(mapping, index, radswap, NULL);
 	spin_unlock_irq(&mapping->tree_lock);
 	if (!error)
-		free_swap_and_cache(radix_to_swp_entry(radswap));
+		free_swap_and_cache(radix_to_swp_entry(radswap), false);
 	return error;
 }
 
diff --git a/mm/swapfile.c b/mm/swapfile.c
index f91a255..43437ff 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -688,7 +688,7 @@ int try_to_free_swap(struct page *page)
  * Free the swap entry like above, but also try to
  * free the page cache entry if it is the last user.
  */
-int free_swap_and_cache(swp_entry_t entry)
+int free_swap_and_cache(swp_entry_t entry, bool page_locked)
 {
 	struct swap_info_struct *p;
 	struct page *page = NULL;
@@ -700,7 +700,7 @@ int free_swap_and_cache(swp_entry_t entry)
 	if (p) {
 		if (swap_entry_free(p, entry, 1) == SWAP_HAS_CACHE) {
 			page = find_get_page(&swapper_space, entry.val);
-			if (page && !trylock_page(page)) {
+			if (page && !page_locked && !trylock_page(page)) {
 				page_cache_release(page);
 				page = NULL;
 			}
@@ -717,7 +717,8 @@ int free_swap_and_cache(swp_entry_t entry)
 			delete_from_swap_cache(page);
 			SetPageDirty(page);
 		}
-		unlock_page(page);
+		if (!page_locked)
+			unlock_page(page);
 		page_cache_release(page);
 	}
 	return p != NULL;
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
