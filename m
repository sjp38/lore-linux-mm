Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 86BB76B0390
	for <linux-mm@kvack.org>; Wed, 15 Mar 2017 01:25:00 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id x127so14818012pgb.4
        for <linux-mm@kvack.org>; Tue, 14 Mar 2017 22:25:00 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id 35si956913pgx.238.2017.03.14.22.24.59
        for <linux-mm@kvack.org>;
        Tue, 14 Mar 2017 22:24:59 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v2 06/10] mm: remove SWAP_AGAIN in ttu
Date: Wed, 15 Mar 2017 14:24:49 +0900
Message-ID: <1489555493-14659-7-git-send-email-minchan@kernel.org>
In-Reply-To: <1489555493-14659-1-git-send-email-minchan@kernel.org>
References: <1489555493-14659-1-git-send-email-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-team@lge.com, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Minchan Kim <minchan@kernel.org>

In 2002, [1] introduced SWAP_AGAIN.
At that time, try_to_unmap_one used spin_trylock(&mm->page_table_lock)
so it's really easy to contend and fail to hold a lock so SWAP_AGAIN
to keep LRU status makes sense.

However, now we changed it to mutex-based lock and be able to block
without skip pte so there is few of small window to return SWAP_AGAIN
so remove SWAP_AGAIN and just return SWAP_FAIL.

[1] c48c43e, minimal rmap
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 mm/rmap.c   | 11 +++--------
 mm/vmscan.c |  2 --
 2 files changed, 3 insertions(+), 10 deletions(-)

diff --git a/mm/rmap.c b/mm/rmap.c
index a5af1e1..612682c 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1499,13 +1499,10 @@ static int page_mapcount_is_zero(struct page *page)
  * Return values are:
  *
  * SWAP_SUCCESS	- we succeeded in removing all mappings
- * SWAP_AGAIN	- we missed a mapping, try again later
  * SWAP_FAIL	- the page is unswappable
  */
 int try_to_unmap(struct page *page, enum ttu_flags flags)
 {
-	int ret;
-
 	struct rmap_walk_control rwc = {
 		.rmap_one = try_to_unmap_one,
 		.arg = (void *)flags,
@@ -1525,13 +1522,11 @@ int try_to_unmap(struct page *page, enum ttu_flags flags)
 		rwc.invalid_vma = invalid_migration_vma;
 
 	if (flags & TTU_RMAP_LOCKED)
-		ret = rmap_walk_locked(page, &rwc);
+		rmap_walk_locked(page, &rwc);
 	else
-		ret = rmap_walk(page, &rwc);
+		rmap_walk(page, &rwc);
 
-	if (!page_mapcount(page))
-		ret = SWAP_SUCCESS;
-	return ret;
+	return !page_mapcount(page) ? SWAP_SUCCESS : SWAP_FAIL;
 }
 
 static int page_not_mapped(struct page *page)
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 2a208f0..7727fbe 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1145,8 +1145,6 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 			case SWAP_FAIL:
 				nr_unmap_fail++;
 				goto activate_locked;
-			case SWAP_AGAIN:
-				goto keep_locked;
 			case SWAP_SUCCESS:
 				; /* try to free the page below */
 			}
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
