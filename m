Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id B6F506B0034
	for <linux-mm@kvack.org>; Mon, 12 Aug 2013 11:53:12 -0400 (EDT)
Received: by mail-pd0-f178.google.com with SMTP id w10so3557574pde.23
        for <linux-mm@kvack.org>; Mon, 12 Aug 2013 08:53:11 -0700 (PDT)
From: Haojian Zhuang <haojian.zhuang@gmail.com>
Subject: [PATCH] mm: vmscan: decrease cma pages from nr_reclaimed
Date: Mon, 12 Aug 2013 23:51:01 +0800
Message-Id: <1376322661-20917-1-git-send-email-haojian.zhuang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: m.szyprowski@samsung.com, linux-mm@kvack.org, akpm@linux-foundation.org, mgorman@suse.de
Cc: Haojian Zhuang <haojian.zhuang@gmail.com>

shrink_page_list() reclaims the pages. But the statistical data may
be inaccurate since some pages are CMA pages. If kernel needs to
reclaim unmovable memory (GFP_KERNEL flag), free CMA pages should not
be counted in nr_reclaimed pages.

Signed-off-by: Haojian Zhuang <haojian.zhuang@gmail.com>
---
 mm/vmscan.c | 17 +++++++++++++++++
 1 file changed, 17 insertions(+)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 2cff0d4..0cbe393 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -720,6 +720,10 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 	unsigned long nr_reclaimed = 0;
 	unsigned long nr_writeback = 0;
 	unsigned long nr_immediate = 0;
+#ifdef CONFIG_CMA
+	/* Number of pages freed with MIGRATE_CMA type */
+	unsigned long nr_reclaimed_cma = 0;
+#endif
 
 	cond_resched();
 
@@ -987,6 +991,11 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 					 * leave it off the LRU).
 					 */
 					nr_reclaimed++;
+#ifdef CONFIG_CMA
+					if (get_pageblock_migratetype(page) ==
+						MIGRATE_CMA)
+						nr_reclaimed_cma++;
+#endif
 					continue;
 				}
 			}
@@ -1005,6 +1014,10 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		__clear_page_locked(page);
 free_it:
 		nr_reclaimed++;
+#ifdef CONFIG_CMA
+		if (get_pageblock_migratetype(page) == MIGRATE_CMA)
+			nr_reclaimed_cma++;
+#endif
 
 		/*
 		 * Is there need to periodically free_page_list? It would
@@ -1044,6 +1057,10 @@ keep:
 	*ret_nr_unqueued_dirty += nr_unqueued_dirty;
 	*ret_nr_writeback += nr_writeback;
 	*ret_nr_immediate += nr_immediate;
+#ifdef CONFIG_CMA
+	if (allocflags_to_migratetype(sc->gfp_mask) == MIGRATE_UNMOVABLE)
+		nr_reclaimed -= nr_reclaimed_cma;
+#endif
 	return nr_reclaimed;
 }
 
-- 
1.8.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
