Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id F12466B0047
	for <linux-mm@kvack.org>; Thu,  2 Sep 2010 23:19:59 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o833Ju4D021894
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 3 Sep 2010 12:19:56 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 2E8CA45DE53
	for <linux-mm@kvack.org>; Fri,  3 Sep 2010 12:19:56 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 08E4145DE4E
	for <linux-mm@kvack.org>; Fri,  3 Sep 2010 12:19:56 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id E34381DB8019
	for <linux-mm@kvack.org>; Fri,  3 Sep 2010 12:19:55 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 8BD0C1DB8013
	for <linux-mm@kvack.org>; Fri,  3 Sep 2010 12:19:52 +0900 (JST)
Date: Fri, 3 Sep 2010 12:14:52 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH 2/2] Make is_mem_section_removable more conformable with
 offlining code
Message-Id: <20100903121452.2d22b3aa.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100903121003.e2b8993a.kamezawa.hiroyu@jp.fujitsu.com>
References: <20100901121951.GC6663@tiehlicka.suse.cz>
	<20100901124138.GD6663@tiehlicka.suse.cz>
	<20100902144500.a0d05b08.kamezawa.hiroyu@jp.fujitsu.com>
	<20100902082829.GA10265@tiehlicka.suse.cz>
	<20100902180343.f4232c6e.kamezawa.hiroyu@jp.fujitsu.com>
	<20100902092454.GA17971@tiehlicka.suse.cz>
	<AANLkTi=cLzRGPCc3gCubtU7Ggws7yyAK5c7tp4iocv6u@mail.gmail.com>
	<20100902131855.GC10265@tiehlicka.suse.cz>
	<AANLkTikYt3Hu_XeNuwAa9KjzfWgpC8cNen6q657ZKmm-@mail.gmail.com>
	<20100902143939.GD10265@tiehlicka.suse.cz>
	<20100902150554.GE10265@tiehlicka.suse.cz>
	<20100903121003.e2b8993a.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Michal Hocko <mhocko@suse.cz>, Hiroyuki Kamezawa <kamezawa.hiroyuki@gmail.com>, Wu Fengguang <fengguang.wu@intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "Kleen, Andi" <andi.kleen@intel.com>, Haicheng Li <haicheng.li@linux.intel.com>, Christoph Lameter <cl@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Mel Gorman <mel@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>


Now, sysfs interface of memory hotplug shows whether the section is
removable or not. But it checks only migrateype of pages and doesn't
check details of cluster of pages.

Next, memory hotplug's set_migratetype_isolate() has the same kind
of check, too. But the migrate-type is just a "hint" and the pageblock
can contain several types of pages if fragmentation is very heavy.

To get precise information, we need to check
 - the pageblock only contains free pages or LRU pages.

This patch adds the function __count_unmovable_pages() and makes
above 2 checks to use the same logic. This will improve user experience
of memory hotplug because sysfs interface tells accurate information.

Note:
it may be better to check MIGRATE_UNMOVABLE for making failure case quick.
Note2:
I'm not sure but notifer should be called ??

Reported-by: Michal Hocko <mhocko@suse.cz>
Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 include/linux/memory_hotplug.h |    1 
 mm/memory_hotplug.c            |   15 --------
 mm/page_alloc.c                |   76 ++++++++++++++++++++++++++++++-----------
 3 files changed, 59 insertions(+), 33 deletions(-)

