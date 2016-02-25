Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f175.google.com (mail-io0-f175.google.com [209.85.223.175])
	by kanga.kvack.org (Postfix) with ESMTP id 44E026B0253
	for <linux-mm@kvack.org>; Thu, 25 Feb 2016 02:45:31 -0500 (EST)
Received: by mail-io0-f175.google.com with SMTP id g203so79991964iof.2
        for <linux-mm@kvack.org>; Wed, 24 Feb 2016 23:45:31 -0800 (PST)
Received: from mail-ig0-x230.google.com (mail-ig0-x230.google.com. [2607:f8b0:4001:c05::230])
        by mx.google.com with ESMTPS id 69si8585883ioc.181.2016.02.24.23.45.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Feb 2016 23:45:30 -0800 (PST)
Received: by mail-ig0-x230.google.com with SMTP id hb3so7968660igb.0
        for <linux-mm@kvack.org>; Wed, 24 Feb 2016 23:45:30 -0800 (PST)
From: Chen Yucong <slaoub@gmail.com>
Subject: [PATCH] mm, memory hotplug: print debug message in the proper way for online_pages
Date: Thu, 25 Feb 2016 15:45:19 +0800
Message-Id: <1456386319-9050-1-git-send-email-slaoub@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: vbabka@suse.cz, rientjes@google.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

online_pages() simply returns an error value if
memory_notify(MEM_GOING_ONLINE, &arg) return a value that is not
what we want for successfully onlining target pages. This patch
arms to print more failure information like offline_pages() in
online_pages.

This patch also converts printk(KERN_<LEVEL>) to pr_<level>(),
and moves __offline_pages() to not print failure information with
KERN_INFO according to David Rientjes's suggestion[1].

[1] https://lkml.org/lkml/2016/2/24/1094

Signed-off-by: Chen Yucong <slaoub@gmail.com>
---
 mm/memory_hotplug.c | 32 ++++++++++++++++----------------
 1 file changed, 16 insertions(+), 16 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index c832ef3..4d15c20 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1059,10 +1059,9 @@ int __ref online_pages(unsigned long pfn, unsigned long nr_pages, int online_typ
 
 	ret = memory_notify(MEM_GOING_ONLINE, &arg);
 	ret = notifier_to_errno(ret);
-	if (ret) {
-		memory_notify(MEM_CANCEL_ONLINE, &arg);
-		return ret;
-	}
+	if (ret)
+		goto failed_addition;
+
 	/*
 	 * If this zone is not populated, then it is not in zonelist.
 	 * This means the page allocator ignores this zone.
@@ -1080,12 +1079,7 @@ int __ref online_pages(unsigned long pfn, unsigned long nr_pages, int online_typ
 		if (need_zonelists_rebuild)
 			zone_pcp_reset(zone);
 		mutex_unlock(&zonelists_mutex);
-		printk(KERN_DEBUG "online_pages [mem %#010llx-%#010llx] failed\n",
-		       (unsigned long long) pfn << PAGE_SHIFT,
-		       (((unsigned long long) pfn + nr_pages)
-			    << PAGE_SHIFT) - 1);
-		memory_notify(MEM_CANCEL_ONLINE, &arg);
-		return ret;
+		goto failed_addition;
 	}
 
 	zone->present_pages += onlined_pages;
@@ -1118,6 +1112,13 @@ int __ref online_pages(unsigned long pfn, unsigned long nr_pages, int online_typ
 	if (onlined_pages)
 		memory_notify(MEM_ONLINE, &arg);
 	return 0;
+
+failed_addition:
+	pr_debug("online_pages [mem %#010llx-%#010llx] failed\n",
+		 (unsigned long long) pfn << PAGE_SHIFT,
+		 (((unsigned long long) pfn + nr_pages) << PAGE_SHIFT) - 1);
+	memory_notify(MEM_CANCEL_ONLINE, &arg);
+	return ret;
 }
 #endif /* CONFIG_MEMORY_HOTPLUG_SPARSE */
 
@@ -1529,8 +1530,7 @@ do_migrate_range(unsigned long start_pfn, unsigned long end_pfn)
 
 		} else {
 #ifdef CONFIG_DEBUG_VM
-			printk(KERN_ALERT "removing pfn %lx from LRU failed\n",
-			       pfn);
+			pr_alert("removing pfn %lx from LRU failed\n", pfn);
 			dump_page(page, "failed to remove from LRU");
 #endif
 			put_page(page);
@@ -1858,7 +1858,7 @@ repeat:
 		ret = -EBUSY;
 		goto failed_removal;
 	}
-	printk(KERN_INFO "Offlined Pages %ld\n", offlined_pages);
+	pr_info("Offlined Pages %ld\n", offlined_pages);
 	/* Ok, all of our target is isolated.
 	   We cannot do rollback at this point. */
 	offline_isolated_pages(start_pfn, end_pfn);
@@ -1895,9 +1895,9 @@ repeat:
 	return 0;
 
 failed_removal:
-	printk(KERN_INFO "memory offlining [mem %#010llx-%#010llx] failed\n",
-	       (unsigned long long) start_pfn << PAGE_SHIFT,
-	       ((unsigned long long) end_pfn << PAGE_SHIFT) - 1);
+	pr_debug("memory offlining [mem %#010llx-%#010llx] failed\n",
+		 (unsigned long long) start_pfn << PAGE_SHIFT,
+		 ((unsigned long long) end_pfn << PAGE_SHIFT) - 1);
 	memory_notify(MEM_CANCEL_OFFLINE, &arg);
 	/* pushback to free area */
 	undo_isolate_page_range(start_pfn, end_pfn, MIGRATE_MOVABLE);
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
