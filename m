Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id EF5936B028F
	for <linux-mm@kvack.org>; Wed, 30 May 2018 06:01:27 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id w14-v6so5156248pfn.12
        for <linux-mm@kvack.org>; Wed, 30 May 2018 03:01:27 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id w1-v6si27222893pgp.10.2018.05.30.03.01.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 30 May 2018 03:01:26 -0700 (PDT)
From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 16/18] xfs: refactor the tail of xfs_writepage_map
Date: Wed, 30 May 2018 12:00:11 +0200
Message-Id: <20180530100013.31358-17-hch@lst.de>
In-Reply-To: <20180530100013.31358-1-hch@lst.de>
References: <20180530100013.31358-1-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-xfs@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

Rejuggle how we deal with the different error vs non-error and have
ioends vs not have ioend cases to keep the fast path streamlined, and
the duplicate code at a minimum.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/xfs/xfs_aops.c | 65 +++++++++++++++++++++++------------------------
 1 file changed, 32 insertions(+), 33 deletions(-)

diff --git a/fs/xfs/xfs_aops.c b/fs/xfs/xfs_aops.c
index 38021023131e..ac417ef326a9 100644
--- a/fs/xfs/xfs_aops.c
+++ b/fs/xfs/xfs_aops.c
@@ -873,7 +873,14 @@ xfs_writepage_map(
 	 * submission of outstanding ioends on the writepage context so they are
 	 * treated correctly on error.
 	 */
-	if (count) {
+	if (unlikely(error)) {
+		if (!count) {
+			xfs_aops_discard_page(page);
+			ClearPageUptodate(page);
+			unlock_page(page);
+			goto done;
+		}
+
 		/*
 		 * If the page was not fully cleaned, we need to ensure that the
 		 * higher layers come back to it correctly.  That means we need
@@ -882,43 +889,35 @@ xfs_writepage_map(
 		 * so another attempt to write this page in this writeback sweep
 		 * will be made.
 		 */
-		if (error) {
-			set_page_writeback_keepwrite(page);
-		} else {
-			clear_page_dirty_for_io(page);
-			set_page_writeback(page);
-		}
-		unlock_page(page);
-
-		/*
-		 * Preserve the original error if there was one, otherwise catch
-		 * submission errors here and propagate into subsequent ioend
-		 * submissions.
-		 */
-		list_for_each_entry_safe(ioend, next, &submit_list, io_list) {
-			int error2;
-
-			list_del_init(&ioend->io_list);
-			error2 = xfs_submit_ioend(wbc, ioend, error);
-			if (error2 && !error)
-				error = error2;
-		}
-	} else if (error) {
-		xfs_aops_discard_page(page);
-		ClearPageUptodate(page);
-		unlock_page(page);
+		set_page_writeback_keepwrite(page);
 	} else {
-		/*
-		 * We can end up here with no error and nothing to write if we
-		 * race with a partial page truncate on a sub-page block sized
-		 * filesystem. In that case we need to mark the page clean.
-		 */
 		clear_page_dirty_for_io(page);
 		set_page_writeback(page);
-		unlock_page(page);
-		end_page_writeback(page);
 	}
 
+	unlock_page(page);
+
+	/*
+	 * Preserve the original error if there was one, otherwise catch
+	 * submission errors here and propagate into subsequent ioend
+	 * submissions.
+	 */
+	list_for_each_entry_safe(ioend, next, &submit_list, io_list) {
+		int error2;
+
+		list_del_init(&ioend->io_list);
+		error2 = xfs_submit_ioend(wbc, ioend, error);
+		if (error2 && !error)
+			error = error2;
+	}
+
+	/*
+	 * We can end up here with no error and nothing to write if we race with
+	 * a partial page truncate on a sub-page block sized filesystem.
+	 */
+	if (!count)
+		end_page_writeback(page);
+done:
 	mapping_set_error(page->mapping, error);
 	return error;
 }
-- 
2.17.0
