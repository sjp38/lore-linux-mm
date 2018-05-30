Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7904E6B028E
	for <linux-mm@kvack.org>; Wed, 30 May 2018 06:01:23 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id g6-v6so11107316plq.9
        for <linux-mm@kvack.org>; Wed, 30 May 2018 03:01:23 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id w12-v6si33832096pld.46.2018.05.30.03.01.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 30 May 2018 03:01:22 -0700 (PDT)
From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 15/18] xfs: remove xfs_start_page_writeback
Date: Wed, 30 May 2018 12:00:10 +0200
Message-Id: <20180530100013.31358-16-hch@lst.de>
In-Reply-To: <20180530100013.31358-1-hch@lst.de>
References: <20180530100013.31358-1-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-xfs@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

This helper only has two callers, one of them with a constant error
argument.  Remove it to make pending changes to the code a little easier.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/xfs/xfs_aops.c | 47 +++++++++++++++++++++--------------------------
 1 file changed, 21 insertions(+), 26 deletions(-)

diff --git a/fs/xfs/xfs_aops.c b/fs/xfs/xfs_aops.c
index 025f2acac100..38021023131e 100644
--- a/fs/xfs/xfs_aops.c
+++ b/fs/xfs/xfs_aops.c
@@ -495,30 +495,6 @@ xfs_imap_valid(
 		offset < imap->br_startoff + imap->br_blockcount;
 }
 
-STATIC void
-xfs_start_page_writeback(
-	struct page		*page,
-	int			clear_dirty)
-{
-	ASSERT(PageLocked(page));
-	ASSERT(!PageWriteback(page));
-
-	/*
-	 * if the page was not fully cleaned, we need to ensure that the higher
-	 * layers come back to it correctly. That means we need to keep the page
-	 * dirty, and for WB_SYNC_ALL writeback we need to ensure the
-	 * PAGECACHE_TAG_TOWRITE index mark is not removed so another attempt to
-	 * write this page in this writeback sweep will be made.
-	 */
-	if (clear_dirty) {
-		clear_page_dirty_for_io(page);
-		set_page_writeback(page);
-	} else
-		set_page_writeback_keepwrite(page);
-
-	unlock_page(page);
-}
-
 /*
  * Submit the bio for an ioend. We are passed an ioend with a bio attached to
  * it, and we submit that bio. The ioend may be used for multiple bio
@@ -877,6 +853,9 @@ xfs_writepage_map(
 	ASSERT(wpc->ioend || list_empty(&submit_list));
 
 out:
+	ASSERT(PageLocked(page));
+	ASSERT(!PageWriteback(page));
+
 	/*
 	 * On error, we have to fail the ioend here because we have locked
 	 * buffers in the ioend. If we don't do this, we'll deadlock
@@ -895,7 +874,21 @@ xfs_writepage_map(
 	 * treated correctly on error.
 	 */
 	if (count) {
-		xfs_start_page_writeback(page, !error);
+		/*
+		 * If the page was not fully cleaned, we need to ensure that the
+		 * higher layers come back to it correctly.  That means we need
+		 * to keep the page dirty, and for WB_SYNC_ALL writeback we need
+		 * to ensure the PAGECACHE_TAG_TOWRITE index mark is not removed
+		 * so another attempt to write this page in this writeback sweep
+		 * will be made.
+		 */
+		if (error) {
+			set_page_writeback_keepwrite(page);
+		} else {
+			clear_page_dirty_for_io(page);
+			set_page_writeback(page);
+		}
+		unlock_page(page);
 
 		/*
 		 * Preserve the original error if there was one, otherwise catch
@@ -920,7 +913,9 @@ xfs_writepage_map(
 		 * race with a partial page truncate on a sub-page block sized
 		 * filesystem. In that case we need to mark the page clean.
 		 */
-		xfs_start_page_writeback(page, 1);
+		clear_page_dirty_for_io(page);
+		set_page_writeback(page);
+		unlock_page(page);
 		end_page_writeback(page);
 	}
 
-- 
2.17.0
