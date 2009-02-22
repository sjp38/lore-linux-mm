Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id CEDBC6B0098
	for <linux-mm@kvack.org>; Sun, 22 Feb 2009 18:16:34 -0500 (EST)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 17/20] Do not double sanity check page attributes during allocation
Date: Sun, 22 Feb 2009 23:17:26 +0000
Message-Id: <1235344649-18265-18-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1235344649-18265-1-git-send-email-mel@csn.ul.ie>
References: <1235344649-18265-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>, Linux Memory Management List <linux-mm@kvack.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>
List-ID: <linux-mm.kvack.org>

On every page free, free_pages_check() sanity checks the page details,
including some atomic operations. On page allocation, the same checks
are been made. This is excessively paranoid as it will only catch severe
memory corruption bugs that are going to manifest in a variety of fun
and entertaining ways with or without this check. This patch removes the
overhead of double checking the page state on every allocation.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---
 mm/page_alloc.c |    8 --------
 1 files changed, 0 insertions(+), 8 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 9e16aec..452f708 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -646,14 +646,6 @@ static inline void expand(struct zone *zone, struct page *page,
  */
 static int prep_new_page(struct page *page, int order, gfp_t gfp_flags)
 {
-	if (unlikely(page_mapcount(page) |
-		(page->mapping != NULL)  |
-		(page_count(page) != 0)  |
-		(page->flags & PAGE_FLAGS_CHECK_AT_PREP))) {
-		bad_page(page);
-		return 1;
-	}
-
 	set_page_private(page, 0);
 	set_page_refcounted(page);
 
-- 
1.5.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
