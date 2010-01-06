Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id A97A76B0078
	for <linux-mm@kvack.org>; Wed,  6 Jan 2010 11:26:17 -0500 (EST)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 7/7] Do not compact within a preferred zone after a compaction failure
Date: Wed,  6 Jan 2010 16:26:09 +0000
Message-Id: <1262795169-9095-8-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1262795169-9095-1-git-send-email-mel@csn.ul.ie>
References: <1262795169-9095-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
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
 include/linux/mmzone.h |    7 +++++++
 mm/page_alloc.c        |   15 ++++++++++++++-
 2 files changed, 21 insertions(+), 1 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 30fe668..1d6ccbe 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -328,6 +328,13 @@ struct zone {
 	unsigned long		*pageblock_flags;
 #endif /* CONFIG_SPARSEMEM */
 
+#ifdef CONFIG_MIGRATION
+	/*
+	 * If a compaction fails, do not try compaction again until
+	 * jiffies is after the value of compact_resume
+	 */
+	unsigned long		compact_resume;
+#endif
 
 	ZONE_PADDING(_pad1_)
 
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 7275afb..9c86606 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1729,7 +1729,7 @@ __alloc_pages_direct_reclaim(gfp_t gfp_mask, unsigned int order,
 	cond_resched();
 
 	/* Try memory compaction for high-order allocations before reclaim */
-	if (order) {
+	if (order && time_after(jiffies, preferred_zone->compact_resume)) {
 		*did_some_progress = try_to_compact_pages(zonelist,
 						order, gfp_mask, nodemask);
 		if (*did_some_progress != COMPACT_INCOMPLETE) {
@@ -1748,6 +1748,19 @@ __alloc_pages_direct_reclaim(gfp_t gfp_mask, unsigned int order,
 			 * but not enough to satisfy watermarks.
 			 */
 			count_vm_event(COMPACTFAIL);
+
+			/*
+			 * On failure, avoid compaction for a short time.
+			 * XXX: This is very unsatisfactory. The failure
+			 * 	to compact has nothing to do with time
+			 * 	and everything to do with the requested
+			 * 	order, the number of free pages and
+			 * 	watermarks. How to wait on that is more
+			 * 	unclear, but the answer would apply to
+			 * 	other areas where the VM waits based on
+			 * 	time.
+			 */
+			preferred_zone->compact_resume = jiffies + HZ/50;
 		}
 	}
 
-- 
1.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
