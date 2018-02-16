Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 854656B005C
	for <linux-mm@kvack.org>; Fri, 16 Feb 2018 11:02:52 -0500 (EST)
Received: by mail-oi0-f72.google.com with SMTP id e15so1736523oic.1
        for <linux-mm@kvack.org>; Fri, 16 Feb 2018 08:02:52 -0800 (PST)
Received: from resqmta-ch2-04v.sys.comcast.net (resqmta-ch2-04v.sys.comcast.net. [69.252.207.36])
        by mx.google.com with ESMTPS id o77si1209023ioe.185.2018.02.16.08.02.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Feb 2018 08:02:28 -0800 (PST)
Message-Id: <20180216160121.583566579@linux.com>
Date: Fri, 16 Feb 2018 10:01:12 -0600
From: Christoph Lameter <cl@linux.com>
Subject: [RFC 2/2] Page order diagnostics
References: <20180216160110.641666320@linux.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline; filename=order_stats
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mel@skynet.ie>
Cc: Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org, linux-rdma@vger.kernel.org, akpm@linux-foundation.org, Thomas Schoebel-Theuer <tst@schoebel-theuer.de>, andi@firstfloor.org, Rik van Riel <riel@redhat.com>, Michal Hocko <mhocko@kernel.org>, Guy Shattah <sguy@mellanox.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Michal Nazarewicz <mina86@mina86.com>, Vlastimil Babka <vbabka@suse.cz>, David Nellans <dnellans@nvidia.com>, Laura Abbott <labbott@redhat.com>, Pavel Machek <pavel@ucw.cz>, Dave Hansen <dave.hansen@intel.com>, Mike Kravetz <mike.kravetz@oracle.com>

It is beneficial to know about the contiguous memory segments
available on a system and the number of allocations failing
for each page order.

This patch adds details per order statistics to /proc/meminfo
so the current memory use can be determined.

Also adds counters to /proc/vmstat to show allocation
failures for each page order.

Signed-off-by: Christoph Laeter <cl@linux.com>

Index: linux/include/linux/mmzone.h
===================================================================
--- linux.orig/include/linux/mmzone.h
+++ linux/include/linux/mmzone.h
@@ -185,6 +185,10 @@ enum node_stat_item {
 	NR_VMSCAN_IMMEDIATE,	/* Prioritise for reclaim when writeback ends */
 	NR_DIRTIED,		/* page dirtyings since bootup */
 	NR_WRITTEN,		/* page writings since bootup */
+#ifdef CONFIG_ORDER_STATS
+	NR_ORDER,
+	NR_ORDER_MAX = NR_ORDER + MAX_ORDER - 1,
+#endif
 	NR_VM_NODE_STAT_ITEMS
 };
 
Index: linux/mm/page_alloc.c
===================================================================
--- linux.orig/mm/page_alloc.c
+++ linux/mm/page_alloc.c
@@ -828,6 +828,10 @@ static inline void __free_one_page(struc
 	VM_BUG_ON_PAGE(pfn & ((1 << order) - 1), page);
 	VM_BUG_ON_PAGE(bad_range(zone, page), page);
 
+#ifdef CONFIG_ORDER_STATS
+	dec_node_page_state(page, NR_ORDER + order);
+#endif
+
 continue_merging:
 	while (order < max_order - 1) {
 		buddy_pfn = __find_buddy_pfn(pfn, order);
@@ -1285,6 +1289,9 @@ static void __init __free_pages_boot_cor
 	page_zone(page)->managed_pages += nr_pages;
 	set_page_refcounted(page);
 	__free_pages(page, order);
+#ifdef CONFIG_ORDER_STATS
+	inc_node_page_state(page, NR_ORDER + order);
+#endif
 }
 
 #if defined(CONFIG_HAVE_ARCH_EARLY_PFN_TO_NID) || \
@@ -1855,6 +1862,9 @@ struct page *__rmqueue_smallest(struct z
 		rmv_page_order(page);
 		area->nr_free--;
 		expand(zone, page, order, current_order, area, migratetype);
+#ifdef CONFIG_ORDER_STATS
+		inc_node_page_state(page, NR_ORDER + order);
+#endif
 		set_pcppage_migratetype(page, migratetype);
 		return page;
 	}
@@ -4169,6 +4179,11 @@ nopage:
 fail:
 	warn_alloc(gfp_mask, ac->nodemask,
 			"page allocation failure: order:%u", order);
+
+#ifdef CONFIG_ORDER_STATS
+	count_vm_event(ORDER0_ALLOC_FAIL + order);
+#endif
+
 got_pg:
 	return page;
 }
