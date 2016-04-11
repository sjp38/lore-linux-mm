Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f48.google.com (mail-wm0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id 3AEAC6B0266
	for <linux-mm@kvack.org>; Mon, 11 Apr 2016 04:14:21 -0400 (EDT)
Received: by mail-wm0-f48.google.com with SMTP id a140so2095023wma.0
        for <linux-mm@kvack.org>; Mon, 11 Apr 2016 01:14:21 -0700 (PDT)
Received: from outbound-smtp03.blacknight.com (outbound-smtp03.blacknight.com. [81.17.249.16])
        by mx.google.com with ESMTPS id fy10si27520272wjc.144.2016.04.11.01.14.19
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 11 Apr 2016 01:14:20 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail01.blacknight.ie [81.17.254.10])
	by outbound-smtp03.blacknight.com (Postfix) with ESMTPS id C9DBB98B80
	for <linux-mm@kvack.org>; Mon, 11 Apr 2016 08:14:19 +0000 (UTC)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 08/22] mm, page_alloc: Convert alloc_flags to unsigned
Date: Mon, 11 Apr 2016 09:13:31 +0100
Message-Id: <1460362424-26369-9-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1460362424-26369-1-git-send-email-mgorman@techsingularity.net>
References: <1460362424-26369-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

alloc_flags is a bitmask of flags but it is signed which does not
necessarily generate the best code depending on the compiler. Even
without an impact, it makes more sense that this be unsigned.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 include/linux/compaction.h |  6 +++---
 include/linux/mmzone.h     |  3 ++-
 mm/compaction.c            | 12 +++++++-----
 mm/internal.h              |  2 +-
 mm/page_alloc.c            | 26 ++++++++++++++------------
 5 files changed, 27 insertions(+), 22 deletions(-)

