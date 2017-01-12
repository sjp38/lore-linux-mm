Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f200.google.com (mail-wj0-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5E8C36B0260
	for <linux-mm@kvack.org>; Thu, 12 Jan 2017 05:43:03 -0500 (EST)
Received: by mail-wj0-f200.google.com with SMTP id l1so2939796wja.2
        for <linux-mm@kvack.org>; Thu, 12 Jan 2017 02:43:03 -0800 (PST)
Received: from outbound-smtp05.blacknight.com (outbound-smtp05.blacknight.com. [81.17.249.38])
        by mx.google.com with ESMTPS id fa7si7115414wjd.16.2017.01.12.02.43.01
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 12 Jan 2017 02:43:01 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail01.blacknight.ie [81.17.254.10])
	by outbound-smtp05.blacknight.com (Postfix) with ESMTPS id 1C3E49914D
	for <linux-mm@kvack.org>; Thu, 12 Jan 2017 10:43:01 +0000 (UTC)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 3/3] mm, page_allocator: Only use per-cpu allocator for irq-safe requests
Date: Thu, 12 Jan 2017 10:43:00 +0000
Message-Id: <20170112104300.24345-4-mgorman@techsingularity.net>
In-Reply-To: <20170112104300.24345-1-mgorman@techsingularity.net>
References: <20170112104300.24345-1-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Hillf Danton <hillf.zj@alibaba-inc.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Mel Gorman <mgorman@techsingularity.net>

Many workloads that allocate pages are not handling an interrupt at a
time. As allocation requests may be from IRQ context, it's necessary to
disable/enable IRQs for every page allocation. This cost is the bulk
of the free path but also a significant percentage of the allocation
path.

This patch alters the locking and checks such that only irq-safe allocation
requests use the per-cpu allocator. All others acquire the irq-safe
zone->lock and allocate from the buddy allocator. It relies on disabling
preemption to safely access the per-cpu structures. It could be slightly
modified to avoid soft IRQs using it but it's not clear it's worthwhile.

This modification may slow allocations from IRQ context slightly but the main
gain from the per-cpu allocator is that it scales better for allocations
from multiple contexts. There is an implicit assumption that intensive
allocations from IRQ contexts on multiple CPUs from a single NUMA node are
rare and that the fast majority of scaling issues are encountered in !IRQ
contexts such as page faulting. It's worth noting that this patch is not
required for a bulk page allocator but it significantly reduces the overhead.

The following is results from a page allocator micro-benchmark. Only
order-0 is interesting as higher orders do not use the per-cpu allocator

                                          4.10.0-rc2                 4.10.0-rc2
                                             vanilla               irqsafe-v1r5
