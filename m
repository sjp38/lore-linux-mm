Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f47.google.com (mail-wg0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id D102A6B0074
	for <linux-mm@kvack.org>; Wed, 14 Jan 2015 04:43:51 -0500 (EST)
Received: by mail-wg0-f47.google.com with SMTP id n12so7810282wgh.6
        for <linux-mm@kvack.org>; Wed, 14 Jan 2015 01:43:51 -0800 (PST)
Received: from casper.infradead.org (casper.infradead.org. [2001:770:15f::2])
        by mx.google.com with ESMTPS id hj8si46944386wjc.14.2015.01.14.01.43.51
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Jan 2015 01:43:51 -0800 (PST)
From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 06/12] nilfs2: set up s_bdi like the generic mount_bdev code
Date: Wed, 14 Jan 2015 10:42:35 +0100
Message-Id: <1421228561-16857-7-git-send-email-hch@lst.de>
In-Reply-To: <1421228561-16857-1-git-send-email-hch@lst.de>
References: <1421228561-16857-1-git-send-email-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@fb.com>
Cc: David Howells <dhowells@redhat.com>, Tejun Heo <tj@kernel.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-mtd@lists.infradead.org, linux-nfs@vger.kernel.org, ceph-devel@vger.kernel.org

mapping->backing_dev_info will go away, so don't rely on it.

Signed-off-by: Christoph Hellwig <hch@lst.de>
Acked-by: Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>
Reviewed-by: Tejun Heo <tj@kernel.org>
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
