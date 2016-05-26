Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id AFF686B0253
	for <linux-mm@kvack.org>; Thu, 26 May 2016 09:02:17 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id b124so143157292pfb.1
        for <linux-mm@kvack.org>; Thu, 26 May 2016 06:02:17 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id 67si6589631pfk.129.2016.05.26.06.02.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 May 2016 06:02:16 -0700 (PDT)
From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH] xfs: fail ->bmap for reflink inodes
Date: Thu, 26 May 2016 15:02:04 +0200
Message-Id: <1464267724-31423-2-git-send-email-hch@lst.de>
In-Reply-To: <1464267724-31423-1-git-send-email-hch@lst.de>
References: <1464267724-31423-1-git-send-email-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=a
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: darrick.wong@oracle.com
Cc: xfs@oss.sgi.com, linux-mm@kvack.org

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/xfs/xfs_aops.c | 11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/fs/xfs/xfs_aops.c b/fs/xfs/xfs_aops.c
index a955552..d053a9e 100644
--- a/fs/xfs/xfs_aops.c
+++ b/fs/xfs/xfs_aops.c
@@ -1829,6 +1829,17 @@ xfs_vm_bmap(
 
 	trace_xfs_vm_bmap(XFS_I(inode));
 	xfs_ilock(ip, XFS_IOLOCK_SHARED);
+
+	/*
+	 * The swap code (ab-)uses ->bmap to get a block mapping and then
+	 * bypasseN? the file system for actual I/O.  We really can't allow
+	 * that on reflinks inodes, so we have to skip out here.  And yes,
+	 * 0 is the magic code for a bmap error..
+	 */
+	if (xfs_is_reflink_inode(ip)) {
+		xfs_iunlock(ip, XFS_IOLOCK_SHARED);
+		return 0;
+	}
 	filemap_write_and_wait(mapping);
 	xfs_iunlock(ip, XFS_IOLOCK_SHARED);
 	return generic_block_bmap(mapping, block, xfs_get_blocks);
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
