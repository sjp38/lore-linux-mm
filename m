Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f197.google.com (mail-ua0-f197.google.com [209.85.217.197])
	by kanga.kvack.org (Postfix) with ESMTP id 521576B0262
	for <linux-mm@kvack.org>; Sat,  5 Nov 2016 04:09:03 -0400 (EDT)
Received: by mail-ua0-f197.google.com with SMTP id 34so75372965uac.6
        for <linux-mm@kvack.org>; Sat, 05 Nov 2016 01:09:03 -0700 (PDT)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTPS id r13si5449885vkf.193.2016.11.05.01.08.11
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 05 Nov 2016 01:09:02 -0700 (PDT)
Message-ID: <581D9103.1000202@huawei.com>
Date: Sat, 5 Nov 2016 15:57:55 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: [RFC][PATCH] mm: merge as soon as possible when pcp alloc/free
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, "'Kirill A . Shutemov'" <kirill.shutemov@linux.intel.com>, Taku Izumi <izumi.taku@jp.fujitsu.com>
Cc: Yisheng Xie <xieyisheng1@huawei.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

Usually the memory of android phones is very small, so after a long
running, the fragment is very large. Kernel stack which called by
alloc_thread_stack_node() usually alloc 16K memory, and it failed
frequently.

However we have CONFIG_VMAP_STACK now, but it do not support arm64,
and maybe it has some regression because of vmalloc, it need to
find an area and create page table dynamically, this will take a short
time.

I think we can merge as soon as possible when pcp alloc/free to reduce
fragment. The pcp page is hot page, so free it will cause cache miss,
I use perf to test it, but it seems the regression is not so much, maybe
it need to test more. Any reply is welcome.

no patch:
perf stat -e cache-misses make -j50

