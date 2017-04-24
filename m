Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id DB00F6B02F2
	for <linux-mm@kvack.org>; Mon, 24 Apr 2017 12:40:34 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id v1so5438332pgv.8
        for <linux-mm@kvack.org>; Mon, 24 Apr 2017 09:40:34 -0700 (PDT)
Received: from EUR03-VE1-obe.outbound.protection.outlook.com (mail-eopbgr50128.outbound.protection.outlook.com. [40.107.5.128])
        by mx.google.com with ESMTPS id s67si19615925pfj.268.2017.04.24.09.40.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 24 Apr 2017 09:40:34 -0700 (PDT)
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Subject: [PATCH v2 3/4] mm/truncate: bail out early from invalidate_inode_pages2_range() if mapping is empty
Date: Mon, 24 Apr 2017 19:41:34 +0300
Message-ID: <20170424164135.22350-4-aryabinin@virtuozzo.com>
In-Reply-To: <20170424164135.22350-1-aryabinin@virtuozzo.com>
References: <20170414140753.16108-1-aryabinin@virtuozzo.com>
 <20170424164135.22350-1-aryabinin@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Viro <viro@zeniv.linux.org.uk>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Jens Axboe <axboe@kernel.dk>, Johannes Weiner <hannes@cmpxchg.org>, Alexey Kuznetsov <kuznet@virtuozzo.com>, Christoph Hellwig <hch@lst.de>, Nikolay Borisov <n.borisov.lkml@gmail.com>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

If mapping is empty (both ->nrpages and ->nrexceptional is zero) we can
avoid pointless lookups in empty radix tree and bail out immediately after
cleancache invalidation.

Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
Acked-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
---
 mm/truncate.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/mm/truncate.c b/mm/truncate.c
index 6263aff..8f12b0e 100644
--- a/mm/truncate.c
+++ b/mm/truncate.c
@@ -624,6 +624,9 @@ int invalidate_inode_pages2_range(struct address_space *mapping,
 	int did_range_unmap = 0;
 
 	cleancache_invalidate_inode(mapping);
+	if (mapping->nrpages == 0 && mapping->nrexceptional == 0)
+		return 0;
+
 	pagevec_init(&pvec, 0);
 	index = start;
 	while (index <= end && pagevec_lookup_entries(&pvec, mapping, index,
-- 
2.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
