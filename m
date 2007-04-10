From: Mel Gorman <mel@csn.ul.ie>
Message-Id: <20070410160324.10742.52582.sendpatchset@skynet.skynet.ie>
In-Reply-To: <20070410160244.10742.42187.sendpatchset@skynet.skynet.ie>
References: <20070410160244.10742.42187.sendpatchset@skynet.skynet.ie>
Subject: [PATCH 2/4] Do not group pages by mobility type on low memory systems
Date: Tue, 10 Apr 2007 17:03:24 +0100 (IST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Grouping pages by mobility can only successfully operate when there
are more MAX_ORDER_NR_PAGES areas than mobility types.  When there are
insufficient areas, fallbacks cannot be avoided.  This has noticeable
performance impacts on machines with small amounts of memory in comparison
to MAX_ORDER_NR_PAGES. For example, on IA64 with a configuration including
huge pages spans 1GiB with MAX_ORDER_NR_PAGES so would need at least 4GiB
of RAM before grouping pages by mobility would be useful. In comparison,
an x86 would need 16MB.

This patch checks the size of vm_total_pages in build_all_zonelists(). If
there are not enough areas,  mobility is effectivly disabled by considering
all allocations as the same type (UNMOVABLE).  This is achived via a
__read_mostly flag.

With this patch, performance is comparable to disabling grouping pages
by mobility at compile-time on a test machine with insufficient memory.
With this patch, it is reasonable to get rid of grouping pages by mobility
a compile-time option.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
Acked-by: Andy Whitcroft <apw@shadowen.org>
---

 page_alloc.c |   27 +++++++++++++++++++++++++--
 1 files changed, 25 insertions(+), 2 deletions(-)

diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.21-rc6-mm1-001_remove_unnecessary_check/mm/page_alloc.c linux-2.6.21-rc6-mm1-002_disable_on_smallmem/mm/page_alloc.c
--- linux-2.6.21-rc6-mm1-001_remove_unnecessary_check/mm/page_alloc.c	2007-04-09 23:27:58.000000000 +0100
+++ linux-2.6.21-rc6-mm1-002_disable_on_smallmem/mm/page_alloc.c	2007-04-10 11:28:01.000000000 +0100
@@ -145,8 +145,13 @@ static unsigned long __meminitdata dma_r
 #endif /* CONFIG_ARCH_POPULATES_NODE_MAP */
 
 #ifdef CONFIG_PAGE_GROUP_BY_MOBILITY
+int page_group_by_mobility_disabled __read_mostly;
+
 static inline int get_pageblock_migratetype(struct page *page)
 {
+	if (unlikely(page_group_by_mobility_disabled))
+		return MIGRATE_UNMOVABLE;
+
 	return get_pageblock_flags_group(page, PB_migrate, PB_migrate_end);
 }
 
@@ -160,6 +165,9 @@ static inline int allocflags_to_migratet
 {
 	WARN_ON((gfp_flags & GFP_MOVABLE_MASK) == GFP_MOVABLE_MASK);
 
+	if (unlikely(page_group_by_mobility_disabled))
+		return MIGRATE_UNMOVABLE;
+
 	/* Cluster high-order atomic allocations together */
 	if (unlikely(order > 0) &&
 			(!(gfp_flags & __GFP_WAIT) || in_interrupt()))
@@ -2298,8 +2306,23 @@ void __meminit build_all_zonelists(void)
 		/* cpuset refresh routine should be here */
 	}
 	vm_total_pages = nr_free_pagecache_pages();
-	printk("Built %i zonelists.  Total pages: %ld\n",
-			num_online_nodes(), vm_total_pages);
+
+	/*
+	 * Disable grouping by mobility if the number of pages in the
+	 * system is too low to allow the mechanism to work. It would be
+	 * more accurate, but expensive to check per-zone. This check is
+	 * made on memory-hotadd so a system can start with mobility
+	 * disabled and enable it later
+	 */
+	if (vm_total_pages < (MAX_ORDER_NR_PAGES * MIGRATE_TYPES))
+		page_group_by_mobility_disabled = 1;
+	else
+		page_group_by_mobility_disabled = 0;
+
+	printk("Built %i zonelists, mobility grouping %s.  Total pages: %ld\n",
+			num_online_nodes(),
+			page_group_by_mobility_disabled ? "off" : "on",
+			vm_total_pages);
 }
 
 /*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
