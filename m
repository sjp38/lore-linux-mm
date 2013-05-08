Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id E27106B0143
	for <linux-mm@kvack.org>; Wed,  8 May 2013 12:03:19 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 13/22] mm: page allocator: Use list_splice to refill the magazine
Date: Wed,  8 May 2013 17:02:58 +0100
Message-Id: <1368028987-8369-14-git-send-email-mgorman@suse.de>
In-Reply-To: <1368028987-8369-1-git-send-email-mgorman@suse.de>
References: <1368028987-8369-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Dave Hansen <dave@sr71.net>, Christoph Lameter <cl@linux.com>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

No need to operate on one page at a time.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/page_alloc.c | 15 +++++++--------
 1 file changed, 7 insertions(+), 8 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index bb2f116..c014b7a 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1333,6 +1333,7 @@ struct page *rmqueue_magazine(struct zone *zone, int migratetype)
 	/* Only acquire the lock if there is a reasonable chance of success */
 	if (zone->noirq_magazine.nr_free) {
 		spin_lock(&zone->magazine_lock);
+retry:
 		page = __rmqueue_magazine(zone, migratetype);
 		spin_unlock(&zone->magazine_lock);
 	}
@@ -1350,7 +1351,7 @@ struct page *rmqueue_magazine(struct zone *zone, int migratetype)
 			page = __rmqueue(zone, 0, migratetype);
 			if (!page)
 				break;
-			list_add_tail(&page->lru, &alloc_list);
+			list_add(&page->lru, &alloc_list);
 			nr_alloced++;
 		}
 		if (!is_migrate_cma(mt))
@@ -1358,15 +1359,13 @@ struct page *rmqueue_magazine(struct zone *zone, int migratetype)
 		else
 			__mod_zone_page_state(zone, NR_FREE_CMA_PAGES, -nr_alloced);
 		spin_unlock_irqrestore(&zone->lock, flags);
+		if (!nr_alloced)
+			return NULL;
 
 		spin_lock(&zone->magazine_lock);
-		while (!list_empty(&alloc_list)) {
-			page = list_entry(alloc_list.next, struct page, lru);
-			list_move_tail(&page->lru, &area->free_list[migratetype]);
-			area->nr_free++;
-		}
-		page = __rmqueue_magazine(zone, migratetype);
-		spin_unlock(&zone->magazine_lock);
+		list_splice(&alloc_list, &area->free_list[migratetype]);
+		area->nr_free += nr_alloced;
+		goto retry;
 	}
 
 	return page;
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
