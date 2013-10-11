Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 6C9CD6B0039
	for <linux-mm@kvack.org>; Fri, 11 Oct 2013 05:54:42 -0400 (EDT)
Received: by mail-pd0-f174.google.com with SMTP id y13so3975296pdi.33
        for <linux-mm@kvack.org>; Fri, 11 Oct 2013 02:54:42 -0700 (PDT)
Received: from eucpsbgm1.samsung.com (unknown [203.254.199.244])
 by mailout2.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0MUI005WY0UJ5P20@mailout2.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 11 Oct 2013 10:54:38 +0100 (BST)
From: Krzysztof Kozlowski <k.kozlowski@samsung.com>
Subject: [PATCH] swap: fix set_blocksize race during swapon/swapoff
Date: Fri, 11 Oct 2013 11:54:22 +0200
Message-id: <1381485262-16792-1-git-send-email-k.kozlowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Weijie Yang <weijie.yang.kh@gmail.com>, Bob Liu <bob.liu@oracle.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Shaohua Li <shli@fusionio.com>, Minchan Kim <minchan@kernel.org>, Krzysztof Kozlowski <k.kozlowski@samsung.com>

Swapoff used old_block_size from swap_info which could be overwritten by
concurrent swapon.

Reported-by: Weijie Yang <weijie.yang.kh@gmail.com>
Signed-off-by: Krzysztof Kozlowski <k.kozlowski@samsung.com>
---
 mm/swapfile.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/mm/swapfile.c b/mm/swapfile.c
index 3963fc2..de7c904 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -1824,6 +1824,7 @@ SYSCALL_DEFINE1(swapoff, const char __user *, specialfile)
 	struct filename *pathname;
 	int i, type, prev;
 	int err;
+	unsigned int old_block_size;
 
 	if (!capable(CAP_SYS_ADMIN))
 		return -EPERM;
@@ -1914,6 +1915,7 @@ SYSCALL_DEFINE1(swapoff, const char __user *, specialfile)
 	}
 
 	swap_file = p->swap_file;
+	old_block_size = p->old_block_size;
 	p->swap_file = NULL;
 	p->max = 0;
 	swap_map = p->swap_map;
@@ -1938,7 +1940,7 @@ SYSCALL_DEFINE1(swapoff, const char __user *, specialfile)
 	inode = mapping->host;
 	if (S_ISBLK(inode->i_mode)) {
 		struct block_device *bdev = I_BDEV(inode);
-		set_blocksize(bdev, p->old_block_size);
+		set_blocksize(bdev, old_block_size);
 		blkdev_put(bdev, FMODE_READ | FMODE_WRITE | FMODE_EXCL);
 	} else {
 		mutex_lock(&inode->i_mutex);
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
