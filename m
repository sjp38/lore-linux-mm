Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5BF3C6B0260
	for <linux-mm@kvack.org>; Wed, 27 Sep 2017 04:21:06 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id b195so13639848wmb.6
        for <linux-mm@kvack.org>; Wed, 27 Sep 2017 01:21:06 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f81si3200766wmh.41.2017.09.27.01.21.05
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 27 Sep 2017 01:21:05 -0700 (PDT)
From: Johannes Thumshirn <jthumshirn@suse.de>
Subject: [PATCH 3/6] IB/qib: use kmalloc_array_node
Date: Wed, 27 Sep 2017 10:20:35 +0200
Message-Id: <20170927082038.3782-4-jthumshirn@suse.de>
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
 drivers/infiniband/hw/qib/qib_init.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/infiniband/hw/qib/qib_init.c b/drivers/infiniband/hw/qib/qib_init.c
index c5a4c65636d6..6aebf4e707b9 100644
--- a/drivers/infiniband/hw/qib/qib_init.c
+++ b/drivers/infiniband/hw/qib/qib_init.c
@@ -1674,8 +1674,9 @@ int qib_setup_eagerbufs(struct qib_ctxtdata *rcd)
 	}
 	if (!rcd->rcvegrbuf_phys) {
 		rcd->rcvegrbuf_phys =
-			kmalloc_node(chunk * sizeof(rcd->rcvegrbuf_phys[0]),
-				GFP_KERNEL, rcd->node_id);
+			kmalloc_array_node(chunk,
+					   sizeof(rcd->rcvegrbuf_phys[0]),
+					   GFP_KERNEL, rcd->node_id);
 		if (!rcd->rcvegrbuf_phys)
 			goto bail_rcvegrbuf;
 	}
-- 
2.13.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
