Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
        by fgwmail5.fujitsu.co.jp (Fujitsu Gateway)
        with ESMTP id k137bq5c012744 for <linux-mm@kvack.org>; Fri, 3 Feb 2006 16:37:52 +0900
        (envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from s13.gw.fujitsu.co.jp by m6.gw.fujitsu.co.jp (8.12.10/Fujitsu Domain Master)
	id k137bpJs011271 for <linux-mm@kvack.org>; Fri, 3 Feb 2006 16:37:51 +0900
	(envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from s13.gw.fujitsu.co.jp (s13 [127.0.0.1])
	by s13.gw.fujitsu.co.jp (Postfix) with ESMTP id 7C0201CC105
	for <linux-mm@kvack.org>; Fri,  3 Feb 2006 16:37:51 +0900 (JST)
Received: from fjm501.ms.jp.fujitsu.com (fjm501.ms.jp.fujitsu.com [10.56.99.71])
	by s13.gw.fujitsu.co.jp (Postfix) with ESMTP id F38C11CC0BD
	for <linux-mm@kvack.org>; Fri,  3 Feb 2006 16:37:50 +0900 (JST)
Received: from [127.0.0.1] (fjmscan501.ms.jp.fujitsu.com [10.56.99.141])by fjm501.ms.jp.fujitsu.com with ESMTP id k137bkUO020234
	for <linux-mm@kvack.org>; Fri, 3 Feb 2006 16:37:47 +0900
Message-ID: <43E30886.7060500@jp.fujitsu.com>
Date: Fri, 03 Feb 2006 16:38:46 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: [RFC] pearing off zone from physical memory layout [1/10] remove
 zone_mem_map
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

This patch removes zone->zone_mem_map.

Because of SPARSEMEM's cleanup, there are no codes
which touches zone->zone_mem_map directly.

This patch affects many archs which has NUMA, so enough tests
should be done. But I don't have test environments...
Please notify me if the kernel cannot be compiled because of this patch.
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
