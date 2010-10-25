Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 0138F8D0006
	for <linux-mm@kvack.org>; Sun, 24 Oct 2010 22:37:49 -0400 (EDT)
From: Bob Liu <lliubbo@gmail.com>
Subject: [PATCH] do_migrate_range: avoid failure as much as possible
Date: Mon, 25 Oct 2010 10:47:31 +0800
Message-ID: <1287974851-4064-1-git-send-email-lliubbo@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, fengguang.wu@intel.com, kamezawa.hiroyu@jp.fujitsu.com, mel@csn.ul.ie, kosaki.motohiro@jp.fujitsu.com, Bob Liu <lliubbo@gmail.com>
List-ID: <linux-mm.kvack.org>

It's normal for isolate_lru_page() to fail at times. The failures are
typically temporal and may well go away when offline_pages() retries
the call. So it seems more reasonable to migrate as much as possible
to increase the chance of complete success in next retry.

This patch remove page_count() check and remove putback_lru_pages() and
call migrate_pages() regardless of not_managed to reduce failure as much
as possible.

Signed-off-by: Bob Liu <lliubbo@gmail.com>
---
 mm/memory_hotplug.c |   12 ------------
 1 files changed, 0 insertions(+), 12 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index a4cfcdc..b64cc9b 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -687,7 +687,6 @@ do_migrate_range(unsigned long start_pfn, unsigned long end_pfn)
 	unsigned long pfn;
 	struct page *page;
 	int move_pages = NR_OFFLINE_AT_ONCE_PAGES;
-	int not_managed = 0;
 	int ret = 0;
 	LIST_HEAD(source);
 
@@ -709,10 +708,6 @@ do_migrate_range(unsigned long start_pfn, unsigned long end_pfn)
 					    page_is_file_cache(page));
 
 		} else {
-			/* Becasue we don't have big zone->lock. we should
-			   check this again here. */
-			if (page_count(page))
-				not_managed++;
 #ifdef CONFIG_DEBUG_VM
 			printk(KERN_ALERT "removing pfn %lx from LRU failed\n",
 			       pfn);
@@ -720,13 +715,6 @@ do_migrate_range(unsigned long start_pfn, unsigned long end_pfn)
 #endif
 		}
 	}
-	ret = -EBUSY;
-	if (not_managed) {
-		if (!list_empty(&source))
-			putback_lru_pages(&source);
-		goto out;
-	}
-	ret = 0;
 	if (list_empty(&source))
 		goto out;
 	/* this function returns # of failed pages */
-- 
1.6.3.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
