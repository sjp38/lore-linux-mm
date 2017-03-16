Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id E46176B0398
	for <linux-mm@kvack.org>; Wed, 15 Mar 2017 21:43:36 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id 14so35764384itw.3
        for <linux-mm@kvack.org>; Wed, 15 Mar 2017 18:43:36 -0700 (PDT)
Received: from smtprelay.hostedemail.com (smtprelay0154.hostedemail.com. [216.40.44.154])
        by mx.google.com with ESMTPS id v65si4599819iof.134.2017.03.15.18.43.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Mar 2017 18:43:35 -0700 (PDT)
From: Joe Perches <joe@perches.com>
Subject: [PATCH 1/3] mm: page_alloc: Reduce object size by neatening printks
Date: Wed, 15 Mar 2017 18:43:13 -0700
Message-Id: <880b3172b67d806082284d80945e4a231a5574bb.1489628459.git.joe@perches.com>
In-Reply-To: <cover.1489628459.git.joe@perches.com>
References: <cover.1489628459.git.joe@perches.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org

Function calls with large argument counts cause x86-64 register
spilling.  Reducing the number of arguments in a multi-line printk
by converting to multiple printks which saves some object code size.

$ size mm/page_alloc.o* (defconfig)
   text    data     bss     dec     hex filename
  35914	   1699	    628	  38241	   9561	mm/page_alloc.o.new
  36018    1699     628   38345    95c9 mm/page_alloc.o.old

Miscellanea:

o Remove line leading spaces from the formerly multi-line printks
  commit a25700a53f71 ("mm: show bounce pages in oom killer output")
  back in 2007 started the leading space when a single long line
  was split into multiple lines but the leading space was likely
  mistakenly kept and subsequent commits followed suit.
o Align arguments in a few more printks

Signed-off-by: Joe Perches <joe@perches.com>
---
 mm/page_alloc.c | 237 ++++++++++++++++++++++++++++----------------------------
 1 file changed, 118 insertions(+), 119 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index f749b7ff7c50..5db9710cb932 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4505,79 +4505,79 @@ void show_free_areas(unsigned int filter, nodemask_t *nodemask)
 			free_pcp += per_cpu_ptr(zone->pageset, cpu)->pcp.count;
 	}
 
