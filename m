Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id B00806B0254
	for <linux-mm@kvack.org>; Tue,  8 Mar 2016 08:42:51 -0500 (EST)
Received: by mail-wm0-f47.google.com with SMTP id n186so132165764wmn.1
        for <linux-mm@kvack.org>; Tue, 08 Mar 2016 05:42:51 -0800 (PST)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id n64si4511127wma.63.2016.03.08.05.42.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Mar 2016 05:42:50 -0800 (PST)
Received: by mail-wm0-f65.google.com with SMTP id n186so4162508wmn.0
        for <linux-mm@kvack.org>; Tue, 08 Mar 2016 05:42:50 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 1/3] mm, compaction: change COMPACT_ constants into enum
Date: Tue,  8 Mar 2016 14:42:43 +0100
Message-Id: <1457444565-10524-2-git-send-email-mhocko@kernel.org>
In-Reply-To: <1457444565-10524-1-git-send-email-mhocko@kernel.org>
References: <20160307160838.GB5028@dhcp22.suse.cz>
 <1457444565-10524-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Vlastimil Babka <vbabka@suse.cz>, Linus Torvalds <torvalds@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Hillf Danton <hillf.zj@alibaba-inc.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Joonsoo Kim <js1304@gmail.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

compaction code is doing weird dances between
COMPACT_FOO -> int -> unsigned long

but there doesn't seem to be any reason for that. All functions which
return/use one of those constants are not expecting any other value
so it really makes sense to define an enum for them and make it clear
that no other values are expected.

This is a pure cleanup and shouldn't introduce any functional changes.

Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 include/linux/compaction.h | 45 +++++++++++++++++++++++++++------------------
 mm/compaction.c            | 27 ++++++++++++++-------------
 mm/page_alloc.c            |  2 +-
 3 files changed, 42 insertions(+), 32 deletions(-)

diff --git a/include/linux/compaction.h b/include/linux/compaction.h
index 4cd4ddf64cc7..b167801187e7 100644
--- a/include/linux/compaction.h
+++ b/include/linux/compaction.h
@@ -2,21 +2,29 @@
 #define _LINUX_COMPACTION_H
 
 /* Return values for compact_zone() and try_to_compact_pages() */
-/* compaction didn't start as it was deferred due to past failures */
-#define COMPACT_DEFERRED	0
-/* compaction didn't start as it was not possible or direct reclaim was more suitable */
-#define COMPACT_SKIPPED		1
-/* compaction should continue to another pageblock */
-#define COMPACT_CONTINUE	2
-/* direct compaction partially compacted a zone and there are suitable pages */
-#define COMPACT_PARTIAL		3
-/* The full zone was compacted */
-#define COMPACT_COMPLETE	4
-/* For more detailed tracepoint output */
-#define COMPACT_NO_SUITABLE_PAGE	5
-#define COMPACT_NOT_SUITABLE_ZONE	6
-#define COMPACT_CONTENDED		7
 /* When adding new states, please adjust include/trace/events/compaction.h */
+enum compact_result {
+	/* compaction didn't start as it was deferred due to past failures */
+	COMPACT_DEFERRED,
+	/*
+	 * compaction didn't start as it was not possible or direct reclaim
+	 * was more suitable
+	 */
+	COMPACT_SKIPPED,
+	/* compaction should continue to another pageblock */
+	COMPACT_CONTINUE,
+	/*
+	 * direct compaction partially compacted a zone and there are suitable
+	 * pages
+	 */
+	COMPACT_PARTIAL,
+	/* The full zone was compacted */
+	COMPACT_COMPLETE,
+	/* For more detailed tracepoint output */
+	COMPACT_NO_SUITABLE_PAGE,
+	COMPACT_NOT_SUITABLE_ZONE,
+	COMPACT_CONTENDED,
+};
 
 /* Used to signal whether compaction detected need_sched() or lock contention */
 /* No contention detected */
