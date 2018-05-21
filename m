Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id A7EA56B0003
	for <linux-mm@kvack.org>; Mon, 21 May 2018 14:04:01 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id r140-v6so12652833iod.16
        for <linux-mm@kvack.org>; Mon, 21 May 2018 11:04:01 -0700 (PDT)
Received: from mail1.bemta12.messagelabs.com (mail1.bemta12.messagelabs.com. [216.82.251.4])
        by mx.google.com with ESMTPS id u188-v6si13062147ioe.98.2018.05.21.11.04.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 May 2018 11:04:00 -0700 (PDT)
From: Huaisheng HS1 Ye <yehs1@lenovo.com>
Subject: [RFC PATCH v2 08/12] drivers/block/zram/zram_drv: update usage of
 address zone modifiers
Date: Mon, 21 May 2018 18:03:38 +0000
Message-ID: <HK2PR03MB16847B9F373C3782466F724192950@HK2PR03MB1684.apcprd03.prod.outlook.com>
Content-Language: zh-CN
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "willy@infradead.org" <willy@infradead.org>
Cc: "mhocko@suse.com" <mhocko@suse.com>, "vbabka@suse.cz" <vbabka@suse.cz>, "mgorman@techsingularity.net" <mgorman@techsingularity.net>, "kstewart@linuxfoundation.org" <kstewart@linuxfoundation.org>, "alexander.levin@verizon.com" <alexander.levin@verizon.com>, "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>, "colyli@suse.de" <colyli@suse.de>, NingTing Cheng <chengnt@lenovo.com>, Ocean HY1 He <hehy1@lenovo.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "iommu@lists.linux-foundation.org" <iommu@lists.linux-foundation.org>, "xen-devel@lists.xenproject.org" <xen-devel@lists.xenproject.org>, "linux-btrfs@vger.kernel.org" <linux-btrfs@vger.kernel.org>, "hch@lst.de" <hch@lst.de>, "minchan@kernel.org" <minchan@kernel.org>, "ngupta@vflare.org" <ngupta@vflare.org>, "sergey.senozhatsky.work@gmail.com" <sergey.senozhatsky.work@gmail.com>

Use __GFP_ZONE_MOVABLE to replace (__GFP_HIGHMEM | __GFP_MOVABLE).

___GFP_DMA, ___GFP_HIGHMEM and ___GFP_DMA32 have been deleted from GFP=20
bitmasks, the bottom three bits of GFP mask is reserved for storing
encoded zone number.

__GFP_ZONE_MOVABLE contains encoded ZONE_MOVABLE and __GFP_MOVABLE flag.

With GFP_ZONE_TABLE, __GFP_HIGHMEM ORing __GFP_MOVABLE means gfp_zone
should return ZONE_MOVABLE. In order to keep that compatible with
GFP_ZONE_TABLE, replace (__GFP_HIGHMEM | __GFP_MOVABLE) with
__GFP_ZONE_MOVABLE.

Signed-off-by: Huaisheng Ye <yehs1@lenovo.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Nitin Gupta <ngupta@vflare.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
---
 drivers/block/zram/zram_drv.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/block/zram/zram_drv.c b/drivers/block/zram/zram_drv.c
index 0afa6c8..39cb7d6 100644
--- a/drivers/block/zram/zram_drv.c
+++ b/drivers/block/zram/zram_drv.c
@@ -997,14 +997,12 @@ static int __zram_bvec_write(struct zram *zram, struc=
t bio_vec *bvec,
                handle =3D zs_malloc(zram->mem_pool, comp_len,
                                __GFP_KSWAPD_RECLAIM |=20
                                __GFP_NOWARN |
-                               __GFP_HIGHMEM |
-                               __GFP_MOVABLE);
+                               __GFP_ZONE_MOVABLE);
        if (!handle) {
                zcomp_stream_put(zram->comp);
                atomic64_inc(&zram->stats.writestall);
                handle =3D zs_malloc(zram->mem_pool, comp_len,
-                               GFP_NOIO | __GFP_HIGHMEM |
-                               __GFP_MOVABLE);
+                               GFP_NOIO | __GFP_ZONE_MOVABLE);
                if (handle)
                        goto compress_again;
                return -ENOMEM;
--=20
1.8.3.1
