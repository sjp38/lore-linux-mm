Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id C94E06B0292
	for <linux-mm@kvack.org>; Thu, 12 Oct 2017 05:37:45 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id k4so2660880wmc.20
        for <linux-mm@kvack.org>; Thu, 12 Oct 2017 02:37:45 -0700 (PDT)
Received: from outbound-smtp10.blacknight.com (outbound-smtp10.blacknight.com. [46.22.139.15])
        by mx.google.com with ESMTPS id e5si3033888edj.426.2017.10.12.02.37.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Oct 2017 02:37:44 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail04.blacknight.ie [81.17.254.17])
	by outbound-smtp10.blacknight.com (Postfix) with ESMTPS id 19E4D1C13F7
	for <linux-mm@kvack.org>; Thu, 12 Oct 2017 10:37:44 +0100 (IST)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 1/8] mm, page_alloc: Enable/disable IRQs once when freeing a list of pages
Date: Thu, 12 Oct 2017 10:30:56 +0100
Message-Id: <20171012093103.13412-2-mgorman@techsingularity.net>
In-Reply-To: <20171012093103.13412-1-mgorman@techsingularity.net>
References: <20171012093103.13412-1-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Linux-FSDevel <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Jan Kara <jack@suse.cz>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Dave Chinner <david@fromorbit.com>, Mel Gorman <mgorman@techsingularity.net>

Freeing a list of pages current enables/disables IRQs for each page freed.
This patch splits freeing a list of pages into two operations -- preparing
the pages for freeing and the actual freeing. This is a tradeoff - we're
taking two passes of the list to free in exchange for avoiding multiple
enable/disable of IRQs.

sparsetruncate (tiny)
                              4.14.0-rc4             4.14.0-rc4
                           janbatch-v1r1            oneirq-v1r1
Min          Time      149.00 (   0.00%)      141.00 (   5.37%)
1st-qrtle    Time      150.00 (   0.00%)      142.00 (   5.33%)
2nd-qrtle    Time      151.00 (   0.00%)      142.00 (   5.96%)
3rd-qrtle    Time      151.00 (   0.00%)      143.00 (   5.30%)
Max-90%      Time      153.00 (   0.00%)      144.00 (   5.88%)
Max-95%      Time      155.00 (   0.00%)      147.00 (   5.16%)
Max-99%      Time      201.00 (   0.00%)      195.00 (   2.99%)
Max          Time      236.00 (   0.00%)      230.00 (   2.54%)
Amean        Time      152.65 (   0.00%)      144.37 (   5.43%)
Stddev       Time        9.78 (   0.00%)       10.44 (  -6.72%)
Coeff        Time        6.41 (   0.00%)        7.23 ( -12.84%)
Best99%Amean Time      152.07 (   0.00%)      143.72 (   5.50%)
Best95%Amean Time      150.75 (   0.00%)      142.37 (   5.56%)
Best90%Amean Time      150.59 (   0.00%)      142.19 (   5.58%)
Best75%Amean Time      150.36 (   0.00%)      141.92 (   5.61%)
Best50%Amean Time      150.04 (   0.00%)      141.69 (   5.56%)
Best25%Amean Time      149.85 (   0.00%)      141.38 (   5.65%)

With a tiny number of files, each file truncated has resident page cache
and it shows that time to truncate is roughtly 5-6% with some minor jitter.

                                      4.14.0-rc4             4.14.0-rc4
                                   janbatch-v1r1            oneirq-v1r1
Hmean     SeqCreate ops         65.27 (   0.00%)       81.86 (  25.43%)
Hmean     SeqCreate read        39.48 (   0.00%)       47.44 (  20.16%)
Hmean     SeqCreate del      24963.95 (   0.00%)    26319.99 (   5.43%)
Hmean     RandCreate ops        65.47 (   0.00%)       82.01 (  25.26%)
Hmean     RandCreate read       42.04 (   0.00%)       51.75 (  23.09%)
Hmean     RandCreate del     23377.66 (   0.00%)    23764.79 (   1.66%)

As expected, there is a small gain for the delete operation.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 mm/page_alloc.c | 58 +++++++++++++++++++++++++++++++++++++++++++--------------
 1 file changed, 44 insertions(+), 14 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 77e4d3c5c57b..167e163cf733 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2590,24 +2590,26 @@ void mark_free_pages(struct zone *zone)
 }
 #endif /* CONFIG_PM */
 
-/*
- * Free a 0-order page
- * cold == true ? free a cold page : free a hot page
- */
-void free_hot_cold_page(struct page *page, bool cold)
+static bool free_hot_cold_page_prepare(struct page *page, unsigned long pfn)
 {
-	struct zone *zone = page_zone(page);
-	struct per_cpu_pages *pcp;
-	unsigned long flags;
-	unsigned long pfn = page_to_pfn(page);
 	int migratetype;
 
 	if (!free_pcp_prepare(page))
-		return;
+		return false;
 
 	migratetype = get_pfnblock_migratetype(page, pfn);
 	set_pcppage_migratetype(page, migratetype);
-	local_irq_save(flags);
+	return true;
+}
+
+static void free_hot_cold_page_commit(struct page *page, unsigned long pfn,
+				bool cold)
+{
+	struct zone *zone = page_zone(page);
+	struct per_cpu_pages *pcp;
+	int migratetype;
+
+	migratetype = get_pcppage_migratetype(page);
 	__count_vm_event(PGFREE);
 
 	/*
@@ -2620,7 +2622,7 @@ void free_hot_cold_page(struct page *page, bool cold)
 	if (migratetype >= MIGRATE_PCPTYPES) {
 		if (unlikely(is_migrate_isolate(migratetype))) {
 			free_one_page(zone, page, pfn, 0, migratetype);
-			goto out;
+			return;
 		}
 		migratetype = MIGRATE_MOVABLE;
 	}
@@ -2636,8 +2638,22 @@ void free_hot_cold_page(struct page *page, bool cold)
 		free_pcppages_bulk(zone, batch, pcp);
 		pcp->count -= batch;
 	}
+}
 
-out:
+/*
+ * Free a 0-order page
+ * cold == true ? free a cold page : free a hot page
+ */
+void free_hot_cold_page(struct page *page, bool cold)
+{
+	unsigned long flags;
+	unsigned long pfn = page_to_pfn(page);
+
+	if (!free_hot_cold_page_prepare(page, pfn))
+		return;
+
+	local_irq_save(flags);
+	free_hot_cold_page_commit(page, pfn, cold);
 	local_irq_restore(flags);
 }
 
@@ -2647,11 +2663,25 @@ void free_hot_cold_page(struct page *page, bool cold)
 void free_hot_cold_page_list(struct list_head *list, bool cold)
 {
 	struct page *page, *next;
+	unsigned long flags, pfn;
+
+	/* Prepare pages for freeing */
+	list_for_each_entry_safe(page, next, list, lru) {
+		pfn = page_to_pfn(page);
+		if (!free_hot_cold_page_prepare(page, pfn))
+			list_del(&page->lru);
+		page->private = pfn;
+	}
 
+	local_irq_save(flags);
 	list_for_each_entry_safe(page, next, list, lru) {
+		unsigned long pfn = page->private;
+
+		page->private = 0;
 		trace_mm_page_free_batched(page, cold);
-		free_hot_cold_page(page, cold);
+		free_hot_cold_page_commit(page, pfn, cold);
 	}
+	local_irq_restore(flags);
 }
 
 /*
-- 
2.14.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
