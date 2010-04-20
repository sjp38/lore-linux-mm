Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id CCD036B01F7
	for <linux-mm@kvack.org>; Tue, 20 Apr 2010 17:01:31 -0400 (EDT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 14/14] mm,compaction: Defer compaction using an exponential backoff when compaction fails
Date: Tue, 20 Apr 2010 22:01:16 +0100
Message-Id: <1271797276-31358-15-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1271797276-31358-1-git-send-email-mel@csn.ul.ie>
References: <1271797276-31358-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

The fragmentation index may indicate that a failure is due to external
fragmentation but after a compaction run completes, it is still possible
for an allocation to fail. There are two obvious reasons as to why

  o Page migration cannot move all pages so fragmentation remains
  o A suitable page may exist but watermarks are not met

In the event of compaction followed by an allocation failure, this patch
defers further compaction in the zone (1 << compact_defer_shift) times.
If the next compaction attempt also fails, compact_defer_shift is
increased up to a maximum of 6. If compaction succeeds, the defer
counters are reset again.

The zone that is deferred is the first zone in the zonelist - i.e. the
preferred zone.  To defer compaction in the other zones, the information
would need to be stored in the zonelist or implemented similar to the
zonelist_cache.  This would impact the fast-paths and is not justified at
this time.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---
 include/linux/compaction.h |   39 +++++++++++++++++++++++++++++++++++++++
 include/linux/mmzone.h     |    9 +++++++++
 mm/page_alloc.c            |    5 ++++-
 3 files changed, 52 insertions(+), 1 deletions(-)

diff --git a/include/linux/compaction.h b/include/linux/compaction.h
index 3719325..5ac5155 100644
--- a/include/linux/compaction.h
+++ b/include/linux/compaction.h
@@ -22,6 +22,36 @@ extern int sysctl_extfrag_handler(struct ctl_table *table, int write,
 extern int fragmentation_index(struct zone *zone, unsigned int order);
 extern unsigned long try_to_compact_pages(struct zonelist *zonelist,
 			int order, gfp_t gfp_mask, nodemask_t *mask);
+
+/* Do not skip compaction more than 64 times */
+#define COMPACT_MAX_DEFER_SHIFT 6
+
+/*
+ * Compaction is deferred when compaction fails to result in a page
+ * allocation success. 1 << compact_defer_limit compactions are skipped up
+ * to a limit of 1 << COMPACT_MAX_DEFER_SHIFT
+ */
+static inline void defer_compaction(struct zone *zone)
+{
+	zone->compact_considered = 0;
+	zone->compact_defer_shift++;
+
+	if (zone->compact_defer_shift > COMPACT_MAX_DEFER_SHIFT)
+		zone->compact_defer_shift = COMPACT_MAX_DEFER_SHIFT;
+}
+
+/* Returns true if compaction should be skipped this time */
+static inline bool compaction_deferred(struct zone *zone)
+{
+	unsigned long defer_limit = 1UL << zone->compact_defer_shift;
+
+	/* Avoid possible overflow */
+	if (++zone->compact_considered > defer_limit)
+		zone->compact_considered = defer_limit;
+
+	return zone->compact_considered < (1UL << zone->compact_defer_shift);
+}
+
 #else
 static inline unsigned long try_to_compact_pages(struct zonelist *zonelist,
 			int order, gfp_t gfp_mask, nodemask_t *nodemask)
@@ -29,6 +59,15 @@ static inline unsigned long try_to_compact_pages(struct zonelist *zonelist,
 	return COMPACT_CONTINUE;
 }
 
+static inline void defer_compaction(struct zone *zone)
+{
+}
+
+static inline bool compaction_deferred(struct zone *zone)
+{
+	return 1;
+}
+
 #endif /* CONFIG_COMPACTION */
 
 #if defined(CONFIG_COMPACTION) && defined(CONFIG_SYSFS) && defined(CONFIG_NUMA)
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index cf9e458..fd55f72 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -321,6 +321,15 @@ struct zone {
 	unsigned long		*pageblock_flags;
 #endif /* CONFIG_SPARSEMEM */
 
+#ifdef CONFIG_COMPACTION
+	/*
+	 * On compaction failure, 1<<compact_defer_shift compactions
+	 * are skipped before trying again. The number attempted since
+	 * last failure is tracked with compact_considered.
+	 */
+	unsigned int		compact_considered;
+	unsigned int		compact_defer_shift;
+#endif
 
 	ZONE_PADDING(_pad1_)
 
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 1de363e..51497ab 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1772,7 +1772,7 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
 {
 	struct page *page;
 
-	if (!order)
+	if (!order || compaction_deferred(preferred_zone))
 		return NULL;
 
 	*did_some_progress = try_to_compact_pages(zonelist, order, gfp_mask,
@@ -1788,6 +1788,8 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
 				alloc_flags, preferred_zone,
 				migratetype);
 		if (page) {
+			preferred_zone->compact_considered = 0;
+			preferred_zone->compact_defer_shift = 0;
 			__count_vm_event(COMPACTSUCCESS);
 			return page;
 		}
@@ -1798,6 +1800,7 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
 		 * but not enough to satisfy watermarks.
 		 */
 		count_vm_event(COMPACTFAIL);
+		defer_compaction(preferred_zone);
 
 		cond_resched();
 	}
-- 
1.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
