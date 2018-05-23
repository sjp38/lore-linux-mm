Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7E5A56B0275
	for <linux-mm@kvack.org>; Wed, 23 May 2018 10:45:00 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id bd7-v6so14343918plb.20
        for <linux-mm@kvack.org>; Wed, 23 May 2018 07:45:00 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id w22-v6si18130697pll.599.2018.05.23.07.44.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 23 May 2018 07:44:59 -0700 (PDT)
From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 17/34] xfs: use iomap_bmap
Date: Wed, 23 May 2018 16:43:40 +0200
Message-Id: <20180523144357.18985-18-hch@lst.de>
In-Reply-To: <20180523144357.18985-1-hch@lst.de>
References: <20180523144357.18985-1-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-xfs@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

Switch to the iomap based bmap implementation to get rid of one of the
last users of xfs_get_blocks.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/xfs/xfs_aops.c | 9 +++------
 1 file changed, 3 insertions(+), 6 deletions(-)

diff --git a/fs/xfs/xfs_aops.c b/fs/xfs/xfs_aops.c
index 80de476cecf8..56e405572909 100644
--- a/fs/xfs/xfs_aops.c
+++ b/fs/xfs/xfs_aops.c
@@ -1378,10 +1378,9 @@ xfs_vm_bmap(
 	struct address_space	*mapping,
 	sector_t		block)
 {
-	struct inode		*inode = (struct inode *)mapping->host;
-	struct xfs_inode	*ip = XFS_I(inode);
+	struct xfs_inode	*ip = XFS_I(mapping->host);
 
-	trace_xfs_vm_bmap(XFS_I(inode));
+	trace_xfs_vm_bmap(ip);
 
 	/*
 	 * The swap code (ab-)uses ->bmap to get a block mapping and then
@@ -1394,9 +1393,7 @@ xfs_vm_bmap(
 	 */
 	if (xfs_is_reflink_inode(ip) || XFS_IS_REALTIME_INODE(ip))
 		return 0;
-
-	filemap_write_and_wait(mapping);
-	return generic_block_bmap(mapping, block, xfs_get_blocks);
+	return iomap_bmap(mapping, block, &xfs_iomap_ops);
 }
 
 STATIC int
-- 
2.17.0
