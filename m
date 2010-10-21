Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id D543D5F0040
	for <linux-mm@kvack.org>; Thu, 21 Oct 2010 09:29:14 -0400 (EDT)
Received: by mail-pw0-f41.google.com with SMTP id 2so79133pwj.14
        for <linux-mm@kvack.org>; Thu, 21 Oct 2010 06:29:15 -0700 (PDT)
From: Bob Liu <lliubbo@gmail.com>
Subject: [PATCH 3/3] do_migrate_range: reduce list_empty() check.
Date: Thu, 21 Oct 2010 21:28:21 +0800
Message-Id: <1287667701-8081-3-git-send-email-lliubbo@gmail.com>
In-Reply-To: <1287667701-8081-2-git-send-email-lliubbo@gmail.com>
References: <1287667701-8081-1-git-send-email-lliubbo@gmail.com>
 <1287667701-8081-2-git-send-email-lliubbo@gmail.com>
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, fengguang.wu@intel.com, kamezawa.hiroyu@jp.fujitsu.com, mel@csn.ul.ie, kosaki.motohiro@jp.fujitsu.com, Bob Liu <lliubbo@gmail.com>
List-ID: <linux-mm.kvack.org>

simple code for reducing list_empty(&source) check.

Signed-off-by: Bob Liu <lliubbo@gmail.com>
---
 mm/memory_hotplug.c |   17 +++++++----------
 1 files changed, 7 insertions(+), 10 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 4f72184..b6ffcfe 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -718,22 +718,19 @@ do_migrate_range(unsigned long start_pfn, unsigned long end_pfn)
 			   check this again here. */
 			if (page_count(page)) {
 				not_managed++;
+				ret = -EBUSY;
 				break;
 			}
 		}
 	}
-	ret = -EBUSY;
-	if (not_managed) {
-		if (!list_empty(&source))
+	if (!list_empty(&source)) {
+		if (not_managed) {
 			putback_lru_pages(&source);
-		goto out;
+			goto out;
+		}
+		/* this function returns # of failed pages */
+		ret = migrate_pages(&source, hotremove_migrate_alloc, 0, 1);
 	}
-	ret = 0;
-	if (list_empty(&source))
-		goto out;
-	/* this function returns # of failed pages */
-	ret = migrate_pages(&source, hotremove_migrate_alloc, 0, 1);
-
 out:
 	return ret;
 }
-- 
1.5.6.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
