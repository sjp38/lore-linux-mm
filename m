Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 99C9C6B004F
	for <linux-mm@kvack.org>; Mon, 22 Jun 2009 11:42:18 -0400 (EDT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 1/3] page-allocator: Allow too high-order warning messages to be suppressed with __GFP_NOWARN
Date: Mon, 22 Jun 2009 16:43:32 +0100
Message-Id: <1245685414-8979-2-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1245685414-8979-1-git-send-email-mel@csn.ul.ie>
References: <1245685414-8979-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Ingo Molnar <mingo@elte.hu>, linux-kernel@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, Heinz Diehl <htd@fancy-poultry.org>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

The page allocator warns once when an order >= MAX_ORDER is specified.
This is to catch callers of the allocator that are always falling back
to their worst-case when it was not expected. However, there are cases
where the caller is behaving correctly but cannot suppress the warning.
This patch allows the warning to be suppressed by the callers by
specifying __GFP_NOWARN.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---
 mm/page_alloc.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index a5f3c27..005b32d 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1740,8 +1740,10 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 	 * be using allocators in order of preference for an area that is
 	 * too large.
 	 */
-	if (WARN_ON_ONCE(order >= MAX_ORDER))
+	if (order >= MAX_ORDER) {
+		WARN_ON_ONCE(!(gfp_mask & __GFP_NOWARN));
 		return NULL;
+	}
 
 	/*
 	 * GFP_THISNODE (meaning __GFP_THISNODE, __GFP_NORETRY and
-- 
1.5.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
