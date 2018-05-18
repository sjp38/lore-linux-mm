Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4CADD6B063A
	for <linux-mm@kvack.org>; Fri, 18 May 2018 12:50:15 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id s3-v6so5061666pfh.0
        for <linux-mm@kvack.org>; Fri, 18 May 2018 09:50:15 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id h186-v6si6180701pge.324.2018.05.18.09.50.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 18 May 2018 09:50:14 -0700 (PDT)
From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 33/34] xfs: do not set the page uptodate in xfs_writepage_map
Date: Fri, 18 May 2018 18:48:29 +0200
Message-Id: <20180518164830.1552-34-hch@lst.de>
In-Reply-To: <20180518164830.1552-1-hch@lst.de>
References: <20180518164830.1552-1-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-xfs@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org, linux-mm@kvack.org

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
