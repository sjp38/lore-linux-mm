Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 2BF8E9000BD
	for <linux-mm@kvack.org>; Wed, 21 Sep 2011 11:19:28 -0400 (EDT)
Received: from hpaq5.eem.corp.google.com (hpaq5.eem.corp.google.com [172.25.149.5])
	by smtp-out.google.com with ESMTP id p8LFJMrQ020330
	for <linux-mm@kvack.org>; Wed, 21 Sep 2011 08:19:23 -0700
Received: from ewy9 (ewy9.prod.google.com [10.241.103.9])
	by hpaq5.eem.corp.google.com with ESMTP id p8LFHqU5026888
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 21 Sep 2011 08:19:21 -0700
Received: by ewy9 with SMTP id 9so1355039ewy.30
        for <linux-mm@kvack.org>; Wed, 21 Sep 2011 08:19:19 -0700 (PDT)
From: Michal Nazarewicz <mnazarewicz@google.com>
Subject: [PATCH 1/3] fixup! mm: alloc_contig_freed_pages() added
Date: Wed, 21 Sep 2011 17:19:05 +0200
Message-Id: <ea1bc31120e0670a044de6af7b3c67203c178065.1316617681.git.mina86@mina86.com>
In-Reply-To: <1315505152.3114.9.camel@nimitz>
References: <1315505152.3114.9.camel@nimitz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>, Dave Hansen <dave@linux.vnet.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, Kyungmin Park <kyungmin.park@samsung.com>, Russell King <linux@arm.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Ankita Garg <ankita@in.ibm.com>, Daniel Walker <dwalker@codeaurora.org>, Mel Gorman <mel@csn.ul.ie>, Arnd Bergmann <arnd@arndb.de>, Jesse Barker <jesse.barker@linaro.org>, Jonathan Corbet <corbet@lwn.net>, Shariq Hasnain <shariq.hasnain@linaro.org>, Chunsang Jeong <chunsang.jeong@linaro.org>

From: Michal Nazarewicz <mina86@mina86.com>

Signed-off-by: Michal Nazarewicz <mina86@mina86.com>

---
 include/linux/page-isolation.h |    4 ++-
 mm/page_alloc.c                |   66 ++++++++++++++++++++++++++++++++++-----
 2 files changed, 60 insertions(+), 10 deletions(-)

