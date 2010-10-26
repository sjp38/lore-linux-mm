Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id BD0E86B0071
	for <linux-mm@kvack.org>; Tue, 26 Oct 2010 06:10:29 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o9QAAPtF009077
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 26 Oct 2010 19:10:25 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 30C2845DE50
	for <linux-mm@kvack.org>; Tue, 26 Oct 2010 19:10:25 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 0734745DE4F
	for <linux-mm@kvack.org>; Tue, 26 Oct 2010 19:10:25 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id D3A971DB8053
	for <linux-mm@kvack.org>; Tue, 26 Oct 2010 19:10:24 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 71D271DB8042
	for <linux-mm@kvack.org>; Tue, 26 Oct 2010 19:10:24 +0900 (JST)
Date: Tue, 26 Oct 2010 19:04:58 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH 2/3] a help function for find physically contiguous
 block.
Message-Id: <20101026190458.4e1c0d98.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20101026190042.57f30338.kamezawa.hiroyu@jp.fujitsu.com>
References: <20101026190042.57f30338.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, andi.kleen@intel.com, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, fujita.tomonori@lab.ntt.co.jp, felipe.contreras@gmail.com
List-ID: <linux-mm.kvack.org>

From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Unlike memory hotplug, at an allocation of contigous memory range, address
may not be a problem. IOW, if a requester of memory wants to allocate 100M of
of contigous memory, placement of allocated memory may not be a problem.
So, "finding a range of memory which seems to be MOVABLE" is required.

This patch adds a functon to isolate a length of memory within [start, end).
This function returns a pfn which is 1st page of isolated contigous chunk
of given length within [start, end).

After isolation, free memory within this area will never be allocated.
But some pages will remain as "Used/LRU" pages. They should be dropped by
page reclaim or migration.

Changelog:
 - zone is added to the argument.
 - fixed a case that zones are not in linear.
 - added zone->lock.


Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/page_isolation.c |  148 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 148 insertions(+)

Index: mmotm-1024/mm/page_isolation.c
===================================================================
--- mmotm-1024.orig/mm/page_isolation.c
+++ mmotm-1024/mm/page_isolation.c
@@ -7,6 +7,7 @@
 #include <linux/pageblock-flags.h>
 #include <linux/memcontrol.h>
 #include <linux/migrate.h>
+#include <linux/memory_hotplug.h>
 #include <linux/mm_inline.h>
 #include "internal.h"
 
@@ -250,3 +251,150 @@ int do_migrate_range(unsigned long start
 out:
 	return ret;
 }
+
+/*
+ * Functions for getting contiguous MOVABLE pages in a zone.
+ */
+struct page_range {
+	unsigned long base; /* Base address of searching contigouous block */
+	unsigned long end;
+	unsigned long pages;/* Length of contiguous block */
+	int align_order;
+	unsigned long align_mask;
+};
+
+int __get_contig_block(unsigned long pfn, unsigned long nr_pages, void *arg)
+{
+	struct page_range *blockinfo = arg;
+	unsigned long end;
+
+	end = pfn + nr_pages;
+	pfn = ALIGN(pfn, 1 << blockinfo->align_order);
+	end = end & ~(MAX_ORDER_NR_PAGES - 1);
+
+	if (end < pfn)
+		return 0;
+	if (end - pfn >= blockinfo->pages) {
+		blockinfo->base = pfn;
+		blockinfo->end = end;
+		return 1;
+	}
+	return 0;
+}
+
+static void __trim_zone(struct zone *zone, struct page_range *range)
+{
+	unsigned long pfn;
+	/*
+ 	 * skip pages which dones'nt under the zone.
+ 	 * There are some archs which zones are not in linear layout.
+	 */
+	if (page_zone(pfn_to_page(range->base)) != zone) {
+		for (pfn = range->base;
+			pfn < range->end;
+			pfn += MAX_ORDER_NR_PAGES) {
+			if (page_zone(pfn_to_page(pfn)) == zone)
+				break;
+		}
+		range->base = min(pfn, range->end);
+	}
+	/* Here, range-> base is in the zone if range->base != range->end */
+	for (pfn = range->base;
+	     pfn < range->end;
+	     pfn += MAX_ORDER_NR_PAGES) {
+		if (zone != page_zone(pfn_to_page(pfn))) {
+			pfn = pfn - MAX_ORDER_NR_PAGES;
+			break;
+		}
+	}
+	range->end = min(pfn, range->end);
+	return;
+}
+
+/*
+ * This function is for finding a contiguous memory block which has length
+ * of pages and MOVABLE. If it finds, make the range of pages as ISOLATED
+ * and return the first page's pfn.
+ * This checks all pages in the returned range is free of Pg_LRU. To reduce
+ * the risk of false-positive testing, lru_add_drain_all() should be called
+ * before this function to reduce pages on pagevec for zones.
+ */
+
+static unsigned long find_contig_block(unsigned long base,
+		unsigned long end, unsigned long pages,
+		int align_order, struct zone *zone)
+{
+	unsigned long pfn, pos;
+	struct page_range blockinfo;
+	int ret;
+
+	VM_BUG_ON(pages & (MAX_ORDER_NR_PAGES - 1));
+	VM_BUG_ON(base & ((1 << align_order) - 1));
+retry:
+	blockinfo.base = base;
+	blockinfo.end = end;
+	blockinfo.pages = pages;
+	blockinfo.align_order = align_order;
+	blockinfo.align_mask = (1 << align_order) - 1;
+	/*
+	 * At first, check physical page layout and skip memory holes.
+	 */
+	ret = walk_system_ram_range(base, end - base, &blockinfo,
+		__get_contig_block);
+	if (!ret)
+		return 0;
+	/* check contiguous pages in a zone */
+	__trim_zone(zone, &blockinfo);
+
+	/*
+	 * Ok, we found contiguous memory chunk of size. Isolate it.
+	 * We just search MAX_ORDER aligned range.
+	 */
+	for (pfn = blockinfo.base; pfn + pages <= blockinfo.end;
+	     pfn += (1 << align_order)) {
+		struct zone *z = page_zone(pfn_to_page(pfn));
+
+		spin_lock_irq(&z->lock);
+		pos = pfn;
+		/*
+		 * Check the range only contains free pages or LRU pages.
+		 */
+		while (pos < pfn + pages) {
+			struct page *p;
+
+			if (!pfn_valid_within(pos))
+				break;
+			p = pfn_to_page(pos);
+			if (PageReserved(p))
+				break;
+			if (!page_count(p)) {
+				if (!PageBuddy(p))
+					pos++;
+				else if (PageBuddy(p)) {
+					int order = page_order(p);
+					pos += (1 << order);
+				}
+			} else if (PageLRU(p)) {
+				pos++;
+			} else
+				break;
+		}
+		spin_unlock_irq(&z->lock);
+		if ((pos == pfn + pages) &&
+			!start_isolate_page_range(pfn, pfn + pages))
+				return pfn;
+		if (pos & ((1 << align_order) - 1))
+			pfn = ALIGN(pos, (1 << align_order));
+		else
+			pfn = pos + (1 << align_order);
+		cond_resched();
+	}
+
+	/* failed */
+	if (blockinfo.end + pages <= end) {
+		/* Move base address and find the next block of RAM. */
+		base = blockinfo.end;
+		goto retry;
+	}
+	return 0;
+}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
