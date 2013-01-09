Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id A8BDC6B005D
	for <linux-mm@kvack.org>; Wed,  9 Jan 2013 08:50:15 -0500 (EST)
Date: Wed, 9 Jan 2013 13:50:10 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: ppoll() stuck on POLLIN while TCP peer is sending
Message-ID: <20130109135010.GB13475@suse.de>
References: <20121228014503.GA5017@dcvr.yhbt.net>
 <20130102200848.GA4500@dcvr.yhbt.net>
 <20130104160148.GB3885@suse.de>
 <20130106120700.GA24671@dcvr.yhbt.net>
 <20130107122516.GC3885@suse.de>
 <20130107223850.GA21311@dcvr.yhbt.net>
 <20130108224313.GA13304@suse.de>
 <20130108232325.GA5948@dcvr.yhbt.net>
 <20130109133746.GD13304@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20130109133746.GD13304@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Wong <normalperson@yhbt.net>
Cc: linux-mm@kvack.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan@kernel.org>, Eric Dumazet <eric.dumazet@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>

On Wed, Jan 09, 2013 at 01:37:46PM +0000, Mel Gorman wrote:
> On Tue, Jan 08, 2013 at 11:23:25PM +0000, Eric Wong wrote:
> > Mel Gorman <mgorman@suse.de> wrote:
> > > Please try the following patch. However, even if it works the benefit of
> > > capture may be so marginal that partially reverting it and simplifying
> > > compaction.c is the better decision.
> > 
> > I already got my VM stuck on this one.  I had two twosleepy instances,
> > 2774 was the one that got stuck (also confirmed by watching top).
> > 
> 
> page->pfmemalloc can be left set for captured pages so try this but as
> capture is rarely used I'm strongly favouring a partial revert even if
> this works for you.

Partial revert looks like this

---8<---

---
 include/linux/compaction.h |    4 +-
 include/linux/mm.h         |    1 -
 mm/compaction.c            |   91 ++++++--------------------------------------
 mm/internal.h              |    1 -
 mm/page_alloc.c            |   38 +++++-------------
 5 files changed, 23 insertions(+), 112 deletions(-)

diff --git a/include/linux/compaction.h b/include/linux/compaction.h
index 6ecb6dc..cc7bdde 100644
--- a/include/linux/compaction.h
+++ b/include/linux/compaction.h
@@ -22,7 +22,7 @@ extern int sysctl_extfrag_handler(struct ctl_table *table, int write,
 extern int fragmentation_index(struct zone *zone, unsigned int order);
 extern unsigned long try_to_compact_pages(struct zonelist *zonelist,
 			int order, gfp_t gfp_mask, nodemask_t *mask,
-			bool sync, bool *contended, struct page **page);
+			bool sync, bool *contended);
 extern int compact_pgdat(pg_data_t *pgdat, int order);
 extern void reset_isolation_suitable(pg_data_t *pgdat);
 extern unsigned long compaction_suitable(struct zone *zone, int order);
@@ -75,7 +75,7 @@ static inline bool compaction_restarting(struct zone *zone, int order)
 #else
 static inline unsigned long try_to_compact_pages(struct zonelist *zonelist,
 			int order, gfp_t gfp_mask, nodemask_t *nodemask,
-			bool sync, bool *contended, struct page **page)
+			bool sync, bool *contended)
 {
 	return COMPACT_CONTINUE;
 }
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 6320407..66e2f7c 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -455,7 +455,6 @@ void put_pages_list(struct list_head *pages);
 
 void split_page(struct page *page, unsigned int order);
 int split_free_page(struct page *page);
-int capture_free_page(struct page *page, int alloc_order, int migratetype);
 
 /*
  * Compound pages have a destructor function.  Provide a
diff --git a/mm/compaction.c b/mm/compaction.c
index 6b807e4..8bc3066 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -816,6 +816,7 @@ static isolate_migrate_t isolate_migratepages(struct zone *zone,
 static int compact_finished(struct zone *zone,
 			    struct compact_control *cc)
 {
+	unsigned int order;
 	unsigned long watermark;
 
 	if (fatal_signal_pending(current))
@@ -850,22 +851,15 @@ static int compact_finished(struct zone *zone,
 		return COMPACT_CONTINUE;
 
 	/* Direct compactor: Is a suitable page free? */
