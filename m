Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id ED05F6B0636
	for <linux-mm@kvack.org>; Fri, 18 May 2018 12:50:07 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id 72-v6so5351575pld.19
        for <linux-mm@kvack.org>; Fri, 18 May 2018 09:50:07 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 73-v6si2248930pge.55.2018.05.18.09.50.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 18 May 2018 09:50:06 -0700 (PDT)
From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 31/34] xfs: remove xfs_start_page_writeback
Date: Fri, 18 May 2018 18:48:27 +0200
Message-Id: <20180518164830.1552-32-hch@lst.de>
In-Reply-To: <20180518164830.1552-1-hch@lst.de>
References: <20180518164830.1552-1-hch@lst.de>
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
index 951b329abb23..dd92d99df51f 100644
--- a/fs/xfs/xfs_aops.c
+++ b/fs/xfs/xfs_aops.c
@@ -505,30 +505,6 @@ xfs_imap_valid(
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
@@ -887,6 +863,9 @@ xfs_writepage_map(
 	ASSERT(wpc->ioend || list_empty(&submit_list));
 
 out:
+	ASSERT(PageLocked(page));
+	ASSERT(!PageWriteback(page));
+
 	/*
 	 * On error, we have to fail the ioend here because we have locked
 	 * buffers in the ioend. If we don't do this, we'll deadlock
@@ -905,7 +884,21 @@ xfs_writepage_map(
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
@@ -930,7 +923,9 @@ xfs_writepage_map(
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
