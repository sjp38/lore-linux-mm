Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 77C106B02F4
	for <linux-mm@kvack.org>; Mon, 24 Apr 2017 12:40:35 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id p21so16369464pgc.21
        for <linux-mm@kvack.org>; Mon, 24 Apr 2017 09:40:35 -0700 (PDT)
Received: from EUR03-VE1-obe.outbound.protection.outlook.com (mail-eopbgr50128.outbound.protection.outlook.com. [40.107.5.128])
        by mx.google.com with ESMTPS id s67si19615925pfj.268.2017.04.24.09.40.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 24 Apr 2017 09:40:34 -0700 (PDT)
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Subject: [PATCH v2 4/4] mm/truncate: avoid pointless cleancache_invalidate_inode() calls.
Date: Mon, 24 Apr 2017 19:41:35 +0300
Message-ID: <20170424164135.22350-5-aryabinin@virtuozzo.com>
In-Reply-To: <20170424164135.22350-1-aryabinin@virtuozzo.com>
References: <20170414140753.16108-1-aryabinin@virtuozzo.com>
 <20170424164135.22350-1-aryabinin@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Viro <viro@zeniv.linux.org.uk>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Jens Axboe <axboe@kernel.dk>, Johannes Weiner <hannes@cmpxchg.org>, Alexey Kuznetsov <kuznet@virtuozzo.com>, Christoph Hellwig <hch@lst.de>, Nikolay Borisov <n.borisov.lkml@gmail.com>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

cleancache_invalidate_inode() called truncate_inode_pages_range()
and invalidate_inode_pages2_range() twice - on entry and on exit.
It's stupid and waste of time. It's enough to call it once at
exit.

Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
Acked-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
---
 mm/truncate.c | 12 +++++++-----
 1 file changed, 7 insertions(+), 5 deletions(-)

diff --git a/mm/truncate.c b/mm/truncate.c
index 8f12b0e..83a059e 100644
--- a/mm/truncate.c
+++ b/mm/truncate.c
@@ -266,9 +266,8 @@ void truncate_inode_pages_range(struct address_space *mapping,
 	pgoff_t		index;
 	int		i;
 
-	cleancache_invalidate_inode(mapping);
 	if (mapping->nrpages == 0 && mapping->nrexceptional == 0)
-		return;
+		goto out;
 
 	/* Offsets within partial pages */
 	partial_start = lstart & (PAGE_SIZE - 1);
@@ -363,7 +362,7 @@ void truncate_inode_pages_range(struct address_space *mapping,
 	 * will be released, just zeroed, so we can bail out now.
 	 */
 	if (start >= end)
-		return;
+		goto out;
 
 	index = start;
 	for ( ; ; ) {
@@ -410,6 +409,8 @@ void truncate_inode_pages_range(struct address_space *mapping,
 		pagevec_release(&pvec);
 		index++;
 	}
+
+out:
 	cleancache_invalidate_inode(mapping);
 }
 EXPORT_SYMBOL(truncate_inode_pages_range);
@@ -623,9 +624,8 @@ int invalidate_inode_pages2_range(struct address_space *mapping,
 	int ret2 = 0;
 	int did_range_unmap = 0;
 
-	cleancache_invalidate_inode(mapping);
 	if (mapping->nrpages == 0 && mapping->nrexceptional == 0)
-		return 0;
+		goto out;
 
 	pagevec_init(&pvec, 0);
 	index = start;
@@ -689,6 +689,8 @@ int invalidate_inode_pages2_range(struct address_space *mapping,
 		cond_resched();
 		index++;
 	}
+
+out:
 	cleancache_invalidate_inode(mapping);
 	return ret;
 }
-- 
2.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
