Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 78E7A6B025E
	for <linux-mm@kvack.org>; Thu, 12 Jan 2017 08:17:11 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id l2so3682952wml.5
        for <linux-mm@kvack.org>; Thu, 12 Jan 2017 05:17:11 -0800 (PST)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id i67si1829800wmh.90.2017.01.12.05.17.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Jan 2017 05:17:10 -0800 (PST)
Received: by mail-wm0-f67.google.com with SMTP id r144so3622864wme.0
        for <linux-mm@kvack.org>; Thu, 12 Jan 2017 05:17:10 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [RFC PATCH 3/4] arch, mm: remove arch specific show_mem
Date: Thu, 12 Jan 2017 14:16:58 +0100
Message-Id: <20170112131659.23058-4-mhocko@kernel.org>
In-Reply-To: <20170112131659.23058-1-mhocko@kernel.org>
References: <20170112131659.23058-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Michal Hocko <mhocko@suse.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, "James E.J. Bottomley" <jejb@parisc-linux.org>, Helge Deller <deller@gmx.de>, "David S. Miller" <davem@davemloft.net>, Chris Metcalf <cmetcalf@mellanox.com>, Guan Xuetao <gxt@mprc.pku.edu.cn>, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org

From: Michal Hocko <mhocko@suse.com>

We have a generic implementation for quite some time already. If there
is any arch specific information to be printed then we should add a
callback called from the generic code rather than duplicate the whole
show_mem. The current code has resulted in the code duplication and
the output divergence which is both confusing and adds maintainance
costs. Let's just get rid of this mess.

Cc: Tony Luck <tony.luck@intel.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>
Cc: "James E.J. Bottomley" <jejb@parisc-linux.org>
Cc: Helge Deller <deller@gmx.de>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Chris Metcalf <cmetcalf@mellanox.com>
Cc: Guan Xuetao <gxt@mprc.pku.edu.cn>
Cc: linux-ia64@vger.kernel.org
Cc: linux-parisc@vger.kernel.org
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 arch/ia64/mm/init.c      | 48 -----------------------------------------------
 arch/parisc/mm/init.c    | 49 ------------------------------------------------
 arch/sparc/mm/init_32.c  | 11 -----------
 arch/tile/mm/pgtable.c   | 45 --------------------------------------------
 arch/unicore32/mm/init.c | 44 -------------------------------------------
 5 files changed, 197 deletions(-)

diff --git a/arch/ia64/mm/init.c b/arch/ia64/mm/init.c
index 1841ef69183d..46afc8d5ebfc 100644
--- a/arch/ia64/mm/init.c
+++ b/arch/ia64/mm/init.c
@@ -684,51 +684,3 @@ int arch_remove_memory(u64 start, u64 size)
 }
 #endif
 #endif
-
-/**
- * show_mem - give short summary of memory stats
- *
- * Shows a simple page count of reserved and used pages in the system.
- * For discontig machines, it does this on a per-pgdat basis.
- */
-void show_mem(unsigned int filter)
-{
-	int total_reserved = 0;
-	unsigned long total_present = 0;
-	pg_data_t *pgdat;
-
-	printk(KERN_INFO "Mem-info:\n");
-	show_free_areas(filter);
-	printk(KERN_INFO "Node memory in pages:\n");
-	for_each_online_pgdat(pgdat) {
-		unsigned long present;
-		unsigned long flags;
-		int reserved = 0;
-		int nid = pgdat->node_id;
-		int zoneid;
-
-		if (skip_free_areas_node(filter, nid))
-			continue;
-		pgdat_resize_lock(pgdat, &flags);
-
-		for (zoneid = 0; zoneid < MAX_NR_ZONES; zoneid++) {
-			struct zone *zone = &pgdat->node_zones[zoneid];
-			if (!populated_zone(zone))
-				continue;
-
-			reserved += zone->present_pages - zone->managed_pages;
-		}
-		present = pgdat->node_present_pages;
-
-		pgdat_resize_unlock(pgdat, &flags);
-		total_present += present;
-		total_reserved += reserved;
-		printk(KERN_INFO "Node %4d:  RAM: %11ld, rsvd: %8d, ",
-		       nid, present, reserved);
-	}
-	printk(KERN_INFO "%ld pages of RAM\n", total_present);
-	printk(KERN_INFO "%d reserved pages\n", total_reserved);
-	printk(KERN_INFO "Total of %ld pages in page table cache\n",
-	       quicklist_total_size());
-	printk(KERN_INFO "%ld free buffer pages\n", nr_free_buffer_pages());
-}
diff --git a/arch/parisc/mm/init.c b/arch/parisc/mm/init.c
index e02ada312be8..64bfdf636f39 100644
--- a/arch/parisc/mm/init.c
+++ b/arch/parisc/mm/init.c
@@ -653,55 +653,6 @@ void __init mem_init(void)
 unsigned long *empty_zero_page __read_mostly;
 EXPORT_SYMBOL(empty_zero_page);
 