-	printk("active_anon:%lu inactive_anon:%lu isolated_anon:%lu\n"
-		" active_file:%lu inactive_file:%lu isolated_file:%lu\n"
-		" unevictable:%lu dirty:%lu writeback:%lu unstable:%lu\n"
-		" slab_reclaimable:%lu slab_unreclaimable:%lu\n"
-		" mapped:%lu shmem:%lu pagetables:%lu bounce:%lu\n"
-		" free:%lu free_pcp:%lu free_cma:%lu\n",
-		global_node_page_state(NR_ACTIVE_ANON),
-		global_node_page_state(NR_INACTIVE_ANON),
-		global_node_page_state(NR_ISOLATED_ANON),
-		global_node_page_state(NR_ACTIVE_FILE),
-		global_node_page_state(NR_INACTIVE_FILE),
-		global_node_page_state(NR_ISOLATED_FILE),
-		global_node_page_state(NR_UNEVICTABLE),
-		global_node_page_state(NR_FILE_DIRTY),
-		global_node_page_state(NR_WRITEBACK),
-		global_node_page_state(NR_UNSTABLE_NFS),
-		global_page_state(NR_SLAB_RECLAIMABLE),
-		global_page_state(NR_SLAB_UNRECLAIMABLE),
-		global_node_page_state(NR_FILE_MAPPED),
-		global_node_page_state(NR_SHMEM),
-		global_page_state(NR_PAGETABLE),
-		global_page_state(NR_BOUNCE),
-		global_page_state(NR_FREE_PAGES),
-		free_pcp,
-		global_page_state(NR_FREE_CMA_PAGES));
+	printk("active_anon:%lu inactive_anon:%lu isolated_anon:%lu\n",
+	       global_node_page_state(NR_ACTIVE_ANON),
+	       global_node_page_state(NR_INACTIVE_ANON),
+	       global_node_page_state(NR_ISOLATED_ANON));
+	printk("active_file:%lu inactive_file:%lu isolated_file:%lu\n",
+	       global_node_page_state(NR_ACTIVE_FILE),
+	       global_node_page_state(NR_INACTIVE_FILE),
+	       global_node_page_state(NR_ISOLATED_FILE));
+	printk("unevictable:%lu dirty:%lu writeback:%lu unstable:%lu\n",
+	       global_node_page_state(NR_UNEVICTABLE),
+	       global_node_page_state(NR_FILE_DIRTY),
+	       global_node_page_state(NR_WRITEBACK),
+	       global_node_page_state(NR_UNSTABLE_NFS));
+	printk("slab_reclaimable:%lu slab_unreclaimable:%lu\n",
+	       global_page_state(NR_SLAB_RECLAIMABLE),
+	       global_page_state(NR_SLAB_UNRECLAIMABLE));
+	printk("mapped:%lu shmem:%lu pagetables:%lu bounce:%lu\n",
+	       global_node_page_state(NR_FILE_MAPPED),
+	       global_node_page_state(NR_SHMEM),
+	       global_page_state(NR_PAGETABLE),
+	       global_page_state(NR_BOUNCE));
+	printk("free:%lu free_pcp:%lu free_cma:%lu\n",
+	       global_page_state(NR_FREE_PAGES),
+	       free_pcp,
+	       global_page_state(NR_FREE_CMA_PAGES));
 
 	for_each_online_pgdat(pgdat) {
 		if (show_mem_node_skip(filter, pgdat->node_id, nodemask))
 			continue;
 
 		printk("Node %d"
-			" active_anon:%lukB"
-			" inactive_anon:%lukB"
-			" active_file:%lukB"
-			" inactive_file:%lukB"
-			" unevictable:%lukB"
-			" isolated(anon):%lukB"
-			" isolated(file):%lukB"
-			" mapped:%lukB"
-			" dirty:%lukB"
-			" writeback:%lukB"
-			" shmem:%lukB"
+		       " active_anon:%lukB"
+		       " inactive_anon:%lukB"
+		       " active_file:%lukB"
+		       " inactive_file:%lukB"
+		       " unevictable:%lukB"
+		       " isolated(anon):%lukB"
+		       " isolated(file):%lukB"
+		       " mapped:%lukB"
+		       " dirty:%lukB"
+		       " writeback:%lukB"
+		       " shmem:%lukB"
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
-			" shmem_thp: %lukB"
-			" shmem_pmdmapped: %lukB"
-			" anon_thp: %lukB"
+		       " shmem_thp: %lukB"
+		       " shmem_pmdmapped: %lukB"
+		       " anon_thp: %lukB"
 #endif
-			" writeback_tmp:%lukB"
-			" unstable:%lukB"
-			" all_unreclaimable? %s"
-			"\n",
-			pgdat->node_id,
-			K(node_page_state(pgdat, NR_ACTIVE_ANON)),
-			K(node_page_state(pgdat, NR_INACTIVE_ANON)),
-			K(node_page_state(pgdat, NR_ACTIVE_FILE)),
-			K(node_page_state(pgdat, NR_INACTIVE_FILE)),
-			K(node_page_state(pgdat, NR_UNEVICTABLE)),
-			K(node_page_state(pgdat, NR_ISOLATED_ANON)),
-			K(node_page_state(pgdat, NR_ISOLATED_FILE)),
-			K(node_page_state(pgdat, NR_FILE_MAPPED)),
-			K(node_page_state(pgdat, NR_FILE_DIRTY)),
-			K(node_page_state(pgdat, NR_WRITEBACK)),
+		       " writeback_tmp:%lukB"
+		       " unstable:%lukB"
+		       " all_unreclaimable? %s"
+		       "\n",
+		       pgdat->node_id,
+		       K(node_page_state(pgdat, NR_ACTIVE_ANON)),
+		       K(node_page_state(pgdat, NR_INACTIVE_ANON)),
+		       K(node_page_state(pgdat, NR_ACTIVE_FILE)),
+		       K(node_page_state(pgdat, NR_INACTIVE_FILE)),
+		       K(node_page_state(pgdat, NR_UNEVICTABLE)),
+		       K(node_page_state(pgdat, NR_ISOLATED_ANON)),
+		       K(node_page_state(pgdat, NR_ISOLATED_FILE)),
+		       K(node_page_state(pgdat, NR_FILE_MAPPED)),
+		       K(node_page_state(pgdat, NR_FILE_DIRTY)),
+		       K(node_page_state(pgdat, NR_WRITEBACK)),
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
-			K(node_page_state(pgdat, NR_SHMEM_THPS) * HPAGE_PMD_NR),
-			K(node_page_state(pgdat, NR_SHMEM_PMDMAPPED)
-					* HPAGE_PMD_NR),
-			K(node_page_state(pgdat, NR_ANON_THPS) * HPAGE_PMD_NR),
+		       K(node_page_state(pgdat, NR_SHMEM_THPS) * HPAGE_PMD_NR),
+		       K(node_page_state(pgdat, NR_SHMEM_PMDMAPPED)
+			 * HPAGE_PMD_NR),
+		       K(node_page_state(pgdat, NR_ANON_THPS) * HPAGE_PMD_NR),
 #endif
-			K(node_page_state(pgdat, NR_SHMEM)),
-			K(node_page_state(pgdat, NR_WRITEBACK_TEMP)),
-			K(node_page_state(pgdat, NR_UNSTABLE_NFS)),
-			pgdat->kswapd_failures >= MAX_RECLAIM_RETRIES ?
-				"yes" : "no");
+		       K(node_page_state(pgdat, NR_SHMEM)),
+		       K(node_page_state(pgdat, NR_WRITEBACK_TEMP)),
+		       K(node_page_state(pgdat, NR_UNSTABLE_NFS)),
+		       pgdat->kswapd_failures >= MAX_RECLAIM_RETRIES ?
+		       "yes" : "no");
 	}
 
 	for_each_populated_zone(zone) {
@@ -4592,51 +4592,51 @@ void show_free_areas(unsigned int filter, nodemask_t *nodemask)
 
 		show_node(zone);
 		printk(KERN_CONT
-			"%s"
-			" free:%lukB"
-			" min:%lukB"
-			" low:%lukB"
-			" high:%lukB"
-			" active_anon:%lukB"
-			" inactive_anon:%lukB"
-			" active_file:%lukB"
-			" inactive_file:%lukB"
-			" unevictable:%lukB"
-			" writepending:%lukB"
-			" present:%lukB"
-			" managed:%lukB"
-			" mlocked:%lukB"
-			" slab_reclaimable:%lukB"
-			" slab_unreclaimable:%lukB"
-			" kernel_stack:%lukB"
-			" pagetables:%lukB"
-			" bounce:%lukB"
-			" free_pcp:%lukB"
-			" local_pcp:%ukB"
-			" free_cma:%lukB"
-			"\n",
-			zone->name,
-			K(zone_page_state(zone, NR_FREE_PAGES)),
-			K(min_wmark_pages(zone)),
-			K(low_wmark_pages(zone)),
-			K(high_wmark_pages(zone)),
-			K(zone_page_state(zone, NR_ZONE_ACTIVE_ANON)),
-			K(zone_page_state(zone, NR_ZONE_INACTIVE_ANON)),
-			K(zone_page_state(zone, NR_ZONE_ACTIVE_FILE)),
-			K(zone_page_state(zone, NR_ZONE_INACTIVE_FILE)),
-			K(zone_page_state(zone, NR_ZONE_UNEVICTABLE)),
-			K(zone_page_state(zone, NR_ZONE_WRITE_PENDING)),
-			K(zone->present_pages),
-			K(zone->managed_pages),
-			K(zone_page_state(zone, NR_MLOCK)),
-			K(zone_page_state(zone, NR_SLAB_RECLAIMABLE)),
-			K(zone_page_state(zone, NR_SLAB_UNRECLAIMABLE)),
-			zone_page_state(zone, NR_KERNEL_STACK_KB),
-			K(zone_page_state(zone, NR_PAGETABLE)),
-			K(zone_page_state(zone, NR_BOUNCE)),
-			K(free_pcp),
-			K(this_cpu_read(zone->pageset->pcp.count)),
-			K(zone_page_state(zone, NR_FREE_CMA_PAGES)));
+		       "%s"
+		       " free:%lukB"
+		       " min:%lukB"
+		       " low:%lukB"
+		       " high:%lukB"
+		       " active_anon:%lukB"
+		       " inactive_anon:%lukB"
+		       " active_file:%lukB"
+		       " inactive_file:%lukB"
+		       " unevictable:%lukB"
+		       " writepending:%lukB"
+		       " present:%lukB"
+		       " managed:%lukB"
+		       " mlocked:%lukB"
+		       " slab_reclaimable:%lukB"
+		       " slab_unreclaimable:%lukB"
+		       " kernel_stack:%lukB"
+		       " pagetables:%lukB"
+		       " bounce:%lukB"
+		       " free_pcp:%lukB"
+		       " local_pcp:%ukB"
+		       " free_cma:%lukB"
+		       "\n",
+		       zone->name,
+		       K(zone_page_state(zone, NR_FREE_PAGES)),
+		       K(min_wmark_pages(zone)),
+		       K(low_wmark_pages(zone)),
+		       K(high_wmark_pages(zone)),
+		       K(zone_page_state(zone, NR_ZONE_ACTIVE_ANON)),
+		       K(zone_page_state(zone, NR_ZONE_INACTIVE_ANON)),
+		       K(zone_page_state(zone, NR_ZONE_ACTIVE_FILE)),
+		       K(zone_page_state(zone, NR_ZONE_INACTIVE_FILE)),
+		       K(zone_page_state(zone, NR_ZONE_UNEVICTABLE)),
+		       K(zone_page_state(zone, NR_ZONE_WRITE_PENDING)),
+		       K(zone->present_pages),
+		       K(zone->managed_pages),
+		       K(zone_page_state(zone, NR_MLOCK)),
+		       K(zone_page_state(zone, NR_SLAB_RECLAIMABLE)),
+		       K(zone_page_state(zone, NR_SLAB_UNRECLAIMABLE)),
+		       zone_page_state(zone, NR_KERNEL_STACK_KB),
+		       K(zone_page_state(zone, NR_PAGETABLE)),
+		       K(zone_page_state(zone, NR_BOUNCE)),
+		       K(free_pcp),
+		       K(this_cpu_read(zone->pageset->pcp.count)),
+		       K(zone_page_state(zone, NR_FREE_CMA_PAGES)));
 		printk("lowmem_reserve[]:");
 		for (i = 0; i < MAX_NR_ZONES; i++)
 			printk(KERN_CONT " %ld", zone->lowmem_reserve[i]);
