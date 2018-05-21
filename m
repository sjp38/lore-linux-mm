Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id A88966B0003
	for <linux-mm@kvack.org>; Mon, 21 May 2018 14:02:01 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id s2-v6so12596809ioa.22
        for <linux-mm@kvack.org>; Mon, 21 May 2018 11:02:01 -0700 (PDT)
Received: from mail1.bemta12.messagelabs.com (mail1.bemta12.messagelabs.com. [216.82.251.16])
        by mx.google.com with ESMTPS id 67-v6si12888610itu.92.2018.05.21.11.02.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 May 2018 11:02:00 -0700 (PDT)
From: Huaisheng HS1 Ye <yehs1@lenovo.com>
Subject: [RFC PATCH v2 07/12] fs/btrfs/extent_io: update usage of address zone
 modifiers
Date: Mon, 21 May 2018 18:01:36 +0000
Message-ID: <HK2PR03MB16848D9371E00E9029FCC94092950@HK2PR03MB1684.apcprd03.prod.outlook.com>
Content-Language: zh-CN
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "willy@infradead.org" <willy@infradead.org>
Cc: "mhocko@suse.com" <mhocko@suse.com>, "vbabka@suse.cz" <vbabka@suse.cz>, "mgorman@techsingularity.net" <mgorman@techsingularity.net>, "kstewart@linuxfoundation.org" <kstewart@linuxfoundation.org>, "alexander.levin@verizon.com" <alexander.levin@verizon.com>, "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>, "colyli@suse.de" <colyli@suse.de>, NingTing Cheng <chengnt@lenovo.com>, Ocean HY1 He <hehy1@lenovo.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "iommu@lists.linux-foundation.org" <iommu@lists.linux-foundation.org>, "xen-devel@lists.xenproject.org" <xen-devel@lists.xenproject.org>, "linux-btrfs@vger.kernel.org" <linux-btrfs@vger.kernel.org>, "hch@lst.de" <hch@lst.de>, "clm@fb.com" <clm@fb.com>, "jbacik@fb.com" <jbacik@fb.com>, "dsterba@suse.com" <dsterba@suse.com>

Use __GFP_ZONE_MASK to replace (__GFP_DMA32 | __GFP_HIGHMEM).

In function alloc_extent_state, it is obvious that __GFP_DMA is not=20
the expecting zone type.

___GFP_DMA, ___GFP_HIGHMEM and ___GFP_DMA32 have been deleted from GFP=20
bitmasks, the bottom three bits of GFP mask is reserved for storing
encoded zone number.
__GFP_DMA, __GFP_HIGHMEM and __GFP_DMA32 should not be operated with
each others by OR.=20

Signed-off-by: Huaisheng Ye <yehs1@lenovo.com>
Cc: Chris Mason <clm@fb.com>
Cc: Josef Bacik <jbacik@fb.com>
Cc: David Sterba <dsterba@suse.com>
---
 fs/btrfs/extent_io.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/btrfs/extent_io.c b/fs/btrfs/extent_io.c
index dfeb74a..6653e9a 100644
--- a/fs/btrfs/extent_io.c
+++ b/fs/btrfs/extent_io.c
@@ -220,7 +220,7 @@ static struct extent_state *alloc_extent_state(gfp_t ma=
sk)
         * The given mask might be not appropriate for the slab allocator,
         * drop the unsupported bits
         */
-       mask &=3D ~(__GFP_DMA32|__GFP_HIGHMEM);
+       mask &=3D ~__GFP_ZONE_MASK;
        state =3D kmem_cache_alloc(extent_state_cache, mask);
        if (!state)
                return state;
--=20
1.8.3.1
