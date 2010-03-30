Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 55EBA6B01F0
	for <linux-mm@kvack.org>; Tue, 30 Mar 2010 05:15:02 -0400 (EDT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 13/14] Do not compact within a preferred zone after a compaction failure
Date: Tue, 30 Mar 2010 10:14:48 +0100
Message-Id: <1269940489-5776-14-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1269940489-5776-1-git-send-email-mel@csn.ul.ie>
References: <1269940489-5776-1-git-send-email-mel@csn.ul.ie>
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
defers further compaction in the zone for a period of time. The zone that
is deferred is the first zone in the zonelist - i.e. the preferred zone.
To defer compaction in the other zones, the information would need to be
stored in the zonelist or implemented similar to the zonelist_cache.
This would impact the fast-paths and is not justified at this time.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
Acked-by: Rik van Riel <riel@redhat.com>
---
 include/linux/compaction.h |   35 +++++++++++++++++++++++++++++++++++
 include/linux/mmzone.h     |    7 +++++++
 mm/page_alloc.c            |    5 ++++-
 3 files changed, 46 insertions(+), 1 deletions(-)

diff --git a/include/linux/compaction.h b/include/linux/compaction.h
index ae98afc..2a02719 100644
--- a/include/linux/compaction.h
+++ b/include/linux/compaction.h
@@ -18,6 +18,32 @@ extern int sysctl_extfrag_handler(struct ctl_table *table, int write,
 extern int fragmentation_index(struct zone *zone, unsigned int order);
 extern unsigned long try_to_compact_pages(struct zonelist *zonelist,
 			int order, gfp_t gfp_mask, nodemask_t *mask);
+
+/* defer_compaction - Do not compact within a zone until a given time */
+static inline void defer_compaction(struct zone *zone, unsigned long resume)
+{
+	/*
+	 * This function is called when compaction fails to result in a page
+	 * allocation success. This is somewhat unsatisfactory as the failure
+	 * to compact has nothing to do with time and everything to do with
+	 * the requested order, the number of free pages and watermarks. How
+	 * to wait on that is more unclear, but the answer would apply to
+	 * other areas where the VM waits based on time.
+	 */
+	zone->compact_resume = resume;
+}
+
+static inline int compaction_deferred(struct zone *zone)
+{
+	/* init once if necessary */
+	if (unlikely(!zone->compact_resume)) {
+		zone->compact_resume = jiffies;
+		return 0;
+	}
+
+	return time_before(jiffies, zone->compact_resume);
+}
+
 #else
 static inline unsigned long try_to_compact_pages(struct zonelist *zonelist,
 			int order, gfp_t gfp_mask, nodemask_t *nodemask)
@@ -25,6 +51,15 @@ static inline unsigned long try_to_compact_pages(struct zonelist *zonelist,
 	return COMPACT_INCOMPLETE;
 }
 
+static inline void defer_compaction(struct zone *zone, unsigned long resume)
+{
+}
+
+static inline int compaction_deferred(struct zone *zone)
+{
+	return 1;
+}
+
 #endif /* CONFIG_COMPACTION */
 
 #if defined(CONFIG_COMPACTION) && defined(CONFIG_SYSFS) && defined(CONFIG_NUMA)
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index cf9e458..bde879b 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -321,6 +321,13 @@ struct zone {
 	unsigned long		*pageblock_flags;
 #endif /* CONFIG_SPARSEMEM */
 
+#ifdef CONFIG_COMPACTION
+	/*
+	 * If a compaction fails, do not try compaction again until
+	 * jiffies is after the value of compact_resume
+	 */
+	unsigned long		compact_resume;
+#endif
 
 	ZONE_PADDING(_pad1_)
 
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 7a2e4a2..66823bd 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1770,7 +1770,7 @@ __alloc_pages_direct_reclaim(gfp_t gfp_mask, unsigned int order,
 	cond_resched();
 
 	/* Try memory compaction for high-order allocations before reclaim */
-	if (order) {
+	if (order && !compaction_deferred(preferred_zone)) {
 		*did_some_progress = try_to_compact_pages(zonelist,
 						order, gfp_mask, nodemask);
 		if (*did_some_progress != COMPACT_SKIPPED) {
@@ -1795,6 +1795,9 @@ __alloc_pages_direct_reclaim(gfp_t gfp_mask, unsigned int order,
 			 */
 			count_vm_event(COMPACTFAIL);
 
+			/* On failure, avoid compaction for a short time. */
+			defer_compaction(preferred_zone, jiffies + HZ/50);
+
 			cond_resched();
 		}
 	}
-- 
1.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
