Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f179.google.com (mail-pf0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 14EA06B0038
	for <linux-mm@kvack.org>; Wed, 16 Dec 2015 00:37:25 -0500 (EST)
Received: by mail-pf0-f179.google.com with SMTP id o64so6340554pfb.3
        for <linux-mm@kvack.org>; Tue, 15 Dec 2015 21:37:25 -0800 (PST)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTPS id eg4si6875395pac.40.2015.12.15.21.37.23
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 15 Dec 2015 21:37:23 -0800 (PST)
Date: Wed, 16 Dec 2015 14:39:03 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v3 6/7] mm/compaction: introduce migration scan limit
Message-ID: <20151216053903.GA13808@js1304-P5Q-DELUXE>
References: <1449126681-19647-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1449126681-19647-7-git-send-email-iamjoonsoo.kim@lge.com>
 <566E8D3A.5030804@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <566E8D3A.5030804@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, Dec 14, 2015 at 10:34:50AM +0100, Vlastimil Babka wrote:
> On 12/03/2015 08:11 AM, Joonsoo Kim wrote:
> >This is preparation step to replace compaction deferring with compaction
> >limit. Whole reason why we need to replace it will be mentioned in
> >the following patch.
> >
> >In this patch, migration_scan_limit is assigned and accounted, but, not
> >checked to finish. So, there is no functional change.
> >
> >Currently, amount of migration_scan_limit is chosen to imitate compaction
> >deferring logic. We can tune it easily if overhead looks insane, but,
> >it would be further work.
> >Also, amount of migration_scan_limit is adapted by compact_defer_shift.
> >More fails increase compact_defer_shift and this will limit compaction
> >more.
> >
> >There are two interesting changes. One is that cached pfn is always
> >updated while limit is activated. Otherwise, we would scan same range
> >over and over. Second one is that async compaction is skipped while
> >limit is activated, for algorithm correctness. Until now, even if
> >failure case, sync compaction continue to work when both scanner is met
> >so COMPACT_COMPLETE usually happens in sync compaction. But, limit is
> >applied, sync compaction is finished if limit is exhausted so
> >COMPACT_COMPLETE usually happens in async compaction. Because we don't
> >consider async COMPACT_COMPLETE as actual fail while we reset cached
> >scanner pfn
> 
> I don't see where compaction being sync/async applies to "reset
> cached scanner pfn". I assume you actually meant the call to
> defer_compaction() in try_to_compact_pages, which only happens for
> async compaction?

What I wanted to say is that reset_cached_positions() is called in
__compact_finished() for async compaction and defer_compaction() isn't
called for this case.

> 
> >defer mechanism doesn't work well. And, async compaction
> >would not be easy to succeed in this case so skipping async compaction
> >doesn't result in much difference.
> 
> So, the alternative to avoiding async compaction would be to call
> defer_compaction() also when async compaction completes, right?
> Which doesn't sound as scary when deferring isn't an on/off thing,
> but applies a limit.

Yeah, it would be one alternative but I'm not sure it works well. I
can think one scenario that this doesn't work well.

1) Asume that most of pageblocks are non-movable and limit is activated.
2) Async compaction skips non-movable pageblocks and scanners are
  easily met without compaction success. Then, cache pfn is reset.
3) Sync compaction scans few pageblocks on front part of zone and
  fails due to reset cache pfn and limit.
4) 2 and 3 happen again for next compaction request.

If we allow async compaction's migration scanner to scan non-movable
pageblock in this case, everything will work fine.

How about allowing async compaction's migration scanner to scan
non-movable pageblock *always*? Reason that async compaction doesn't
scan it is to succeed compaction without much stall but it makes
compaction too complicated. For example, defer_compaction() cannot be
called for async compaction and compaction works different according to
pageblock type distribution on the system. We already have a logic to
control stall so stall would not matter now. If it doesn't work well,
we can change it by always applying scan limit to async compaction.
It could cause lower success rate on async compaction but I don't
think it causes a problem because it's not that hard to succeed to
make high-order page up to PAGE_ALLOC_COSTLY_ORDER even in non-movable
pageblock. For request more than PAGE_ALLOC_COSTLY order, we don't
need to consider success rate much because it isn't easy to succeed
on async compaction.

> This would also help the issue with THP fault compactions being only
> async and thus never deferring anything, which I think showed itself
> in Aaron's reports. This current patch wouldn't help there I think,
> as without sync compaction the system would never start to apply the

Yes, if async compaction calls defer_compaction(), Aaron's problem
would be mitigated.

> limit in the first place, and would be stuck with the ill-defined
> contended compaction detection based on need_resched etc.

I also think that contended compaction detection based on need_resched()
should be changed. If there is just one task on cpu, it isn't triggered.
It would be better to apply scan limit in this case.

Thanks.

