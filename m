Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id A23966B0255
	for <linux-mm@kvack.org>; Mon, 25 Jan 2016 11:42:36 -0500 (EST)
Received: by mail-wm0-f42.google.com with SMTP id 123so73199564wmz.0
        for <linux-mm@kvack.org>; Mon, 25 Jan 2016 08:42:36 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id c192si25455423wmd.11.2016.01.25.08.42.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Jan 2016 08:42:35 -0800 (PST)
Date: Mon, 25 Jan 2016 11:41:52 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH 2/3] mm: workingset: separate shadow unpacking and refault
 calculation
Message-ID: <20160125164152.GC29291@cmpxchg.org>
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

used to be alright, but we're gonna add memcg and then the difference
between unpacking static data from the radix entry and dealing with
dynamic objects and doing calculations becomes more pronounced and
would make things awkward.

keep unpacking simple, move the higher-level stuff to _refault().

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/workingset.c | 55 ++++++++++++++++++++++++++++---------------------------
 1 file changed, 28 insertions(+), 27 deletions(-)

diff --git a/mm/workingset.c b/mm/workingset.c
index 6f3ba184ffb2..ac6eb7bc1faa 100644
--- a/mm/workingset.c
+++ b/mm/workingset.c
@@ -176,13 +176,10 @@ static void *pack_shadow(unsigned long eviction, struct zone *zone)
 	return (void *)(eviction | RADIX_TREE_EXCEPTIONAL_ENTRY);
 }
 
-static void unpack_shadow(void *shadow,
-			  struct zone **zone,
-			  unsigned long *distance)
+static void unpack_shadow(void *shadow, struct zone **zonep,
+			  unsigned long *evictionp)
 {
 	unsigned long entry = (unsigned long)shadow;
-	unsigned long eviction;
-	unsigned long refault;
 	int zid, nid;
 
 	entry >>= RADIX_TREE_EXCEPTIONAL_SHIFT;
@@ -190,29 +187,10 @@ static void unpack_shadow(void *shadow,
 	entry >>= ZONES_SHIFT;
 	nid = entry & ((1UL << NODES_SHIFT) - 1);
 	entry >>= NODES_SHIFT;
-	eviction = entry << bucket_order;
-
-	*zone = NODE_DATA(nid)->node_zones + zid;
 
-	refault = atomic_long_read(&(*zone)->inactive_age);
+	*zonep = NODE_DATA(nid)->node_zones + zid;
+	*evictionp = entry << bucket_order;
 
-	/*
-	 * The unsigned subtraction here gives an accurate distance
-	 * across inactive_age overflows in most cases.
-	 *
-	 * There is a special case: usually, shadow entries have a
-	 * short lifetime and are either refaulted or reclaimed along
-	 * with the inode before they get too old.  But it is not
-	 * impossible for the inactive_age to lap a shadow entry in
-	 * the field, which can then can result in a false small
-	 * refault distance, leading to a false activation should this
-	 * old entry actually refault again.  However, earlier kernels
-	 * used to deactivate unconditionally with *every* reclaim
-	 * invocation for the longest time, so the occasional
-	 * inappropriate activation leading to pressure on the active
-	 * list is not a problem.
-	 */
-	*distance = (refault - eviction) & EVICTION_MASK;
 }
 
 /**
@@ -244,9 +222,32 @@ void *workingset_eviction(struct address_space *mapping, struct page *page)
 bool workingset_refault(void *shadow)
 {
 	unsigned long refault_distance;
+	unsigned long eviction;
+	unsigned long refault;
 	struct zone *zone;
 
-	unpack_shadow(shadow, &zone, &refault_distance);
+	unpack_shadow(shadow, &zone, &eviction);
+
+	refault = atomic_long_read(&zone->inactive_age);
+
+	/*
+	 * The unsigned subtraction here gives an accurate distance
+	 * across inactive_age overflows in most cases.
+	 *
+	 * There is a special case: usually, shadow entries have a
+	 * short lifetime and are either refaulted or reclaimed along
+	 * with the inode before they get too old.  But it is not
+	 * impossible for the inactive_age to lap a shadow entry in
+	 * the field, which can then can result in a false small
+	 * refault distance, leading to a false activation should this
+	 * old entry actually refault again.  However, earlier kernels
+	 * used to deactivate unconditionally with *every* reclaim
+	 * invocation for the longest time, so the occasional
+	 * inappropriate activation leading to pressure on the active
+	 * list is not a problem.
+	 */
+	refault_distance = (refault - eviction) & EVICTION_MASK;
+
 	inc_zone_state(zone, WORKINGSET_REFAULT);
 
 	if (refault_distance <= zone_page_state(zone, NR_ACTIVE_FILE)) {
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
