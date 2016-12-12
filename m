Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1010C6B0038
	for <linux-mm@kvack.org>; Mon, 12 Dec 2016 00:59:12 -0500 (EST)
Received: by mail-qt0-f198.google.com with SMTP id 41so61023841qtn.7
        for <linux-mm@kvack.org>; Sun, 11 Dec 2016 21:59:12 -0800 (PST)
Received: from mail-qt0-x241.google.com (mail-qt0-x241.google.com. [2607:f8b0:400d:c0d::241])
        by mx.google.com with ESMTPS id k6si25634161qkf.38.2016.12.11.21.59.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 11 Dec 2016 21:59:11 -0800 (PST)
Received: by mail-qt0-x241.google.com with SMTP id n34so8610297qtb.3
        for <linux-mm@kvack.org>; Sun, 11 Dec 2016 21:59:11 -0800 (PST)
From: Jia He <hejianet@gmail.com>
Subject: [PATCH RFC 0/1] mm, page_alloc: fix incorrect zone_statistics data
Date: Mon, 12 Dec 2016 13:59:06 +0800
Message-Id: <1481522347-20393-1-git-send-email-hejianet@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Taku Izumi <izumi.taku@jp.fujitsu.com>, Jia He <hejianet@gmail.com>


In commit b9f00e147f27 ("mm, page_alloc: reduce branches in
zone_statistics"), it reconstructed the code to reduce the branch miss rate.
Compared with the original logic, it assumed if !(flag & __GFP_OTHER_NODE)
 z->node would not be equal to preferred_zone->node. That seems to be
incorrect.

Here is what I catch, dumpstack() is triggered when z->node ==
preferred_zone->node and z->node != numa_node_id()

z=5,prefer=5,local=4, flag&OTHER_NODE=0
[c000000cdcaef440] [c0000000002e88cc] cache_grow_begin+0xcc/0x500
[c000000cdcaef6f0] [c0000000002ecb44] do_tune_cpucache+0x64/0x100
[c000000cdcaef750] [c0000000002ecc7c] enable_cpucache+0x9c/0x180
[c000000cdcaef7d0] [c0000000002ed01c] __kmem_cache_create+0x1ec/00x2c0
[c000000cdcaef820] [c000000000291c98] create_cache+0xb8/0x240
[c000000cdcaef890] [c000000000291fa8] kmem_cache_create+0x188/0x2290
[c000000cdcaef950] [d000000011dc5c70] ext4_mb_init+0x3c0/0x5e0 [eext4]
[c000000cdcaef9f0] [d000000011daaedc] ext4_fill_super+0x266c/0x33390 [ext4]
[c000000cdcaefb30] [c000000000328b8c] mount_bdev+0x22c/0x260
[c000000cdcaefbd0] [d000000011da1fa8] ext4_mount+0x48/0x60 [ext4]
[c000000cdcaefc10] [c00000000032a11c] mount_fs+0x8c/0x230
[c000000cdcaefcb0] [c000000000351f98] vfs_kern_mount+0x78/0x180
[c000000cdcaefd00] [c000000000356d68] do_mount+0x258/0xea0
[c000000cdcaefde0] [c000000000357da0] SyS_mount+0xa0/0x110
[c000000cdcaefe30] [c00000000000bd84] system_call+0x38/0xe0

Before this patch, the numa_miss and numa_foreign looked very odd:
linux:~ # numastat
                           node0           node1           node2           node3           node4           node5           node6
numa_hit                   42216               0               0               0           96755               0               0
numa_miss                      1             718             711             726             860             712             719
numa_foreign                   1             718             711             726             860             712             719
interleave_hit               631             638             632             641             621             633             636
local_node                 42216               0               0               0           96755               0               0
other_node                     0               0               0               0               0               0               0

After this patch
linux:~ # numastat  
                           node0           node1           node2           node3           node4           node5           node6
numa_hit                  177891             718             711             726           60302             712             719
numa_miss                      0          196944          237222          253424               0           36265               0
numa_foreign              723855               0               0               0               0               0               0
interleave_hit               631             638             632             641             621             633             636
local_node                177891               0               0               0           59444               0               0
other_node                     0             718             711             726             858             712             719
Jia He (1):
  mm, page_alloc: fix incorrect zone_statistics data

 mm/page_alloc.c | 3 +++
 1 file changed, 3 insertions(+)

-- 
2.5.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
