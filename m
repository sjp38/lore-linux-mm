Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id CD72E6B0072
	for <linux-mm@kvack.org>; Tue, 30 Dec 2014 03:58:38 -0500 (EST)
Received: by mail-wi0-f181.google.com with SMTP id r20so23686413wiv.8
        for <linux-mm@kvack.org>; Tue, 30 Dec 2014 00:58:38 -0800 (PST)
Received: from casper.infradead.org (casper.infradead.org. [2001:770:15f::2])
        by mx.google.com with ESMTPS id t4si77852558wjq.42.2014.12.30.00.58.29
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Dec 2014 00:58:29 -0800 (PST)
From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 6/8] nilfs2: set up s_bdi like the generic mount_bdev code
Date: Tue, 30 Dec 2014 09:57:37 +0100
Message-Id: <1419929859-24427-7-git-send-email-hch@lst.de>
In-Reply-To: <1419929859-24427-1-git-send-email-hch@lst.de>
References: <1419929859-24427-1-git-send-email-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@fb.com>
Cc: David Howells <dhowells@redhat.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-mtd@lists.infradead.org

mapping->backing_dev_info will go away, so don't rely on it.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/nilfs2/super.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/fs/nilfs2/super.c b/fs/nilfs2/super.c
index 2e5b3ec..3d4bbac 100644
--- a/fs/nilfs2/super.c
+++ b/fs/nilfs2/super.c
@@ -1057,7 +1057,6 @@ nilfs_fill_super(struct super_block *sb, void *data, int silent)
 {
 	struct the_nilfs *nilfs;
 	struct nilfs_root *fsroot;
-	struct backing_dev_info *bdi;
 	__u64 cno;
 	int err;
 
@@ -1077,8 +1076,7 @@ nilfs_fill_super(struct super_block *sb, void *data, int silent)
 	sb->s_time_gran = 1;
 	sb->s_max_links = NILFS_LINK_MAX;
 
-	bdi = sb->s_bdev->bd_inode->i_mapping->backing_dev_info;
-	sb->s_bdi = bdi ? : &default_backing_dev_info;
+	sb->s_bdi = &bdev_get_queue(sb->s_bdev)->backing_dev_info;
 
 	err = load_nilfs(nilfs, sb);
 	if (err)
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
