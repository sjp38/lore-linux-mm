Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2F3CD6B029D
	for <linux-mm@kvack.org>; Wed, 23 May 2018 10:45:47 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id 89-v6so14154256plb.18
        for <linux-mm@kvack.org>; Wed, 23 May 2018 07:45:47 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id h125-v6si13041658pgc.34.2018.05.23.07.45.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 23 May 2018 07:45:45 -0700 (PDT)
From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 33/34] xfs: do not set the page uptodate in xfs_writepage_map
Date: Wed, 23 May 2018 16:43:56 +0200
Message-Id: <20180523144357.18985-34-hch@lst.de>
In-Reply-To: <20180523144357.18985-1-hch@lst.de>
References: <20180523144357.18985-1-hch@lst.de>
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
index a4e53e0a57c2..492f4a4b1deb 100644
--- a/fs/xfs/xfs_aops.c
+++ b/fs/xfs/xfs_aops.c
@@ -796,7 +796,6 @@ xfs_writepage_map(
 	ssize_t			len = i_blocksize(inode);
 	int			error = 0;
 	int			count = 0;
-	bool			uptodate = true;
 	loff_t			file_offset;	/* file offset of page */
 	unsigned		poffset;	/* offset into page */
 
@@ -823,7 +822,6 @@ xfs_writepage_map(
 		if (!buffer_uptodate(bh)) {
 			if (PageUptodate(page))
 				ASSERT(buffer_mapped(bh));
-			uptodate = false;
 			continue;
 		}
 
@@ -857,9 +855,6 @@ xfs_writepage_map(
 		count++;
 	}
 
-	if (uptodate && poffset == PAGE_SIZE)
-		SetPageUptodate(page);
-
 	ASSERT(wpc->ioend || list_empty(&submit_list));
 
 out:
-- 
2.17.0