Index: linux/fs/proc/meminfo.c
===================================================================
--- linux.orig/fs/proc/meminfo.c
+++ linux/fs/proc/meminfo.c
@@ -51,6 +51,7 @@ static int meminfo_proc_show(struct seq_
 	long available;
 	unsigned long pages[NR_LRU_LISTS];
 	int lru;
+	int order;
 
 	si_meminfo(&i);
 	si_swapinfo(&i);
@@ -155,6 +156,11 @@ static int meminfo_proc_show(struct seq_
 		    global_zone_page_state(NR_FREE_CMA_PAGES));
 #endif
 
+#ifdef CONFIG_ORDER_STATS
+	for (order= 0; order < MAX_ORDER; order++)
+		seq_printf(m, "Order%2d Pages:     %5lu\n",
+			order, global_node_page_state(NR_ORDER + order));
+#endif
 	hugetlb_report_meminfo(m);
 
 	arch_report_meminfo(m);
Index: linux/mm/Kconfig
===================================================================
--- linux.orig/mm/Kconfig
+++ linux/mm/Kconfig
@@ -752,6 +752,15 @@ config PERCPU_STATS
 	  information includes global and per chunk statistics, which can
 	  be used to help understand percpu memory usage.
 
+config ORDER_STATS
+	bool "Statistics for different sized allocations"
+	default n
+	help
+	  Create statistics about the contiguous memory segments allocated
+	  through the page allocator. This creates statistics about the
+	  memory segments in use in /proc/meminfo and the node meminfo files
+	  as well as allocation failure statistics in /proc/vmstat.
+
 config GUP_BENCHMARK
 	bool "Enable infrastructure for get_user_pages_fast() benchmarking"
 	default n
Index: linux/include/linux/vm_event_item.h
===================================================================
--- linux.orig/include/linux/vm_event_item.h
+++ linux/include/linux/vm_event_item.h
@@ -111,6 +111,10 @@ enum vm_event_item { PGPGIN, PGPGOUT, PS
 		SWAP_RA,
 		SWAP_RA_HIT,
 #endif
+#ifdef CONFIG_ORDER_STATS
+		ORDER0_ALLOC_FAIL,
+		ORDER_MAX_FAIL = ORDER0_ALLOC_FAIL + MAX_ORDER -1,
+#endif
 		NR_VM_EVENT_ITEMS
 };
 
Index: linux/mm/vmstat.c
===================================================================
--- linux.orig/mm/vmstat.c
+++ linux/mm/vmstat.c
@@ -1289,6 +1289,52 @@ const char * const vmstat_text[] = {
 	"swap_ra",
 	"swap_ra_hit",
 #endif
+#ifdef CONFIG_ORDER_STATS
+	"order0_failure",
+	"order1_failure",
+	"order2_failure",
+	"order3_failure",
+	"order4_failure",
+	"order5_failure",
+	"order6_failure",
+	"order7_failure",
+	"order8_failure",
+	"order9_failure",
+	"order10_failure",
+#ifdef CONFIG_FORCE_MAX_ZONEORDER
+#if MAX_ORDER > 11
+	"order11_failure"
+#endif
+#if MAX_ORDER > 12
+	"order12_failure"
+#endif
+#if MAX_ORDER > 13
+	"order13_failure"
+#endif
+#if MAX_ORDER > 14
+	"order14_failure"
+#endif
+#if MAX_ORDER > 15
+	"order15_failure"
+#endif
+#if MAX_ORDER > 16
+	"order16_failure"
+#endif
+#if MAX_ORDER > 17
+	"order17_failure"
+#endif
+#if MAX_ORDER > 18
+	"order18_failure"
+#endif
+#if MAX_ORDER > 19
+	"order19_failure"
+#endif
+#if MAX_ORDER > 20
+#error Please add more lines...
+#endif
+
+#endif /* CONFIG_FORCE_MAX_ZONEORDER */
+#endif /* CONFIG_ORDER_STATS */
 #endif /* CONFIG_VM_EVENTS_COUNTERS */
 };
 #endif /* CONFIG_PROC_FS || CONFIG_SYSFS || CONFIG_NUMA */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
