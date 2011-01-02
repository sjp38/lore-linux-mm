Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 5210B6B0098
	for <linux-mm@kvack.org>; Sun,  2 Jan 2011 10:45:08 -0500 (EST)
Received: by pwj8 with SMTP id 8so2131053pwj.14
        for <linux-mm@kvack.org>; Sun, 02 Jan 2011 07:45:07 -0800 (PST)
From: Minchan Kim <minchan.kim@gmail.com>
Subject: [PATCH v2 5/7] truncate: Change remove_from_page_cache
Date: Mon,  3 Jan 2011 00:44:34 +0900
Message-Id: <05cf42eb7ae72d22b5cf050f02b95874ce216ace.1293982522.git.minchan.kim@gmail.com>
In-Reply-To: <cover.1293982522.git.minchan.kim@gmail.com>
References: <cover.1293982522.git.minchan.kim@gmail.com>
In-Reply-To: <cover.1293982522.git.minchan.kim@gmail.com>
References: <cover.1293982522.git.minchan.kim@gmail.com>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan.kim@gmail.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Andi Kleen <andi@firstfloor.org>, Nick Piggin <npiggin@kernel.dk>, Al Viro <viro@zeniv.linux.org.uk>
List-ID: <linux-mm.kvack.org>

This patch series changes remove_from_page_cache's page ref counting
rule. Page cache ref count is decreased in delete_from_page_cache.
So we don't need decreasing page reference by caller.

Cc: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: Andi Kleen <andi@firstfloor.org>
Cc: Nick Piggin <npiggin@kernel.dk>
Cc: Al Viro <viro@zeniv.linux.org.uk>
Acked-by: Hugh Dickins <hughd@google.com>
Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
---
 mm/truncate.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/mm/truncate.c b/mm/truncate.c
index 9ee5673..85404b0 100644
--- a/mm/truncate.c
+++ b/mm/truncate.c
@@ -108,13 +108,12 @@ truncate_complete_page(struct address_space *mapping, struct page *page)
 	cancel_dirty_page(page, PAGE_CACHE_SIZE);
 
 	clear_page_mlock(page);
-	remove_from_page_cache(page);
+	delete_from_page_cache(page);
 	ClearPageMappedToDisk(page);
-	/* this must be after the remove_from_page_cache which
+	/* this must be after the delete_from_page_cache which
 	 * calls cleancache_put_page (and note page->mapping is now NULL)
 	 */
 	cleancache_flush_page(mapping, page);
-	page_cache_release(page);	/* pagecache ref */
 	return 0;
 }
 
-- 
1.7.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
