Date: Tue, 6 Mar 2007 13:57:18 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC} memory unplug patchset prep [13/16] isolate freed pages.
Message-Id: <20070306135718.56de382c.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20070306133223.5d610daf.kamezawa.hiroyu@jp.fujitsu.com>
References: <20070306133223.5d610daf.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, mel@skynet.ie, clameter@engr.sgi.com, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

Isolate all freed pages (means in buddy_list) in the range.
See page_buddy() and free_one_page() function if unsure.

Signed-Off-By: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

---
 include/linux/page_isolation.h |    2 +
 mm/page_alloc.c                |   48 +++++++++++++++++++++++++++++++++++++++++
 2 files changed, 50 insertions(+)

Index: devel-tree-2.6.20-mm2/mm/page_alloc.c
===================================================================
--- devel-tree-2.6.20-mm2.orig/mm/page_alloc.c
+++ devel-tree-2.6.20-mm2/mm/page_alloc.c
@@ -3927,10 +3929,59 @@ free_all_isolated_pages(struct isolation
 		list_del(&page->lru);
 		set_page_count(page, 0);
 		set_page_refcounted(page);
 		/* This is sage because info is detached from zone */
 		__free_page(page);
 	}
 }
 
+
+/*
+ * Isolate already freed pages.
+ */
+int
+capture_isolate_freed_pages(struct isolation_info *info)
+{
+	struct zone *zone;
+	unsigned long pfn;
+	struct page *page;
+	int order, order_size;
+	int nr_pages = 0;
+	unsigned long last_pfn = info->end_pfn - 1;
+	pfn = info->start_pfn;
+	if (!pfn_valid(pfn))
+		return -EINVAL;
+	zone = info->zone;
+	if ((zone != page_zone(pfn_to_page(pfn))) ||
+	    (zone != page_zone(pfn_to_page(last_pfn))))
+		return -EINVAL;
+	drain_all_pages();
+	spin_lock(&zone->lock);
+	while (pfn < info->end_pfn) {
+		if (!pfn_valid(pfn)) {
+			pfn++;
+			continue;
+		}
+		page = pfn_to_page(pfn);
+		/* See page_is_buddy()  */
+		if (page_count(page) == 0 && PageBuddy(page)) {
+			order = page_order(page);
+			order_size = 1 << order;
+			zone->free_area[order].nr_free--;
+			__mod_zone_page_state(zone, NR_FREE_PAGES, -order_size);
+			list_del(&page->lru);
+			rmv_page_order(page);
+			isolate_page_nolock(info, page, order);
+			nr_pages += order_size;
+			pfn += order_size;
+		} else {
+			pfn++;
+		}
+	}
+	spin_unlock(&zone->lock);
+	return nr_pages;
+}
+
+
 #endif

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
