Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f200.google.com (mail-yw0-f200.google.com [209.85.161.200])
	by kanga.kvack.org (Postfix) with ESMTP id BB6A66B0038
	for <linux-mm@kvack.org>; Thu, 29 Sep 2016 08:08:24 -0400 (EDT)
Received: by mail-yw0-f200.google.com with SMTP id g18so52099232ywb.3
        for <linux-mm@kvack.org>; Thu, 29 Sep 2016 05:08:24 -0700 (PDT)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [58.251.152.64])
        by mx.google.com with ESMTPS id t128si3688861ywe.354.2016.09.29.05.08.22
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 29 Sep 2016 05:08:23 -0700 (PDT)
From: Wei Fang <fangwei1@huawei.com>
Subject: [RFC][PATCH] vfs,mm: fix a dead loop in truncate_inode_pages_range()
Date: Thu, 29 Sep 2016 20:10:10 +0800
Message-ID: <1475151010-40166-1-git-send-email-fangwei1@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: viro@ZenIV.linux.org.uk, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Wei Fang <fangwei1@huawei.com>, stable@vger.kernel.org

We triggered a deadloop in truncate_inode_pages_range() on 32 bits
architecture with the test case bellow:
	...
	fd = open();
	write(fd, buf, 4096);
	preadv64(fd, &iovec, 1, 0xffffffff000);
	ftruncate(fd, 0);
	...
Then ftruncate() will not return forever.

The filesystem used in this case is ubifs, but it can be triggered
on many other filesystems.

When preadv64() is called with offset=0xffffffff000, a page with
index=0xffffffff will be added to the radix tree of ->mapping.
Then this page can be found in ->mapping with pagevec_lookup().
After that, truncate_inode_pages_range(), which is called in
ftruncate(), will fall into an infinite loop:
* find a page with index=0xffffffff, since index>=end, this page
  won't be truncated
* index++, and index become 0
* the page with index=0xffffffff will be found again

The data type of index is unsigned long, so index won't overflow to
0 on 64 bits architecture in this case, and the dead loop won't
happen.

Since truncate_inode_pages_range() is executed with holding lock
of inode->i_rwsem, any operation related with this lock will be
blocked, and a hung task will happen, e.g.:

INFO: task truncate_test:3364 blocked for more than 120 seconds.
...
[<c03c2c44>] call_rwsem_down_write_failed+0x17/0x30
[<c00b93bc>] generic_file_write_iter+0x32/0x1c0
[<c01b7078>] ubifs_write_iter+0xcc/0x170
[<c00fae48>] __vfs_write+0xc4/0x120
[<c00fb784>] vfs_write+0xb2/0x1b0
[<c00fbbe4>] SyS_write+0x46/0xa0

The page with index=0xffffffff added to ->mapping is useless.
Fix this by checking the read position before allocating pages.

Cc: stable@vger.kernel.org
Signed-off-by: Wei Fang <fangwei1@huawei.com>
---
 mm/filemap.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/mm/filemap.c b/mm/filemap.c
index 1345f09..6946346 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1674,6 +1674,10 @@ static ssize_t do_generic_file_read(struct file *filp, loff_t *ppos,
 	unsigned int prev_offset;
 	int error = 0;
 
+	if (unlikely(*ppos >= inode->i_sb->s_maxbytes))
+		return -EINVAL;
+	iov_iter_truncate(iter, inode->i_sb->s_maxbytes);
+
 	index = *ppos >> PAGE_SHIFT;
 	prev_index = ra->prev_pos >> PAGE_SHIFT;
 	prev_offset = ra->prev_pos & (PAGE_SIZE-1);
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