> On Fri, 2011-08-19 at 16:27 +0200, Marek Szyprowski wrote:
>> +unsigned long alloc_contig_freed_pages(unsigned long start, unsigned  
>> long end,
>> +				       gfp_t flag)
>> +{
>> +	unsigned long pfn = start, count;
>> +	struct page *page;
>> +	struct zone *zone;
>> +	int order;
>> +
>> +	VM_BUG_ON(!pfn_valid(start));
>> +	zone = page_zone(pfn_to_page(start));

On Thu, 08 Sep 2011 20:05:52 +0200, Dave Hansen <dave@linux.vnet.ibm.com> wrote:
> This implies that start->end are entirely contained in a single zone.
> What enforces that?  If some higher layer enforces that, I think we
> probably need at least a VM_BUG_ON() in here and a comment about who
> enforces it.

>> +	spin_lock_irq(&zone->lock);
>> +
>> +	page = pfn_to_page(pfn);
>> +	for (;;) {
>> +		VM_BUG_ON(page_count(page) || !PageBuddy(page));
>> +		list_del(&page->lru);
>> +		order = page_order(page);
>> +		zone->free_area[order].nr_free--;
>> +		rmv_page_order(page);
>> +		__mod_zone_page_state(zone, NR_FREE_PAGES, -(1UL << order));
>> +		pfn  += 1 << order;
>> +		if (pfn >= end)
>> +			break;
>> +		VM_BUG_ON(!pfn_valid(pfn));
>> +		page += 1 << order;
>> +	}

> This 'struct page *'++ stuff is OK, but only for small, aligned areas.
> For at least some of the sparsemem modes (non-VMEMMAP), you could walk
> off of the end of the section_mem_map[] when you cross a MAX_ORDER
> boundary.  I'd feel a little bit more comfortable if pfn_to_page() was
> being done each time, or only occasionally when you cross a section
> boundary.

Do the attached changes seem to make sense?

I wanted to avoid calling pfn_to_page() each time as it seem fairly
expensive in sparsemem and disctontig modes.  At the same time, the
macro trickery is so that users of sparsemem-vmemmap and flatmem won't
have to pay the price.

diff --git a/include/linux/page-isolation.h b/include/linux/page-isolation.h
index b2a81fd..003c52f 100644
--- a/include/linux/page-isolation.h
+++ b/include/linux/page-isolation.h
@@ -46,11 +46,13 @@ static inline void unset_migratetype_isolate(struct page *page)
 {
 	__unset_migratetype_isolate(page, MIGRATE_MOVABLE);
 }
+
+/* The below functions must be run on a range from a single zone. */
 extern unsigned long alloc_contig_freed_pages(unsigned long start,
 					      unsigned long end, gfp_t flag);
 extern int alloc_contig_range(unsigned long start, unsigned long end,
 			      gfp_t flags, unsigned migratetype);
-extern void free_contig_pages(struct page *page, int nr_pages);
+extern void free_contig_pages(unsigned long pfn, unsigned nr_pages);
 
 /*
  * For migration.
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 46e78d4..32fda5d 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5716,9 +5716,41 @@ out:
 	spin_unlock_irqrestore(&zone->lock, flags);
 }
 
+#if defined(CONFIG_FLATMEM) || defined(CONFIG_SPARSEMEM_VMEMMAP)
+
+/*
+ * In FLATMEM and CONFIG_SPARSEMEM_VMEMMAP we can safely increment the page
+ * pointer and get the same value as if we were to get by calling
+ * pfn_to_page() on incremented pfn counter.
+ */
+#define __contig_next_page(page, pageblock_left, pfn, increment) \
+	((page) + (increment))
+
+#define __contig_first_page(pageblock_left, pfn) pfn_to_page(pfn)
+
+#else
+
+/*
+ * If we cross pageblock boundary, make sure we get a valid page pointer.  If
+ * we are within pageblock, incrementing the pointer is good enough, and is
+ * a bit of an optimisation.
+ */
+#define __contig_next_page(page, pageblock_left, pfn, increment)	\
+	(likely((pageblock_left) -= (increment)) ? (page) + (increment)	\
+	 : (((pageblock_left) = pageblock_nr_pages), pfn_to_page(pfn)))
+
+#define __contig_first_page(pageblock_left, pfn) (			\
+	((pageblock_left) = pageblock_nr_pages -			\
+		 ((pfn) & (pageblock_nr_pages - 1))),			\
+	pfn_to_page(pfn))
+
+
+#endif
+
 unsigned long alloc_contig_freed_pages(unsigned long start, unsigned long end,
 				       gfp_t flag)
 {
+	unsigned long pageblock_left __unused;
 	unsigned long pfn = start, count;
 	struct page *page;
 	struct zone *zone;
@@ -5729,27 +5761,37 @@ unsigned long alloc_contig_freed_pages(unsigned long start, unsigned long end,
 
 	spin_lock_irq(&zone->lock);
 
-	page = pfn_to_page(pfn);
+	page = __contig_first_page(pageblock_left, pfn);
 	for (;;) {
-		VM_BUG_ON(page_count(page) || !PageBuddy(page));
+		VM_BUG_ON(!page_count(page) || !PageBuddy(page) ||
+			  page_zone(page) != zone);
+
 		list_del(&page->lru);
 		order = page_order(page);
+		count = 1UL << order;
 		zone->free_area[order].nr_free--;
 		rmv_page_order(page);
-		__mod_zone_page_state(zone, NR_FREE_PAGES, -(1UL << order));
-		pfn  += 1 << order;
+		__mod_zone_page_state(zone, NR_FREE_PAGES, -(long)count);
+
+		pfn += count;
 		if (pfn >= end)
 			break;
 		VM_BUG_ON(!pfn_valid(pfn));
-		page += 1 << order;
+
+		page = __contig_next_page(page, pageblock_left, pfn, count);
 	}
 
 	spin_unlock_irq(&zone->lock);
 
 	/* After this, pages in the range can be freed one be one */
-	page = pfn_to_page(start);
-	for (count = pfn - start; count; --count, ++page)
+	count = pfn - start;
+	pfn = start;
+	page = __contig_first_page(pageblock_left, pfn);
+	for (; count; --count) {
 		prep_new_page(page, 0, flag);
+		++pfn;
+		page = __contig_next_page(page, pageblock_left, pfn, 1);
+	}
 
 	return pfn;
 }
@@ -5903,10 +5945,16 @@ done:
 	return ret;
 }
 
-void free_contig_pages(struct page *page, int nr_pages)
+void free_contig_pages(unsigned long pfn, unsigned nr_pages)
 {
-	for (; nr_pages; --nr_pages, ++page)
+	unsigned long pageblock_left __unused;
+	struct page *page = __contig_first_page(pageblock_left, pfn);
+
+	while (nr_pages--) {
 		__free_page(page);
+		++pfn;
+		page = __contig_next_page(page, pageblock_left, pfn, 1);
+	}
 }
 
 #ifdef CONFIG_MEMORY_HOTREMOVE
-- 
1.7.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
