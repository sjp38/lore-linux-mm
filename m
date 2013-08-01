Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id 17AD86B0031
	for <linux-mm@kvack.org>; Thu,  1 Aug 2013 05:19:28 -0400 (EDT)
Message-ID: <51FA2800.9070706@huawei.com>
Date: Thu, 1 Aug 2013 17:18:56 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: [PATCH] mm/hotplug: fix a drain pcp bug when offline pages
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, cody@linux.vnet.ibm.com, Liujiang <jiang.liu@huawei.com>, Minchan Kim <minchan@kernel.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, b.zolnierkie@samsung.com
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

__offline_pages()
   start_isolate_page_range()
      set_migratetype_isolate()
         set_pageblock_migratetype() -> this pageblock will be marked as MIGRATE_ISOLATE
         move_freepages_block() -> pages in PageBuddy will be moved into MIGRATE_ISOLATE list
         drain_all_pages() -> drain PCP
            free_pcppages_bulk()
               mt = get_freepage_migratetype(page); -> PCP's migratetype is not MIGRATE_ISOLATE
               __free_one_page(page, zone, 0, mt); -> so PCP will not be freed into into MIGRATE_ISOLATE list

In this case, the PCP may be allocated again, because they are not in 
PageBuddy's MIGRATE_ISOLATE list. This will cause offline_pages failed.

Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
---
 mm/page_alloc.c     |   10 ++++++----
 mm/page_isolation.c |   15 ++++++++++++++-
 2 files changed, 20 insertions(+), 5 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index b100255..d873471 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -965,11 +965,13 @@ int move_freepages(struct zone *zone,
 		}
 
 		order = page_order(page);
-		list_move(&page->lru,
-			  &zone->free_area[order].free_list[migratetype]);
-		set_freepage_migratetype(page, migratetype);
+		if (get_freepage_migratetype(page) != migratetype) {
+			list_move(&page->lru,
+				&zone->free_area[order].free_list[migratetype]);
+			set_freepage_migratetype(page, migratetype);
+			pages_moved += 1 << order;
+		}
 		page += 1 << order;
-		pages_moved += 1 << order;
 	}
 
 	return pages_moved;
diff --git a/mm/page_isolation.c b/mm/page_isolation.c
index 383bdbb..ba1afc9 100644
--- a/mm/page_isolation.c
+++ b/mm/page_isolation.c
@@ -65,8 +65,21 @@ out:
 	}
 
 	spin_unlock_irqrestore(&zone->lock, flags);
-	if (!ret)
+
+	if (!ret) {
 		drain_all_pages();
+		/*
+		 * When drain_all_pages() frees cached pages into the buddy
+		 * system, it uses the stale migratetype cached in the
+		 * page->index field, so try to move free pages to ISOLATE
+		 * list again.
+		 */
+		spin_lock_irqsave(&zone->lock, flags);
+		nr_pages = move_freepages_block(zone, page, MIGRATE_ISOLATE);
+		__mod_zone_freepage_state(zone, -nr_pages, migratetype);
+		spin_unlock_irqrestore(&zone->lock, flags);
+	}
+
 	return ret;
 }
 
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
