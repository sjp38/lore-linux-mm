Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 365DE6B0007
	for <linux-mm@kvack.org>; Wed, 30 May 2018 05:59:10 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id e16-v6so10656944pfn.5
        for <linux-mm@kvack.org>; Wed, 30 May 2018 02:59:10 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id w28-v6si1295985pge.329.2018.05.30.02.59.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 30 May 2018 02:59:08 -0700 (PDT)
From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 12/13] xfs: use iomap_bmap
Date: Wed, 30 May 2018 11:58:12 +0200
Message-Id: <20180530095813.31245-13-hch@lst.de>
In-Reply-To: <20180530095813.31245-1-hch@lst.de>
References: <20180530095813.31245-1-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-xfs@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

Switch to the iomap based bmap implementation to get rid of one of the
last users of xfs_get_blocks.

Signed-off-by: Christoph Hellwig <hch@lst.de>
Reviewed-by: Darrick J. Wong <darrick.wong@oracle.com>
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
