Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id 511B66B0032
	for <linux-mm@kvack.org>; Mon, 12 Aug 2013 21:09:52 -0400 (EDT)
Received: by mail-pd0-f182.google.com with SMTP id r10so4174042pdi.13
        for <linux-mm@kvack.org>; Mon, 12 Aug 2013 18:09:51 -0700 (PDT)
From: Haojian Zhuang <haojian.zhuang@gmail.com>
Subject: [PATCH v2] mm: vmscan: decrease cma pages from nr_reclaimed
Date: Tue, 13 Aug 2013 09:07:42 +0800
Message-Id: <1376356062-25200-1-git-send-email-haojian.zhuang@gmail.com>
In-Reply-To: <52092FB5.3060300@intel.com>
References: <52092FB5.3060300@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dave.hansen@intel.com, m.szyprowski@samsung.com, akpm@linux-foundation.org, mgorman@suse.de, linux-mm@kvack.org
Cc: Haojian Zhuang <haojian.zhuang@gmail.com>

shrink_page_list() reclaims the pages. But the statistical data may
be inaccurate since some pages are CMA pages. If kernel needs to
reclaim unmovable memory (GFP_KERNEL flag), free CMA pages should not
be counted in nr_reclaimed pages.

v2:
* Remove #ifdef CONFIG_CMA. Use IS_ENABLED() & is_migrate_cma() instead.

Signed-off-by: Haojian Zhuang <haojian.zhuang@gmail.com>
---
 mm/vmscan.c | 14 ++++++++++++++
 1 file changed, 14 insertions(+)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 2cff0d4..414f74f 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -720,6 +720,9 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 	unsigned long nr_reclaimed = 0;
 	unsigned long nr_writeback = 0;
 	unsigned long nr_immediate = 0;
+	/* Number of pages freed with MIGRATE_CMA type */
+	unsigned long nr_reclaimed_cma = 0;
+	int mt = 0;
 
 	cond_resched();
 
@@ -987,6 +990,9 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 					 * leave it off the LRU).
 					 */
 					nr_reclaimed++;
+					mt = get_pageblock_migratetype(page);
+					if (is_migrate_cma(mt))
+						nr_reclaimed_cma++;
 					continue;
 				}
 			}
@@ -1005,6 +1011,9 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		__clear_page_locked(page);
 free_it:
 		nr_reclaimed++;
+		mt = get_pageblock_migratetype(page);
+		if (is_migrate_cma(mt))
+			nr_reclaimed_cma++;
 
 		/*
 		 * Is there need to periodically free_page_list? It would
@@ -1044,6 +1053,11 @@ keep:
 	*ret_nr_unqueued_dirty += nr_unqueued_dirty;
 	*ret_nr_writeback += nr_writeback;
 	*ret_nr_immediate += nr_immediate;
+	if (IS_ENABLED(CONFIG_CMA)) {
+		mt = allocflags_to_migratetype(sc->gfp_mask);
+		if (mt == MIGRATE_UNMOVABLE)
+			nr_reclaimed -= nr_reclaimed_cma;
+	}
 	return nr_reclaimed;
 }
 
-- 
1.8.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
