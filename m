Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id C7FBF6B02FD
	for <linux-mm@kvack.org>; Wed, 26 Jul 2017 07:47:27 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id z36so23163425wrb.13
        for <linux-mm@kvack.org>; Wed, 26 Jul 2017 04:47:27 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 34si17022560wrg.43.2017.07.26.04.47.26
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 26 Jul 2017 04:47:26 -0700 (PDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 04/10] fs: Fix performance regression in clean_bdev_aliases()
Date: Wed, 26 Jul 2017 13:46:58 +0200
Message-Id: <20170726114704.7626-5-jack@suse.cz>
In-Reply-To: <20170726114704.7626-1-jack@suse.cz>
References: <20170726114704.7626-1-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>

Commit e64855c6cfaa "fs: Add helper to clean bdev aliases under a bh and
use it" added a wrapper for clean_bdev_aliases() that invalidates bdev
aliases underlying a single buffer head. However this has caused a
performance regression for bonnie++ benchmark on ext4 filesystem when
delayed allocation is turned off (ext3 mode) - average of 3 runs:

Hmean SeqOut Char  164787.55 (  0.00%) 107189.06 (-34.95%)
Hmean SeqOut Block 219883.89 (  0.00%) 168870.32 (-23.20%)

The reason for this regression is that clean_bdev_aliases() is slower
when called for a single block because pagevec_lookup() it uses will end
up iterating through the radix tree until it finds a page (which may
take a while) but we are only interested whether there's a page at a
particular index.

Fix the problem by using pagevec_lookup_range() instead which avoids the
needless iteration.

Fixes: e64855c6cfaa0a80c1b71c5f647cb792dc436668
Signed-off-by: Jan Kara <jack@suse.cz>
---
 fs/buffer.c | 14 ++++++++------
 1 file changed, 8 insertions(+), 6 deletions(-)

diff --git a/fs/buffer.c b/fs/buffer.c
index 5b20893708e2..7e531bb356bd 100644
--- a/fs/buffer.c
+++ b/fs/buffer.c
@@ -1627,19 +1627,18 @@ void clean_bdev_aliases(struct block_device *bdev, sector_t block, sector_t len)
 	struct pagevec pvec;
 	pgoff_t index = block >> (PAGE_SHIFT - bd_inode->i_blkbits);
 	pgoff_t end;
-	int i;
+	int i, count;
 	struct buffer_head *bh;
 	struct buffer_head *head;
 
 	end = (block + len - 1) >> (PAGE_SHIFT - bd_inode->i_blkbits);
 	pagevec_init(&pvec, 0);
-	while (index <= end && pagevec_lookup(&pvec, bd_mapping, &index,
-			min(end - index, (pgoff_t)PAGEVEC_SIZE - 1) + 1)) {
-		for (i = 0; i < pagevec_count(&pvec); i++) {
+	while (pagevec_lookup_range(&pvec, bd_mapping, &index, end,
+				    PAGEVEC_SIZE)) {
+		count = pagevec_count(&pvec);
+		for (i = 0; i < count; i++) {
 			struct page *page = pvec.pages[i];
 
-			if (page->index > end)
-				break;
 			if (!page_has_buffers(page))
 				continue;
 			/*
@@ -1669,6 +1668,9 @@ void clean_bdev_aliases(struct block_device *bdev, sector_t block, sector_t len)
 		}
 		pagevec_release(&pvec);
 		cond_resched();
+		/* End of range already reached? */
+		if (index > end || !index)
+			break;
 	}
 }
 EXPORT_SYMBOL(clean_bdev_aliases);
-- 
2.12.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
