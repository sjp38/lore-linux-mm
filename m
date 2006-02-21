Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
        by fgwmail5.fujitsu.co.jp (Fujitsu Gateway)
        with ESMTP id k1LC59e2026423 for <linux-mm@kvack.org>; Tue, 21 Feb 2006 21:05:09 +0900
        (envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from s11.gw.fujitsu.co.jp by m3.gw.fujitsu.co.jp (8.12.10/Fujitsu Domain Master)
	id k1LC580Y018901 for <linux-mm@kvack.org>; Tue, 21 Feb 2006 21:05:08 +0900
	(envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from s11.gw.fujitsu.co.jp (s11 [127.0.0.1])
	by s11.gw.fujitsu.co.jp (Postfix) with ESMTP id E42A11D8053
	for <linux-mm@kvack.org>; Tue, 21 Feb 2006 21:05:07 +0900 (JST)
Received: from fjm506.ms.jp.fujitsu.com (fjm506.ms.jp.fujitsu.com [10.56.99.86])
	by s11.gw.fujitsu.co.jp (Postfix) with ESMTP id 81C891D804F
	for <linux-mm@kvack.org>; Tue, 21 Feb 2006 21:05:07 +0900 (JST)
Received: from [127.0.0.1] (fjmscan501.ms.jp.fujitsu.com [10.56.99.141])by fjm506.ms.jp.fujitsu.com with ESMTP id k1LC51xf017237
	for <linux-mm@kvack.org>; Tue, 21 Feb 2006 21:05:02 +0900
Message-ID: <43FB0257.4080802@jp.fujitsu.com>
Date: Tue, 21 Feb 2006 21:06:47 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: [RFC][PATCH] bdata and pgdat initialization cleanup [4/5]  mod generic
 callers of alloc_bootmem_node
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Modifies argments of alloc_bootmem_node().

Signed-Off-By: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


Index: testtree/mm/page_alloc.c
===================================================================
--- testtree.orig/mm/page_alloc.c
+++ testtree/mm/page_alloc.c
@@ -2074,8 +2074,6 @@ static __meminit
  void zone_wait_table_init(struct zone *zone, unsigned long zone_size_pages)
  {
  	int i;
-	struct pglist_data *pgdat = zone->zone_pgdat;
-
  	/*
  	 * The per-page waitqueue mechanism uses hashed waitqueues
  	 * per zone.
@@ -2083,8 +2081,8 @@ void zone_wait_table_init(struct zone *z
  	zone->wait_table_size = wait_table_size(zone_size_pages);
  	zone->wait_table_bits =	wait_table_bits(zone->wait_table_size);
  	zone->wait_table = (wait_queue_head_t *)
-		alloc_bootmem_node(pgdat, zone->wait_table_size
-					* sizeof(wait_queue_head_t));
+		alloc_bootmem_node(BOOTMEM(pgdat->node_id),
+			   zone->wait_table_size * sizeof(wait_queue_head_t));

  	for(i = 0; i < zone->wait_table_size; ++i)
  		init_waitqueue_head(zone->wait_table + i);
@@ -2197,7 +2195,7 @@ static void __init alloc_node_mem_map(st
  		size = (pgdat->node_spanned_pages + 1) * sizeof(struct page);
  		map = alloc_remap(pgdat->node_id, size);
  		if (!map)
-			map = alloc_bootmem_node(pgdat, size);
+			map = alloc_bootmem_node(BOOTMEM(pgdat->node_id), size);
  		pgdat->node_mem_map = map;
  	}
  #ifdef CONFIG_FLATMEM
Index: testtree/mm/sparse.c
===================================================================
--- testtree.orig/mm/sparse.c
+++ testtree/mm/sparse.c
@@ -32,7 +32,7 @@ static struct mem_section *sparse_index_
  	unsigned long array_size = SECTIONS_PER_ROOT *
  				   sizeof(struct mem_section);

-	section = alloc_bootmem_node(NODE_DATA(nid), array_size);
+	section = alloc_bootmem_node(BOOTMEM(nid), array_size);

  	if (section)
  		memset(section, 0, array_size);
@@ -179,7 +179,7 @@ static struct page *sparse_early_mem_map
  	if (map)
  		return map;

-	map = alloc_bootmem_node(NODE_DATA(nid),
+	map = alloc_bootmem_node(BOOTMEM(nid),
  			sizeof(struct page) * PAGES_PER_SECTION);
  	if (map)
  		return map;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