@@ -38,12 +46,13 @@ extern int sysctl_extfrag_handler(struct ctl_table *table, int write,
 extern int sysctl_compact_unevictable_allowed;
 
 extern int fragmentation_index(struct zone *zone, unsigned int order);
-extern unsigned long try_to_compact_pages(gfp_t gfp_mask, unsigned int order,
+extern enum compact_result try_to_compact_pages(gfp_t gfp_mask,
+			unsigned int order,
 			int alloc_flags, const struct alloc_context *ac,
 			enum migrate_mode mode, int *contended);
 extern void compact_pgdat(pg_data_t *pgdat, int order);
 extern void reset_isolation_suitable(pg_data_t *pgdat);
-extern unsigned long compaction_suitable(struct zone *zone, int order,
+extern enum compact_result compaction_suitable(struct zone *zone, int order,
 					int alloc_flags, int classzone_idx);
 
 extern void defer_compaction(struct zone *zone, int order);
@@ -53,7 +62,7 @@ extern void compaction_defer_reset(struct zone *zone, int order,
 extern bool compaction_restarting(struct zone *zone, int order);
 
 #else
-static inline unsigned long try_to_compact_pages(gfp_t gfp_mask,
+static inline enum compact_result try_to_compact_pages(gfp_t gfp_mask,
 			unsigned int order, int alloc_flags,
 			const struct alloc_context *ac,
 			enum migrate_mode mode, int *contended)
@@ -69,7 +78,7 @@ static inline void reset_isolation_suitable(pg_data_t *pgdat)
 {
 }
 
-static inline unsigned long compaction_suitable(struct zone *zone, int order,
+static inline enum compact_result compaction_suitable(struct zone *zone, int order,
 					int alloc_flags, int classzone_idx)
 {
 	return COMPACT_SKIPPED;
diff --git a/mm/compaction.c b/mm/compaction.c
index 585de54dbe8c..0f61f12d82b6 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -1195,7 +1195,7 @@ static inline bool is_via_compact_memory(int order)
 	return order == -1;
 }
 
-static int __compact_finished(struct zone *zone, struct compact_control *cc,
+static enum compact_result __compact_finished(struct zone *zone, struct compact_control *cc,
 			    const int migratetype)
 {
 	unsigned int order;
@@ -1258,8 +1258,9 @@ static int __compact_finished(struct zone *zone, struct compact_control *cc,
 	return COMPACT_NO_SUITABLE_PAGE;
 }
 
-static int compact_finished(struct zone *zone, struct compact_control *cc,
-			    const int migratetype)
+static enum compact_result compact_finished(struct zone *zone,
+			struct compact_control *cc,
+			const int migratetype)
 {
 	int ret;
 
@@ -1278,7 +1279,7 @@ static int compact_finished(struct zone *zone, struct compact_control *cc,
  *   COMPACT_PARTIAL  - If the allocation would succeed without compaction
  *   COMPACT_CONTINUE - If compaction should run now
  */
-static unsigned long __compaction_suitable(struct zone *zone, int order,
+static enum compact_result __compaction_suitable(struct zone *zone, int order,
 					int alloc_flags, int classzone_idx)
 {
 	int fragindex;
@@ -1323,10 +1324,10 @@ static unsigned long __compaction_suitable(struct zone *zone, int order,
 	return COMPACT_CONTINUE;
 }
 
-unsigned long compaction_suitable(struct zone *zone, int order,
+enum compact_result compaction_suitable(struct zone *zone, int order,
 					int alloc_flags, int classzone_idx)
 {
-	unsigned long ret;
+	enum compact_result ret;
 
 	ret = __compaction_suitable(zone, order, alloc_flags, classzone_idx);
 	trace_mm_compaction_suitable(zone, order, ret);
@@ -1336,9 +1337,9 @@ unsigned long compaction_suitable(struct zone *zone, int order,
 	return ret;
 }
 
-static int compact_zone(struct zone *zone, struct compact_control *cc)
+static enum compact_result compact_zone(struct zone *zone, struct compact_control *cc)
 {
-	int ret;
+	enum compact_result ret;
 	unsigned long start_pfn = zone->zone_start_pfn;
 	unsigned long end_pfn = zone_end_pfn(zone);
 	const int migratetype = gfpflags_to_migratetype(cc->gfp_mask);
@@ -1483,11 +1484,11 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
 	return ret;
 }
 
-static unsigned long compact_zone_order(struct zone *zone, int order,
+static enum compact_result compact_zone_order(struct zone *zone, int order,
 		gfp_t gfp_mask, enum migrate_mode mode, int *contended,
 		int alloc_flags, int classzone_idx)
 {
-	unsigned long ret;
+	enum compact_result ret;
 	struct compact_control cc = {
 		.nr_freepages = 0,
 		.nr_migratepages = 0,
@@ -1524,7 +1525,7 @@ int sysctl_extfrag_threshold = 500;
  *
  * This is the main entry point for direct page compaction.
  */
-unsigned long try_to_compact_pages(gfp_t gfp_mask, unsigned int order,
+enum compact_result try_to_compact_pages(gfp_t gfp_mask, unsigned int order,
 			int alloc_flags, const struct alloc_context *ac,
 			enum migrate_mode mode, int *contended)
 {
@@ -1532,7 +1533,7 @@ unsigned long try_to_compact_pages(gfp_t gfp_mask, unsigned int order,
 	int may_perform_io = gfp_mask & __GFP_IO;
 	struct zoneref *z;
 	struct zone *zone;
-	int rc = COMPACT_DEFERRED;
+	enum compact_result rc = COMPACT_DEFERRED;
 	int all_zones_contended = COMPACT_CONTENDED_LOCK; /* init for &= op */
 
 	*contended = COMPACT_CONTENDED_NONE;
@@ -1546,7 +1547,7 @@ unsigned long try_to_compact_pages(gfp_t gfp_mask, unsigned int order,
 	/* Compact each zone in the list */
 	for_each_zone_zonelist_nodemask(zone, z, ac->zonelist, ac->high_zoneidx,
 								ac->nodemask) {
-		int status;
+		enum compact_result status;
 		int zone_contended;
 
 		if (compaction_deferred(zone, order))
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 269a04f20927..4acc0aa1aee0 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2821,7 +2821,7 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
 		enum migrate_mode mode, int *contended_compaction,
 		bool *deferred_compaction)
 {
-	unsigned long compact_result;
+	enum compact_result compact_result;
 	struct page *page;
 
 	if (!order)
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
