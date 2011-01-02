Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id C3EB76B0095
	for <linux-mm@kvack.org>; Sun,  2 Jan 2011 10:45:04 -0500 (EST)
Received: by mail-px0-f169.google.com with SMTP id 12so3610709pxi.14
        for <linux-mm@kvack.org>; Sun, 02 Jan 2011 07:45:03 -0800 (PST)
From: Minchan Kim <minchan.kim@gmail.com>
Subject: [PATCH v2 4/7] swap: Change remove_from_page_cache
Date: Mon,  3 Jan 2011 00:44:33 +0900
Message-Id: <74a0a108b98f304efc2e28cea413fa3c9682ca15.1293982522.git.minchan.kim@gmail.com>
In-Reply-To: <cover.1293982522.git.minchan.kim@gmail.com>
References: <cover.1293982522.git.minchan.kim@gmail.com>
In-Reply-To: <cover.1293982522.git.minchan.kim@gmail.com>
References: <cover.1293982522.git.minchan.kim@gmail.com>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan.kim@gmail.com>
List-ID: <linux-mm.kvack.org>

This patch series changes remove_from_page_cache's page ref counting
rule. Page cache ref count is decreased in delete_from_page_cache.
So we don't need decreasing page reference by caller.

Acked-by:Hugh Dickins <hughd@google.com>
Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
---
 mm/shmem.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/mm/shmem.c b/mm/shmem.c
index fa9acc9..079cced 100644
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
1.7.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
