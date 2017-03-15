Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id A79846B0388
	for <linux-mm@kvack.org>; Wed, 15 Mar 2017 01:24:59 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id 190so14859308pgg.3
        for <linux-mm@kvack.org>; Tue, 14 Mar 2017 22:24:59 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id c64si701541pfl.21.2017.03.14.22.24.58
        for <linux-mm@kvack.org>;
        Tue, 14 Mar 2017 22:24:58 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v2 02/10] mm: remove SWAP_DIRTY in ttu
Date: Wed, 15 Mar 2017 14:24:45 +0900
Message-ID: <1489555493-14659-3-git-send-email-minchan@kernel.org>
In-Reply-To: <1489555493-14659-1-git-send-email-minchan@kernel.org>
References: <1489555493-14659-1-git-send-email-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-team@lge.com, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Minchan Kim <minchan@kernel.org>, Hillf Danton <hillf.zj@alibaba-inc.com>

If we found lazyfree page is dirty, try_to_unmap_one can just
SetPageSwapBakced in there like PG_mlocked page and just return
with SWAP_FAIL which is very natural because the page is not swappable
right now so that vmscan can activate it.
There is no point to introduce new return value SWAP_DIRTY
in try_to_unmap at the moment.

Acked-by: Hillf Danton <hillf.zj@alibaba-inc.com>
Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
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
index 9dbfa6f..e692cb5 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1431,7 +1431,8 @@ static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 				 * discarded. Remap the page to page table.
 				 */
 				set_pte_at(mm, address, pvmw.pte, pteval);
-				ret = SWAP_DIRTY;
+				SetPageSwapBacked(page);
+				ret = SWAP_FAIL;
 				page_vma_mapped_walk_done(&pvmw);
 				break;
 			}
@@ -1501,7 +1502,6 @@ static int page_mapcount_is_zero(struct page *page)
  * SWAP_AGAIN	- we missed a mapping, try again later
  * SWAP_FAIL	- the page is unswappable
  * SWAP_MLOCK	- page is mlocked.
- * SWAP_DIRTY	- page is dirty MADV_FREE page
  */
 int try_to_unmap(struct page *page, enum ttu_flags flags)
 {
diff --git a/mm/vmscan.c b/mm/vmscan.c
index a3656f9..b8fd656 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1142,9 +1142,6 @@ static unsigned long shrink_page_list(struct list_head *page_list,
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