@@ -4679,7 +4679,8 @@ void show_free_areas(unsigned int filter, nodemask_t *nodemask)
 
 	hugetlb_show_meminfo();
 
-	printk("%ld total pagecache pages\n", global_node_page_state(NR_FILE_PAGES));
+	printk("%ld total pagecache pages\n",
+	       global_node_page_state(NR_FILE_PAGES));
 
 	show_swap_cache_info();
 }
@@ -5516,8 +5517,7 @@ static __meminit void zone_pcp_init(struct zone *zone)
 
 	if (populated_zone(zone))
 		printk(KERN_DEBUG "  %s zone: %lu pages, LIFO batch:%u\n",
-			zone->name, zone->present_pages,
-					 zone_batchsize(zone));
+		       zone->name, zone->present_pages, zone_batchsize(zone));
 }
 
 int __meminit init_currently_empty_zone(struct zone *zone,
@@ -5891,8 +5891,8 @@ static void __meminit calculate_node_totalpages(struct pglist_data *pgdat,
 
 	pgdat->node_spanned_pages = totalpages;
 	pgdat->node_present_pages = realtotalpages;
-	printk(KERN_DEBUG "On node %d totalpages: %lu\n", pgdat->node_id,
-							realtotalpages);
+	printk(KERN_DEBUG "On node %d totalpages: %lu\n",
+	       pgdat->node_id, realtotalpages);
 }
 
 #ifndef CONFIG_SPARSEMEM
@@ -6042,8 +6042,7 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat)
 			if (freesize >= memmap_pages) {
 				freesize -= memmap_pages;
 				if (memmap_pages)
-					printk(KERN_DEBUG
-					       "  %s zone: %lu pages used for memmap\n",
+					printk(KERN_DEBUG "  %s zone: %lu pages used for memmap\n",
 					       zone_names[j], memmap_pages);
 			} else
 				pr_warn("  %s zone: %lu pages exceeds freesize %lu\n",
@@ -6054,7 +6053,7 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat)
 		if (j == 0 && freesize > dma_reserve) {
 			freesize -= dma_reserve;
 			printk(KERN_DEBUG "  %s zone: %lu pages reserved\n",
-					zone_names[0], dma_reserve);
+			       zone_names[0], dma_reserve);
 		}
 
 		if (!is_highmem_idx(j))
@@ -6163,9 +6162,9 @@ void __paginginit free_area_init_node(int nid, unsigned long *zones_size,
 
 	alloc_node_mem_map(pgdat);
 #ifdef CONFIG_FLAT_NODE_MEM_MAP
-	printk(KERN_DEBUG "free_area_init_node: node %d, pgdat %08lx, node_mem_map %08lx\n",
-		nid, (unsigned long)pgdat,
-		(unsigned long)pgdat->node_mem_map);
+	printk(KERN_DEBUG "%s: node %d, pgdat %08lx, node_mem_map %08lx\n",
+	       __func__, nid, (unsigned long)pgdat,
+	       (unsigned long)pgdat->node_mem_map);
 #endif
 
 	free_area_init_core(pgdat);
-- 
2.10.0.rc2.1.g053435c

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
