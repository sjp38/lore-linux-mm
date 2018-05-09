Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 877F46B0371
	for <linux-mm@kvack.org>; Wed,  9 May 2018 03:50:26 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id j18-v6so19291411pgv.18
        for <linux-mm@kvack.org>; Wed, 09 May 2018 00:50:26 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id s21-v6si12327527plr.143.2018.05.09.00.50.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 09 May 2018 00:50:25 -0700 (PDT)
From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 27/33] xfs: remove xfs_start_page_writeback
Date: Wed,  9 May 2018 09:48:24 +0200
Message-Id: <20180509074830.16196-28-hch@lst.de>
In-Reply-To: <20180509074830.16196-1-hch@lst.de>
References: <20180509074830.16196-1-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-xfs@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org, linux-mm@kvack.org

This helper only has two callers, one of them with a constant error
argument.  Remove it to make pending changes to the code a little easier.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/xfs/xfs_aops.c | 47 +++++++++++++++++++++--------------------------
 1 file changed, 21 insertions(+), 26 deletions(-)

diff --git a/fs/xfs/xfs_aops.c b/fs/xfs/xfs_aops.c
index 879599f723b6..6b39792270aa 100644
--- a/fs/xfs/xfs_aops.c
+++ b/fs/xfs/xfs_aops.c
@@ -521,30 +521,6 @@ xfs_imap_valid(
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
@@ -910,6 +886,9 @@ xfs_writepage_map(
 	ASSERT(wpc->ioend || list_empty(&submit_list));
 
 out:
+	ASSERT(PageLocked(page));
+	ASSERT(!PageWriteback(page));
+
 	/*
 	 * On error, we have to fail the ioend here because we have locked
 	 * buffers in the ioend. If we don't do this, we'll deadlock
@@ -928,7 +907,21 @@ xfs_writepage_map(
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
@@ -953,7 +946,9 @@ xfs_writepage_map(
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
