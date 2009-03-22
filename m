Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 666496B003D
	for <linux-mm@kvack.org>; Sun, 22 Mar 2009 15:24:43 -0400 (EDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 2/3] ramfs-nommu: use generic lru cache
Date: Sun, 22 Mar 2009 21:13:03 +0100
Message-Id: <1237752784-1989-2-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <20090321102044.GA3427@cmpxchg.org>
References: <20090321102044.GA3427@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, David Howells <dhowells@redhat.com>, Nick Piggin <npiggin@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.com>, MinChan Kim <minchan.kim@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

Instead of open-coding the lru-list-add pagevec batching when
expanding a file mapping from zero, defer to the appropriate page
cache function that also takes care of adding the page to the lru
list.

This is cleaner, saves code and reduces the stack footprint by 16
words worth of pagevec.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Cc: David Howells <dhowells@redhat.com>
Cc: Nick Piggin <npiggin@suse.de>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: Peter Zijlstra <peterz@infradead.com>
Cc: MinChan Kim <minchan.kim@gmail.com>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
---
 fs/ramfs/file-nommu.c |   15 ++++-----------
 1 files changed, 4 insertions(+), 11 deletions(-)

diff --git a/fs/ramfs/file-nommu.c b/fs/ramfs/file-nommu.c
index 5d7c7ec..351192a 100644
--- a/fs/ramfs/file-nommu.c
+++ b/fs/ramfs/file-nommu.c
@@ -60,7 +60,6 @@ const struct inode_operations ramfs_file_inode_operations = {
  */
 int ramfs_nommu_expand_for_mapping(struct inode *inode, size_t newsize)
 {
-	struct pagevec lru_pvec;
 	unsigned long npages, xpages, loop, limit;
 	struct page *pages;
 	unsigned order;
@@ -103,24 +102,20 @@ int ramfs_nommu_expand_for_mapping(struct inode *inode, size_t newsize)
 	memset(data, 0, newsize);
 
 	/* attach all the pages to the inode's address space */
-	pagevec_init(&lru_pvec, 0);
 	for (loop = 0; loop < npages; loop++) {
 		struct page *page = pages + loop;
 
-		ret = add_to_page_cache(page, inode->i_mapping, loop, GFP_KERNEL);
+		ret = add_to_page_cache_lru(page, inode->i_mapping, loop,
+					GFP_KERNEL);
 		if (ret < 0)
 			goto add_error;
 
-		if (!pagevec_add(&lru_pvec, page))
-			__pagevec_lru_add_file(&lru_pvec);
-
 		/* prevent the page from being discarded on memory pressure */
 		SetPageDirty(page);
 
 		unlock_page(page);
 	}
 
-	pagevec_lru_add_file(&lru_pvec);
 	return 0;
 
  fsize_exceeded:
@@ -129,10 +124,8 @@ int ramfs_nommu_expand_for_mapping(struct inode *inode, size_t newsize)
 	return -EFBIG;
 
  add_error:
-	pagevec_lru_add_file(&lru_pvec);
-	page_cache_release(pages + loop);
-	for (loop++; loop < npages; loop++)
-		__free_page(pages + loop);
+	while (loop < npages)
+		__free_page(pages + loop++);
 	return ret;
 }
 
-- 
1.6.2.1.135.gde769

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
