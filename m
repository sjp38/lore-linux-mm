Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 645A06B0261
	for <linux-mm@kvack.org>; Wed, 27 Sep 2017 04:21:08 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id j50so1169595wra.4
        for <linux-mm@kvack.org>; Wed, 27 Sep 2017 01:21:08 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i26si3076456wmb.174.2017.09.27.01.21.07
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 27 Sep 2017 01:21:07 -0700 (PDT)
From: Johannes Thumshirn <jthumshirn@suse.de>
Subject: [PATCH 4/6] IB/rdmavt: use kmalloc_array_node
Date: Wed, 27 Sep 2017 10:20:36 +0200
Message-Id: <20170927082038.3782-5-jthumshirn@suse.de>
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
 drivers/infiniband/sw/rdmavt/qp.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/infiniband/sw/rdmavt/qp.c b/drivers/infiniband/sw/rdmavt/qp.c
index 22df09ae809e..b8e904905f47 100644
--- a/drivers/infiniband/sw/rdmavt/qp.c
+++ b/drivers/infiniband/sw/rdmavt/qp.c
@@ -238,7 +238,7 @@ int rvt_driver_qp_init(struct rvt_dev_info *rdi)
 	rdi->qp_dev->qp_table_size = rdi->dparms.qp_table_size;
 	rdi->qp_dev->qp_table_bits = ilog2(rdi->dparms.qp_table_size);
 	rdi->qp_dev->qp_table =
-		kmalloc_node(rdi->qp_dev->qp_table_size *
+		kmalloc_array_node(rdi->qp_dev->qp_table_size,
 			     sizeof(*rdi->qp_dev->qp_table),
 			     GFP_KERNEL, rdi->dparms.node);
 	if (!rdi->qp_dev->qp_table)
-- 
2.13.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
