Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id A6E8E5F0040
	for <linux-mm@kvack.org>; Thu, 21 Oct 2010 09:28:58 -0400 (EDT)
Received: by pwj2 with SMTP id 2so79133pwj.14
        for <linux-mm@kvack.org>; Thu, 21 Oct 2010 06:28:58 -0700 (PDT)
From: Bob Liu <lliubbo@gmail.com>
Subject: [PATCH 2/3] do_migrate_range: exit loop if not_managed is true.
Date: Thu, 21 Oct 2010 21:28:20 +0800
Message-Id: <1287667701-8081-2-git-send-email-lliubbo@gmail.com>
In-Reply-To: <1287667701-8081-1-git-send-email-lliubbo@gmail.com>
References: <1287667701-8081-1-git-send-email-lliubbo@gmail.com>
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, fengguang.wu@intel.com, kamezawa.hiroyu@jp.fujitsu.com, mel@csn.ul.ie, kosaki.motohiro@jp.fujitsu.com, Bob Liu <lliubbo@gmail.com>
List-ID: <linux-mm.kvack.org>

If not_managed is true all pages will be putback to lru, so
break the loop earlier to skip other pages isolate.

Signed-off-by: Bob Liu <lliubbo@gmail.com>
---
 mm/memory_hotplug.c |   10 ++++++----
 1 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index d4e940a..4f72184 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -709,15 +709,17 @@ do_migrate_range(unsigned long start_pfn, unsigned long end_pfn)
 					    page_is_file_cache(page));
 
 		} else {
-			/* Becasue we don't have big zone->lock. we should
-			   check this again here. */
-			if (page_count(page))
-				not_managed++;
 #ifdef CONFIG_DEBUG_VM
 			printk(KERN_ALERT "removing pfn %lx from LRU failed\n",
 			       pfn);
 			dump_page(page);
 #endif
+			/* Becasue we don't have big zone->lock. we should
+			   check this again here. */
+			if (page_count(page)) {
+				not_managed++;
+				break;
+			}
 		}
 	}
 	ret = -EBUSY;
-- 
1.5.6.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
