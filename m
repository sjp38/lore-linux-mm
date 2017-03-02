Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id A145B6B038E
	for <linux-mm@kvack.org>; Thu,  2 Mar 2017 01:39:33 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id t184so82026261pgt.1
        for <linux-mm@kvack.org>; Wed, 01 Mar 2017 22:39:33 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id r1si6625114plb.293.2017.03.01.22.39.31
        for <linux-mm@kvack.org>;
        Wed, 01 Mar 2017 22:39:32 -0800 (PST)
From: Minchan Kim <minchan@kernel.org>
Subject: [RFC 03/11] mm: remove SWAP_DIRTY in ttu
Date: Thu,  2 Mar 2017 15:39:17 +0900
Message-Id: <1488436765-32350-4-git-send-email-minchan@kernel.org>
In-Reply-To: <1488436765-32350-1-git-send-email-minchan@kernel.org>
References: <1488436765-32350-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kernel-team@lge.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.com>, Minchan Kim <minchan@kernel.org>, Shaohua Li <shli@kernel.org>

If we found lazyfree page is dirty, ttuo can just SetPageSwapBakced
in there like PG_mlocked page and just return with SWAP_FAIL which
is very natural because the page is not swappable right now so that
vmscan can activate it. There is no point to introduce new return
value SWAP_DIRTY in ttu at the moment.

Cc: Shaohua Li <shli@kernel.org>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 include/linux/rmap.h | 1 -
 mm/rmap.c            | 4 ++--
 mm/vmscan.c          | 3 ---
 3 files changed, 2 insertions(+), 6 deletions(-)

diff --git a/include/linux/rmap.h b/include/linux/rmap.h
index fee10d7..b556eef 100644
--- a/include/linux/rmap.h
+++ b/include/linux/rmap.h
@@ -298,6 +298,5 @@ static inline int page_mkclean(struct page *page)
 #define SWAP_AGAIN	1
 #define SWAP_FAIL	2
 #define SWAP_MLOCK	3
-#define SWAP_DIRTY	4
 
 #endif	/* _LINUX_RMAP_H */
diff --git a/mm/rmap.c b/mm/rmap.c
index 8076347..3a14013 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1424,7 +1424,8 @@ static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 			} else if (!PageSwapBacked(page)) {
 				/* dirty MADV_FREE page */
 				set_pte_at(mm, address, pvmw.pte, pteval);
-				ret = SWAP_DIRTY;
+				SetPageSwapBacked(page);
+				ret = SWAP_FAIL;
 				page_vma_mapped_walk_done(&pvmw);
 				break;
 			}
@@ -1494,7 +1495,6 @@ static int page_mapcount_is_zero(struct page *page)
  * SWAP_AGAIN	- we missed a mapping, try again later
  * SWAP_FAIL	- the page is unswappable
  * SWAP_MLOCK	- page is mlocked.
- * SWAP_DIRTY	- page is dirty MADV_FREE page
  */
 int try_to_unmap(struct page *page, enum ttu_flags flags)
 {
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 7aa89e3..91cef05 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1141,9 +1141,6 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		if (page_mapped(page)) {
 			switch (ret = try_to_unmap(page,
 				ttu_flags | TTU_BATCH_FLUSH)) {
-			case SWAP_DIRTY:
-				SetPageSwapBacked(page);
-				/* fall through */
 			case SWAP_FAIL:
 				nr_unmap_fail++;
 				goto activate_locked;
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
