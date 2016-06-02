Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id A1CEA6B0263
	for <linux-mm@kvack.org>; Thu,  2 Jun 2016 08:21:46 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id w16so23410320lfd.0
        for <linux-mm@kvack.org>; Thu, 02 Jun 2016 05:21:46 -0700 (PDT)
Received: from outbound-smtp08.blacknight.com (outbound-smtp08.blacknight.com. [46.22.139.13])
        by mx.google.com with ESMTPS id v9si420322wjw.43.2016.06.02.05.21.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Jun 2016 05:21:44 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail01.blacknight.ie [81.17.254.10])
	by outbound-smtp08.blacknight.com (Postfix) with ESMTPS id 862821C12A8
	for <linux-mm@kvack.org>; Thu,  2 Jun 2016 13:21:44 +0100 (IST)
Date: Thu, 2 Jun 2016 13:21:42 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH] mm, page_alloc: Recalculate the preferred zoneref if the
 context can ignore memory policies
Message-ID: <20160602122142.GW2527@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Geert Uytterhoeven <geert@linux-m68k.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, linux-m68k <linux-m68k@lists.linux-m68k.org>

The optimistic fast path may use cpuset_current_mems_allowed instead of
of a NULL nodemask supplied by the caller for cpuset allocations. The
preferred zone is calculated on this basis for statistic purposes and
as a starting point in the zonelist iterator.

However, if the context can ignore memory policies due to being atomic or
being able to ignore watermarks then the starting point in the zonelist
iterator is no longer correct. This patch resets the zonelist iterator in
the allocator slowpath if the context can ignore memory policies. This will
alter the zone used for statistics but only after it is known that it makes
sense for that context. Resetting it before entering the slowpath would
potentially allow an ALLOC_CPUSET allocation to be accounted for against
the wrong zone. Note that while nodemask is not explicitly set to the
original nodemask, it would only have been overwritten if cpuset_enabled()
and it was reset before the slowpath was entered.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
Acked-by: Vlastimil Babka <vbabka@suse.cz>
---
 mm/page_alloc.c | 23 ++++++++++++++++-------
 1 file changed, 16 insertions(+), 7 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 557549c81083..b17358617a1b 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3598,6 +3598,17 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 	 */
 	alloc_flags = gfp_to_alloc_flags(gfp_mask);
 
+	/*
+	 * Reset the zonelist iterators if memory policies can be ignored.
+	 * These allocations are high priority and system rather than user
+	 * orientated.
+	 */
+	if ((alloc_flags & ALLOC_NO_WATERMARKS) || !(alloc_flags & ALLOC_CPUSET)) {
+		ac->zonelist = node_zonelist(numa_node_id(), gfp_mask);
+		ac->preferred_zoneref = first_zones_zonelist(ac->zonelist,
+					ac->high_zoneidx, ac->nodemask);
+	}
+
 	/* This is the last chance, in general, before the goto nopage. */
 	page = get_page_from_freelist(gfp_mask, order,
 				alloc_flags & ~ALLOC_NO_WATERMARKS, ac);
@@ -3606,12 +3617,6 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 
 	/* Allocate without watermarks if the context allows */
 	if (alloc_flags & ALLOC_NO_WATERMARKS) {
-		/*
-		 * Ignore mempolicies if ALLOC_NO_WATERMARKS on the grounds
-		 * the allocation is high priority and these type of
-		 * allocations are system rather than user orientated
-		 */
-		ac->zonelist = node_zonelist(numa_node_id(), gfp_mask);
 		page = get_page_from_freelist(gfp_mask, order,
 						ALLOC_NO_WATERMARKS, ac);
 		if (page)
@@ -3810,7 +3815,11 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
 	/* Dirty zone balancing only done in the fast path */
 	ac.spread_dirty_pages = (gfp_mask & __GFP_WRITE);
 
-	/* The preferred zone is used for statistics later */
+	/*
+	 * The preferred zone is used for statistics but crucially it is
+	 * also used as the starting point for the zonelist iterator. It
+	 * may get reset for allocations that ignore memory policies.
+	 */
 	ac.preferred_zoneref = first_zones_zonelist(ac.zonelist,
 					ac.high_zoneidx, ac.nodemask);
 	if (!ac.preferred_zoneref) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
