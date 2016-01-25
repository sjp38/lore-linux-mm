Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 765B06B0258
	for <linux-mm@kvack.org>; Mon, 25 Jan 2016 11:41:58 -0500 (EST)
Received: by mail-wm0-f41.google.com with SMTP id u188so73392613wmu.1
        for <linux-mm@kvack.org>; Mon, 25 Jan 2016 08:41:58 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id 79si25455419wmb.9.2016.01.25.08.41.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Jan 2016 08:41:57 -0800 (PST)
Date: Mon, 25 Jan 2016 11:41:14 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH 1/3] mm: workingset: eviction buckets for bigmem/lowbit
 machines
Message-ID: <20160125164114.GB29291@cmpxchg.org>
References: <1453654576-8371-1-git-send-email-vdavydov@virtuozzo.com>
 <20160125163907.GA29291@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160125163907.GA29291@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

space will get tight once we need to identify the memcg. add this to
stretch out the necessary distance by sacrificing granularity.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/workingset.c | 40 +++++++++++++++++++++++++++++++++++-----
 1 file changed, 35 insertions(+), 5 deletions(-)

diff --git a/mm/workingset.c b/mm/workingset.c
index 61ead9e5549d..6f3ba184ffb2 100644
--- a/mm/workingset.c
+++ b/mm/workingset.c
@@ -152,8 +152,23 @@
  * refault distance will immediately activate the refaulting page.
  */
 
+#define EVICTION_SHIFT (NODES_SHIFT + ZONES_SHIFT +	\
+			RADIX_TREE_EXCEPTIONAL_SHIFT)
+#define EVICTION_MASK (~0UL >> EVICTION_SHIFT)
+
+/*
+ * Eviction timestamps need to be able to cover the full range of
+ * actionable refaults. However, bits are tight in the radix tree
+ * entry, and after storing the identifier for the lruvec there might
+ * not be enough left to represent every single actionable refault. In
+ * that case, we have to sacrifice granularity for distance, and group
+ * evictions into coarser buckets by shaving off lower timestamp bits.
+ */
+static unsigned int bucket_order;
+
 static void *pack_shadow(unsigned long eviction, struct zone *zone)
 {
+	eviction >>= bucket_order;
 	eviction = (eviction << NODES_SHIFT) | zone_to_nid(zone);
 	eviction = (eviction << ZONES_SHIFT) | zone_idx(zone);
 	eviction = (eviction << RADIX_TREE_EXCEPTIONAL_SHIFT);
@@ -168,7 +183,6 @@ static void unpack_shadow(void *shadow,
 	unsigned long entry = (unsigned long)shadow;
 	unsigned long eviction;
 	unsigned long refault;
-	unsigned long mask;
 	int zid, nid;
 
 	entry >>= RADIX_TREE_EXCEPTIONAL_SHIFT;
@@ -176,13 +190,12 @@ static void unpack_shadow(void *shadow,
 	entry >>= ZONES_SHIFT;
 	nid = entry & ((1UL << NODES_SHIFT) - 1);
 	entry >>= NODES_SHIFT;
-	eviction = entry;
+	eviction = entry << bucket_order;
 
 	*zone = NODE_DATA(nid)->node_zones + zid;
 
 	refault = atomic_long_read(&(*zone)->inactive_age);
-	mask = ~0UL >> (NODES_SHIFT + ZONES_SHIFT +
-			RADIX_TREE_EXCEPTIONAL_SHIFT);
+
 	/*
 	 * The unsigned subtraction here gives an accurate distance
 	 * across inactive_age overflows in most cases.
@@ -199,7 +212,7 @@ static void unpack_shadow(void *shadow,
 	 * inappropriate activation leading to pressure on the active
 	 * list is not a problem.
 	 */
-	*distance = (refault - eviction) & mask;
+	*distance = (refault - eviction) & EVICTION_MASK;
 }
 
 /**
@@ -398,8 +411,25 @@ static struct lock_class_key shadow_nodes_key;
 
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
