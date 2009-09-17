Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id D498A6B004F
	for <linux-mm@kvack.org>; Thu, 17 Sep 2009 11:21:43 -0400 (EDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 1/7] fs: buffer_head writepage no invalidate
Date: Thu, 17 Sep 2009 17:21:41 +0200
Message-Id: <1253200907-31392-2-git-send-email-jack@suse.cz>
In-Reply-To: <1253200907-31392-1-git-send-email-jack@suse.cz>
References: <1253200907-31392-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
To: linux-fsdevel@vger.kernel.org
Cc: LKML <linux-kernel@vger.kernel.org>, linux-ext4@vger.kernel.org, linux-mm@kvack.org, npiggin@suse.de
List-ID: <linux-mm.kvack.org>

From: Nick Piggin <npiggin@suse.de>

invalidate should not be required in the writeout path. The truncate
sequence will first reduce i_size, then clean and discard any existing
pagecache (and no new dirty pagecache can be added because i_size was
reduced and i_mutex is being held), then filesystem data structures
are updated.

Filesystem needs to be able to handle writeout at any point before
the last step, and once the 2nd step completes, there should be no
unfreeable dirty buffers anyway (truncate performs the do_invalidatepage).

Having filesystem changes depend on reading i_size without holding
i_mutex is confusing at least. There is still a case in writepage
paths in buffer.c uses i_size (testing which block to write out), but
this is a small improvement.
---
 fs/buffer.c |   20 ++------------------
 1 files changed, 2 insertions(+), 18 deletions(-)

diff --git a/fs/buffer.c b/fs/buffer.c
index d8d1b46..67b260a 100644
--- a/fs/buffer.c
+++ b/fs/buffer.c
@@ -2666,18 +2666,8 @@ int nobh_writepage(struct page *page, get_block_t *get_block,
 	/* Is the page fully outside i_size? (truncate in progress) */
 	offset = i_size & (PAGE_CACHE_SIZE-1);
 	if (page->index >= end_index+1 || !offset) {
-		/*
-		 * The page may have dirty, unmapped buffers.  For example,
-		 * they may have been added in ext3_writepage().  Make them
-		 * freeable here, so the page does not leak.
-		 */
-#if 0
-		/* Not really sure about this  - do we need this ? */
-		if (page->mapping->a_ops->invalidatepage)
-			page->mapping->a_ops->invalidatepage(page, offset);
-#endif
 		unlock_page(page);
-		return 0; /* don't care */
+		return 0;
 	}
 
 	/*
@@ -2870,14 +2860,8 @@ int block_write_full_page_endio(struct page *page, get_block_t *get_block,
 	/* Is the page fully outside i_size? (truncate in progress) */
 	offset = i_size & (PAGE_CACHE_SIZE-1);
 	if (page->index >= end_index+1 || !offset) {
-		/*
-		 * The page may have dirty, unmapped buffers.  For example,
-		 * they may have been added in ext3_writepage().  Make them
-		 * freeable here, so the page does not leak.
-		 */
-		do_invalidatepage(page, 0);
 		unlock_page(page);
-		return 0; /* don't care */
+		return 0;
 	}
 
 	/*
-- 
1.6.0.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
