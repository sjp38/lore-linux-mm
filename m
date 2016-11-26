Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7C1DD6B0069
	for <linux-mm@kvack.org>; Fri, 25 Nov 2016 21:09:39 -0500 (EST)
Received: by mail-oi0-f71.google.com with SMTP id n184so151829726oig.1
        for <linux-mm@kvack.org>; Fri, 25 Nov 2016 18:09:39 -0800 (PST)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTPS id 12si22881827otj.49.2016.11.25.18.09.37
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 25 Nov 2016 18:09:38 -0800 (PST)
From: Wei Fang <fangwei1@huawei.com>
Subject: [PATCH] mm: Fix a NULL dereference crash while accessing bdev->bd_disk
Date: Sat, 26 Nov 2016 10:06:22 +0800
Message-ID: <1480125982-8497-1-git-send-email-fangwei1@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: jack@suse.cz, hannes@cmpxchg.org, hch@infradead.org, linux-mm@kvack.org, Wei Fang <fangwei1@huawei.com>, stable@vger.kernel.org

->bd_disk is assigned to NULL in __blkdev_put() when no one is holding
the bdev. After that, ->bd_inode still can be touched in the
blockdev_superblock->s_inodes list before the final iput. So iterate_bdevs()
can still get this inode, and start writeback on mapping dirty pages.
->bd_disk will be dereferenced in mapping_cap_writeback_dirty() in this
case, and a NULL dereference crash will be triggered:

Unable to handle kernel NULL pointer dereference at virtual address 00000388
...
[<ffff8000004cb1e4>] blk_get_backing_dev_info+0x1c/0x28
[<ffff8000001c879c>] __filemap_fdatawrite_range+0x54/0x98
[<ffff8000001c8804>] filemap_fdatawrite+0x24/0x2c
[<ffff80000027e7a4>] fdatawrite_one_bdev+0x20/0x28
[<ffff800000288b44>] iterate_bdevs+0xec/0x144
[<ffff80000027eb50>] sys_sync+0x84/0xd0

Since mapping_cap_writeback_dirty() is always return true about
block device inodes, no need to check it if the inode is a block
device inode.

Cc: stable@vger.kernel.org
Signed-off-by: Wei Fang <fangwei1@huawei.com>
---
 mm/filemap.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/mm/filemap.c b/mm/filemap.c
index 235021e..d607677 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -334,8 +334,9 @@ int __filemap_fdatawrite_range(struct address_space *mapping, loff_t start,
 		.range_end = end,
 	};
 
-	if (!mapping_cap_writeback_dirty(mapping))
-		return 0;
+	if (!sb_is_blkdev_sb(mapping->host->i_sb))
+		if (!mapping_cap_writeback_dirty(mapping))
+			return 0;
 
 	wbc_attach_fdatawrite_inode(&wbc, mapping->host);
 	ret = do_writepages(mapping, &wbc);
-- 
2.4.11

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
