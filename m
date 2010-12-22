Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 9DC966B0092
	for <linux-mm@kvack.org>; Wed, 22 Dec 2010 10:34:07 -0500 (EST)
Received: by mail-iw0-f169.google.com with SMTP id 40so5493006iwn.14
        for <linux-mm@kvack.org>; Wed, 22 Dec 2010 07:34:06 -0800 (PST)
From: Minchan Kim <minchan.kim@gmail.com>
Subject: [PATCH 5/7] truncate: Change remove_from_page_cache
Date: Thu, 23 Dec 2010 00:32:47 +0900
Message-Id: <fdafb3fb6ed32ec96f945fdbdd42bd6492d00cd7.1293031047.git.minchan.kim@gmail.com>
In-Reply-To: <cover.1293031046.git.minchan.kim@gmail.com>
References: <cover.1293031046.git.minchan.kim@gmail.com>
In-Reply-To: <cover.1293031046.git.minchan.kim@gmail.com>
References: <cover.1293031046.git.minchan.kim@gmail.com>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Andi Kleen <andi@firstfloor.org>, Nick Piggin <npiggin@kernel.dk>, Al Viro <viro@zeniv.linux.org.uk>
List-ID: <linux-mm.kvack.org>

This patch series changes remove_from_page_cache's page ref counting
rule. Page cache ref count is decreased in delete_from_page_cache.
So we don't need decreasing page reference by caller.

Cc: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: Andi Kleen <andi@firstfloor.org>
Cc: Nick Piggin <npiggin@kernel.dk>
Cc: Al Viro <viro@zeniv.linux.org.uk>
Cc: linux-mm@kvack.org
Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/truncate.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/mm/truncate.c b/mm/truncate.c
index 9ee5673..3adb9c0 100644
--- a/mm/truncate.c
+++ b/mm/truncate.c
@@ -108,13 +108,12 @@ truncate_complete_page(struct address_space *mapping, struct page *page)
 	cancel_dirty_page(page, PAGE_CACHE_SIZE);
 
 	clear_page_mlock(page);
-	remove_from_page_cache(page);
+	delete_from_page_cache(page);
 	ClearPageMappedToDisk(page);
 	/* this must be after the remove_from_page_cache which
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
