Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 24E366B0287
	for <linux-mm@kvack.org>; Wed, 30 May 2018 06:01:07 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id s3-v6so10661946pfh.0
        for <linux-mm@kvack.org>; Wed, 30 May 2018 03:01:07 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id t1-v6si35331346plb.90.2018.05.30.03.01.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 30 May 2018 03:01:06 -0700 (PDT)
From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 11/18] xfs: don't clear imap_valid for a non-uptodate buffers
Date: Wed, 30 May 2018 12:00:06 +0200
Message-Id: <20180530100013.31358-12-hch@lst.de>
In-Reply-To: <20180530100013.31358-1-hch@lst.de>
References: <20180530100013.31358-1-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-xfs@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

Finding a buffer that isn't uptodate doesn't invalidate the mapping for
any given block.  The last_sector check will already take care of starting
another ioend as soon as we find any non-update buffer, and if the current
mapping doesn't include the next uptodate buffer the xfs_imap_valid check
will take care of it.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/xfs/xfs_aops.c | 5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

diff --git a/fs/xfs/xfs_aops.c b/fs/xfs/xfs_aops.c
index cef2bc3cf98b..7dc13b0aae60 100644
--- a/fs/xfs/xfs_aops.c
+++ b/fs/xfs/xfs_aops.c
@@ -849,15 +849,12 @@ xfs_writepage_map(
 			break;
 
 		/*
-		 * Block does not contain valid data, skip it, mark the current
-		 * map as invalid because we have a discontiguity. This ensures
-		 * we put subsequent writeable buffers into a new ioend.
+		 * Block does not contain valid data, skip it.
 		 */
 		if (!buffer_uptodate(bh)) {
 			if (PageUptodate(page))
 				ASSERT(buffer_mapped(bh));
 			uptodate = false;
-			wpc->imap_valid = false;
 			continue;
 		}
 
-- 
2.17.0
