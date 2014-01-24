Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f47.google.com (mail-bk0-f47.google.com [209.85.214.47])
	by kanga.kvack.org (Postfix) with ESMTP id 905916B0036
	for <linux-mm@kvack.org>; Fri, 24 Jan 2014 17:03:22 -0500 (EST)
Received: by mail-bk0-f47.google.com with SMTP id d7so1520908bkh.20
        for <linux-mm@kvack.org>; Fri, 24 Jan 2014 14:03:21 -0800 (PST)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id cq2si4527696bkc.108.2014.01.24.14.03.20
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 24 Jan 2014 14:03:21 -0800 (PST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 1/2] mm: page-writeback: fix dirty_balance_reserve subtraction from dirtyable memory
Date: Fri, 24 Jan 2014 17:03:03 -0500
Message-Id: <1390600984-13925-2-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1390600984-13925-1-git-send-email-hannes@cmpxchg.org>
References: <1390600984-13925-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tejun Heo <tj@kernel.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

The dirty_balance_reserve is an approximation of the fraction of free
pages that the page allocator does not make available for page cache
allocations.  As a result, it has to be taken into account when
calculating the amount of "dirtyable memory", the baseline to which
dirty_background_ratio and dirty_ratio are applied.

However, currently the reserve is subtracted from the sum of free and
reclaimable pages, which is non-sensical and leads to erroneous
results when the system is dominated by unreclaimable pages and the
dirty_balance_reserve is bigger than free+reclaimable.  In that case,
at least the already allocated cache should be considered dirtyable.

Fix the calculation by subtracting the reserve from the amount of free
pages, then adding the reclaimable pages on top.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/page-writeback.c | 52 +++++++++++++++++++++++-----------------------------
 1 file changed, 23 insertions(+), 29 deletions(-)

diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 63807583d8e8..79cf52b058a7 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -191,6 +191,25 @@ static unsigned long writeout_period_time = 0;
  * global dirtyable memory first.
  */
 
+/**
+ * zone_dirtyable_memory - number of dirtyable pages in a zone
+ * @zone: the zone
+ *
+ * Returns the zone's number of pages potentially available for dirty
+ * page cache.  This is the base value for the per-zone dirty limits.
+ */
+static unsigned long zone_dirtyable_memory(struct zone *zone)
+{
+	unsigned long nr_pages;
+
+	nr_pages = zone_page_state(zone, NR_FREE_PAGES);
+	nr_pages -= min(nr_pages, zone->dirty_balance_reserve);
+
+	nr_pages += zone_reclaimable_pages(zone);
+
+	return nr_pages;
+}
+
 static unsigned long highmem_dirtyable_memory(unsigned long total)
 {
 #ifdef CONFIG_HIGHMEM
@@ -201,8 +220,7 @@ static unsigned long highmem_dirtyable_memory(unsigned long total)
 		struct zone *z =
 			&NODE_DATA(node)->node_zones[ZONE_HIGHMEM];
 
-		x += zone_page_state(z, NR_FREE_PAGES) +
-		     zone_reclaimable_pages(z) - z->dirty_balance_reserve;
+		x += zone_dirtyable_memory(zone);
 	}
 	/*
 	 * Unreclaimable memory (kernel memory or anonymous memory
@@ -238,9 +256,11 @@ static unsigned long global_dirtyable_memory(void)
 {
 	unsigned long x;
 
-	x = global_page_state(NR_FREE_PAGES) + global_reclaimable_pages();
+	x = global_page_state(NR_FREE_PAGES);
 	x -= min(x, dirty_balance_reserve);
 
+	x += global_reclaimable_pages();
+
 	if (!vm_highmem_is_dirtyable)
 		x -= highmem_dirtyable_memory(x);
 
@@ -289,32 +309,6 @@ void global_dirty_limits(unsigned long *pbackground, unsigned long *pdirty)
 }
 
 /**
- * zone_dirtyable_memory - number of dirtyable pages in a zone
- * @zone: the zone
- *
- * Returns the zone's number of pages potentially available for dirty
- * page cache.  This is the base value for the per-zone dirty limits.
- */
-static unsigned long zone_dirtyable_memory(struct zone *zone)
-{
-	/*
-	 * The effective global number of dirtyable pages may exclude
-	 * highmem as a big-picture measure to keep the ratio between
-	 * dirty memory and lowmem reasonable.
-	 *
-	 * But this function is purely about the individual zone and a
-	 * highmem zone can hold its share of dirty pages, so we don't
-	 * care about vm_highmem_is_dirtyable here.
-	 */
-	unsigned long nr_pages = zone_page_state(zone, NR_FREE_PAGES) +
-		zone_reclaimable_pages(zone);
-
-	/* don't allow this to underflow */
-	nr_pages -= min(nr_pages, zone->dirty_balance_reserve);
-	return nr_pages;
-}
-
-/**
  * zone_dirty_limit - maximum number of dirty pages allowed in a zone
  * @zone: the zone
  *
-- 
1.8.4.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
