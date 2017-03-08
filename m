Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 544846B0388
	for <linux-mm@kvack.org>; Tue,  7 Mar 2017 21:06:27 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id e5so34714899pgk.1
        for <linux-mm@kvack.org>; Tue, 07 Mar 2017 18:06:27 -0800 (PST)
Received: from dggrg02-dlp.huawei.com ([45.249.212.188])
        by mx.google.com with ESMTPS id s81si1701309pgs.29.2017.03.07.18.06.25
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 07 Mar 2017 18:06:26 -0800 (PST)
From: <zhouxianrong@huawei.com>
Subject: [PATCH] compaction: add def_blk_aops migrate function for memory compaction
Date: Wed, 8 Mar 2017 09:51:55 +0800
Message-ID: <1488937915-78955-1-git-send-email-zhouxianrong@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, hannes@cmpxchg.org, minchan@kernel.org, mgorman@techsingularity.net, vbabka@suse.cz, viro@zeniv.linux.org.uk, Mi.Sophia.Wang@huawei.com, zhouxianrong@huawei.com, zhouxiyu@huawei.com, weidu.du@huawei.com, zhangshiming5@huawei.com, won.ho.park@huawei.com, zhouxiaoyan1@huawei.com

From: zhouxianrong <zhouxianrong@huawei.com>

the reason for why to do this is based on below factors.

1. larg file read/write operations with order 0 can fragmentize
   memory rapidly.

2. when a special filesystem does not supply migratepage callback,
   kernel would fallback to default function fallback_migrate_page.
   but fallback_migrate_page could not migrate diry page nicely;
   specially kcompactd with MIGRATE_SYNC_LIGHT could not migrate
   diry pages due to this until clear_page_dirty_for_io in some
   procedure. i think it is not suitable here in this scenario.
   for dirty pages we should migrate it rather than skip or writeout
   it in kcomapctd with MIGRATE_SYNC_LIGHT. i think this problem is
   for all filesystem without migratepage not only for block device fs. 
   
so for compaction under large file writing supply migratepage for
def_blk_aops.

Signed-off-by: zhouxianrong <zhouxianrong@huawei.com>
---
 fs/block_dev.c |    3 +++
 1 file changed, 3 insertions(+)

diff --git a/fs/block_dev.c b/fs/block_dev.c
index 1c62845..9343b60 100644
--- a/fs/block_dev.c
+++ b/fs/block_dev.c
@@ -2062,6 +2062,9 @@ static int blkdev_writepages(struct address_space *mapping,
 	.releasepage	= blkdev_releasepage,
 	.direct_IO	= blkdev_direct_IO,
 	.is_dirty_writeback = buffer_check_dirty_writeback,
+#ifdef CONFIG_MIGRATION
+	.migratepage = buffer_migrate_page,
+#endif
 };
 
 #define	BLKDEV_FALLOC_FL_SUPPORTED					\
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
