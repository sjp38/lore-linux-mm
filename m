Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id EBB646B025F
	for <linux-mm@kvack.org>; Wed, 27 Sep 2017 04:21:00 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id b9so14760140wra.3
        for <linux-mm@kvack.org>; Wed, 27 Sep 2017 01:21:00 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r1si8859615wre.56.2017.09.27.01.20.59
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 27 Sep 2017 01:20:59 -0700 (PDT)
From: Johannes Thumshirn <jthumshirn@suse.de>
Subject: [PATCH 2/6] block: use kmalloc_array_node
Date: Wed, 27 Sep 2017 10:20:34 +0200
Message-Id: <20170927082038.3782-3-jthumshirn@suse.de>
In-Reply-To: <20170927082038.3782-1-jthumshirn@suse.de>
References: <20170927082038.3782-1-jthumshirn@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Damien Le Moal <damien.lemoal@wdc.com>, Christoph Hellwig <hch@lst.de>, Johannes Thumshirn <jthumshirn@suse.de>

Now that we have a NUMA-aware version of kmalloc_array() we can use it
instead of kmalloc_node() without an overflow check in the size
calculation.

Signed-off-by: Johannes Thumshirn <jthumshirn@suse.de>
---
 block/blk-mq.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/block/blk-mq.c b/block/blk-mq.c
index 98a18609755e..49f9dc0eb47c 100644
--- a/block/blk-mq.c
+++ b/block/blk-mq.c
@@ -1979,7 +1979,7 @@ static int blk_mq_init_hctx(struct request_queue *q,
 	 * Allocate space for all possible cpus to avoid allocation at
 	 * runtime
 	 */
-	hctx->ctxs = kmalloc_node(nr_cpu_ids * sizeof(void *),
+	hctx->ctxs = kmalloc_array_node(nr_cpu_ids, sizeof(void *),
 					GFP_KERNEL, node);
 	if (!hctx->ctxs)
 		goto unregister_cpu_notifier;
-- 
2.13.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