-void show_mem(unsigned int filter)
-{
-	int total = 0,reserved = 0;
-	pg_data_t *pgdat;
-
-	printk(KERN_INFO "Mem-info:\n");
-	show_free_areas(filter);
-
-	for_each_online_pgdat(pgdat) {
-		unsigned long flags;
-		int zoneid;
-
-		pgdat_resize_lock(pgdat, &flags);
-		for (zoneid = 0; zoneid < MAX_NR_ZONES; zoneid++) {
-			struct zone *zone = &pgdat->node_zones[zoneid];
-			if (!populated_zone(zone))
-				continue;
-
-			total += zone->present_pages;
-			reserved = zone->present_pages - zone->managed_pages;
-		}
-		pgdat_resize_unlock(pgdat, &flags);
-	}
-
-	printk(KERN_INFO "%d pages of RAM\n", total);
-	printk(KERN_INFO "%d reserved pages\n", reserved);
-
-#ifdef CONFIG_DISCONTIGMEM
-	{
-		struct zonelist *zl;
-		int i, j;
-
-		for (i = 0; i < npmem_ranges; i++) {
-			zl = node_zonelist(i, 0);
-			for (j = 0; j < MAX_NR_ZONES; j++) {
-				struct zoneref *z;
-				struct zone *zone;
-
-				printk("Zone list for zone %d on node %d: ", j, i);
-				for_each_zone_zonelist(zone, z, zl, j)
-					printk("[%d/%s] ", zone_to_nid(zone),
-								zone->name);
-				printk("\n");
-			}
-		}
-	}
-#endif
-}
-
 /*
  * pagetable_init() sets up the page tables
  *
diff --git a/arch/sparc/mm/init_32.c b/arch/sparc/mm/init_32.c
index eb8287155279..c6afe98de4d9 100644
--- a/arch/sparc/mm/init_32.c
+++ b/arch/sparc/mm/init_32.c
@@ -55,17 +55,6 @@ extern unsigned int sparc_ramdisk_size;
 
 unsigned long highstart_pfn, highend_pfn;
 
-void show_mem(unsigned int filter)
-{
-	printk("Mem-info:\n");
-	show_free_areas(filter);
-	printk("Free swap:       %6ldkB\n",
-	       get_nr_swap_pages() << (PAGE_SHIFT-10));
-	printk("%ld pages of RAM\n", totalram_pages);
-	printk("%ld free pages\n", nr_free_pages());
-}
-
-
 unsigned long last_valid_pfn;
 
 unsigned long calc_highpages(void)
diff --git a/arch/tile/mm/pgtable.c b/arch/tile/mm/pgtable.c
index 7cc6ee7f1a58..492a7361e58e 100644
--- a/arch/tile/mm/pgtable.c
+++ b/arch/tile/mm/pgtable.c
@@ -36,51 +36,6 @@
 
 #define K(x) ((x) << (PAGE_SHIFT-10))
 
-/*
- * The normal show_free_areas() is too verbose on Tile, with dozens
- * of processors and often four NUMA zones each with high and lowmem.
- */
-void show_mem(unsigned int filter)
-{
-	struct zone *zone;
-
-	pr_err("Active:%lu inactive:%lu dirty:%lu writeback:%lu unstable:%lu free:%lu\n slab:%lu mapped:%lu pagetables:%lu bounce:%lu pagecache:%lu swap:%lu\n",
-	       (global_node_page_state(NR_ACTIVE_ANON) +
-		global_node_page_state(NR_ACTIVE_FILE)),
-	       (global_node_page_state(NR_INACTIVE_ANON) +
-		global_node_page_state(NR_INACTIVE_FILE)),
-	       global_node_page_state(NR_FILE_DIRTY),
-	       global_node_page_state(NR_WRITEBACK),
-	       global_node_page_state(NR_UNSTABLE_NFS),
-	       global_page_state(NR_FREE_PAGES),
-	       (global_page_state(NR_SLAB_RECLAIMABLE) +
-		global_page_state(NR_SLAB_UNRECLAIMABLE)),
-	       global_node_page_state(NR_FILE_MAPPED),
-	       global_page_state(NR_PAGETABLE),
-	       global_page_state(NR_BOUNCE),
-	       global_node_page_state(NR_FILE_PAGES),
-	       get_nr_swap_pages());
-
-	for_each_zone(zone) {
-		unsigned long flags, order, total = 0, largest_order = -1;
-
-		if (!populated_zone(zone))
-			continue;
-
-		spin_lock_irqsave(&zone->lock, flags);
-		for (order = 0; order < MAX_ORDER; order++) {
-			int nr = zone->free_area[order].nr_free;
-			total += nr << order;
-			if (nr)
-				largest_order = order;
-		}
-		spin_unlock_irqrestore(&zone->lock, flags);
-		pr_err("Node %d %7s: %lukB (largest %luKb)\n",
-		       zone_to_nid(zone), zone->name,
-		       K(total), largest_order ? K(1UL) << largest_order : 0);
-	}
-}
-
 /**
  * shatter_huge_page() - ensure a given address is mapped by a small page.
  *
diff --git a/arch/unicore32/mm/init.c b/arch/unicore32/mm/init.c
index be2bde9b07cf..f4950fbfe574 100644
--- a/arch/unicore32/mm/init.c
+++ b/arch/unicore32/mm/init.c
@@ -57,50 +57,6 @@ early_param("initrd", early_initrd);
  */
 struct meminfo meminfo;
 
