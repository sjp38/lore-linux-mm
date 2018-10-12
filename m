Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 092EA6B0003
	for <linux-mm@kvack.org>; Fri, 12 Oct 2018 17:25:01 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id h76-v6so13263853pfd.10
        for <linux-mm@kvack.org>; Fri, 12 Oct 2018 14:25:01 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u6-v6sor1998756plz.53.2018.10.12.14.24.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 12 Oct 2018 14:24:59 -0700 (PDT)
Date: Fri, 12 Oct 2018 14:24:57 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch] mm, slab: avoid high-order slab pages when it does not reduce
 waste
Message-ID: <alpine.DEB.2.21.1810121424420.116562@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

The slab allocator has a heuristic that checks whether the internal
fragmentation is satisfactory and, if not, increases cachep->gfporder to
try to improve this.

If the amount of waste is the same at higher cachep->gfporder values,
there is no significant benefit to allocating higher order memory.  There
will be fewer calls to the page allocator, but each call will require
zone->lock and finding the page of best fit from the per-zone free areas.

Instead, it is better to allocate order-0 memory if possible so that pages
can be returned from the per-cpu pagesets (pcp).

There are two reasons to prefer this over allocating high order memory:

 - allocating from the pcp lists does not require a per-zone lock, and

 - this reduces stranding of MIGRATE_UNMOVABLE pageblocks on pcp lists
   that increases slab fragmentation across a zone.

We are particularly interested in the second point to eliminate cases
where all other pages on a pageblock are movable (or free) and fallback to
pageblocks of other migratetypes from the per-zone free areas causes
high-order slab memory to be allocated from them rather than from free
MIGRATE_UNMOVABLE pages on the pcp.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/slab.c | 15 +++++++++++++++
 1 file changed, 15 insertions(+)

diff --git a/mm/slab.c b/mm/slab.c
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -1748,6 +1748,7 @@ static size_t calculate_slab_order(struct kmem_cache *cachep,
 	for (gfporder = 0; gfporder <= KMALLOC_MAX_ORDER; gfporder++) {
 		unsigned int num;
 		size_t remainder;
+		int order;
 
 		num = cache_estimate(gfporder, size, flags, &remainder);
 		if (!num)
@@ -1803,6 +1804,20 @@ static size_t calculate_slab_order(struct kmem_cache *cachep,
 		 */
 		if (left_over * 8 <= (PAGE_SIZE << gfporder))
 			break;
+
+		/*
+		 * If a higher gfporder would not reduce internal fragmentation,
+		 * no need to continue.  The preference is to keep gfporder as
+		 * small as possible so slab allocations can be served from
+		 * MIGRATE_UNMOVABLE pcp lists to avoid stranding.
+		 */
+		for (order = gfporder + 1; order <= slab_max_order; order++) {
+			cache_estimate(order, size, flags, &remainder);
+			if (remainder < left_over)
+				break;
+		}
+		if (order > slab_max_order)
+			break;
 	}
 	return left_over;
 }
