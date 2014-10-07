Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id DC47A6B0074
	for <linux-mm@kvack.org>; Tue,  7 Oct 2014 11:34:02 -0400 (EDT)
Received: by mail-wi0-f179.google.com with SMTP id d1so8340216wiv.6
        for <linux-mm@kvack.org>; Tue, 07 Oct 2014 08:34:02 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id fp5si14512836wic.107.2014.10.07.08.34.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 07 Oct 2014 08:34:00 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH 5/5] mm, compaction: more focused lru and pcplists draining
Date: Tue,  7 Oct 2014 17:33:39 +0200
Message-Id: <1412696019-21761-6-git-send-email-vbabka@suse.cz>
In-Reply-To: <1412696019-21761-1-git-send-email-vbabka@suse.cz>
References: <1412696019-21761-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Nazarewicz <mina86@mina86.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>

The goal of memory compaction is to create high-order freepages through page
migration. Page migration however puts pages on the per-cpu lru_add cache,
which is later flushed to per-cpu pcplists, and only after pcplists are
drained the pages can actually merge. This can happen due to the per-cpu
caches becoming full through further freeing, or explicitly.

During direct compaction, it is useful to do the draining explicitly so that
pages merge as soon as possible and compaction can detect success immediately
and keep the latency impact at minimum. However the current implementation is
far from ideal. Draining is done only in  __alloc_pages_direct_compact(),
after all zones were already compacted, and the decisions to continue or stop
compaction in individual zones was done without the last batch of migrations
being merged. It is also missing the draining of lru_add cache before the
pcplists.

This patch moves the draining for direct compaction into compact_zone(). It
adds the missing lru_cache draining and uses the newly introduced single zone
pcplists draining to reduce overhead and avoid impact on unrelated zones.
Draining is only performed when it can actually lead to merging of a page of
desired order (passed by cc->order). This means it is only done when migration
occurred in the previously scanned cc->order aligned block(s) and the
migration scanner is now pointing to the next cc->order aligned block.

The patch has been tested with stress-highalloc benchmark from mmtests.
Although overal allocation success rates of the benchmark were not affected,
the number of detected compaction successes has doubled. This suggests that
allocations were previously successful due to implicit merging caused by
background activity, making a later allocation attempt succeed immediately,
but not attributing the success to compaction. Since stress-highalloc always
tries to allocate almost the whole memory, it cannot show the improvement in
its reported success rate metric. However after this patch, compaction should
detect success and terminate earlier, reducing the direct compaction latencies
in a real scenario.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Michal Nazarewicz <mina86@mina86.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Christoph Lameter <cl@linux.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: David Rientjes <rientjes@google.com>
---
 mm/compaction.c | 41 ++++++++++++++++++++++++++++++++++++++++-
 mm/page_alloc.c |  4 ----
 2 files changed, 40 insertions(+), 5 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 8fa888d..41b49d7 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -1179,6 +1179,7 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
 	while ((ret = compact_finished(zone, cc, migratetype)) ==
 						COMPACT_CONTINUE) {
 		int err;
+		unsigned long last_migrated_pfn = 0;
 
 		switch (isolate_migratepages(zone, cc)) {
 		case ISOLATE_ABORT:
@@ -1187,7 +1188,12 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
 			cc->nr_migratepages = 0;
 			goto out;
 		case ISOLATE_NONE:
-			continue;
+			/*
+			 * We haven't isolated and migrated anything, but
+			 * there might still be unflushed migrations from
+			 * previous cc->order aligned block.
+			 */
+			goto check_drain;
 		case ISOLATE_SUCCESS:
 			;
 		}
@@ -1212,6 +1218,39 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
 				goto out;
 			}
 		}
+
+		/*
+		 * Record where we have freed pages by migration and not yet
+		 * flushed them to buddy allocator. Subtract 1, because often
+		 * we finish a pageblock and migrate_pfn points to the first
+		 * page* of the next one. In that case we want the drain below
+		 * to happen immediately.
+		 */
+		if (!last_migrated_pfn)
+			last_migrated_pfn = cc->migrate_pfn - 1;
+
+check_drain:
+		/*
+		 * Have we moved away from the previous cc->order aligned block
+		 * where we migrated from? If yes, flush the pages that were
+		 * freed, so that they can merge and compact_finished() can
+		 * detect immediately if allocation should succeed.
+		 */
+		if (cc->order > 0 && last_migrated_pfn) {
+			int cpu;
+			unsigned long current_block_start =
+				cc->migrate_pfn & ~((1UL << cc->order) - 1);
+
+			if (last_migrated_pfn < current_block_start) {
+				cpu = get_cpu();
+				lru_add_drain_cpu(cpu);
+				drain_local_pages(zone);
+				put_cpu();
+				/* No more flushing until we migrate again */
+				last_migrated_pfn = 0;
+			}
+		}
+
 	}
 
 out:
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 5a4506f..14fac43 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2357,10 +2357,6 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
 	 */
 	count_vm_event(COMPACTSTALL);
 
-	/* Page migration frees to the PCP lists but we want merging */
-	drain_pages(get_cpu());
-	put_cpu();
-
 	page = get_page_from_freelist(gfp_mask, nodemask,
 			order, zonelist, high_zoneidx,
 			alloc_flags & ~ALLOC_NO_WATERMARKS,
-- 
1.8.4.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