-void show_mem(unsigned int filter)
-{
-	int free = 0, total = 0, reserved = 0;
-	int shared = 0, cached = 0, slab = 0, i;
-	struct meminfo *mi = &meminfo;
-
-	printk(KERN_DEFAULT "Mem-info:\n");
-	show_free_areas(filter);
-
-	for_each_bank(i, mi) {
-		struct membank *bank = &mi->bank[i];
-		unsigned int pfn1, pfn2;
-		struct page *page, *end;
-
-		pfn1 = bank_pfn_start(bank);
-		pfn2 = bank_pfn_end(bank);
-
-		page = pfn_to_page(pfn1);
-		end  = pfn_to_page(pfn2 - 1) + 1;
-
-		do {
-			total++;
-			if (PageReserved(page))
-				reserved++;
-			else if (PageSwapCache(page))
-				cached++;
-			else if (PageSlab(page))
-				slab++;
-			else if (!page_count(page))
-				free++;
-			else
-				shared += page_count(page) - 1;
-			page++;
-		} while (page < end);
-	}
-
-	printk(KERN_DEFAULT "%d pages of RAM\n", total);
-	printk(KERN_DEFAULT "%d free pages\n", free);
-	printk(KERN_DEFAULT "%d reserved pages\n", reserved);
-	printk(KERN_DEFAULT "%d slab pages\n", slab);
-	printk(KERN_DEFAULT "%d pages shared\n", shared);
-	printk(KERN_DEFAULT "%d pages swap cached\n", cached);
-}
-
 static void __init find_limits(unsigned long *min, unsigned long *max_low,
 	unsigned long *max_high)
 {
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
