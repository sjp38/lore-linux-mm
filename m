Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 7ACD78D0039
	for <linux-mm@kvack.org>; Sun,  6 Feb 2011 05:49:11 -0500 (EST)
Received: by mail-pw0-f41.google.com with SMTP id 8so904564pwj.14
        for <linux-mm@kvack.org>; Sun, 06 Feb 2011 02:49:10 -0800 (PST)
From: Minchan Kim <minchan.kim@gmail.com>
Subject: [PATCH v4 3/6] shmem: Change remove_from_page_cache
Date: Sun,  6 Feb 2011 19:48:02 +0900
Message-Id: <831b8109fc3bf929e791f4dc45e63bab45ebedb0.1296987110.git.minchan.kim@gmail.com>
In-Reply-To: <cover.1296987110.git.minchan.kim@gmail.com>
References: <cover.1296987110.git.minchan.kim@gmail.com>
In-Reply-To: <cover.1296987110.git.minchan.kim@gmail.com>
References: <cover.1296987110.git.minchan.kim@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mel@csn.ul.ie>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan.kim@gmail.com>

This patch series changes remove_from_page_cache's page ref counting
rule. Page cache ref count is decreased in delete_from_page_cache.
So we don't need decreasing page reference by caller.

Acked-by:Hugh Dickins <hughd@google.com>
Acked-by: Mel Gorman <mel@csn.ul.ie>
Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Reviewed-by: Johannes Weiner <hannes@cmpxchg.org>
Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
---
 mm/shmem.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/mm/shmem.c b/mm/shmem.c
index 7c9cdc6..4549134 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -1081,7 +1081,7 @@ static int shmem_writepage(struct page *page, struct writeback_control *wbc)
 	shmem_recalc_inode(inode);
 
 	if (swap.val && add_to_swap_cache(page, swap, GFP_ATOMIC) == 0) {
-		remove_from_page_cache(page);
+		delete_from_page_cache(page);
 		shmem_swp_set(info, entry, swap.val);
 		shmem_swp_unmap(entry);
 		if (list_empty(&info->swaplist))
@@ -1091,7 +1091,6 @@ static int shmem_writepage(struct page *page, struct writeback_control *wbc)
 		spin_unlock(&info->lock);
 		swap_shmem_alloc(swap);
 		BUG_ON(page_mapped(page));
-		page_cache_release(page);	/* pagecache ref */
 		swap_writepage(page, wbc);
 		if (inode) {
 			mutex_lock(&shmem_swaplist_mutex);
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
