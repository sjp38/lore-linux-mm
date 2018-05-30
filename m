Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 247EE6B0299
	for <linux-mm@kvack.org>; Wed, 30 May 2018 06:01:31 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id d1-v6so3777906pga.15
        for <linux-mm@kvack.org>; Wed, 30 May 2018 03:01:31 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 67-v6si34369495pla.475.2018.05.30.03.01.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 30 May 2018 03:01:30 -0700 (PDT)
From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 17/18] xfs: do not set the page uptodate in xfs_writepage_map
Date: Wed, 30 May 2018 12:00:12 +0200
Message-Id: <20180530100013.31358-18-hch@lst.de>
In-Reply-To: <20180530100013.31358-1-hch@lst.de>
References: <20180530100013.31358-1-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-xfs@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

We already track the page uptodate status based on the buffer uptodate
status, which is updated whenever reading or zeroing blocks.

This code has been there since commit a ptool commit in 2002, which
claims to:

    "merge" the 2.4 fsx fix for block size < page size to 2.5.  This needed
    major changes to actually fit.

and isn't present in other writepage implementations.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/xfs/xfs_aops.c | 5 -----
 1 file changed, 5 deletions(-)

diff --git a/fs/xfs/xfs_aops.c b/fs/xfs/xfs_aops.c
index ac417ef326a9..84f88cecd2f1 100644
--- a/fs/xfs/xfs_aops.c
+++ b/fs/xfs/xfs_aops.c
@@ -786,7 +786,6 @@ xfs_writepage_map(
 	ssize_t			len = i_blocksize(inode);
 	int			error = 0;
 	int			count = 0;
-	bool			uptodate = true;
 	loff_t			file_offset;	/* file offset of page */
 	unsigned		poffset;	/* offset into page */
 
@@ -813,7 +812,6 @@ xfs_writepage_map(
 		if (!buffer_uptodate(bh)) {
 			if (PageUptodate(page))
 				ASSERT(buffer_mapped(bh));
-			uptodate = false;
 			continue;
 		}
 
@@ -847,9 +845,6 @@ xfs_writepage_map(
 		count++;
 	}
 
-	if (uptodate && poffset == PAGE_SIZE)
-		SetPageUptodate(page);
-
 	ASSERT(wpc->ioend || list_empty(&submit_list));
 
 out:
-- 
2.17.0
