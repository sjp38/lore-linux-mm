Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 769A26B0087
	for <linux-mm@kvack.org>; Fri, 19 Nov 2010 03:19:57 -0500 (EST)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oAJ8JsaC012675
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 19 Nov 2010 17:19:54 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 4281F45DE57
	for <linux-mm@kvack.org>; Fri, 19 Nov 2010 17:19:54 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 178E945DE4F
	for <linux-mm@kvack.org>; Fri, 19 Nov 2010 17:19:54 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 51229E38001
	for <linux-mm@kvack.org>; Fri, 19 Nov 2010 17:19:53 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id E52E7E18006
	for <linux-mm@kvack.org>; Fri, 19 Nov 2010 17:19:52 +0900 (JST)
Date: Fri, 19 Nov 2010 17:14:15 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH 2/4] alloc_contig_pages() find appropriate physical memory
 range
Message-Id: <20101119171415.aa320cab.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20101119171033.a8d9dc8f.kamezawa.hiroyu@jp.fujitsu.com>
References: <20101119171033.a8d9dc8f.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, minchan.kim@gmail.com, Bob Liu <lliubbo@gmail.com>, fujita.tomonori@lab.ntt.co.jp, m.nazarewicz@samsung.com, pawel@osciak.com, andi.kleen@intel.com, felipe.contreras@gmail.com, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Unlike memory hotplug, at an allocation of contigous memory range, address
may not be a problem. IOW, if a requester of memory wants to allocate 100M of
of contigous memory, placement of allocated memory may not be a problem.
So, "finding a range of memory which seems to be MOVABLE" is required.

This patch adds a functon to isolate a length of memory within [start, end).
This function returns a pfn which is 1st page of isolated contigous chunk
of given length within [start, end).

If no_search=true is passed as argument, start address is always same to
the specified "base" addresss.

After isolation, free memory within this area will never be allocated.
But some pages will remain as "Used/LRU" pages. They should be dropped by
page reclaim or migration.

Changelog: 2010-11-17
 - fixed some conding style (if-then-else)

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/page_isolation.c |  146 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 146 insertions(+)

Index: mmotm-1117/mm/page_isolation.c
===================================================================
--- mmotm-1117.orig/mm/page_isolation.c
+++ mmotm-1117/mm/page_isolation.c
@@ -7,6 +7,7 @@
 #include <linux/pageblock-flags.h>
 #include <linux/memcontrol.h>
 #include <linux/migrate.h>
+#include <linux/memory_hotplug.h>
 #include <linux/mm_inline.h>
 #include "internal.h"
 
@@ -250,3 +251,148 @@ int do_migrate_range(unsigned long start
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
+		if (z != zone)
+			continue;
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
+				else
+					pos += (1 << page_order(p));
+			} else if (PageLRU(p)) {
+				pos++;
+			} else
+				break;
+		}
+		spin_unlock_irq(&z->lock);
+		if ((pos == pfn + pages)) {
+			if (!start_isolate_page_range(pfn, pfn + pages))
+				return pfn;
+		} else/* the chunk including "pos" should be skipped */
+			pfn = pos & ~((1 << align_order) - 1);
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
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
