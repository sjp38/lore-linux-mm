Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id A7D136B005D
	for <linux-mm@kvack.org>; Fri, 16 Oct 2009 06:37:34 -0400 (EDT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 2/2] page allocator: Direct reclaim should always obey watermarks
Date: Fri, 16 Oct 2009 11:37:26 +0100
Message-Id: <1255689446-3858-3-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1255689446-3858-1-git-send-email-mel@csn.ul.ie>
References: <1255689446-3858-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>, stable <stable@kernel.org>
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>, David Miller <davem@davemloft.net>, Frans Pop <elendil@planet.nl>, reinette chatre <reinette.chatre@intel.com>, Kalle Valo <kalle.valo@iki.fi>, "John W. Linville" <linville@tuxdriver.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>, Karol Lewandowski <karol.k.lewandowski@gmail.com>, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, "linux-mm@kvack.org\"" <linux-mm@kvack.org>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

ALLOC_NO_WATERMARKS should be cleared when trying to allocate from the
free-lists after a direct reclaim. If it's not, __GFP_NOFAIL allocations
from a process that is exiting can ignore watermarks. __GFP_NOFAIL is not
often used but the journal layer is one of those places. This is suspected of
causing an increase in the number of GFP_ATOMIC allocation failures reported.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---
 mm/page_alloc.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index dfa4362..a3e5fed 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1860,7 +1860,8 @@ rebalance:
 	page = __alloc_pages_direct_reclaim(gfp_mask, order,
 					zonelist, high_zoneidx,
 					nodemask,
-					alloc_flags, preferred_zone,
+					alloc_flags & ~ALLOC_NO_WATERMARKS,
+					preferred_zone,
 					migratetype, &did_some_progress);
 	if (page)
 		goto got_pg;
-- 
1.6.3.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
