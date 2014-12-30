Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f43.google.com (mail-wg0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id 1A8AB6B0071
	for <linux-mm@kvack.org>; Tue, 30 Dec 2014 03:58:34 -0500 (EST)
Received: by mail-wg0-f43.google.com with SMTP id k14so2533955wgh.16
        for <linux-mm@kvack.org>; Tue, 30 Dec 2014 00:58:33 -0800 (PST)
Received: from casper.infradead.org (casper.infradead.org. [2001:770:15f::2])
        by mx.google.com with ESMTPS id l17si63635925wiv.106.2014.12.30.00.58.28
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Dec 2014 00:58:28 -0800 (PST)
From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 5/8] block_dev: get bdev inode bdi directly from the block device
Date: Tue, 30 Dec 2014 09:57:36 +0100
Message-Id: <1419929859-24427-6-git-send-email-hch@lst.de>
In-Reply-To: <1419929859-24427-1-git-send-email-hch@lst.de>
References: <1419929859-24427-1-git-send-email-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@fb.com>
Cc: David Howells <dhowells@redhat.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-mtd@lists.infradead.org

Directly grab the backing_dev_info from the request_queue instead of
detouring through the address_space.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/fs-writeback.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
index 2d609a5..e8116a4 100644
--- a/fs/fs-writeback.c
+++ b/fs/fs-writeback.c
@@ -69,10 +69,10 @@ EXPORT_SYMBOL(writeback_in_progress);
 static inline struct backing_dev_info *inode_to_bdi(struct inode *inode)
 {
 	struct super_block *sb = inode->i_sb;
-
+#ifdef CONFIG_BLOCK
 	if (sb_is_blkdev_sb(sb))
-		return inode->i_mapping->backing_dev_info;
-
+		return blk_get_backing_dev_info(I_BDEV(inode));
+#endif
 	return sb->s_bdi;
 }
 
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
