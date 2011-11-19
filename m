Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 0C9826B006E
	for <linux-mm@kvack.org>; Sat, 19 Nov 2011 14:54:37 -0500 (EST)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 4/8] mm: compaction: defer compaction only with sync_migration
Date: Sat, 19 Nov 2011 20:54:16 +0100
Message-Id: <1321732460-14155-5-git-send-email-aarcange@redhat.com>
In-Reply-To: <1321635524-8586-1-git-send-email-mgorman@suse.de>
References: <1321635524-8586-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan.kim@gmail.com>, Jan Kara <jack@suse.cz>, Andy Isaacson <adi@hexapodia.org>, Johannes Weiner <jweiner@redhat.com>, linux-kernel@vger.kernel.org

Let only sync migration drive the
compaction_deferred()/defer_compaction() logic. So sync migration
isn't prevented to run if async migration fails. Without sync
migration pages requiring migrate.c:writeout() or a ->migratepage
operation (that isn't migrate_page) can't me migrated, and that has
the effect of polluting the movable pageblock with pages that won't be
migrated by async migration, so it's fundamental to guarantee sync
compaction will be run too before failing.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 mm/page_alloc.c |   50 ++++++++++++++++++++++++++++++--------------------
 1 files changed, 30 insertions(+), 20 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 9dd443d..2229f7d 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1891,7 +1891,7 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
 {
 	struct page *page;
 
-	if (!order || compaction_deferred(preferred_zone))
+	if (!order)
 		return NULL;
 
 	current->flags |= PF_MEMALLOC;
@@ -1921,7 +1921,8 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
 		 * but not enough to satisfy watermarks.
 		 */
 		count_vm_event(COMPACTFAIL);
-		defer_compaction(preferred_zone);
+		if (sync_migration)
+			defer_compaction(preferred_zone);
 
 		cond_resched();
 	}
@@ -2083,7 +2084,7 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 	int alloc_flags;
 	unsigned long pages_reclaimed = 0;
 	unsigned long did_some_progress;
-	bool sync_migration = false;
+	bool sync_migration = false, defer_compaction;
 
 	/*
 	 * In the slowpath, we sanity check order to avoid ever trying to
@@ -2160,15 +2161,20 @@ rebalance:
 	 * Try direct compaction. The first pass is asynchronous. Subsequent
 	 * attempts after direct reclaim are synchronous
 	 */
-	page = __alloc_pages_direct_compact(gfp_mask, order,
-					zonelist, high_zoneidx,
-					nodemask,
-					alloc_flags, preferred_zone,
-					migratetype, &did_some_progress,
-					sync_migration);
-	if (page)
-		goto got_pg;
-	sync_migration = true;
+	defer_compaction = compaction_deferred(preferred_zone);
+	if (!defer_compaction) {
+		page = __alloc_pages_direct_compact(gfp_mask, order,
+						    zonelist, high_zoneidx,
+						    nodemask,
+						    alloc_flags,
+						    preferred_zone,
+						    migratetype,
+						    &did_some_progress,
+						    sync_migration);
+		if (page)
+			goto got_pg;
+		sync_migration = true;
+	}
 
 	/* Try direct reclaim and then allocating */
 	page = __alloc_pages_direct_reclaim(gfp_mask, order,
@@ -2223,19 +2229,23 @@ rebalance:
 		wait_iff_congested(preferred_zone, BLK_RW_ASYNC, HZ/50);
 		goto rebalance;
 	} else {
-		/*
-		 * High-order allocations do not necessarily loop after
-		 * direct reclaim and reclaim/compaction depends on compaction
-		 * being called after reclaim so call directly if necessary
-		 */
-		page = __alloc_pages_direct_compact(gfp_mask, order,
+		if (!defer_compaction) {
+			/*
+			 * High-order allocations do not necessarily
+			 * loop after direct reclaim and
+			 * reclaim/compaction depends on compaction
+			 * being called after reclaim so call directly
+			 * if necessary
+			 */
+			page = __alloc_pages_direct_compact(gfp_mask, order,
 					zonelist, high_zoneidx,
 					nodemask,
 					alloc_flags, preferred_zone,
 					migratetype, &did_some_progress,
 					sync_migration);
-		if (page)
-			goto got_pg;
+			if (page)
+				goto got_pg;
+		}
 	}
 
 nopage:

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
