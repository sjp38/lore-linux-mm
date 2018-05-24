Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f199.google.com (mail-ot0-f199.google.com [74.125.82.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5F1076B0008
	for <linux-mm@kvack.org>; Thu, 24 May 2018 11:22:35 -0400 (EDT)
Received: by mail-ot0-f199.google.com with SMTP id t1-v6so1133163oth.3
        for <linux-mm@kvack.org>; Thu, 24 May 2018 08:22:35 -0700 (PDT)
Received: from sender-pp-092.zoho.com (sender-pp-092.zoho.com. [135.84.80.237])
        by mx.google.com with ESMTPS id c186-v6si7136297oia.171.2018.05.24.08.22.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 May 2018 08:22:31 -0700 (PDT)
From: Huaisheng Ye <yehs2007@zoho.com>
Subject: [RFC PATCH v3 6/9] mm/vmpressure: update usage of zone modifiers
Date: Thu, 24 May 2018 23:20:53 +0800
Message-Id: <20180524152053.1248-1-yehs2007@zoho.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, linux-mm@kvack.org
Cc: mhocko@suse.com, willy@infradead.org, hch@lst.de, vbabka@suse.cz, mgorman@techsingularity.net, kstewart@linuxfoundation.org, gregkh@linuxfoundation.org, colyli@suse.de, chengnt@lenovo.com, hehy1@lenovo.com, linux-kernel@vger.kernel.org, iommu@lists.linux-foundation.org, xen-devel@lists.xenproject.org, linux-btrfs@vger.kernel.org, Huaisheng Ye <yehs1@lenovo.com>, zhongjiang <zhongjiang@huawei.com>, Minchan Kim <minchan@kernel.org>, Dan Carpenter <dan.carpenter@oracle.com>, David Rientjes <rientjes@google.com>, Christoph Hellwig <hch@infradead.org>

From: Huaisheng Ye <yehs1@lenovo.com>

Use __GFP_ZONE_MOVABLE to replace (__GFP_HIGHMEM | __GFP_MOVABLE).

___GFP_DMA, ___GFP_HIGHMEM and ___GFP_DMA32 have been deleted from GFP
bitmasks, the bottom three bits of GFP mask is reserved for storing
encoded zone number.

__GFP_ZONE_MOVABLE contains encoded ZONE_MOVABLE and __GFP_MOVABLE flag.

With GFP_ZONE_TABLE, __GFP_HIGHMEM ORing __GFP_MOVABLE means gfp_zone
should return ZONE_MOVABLE. In order to keep that compatible with
GFP_ZONE_TABLE, replace (__GFP_HIGHMEM | __GFP_MOVABLE) with
__GFP_ZONE_MOVABLE.

Signed-off-by: Huaisheng Ye <yehs1@lenovo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: zhongjiang <zhongjiang@huawei.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Dan Carpenter <dan.carpenter@oracle.com>
Cc: David Rientjes <rientjes@google.com>
Cc: Christoph Hellwig <hch@infradead.org>
---
 mm/vmpressure.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/vmpressure.c b/mm/vmpressure.c
index 85350ce..30a40e2 100644
--- a/mm/vmpressure.c
+++ b/mm/vmpressure.c
@@ -256,7 +256,7 @@ void vmpressure(gfp_t gfp, struct mem_cgroup *memcg, bool tree,
 	 * Indirect reclaim (kswapd) sets sc->gfp_mask to GFP_KERNEL, so
 	 * we account it too.
 	 */
-	if (!(gfp & (__GFP_HIGHMEM | __GFP_MOVABLE | __GFP_IO | __GFP_FS)))
+	if (!(gfp & (__GFP_ZONE_MOVABLE | __GFP_IO | __GFP_FS)))
 		return;
 
 	/*
-- 
1.8.3.1
