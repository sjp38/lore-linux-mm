Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id 649526B0257
	for <linux-mm@kvack.org>; Fri, 29 Jan 2016 12:58:13 -0500 (EST)
Received: by mail-wm0-f50.google.com with SMTP id 128so63108741wmz.1
        for <linux-mm@kvack.org>; Fri, 29 Jan 2016 09:58:13 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id lu1si19085656wjb.170.2016.01.29.09.58.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Jan 2016 09:58:12 -0800 (PST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH v2 4/5] mm: workingset: eviction buckets for bigmem/lowbit machines
Date: Fri, 29 Jan 2016 12:54:06 -0500
Message-Id: <1454090047-1790-5-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1454090047-1790-1-git-send-email-hannes@cmpxchg.org>
References: <1454090047-1790-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vladimir Davydov <vdavydov@virtuozzo.com>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

For per-cgroup thrash detection, we need to store the memcg ID inside
the radix tree cookie as well. However, on 32 bit that doesn't leave
enough bits for the eviction timestamp to cover the necessary range of
recently evicted pages. The radix tree entry would look like this:

[ RADIX_TREE_EXCEPTIONAL(2) | ZONEID(2) | MEMCGID(16) | EVICTION(12) ]

12 bits means 4096 pages, means 16M worth of recently evicted pages.
But refaults are actionable up to distances covering half of memory.
To not miss refaults, we have to stretch out the range at the cost of
how precisely we can tell when a page was evicted. This way we can
shave off lower bits from the eviction timestamp until the necessary
range is covered. E.g. grouping evictions into 1M buckets (256 pages)
will stretch the longest representable refault distance to 4G.

This patch implements eviction buckets that are automatically sized
according to the available bits and the necessary refault range, in
preparation for per-cgroup thrash detection.

The maximum actionable distance is currently half of memory, but to
support memory hotplug of up to 200% of boot-time memory, we size the
buckets to cover double the distance. Beyond that, thrashing won't be
detectable anymore.

During boot, the kernel will print out the exact parameters, like so:

[    0.113929] workingset: timestamp_bits=12 max_order=18 bucket_order=6

In this example, there are 12 radix entry bits available for the
eviction timestamp, to cover a maximum distance of 2^18 pages (this is
a 1G machine). Consequently, evictions must be grouped into buckets of
2^6 pages, or 256K.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Reviewed-by: Vladimir Davydov <vdavydov@virtuozzo.com>
---
 mm/workingset.c | 30 +++++++++++++++++++++++++++++-
 1 file changed, 29 insertions(+), 1 deletion(-)

diff --git a/mm/workingset.c b/mm/workingset.c
index f874b2c..9a26a60 100644
--- a/mm/workingset.c
+++ b/mm/workingset.c
@@ -156,8 +156,19 @@
 			 ZONES_SHIFT + NODES_SHIFT)
 #define EVICTION_MASK	(~0UL >> EVICTION_SHIFT)
 
+/*
+ * Eviction timestamps need to be able to cover the full range of
+ * actionable refaults. However, bits are tight in the radix tree
+ * entry, and after storing the identifier for the lruvec there might
+ * not be enough left to represent every single actionable refault. In
+ * that case, we have to sacrifice granularity for distance, and group
+ * evictions into coarser buckets by shaving off lower timestamp bits.
+ */
+static unsigned int bucket_order __read_mostly;
+
 static void *pack_shadow(unsigned long eviction, struct zone *zone)
 {
+	eviction >>= bucket_order;
 	eviction = (eviction << NODES_SHIFT) | zone_to_nid(zone);
 	eviction = (eviction << ZONES_SHIFT) | zone_idx(zone);
 	eviction = (eviction << RADIX_TREE_EXCEPTIONAL_SHIFT);
@@ -178,7 +189,7 @@ static void unpack_shadow(void *shadow, struct zone **zonep,
 	entry >>= NODES_SHIFT;
 
 	*zonep = NODE_DATA(nid)->node_zones + zid;
-	*evictionp = entry;
+	*evictionp = entry << bucket_order;
 }
 
 /**
@@ -400,8 +411,25 @@ static struct lock_class_key shadow_nodes_key;
 
 static int __init workingset_init(void)
 {
+	unsigned int timestamp_bits;
+	unsigned int max_order;
 	int ret;
 
+	BUILD_BUG_ON(BITS_PER_LONG < EVICTION_SHIFT);
+	/*
+	 * Calculate the eviction bucket size to cover the longest
+	 * actionable refault distance, which is currently half of
+	 * memory (totalram_pages/2). However, memory hotplug may add
+	 * some more pages at runtime, so keep working with up to
+	 * double the initial memory by using totalram_pages as-is.
+	 */
+	timestamp_bits = BITS_PER_LONG - EVICTION_SHIFT;
+	max_order = fls_long(totalram_pages - 1);
+	if (max_order > timestamp_bits)
+		bucket_order = max_order - timestamp_bits;
+	printk("workingset: timestamp_bits=%d max_order=%d bucket_order=%u\n",
+	       timestamp_bits, max_order, bucket_order);
+
 	ret = list_lru_init_key(&workingset_shadow_nodes, &shadow_nodes_key);
 	if (ret)
 		goto err;
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
