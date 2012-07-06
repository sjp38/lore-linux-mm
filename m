Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id 1AA706B0078
	for <linux-mm@kvack.org>; Fri,  6 Jul 2012 11:30:02 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so17851366pbb.14
        for <linux-mm@kvack.org>; Fri, 06 Jul 2012 08:30:01 -0700 (PDT)
From: Joonsoo Kim <js1304@gmail.com>
Subject: [PATCH] mm: don't invoke __alloc_pages_direct_compact when order 0
Date: Sat,  7 Jul 2012 00:28:41 +0900
Message-Id: <1341588521-17744-1-git-send-email-js1304@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonsoo Kim <js1304@gmail.com>

__alloc_pages_direct_compact has many arguments so invoking it is very costly.
And in almost invoking case, order is 0, so return immediately.

Let's not invoke it when order 0

Signed-off-by: Joonsoo Kim <js1304@gmail.com>

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 6092f33..f4039aa 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2056,7 +2056,10 @@ out:
 }
 
 #ifdef CONFIG_COMPACTION
-/* Try memory compaction for high-order allocations before reclaim */
+/*
+ * Try memory compaction for high-order allocations before reclaim
+ * Must be called with order > 0
+ */
 static struct page *
 __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
 	struct zonelist *zonelist, enum zone_type high_zoneidx,
@@ -2067,8 +2070,7 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
 {
 	struct page *page;
 
-	if (!order)
-		return NULL;
+	BUG_ON(!order);
 
 	if (compaction_deferred(preferred_zone, order)) {
 		*deferred_compaction = true;
@@ -2363,15 +2365,17 @@ rebalance:
 	 * Try direct compaction. The first pass is asynchronous. Subsequent
 	 * attempts after direct reclaim are synchronous
 	 */
-	page = __alloc_pages_direct_compact(gfp_mask, order,
-					zonelist, high_zoneidx,
-					nodemask,
-					alloc_flags, preferred_zone,
-					migratetype, sync_migration,
-					&deferred_compaction,
-					&did_some_progress);
-	if (page)
-		goto got_pg;
+	if (unlikely(order)) {
+		page = __alloc_pages_direct_compact(gfp_mask, order,
+						zonelist, high_zoneidx,
+						nodemask,
+						alloc_flags, preferred_zone,
+						migratetype, sync_migration,
+						&deferred_compaction,
+						&did_some_progress);
+		if (page)
+			goto got_pg;
+	}
 	sync_migration = true;
 
 	/*
@@ -2446,15 +2450,17 @@ rebalance:
 		 * direct reclaim and reclaim/compaction depends on compaction
 		 * being called after reclaim so call directly if necessary
 		 */
-		page = __alloc_pages_direct_compact(gfp_mask, order,
-					zonelist, high_zoneidx,
-					nodemask,
-					alloc_flags, preferred_zone,
-					migratetype, sync_migration,
-					&deferred_compaction,
-					&did_some_progress);
-		if (page)
-			goto got_pg;
+		if (unlikely(order)) {
+			page = __alloc_pages_direct_compact(gfp_mask, order,
+						zonelist, high_zoneidx,
+						nodemask,
+						alloc_flags, preferred_zone,
+						migratetype, sync_migration,
+						&deferred_compaction,
+						&did_some_progress);
+			if (page)
+				goto got_pg;
+		}
 	}
 
 nopage:
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
