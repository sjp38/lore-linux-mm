Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 3C0306B005A
	for <linux-mm@kvack.org>; Tue, 24 Feb 2009 07:17:16 -0500 (EST)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 06/19] Check only once if the zonelist is suitable for the allocation
Date: Tue, 24 Feb 2009 12:17:02 +0000
Message-Id: <1235477835-14500-7-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1235477835-14500-1-git-send-email-mel@csn.ul.ie>
References: <1235477835-14500-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>, Linux Memory Management List <linux-mm@kvack.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>

It is possible with __GFP_THISNODE that no zones are suitable. This
patch makes sure the check is only made once.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---
 mm/page_alloc.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 7cc4932..99fd538 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1487,9 +1487,8 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
 	if (should_fail_alloc_page(gfp_mask, order))
 		return NULL;
 
-restart:
-	z = zonelist->_zonerefs;  /* the list of zones suitable for gfp_mask */
-
+	/* the list of zones suitable for gfp_mask */
+	z = zonelist->_zonerefs;
 	if (unlikely(!z->zone)) {
 		/*
 		 * Happens if we have an empty zonelist as a result of
@@ -1498,6 +1497,7 @@ restart:
 		return NULL;
 	}
 
+restart:
 	page = get_page_from_freelist(gfp_mask|__GFP_HARDWALL, nodemask, order,
 			zonelist, high_zoneidx, ALLOC_WMARK_LOW|ALLOC_CPUSET);
 	if (page)
-- 
1.5.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
