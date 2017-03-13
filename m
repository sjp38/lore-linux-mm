Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 725C1280957
	for <linux-mm@kvack.org>; Sun, 12 Mar 2017 20:36:01 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id e129so272401505pfh.1
        for <linux-mm@kvack.org>; Sun, 12 Mar 2017 17:36:01 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id j9si9853712pgc.104.2017.03.12.17.35.59
        for <linux-mm@kvack.org>;
        Sun, 12 Mar 2017 17:36:00 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v1 05/10] mm: remove SWAP_MLOCK in ttu
Date: Mon, 13 Mar 2017 09:35:48 +0900
Message-ID: <1489365353-28205-6-git-send-email-minchan@kernel.org>
In-Reply-To: <1489365353-28205-1-git-send-email-minchan@kernel.org>
References: <1489365353-28205-1-git-send-email-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-team@lge.com, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Minchan Kim <minchan@kernel.org>

ttu don't need to return SWAP_MLOCK. Instead, just return SWAP_FAIL
because it means the page is not-swappable so it should move to
another LRU list(active or unevictable). putback friends will
move it to right list depending on the page's LRU flag.

Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 include/linux/rmap.h |  1 -
 mm/rmap.c            |  3 +--
 mm/vmscan.c          | 20 +++++++-------------
 3 files changed, 8 insertions(+), 16 deletions(-)

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
index 9c51065..38e8ab1 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1324,7 +1324,7 @@ static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 					 */
 					mlock_vma_page(page);
 				}
-				ret = SWAP_MLOCK;
+				ret = SWAP_FAIL;
 				page_vma_mapped_walk_done(&pvmw);
 				break;
 			}
@@ -1501,7 +1501,6 @@ static int page_mapcount_is_zero(struct page *page)
  * SWAP_SUCCESS	- we succeeded in removing all mappings
  * SWAP_AGAIN	- we missed a mapping, try again later
  * SWAP_FAIL	- the page is unswappable
- * SWAP_MLOCK	- page is mlocked.
  */
 int try_to_unmap(struct page *page, enum ttu_flags flags)
 {
diff --git a/mm/vmscan.c b/mm/vmscan.c
index b8fd656..2a208f0 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -982,7 +982,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		sc->nr_scanned++;
 
 		if (unlikely(!page_evictable(page)))
-			goto cull_mlocked;
+			goto activate_locked;
 
 		if (!sc->may_unmap && page_mapped(page))
 			goto keep_locked;
@@ -1147,8 +1147,6 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 				goto activate_locked;
 			case SWAP_AGAIN:
 				goto keep_locked;
-			case SWAP_MLOCK:
-				goto cull_mlocked;
 			case SWAP_SUCCESS:
 				; /* try to free the page below */
 			}
@@ -1290,20 +1288,16 @@ static unsigned long shrink_page_list(struct list_head *page_list,
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
-		SetPageActive(page);
-		pgactivate++;
+		if (!PageMlocked(page)) {
+			SetPageActive(page);
+			pgactivate++;
+		}
 keep_locked:
 		unlock_page(page);
 keep:
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
