Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id EEEC66B00F4
	for <linux-mm@kvack.org>; Wed, 22 Feb 2012 11:49:17 -0500 (EST)
Received: from euspt1 (mailout1.w1.samsung.com [210.118.77.11])
 by mailout1.w1.samsung.com
 (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14 2004))
 with ESMTP id <0LZT00JTE01Q7G@mailout1.w1.samsung.com> for linux-mm@kvack.org;
 Wed, 22 Feb 2012 16:49:03 +0000 (GMT)
Received: from linux.samsung.com ([106.116.38.10])
 by spt1.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0LZT003LA01PN7@spt1.w1.samsung.com> for
 linux-mm@kvack.org; Wed, 22 Feb 2012 16:49:02 +0000 (GMT)
Date: Wed, 22 Feb 2012 17:48:52 +0100
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: [PATCHv23 11/16] mm: extract reclaim code from
 __alloc_pages_direct_reclaim()
In-reply-to: <1329929337-16648-1-git-send-email-m.szyprowski@samsung.com>
Message-id: <1329929337-16648-12-git-send-email-m.szyprowski@samsung.com>
MIME-version: 1.0
Content-type: TEXT/PLAIN
Content-transfer-encoding: 7BIT
References: <1329929337-16648-1-git-send-email-m.szyprowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org
Cc: Michal Nazarewicz <mina86@mina86.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Russell King <linux@arm.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daniel Walker <dwalker@codeaurora.org>, Mel Gorman <mel@csn.ul.ie>, Arnd Bergmann <arnd@arndb.de>, Jesse Barker <jesse.barker@linaro.org>, Jonathan Corbet <corbet@lwn.net>, Chunsang Jeong <chunsang.jeong@linaro.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Gaignard <benjamin.gaignard@linaro.org>, Rob Clark <rob.clark@linaro.org>, Ohad Ben-Cohen <ohad@wizery.com>

This patch extracts common reclaim code from __alloc_pages_direct_reclaim()
function to separate function: __perform_reclaim() which can be later used
by alloc_contig_range().

Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
Cc: Michal Nazarewicz <mina86@mina86.com>
Acked-by: Mel Gorman <mel@csn.ul.ie>
Tested-by: Rob Clark <rob.clark@linaro.org>
Tested-by: Ohad Ben-Cohen <ohad@wizery.com>
Tested-by: Benjamin Gaignard <benjamin.gaignard@linaro.org>
Tested-by: Robert Nelson <robertcnelson@gmail.com>
---
 mm/page_alloc.c |   30 +++++++++++++++++++++---------
 1 files changed, 21 insertions(+), 9 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 0aa8079..7a0d286 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2143,16 +2143,13 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
 }
 #endif /* CONFIG_COMPACTION */
 
-/* The really slow allocator path where we enter direct reclaim */
-static inline struct page *
-__alloc_pages_direct_reclaim(gfp_t gfp_mask, unsigned int order,
-	struct zonelist *zonelist, enum zone_type high_zoneidx,
-	nodemask_t *nodemask, int alloc_flags, struct zone *preferred_zone,
-	int migratetype, unsigned long *did_some_progress)
+/* Perform direct synchronous page reclaim */
+static int
+__perform_reclaim(gfp_t gfp_mask, unsigned int order, struct zonelist *zonelist,
+		  nodemask_t *nodemask)
 {
-	struct page *page = NULL;
 	struct reclaim_state reclaim_state;
-	bool drained = false;
+	int progress;
 
 	cond_resched();
 
@@ -2163,7 +2160,7 @@ __alloc_pages_direct_reclaim(gfp_t gfp_mask, unsigned int order,
 	reclaim_state.reclaimed_slab = 0;
 	current->reclaim_state = &reclaim_state;
 
-	*did_some_progress = try_to_free_pages(zonelist, order, gfp_mask, nodemask);
+	progress = try_to_free_pages(zonelist, order, gfp_mask, nodemask);
 
 	current->reclaim_state = NULL;
 	lockdep_clear_current_reclaim_state();
@@ -2171,6 +2168,21 @@ __alloc_pages_direct_reclaim(gfp_t gfp_mask, unsigned int order,
 
 	cond_resched();
 
+	return progress;
+}
+
+/* The really slow allocator path where we enter direct reclaim */
+static inline struct page *
+__alloc_pages_direct_reclaim(gfp_t gfp_mask, unsigned int order,
+	struct zonelist *zonelist, enum zone_type high_zoneidx,
+	nodemask_t *nodemask, int alloc_flags, struct zone *preferred_zone,
+	int migratetype, unsigned long *did_some_progress)
+{
+	struct page *page = NULL;
+	bool drained = false;
+
+	*did_some_progress = __perform_reclaim(gfp_mask, order, zonelist,
+					       nodemask);
 	if (unlikely(!(*did_some_progress)))
 		return NULL;
 
-- 
1.7.1.569.g6f426

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
