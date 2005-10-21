From: Mel Gorman <mel@csn.ul.ie>
Message-Id: <20051021095718.14409.28464.sendpatchset@skynet.csn.ul.ie>
In-Reply-To: <20051021095658.14409.26527.sendpatchset@skynet.csn.ul.ie>
References: <20051021095658.14409.26527.sendpatchset@skynet.csn.ul.ie>
Subject: [PATCH 4/8] Fragmentation Avoidance V18: 004_markfree
Date: Fri, 21 Oct 2005 10:57:19 +0100 (IST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, lhms-devel@lists.sourceforge.net
Cc: Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

This patch alters show_free_areas() to print out the number of free pages
for each reclaim type. Without this patch, only an aggregate number is
displayed. Before this patch, the output of show_free_area() would include
something like;

DMA: 2*4kB 1*8kB 5*16kB 3*32kB 3*64kB 3*128kB 2*256kB 0*512kB 1*1024kB 1*2048kB 2*4096kB = 12544kB
Normal: 34*4kB 57*8kB 14*16kB 4*32kB 4*64kB 2*128kB 2*256kB 2*512kB 2*1024kB 2*2048kB 210*4096kB = 869296kB
HighMem: 1*4kB 0*8kB 15*16kB 23*32kB 11*64kB 10*128kB 2*256kB 2*512kB 1*1024kB 1*2048kB 153*4096kB = 634260kB

After, it shows something like;

DMA: (2+0+0+0)2*4kB (1+0+0+0)1*8kB (5+0+0+0)5*16kB (3+0+0+0)3*32kB (3+0+0+0)3*64kB (3+0+0+0)3*128kB (2+0+0+0)2*256kB (0+0+0+0)0*512kB (1+0+0+0)1*1024kB (1+0+0+0)1*2048kB (2+0+0+0)2*4096kB = 12544kB
Normal: (21+0+13+0)34*4kB (52+1+4+0)57*8kB (12+0+2+0)14*16kB (2+1+1+0)4*32kB (3+1+0+0)4*64kB (1+0+1+0)2*128kB (1+1+0+0)2*256kB (1+1+0+0)2*512kB (1+0+1+0)2*1024kB (1+0+1+0)2*2048kB (210+0+0+0)210*4096kB = 869296kB
HighMem: (1+0+0+0)1*4kB (0+0+0+0)0*8kB (0+15+0+0)15*16kB (1+22+0+0)23*32kB (0+11+0+0)11*64kB (2+8+0+0)10*128kB (0+2+0+0)2*256kB (0+2+0+0)2*512kB (0+1+0+0)1*1024kB (1+0+0+0)1*2048kB (153+0+0+0)153*4096kB = 634260kB

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
diff -rup -X /usr/src/patchset-0.5/bin//dontdiff linux-2.6.14-rc4-mm1-003_fragcore/mm/page_alloc.c linux-2.6.14-rc4-mm1-004_markfree/mm/page_alloc.c
--- linux-2.6.14-rc4-mm1-003_fragcore/mm/page_alloc.c	2005-10-19 22:10:51.000000000 +0100
+++ linux-2.6.14-rc4-mm1-004_markfree/mm/page_alloc.c	2005-10-19 22:11:37.000000000 +0100
@@ -1630,12 +1630,12 @@ void show_free_areas(void)
 	}
 
 	for_each_zone(zone) {
- 		unsigned long nr = 0;
+		unsigned long tnr = 0;
 		unsigned long total = 0;
-		unsigned long flags,order;
+		unsigned long nr,flags,order;
 
 		show_node(zone);
-		printk("%s: ", zone->name);
+		printk("%s: (", zone->name);
 		if (!zone->present_pages) {
 			printk("empty\n");
 			continue;
@@ -1643,17 +1643,21 @@ void show_free_areas(void)
 
 		spin_lock_irqsave(&zone->lock, flags);
 		for_each_rclmtype_order(type, order) {
-			nr += zone->free_area_lists[type][order].nr_free;
+			nr = zone->free_area_lists[type][order].nr_free;
+			tnr += nr;
 			total += nr << order;
 
+			printk("%lu", nr);
 			/*
 			 * If type had reached RCLM_TYPE, the free pages
 			 * for this order have been summed up
 			 */
 			if (type == RCLM_TYPES-1) {
-				printk("%lu*%lukB ", nr, K(1UL) << order);
+				printk(")%lu*%lukB %s", tnr, K(1UL) << order,
+					order == MAX_ORDER-1 ? "" : "(");
 				nr = 0;
-			}
+			} else
+				printk("+");
 		}
 		spin_unlock_irqrestore(&zone->lock, flags);
 		printk("= %lukB\n", K(total));

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
