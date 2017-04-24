Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 885566B02EE
	for <linux-mm@kvack.org>; Mon, 24 Apr 2017 12:40:31 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id j16so14826211pfk.4
        for <linux-mm@kvack.org>; Mon, 24 Apr 2017 09:40:31 -0700 (PDT)
Received: from EUR03-VE1-obe.outbound.protection.outlook.com (mail-eopbgr50117.outbound.protection.outlook.com. [40.107.5.117])
        by mx.google.com with ESMTPS id 61si19620302plz.198.2017.04.24.09.40.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 24 Apr 2017 09:40:30 -0700 (PDT)
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Subject: [PATCH v2 2/4] fs/block_dev: always invalidate cleancache in invalidate_bdev()
Date: Mon, 24 Apr 2017 19:41:33 +0300
Message-ID: <20170424164135.22350-3-aryabinin@virtuozzo.com>
In-Reply-To: <20170424164135.22350-1-aryabinin@virtuozzo.com>
References: <20170414140753.16108-1-aryabinin@virtuozzo.com>
 <20170424164135.22350-1-aryabinin@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Viro <viro@zeniv.linux.org.uk>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, stable@vger.kernel.org, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Jens Axboe <axboe@kernel.dk>, Johannes Weiner <hannes@cmpxchg.org>, Alexey Kuznetsov <kuznet@virtuozzo.com>, Christoph Hellwig <hch@lst.de>, Nikolay Borisov <n.borisov.lkml@gmail.com>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

invalidate_bdev() calls cleancache_invalidate_inode() iff ->nrpages != 0
which doen't make any sense.
Make sure that invalidate_bdev() always calls cleancache_invalidate_inode()
regardless of mapping->nrpages value.

Fixes: c515e1fd361c ("mm/fs: add hooks to support cleancache")
Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
Acked-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Cc: <stable@vger.kernel.org>
---
 fs/block_dev.c | 11 +++++------
 1 file changed, 5 insertions(+), 6 deletions(-)

diff --git a/fs/block_dev.c b/fs/block_dev.c
index 065d7c5..f625dce 100644
--- a/fs/block_dev.c
+++ b/fs/block_dev.c
@@ -104,12 +104,11 @@ void invalidate_bdev(struct block_device *bdev)
 {
 	struct address_space *mapping = bdev->bd_inode->i_mapping;
 
-	if (mapping->nrpages == 0)
-		return;
-
-	invalidate_bh_lrus();
-	lru_add_drain_all();	/* make sure all lru add caches are flushed */
-	invalidate_mapping_pages(mapping, 0, -1);
+	if (mapping->nrpages) {
+		invalidate_bh_lrus();
+		lru_add_drain_all();	/* make sure all lru add caches are flushed */
+		invalidate_mapping_pages(mapping, 0, -1);
+	}
 	/* 99% of the time, we don't need to flush the cleancache on the bdev.
 	 * But, for the strange corners, lets be cautious
 	 */
-- 
2.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