-	if (cc->page) {
-		/* Was a suitable page captured? */
-		if (*cc->page)
+	for (order = cc->order; order < MAX_ORDER; order++) {
+		struct free_area *area = &zone->free_area[cc->order];
+		/* Job done if page is free of the right migratetype */
+		if (!list_empty(&area->free_list[cc->migratetype]))
+			return COMPACT_PARTIAL;
+
+		/* Job done if allocation would set block type */
+		if (cc->order >= pageblock_order && area->nr_free)
 			return COMPACT_PARTIAL;
-	} else {
-		unsigned int order;
-		for (order = cc->order; order < MAX_ORDER; order++) {
-			struct free_area *area = &zone->free_area[cc->order];
-			/* Job done if page is free of the right migratetype */
-			if (!list_empty(&area->free_list[cc->migratetype]))
-				return COMPACT_PARTIAL;
-
-			/* Job done if allocation would set block type */
-			if (cc->order >= pageblock_order && area->nr_free)
-				return COMPACT_PARTIAL;
-		}
 	}
 
 	return COMPACT_CONTINUE;
@@ -921,60 +915,6 @@ unsigned long compaction_suitable(struct zone *zone, int order)
 	return COMPACT_CONTINUE;
 }
 
-static void compact_capture_page(struct compact_control *cc)
-{
-	unsigned long flags;
-	int mtype, mtype_low, mtype_high;
-
-	if (!cc->page || *cc->page)
-		return;
-
-	/*
-	 * For MIGRATE_MOVABLE allocations we capture a suitable page ASAP
-	 * regardless of the migratetype of the freelist is is captured from.
-	 * This is fine because the order for a high-order MIGRATE_MOVABLE
-	 * allocation is typically at least a pageblock size and overall
-	 * fragmentation is not impaired. Other allocation types must
-	 * capture pages from their own migratelist because otherwise they
-	 * could pollute other pageblocks like MIGRATE_MOVABLE with
-	 * difficult to move pages and making fragmentation worse overall.
-	 */
-	if (cc->migratetype == MIGRATE_MOVABLE) {
-		mtype_low = 0;
-		mtype_high = MIGRATE_PCPTYPES;
-	} else {
-		mtype_low = cc->migratetype;
-		mtype_high = cc->migratetype + 1;
-	}
-
-	/* Speculatively examine the free lists without zone lock */
-	for (mtype = mtype_low; mtype < mtype_high; mtype++) {
-		int order;
-		for (order = cc->order; order < MAX_ORDER; order++) {
-			struct page *page;
-			struct free_area *area;
-			area = &(cc->zone->free_area[order]);
-			if (list_empty(&area->free_list[mtype]))
-				continue;
-
-			/* Take the lock and attempt capture of the page */
-			if (!compact_trylock_irqsave(&cc->zone->lock, &flags, cc))
-				return;
-			if (!list_empty(&area->free_list[mtype])) {
-				page = list_entry(area->free_list[mtype].next,
-							struct page, lru);
-				if (capture_free_page(page, cc->order, mtype)) {
-					spin_unlock_irqrestore(&cc->zone->lock,
-									flags);
-					*cc->page = page;
-					return;
-				}
-			}
-			spin_unlock_irqrestore(&cc->zone->lock, flags);
-		}
-	}
-}
-
 static int compact_zone(struct zone *zone, struct compact_control *cc)
 {
 	int ret;
@@ -1054,9 +994,6 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
 				goto out;
 			}
 		}
-
-		/* Capture a page now if it is a suitable size */
-		compact_capture_page(cc);
 	}
 
 out:
