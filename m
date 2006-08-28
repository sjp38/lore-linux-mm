Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e35.co.us.ibm.com (8.13.8/8.12.11) with ESMTP id k7SMNNlZ025769
	for <linux-mm@kvack.org>; Mon, 28 Aug 2006 18:23:23 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k7SMNNCr161478
	for <linux-mm@kvack.org>; Mon, 28 Aug 2006 16:23:23 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k7SMNNWU026032
	for <linux-mm@kvack.org>; Mon, 28 Aug 2006 16:23:23 -0600
Subject: [PATCH] remove static variable mm/page-writeback.c:total_pages
From: Chandra Seetharaman <sekharan@us.ibm.com>
Reply-To: sekharan@us.ibm.com
Content-Type: text/plain
Date: Mon, 28 Aug 2006 15:23:22 -0700
Message-Id: <1156803802.1196.73.camel@linuxchandra>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

page-writeback.c has a static local variable "total_pages", which 
is the total number of pages in the system.

There is a global variable "vm_total_pages", which is the total number
of pages the VM controls.

Both are assigned from the return value of nr_free_pagecache_pages().

This patch removes the local variable and uses the global variable in that
place.

One more issue with the local static variable "total_pages" is that it is
not updated when new pages are hot-added. Since vm_total_pages is updated
when new pages are hot-added, this patch fixes that problem too.

Signed-Off-by: Chandra Seetharaman <sekharan@us.ibm.com>

--
Index: linux-2.6.17/mm/page-writeback.c
===================================================================
--- linux-2.6.17.orig/mm/page-writeback.c
+++ linux-2.6.17/mm/page-writeback.c
@@ -45,7 +45,6 @@
  */
 static long ratelimit_pages = 32;
 
-static long total_pages;	/* The total number of pages in the machine. */
 static int dirty_exceeded __cacheline_aligned_in_smp;	/* Dirty mem may be over limit */
 
 /*
@@ -125,7 +124,7 @@ get_dirty_limits(long *pbackground, long
 	int unmapped_ratio;
 	long background;
 	long dirty;
-	unsigned long available_memory = total_pages;
+	unsigned long available_memory = vm_total_pages;
 	struct task_struct *tsk;
 
 #ifdef CONFIG_HIGHMEM
@@ -140,7 +139,7 @@ get_dirty_limits(long *pbackground, long
 
 	unmapped_ratio = 100 - ((global_page_state(NR_FILE_MAPPED) +
 				global_page_state(NR_ANON_PAGES)) * 100) /
-					total_pages;
+					vm_total_pages;
 
 	dirty_ratio = vm_dirty_ratio;
 	if (dirty_ratio > unmapped_ratio / 2)
@@ -493,7 +492,7 @@ void laptop_sync_completion(void)
 
 static void set_ratelimit(void)
 {
-	ratelimit_pages = total_pages / (num_online_cpus() * 32);
+	ratelimit_pages = vm_total_pages / (num_online_cpus() * 32);
 	if (ratelimit_pages < 16)
 		ratelimit_pages = 16;
 	if (ratelimit_pages * PAGE_CACHE_SIZE > 4096 * 1024)
@@ -522,9 +521,7 @@ void __init page_writeback_init(void)
 	long buffer_pages = nr_free_buffer_pages();
 	long correction;
 
-	total_pages = nr_free_pagecache_pages();
-
-	correction = (100 * 4 * buffer_pages) / total_pages;
+	correction = (100 * 4 * buffer_pages) / vm_total_pages;
 
 	if (correction < 100) {
 		dirty_background_ratio *= correction;

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
