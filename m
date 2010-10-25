Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 8466D6B00B5
	for <linux-mm@kvack.org>; Mon, 25 Oct 2010 01:12:08 -0400 (EDT)
Date: Mon, 25 Oct 2010 13:12:02 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH] memory-hotplug: only drain LRU when failed to offline pages
Message-ID: <20101025051202.GA22412@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Bob Liu <lliubbo@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "mel@csn.ul.ie" <mel@csn.ul.ie>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

do_migrate_range() offlines 1MB pages at one time and hence might be
called up to 16000 times when trying to offline 16GB memory. It makes
sense to avoid sending the costly IPIs to drain pages on all LRU for
the 99% cases that do_migrate_range() succeeds offlining some pages.

Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 mm/memory_hotplug.c |   24 ++++++++++--------------
 1 file changed, 10 insertions(+), 14 deletions(-)

--- linux-next.orig/mm/memory_hotplug.c	2010-10-25 11:20:47.000000000 +0800
+++ linux-next/mm/memory_hotplug.c	2010-10-25 13:07:10.000000000 +0800
@@ -788,7 +788,7 @@ static int offline_pages(unsigned long s
 {
 	unsigned long pfn, nr_pages, expire;
 	long offlined_pages;
-	int ret, drain, retry_max, node;
+	int ret, retry_max, node;
 	struct zone *zone;
 	struct memory_notify arg;
 
@@ -827,7 +827,6 @@ static int offline_pages(unsigned long s
 
 	pfn = start_pfn;
 	expire = jiffies + timeout;
-	drain = 0;
 	retry_max = 5;
 repeat:
 	/* start memory hot removal */
@@ -838,34 +837,31 @@ repeat:
 	if (signal_pending(current))
 		goto failed_removal;
 	ret = 0;
-	if (drain) {
-		lru_add_drain_all();
-		flush_scheduled_work();
-		cond_resched();
-		drain_all_pages();
-	}
-
 	pfn = scan_lru_pages(start_pfn, end_pfn);
 	if (pfn) { /* We have page on LRU */
 		ret = do_migrate_range(pfn, end_pfn);
 		if (!ret) {
-			drain = 1;
 			goto repeat;
 		} else {
 			if (ret < 0)
 				if (--retry_max == 0)
 					goto failed_removal;
 			yield();
-			drain = 1;
+			lru_add_drain_all();
+			flush_scheduled_work();
+			cond_resched();
+			drain_all_pages();
 			goto repeat;
 		}
 	}
-	/* drain all zone's lru pagevec, this is asyncronous... */
+
+	/* drain all zone's lru pagevec, this is asynchronous... */
 	lru_add_drain_all();
 	flush_scheduled_work();
 	yield();
-	/* drain pcp pages , this is synchrouns. */
+	/* drain pcp pages , this is asynchronous. */
 	drain_all_pages();
+
 	/* check again */
 	offlined_pages = check_pages_isolated(start_pfn, end_pfn);
 	if (offlined_pages < 0) {
@@ -873,7 +869,7 @@ repeat:
 		goto failed_removal;
 	}
 	printk(KERN_INFO "Offlined Pages %ld\n", offlined_pages);
-	/* Ok, all of our target is islaoted.
+	/* Ok, all of our target is isolated.
 	   We cannot do rollback at this point. */
 	offline_isolated_pages(start_pfn, end_pfn);
 	/* reset pagetype flags and makes migrate type to be MOVABLE */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
