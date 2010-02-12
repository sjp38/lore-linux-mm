Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 03587620016
	for <linux-mm@kvack.org>; Fri, 12 Feb 2010 07:01:04 -0500 (EST)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 09/12] Do not compact within a preferred zone after a compaction failure
Date: Fri, 12 Feb 2010 12:00:56 +0000
Message-Id: <1265976059-7459-10-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1265976059-7459-1-git-send-email-mel@csn.ul.ie>
References: <1265976059-7459-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

The fragmentation index may indicate that a failure it due to external
fragmentation, a compaction run complete and an allocation failure still
fail. There are two obvious reasons as to why

  o Page migration cannot move all pages so fragmentation remains
  o A suitable page may exist but watermarks are not met

In the event of compaction and allocation failure, this patch prevents
compaction happening for a short interval. It's only recorded on the
preferred zone but that should be enough coverage. This could have been
implemented similar to the zonelist_cache but the increased size of the
zonelist did not appear to be justified.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---
 include/linux/compaction.h |   29 +++++++++++++++++++++++++++++
 include/linux/mmzone.h     |    7 +++++++
 mm/page_alloc.c            |    5 ++++-
 3 files changed, 40 insertions(+), 1 deletions(-)

diff --git a/include/linux/compaction.h b/include/linux/compaction.h
index 1cf95e2..1891bd1 100644
--- a/include/linux/compaction.h
+++ b/include/linux/compaction.h
@@ -13,6 +13,26 @@ extern int sysctl_compaction_handler(struct ctl_table *table, int write,
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
+	zone->compact_resume = jiffies + HZ/50;
+}
+
+static inline int compaction_deferred(struct zone *zone)
+{
+	return time_before(jiffies, zone->compact_resume);
+}
+
 #else
 static inline unsigned long try_to_compact_pages(struct zonelist *zonelist,
 			int order, gfp_t gfp_mask, nodemask_t *nodemask)
@@ -20,6 +40,15 @@ static inline unsigned long try_to_compact_pages(struct zonelist *zonelist,
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
index 30fe668..31fb38b 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -328,6 +328,13 @@ struct zone {
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
index 1910b8b..7021c68 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1730,7 +1730,7 @@ __alloc_pages_direct_reclaim(gfp_t gfp_mask, unsigned int order,
 	cond_resched();
 
 	/* Try memory compaction for high-order allocations before reclaim */
-	if (order) {
+	if (order && !compaction_deferred(preferred_zone)) {
 		*did_some_progress = try_to_compact_pages(zonelist,
 						order, gfp_mask, nodemask);
 		if (*did_some_progress != COMPACT_INCOMPLETE) {
@@ -1750,6 +1750,9 @@ __alloc_pages_direct_reclaim(gfp_t gfp_mask, unsigned int order,
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
