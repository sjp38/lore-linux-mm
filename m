Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0E99E6B0003
	for <linux-mm@kvack.org>; Mon, 21 May 2018 13:58:48 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id t143-v6so6992075qke.18
        for <linux-mm@kvack.org>; Mon, 21 May 2018 10:58:48 -0700 (PDT)
Received: from mail1.bemta8.messagelabs.com (mail1.bemta8.messagelabs.com. [216.82.243.195])
        by mx.google.com with ESMTPS id y16-v6si144354qvh.46.2018.05.21.10.58.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 May 2018 10:58:47 -0700 (PDT)
From: Huaisheng HS1 Ye <yehs1@lenovo.com>
Subject: [RFC PATCH v2 06/12] drivers/xen/swiotlb-xen: update usage of address
 zone modifiers
Date: Mon, 21 May 2018 17:58:29 +0000
Message-ID: <HK2PR03MB1684F5870EE8D64A2B54635692950@HK2PR03MB1684.apcprd03.prod.outlook.com>
Content-Language: zh-CN
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "willy@infradead.org" <willy@infradead.org>
Cc: "mhocko@suse.com" <mhocko@suse.com>, "vbabka@suse.cz" <vbabka@suse.cz>, "mgorman@techsingularity.net" <mgorman@techsingularity.net>, "kstewart@linuxfoundation.org" <kstewart@linuxfoundation.org>, "alexander.levin@verizon.com" <alexander.levin@verizon.com>, "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>, "colyli@suse.de" <colyli@suse.de>, NingTing Cheng <chengnt@lenovo.com>, Ocean HY1 He <hehy1@lenovo.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "iommu@lists.linux-foundation.org" <iommu@lists.linux-foundation.org>, "xen-devel@lists.xenproject.org" <xen-devel@lists.xenproject.org>, "linux-btrfs@vger.kernel.org" <linux-btrfs@vger.kernel.org>, "hch@lst.de" <hch@lst.de>, "konrad.wilk@oracle.com" <konrad.wilk@oracle.com>"konrad.wilk@oracle.com" <konrad.wilk@oracle.com>, "boris.ostrovsky@oracle.com" <boris.ostrovsky@oracle.com>, "jgross@suse.com" <jgross@suse.com>

Use __GFP_ZONE_MASK to replace (__GFP_DMA | __GFP_HIGHMEM).

In function xen_swiotlb_alloc_coherent, it is obvious that __GFP_DMA32
is not the expecting zone type.

___GFP_DMA, ___GFP_HIGHMEM and ___GFP_DMA32 have been deleted from GFP=20
bitmasks, the bottom three bits of GFP mask is reserved for storing
encoded zone number.
__GFP_DMA, __GFP_HIGHMEM and __GFP_DMA32 should not be operated with
each others by OR.=20

Signed-off-by: Huaisheng Ye <yehs1@lenovo.com>
Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Cc: Boris Ostrovsky <boris.ostrovsky@oracle.com>
Cc: Juergen Gross <jgross@suse.com>
---
 drivers/xen/swiotlb-xen.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/xen/swiotlb-xen.c b/drivers/xen/swiotlb-xen.c
index 5bb72d3..00e8368 100644
--- a/drivers/xen/swiotlb-xen.c
+++ b/drivers/xen/swiotlb-xen.c
@@ -315,7 +315,7 @@ int __ref xen_swiotlb_init(int verbose, bool early)
        * machine physical layout.  We can't allocate highmem
        * because we can't return a pointer to it.=20
        */
-       flags &=3D ~(__GFP_DMA | __GFP_HIGHMEM);
+       flags &=3D ~__GFP_ZONE_MASK;
=20
        /* On ARM this function returns an ioremap'ped virtual address for=
=20
         * which virt_to_phys doesn't return the corresponding physical
--=20
1.8.3.1
