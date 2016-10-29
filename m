Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id E2E266B028D
	for <linux-mm@kvack.org>; Sat, 29 Oct 2016 02:11:29 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id rf5so56633505pab.3
        for <linux-mm@kvack.org>; Fri, 28 Oct 2016 23:11:29 -0700 (PDT)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTPS id a65si16381204pfb.18.2016.10.28.23.11.28
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 28 Oct 2016 23:11:28 -0700 (PDT)
From: zhongjiang <zhongjiang@huawei.com>
Subject: [RFC PATCH] hugetlbfs: fix the hugetlbfs can not be mounted
Date: Sat, 29 Oct 2016 14:08:31 +0800
Message-ID: <1477721311-54522-1-git-send-email-zhongjiang@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: nyc@holomorphy.com, n-horiguchi@ah.jp.nec.com, mike.kravetz@oracle.com, rientjes@google.com, hillf.zj@alibaba-inc.com, akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

From: zhong jiang <zhongjiang@huawei.com>

Since 'commit 3e89e1c5ea84 ("hugetlb: make mm and fs code explicitly non-modular")'
bring in the mainline. mount hugetlbfs will result in the following issue.

mount: unknown filesystme type 'hugetlbfs'

because previous patch remove the module_alias_fs, when we mount the fs type,
the caller get_fs_type can not find the filesystem.

The patch just recover the module_alias_fs to identify the hugetlbfs.

Signed-off-by: zhong jiang <zhongjiang@huawei.com>
---
 fs/hugetlbfs/inode.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index 4fb7b10..b63e7de 100644
--- a/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
@@ -35,6 +35,7 @@
 #include <linux/security.h>
 #include <linux/magic.h>
 #include <linux/migrate.h>
+#include <linux/module.h>
 #include <linux/uio.h>
 
 #include <asm/uaccess.h>
@@ -1209,6 +1210,7 @@ static struct dentry *hugetlbfs_mount(struct file_system_type *fs_type,
 	.mount		= hugetlbfs_mount,
 	.kill_sb	= kill_litter_super,
 };
+MODULE_ALIAS_FS("hugetlbfs");
 
 static struct vfsmount *hugetlbfs_vfsmount[HUGE_MAX_HSTATE];
 
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
