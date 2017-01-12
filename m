Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 95C776B0033
	for <linux-mm@kvack.org>; Thu, 12 Jan 2017 16:12:30 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id c85so8705465wmi.6
        for <linux-mm@kvack.org>; Thu, 12 Jan 2017 13:12:30 -0800 (PST)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id b26si8556741wra.300.2017.01.12.13.12.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Jan 2017 13:12:29 -0800 (PST)
Received: by mail-wm0-f67.google.com with SMTP id r144so6688158wme.0
        for <linux-mm@kvack.org>; Thu, 12 Jan 2017 13:12:29 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH] mm, vmscan: do not count freed pages as PGDEACTIVATE
Date: Thu, 12 Jan 2017 22:12:21 +0100
Message-Id: <20170112211221.17636-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

PGDEACTIVATE represents the number of pages moved from the active list
to the inactive list. At least this sounds like the original motivation
of the counter. move_active_pages_to_lru, however, counts pages which
got freed in the mean time as deactivated as well. This is a very rare
event and counting them as deactivation in itself is not harmful but it
makes the code more convoluted than necessary - we have to count both
all pages and those which are freed which is a bit confusing.

After this patch the PGDEACTIVATE should have a slightly more clear
semantic and only count those pages which are moved from the active to
the inactive list which is a plus.

Suggested-by: Vlastimil Babka <vbabka@suse.cz>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
Hi,
Vlastimil has pointed out [1] that move_active_pages_to_lru is more
confusing than necessary because we count two things, pgmoved and
nr_moved. I believe that counting freed pages as PGDEACTIVATE is more
confusing than helpful. I doubt that this patch will make any real
difference in the real life but it at least makes the code easier which
is a plus so I think this is more a cleanup than any bug fix.

[1] http://lkml.kernel.org/r/646c3551-e794-611c-5247-490bd89133db@suse.cz

 mm/vmscan.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index cf940af609fd..7e1c3cd91fab 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1878,7 +1878,6 @@ static unsigned move_active_pages_to_lru(struct lruvec *lruvec,
 				     enum lru_list lru)
 {
 	struct pglist_data *pgdat = lruvec_pgdat(lruvec);
-	unsigned long pgmoved = 0;
 	struct page *page;
 	int nr_pages;
 	int nr_moved = 0;
@@ -1893,7 +1892,6 @@ static unsigned move_active_pages_to_lru(struct lruvec *lruvec,
 		nr_pages = hpage_nr_pages(page);
 		update_lru_size(lruvec, lru, page_zonenum(page), nr_pages);
 		list_move(&page->lru, &lruvec->lists[lru]);
-		pgmoved += nr_pages;
 
 		if (put_page_testzero(page)) {
 			__ClearPageLRU(page);
@@ -1913,7 +1911,7 @@ static unsigned move_active_pages_to_lru(struct lruvec *lruvec,
 	}
 
 	if (!is_active_lru(lru))
-		__count_vm_events(PGDEACTIVATE, pgmoved);
+		__count_vm_events(PGDEACTIVATE, nr_moved);
 
 	return nr_moved;
 }
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
