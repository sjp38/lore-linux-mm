Date: Wed, 09 May 2007 12:10:59 +0900
From: Yasunori Goto <y-goto@jp.fujitsu.com>
Subject: [RFC] memory hotremove patch take 2 [04/10] (isolate all free pages)
In-Reply-To: <20070509115506.B904.Y-GOTO@jp.fujitsu.com>
References: <20070509115506.B904.Y-GOTO@jp.fujitsu.com>
Message-Id: <20070509120434.B90E.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux Kernel ML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
Cc: Andrew Morton <akpm@osdl.org>, Christoph Lameter <clameter@sgi.com>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

Isolate all freed pages (means in buddy_list) in the range.
See page_buddy() and free_one_page() function if unsure.

Signed-Off-By: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Signed-off-by: Yasunori Goto <y-goto@jp.fujitsu.com>

 include/linux/page_isolation.h |    1 
 mm/page_alloc.c                |   45 +++++++++++++++++++++++++++++++++++++++++
 2 files changed, 46 insertions(+)

Index: current_test/mm/page_alloc.c
===================================================================
--- current_test.orig/mm/page_alloc.c	2007-05-08 15:08:04.000000000 +0900
+++ current_test/mm/page_alloc.c	2007-05-08 15:08:26.000000000 +0900
@@ -4411,6 +4411,51 @@ free_all_isolated_pages(struct isolation
 	}
 }
 
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
 #endif /* CONFIG_PAGE_ISOLATION */
 
 
Index: current_test/include/linux/page_isolation.h
===================================================================
--- current_test.orig/include/linux/page_isolation.h	2007-05-08 15:08:04.000000000 +0900
+++ current_test/include/linux/page_isolation.h	2007-05-08 15:08:27.000000000 +0900
@@ -40,6 +40,7 @@ extern void free_isolation_info(struct i
 extern void unuse_all_isolated_pages(struct isolation_info *info);
 extern void free_all_isolated_pages(struct isolation_info *info);
 extern void drain_all_pages(void);
+extern int capture_isolate_freed_pages(struct isolation_info *info);
 
 #else
 

-- 
Yasunori Goto 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
