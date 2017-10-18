Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id E90ED6B0038
	for <linux-mm@kvack.org>; Wed, 18 Oct 2017 03:36:01 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id a192so3508786pge.1
        for <linux-mm@kvack.org>; Wed, 18 Oct 2017 00:36:01 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x18si6584071pge.118.2017.10.18.00.36.00
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 18 Oct 2017 00:36:00 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH] mm, page_alloc: simplify hot/cold page handling in rmqueue_bulk()
Date: Wed, 18 Oct 2017 09:35:28 +0200
Message-Id: <20171018073528.30982-1-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>

The rmqueue_bulk() function fills an empty pcplist with pages from the free
list. It tries to preserve increasing order by pfn to the caller, because it
leads to better performance with some I/O controllers, as explained in
e084b2d95e48 ("page-allocator: preserve PFN ordering when __GFP_COLD is set").
For callers requesting cold pages, which are obtained from the tail of
pcplists, it means the pcplist has to be filled in reverse order from the free
lists (the hot/cold property only applies when pages are recycled on the
pcplists, not when refilled from free lists).

The related comment in rmqueue_bulk() wasn't clear to me without reading the
log of the commit mentioned above, so try to clarify it.

The code for filling the pcplists in order determined by the cold flag also
seems unnecessarily hard to follow. It's sufficient to either use list_add()
or list_add_tail(), but the current code also updates the list head pointer
in each step to the last added page, which then counterintuitively requires
to switch the usage of list_add() and list_add_tail() to achieve the desired
order, with no apparent benefit. This patch simplifies the code.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 mm/page_alloc.c | 17 ++++++++---------
 1 file changed, 8 insertions(+), 9 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 6191c9a04789..4b296fc8e599 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2329,19 +2329,18 @@ static int rmqueue_bulk(struct zone *zone, unsigned int order,
 			continue;
 
 		/*
-		 * Split buddy pages returned by expand() are received here
-		 * in physical page order. The page is added to the callers and
-		 * list and the list head then moves forward. From the callers
-		 * perspective, the linked list is ordered by page number in
-		 * some conditions. This is useful for IO devices that can
-		 * merge IO requests if the physical pages are ordered
+		 * Split buddy pages returned by expand() are received here in
+		 * physical page order. The page is added to the caller's list.
+		 * From the callers perspective, make sure the pages will be
+		 * consumed in the order as returned by expand(), regardless of
+		 * cold being true or false. This is useful for IO devices that
+		 * can merge IO requests if the physical pages are ordered
 		 * properly.
 		 */
 		if (likely(!cold))
-			list_add(&page->lru, list);
-		else
 			list_add_tail(&page->lru, list);
-		list = &page->lru;
+		else
+			list_add(&page->lru, list);
 		alloced++;
 		if (is_migrate_cma(get_pcppage_migratetype(page)))
 			__mod_zone_page_state(zone, NR_FREE_CMA_PAGES,
-- 
2.14.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
