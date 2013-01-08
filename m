Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx202.postini.com [74.125.245.202])
	by kanga.kvack.org (Postfix) with SMTP id CBD666B0062
	for <linux-mm@kvack.org>; Tue,  8 Jan 2013 17:43:19 -0500 (EST)
Date: Tue, 8 Jan 2013 22:43:13 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: ppoll() stuck on POLLIN while TCP peer is sending
Message-ID: <20130108224313.GA13304@suse.de>
References: <20121228014503.GA5017@dcvr.yhbt.net>
 <20130102200848.GA4500@dcvr.yhbt.net>
 <20130104160148.GB3885@suse.de>
 <20130106120700.GA24671@dcvr.yhbt.net>
 <20130107122516.GC3885@suse.de>
 <20130107223850.GA21311@dcvr.yhbt.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20130107223850.GA21311@dcvr.yhbt.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Wong <normalperson@yhbt.net>
Cc: linux-mm@kvack.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan@kernel.org>, Eric Dumazet <eric.dumazet@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>

On Mon, Jan 07, 2013 at 10:38:50PM +0000, Eric Wong wrote:
> Mel Gorman <mgorman@suse.de> wrote:
> > Right now it's difficult to see how the capture could be the source of
> > this bug but I'm not ruling it out either so try the following (untested
> > but should be ok) patch.  It's not a proper revert, it just disables the
> > capture page logic to see if it's at fault.
> 
> Things look good so far with your change.

Ok, so minimally reverting is an option once 2e30abd1 is preserved. The
original motivation for the patch was to improve allocation success rates
under load but due to a bug in the patch the likely source of the improvement
was due to compacting more for THP allocations.

> It's been running 2 hours on a VM and 1 hour on my regular machine.
> Will update again in a few hours (or sooner if it's stuck again).

When I looked at it for long enough I found a number of problems. Most
affect timing but two serious issues are in there. One affects how long
kswapd spends compacting versus reclaiming and the other increases lock
contention meaning that async compaction can abort early. Both are serious
and could explain why a driver would fail high-order allocations.

Please try the following patch. However, even if it works the benefit of
capture may be so marginal that partially reverting it and simplifying
compaction.c is the better decision.

diff --git a/mm/compaction.c b/mm/compaction.c
index 6b807e4..03c82c0 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -857,7 +857,8 @@ static int compact_finished(struct zone *zone,
 	} else {
 		unsigned int order;
 		for (order = cc->order; order < MAX_ORDER; order++) {
-			struct free_area *area = &zone->free_area[cc->order];
+			struct free_area *area = &zone->free_area[order];
+
 			/* Job done if page is free of the right migratetype */
 			if (!list_empty(&area->free_list[cc->migratetype]))
 				return COMPACT_PARTIAL;
@@ -929,6 +930,11 @@ static void compact_capture_page(struct compact_control *cc)
 	if (!cc->page || *cc->page)
 		return;
 
+	/* Check that watermarks are satisifed before acquiring locks */
+	if (!zone_watermark_ok(cc->zone, cc->order, low_wmark_pages(cc->zone),
+									0, 0))
+		return;
+
 	/*
 	 * For MIGRATE_MOVABLE allocations we capture a suitable page ASAP
 	 * regardless of the migratetype of the freelist is is captured from.
@@ -941,7 +947,7 @@ static void compact_capture_page(struct compact_control *cc)
 	 */
 	if (cc->migratetype == MIGRATE_MOVABLE) {
 		mtype_low = 0;
-		mtype_high = MIGRATE_PCPTYPES;
+		mtype_high = MIGRATE_PCPTYPES + 1;
 	} else {
 		mtype_low = cc->migratetype;
 		mtype_high = cc->migratetype + 1;
@@ -1118,7 +1124,6 @@ unsigned long try_to_compact_pages(struct zonelist *zonelist,
 	struct zoneref *z;
 	struct zone *zone;
 	int rc = COMPACT_SKIPPED;
-	int alloc_flags = 0;
 
 	/* Check if the GFP flags allow compaction */
 	if (!order || !may_enter_fs || !may_perform_io)
@@ -1126,10 +1131,6 @@ unsigned long try_to_compact_pages(struct zonelist *zonelist,
 
 	count_compact_event(COMPACTSTALL);
 
-#ifdef CONFIG_CMA
-	if (allocflags_to_migratetype(gfp_mask) == MIGRATE_MOVABLE)
-		alloc_flags |= ALLOC_CMA;
-#endif
 	/* Compact each zone in the list */
 	for_each_zone_zonelist_nodemask(zone, z, zonelist, high_zoneidx,
 								nodemask) {
@@ -1139,9 +1140,8 @@ unsigned long try_to_compact_pages(struct zonelist *zonelist,
 						contended, page);
 		rc = max(status, rc);
 
-		/* If a normal allocation would succeed, stop compacting */
-		if (zone_watermark_ok(zone, order, low_wmark_pages(zone), 0,
-				      alloc_flags))
+		/* If a page was captured, stop compacting */
+		if (*page)
 			break;
 	}
 
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 4ba5e37..9d20c13 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2180,10 +2180,8 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
 	current->flags &= ~PF_MEMALLOC;
 
 	/* If compaction captured a page, prep and use it */
-	if (page) {
-		prep_new_page(page, order, gfp_mask);
+	if (page && !prep_new_page(page, order, gfp_mask))
 		goto got_page;
-	}
 
 	if (*did_some_progress != COMPACT_SKIPPED) {
 		/* Page migration frees to the PCP lists but we want merging */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