Index: mmotm-0827/mm/page_alloc.c
===================================================================
--- mmotm-0827.orig/mm/page_alloc.c
+++ mmotm-0827/mm/page_alloc.c
@@ -5274,11 +5274,63 @@ void set_pageblock_flags_group(struct pa
  * page allocater never alloc memory from ISOLATE block.
  */
 
+static int __count_unmovable_pages(struct zone *zone, struct page *page)
+{
+	unsigned long pfn, iter, found;
+	/*
+	 * For avoiding noise data, lru_add_drain_all() should be called.
+ 	 * before this.
+ 	 */
+	if (zone_idx(zone) == ZONE_MOVABLE)
+		return 0;
+
+	pfn = page_to_pfn(page);
+	for (found = 0, iter = 0; iter < pageblock_nr_pages; iter++) {
+		unsigned long check = pfn + iter;
+
+		if (!pfn_valid_within(check)) {
+			iter++;
+			continue;
+		}
+		page = pfn_to_page(check);
+		if (!page_count(page)) {
+			if (PageBuddy(page))
+				iter += (1 << page_order(page)) - 1;
+			continue;
+		}
+		if (!PageLRU(page))
+			found++;
+		/*
+		 * If the page is not RAM, page_count()should be 0.
+		 * we don't need more check. This is an _used_ not-movable page.
+		 *
+		 * The problematic thing here is PG_reserved pages. But if
+		 * a PG_reserved page is _used_ (at boot), page_count > 1.
+		 * But...is there PG_reserved && page_count(page)==0 page ?
+		 */
+	}
+	return found;
+}
+
+bool is_pageblock_removable(struct page *page)
+{
+	struct zone *zone = page_zone(page);
+	unsigned long flags;
+	int num;
+
+	spin_lock_irqsave(&zone->lock, flags);
+	num = __count_unmovable_pages(zone, page);
+	spin_unlock_irqrestore(&zone->lock, flags);
+
+	if (num)
+		return false;
+	return true;
+}
+
 int set_migratetype_isolate(struct page *page)
 {
 	struct zone *zone;
-	struct page *curr_page;
-	unsigned long flags, pfn, iter;
+	unsigned long flags, pfn;
 	unsigned long immobile = 0;
 	struct memory_isolate_notify arg;
 	int notifier_ret;
@@ -5289,11 +5341,6 @@ int set_migratetype_isolate(struct page 
 	zone_idx = zone_idx(zone);
 
 	spin_lock_irqsave(&zone->lock, flags);
-	if (get_pageblock_migratetype(page) == MIGRATE_MOVABLE ||
-	    zone_idx == ZONE_MOVABLE) {
-		ret = 0;
-		goto out;
-	}
 
 	pfn = page_to_pfn(page);
 	arg.start_pfn = pfn;
@@ -5315,19 +5362,9 @@ int set_migratetype_isolate(struct page 
 	notifier_ret = notifier_to_errno(notifier_ret);
 	if (notifier_ret || !arg.pages_found)
 		goto out;
+	immobile = __count_unmovable_pages(zone ,page);
 
-	for (iter = pfn; iter < (pfn + pageblock_nr_pages); iter++) {
-		if (!pfn_valid_within(pfn))
-			continue;
-
-		curr_page = pfn_to_page(iter);
-		if (!page_count(curr_page) || PageLRU(curr_page))
-			continue;
-
-		immobile++;
-	}
-
-	if (arg.pages_found == immobile)
+	if (!immobile || arg.pages_found == immobile)
 		ret = 0;
 
 out:
Index: mmotm-0827/mm/memory_hotplug.c
===================================================================
--- mmotm-0827.orig/mm/memory_hotplug.c
+++ mmotm-0827/mm/memory_hotplug.c
@@ -602,27 +602,14 @@ static struct page *next_active_pagebloc
 /* Checks if this range of memory is likely to be hot-removable. */
 int is_mem_section_removable(unsigned long start_pfn, unsigned long nr_pages)
 {
-	int type;
 	struct page *page = pfn_to_page(start_pfn);
 	struct page *end_page = page + nr_pages;
 
 	/* Check the starting page of each pageblock within the range */
 	for (; page < end_page; page = next_active_pageblock(page)) {
-		type = get_pageblock_migratetype(page);
-
-		/*
-		 * A pageblock containing MOVABLE or free pages is considered
-		 * removable
-		 */
-		if (type != MIGRATE_MOVABLE && !pageblock_free(page))
+		if (!is_pageblock_removable(page))
 			return 0;
 
-		/*
-		 * A pageblock starting with a PageReserved page is not
-		 * considered removable.
-		 */
-		if (PageReserved(page))
-			return 0;
 	}
 
 	/* All pageblocks in the memory block are likely to be hot-removable */
Index: mmotm-0827/include/linux/memory_hotplug.h
===================================================================
--- mmotm-0827.orig/include/linux/memory_hotplug.h
+++ mmotm-0827/include/linux/memory_hotplug.h
@@ -76,6 +76,7 @@ extern int __add_pages(int nid, struct z
 extern int __remove_pages(struct zone *zone, unsigned long start_pfn,
 	unsigned long nr_pages);
 
+extern bool is_pageblock_removable(struct page *page);
 #ifdef CONFIG_NUMA
 extern int memory_add_physaddr_to_nid(u64 start);
 #else

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