Amean    alloc-odr0-1               287.15 (  0.00%)           219.00 ( 23.73%)
Amean    alloc-odr0-2               221.23 (  0.00%)           183.23 ( 17.18%)
Amean    alloc-odr0-4               187.00 (  0.00%)           151.38 ( 19.05%)
Amean    alloc-odr0-8               167.54 (  0.00%)           132.77 ( 20.75%)
Amean    alloc-odr0-16              156.00 (  0.00%)           123.00 ( 21.15%)
Amean    alloc-odr0-32              149.00 (  0.00%)           118.31 ( 20.60%)
Amean    alloc-odr0-64              138.77 (  0.00%)           116.00 ( 16.41%)
Amean    alloc-odr0-128             145.00 (  0.00%)           118.00 ( 18.62%)
Amean    alloc-odr0-256             136.15 (  0.00%)           125.00 (  8.19%)
Amean    alloc-odr0-512             147.92 (  0.00%)           121.77 ( 17.68%)
Amean    alloc-odr0-1024            147.23 (  0.00%)           126.15 ( 14.32%)
Amean    alloc-odr0-2048            155.15 (  0.00%)           129.92 ( 16.26%)
Amean    alloc-odr0-4096            164.00 (  0.00%)           136.77 ( 16.60%)
Amean    alloc-odr0-8192            166.92 (  0.00%)           138.08 ( 17.28%)
Amean    alloc-odr0-16384           159.00 (  0.00%)           138.00 ( 13.21%)
Amean    free-odr0-1                165.00 (  0.00%)            89.00 ( 46.06%)
Amean    free-odr0-2                113.00 (  0.00%)            63.00 ( 44.25%)
Amean    free-odr0-4                 99.00 (  0.00%)            54.00 ( 45.45%)
Amean    free-odr0-8                 88.00 (  0.00%)            47.38 ( 46.15%)
Amean    free-odr0-16                83.00 (  0.00%)            46.00 ( 44.58%)
Amean    free-odr0-32                80.00 (  0.00%)            44.38 ( 44.52%)
Amean    free-odr0-64                72.62 (  0.00%)            43.00 ( 40.78%)
Amean    free-odr0-128               78.00 (  0.00%)            42.00 ( 46.15%)
Amean    free-odr0-256               80.46 (  0.00%)            57.00 ( 29.16%)
Amean    free-odr0-512               96.38 (  0.00%)            64.69 ( 32.88%)
Amean    free-odr0-1024             107.31 (  0.00%)            72.54 ( 32.40%)
Amean    free-odr0-2048             108.92 (  0.00%)            78.08 ( 28.32%)
Amean    free-odr0-4096             113.38 (  0.00%)            82.23 ( 27.48%)
Amean    free-odr0-8192             112.08 (  0.00%)            82.85 ( 26.08%)
Amean    free-odr0-16384            110.38 (  0.00%)            81.92 ( 25.78%)
Amean    total-odr0-1               452.15 (  0.00%)           308.00 ( 31.88%)
Amean    total-odr0-2               334.23 (  0.00%)           246.23 ( 26.33%)
Amean    total-odr0-4               286.00 (  0.00%)           205.38 ( 28.19%)
Amean    total-odr0-8               255.54 (  0.00%)           180.15 ( 29.50%)
Amean    total-odr0-16              239.00 (  0.00%)           169.00 ( 29.29%)
Amean    total-odr0-32              229.00 (  0.00%)           162.69 ( 28.96%)
Amean    total-odr0-64              211.38 (  0.00%)           159.00 ( 24.78%)
Amean    total-odr0-128             223.00 (  0.00%)           160.00 ( 28.25%)
Amean    total-odr0-256             216.62 (  0.00%)           182.00 ( 15.98%)
Amean    total-odr0-512             244.31 (  0.00%)           186.46 ( 23.68%)
Amean    total-odr0-1024            254.54 (  0.00%)           198.69 ( 21.94%)
Amean    total-odr0-2048            264.08 (  0.00%)           208.00 ( 21.24%)
Amean    total-odr0-4096            277.38 (  0.00%)           219.00 ( 21.05%)
Amean    total-odr0-8192            279.00 (  0.00%)           220.92 ( 20.82%)
Amean    total-odr0-16384           269.38 (  0.00%)           219.92 ( 18.36%)

This is the alloc, free and total overhead of allocating order-0 pages in
batches of 1 page up to 16384 pages. Avoiding disabling/enabling overhead
massively reduces overhead. Alloc overhead is roughly reduced by 14-20% in
most cases. The free path is reduced by 26-46% and the total reduction
is significant.

Many users require zeroing of pages from the page allocator which is the
vast cost of allocation. Hence, the impact on a basic page faulting benchmark
is not that significant

                              4.10.0-rc2            4.10.0-rc2
                                 vanilla          irqsafe-v1r5
Hmean    page_test   656632.98 (  0.00%)   675536.13 (  2.88%)
Hmean    brk_test   3845502.67 (  0.00%)  3867186.94 (  0.56%)
Stddev   page_test    10543.29 (  0.00%)     4104.07 ( 61.07%)
Stddev   brk_test     33472.36 (  0.00%)    15538.39 ( 53.58%)
CoeffVar page_test        1.61 (  0.00%)        0.61 ( 62.15%)
CoeffVar brk_test         0.87 (  0.00%)        0.40 ( 53.84%)
Max      page_test   666513.33 (  0.00%)   678640.00 (  1.82%)
Max      brk_test   3882800.00 (  0.00%)  3887008.66 (  0.11%)

This is from aim9 and the most notable outcome is that fault variability
is reduced by the patch. The headline improvement is small as the overall
fault cost, zeroing, page table insertion etc dominate relative to
disabling/enabling IRQs in the per-cpu allocator.

Similarly, little benefit was seen on networking benchmarks both localhost
and between physical server/clients where other costs dominate. It's
possible that this will only be noticable on very high speed networks.

Jesper Dangaard Brouer independently tested
this with a separate microbenchmark from
https://github.com/netoptimizer/prototype-kernel/tree/master/kernel/mm/bench

