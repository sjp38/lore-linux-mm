Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 345896B0378
	for <linux-mm@kvack.org>; Wed,  9 May 2018 03:50:29 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id y12so17631063pfe.8
        for <linux-mm@kvack.org>; Wed, 09 May 2018 00:50:29 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id z23-v6si24686175plo.492.2018.05.09.00.50.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 09 May 2018 00:50:28 -0700 (PDT)
From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 29/33] xfs: do not set the page uptodate in xfs_writepage_map
Date: Wed,  9 May 2018 09:48:26 +0200
Message-Id: <20180509074830.16196-30-hch@lst.de>
In-Reply-To: <20180509074830.16196-1-hch@lst.de>
References: <20180509074830.16196-1-hch@lst.de>
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
index dc82d4e71a64..dc92f23b0ea4 100644
--- a/fs/xfs/xfs_aops.c
+++ b/fs/xfs/xfs_aops.c
@@ -812,7 +812,6 @@ xfs_writepage_map(
 	ssize_t			len = i_blocksize(inode);
 	int			error = 0;
 	int			count = 0;
-	bool			uptodate = true;
 	loff_t			file_offset;	/* file offset of page */
 	unsigned		poffset;	/* offset into page */
 
@@ -840,7 +839,6 @@ xfs_writepage_map(
 		if (bh && !buffer_uptodate(bh)) {
 			if (PageUptodate(page))
 				ASSERT(buffer_mapped(bh));
-			uptodate = false;
 			bh = bh->b_this_page;
 			continue;
 		}
@@ -880,9 +878,6 @@ xfs_writepage_map(
 		count++;
 	}
 
-	if (uptodate && poffset == PAGE_SIZE)
-		SetPageUptodate(page);
-
 	ASSERT(wpc->ioend || list_empty(&submit_list));
 
 out:
-- 
2.17.0