> 
> >Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> >---
> >  mm/compaction.c | 88 +++++++++++++++++++++++++++++++++++++++++++++++++--------
> >  mm/internal.h   |  1 +
> >  2 files changed, 78 insertions(+), 11 deletions(-)
> >
> >diff --git a/mm/compaction.c b/mm/compaction.c
> >index 1a75a6e..b23f6d9 100644
> >--- a/mm/compaction.c
> >+++ b/mm/compaction.c
> >@@ -116,6 +116,67 @@ static struct page *pageblock_pfn_to_page(unsigned long start_pfn,
> >
> >  #ifdef CONFIG_COMPACTION
> >
> >+/*
> >+ * order == -1 is expected when compacting via
> >+ * /proc/sys/vm/compact_memory
> >+ */
> >+static inline bool is_via_compact_memory(int order)
> >+{
> >+	return order == -1;
> >+}
> >+
> >+#define COMPACT_MIN_SCAN_LIMIT (pageblock_nr_pages)
> >+
> >+static bool excess_migration_scan_limit(struct compact_control *cc)
> >+{
> >+	/* Disable scan limit for now */
> >+	return false;
> >+}
> >+
> >+static void set_migration_scan_limit(struct compact_control *cc)
> >+{
> >+	struct zone *zone = cc->zone;
> >+	int order = cc->order;
> >+	unsigned long limit = zone->managed_pages;
> >+
> >+	cc->migration_scan_limit = LONG_MAX;
> >+	if (is_via_compact_memory(order))
> >+		return;
> >+
> >+	if (order < zone->compact_order_failed)
> >+		return;
> >+
> >+	if (!zone->compact_defer_shift)
> >+		return;
> >+
> >+	/*
> >+	 * Do not allow async compaction during limit work. In this case,
> >+	 * async compaction would not be easy to succeed and we need to
> >+	 * ensure that COMPACT_COMPLETE occurs by sync compaction for
> >+	 * algorithm correctness and prevention of async compaction will
> >+	 * lead it.
> >+	 */
> >+	if (cc->mode == MIGRATE_ASYNC) {
> >+		cc->migration_scan_limit = -1;
> >+		return;
> >+	}
> >+
> >+	/* Migration scanner usually scans less than 1/4 pages */
> >+	limit >>= 2;
> >+
> >+	/*
> >+	 * Deferred compaction restart compaction every 64 compaction
> >+	 * attempts and it rescans whole zone range. To imitate it,
> >+	 * we set limit to 1/64 of scannable range.
> >+	 */
> >+	limit >>= 6;
> >+
> >+	/* Degradation scan limit according to defer shift */
> >+	limit >>= zone->compact_defer_shift;
> >+
> >+	cc->migration_scan_limit = max(limit, COMPACT_MIN_SCAN_LIMIT);
> >+}
> >+
> >  /* Do not skip compaction more than 64 times */
> >  #define COMPACT_MAX_DEFER_SHIFT 6
> >
> >@@ -263,10 +324,15 @@ static void update_pageblock_skip(struct compact_control *cc,
> >  	if (!page)
> >  		return;
> >
> >-	if (nr_isolated)
> >+	/*
> >+	 * Always update cached_pfn if compaction has scan_limit,
> >+	 * otherwise we would scan same range over and over.
> >+	 */
> >+	if (cc->migration_scan_limit == LONG_MAX && nr_isolated)
> >  		return;
> >
> >-	set_pageblock_skip(page);
> >+	if (!nr_isolated)
> >+		set_pageblock_skip(page);
> >
> >  	/* Update where async and sync compaction should restart */
> >  	if (migrate_scanner) {
> >@@ -822,6 +888,8 @@ isolate_success:
> >  	if (locked)
> >  		spin_unlock_irqrestore(&zone->lru_lock, flags);
> >
> >+	cc->migration_scan_limit -= nr_scanned;
> >+
> >  	trace_mm_compaction_isolate_migratepages(start_pfn, low_pfn,
> >  						nr_scanned, nr_isolated);
> >
> >@@ -1186,15 +1254,6 @@ static isolate_migrate_t isolate_migratepages(struct zone *zone,
> >  	return cc->nr_migratepages ? ISOLATE_SUCCESS : ISOLATE_NONE;
> >  }
> >
> >-/*
> >- * order == -1 is expected when compacting via
> >- * /proc/sys/vm/compact_memory
> >- */
> >-static inline bool is_via_compact_memory(int order)
> >-{
> >-	return order == -1;
> >-}
> >-
> >  static int __compact_finished(struct zone *zone, struct compact_control *cc,
> >  			    const int migratetype)
> >  {
> >@@ -1224,6 +1283,9 @@ static int __compact_finished(struct zone *zone, struct compact_control *cc,
> >  	if (is_via_compact_memory(cc->order))
> >  		return COMPACT_CONTINUE;
> >
> >+	if (excess_migration_scan_limit(cc))
> >+		return COMPACT_PARTIAL;
> >+
> >  	/* Compaction run is not finished if the watermark is not met */
> >  	watermark = low_wmark_pages(zone);
> >
> >@@ -1382,6 +1444,10 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
> >  	}
> >  	cc->last_migrated_pfn = 0;
> >
> >+	set_migration_scan_limit(cc);
> >+	if (excess_migration_scan_limit(cc))
> >+		return COMPACT_SKIPPED;
> >+
> >  	trace_mm_compaction_begin(start_pfn, cc->migrate_pfn,
> >  				cc->free_pfn, end_pfn, sync);
> >
> >diff --git a/mm/internal.h b/mm/internal.h
> >index dbe0436..bb8225c 100644
> >--- a/mm/internal.h
> >+++ b/mm/internal.h
> >@@ -164,6 +164,7 @@ struct compact_control {
> >  	unsigned long free_pfn;		/* isolate_freepages search base */
> >  	unsigned long migrate_pfn;	/* isolate_migratepages search base */
> >  	unsigned long last_migrated_pfn;/* Not yet flushed page being freed */
> >+	long migration_scan_limit;      /* Limit migration scanner activity */
> >  	enum migrate_mode mode;		/* Async or sync migration mode */
> >  	bool ignore_skip_hint;		/* Scan blocks even if marked skip */
> >  	int order;			/* order a direct compactor needs */
> >
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