diff --git a/include/linux/compaction.h b/include/linux/compaction.h
index d7c8de583a23..242b660f64e6 100644
--- a/include/linux/compaction.h
+++ b/include/linux/compaction.h
@@ -39,12 +39,12 @@ extern int sysctl_compact_unevictable_allowed;
 
 extern int fragmentation_index(struct zone *zone, unsigned int order);
 extern unsigned long try_to_compact_pages(gfp_t gfp_mask, unsigned int order,
-			int alloc_flags, const struct alloc_context *ac,
-			enum migrate_mode mode, int *contended);
+		unsigned int alloc_flags, const struct alloc_context *ac,
+		enum migrate_mode mode, int *contended);
 extern void compact_pgdat(pg_data_t *pgdat, int order);
 extern void reset_isolation_suitable(pg_data_t *pgdat);
 extern unsigned long compaction_suitable(struct zone *zone, int order,
-					int alloc_flags, int classzone_idx);
+		unsigned int alloc_flags, int classzone_idx);
 
 extern void defer_compaction(struct zone *zone, int order);
 extern bool compaction_deferred(struct zone *zone, int order);
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 0c4d5ebb3849..f49bb9add372 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -747,7 +747,8 @@ extern struct mutex zonelists_mutex;
 void build_all_zonelists(pg_data_t *pgdat, struct zone *zone);
 void wakeup_kswapd(struct zone *zone, int order, enum zone_type classzone_idx);
 bool zone_watermark_ok(struct zone *z, unsigned int order,
-		unsigned long mark, int classzone_idx, int alloc_flags);
+		unsigned long mark, int classzone_idx,
+		unsigned int alloc_flags);
 bool zone_watermark_ok_safe(struct zone *z, unsigned int order,
 		unsigned long mark, int classzone_idx);
 enum memmap_context {
diff --git a/mm/compaction.c b/mm/compaction.c
index ccf97b02b85f..244bb669b5a6 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -1259,7 +1259,8 @@ static int compact_finished(struct zone *zone, struct compact_control *cc,
  *   COMPACT_CONTINUE - If compaction should run now
  */
 static unsigned long __compaction_suitable(struct zone *zone, int order,
-					int alloc_flags, int classzone_idx)
+					unsigned int alloc_flags,
+					int classzone_idx)
 {
 	int fragindex;
 	unsigned long watermark;
@@ -1304,7 +1305,8 @@ static unsigned long __compaction_suitable(struct zone *zone, int order,
 }
 
 unsigned long compaction_suitable(struct zone *zone, int order,
-					int alloc_flags, int classzone_idx)
+					unsigned int alloc_flags,
+					int classzone_idx)
 {
 	unsigned long ret;
 
@@ -1464,7 +1466,7 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
 
 static unsigned long compact_zone_order(struct zone *zone, int order,
 		gfp_t gfp_mask, enum migrate_mode mode, int *contended,
-		int alloc_flags, int classzone_idx)
+		unsigned int alloc_flags, int classzone_idx)
 {
 	unsigned long ret;
 	struct compact_control cc = {
@@ -1505,8 +1507,8 @@ int sysctl_extfrag_threshold = 500;
  * This is the main entry point for direct page compaction.
  */
 unsigned long try_to_compact_pages(gfp_t gfp_mask, unsigned int order,
-			int alloc_flags, const struct alloc_context *ac,
-			enum migrate_mode mode, int *contended)
+		unsigned int alloc_flags, const struct alloc_context *ac,
+		enum migrate_mode mode, int *contended)
 {
 	int may_enter_fs = gfp_mask & __GFP_FS;
 	int may_perform_io = gfp_mask & __GFP_IO;
diff --git a/mm/internal.h b/mm/internal.h
index b79abb6721cf..f6d0a5875ec4 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -175,7 +175,7 @@ struct compact_control {
 	bool direct_compaction;		/* False from kcompactd or /proc/... */
 	int order;			/* order a direct compactor needs */
 	const gfp_t gfp_mask;		/* gfp mask of a direct compactor */
-	const int alloc_flags;		/* alloc flags of a direct compactor */
+	const unsigned int alloc_flags;	/* alloc flags of a direct compactor */
 	const int classzone_idx;	/* zone index of a direct compactor */
 	struct zone *zone;
 	int contended;			/* Signal need_sched() or lock
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index d00847bb1612..4bce6298dd07 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1526,7 +1526,7 @@ static inline bool free_pages_prezeroed(bool poisoned)
 }
 
 static int prep_new_page(struct page *page, unsigned int order, gfp_t gfp_flags,
-								int alloc_flags)
+							unsigned int alloc_flags)
 {
 	int i;
 	bool poisoned = true;
@@ -2388,7 +2388,8 @@ static inline void zone_statistics(struct zone *preferred_zone, struct zone *z,
 static inline
 struct page *buffered_rmqueue(struct zone *preferred_zone,
 			struct zone *zone, unsigned int order,
-			gfp_t gfp_flags, int alloc_flags, int migratetype)
+			gfp_t gfp_flags, unsigned int alloc_flags,
+			int migratetype)
 {
 	unsigned long flags;
 	struct page *page;
@@ -2542,12 +2543,13 @@ static inline bool should_fail_alloc_page(gfp_t gfp_mask, unsigned int order)
  * to check in the allocation paths if no pages are free.
  */
 static bool __zone_watermark_ok(struct zone *z, unsigned int order,
-			unsigned long mark, int classzone_idx, int alloc_flags,
+			unsigned long mark, int classzone_idx,
+			unsigned int alloc_flags,
 			long free_pages)
 {
 	long min = mark;
 	int o;
-	const int alloc_harder = (alloc_flags & ALLOC_HARDER);
+	const bool alloc_harder = (alloc_flags & ALLOC_HARDER);
 
 	/* free_pages may go negative - that's OK */
 	free_pages -= (1 << order) - 1;
@@ -2610,7 +2612,7 @@ static bool __zone_watermark_ok(struct zone *z, unsigned int order,
 }
 
 bool zone_watermark_ok(struct zone *z, unsigned int order, unsigned long mark,
-		      int classzone_idx, int alloc_flags)
+		      int classzone_idx, unsigned int alloc_flags)
 {
 	return __zone_watermark_ok(z, order, mark, classzone_idx, alloc_flags,
 					zone_page_state(z, NR_FREE_PAGES));
@@ -2958,7 +2960,7 @@ __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
 /* Try memory compaction for high-order allocations before reclaim */
 static struct page *
 __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
-		int alloc_flags, const struct alloc_context *ac,
+		unsigned int alloc_flags, const struct alloc_context *ac,
 		enum migrate_mode mode, int *contended_compaction,
 		bool *deferred_compaction)
 {
@@ -3014,7 +3016,7 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
 #else
 static inline struct page *
 __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
-		int alloc_flags, const struct alloc_context *ac,
+		unsigned int alloc_flags, const struct alloc_context *ac,
 		enum migrate_mode mode, int *contended_compaction,
 		bool *deferred_compaction)
 {
@@ -3054,7 +3056,7 @@ __perform_reclaim(gfp_t gfp_mask, unsigned int order,
 /* The really slow allocator path where we enter direct reclaim */
 static inline struct page *
 __alloc_pages_direct_reclaim(gfp_t gfp_mask, unsigned int order,
-		int alloc_flags, const struct alloc_context *ac,
+		unsigned int alloc_flags, const struct alloc_context *ac,
 		unsigned long *did_some_progress)
 {
 	struct page *page = NULL;
@@ -3093,10 +3095,10 @@ static void wake_all_kswapds(unsigned int order, const struct alloc_context *ac)
 		wakeup_kswapd(zone, order, zone_idx(ac->preferred_zone));
 }
 
-static inline int
+static inline unsigned int
 gfp_to_alloc_flags(gfp_t gfp_mask)
 {
-	int alloc_flags = ALLOC_WMARK_MIN | ALLOC_CPUSET;
+	unsigned int alloc_flags = ALLOC_WMARK_MIN | ALLOC_CPUSET;
 
 	/* __GFP_HIGH is assumed to be the same as ALLOC_HIGH to save a branch. */
 	BUILD_BUG_ON(__GFP_HIGH != (__force gfp_t) ALLOC_HIGH);
@@ -3157,7 +3159,7 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 {
 	bool can_direct_reclaim = gfp_mask & __GFP_DIRECT_RECLAIM;
 	struct page *page = NULL;
-	int alloc_flags;
+	unsigned int alloc_flags;
 	unsigned long pages_reclaimed = 0;
 	unsigned long did_some_progress;
 	enum migrate_mode migration_mode = MIGRATE_ASYNC;
@@ -3349,7 +3351,7 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
 	struct zoneref *preferred_zoneref;
 	struct page *page = NULL;
 	unsigned int cpuset_mems_cookie;
-	int alloc_flags = ALLOC_WMARK_LOW|ALLOC_FAIR;
+	unsigned int alloc_flags = ALLOC_WMARK_LOW|ALLOC_FAIR;
 	gfp_t alloc_mask; /* The gfp_t that was actually used for allocation */
 	struct alloc_context ac = {
 		.high_zoneidx = gfp_zone(gfp_mask),
-- 
2.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
