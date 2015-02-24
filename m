Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id C66BB6B0071
	for <linux-mm@kvack.org>; Tue, 24 Feb 2015 03:18:20 -0500 (EST)
Received: by padfa1 with SMTP id fa1so34369979pad.2
        for <linux-mm@kvack.org>; Tue, 24 Feb 2015 00:18:20 -0800 (PST)
Received: from lgeamrelo04.lge.com (lgeamrelo04.lge.com. [156.147.1.127])
        by mx.google.com with ESMTP id c9si19755120pas.189.2015.02.24.00.18.16
        for <linux-mm@kvack.org>;
        Tue, 24 Feb 2015 00:18:17 -0800 (PST)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH RFC 2/4] mm: change deactivate_page with deactivate_file_page
Date: Tue, 24 Feb 2015 17:18:15 +0900
Message-Id: <1424765897-27377-2-git-send-email-minchan@kernel.org>
In-Reply-To: <1424765897-27377-1-git-send-email-minchan@kernel.org>
References: <1424765897-27377-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Shaohua Li <shli@kernel.org>, Yalin.Wang@sonymobile.com, Minchan Kim <minchan@kernel.org>

Deactivate_page was born for file invalidation so it has too
specific logic for file-backed pages.
Make the name of function to file-specific.

Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 include/linux/swap.h |  2 +-
 mm/swap.c            | 20 ++++++++++----------
 mm/truncate.c        |  2 +-
 3 files changed, 12 insertions(+), 12 deletions(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index 7067eca501e2..cee108cbe2d5 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -307,7 +307,7 @@ extern void lru_add_drain(void);
 extern void lru_add_drain_cpu(int cpu);
 extern void lru_add_drain_all(void);
 extern void rotate_reclaimable_page(struct page *page);
-extern void deactivate_page(struct page *page);
+extern void deactivate_file_page(struct page *page);
 extern void swap_setup(void);
 
 extern void add_page_to_unevictable_list(struct page *page);
diff --git a/mm/swap.c b/mm/swap.c
index cd3a5e64cea9..5b2a60578f9c 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -42,7 +42,7 @@ int page_cluster;
 
 static DEFINE_PER_CPU(struct pagevec, lru_add_pvec);
 static DEFINE_PER_CPU(struct pagevec, lru_rotate_pvecs);
-static DEFINE_PER_CPU(struct pagevec, lru_deactivate_pvecs);
+static DEFINE_PER_CPU(struct pagevec, lru_deactivate_file_pvecs);
 
 /*
  * This path almost never happens for VM activity - pages are normally
@@ -743,7 +743,7 @@ void lru_cache_add_active_or_unevictable(struct page *page,
  * be write it out by flusher threads as this is much more effective
  * than the single-page writeout from reclaim.
  */
-static void lru_deactivate_fn(struct page *page, struct lruvec *lruvec,
+static void lru_deactivate_file_fn(struct page *page, struct lruvec *lruvec,
 			      void *arg)
 {
 	int lru, file;
@@ -811,22 +811,22 @@ void lru_add_drain_cpu(int cpu)
 		local_irq_restore(flags);
 	}
 
-	pvec = &per_cpu(lru_deactivate_pvecs, cpu);
+	pvec = &per_cpu(lru_deactivate_file_pvecs, cpu);
 	if (pagevec_count(pvec))
-		pagevec_lru_move_fn(pvec, lru_deactivate_fn, NULL);
+		pagevec_lru_move_fn(pvec, lru_deactivate_file_fn, NULL);
 
 	activate_page_drain(cpu);
 }
 
 /**
- * deactivate_page - forcefully deactivate a page
+ * deactivate_file_page - forcefully deactivate a file page
  * @page: page to deactivate
  *
  * This function hints the VM that @page is a good reclaim candidate,
  * for example if its invalidation fails due to the page being dirty
  * or under writeback.
  */
-void deactivate_page(struct page *page)
+void deactivate_file_page(struct page *page)
 {
 	/*
 	 * In a workload with many unevictable page such as mprotect, unevictable
@@ -836,11 +836,11 @@ void deactivate_page(struct page *page)
 		return;
 
 	if (likely(get_page_unless_zero(page))) {
-		struct pagevec *pvec = &get_cpu_var(lru_deactivate_pvecs);
+		struct pagevec *pvec = &get_cpu_var(lru_deactivate_file_pvecs);
 
 		if (!pagevec_add(pvec, page))
-			pagevec_lru_move_fn(pvec, lru_deactivate_fn, NULL);
-		put_cpu_var(lru_deactivate_pvecs);
+			pagevec_lru_move_fn(pvec, lru_deactivate_file_fn, NULL);
+		put_cpu_var(lru_deactivate_file_pvecs);
 	}
 }
 
@@ -872,7 +872,7 @@ void lru_add_drain_all(void)
 
 		if (pagevec_count(&per_cpu(lru_add_pvec, cpu)) ||
 		    pagevec_count(&per_cpu(lru_rotate_pvecs, cpu)) ||
-		    pagevec_count(&per_cpu(lru_deactivate_pvecs, cpu)) ||
+		    pagevec_count(&per_cpu(lru_deactivate_file_pvecs, cpu)) ||
 		    need_activate_page_drain(cpu)) {
 			INIT_WORK(work, lru_add_drain_per_cpu);
 			schedule_work_on(cpu, work);
diff --git a/mm/truncate.c b/mm/truncate.c
index ddec5a5966d7..a0619c492f17 100644
--- a/mm/truncate.c
+++ b/mm/truncate.c
@@ -513,7 +513,7 @@ unsigned long invalidate_mapping_pages(struct address_space *mapping,
 			 * of interest and try to speed up its reclaim.
 			 */
 			if (!ret)
-				deactivate_page(page);
+				deactivate_file_page(page);
 			count += ret;
 		}
 		pagevec_remove_exceptionals(&pvec);
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
