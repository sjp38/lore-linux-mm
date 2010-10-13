Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 4CBC46B00E0
	for <linux-mm@kvack.org>; Tue, 12 Oct 2010 23:22:58 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o9D3MuQO031723
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 13 Oct 2010 12:22:56 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 2903F45DE60
	for <linux-mm@kvack.org>; Wed, 13 Oct 2010 12:22:56 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 0099345DE4D
	for <linux-mm@kvack.org>; Wed, 13 Oct 2010 12:22:56 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id DD1791DB803A
	for <linux-mm@kvack.org>; Wed, 13 Oct 2010 12:22:55 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 8EFC61DB8037
	for <linux-mm@kvack.org>; Wed, 13 Oct 2010 12:22:55 +0900 (JST)
Date: Wed, 13 Oct 2010 12:17:38 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH 2/3] find a contiguous range.
Message-Id: <20101013121738.933ff002.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20101013121527.8ec6a769.kamezawa.hiroyu@jp.fujitsu.com>
References: <20101013121527.8ec6a769.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>
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


Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/page_isolation.c |  130 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 130 insertions(+)

Index: mmotm-1008/mm/page_isolation.c
===================================================================
--- mmotm-1008.orig/mm/page_isolation.c
+++ mmotm-1008/mm/page_isolation.c
@@ -9,6 +9,7 @@
 #include <linux/pageblock-flags.h>
 #include <linux/memcontrol.h>
 #include <linux/migrate.h>
+#include <linux/memory_hotplug.h>
 #include <linux/mm_inline.h>
 #include "internal.h"
 
@@ -254,3 +255,132 @@ out:
 	return ret;
 }
 
+/*
+ * Functions for getting contiguous MOVABLE pages in a zone.
+ */
+struct page_range {
+	unsigned long base; /* Base address of searching contigouous block */
+	unsigned long end;
+	unsigned long pages;/* Length of contiguous block */
+};
+
+static inline unsigned long  MAX_ORDER_ALIGN(unsigned long x)
+{
+	return ALIGN(x, MAX_ORDER_NR_PAGES);
+}
+
+static inline unsigned long MAX_ORDER_BASE(unsigned long x)
+{
+	return x & ~(MAX_ORDER_NR_PAGES - 1);
+}
+
+int __get_contig_block(unsigned long pfn, unsigned long nr_pages, void *arg)
+{
+	struct page_range *blockinfo = arg;
+	unsigned long end;
+
+	end = pfn + nr_pages;
+	pfn = MAX_ORDER_ALIGN(pfn);
+	end = MAX_ORDER_BASE(end);
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
+static void __trim_zone(struct page_range *range)
+{
+	struct zone *zone;
+	unsigned long pfn;
+	/*
+	 * In most case, each zone's [start_pfn, end_pfn) has no
+	 * overlap between each other. But some arch allows it and
+	 * we need to check it here.
+	 */
+	for (pfn = range->base, zone = page_zone(pfn_to_page(pfn));
+	     pfn < range->end;
+	     pfn += MAX_ORDER_NR_PAGES) {
+
+		if (zone != page_zone(pfn_to_page(pfn)))
+			break;
+	}
+	range->end = min(pfn, range->end);
+	return;
+}
+
+/*
+ * This function is for finding a contiguous memory block which has length
+ * of pages and MOVABLE. If it finds, make the range of pages as ISOLATED
+ * and return the first page's pfn.
+ * If no_search==true, this function doesn't scan the range but tries to
+ * isolate the range of memory.
+ */
+
+static unsigned long find_contig_block(unsigned long base,
+		unsigned long end, unsigned long pages, bool no_search)
+{
+	unsigned long pfn, pos;
+	struct page_range blockinfo;
+	int ret;
+
+	pages = MAX_ORDER_ALIGN(pages);
+retry:
+	blockinfo.base = base;
+	blockinfo.end = end;
+	blockinfo.pages = pages;
+	/*
+	 * At first, check physical page layout and skip memory holes.
+	 */
+	ret = walk_system_ram_range(base, end - base, &blockinfo,
+		__get_contig_block);
+	if (!ret)
+		return 0;
+	/* check contiguous pages in a zone */
+	__trim_zone(&blockinfo);
+
+
+	/* Ok, we found contiguous memory chunk of size. Isolate it.*/
+	for (pfn = blockinfo.base; pfn + pages < blockinfo.end;
+	     pfn += MAX_ORDER_NR_PAGES) {
+		/* If no_search==true, base addess should be same to 'base' */
+		if (no_search && pfn != base)
+			break;
+		/* Better code is necessary here.. */
+		for (pos = pfn; pos < pfn + pages; pos++) {
+			struct page *p;
+
+			if (!pfn_valid_within(pos))
+				break;
+			p = pfn_to_page(pos);
+			if (PageReserved(p))
+				break;
+			/* This may hit a page on per-cpu queue. */
+			if (page_count(p) && !PageLRU(p))
+				break;
+			/* Need to skip order of pages */
+		}
+		if (pos != pfn + pages) {
+			pfn = MAX_ORDER_BASE(pos);
+			continue;
+		}
+		/*
+		 * Now, we know [base,end) of a contiguous chunk.
+		 * Don't need to take care of memory holes.
+		 */
+		if (!start_isolate_page_range(pfn, pfn + pages))
+			return pfn;
+	}
+
+	/* failed */
+	if (!no_search && blockinfo.end + pages < end) {
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
