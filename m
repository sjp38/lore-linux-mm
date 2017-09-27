Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 19F146B026A
	for <linux-mm@kvack.org>; Wed, 27 Sep 2017 04:21:13 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id i131so13648473wma.1
        for <linux-mm@kvack.org>; Wed, 27 Sep 2017 01:21:13 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h189si3012137wmf.89.2017.09.27.01.21.11
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 27 Sep 2017 01:21:12 -0700 (PDT)
From: Johannes Thumshirn <jthumshirn@suse.de>
Subject: [PATCH 6/6] rds: ib: use kmalloc_array_node
Date: Wed, 27 Sep 2017 10:20:38 +0200
Message-Id: <20170927082038.3782-7-jthumshirn@suse.de>
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
 net/rds/ib_fmr.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/rds/ib_fmr.c b/net/rds/ib_fmr.c
index 86ef907067bb..e0f70c4051b6 100644
--- a/net/rds/ib_fmr.c
+++ b/net/rds/ib_fmr.c
@@ -139,8 +139,8 @@ static int rds_ib_map_fmr(struct rds_ib_device *rds_ibdev,
 		return -EINVAL;
 	}
 
-	dma_pages = kmalloc_node(sizeof(u64) * page_cnt, GFP_ATOMIC,
-				 rdsibdev_to_node(rds_ibdev));
+	dma_pages = kmalloc_array_node(sizeof(u64), page_cnt, GFP_ATOMIC,
+				       rdsibdev_to_node(rds_ibdev));
 	if (!dma_pages) {
 		ib_dma_unmap_sg(dev, sg, nents, DMA_BIDIRECTIONAL);
 		return -ENOMEM;
-- 
2.13.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
