Message-ID: <43FBAEBA.2020300@jp.fujitsu.com>
Date: Wed, 22 Feb 2006 09:22:18 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: [PATCH] remove zone_mem_map 
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Cc: linux-mm <linux-mm@kvack.org>, Dave Hansen <haveblue@us.ibm.com>, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

This patch removes zone_mem_map from zone.
By this, (generic) page_to_pfn and pfn_to_page can use the same logic.
This modifies page_to_pfn implementation. Could anyone do performance test on NUMA ?

(ia64 is not affected by this because it doesn't use generic page_to_pfn.)

-- Kame


This patch removes zone_mem_map.

However pfn_to_page uses pgdat, page_to_pfn uses zone.
page_to_pfn can use pgdat instead of zone, which is only one
user of zone_mem_map. By modifing it, we can remove zone_mem_map.


Signed-Off-By: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Index: test/include/asm-generic/memory_model.h
===================================================================
--- test.orig/include/asm-generic/memory_model.h
+++ test/include/asm-generic/memory_model.h
@@ -47,9 +47,9 @@ extern unsigned long page_to_pfn(struct

  #define page_to_pfn(pg)			\
  ({	struct page *__pg = (pg);		\
-	struct zone *__zone = page_zone(__pg);	\
-	(unsigned long)(__pg - __zone->zone_mem_map) +	\
-	 __zone->zone_start_pfn;			\
+	struct pglist_data *__pgdat = NODE_DATA(page_to_nid(__pg));	\
+	(unsigned long)(__pg - __pgdat->node_mem_map) +	\
+	 __pgdat->node_start_pfn;			\
  })

  #elif defined(CONFIG_SPARSEMEM)
Index: test/include/linux/mmzone.h
===================================================================
--- test.orig/include/linux/mmzone.h
+++ test/include/linux/mmzone.h
@@ -225,7 +225,6 @@ struct zone {
  	 * Discontig memory support fields.
  	 */
  	struct pglist_data	*zone_pgdat;
-	struct page		*zone_mem_map;
  	/* zone_start_pfn == zone_start_paddr >> PAGE_SHIFT */
  	unsigned long		zone_start_pfn;

Index: test/mm/page_alloc.c
===================================================================
--- test.orig/mm/page_alloc.c
+++ test/mm/page_alloc.c
@@ -2117,7 +2117,6 @@ static __meminit void init_currently_emp
  	zone_wait_table_init(zone, size);
  	pgdat->nr_zones = zone_idx(zone) + 1;

-	zone->zone_mem_map = pfn_to_page(zone_start_pfn);
  	zone->zone_start_pfn = zone_start_pfn;

  	memmap_init(size, pgdat->node_id, zone_idx(zone), zone_start_pfn);
@@ -2844,8 +2843,8 @@ struct page *pfn_to_page(unsigned long p
  }
  unsigned long page_to_pfn(struct page *page)
  {
-	struct zone *zone = page_zone(page);
-	return (page - zone->zone_mem_map) + zone->zone_start_pfn;
+	struct pglist_data *pgdat = NODE_DATA(page_to_nid(page));
+	return (page - pgdat->node_mem_map) + pgdat->node_start_pfn;

  }
  #elif defined(CONFIG_SPARSEMEM)
Index: test/include/asm-alpha/mmzone.h
===================================================================
--- test.orig/include/asm-alpha/mmzone.h
+++ test/include/asm-alpha/mmzone.h
@@ -83,8 +83,7 @@ PLAT_NODE_DATA_LOCALNR(unsigned long p,
  	pte_t pte;                                                           \
  	unsigned long pfn;                                                   \
  									     \
-	pfn = ((unsigned long)((page)-page_zone(page)->zone_mem_map)) << 32; \
-	pfn += page_zone(page)->zone_start_pfn << 32;			     \
+	pfn = page_to_pfn(page) << 32; \
  	pte_val(pte) = pfn | pgprot_val(pgprot);			     \
  									     \
  	pte;								     \

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
