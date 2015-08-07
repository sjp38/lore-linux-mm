Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 30BCE6B0259
	for <linux-mm@kvack.org>; Thu,  6 Aug 2015 22:10:21 -0400 (EDT)
Received: by pacrr5 with SMTP id rr5so40656366pac.3
        for <linux-mm@kvack.org>; Thu, 06 Aug 2015 19:10:20 -0700 (PDT)
Received: from mail-pa0-x232.google.com (mail-pa0-x232.google.com. [2607:f8b0:400e:c03::232])
        by mx.google.com with ESMTPS id v8si14806162pds.131.2015.08.06.19.10.19
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Aug 2015 19:10:19 -0700 (PDT)
Received: by pabyb7 with SMTP id yb7so43822971pab.0
        for <linux-mm@kvack.org>; Thu, 06 Aug 2015 19:10:19 -0700 (PDT)
From: Joonsoo Kim <js1304@gmail.com>
Subject: [PATCH v2] mm/slub: don't wait for high-order page allocation
Date: Fri,  7 Aug 2015 11:10:03 +0900
Message-Id: <1438913403-3682-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Shaohua Li <shli@fb.com>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.cz>, Eric Dumazet <edumazet@google.com>

Almost description is copied from commit fb05e7a89f50
("net: don't wait for order-3 page allocation").

I saw excessive direct memory reclaim/compaction triggered by slub.
This causes performance issues and add latency. Slub uses high-order
allocation to reduce internal fragmentation and management overhead. But,
direct memory reclaim/compaction has high overhead and the benefit of
high-order allocation can't compensate the overhead of both work.

This patch makes auxiliary high-order allocation atomic. If there is
no memory pressure and memory isn't fragmented, the alloction will still
success, so we don't sacrifice high-order allocation's benefit here.
If the atomic allocation fails, direct memory reclaim/compaction will not
be triggered, allocation fallback to low-order immediately, hence
the direct memory reclaim/compaction overhead is avoided. In the
allocation failure case, kswapd is waken up and trying to make high-order
freepages, so allocation could success next time.

Following is the test to measure effect of this patch.

System: QEMU, CPU 8, 512 MB
Mem: 25% memory is allocated at random position to make fragmentation.
 Memory-hogger occupies 150 MB memory.
Workload: hackbench -g 20 -l 1000

Average result by 10 runs (Base va Patched)

elapsed_time(s): 4.3468 vs 2.9838
compact_stall: 461.7 vs 73.6
pgmigrate_success: 28315.9 vs 7256.1

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/slub.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/mm/slub.c b/mm/slub.c
index 257283f..52b9025 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1364,6 +1364,8 @@ static struct page *allocate_slab(struct kmem_cache *s, gfp_t flags, int node)
 	 * so we fall-back to the minimum order allocation.
 	 */
 	alloc_gfp = (flags | __GFP_NOWARN | __GFP_NORETRY) & ~__GFP_NOFAIL;
+	if ((alloc_gfp & __GFP_WAIT) && oo_order(oo) > oo_order(s->min))
+		alloc_gfp = (alloc_gfp | __GFP_NOMEMALLOC) & ~__GFP_WAIT;
 
 	page = alloc_slab_page(s, alloc_gfp, node, oo);
 	if (unlikely(!page)) {
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