@@ -1069,8 +1006,7 @@ out:
 
 static unsigned long compact_zone_order(struct zone *zone,
 				 int order, gfp_t gfp_mask,
-				 bool sync, bool *contended,
-				 struct page **page)
+				 bool sync, bool *contended)
 {
 	unsigned long ret;
 	struct compact_control cc = {
@@ -1080,7 +1016,6 @@ static unsigned long compact_zone_order(struct zone *zone,
 		.migratetype = allocflags_to_migratetype(gfp_mask),
 		.zone = zone,
 		.sync = sync,
-		.page = page,
 	};
 	INIT_LIST_HEAD(&cc.freepages);
 	INIT_LIST_HEAD(&cc.migratepages);
@@ -1110,7 +1045,7 @@ int sysctl_extfrag_threshold = 500;
  */
 unsigned long try_to_compact_pages(struct zonelist *zonelist,
 			int order, gfp_t gfp_mask, nodemask_t *nodemask,
-			bool sync, bool *contended, struct page **page)
+			bool sync, bool *contended)
 {
 	enum zone_type high_zoneidx = gfp_zone(gfp_mask);
 	int may_enter_fs = gfp_mask & __GFP_FS;
@@ -1136,7 +1071,7 @@ unsigned long try_to_compact_pages(struct zonelist *zonelist,
 		int status;
 
 		status = compact_zone_order(zone, order, gfp_mask, sync,
-						contended, page);
+						contended);
 		rc = max(status, rc);
 
 		/* If a normal allocation would succeed, stop compacting */
@@ -1192,7 +1127,6 @@ int compact_pgdat(pg_data_t *pgdat, int order)
 	struct compact_control cc = {
 		.order = order,
 		.sync = false,
-		.page = NULL,
 	};
 
 	return __compact_pgdat(pgdat, &cc);
@@ -1203,7 +1137,6 @@ static int compact_node(int nid)
 	struct compact_control cc = {
 		.order = -1,
 		.sync = true,
-		.page = NULL,
 	};
 
 	return __compact_pgdat(NODE_DATA(nid), &cc);
diff --git a/mm/internal.h b/mm/internal.h
index d597f94..9ba2110 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -135,7 +135,6 @@ struct compact_control {
 	int migratetype;		/* MOVABLE, RECLAIMABLE etc */
 	struct zone *zone;
 	bool contended;			/* True if a lock was contended */
-	struct page **page;		/* Page captured of requested size */
 };
 
 unsigned long
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 4ba5e37..ebf7fd8 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1389,22 +1389,14 @@ void split_page(struct page *page, unsigned int order)
 		set_page_refcounted(page + i);
 }
 
-/*
- * Similar to the split_page family of functions except that the page
- * required at the given order and being isolated now to prevent races
- * with parallel allocators
- */
-int capture_free_page(struct page *page, int alloc_order, int migratetype)
+static int __isolate_free_page(struct page *page, unsigned int order)
 {
-	unsigned int order;
 	unsigned long watermark;
 	struct zone *zone;
 	int mt;
 
 	BUG_ON(!PageBuddy(page));
-
 	zone = page_zone(page);
-	order = page_order(page);
 	mt = get_pageblock_migratetype(page);
 
 	if (mt != MIGRATE_ISOLATE) {
@@ -1413,7 +1405,7 @@ int capture_free_page(struct page *page, int alloc_order, int migratetype)
 		if (!zone_watermark_ok(zone, 0, watermark, 0, 0))
 			return 0;
 
-		__mod_zone_freepage_state(zone, -(1UL << alloc_order), mt);
+		__mod_zone_freepage_state(zone, -(1UL << order), mt);
 	}
 
 	/* Remove page from free list */
@@ -1421,11 +1413,7 @@ int capture_free_page(struct page *page, int alloc_order, int migratetype)
 	zone->free_area[order].nr_free--;
 	rmv_page_order(page);
 
-	if (alloc_order != order)
-		expand(zone, page, alloc_order, order,
-			&zone->free_area[order], migratetype);
-
-	/* Set the pageblock if the captured page is at least a pageblock */
+	/* Set the pageblock if the isolated page is at least a pageblock */
 	if (order >= pageblock_order - 1) {
 		struct page *endpage = page + (1 << order) - 1;
 		for (; page < endpage; page += pageblock_nr_pages) {
@@ -1436,7 +1424,7 @@ int capture_free_page(struct page *page, int alloc_order, int migratetype)
 		}
 	}
 
-	return 1UL << alloc_order;
+	return 1UL << order;
 }
 
 /*
@@ -1451,13 +1439,12 @@ int capture_free_page(struct page *page, int alloc_order, int migratetype)
  */
 int split_free_page(struct page *page)
 {
-	unsigned int order;
+	unsigned int order = page_order(page);
 	int nr_pages;
 
-	BUG_ON(!PageBuddy(page));
 	order = page_order(page);
 
-	nr_pages = capture_free_page(page, order, 0);
+	nr_pages = __isolate_free_page(page, order);
 	if (!nr_pages)
 		return 0;
 
@@ -2163,8 +2150,6 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
 	bool *contended_compaction, bool *deferred_compaction,
 	unsigned long *did_some_progress)
 {
-	struct page *page = NULL;
-
 	if (!order)
 		return NULL;
 
@@ -2176,16 +2161,12 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
 	current->flags |= PF_MEMALLOC;
 	*did_some_progress = try_to_compact_pages(zonelist, order, gfp_mask,
 						nodemask, sync_migration,
-						contended_compaction, &page);
+						contended_compaction);
 	current->flags &= ~PF_MEMALLOC;
 
-	/* If compaction captured a page, prep and use it */
-	if (page) {
-		prep_new_page(page, order, gfp_mask);
-		goto got_page;
-	}
-
 	if (*did_some_progress != COMPACT_SKIPPED) {
+		struct page *page;
+
 		/* Page migration frees to the PCP lists but we want merging */
 		drain_pages(get_cpu());
 		put_cpu();
@@ -2195,7 +2176,6 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
 				alloc_flags & ~ALLOC_NO_WATERMARKS,
 				preferred_zone, migratetype);
 		if (page) {
-got_page:
 			preferred_zone->compact_blockskip_flush = false;
 			preferred_zone->compact_considered = 0;
 			preferred_zone->compact_defer_shift = 0;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
