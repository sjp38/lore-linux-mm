Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e35.co.us.ibm.com (8.13.8/8.12.11) with ESMTP id k7SMNQST025836
	for <linux-mm@kvack.org>; Mon, 28 Aug 2006 18:23:26 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k7SMNQKn249658
	for <linux-mm@kvack.org>; Mon, 28 Aug 2006 16:23:26 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k7SMNQMk026098
	for <linux-mm@kvack.org>; Mon, 28 Aug 2006 16:23:26 -0600
Subject: [PATCH] call mm/page-writeback.c:set_ratelimit() when new pages
	are hot-added
From: Chandra Seetharaman <sekharan@us.ibm.com>
Reply-To: sekharan@us.ibm.com
Content-Type: text/plain
Date: Mon, 28 Aug 2006 15:23:25 -0700
Message-Id: <1156803805.1196.74.camel@linuxchandra>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

ratelimit_pages in page-writeback.c is recalculated (in set_ratelimit())
every time a CPU is hot-added/removed. But this value is not recalculated
when new pages are hot-added.

This patch fixes that problem by calling set_ratelimit() when new pages
are hot-added.

Signed-Off-by: Chandra Seetharaman <sekharan@us.ibm.com>

--
Index: linux-2.6.17/mm/memory_hotplug.c
===================================================================
--- linux-2.6.17.orig/mm/memory_hotplug.c
+++ linux-2.6.17/mm/memory_hotplug.c
@@ -141,6 +141,7 @@ int online_pages(unsigned long pfn, unsi
 	unsigned long start_pfn;
 	struct zone *zone;
 	int need_zonelists_rebuild = 0;
+	extern void set_ratelimit(void);
 
 	/*
 	 * This doesn't need a lock to do pfn_to_page().
@@ -191,6 +192,7 @@ int online_pages(unsigned long pfn, unsi
 	if (need_zonelists_rebuild)
 		build_all_zonelists();
 	vm_total_pages = nr_free_pagecache_pages();
+	set_ratelimit();
 	return 0;
 }
 
Index: linux-2.6.17/mm/page-writeback.c
===================================================================
--- linux-2.6.17.orig/mm/page-writeback.c
+++ linux-2.6.17/mm/page-writeback.c
@@ -490,7 +490,7 @@ void laptop_sync_completion(void)
  * will write six megabyte chunks, max.
  */
 
-static void set_ratelimit(void)
+void set_ratelimit(void)
 {
 	ratelimit_pages = vm_total_pages / (num_online_cpus() * 32);
 	if (ratelimit_pages < 16)

-- 

----------------------------------------------------------------------
    Chandra Seetharaman               | Be careful what you choose....
              - sekharan@us.ibm.com   |      .......you may get it.
----------------------------------------------------------------------


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
