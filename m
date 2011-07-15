Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 86E4F6B0083
	for <linux-mm@kvack.org>; Fri, 15 Jul 2011 10:59:45 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 3/3] mm: page allocator: Reconsider zones for allocation after direct reclaim
Date: Fri, 15 Jul 2011 15:59:39 +0100
Message-Id: <1310741979-21374-3-git-send-email-mgorman@suse.de>
In-Reply-To: <1310741979-21374-1-git-send-email-mgorman@suse.de>
References: <1310741979-21374-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

With zone_reclaim_mode enabled, it's possible for zones to be considered
full in the zonelist_cache so they are skipped in the future. If the
process enters direct reclaim, the ZLC may still consider zones to be
full even after reclaiming pages. Reconsider all zones for allocation
if direct reclaim returns successfully.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/page_alloc.c |   19 +++++++++++++++++++
 1 files changed, 19 insertions(+), 0 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 6913854..149409c 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1616,6 +1616,21 @@ static void zlc_mark_zone_full(struct zonelist *zonelist, struct zoneref *z)
 	set_bit(i, zlc->fullzones);
 }
 
+/*
+ * clear all zones full, called after direct reclaim makes progress so that
+ * a zone that was recently full is not skipped over for up to a second
+ */
+static void zlc_clear_zones_full(struct zonelist *zonelist)
+{
+	struct zonelist_cache *zlc;	/* cached zonelist speedup info */
+
+	zlc = zonelist->zlcache_ptr;
+	if (!zlc)
+		return;
+
+	bitmap_zero(zlc->fullzones, MAX_ZONES_PER_ZONELIST);
+}
+
 #else	/* CONFIG_NUMA */
 
 static nodemask_t *zlc_setup(struct zonelist *zonelist, int alloc_flags)
@@ -1963,6 +1978,10 @@ __alloc_pages_direct_reclaim(gfp_t gfp_mask, unsigned int order,
 	if (unlikely(!(*did_some_progress)))
 		return NULL;
 
+	/* After successful reclaim, reconsider all zones for allocation */
+	if (NUMA_BUILD)
+		zlc_clear_zones_full(zonelist);
+
 retry:
 	page = get_page_from_freelist(gfp_mask, nodemask, order,
 					zonelist, high_zoneidx,
-- 
1.7.3.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
