Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 286DB6B0010
	for <linux-mm@kvack.org>; Tue, 17 Apr 2018 22:29:22 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id u11-v6so163500pls.22
        for <linux-mm@kvack.org>; Tue, 17 Apr 2018 19:29:22 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f128sor44105pgc.186.2018.04.17.19.29.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 17 Apr 2018 19:29:20 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH] mm:memcg: add __GFP_NOWARN in __memcg_schedule_kmem_cache_create
Date: Wed, 18 Apr 2018 11:29:12 +0900
Message-Id: <20180418022912.248417-1-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Minchan Kim <minchan@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>

If there are heavy memory pressure, page allocation with __GFP_NOWAIT
fails easily although it's order-0 request.
I got below warning 9 times for normal boot.

[   17.072747] c0 0      <snip >: page allocation failure: order:0, mode:0x2200000(GFP_NOWAIT|__GFP_NOTRACK)
< snip >
[   17.072789] c0 0      Call trace:
[   17.072803] c0 0      [<ffffff8009914da4>] dump_backtrace+0x0/0x4
[   17.072813] c0 0      [<ffffff80086bfb5c>] dump_stack+0xa4/0xc0
[   17.072822] c0 0      [<ffffff800831a4f8>] warn_alloc+0xd4/0x15c
[   17.072829] c0 0      [<ffffff8008318c3c>] __alloc_pages_nodemask+0xf88/0x10fc
[   17.072838] c0 0      [<ffffff8008392b34>] alloc_slab_page+0x40/0x18c
[   17.072843] c0 0      [<ffffff8008392acc>] new_slab+0x2b8/0x2e0
[   17.072849] c0 0      [<ffffff800839220c>] ___slab_alloc+0x25c/0x464
[   17.072858] c0 0      [<ffffff8008393dd0>] __kmalloc+0x394/0x498
[   17.072865] c0 0      [<ffffff80083a658c>] memcg_kmem_get_cache+0x114/0x2b8
[   17.072870] c0 0      [<ffffff8008392f38>] kmem_cache_alloc+0x98/0x3e8
[   17.072878] c0 0      [<ffffff8008370be8>] mmap_region+0x3bc/0x8c0
[   17.072884] c0 0      [<ffffff80083707fc>] do_mmap+0x40c/0x43c
[   17.072890] c0 0      [<ffffff8008343598>] vm_mmap_pgoff+0x15c/0x1e4
[   17.072898] c0 0      [<ffffff800814be28>] sys_mmap+0xb0/0xc8
[   17.072904] c0 0      [<ffffff8008083730>] el0_svc_naked+0x24/0x28
[   17.072908] c0 0      Mem-Info:
[   17.072920] c0 0      active_anon:17124 inactive_anon:193 isolated_anon:0
[   17.072920] c0 0       active_file:7898 inactive_file:712955 isolated_file:55
[   17.072920] c0 0       unevictable:0 dirty:27 writeback:18 unstable:0
[   17.072920] c0 0       slab_reclaimable:12250 slab_unreclaimable:23334
[   17.072920] c0 0       mapped:19310 shmem:212 pagetables:816 bounce:0
[   17.072920] c0 0       free:36561 free_pcp:1205 free_cma:35615
[   17.072933] c0 0      Node 0 active_anon:68496kB inactive_anon:772kB active_file:31592kB inactive_file:2851820kB unevictable:0kB isolated(anon):0kB isolated(file):220kB mapped:77240kB dirty:108kB writeback:72kB shmem:848kB writeback_tmp:0kB unstable:0kB all_unreclaimable? no
[   17.072945] c0 0      DMA free:142188kB min:3056kB low:3820kB high:4584kB active_anon:10052kB inactive_anon:12kB active_file:312kB inactive_file:1412620kB unevictable:0kB writepending:0kB present:1781412kB managed:1604728kB mlocked:0kB slab_reclaimable:3592kB slab_unreclaimable:876kB kernel_stack:400kB pagetables:52kB bounce:0kB free_pcp:1436kB local_pcp:124kB free_cma:142492kB
[   17.072949] c0 0      lowmem_reserve[]: 0 1842 1842
[   17.072966] c0 0      Normal free:4056kB min:4172kB low:5212kB high:6252kB active_anon:58376kB inactive_anon:760kB active_file:31348kB inactive_file:1439040kB unevictable:0kB writepending:180kB present:2000636kB managed:1923688kB mlocked:0kB slab_reclaimable:45408kB slab_unreclaimable:92460kB kernel_stack:9680kB pagetables:3212kB bounce:0kB free_pcp:3392kB local_pcp:688kB free_cma:0kB
[   17.072971] c0 0      lowmem_reserve[]: 0 0 0
[   17.072982] c0 0      DMA: 0*4kB 0*8kB 1*16kB (C) 0*32kB 0*64kB 0*128kB 1*256kB (C) 1*512kB (C) 0*1024kB 1*2048kB (C) 34*4096kB (C) = 142096kB
[   17.073024] c0 0      Normal: 228*4kB (UMEH) 172*8kB (UMH) 23*16kB (UH) 24*32kB (H) 5*64kB (H) 1*128kB (H) 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 3872kB
[   17.073069] c0 0      721350 total pagecache pages
[   17.073073] c0 0      0 pages in swap cache
[   17.073078] c0 0      Swap cache stats: add 0, delete 0, find 0/0
[   17.073081] c0 0      Free swap  = 0kB
[   17.073085] c0 0      Total swap = 0kB
[   17.073089] c0 0      945512 pages RAM
[   17.073093] c0 0      0 pages HighMem/MovableOnly
[   17.073097] c0 0      63408 pages reserved
[   17.073100] c0 0      51200 pages cma reserved

Let's not make user scared.

Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 mm/memcontrol.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 448db08d97a0..671d07e73a3b 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2200,7 +2200,7 @@ static void __memcg_schedule_kmem_cache_create(struct mem_cgroup *memcg,
 {
 	struct memcg_kmem_cache_create_work *cw;
 
-	cw = kmalloc(sizeof(*cw), GFP_NOWAIT);
+	cw = kmalloc(sizeof(*cw), GFP_NOWAIT | __GFP_NOWARN);
 	if (!cw)
 		return;
 
-- 
2.17.0.484.g0c8726318c-goog