Kernel: arch/x86/boot/bzImage is ready  (#10)

 Performance counter stats for 'make -j50':

    17,845,292,704      cache-misses

     157.605906725 seconds time elapsed

patched:
perf stat -e cache-misses make -j50

Kernel: arch/x86/boot/bzImage is ready  (#8)

 Performance counter stats for 'make -j50':

    17,876,726,774      cache-misses

     156.293720662 seconds time elapsed

nopatch:
make clean, dropcache, then make -j50, CONFIG_VMAP_STACK is off
[root@localhost ~]# cat /proc/buddyinfo
Node 0, zone      DMA      3      0      2      1      3      2      2      1      0      1      3
Node 0, zone    DMA32      4      4      1      5      2      4      2      2      3      1    447
Node 0, zone   Normal   2389    418    668    707    738    451    246     93     42     21  15147
Node 1, zone   Normal   1137    386    583    631    878    311     80     12      2      8  15640
Node 2, zone   Normal   1875    230    323    462    729    453    177     67     12      9  15749
Node 3, zone   Normal   1675    452    503    898    928    628    256     70     25     14  11688
Node 4, zone   Normal   1917    407    306   2706   1722    909    477    218     54     34  15682
Node 5, zone   Normal   4330   9785   6265   2612   1404    703    276    113     33      7  15730
Node 6, zone   Normal    754    211   1093   1023    748    599    352    193    107     43  15672
Node 7, zone   Normal   1092    133    819    807    729    549    254    120     52     28  15500
[root@localhost ~]# cat /sys/kernel/debug/extfrag/unusable_index
Node 0, zone      DMA 0.000 0.000 0.000 0.002 0.004 0.016 0.032 0.065 0.097 0.097 0.226
Node 0, zone    DMA32 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.001 0.002 0.004
Node 0, zone   Normal 0.000 0.000 0.000 0.000 0.000 0.001 0.002 0.003 0.004 0.004 0.005
Node 1, zone   Normal 0.000 0.000 0.000 0.000 0.000 0.001 0.002 0.002 0.002 0.002 0.002
Node 2, zone   Normal 0.000 0.000 0.000 0.000 0.000 0.001 0.002 0.002 0.003 0.003 0.003
Node 3, zone   Normal 0.000 0.000 0.000 0.000 0.000 0.002 0.003 0.005 0.005 0.006 0.007
Node 4, zone   Normal 0.000 0.000 0.000 0.000 0.001 0.003 0.005 0.006 0.008 0.009 0.010
Node 5, zone   Normal 0.000 0.000 0.001 0.003 0.004 0.005 0.007 0.008 0.009 0.009 0.009
Node 6, zone   Normal 0.000 0.000 0.000 0.000 0.000 0.001 0.002 0.004 0.005 0.007 0.008
Node 7, zone   Normal 0.000 0.000 0.000 0.000 0.000 0.001 0.002 0.003 0.004 0.005 0.006

patched:
make clean, dropcache, then make -j50, CONFIG_VMAP_STACK is off
[root@localhost ~]# cat /proc/buddyinfo
Node 0, zone      DMA      1      1      2      1      3      2      2      1      0      1      3
Node 0, zone    DMA32      3      3      0      2      2      4      2      2      3      1    447
Node 0, zone   Normal   1293   1097    159    564    620    392    242     89     49     21  15154
Node 1, zone   Normal   1195    369    155     73    295    260     92     32      8     10  15769
Node 2, zone   Normal   1478    434    160    846   1397    590    274    118     39     25  15753
Node 3, zone   Normal    892    285    176    625    691    450    226     78     33     14  11596
Node 4, zone   Normal    604    217     28    468   1560    690    292    126     46     31  15741
Node 5, zone   Normal    888    225    101    263    483    319    196     97     30     24  15726
Node 6, zone   Normal   1908   9294   7075   3373   1765    759    243    128     21     20  15591
Node 7, zone   Normal   1362   1126   1271    646    558    377    170     84     37     35  15602
[root@localhost ~]# cat /sys/kernel/debug/extfrag/unusable_index
Node 0, zone      DMA 0.000 0.000 0.000 0.002 0.004 0.016 0.032 0.065 0.097 0.097 0.226
Node 0, zone    DMA32 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.001 0.002 0.004
Node 0, zone   Normal 0.000 0.000 0.000 0.000 0.000 0.001 0.001 0.002 0.003 0.004 0.005
Node 1, zone   Normal 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.001 0.001 0.001 0.001
Node 2, zone   Normal 0.000 0.000 0.000 0.000 0.000 0.002 0.003 0.004 0.005 0.005 0.006
Node 3, zone   Normal 0.000 0.000 0.000 0.000 0.000 0.001 0.002 0.003 0.004 0.005 0.005
Node 4, zone   Normal 0.000 0.000 0.000 0.000 0.000 0.001 0.003 0.004 0.005 0.006 0.007
Node 5, zone   Normal 0.000 0.000 0.000 0.000 0.000 0.000 0.001 0.002 0.002 0.003 0.004
Node 6, zone   Normal 0.000 0.000 0.001 0.003 0.004 0.006 0.007 0.008 0.009 0.010 0.010
Node 7, zone   Normal 0.000 0.000 0.000 0.000 0.000 0.001 0.002 0.002 0.003 0.004 0.005


Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
---
 mm/page_alloc.c | 29 +++++++++++++++++++++++++++++
 1 file changed, 29 insertions(+)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 8fd42aa..82257e6 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2413,6 +2413,8 @@ void free_hot_cold_page(struct page *page, bool cold)
 	unsigned long flags;
 	unsigned long pfn = page_to_pfn(page);
 	int migratetype;
+	unsigned long page_idx = pfn & 1UL;
+	struct page *buddy;
 
 	if (!free_pcp_prepare(page))
 		return;
@@ -2437,6 +2439,16 @@ void free_hot_cold_page(struct page *page, bool cold)
 		migratetype = MIGRATE_MOVABLE;
 	}
 
+	if (page_idx)
+		buddy = page - 1;
+	else
+		buddy = page + 1;
+	/* merge immediately if buddy is free */	
+	if (PageBuddy(buddy)) {
+		free_one_page(zone, page, pfn, 0, migratetype);
+		goto out;
+	}
+
 	pcp = &this_cpu_ptr(zone->pageset)->pcp;
 	if (!cold)
 		list_add(&page->lru, &pcp->lists[migratetype]);
@@ -2591,8 +2603,12 @@ struct page *buffered_rmqueue(struct zone *preferred_zone,
 	if (likely(order == 0)) {
 		struct per_cpu_pages *pcp;
 		struct list_head *list;
+		unsigned long page_idx;
+		struct page *buddy;
+		int retry = 0;
 
 		local_irq_save(flags);
+retry:
 		do {
 			pcp = &this_cpu_ptr(zone->pageset)->pcp;
 			list = &pcp->lists[migratetype];
@@ -2612,6 +2628,19 @@ struct page *buffered_rmqueue(struct zone *preferred_zone,
 			list_del(&page->lru);
 			pcp->count--;
 
+			page_idx = page_to_pfn(page) & 1UL;
+			if (page_idx)
+				buddy = page - 1;
+			else
+				buddy = page + 1;
+			/* merge immediately if buddy is free */
+			if (PageBuddy(buddy) && retry < 3) {
+				free_one_page(page_zone(page), page,
+						page_to_pfn(page), 0, migratetype);
+				retry++;
+				goto retry;
+			}
+
 		} while (check_new_pcp(page));
 	} else {
 		/*
-- 
1.8.3.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
