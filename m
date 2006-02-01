Message-ID: <43E02945.2000508@jp.fujitsu.com>
Date: Wed, 01 Feb 2006 12:21:41 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: [RFC][PATCH] remove zone_mem_map [1/4] remove zone_mem_map.
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>
Cc: "Martin J. Bligh" <mbligh@mbligh.org>
List-ID: <linux-mm.kvack.org>

This patch removes zone->zone_mem_map.
Againt 2.6.16-rc1.

Because of SPARSEMEM's cleanup, there are no codes
which touches zone->zone_mem_map directly.

My purpose is:
    Reduce the assumptions of zones. Because of zone_mem_map,
    zone is considered to have contiguous mem_map. This patch removes
    that needless? assumption.
    I'll try to remove zone_start_pfn etc.. if I can go ahead.


This patch affects many archs which has NUMA, so enough tests
should be done. But I don't have test environments...
Please notify me if the kernel cannot be compiled or perfomance goes down
because of this patch.
Sigh, binary modules which uses page_to_pfn() will not work either ;)


Signed-Off-By: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Index: hogehoge/include/linux/mmzone.h
===================================================================
--- hogehoge.orig/include/linux/mmzone.h
+++ hogehoge/include/linux/mmzone.h
@@ -212,7 +212,6 @@ struct zone {
  	 * Discontig memory support fields.
  	 */
  	struct pglist_data	*zone_pgdat;
-	struct page		*zone_mem_map;
  	/* zone_start_pfn == zone_start_paddr >> PAGE_SHIFT */
  	unsigned long		zone_start_pfn;

Index: hogehoge/mm/page_alloc.c
===================================================================
--- hogehoge.orig/mm/page_alloc.c
+++ hogehoge/mm/page_alloc.c
@@ -2009,7 +2009,6 @@ static __meminit void init_currently_emp
  	zone_wait_table_init(zone, size);
  	pgdat->nr_zones = zone_idx(zone) + 1;

-	zone->zone_mem_map = pfn_to_page(zone_start_pfn);
  	zone->zone_start_pfn = zone_start_pfn;

  	memmap_init(size, pgdat->node_id, zone_idx(zone), zone_start_pfn);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
