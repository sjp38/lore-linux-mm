Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5875D6B038C
	for <linux-mm@kvack.org>; Thu,  2 Mar 2017 01:39:32 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id 65so81772463pgi.7
        for <linux-mm@kvack.org>; Wed, 01 Mar 2017 22:39:32 -0800 (PST)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id f1si6629091plb.246.2017.03.01.22.39.30
        for <linux-mm@kvack.org>;
        Wed, 01 Mar 2017 22:39:31 -0800 (PST)
From: Minchan Kim <minchan@kernel.org>
Subject: [RFC 06/11] mm: remove SWAP_MLOCK in ttu
Date: Thu,  2 Mar 2017 15:39:20 +0900
Message-Id: <1488436765-32350-7-git-send-email-minchan@kernel.org>
In-Reply-To: <1488436765-32350-1-git-send-email-minchan@kernel.org>
References: <1488436765-32350-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kernel-team@lge.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.com>, Minchan Kim <minchan@kernel.org>

ttu don't need to return SWAP_MLOCK. Instead, just return SWAP_FAIL
because it means the page is not-swappable so it should move to
another LRU list(active or unevictable). putback friends will
move it to right list depending on the page's LRU flag.

A side effect is shrink_page_list accounts unevictable list movement
by PGACTIVATE but I don't think it corrupts something severe.

Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 include/linux/rmap.h |  1 -
 mm/rmap.c            |  3 +--
 mm/vmscan.c          | 14 +++-----------
 3 files changed, 4 insertions(+), 14 deletions(-)

diff --git a/include/linux/rmap.h b/include/linux/rmap.h
index 1b0cd4c..3630d4d 100644
--- a/include/linux/rmap.h
+++ b/include/linux/rmap.h
@@ -297,6 +297,5 @@ static inline int page_mkclean(struct page *page)
 #define SWAP_SUCCESS	0
 #define SWAP_AGAIN	1
 #define SWAP_FAIL	2
-#define SWAP_MLOCK	3
 
 #endif	/* _LINUX_RMAP_H */
diff --git a/mm/rmap.c b/mm/rmap.c
index 61ae694..47898a1 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1328,7 +1328,7 @@ static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 					 */
 					mlock_vma_page(page);
 				}
-				ret = SWAP_MLOCK;
+				ret = SWAP_FAIL;
 				page_vma_mapped_walk_done(&pvmw);
 				break;
 			}
@@ -1494,7 +1494,6 @@ static int page_mapcount_is_zero(struct page *page)
  * SWAP_SUCCESS	- we succeeded in removing all mappings
  * SWAP_AGAIN	- we missed a mapping, try again later
  * SWAP_FAIL	- the page is unswappable
- * SWAP_MLOCK	- page is mlocked.
  */
 int try_to_unmap(struct page *page, enum ttu_flags flags)
 {
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 91cef05..3cdd270b 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -981,7 +981,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		sc->nr_scanned++;
 
 		if (unlikely(!page_evictable(page)))
-			goto cull_mlocked;
+			goto activate_locked;
 
 		if (!sc->may_unmap && page_mapped(page))
 			goto keep_locked;
@@ -1146,8 +1146,6 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 				goto activate_locked;
 			case SWAP_AGAIN:
 				goto keep_locked;
-			case SWAP_MLOCK:
-				goto cull_mlocked;
 			case SWAP_SUCCESS:
 				; /* try to free the page below */
 			}
@@ -1289,16 +1287,10 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		list_add(&page->lru, &free_pages);
 		continue;
 
-cull_mlocked:
-		if (PageSwapCache(page))
-			try_to_free_swap(page);
-		unlock_page(page);
-		list_add(&page->lru, &ret_pages);
-		continue;
-
 activate_locked:
 		/* Not a candidate for swapping, so reclaim swap space. */
-		if (PageSwapCache(page) && mem_cgroup_swap_full(page))
+		if (PageSwapCache(page) && (mem_cgroup_swap_full(page) ||
+						PageMlocked(page)))
 			try_to_free_swap(page);
 		VM_BUG_ON_PAGE(PageActive(page), page);
 		SetPageActive(page);
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
