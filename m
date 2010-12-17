Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 33F1C6B009F
	for <linux-mm@kvack.org>; Fri, 17 Dec 2010 12:14:12 -0500 (EST)
Received: by pwj8 with SMTP id 8so160736pwj.14
        for <linux-mm@kvack.org>; Fri, 17 Dec 2010 09:14:09 -0800 (PST)
From: Minchan Kim <minchan.kim@gmail.com>
Subject: [RFC 4/5] swap: Remove unnecessary page release
Date: Sat, 18 Dec 2010 02:13:39 +0900
Message-Id: <7b8f65cb0e08556bdb48c459cb1f72500f6aa61d.1292604746.git.minchan.kim@gmail.com>
In-Reply-To: <cover.1292604745.git.minchan.kim@gmail.com>
References: <cover.1292604745.git.minchan.kim@gmail.com>
In-Reply-To: <cover.1292604745.git.minchan.kim@gmail.com>
References: <cover.1292604745.git.minchan.kim@gmail.com>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Minchan Kim <minchan.kim@gmail.com>
List-ID: <linux-mm.kvack.org>

This patch series changes remove_from_page_cache's page ref counting
rule. page cache ref count is decreased in remove_from_page_cache.
So we don't need call again in caller context.

Cc:Hugh Dickins <hughd@google.com>
Cc: linux-mm@kvack.org
Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
---
 mm/shmem.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/mm/shmem.c b/mm/shmem.c
index fa9acc9..16800f2 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
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