Micro-benchmarked with [1] page_bench02:
 modprobe page_bench02 page_order=0 run_flags=$((2#010)) loops=$((10**8)); \
  rmmod page_bench02 ; dmesg --notime | tail -n 4

Compared to baseline: 213 cycles(tsc) 53.417 ns
 - against this     : 184 cycles(tsc) 46.056 ns
 - Saving           : -29 cycles
 - Very close to expected 27 cycles saving [see below [2]]

Micro benchmarking via time_bench_sample[3], we get the cost of these
operations:

 time_bench: Type:for_loop                 Per elem: 0 cycles(tsc) 0.232 ns (step:0)
 time_bench: Type:spin_lock_unlock         Per elem: 33 cycles(tsc) 8.334 ns (step:0)
 time_bench: Type:spin_lock_unlock_irqsave Per elem: 62 cycles(tsc) 15.607 ns (step:0)
 time_bench: Type:irqsave_before_lock      Per elem: 57 cycles(tsc) 14.344 ns (step:0)
 time_bench: Type:spin_lock_unlock_irq     Per elem: 34 cycles(tsc) 8.560 ns (step:0)
 time_bench: Type:simple_irq_disable_before_lock Per elem: 37 cycles(tsc) 9.289 ns (step:0)
 time_bench: Type:local_BH_disable_enable  Per elem: 19 cycles(tsc) 4.920 ns (step:0)
 time_bench: Type:local_IRQ_disable_enable Per elem: 7 cycles(tsc) 1.864 ns (step:0)
 time_bench: Type:local_irq_save_restore   Per elem: 38 cycles(tsc) 9.665 ns (step:0)
 [Mel's patch removes a ^^^^^^^^^^^^^^^^]            ^^^^^^^^^ expected saving - preempt cost
 time_bench: Type:preempt_disable_enable   Per elem: 11 cycles(tsc) 2.794 ns (step:0)
 [adds a preempt  ^^^^^^^^^^^^^^^^^^^^^^]            ^^^^^^^^^ adds this cost
 time_bench: Type:funcion_call_cost        Per elem: 6 cycles(tsc) 1.689 ns (step:0)
 time_bench: Type:func_ptr_call_cost       Per elem: 11 cycles(tsc) 2.767 ns (step:0)
 time_bench: Type:page_alloc_put           Per elem: 211 cycles(tsc) 52.803 ns (step:0)

Thus, expected improvement is: 38-11 = 27 cycles.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
Acked-by: Hillf Danton <hillf.zj@alibaba-inc.com>
Acked-by: Jesper Dangaard Brouer <brouer@redhat.com>
---
 mm/page_alloc.c | 38 +++++++++++++++++---------------------
 1 file changed, 17 insertions(+), 21 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 4a602b7f258d..232cadbe9231 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1087,10 +1087,10 @@ static void free_pcppages_bulk(struct zone *zone, int count,
 {
 	int migratetype = 0;
 	int batch_free = 0;
-	unsigned long nr_scanned;
+	unsigned long nr_scanned, flags;
 	bool isolated_pageblocks;
 
-	spin_lock(&zone->lock);
+	spin_lock_irqsave(&zone->lock, flags);
 	isolated_pageblocks = has_isolate_pageblock(zone);
 	nr_scanned = node_page_state(zone->zone_pgdat, NR_PAGES_SCANNED);
 	if (nr_scanned)
@@ -1139,7 +1139,7 @@ static void free_pcppages_bulk(struct zone *zone, int count,
 			trace_mm_page_pcpu_drain(page, 0, mt);
 		} while (--count && --batch_free && !list_empty(list));
 	}
-	spin_unlock(&zone->lock);
+	spin_unlock_irqrestore(&zone->lock, flags);
 }
 
 static void free_one_page(struct zone *zone,
@@ -1147,8 +1147,8 @@ static void free_one_page(struct zone *zone,
 				unsigned int order,
 				int migratetype)
 {
-	unsigned long nr_scanned;
-	spin_lock(&zone->lock);
+	unsigned long nr_scanned, flags;
+	spin_lock_irqsave(&zone->lock, flags);
 	nr_scanned = node_page_state(zone->zone_pgdat, NR_PAGES_SCANNED);
 	if (nr_scanned)
 		__mod_node_page_state(zone->zone_pgdat, NR_PAGES_SCANNED, -nr_scanned);
@@ -1158,7 +1158,7 @@ static void free_one_page(struct zone *zone,
 		migratetype = get_pfnblock_migratetype(page, pfn);
 	}
 	__free_one_page(page, pfn, zone, order, migratetype);
-	spin_unlock(&zone->lock);
+	spin_unlock_irqrestore(&zone->lock, flags);
 }
 
 static void __meminit __init_single_page(struct page *page, unsigned long pfn,
@@ -1236,7 +1236,6 @@ void __meminit reserve_bootmem_region(phys_addr_t start, phys_addr_t end)
 
 static void __free_pages_ok(struct page *page, unsigned int order)
 {
-	unsigned long flags;
 	int migratetype;
 	unsigned long pfn = page_to_pfn(page);
 
@@ -1244,10 +1243,8 @@ static void __free_pages_ok(struct page *page, unsigned int order)
 		return;
 
 	migratetype = get_pfnblock_migratetype(page, pfn);
-	local_irq_save(flags);
-	__count_vm_events(PGFREE, 1 << order);
+	count_vm_events(PGFREE, 1 << order);
 	free_one_page(page_zone(page), page, pfn, order, migratetype);
-	local_irq_restore(flags);
 }
 
 static void __init __free_pages_boot_core(struct page *page, unsigned int order)
@@ -2219,8 +2216,9 @@ static int rmqueue_bulk(struct zone *zone, unsigned int order,
 			int migratetype, bool cold)
 {
 	int i, alloced = 0;
+	unsigned long flags;
 
-	spin_lock(&zone->lock);
+	spin_lock_irqsave(&zone->lock, flags);
 	for (i = 0; i < count; ++i) {
 		struct page *page = __rmqueue(zone, order, migratetype);
 		if (unlikely(page == NULL))
@@ -2256,7 +2254,7 @@ static int rmqueue_bulk(struct zone *zone, unsigned int order,
 	 * pages added to the pcp list.
 	 */
 	__mod_zone_page_state(zone, NR_FREE_PAGES, -(i << order));
-	spin_unlock(&zone->lock);
+	spin_unlock_irqrestore(&zone->lock, flags);
 	return alloced;
 }
 
@@ -2444,7 +2442,6 @@ void free_hot_cold_page(struct page *page, bool cold)
 {
 	struct zone *zone = page_zone(page);
 	struct per_cpu_pages *pcp;
-	unsigned long flags;
 	unsigned long pfn = page_to_pfn(page);
 	int migratetype;
 
@@ -2453,8 +2450,8 @@ void free_hot_cold_page(struct page *page, bool cold)
 
 	migratetype = get_pfnblock_migratetype(page, pfn);
 	set_pcppage_migratetype(page, migratetype);
-	local_irq_save(flags);
-	__count_vm_event(PGFREE);
+	preempt_disable();
+	count_vm_event(PGFREE);
 
 	/*
 	 * We only track unmovable, reclaimable and movable on pcp lists.
@@ -2484,7 +2481,7 @@ void free_hot_cold_page(struct page *page, bool cold)
 	}
 
 out:
-	local_irq_restore(flags);
+	preempt_enable_no_resched();
 }
 
 /*
@@ -2647,9 +2644,8 @@ static struct page *rmqueue_pcplist(struct zone *preferred_zone,
 	struct list_head *list;
 	bool cold = ((gfp_flags & __GFP_COLD) != 0);
 	struct page *page;
-	unsigned long flags;
 
-	local_irq_save(flags);
+	preempt_disable();
 	pcp = &this_cpu_ptr(zone->pageset)->pcp;
 	list = &pcp->lists[migratetype];
 	page = __rmqueue_pcplist(zone,  order, gfp_flags, migratetype,
@@ -2658,7 +2654,7 @@ static struct page *rmqueue_pcplist(struct zone *preferred_zone,
 		__count_zid_vm_events(PGALLOC, page_zonenum(page), 1 << order);
 		zone_statistics(preferred_zone, zone, gfp_flags);
 	}
-	local_irq_restore(flags);
+	preempt_enable_no_resched();
 	return page;
 }
 
@@ -2674,7 +2670,7 @@ struct page *rmqueue(struct zone *preferred_zone,
 	unsigned long flags;
 	struct page *page;
 
-	if (likely(order == 0))
+	if (likely(order == 0) && !in_interrupt())
 		return rmqueue_pcplist(preferred_zone, zone, order,
 				gfp_flags, migratetype);
 
@@ -3919,7 +3915,7 @@ EXPORT_SYMBOL(get_zeroed_page);
 void __free_pages(struct page *page, unsigned int order)
 {
 	if (put_page_testzero(page)) {
-		if (order == 0)
+		if (order == 0 && !in_interrupt())
 			free_hot_cold_page(page, false);
 		else
 			__free_pages_ok(page, order);
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
