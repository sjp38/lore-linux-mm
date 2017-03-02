Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 942716B038E
	for <linux-mm@kvack.org>; Thu,  2 Mar 2017 01:39:32 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id t184so82025903pgt.1
        for <linux-mm@kvack.org>; Wed, 01 Mar 2017 22:39:32 -0800 (PST)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id p24si6624202pli.285.2017.03.01.22.39.31
        for <linux-mm@kvack.org>;
        Wed, 01 Mar 2017 22:39:31 -0800 (PST)
From: Minchan Kim <minchan@kernel.org>
Subject: [RFC 07/11] mm: remove SWAP_AGAIN in ttu
Date: Thu,  2 Mar 2017 15:39:21 +0900
Message-Id: <1488436765-32350-8-git-send-email-minchan@kernel.org>
In-Reply-To: <1488436765-32350-1-git-send-email-minchan@kernel.org>
References: <1488436765-32350-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kernel-team@lge.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.com>, Minchan Kim <minchan@kernel.org>

In 2002, [1] introduced SWAP_AGAIN.
At that time, ttuo used spin_trylock(&mm->page_table_lock) so it's
really easy to contend and fail to hold a lock so SWAP_AGAIN to keep
LRU status makes sense.

However, now we changed it to mutex-based lock and be able to block
without skip pte so there is a few of small window to return
SWAP_AGAIN so remove SWAP_AGAIN and just return SWAP_FAIL.

[1] c48c43e, minimal rmap
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 mm/rmap.c   | 11 +++--------
 mm/vmscan.c |  2 --
 2 files changed, 3 insertions(+), 10 deletions(-)

diff --git a/mm/rmap.c b/mm/rmap.c
index 47898a1..da18f21 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1492,13 +1492,10 @@ static int page_mapcount_is_zero(struct page *page)
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
@@ -1518,13 +1515,11 @@ int try_to_unmap(struct page *page, enum ttu_flags flags)
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
+	return !page_mapcount(page) ? SWAP_SUCCESS: SWAP_FAIL;
 }
 
 static int page_not_mapped(struct page *page)
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 3cdd270b..170c61f 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1144,8 +1144,6 @@ static unsigned long shrink_page_list(struct list_head *page_list,
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
