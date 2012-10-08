Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx109.postini.com [74.125.245.109])
	by kanga.kvack.org (Postfix) with SMTP id E2A476B002B
	for <linux-mm@kvack.org>; Mon,  8 Oct 2012 11:33:27 -0400 (EDT)
From: Rabin Vincent <rabin.vincent@stericsson.com>
Subject: [PATCH] mm: show migration types in show_mem
Date: Mon, 8 Oct 2012 17:32:18 +0200
Message-ID: <1349710338-13955-1-git-send-email-rabin.vincent@stericsson.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, rabin@rab.in, Rabin Vincent <rabin.vincent@stericsson.com>

This is useful to diagnose the reason for page allocation failure for
cases where there appear to be several free pages.

Example, with this alloc_pages(GFP_ATOMIC) failure:

 swapper/0: page allocation failure: order:0, mode:0x0
 ...
 Mem-info:
 Normal per-cpu:
 CPU    0: hi:   90, btch:  15 usd:  48
 CPU    1: hi:   90, btch:  15 usd:  21
 active_anon:0 inactive_anon:0 isolated_anon:0
  active_file:0 inactive_file:84 isolated_file:0
  unevictable:0 dirty:0 writeback:0 unstable:0
  free:4026 slab_reclaimable:75 slab_unreclaimable:484
  mapped:0 shmem:0 pagetables:0 bounce:0
 Normal free:16104kB min:2296kB low:2868kB high:3444kB active_anon:0kB
 inactive_anon:0kB active_file:0kB inactive_file:336kB unevictable:0kB
 isolated(anon):0kB isolated(file):0kB present:331776kB mlocked:0kB
 dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:300kB
 slab_unreclaimable:1936kB kernel_stack:328kB pagetables:0kB unstable:0kB
 bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
 lowmem_reserve[]: 0 0

Before the patch, it's hard (for me, at least) to say why all these free
chunks weren't considered for allocation:

 Normal: 0*4kB 0*8kB 0*16kB 0*32kB 0*64kB 0*128kB 1*256kB 1*512kB
 1*1024kB 1*2048kB 3*4096kB = 16128kB

After the patch, it's obvious that the reason is that all of these are
in the MIGRATE_CMA (C) freelist:

 Normal: 0*4kB 0*8kB 0*16kB 0*32kB 0*64kB 0*128kB 1*256kB (C) 1*512kB
 (C) 1*1024kB (C) 1*2048kB (C) 3*4096kB (C) = 16128kB

Signed-off-by: Rabin Vincent <rabin.vincent@stericsson.com>
---
 mm/page_alloc.c | 42 ++++++++++++++++++++++++++++++++++++++++--
 1 file changed, 40 insertions(+), 2 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index c13ea75..cbe5373 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2818,6 +2818,31 @@ out:
 
 #define K(x) ((x) << (PAGE_SHIFT-10))
 
+static void show_migration_types(unsigned char type)
+{
+	static const char types[MIGRATE_TYPES] = {
+		[MIGRATE_UNMOVABLE]	= 'U',
+		[MIGRATE_RECLAIMABLE]	= 'E',
+		[MIGRATE_MOVABLE]	= 'M',
+		[MIGRATE_RESERVE]	= 'R',
+#ifdef CONFIG_CMA
+		[MIGRATE_CMA]		= 'C',
+#endif
+		[MIGRATE_ISOLATE]	= 'I',
+	};
+	char tmp[MIGRATE_TYPES + 1];
+	char *p = tmp;
+	int i;
+
+	for (i = 0; i < MIGRATE_TYPES; i++) {
+		if (type & (1 << i))
+			*p++ = types[i];
+	}
+
+	*p = '\0';
+	printk("(%s) ", tmp);
+}
+
 /*
  * Show free area list (used inside shift_scroll-lock stuff)
  * We also calculate the percentage fragmentation. We do this by counting the
@@ -2942,6 +2967,7 @@ void show_free_areas(unsigned int filter)
 
 	for_each_populated_zone(zone) {
  		unsigned long nr[MAX_ORDER], flags, order, total = 0;
+		unsigned char types[MAX_ORDER];
 
 		if (skip_free_areas_node(filter, zone_to_nid(zone)))
 			continue;
@@ -2950,12 +2976,24 @@ void show_free_areas(unsigned int filter)
 
 		spin_lock_irqsave(&zone->lock, flags);
 		for (order = 0; order < MAX_ORDER; order++) {
-			nr[order] = zone->free_area[order].nr_free;
+			struct free_area *area = &zone->free_area[order];
+			int type;
+
+			nr[order] = area->nr_free;
 			total += nr[order] << order;
+
+			types[order] = 0;
+			for (type = 0; type < MIGRATE_TYPES; type++) {
+				if (!list_empty(&area->free_list[type]))
+					types[order] |= 1 << type;
+			}
 		}
 		spin_unlock_irqrestore(&zone->lock, flags);
-		for (order = 0; order < MAX_ORDER; order++)
+		for (order = 0; order < MAX_ORDER; order++) {
 			printk("%lu*%lukB ", nr[order], K(1UL) << order);
+			if (nr[order])
+				show_migration_types(types[order]);
+		}
 		printk("= %lukB\n", K(total));
 	}
 
-- 
1.7.11.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
