Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 609D66B0035
	for <linux-mm@kvack.org>; Sat, 10 May 2014 03:15:58 -0400 (EDT)
Received: by mail-pd0-f170.google.com with SMTP id v10so4605929pde.29
        for <linux-mm@kvack.org>; Sat, 10 May 2014 00:15:58 -0700 (PDT)
Received: from mail-pd0-x22e.google.com (mail-pd0-x22e.google.com [2607:f8b0:400e:c02::22e])
        by mx.google.com with ESMTPS id dh1si3395723pbc.69.2014.05.10.00.15.57
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 10 May 2014 00:15:57 -0700 (PDT)
Received: by mail-pd0-f174.google.com with SMTP id w10so4589167pde.33
        for <linux-mm@kvack.org>; Sat, 10 May 2014 00:15:57 -0700 (PDT)
From: Jianyu Zhan <nasa4836@gmail.com>
Subject: [PATCH 1/3] mm: add comment for __mod_zone_page_stat
Date: Sat, 10 May 2014 15:15:39 +0800
Message-Id: <1d32d83e54542050dba3f711a8d10b1e951a9a58.1399705884.git.nasa4836@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mgorman@suse.de, cody@linux.vnet.ibm.com, liuj97@gmail.com, zhangyanfei@cn.fujitsu.com, srivatsa.bhat@linux.vnet.ibm.com, dave@sr71.net, iamjoonsoo.kim@lge.com, n-horiguchi@ah.jp.nec.com, kirill.shutemov@linux.intel.com, schwidefsky@de.ibm.com, nasa4836@gmail.com, gorcunov@gmail.com, riel@redhat.com, cl@linux.com, toshi.kani@hp.com, paul.gortmaker@windriver.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

__mod_zone_page_stat() is not irq-safe, so it should be used carefully.
And it is not appropirately documented now. This patch adds comment for
it, and also documents for some of its call sites.

Suggested-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Jianyu Zhan <nasa4836@gmail.com>
---
 mm/page_alloc.c |  2 ++
 mm/rmap.c       |  6 ++++++
 mm/vmstat.c     | 16 +++++++++++++++-
 3 files changed, 23 insertions(+), 1 deletion(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 5dba293..9d6f474 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -659,6 +659,8 @@ static inline int free_pages_check(struct page *page)
  *
  * And clear the zone's pages_scanned counter, to hold off the "all pages are
  * pinned" detection logic.
+ *
+ * Note: this function should be used with irq disabled.
  */
 static void free_pcppages_bulk(struct zone *zone, int count,
 					struct per_cpu_pages *pcp)
diff --git a/mm/rmap.c b/mm/rmap.c
index 9c3e773..6078a30 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -979,6 +979,8 @@ void page_add_anon_rmap(struct page *page,
 /*
  * Special version of the above for do_swap_page, which often runs
  * into pages that are exclusively owned by the current process.
+ * So we could use the irq-unsafe version __{inc|mod}_zone_page_stat
+ * here without others racing change it in between.
  * Everybody else should continue to use page_add_anon_rmap above.
  */
 void do_page_add_anon_rmap(struct page *page,
@@ -1077,6 +1079,10 @@ void page_remove_rmap(struct page *page)
 	/*
 	 * Hugepages are not counted in NR_ANON_PAGES nor NR_FILE_MAPPED
 	 * and not charged by memcg for now.
+	 *
+	 * And we are the last user of this page, so it is safe to use
+	 * the irq-unsafe version __{mod|dec}_zone_page here, since we
+	 * have no racer.
 	 */
 	if (unlikely(PageHuge(page)))
 		goto out;
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 302dd07..778f154 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -207,7 +207,21 @@ void set_pgdat_percpu_threshold(pg_data_t *pgdat,
 }
 
 /*
- * For use when we know that interrupts are disabled.
+ * Optimized modificatoin function.
+ *
+ * The code basically does the modification in two steps:
+ *
+ *  1. read the current counter based on the processor number
+ *  2. modificate the counter write it back.
+ *
+ * So this function should be used with the guarantee that
+ *
+ *  1. interrupts are disabled, or
+ *  2. interrupts are enabled, but no other sites would race to
+ *     modify this counter in between.
+ *
+ * Otherwise, an irq-safe version mod_zone_page_state() should
+ * be used instead.
  */
 void __mod_zone_page_state(struct zone *zone, enum zone_stat_item item,
 				int delta)
-- 
2.0.0-rc1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
