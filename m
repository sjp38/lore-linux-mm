Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
        by fgwmail5.fujitsu.co.jp (Fujitsu Gateway)
        with ESMTP id k137o7FX026231 for <linux-mm@kvack.org>; Fri, 3 Feb 2006 16:50:07 +0900
        (envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from s3.gw.fujitsu.co.jp by m3.gw.fujitsu.co.jp (8.12.10/Fujitsu Domain Master)
	id k137o60Y017796 for <linux-mm@kvack.org>; Fri, 3 Feb 2006 16:50:06 +0900
	(envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from s3.gw.fujitsu.co.jp (s3 [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 88031D40B3
	for <linux-mm@kvack.org>; Fri,  3 Feb 2006 16:50:06 +0900 (JST)
Received: from fjm505.ms.jp.fujitsu.com (fjm505.ms.jp.fujitsu.com [10.56.99.83])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 3E1FBD40B2
	for <linux-mm@kvack.org>; Fri,  3 Feb 2006 16:50:06 +0900 (JST)
Received: from [127.0.0.1] (fjmscan501.ms.jp.fujitsu.com [10.56.99.141])by fjm505.ms.jp.fujitsu.com with ESMTP id k137nTvi007987
	for <linux-mm@kvack.org>; Fri, 3 Feb 2006 16:49:29 +0900
Message-ID: <43E30B44.2080401@jp.fujitsu.com>
Date: Fri, 03 Feb 2006 16:50:28 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: [RFC] peeling off zone from physical memory layout [7/10]  i386 dicontig
 fix.
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Use for_each_page_in_zone() in i386/mm/discontig.c

Signed-Off-By: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


Index: hogehoge/arch/i386/mm/discontig.c
===================================================================
--- hogehoge.orig/arch/i386/mm/discontig.c
+++ hogehoge/arch/i386/mm/discontig.c
@@ -31,6 +31,7 @@
  #include <linux/nodemask.h>
  #include <linux/module.h>
  #include <linux/kexec.h>
+#include <linux/memorymap.h>

  #include <asm/e820.h>
  #include <asm/setup.h>
@@ -409,26 +410,15 @@ void __init set_highmem_pages_init(int b
  #ifdef CONFIG_HIGHMEM
  	struct zone *zone;
  	struct page *page;
+	void *iter;

  	for_each_zone(zone) {
  		unsigned long node_pfn, zone_start_pfn, zone_end_pfn;

  		if (!is_highmem(zone))
  			continue;
-
-		zone_start_pfn = zone->zone_start_pfn;
-		zone_end_pfn = zone_start_pfn + zone->spanned_pages;
-
-		printk("Initializing %s for node %d (%08lx:%08lx)\n",
-				zone->name, zone->zone_pgdat->node_id,
-				zone_start_pfn, zone_end_pfn);
-
-		for (node_pfn = zone_start_pfn; node_pfn < zone_end_pfn; node_pfn++) {
-			if (!pfn_valid(node_pfn))
-				continue;
-			page = pfn_to_page(node_pfn);
-			add_one_highpage_init(page, node_pfn, bad_ppro);
-		}
+		for_each_page_in_zone(page, zone , iter)
+			add_one_highpage_init(page, page_to_pfn(page), bad_ppro);
  	}
  	totalram_pages += totalhigh_pages;
  #endif

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
