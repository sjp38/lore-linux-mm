Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f181.google.com (mail-ig0-f181.google.com [209.85.213.181])
	by kanga.kvack.org (Postfix) with ESMTP id AC6346B0262
	for <linux-mm@kvack.org>; Wed, 11 Nov 2015 23:33:11 -0500 (EST)
Received: by igbxm8 with SMTP id xm8so34449199igb.1
        for <linux-mm@kvack.org>; Wed, 11 Nov 2015 20:33:11 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTPS id p72si14240275iop.47.2015.11.11.20.32.50
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 11 Nov 2015 20:32:58 -0800 (PST)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v3 05/17] mm: move lazily freed pages to inactive list
Date: Thu, 12 Nov 2015 13:33:01 +0900
Message-Id: <1447302793-5376-6-git-send-email-minchan@kernel.org>
In-Reply-To: <1447302793-5376-1-git-send-email-minchan@kernel.org>
References: <1447302793-5376-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michael Kerrisk <mtk.manpages@gmail.com>, linux-api@vger.kernel.org, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Jason Evans <je@fb.com>, Daniel Micay <danielmicay@gmail.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Shaohua Li <shli@kernel.org>, Michal Hocko <mhocko@suse.cz>, yalin.wang2010@gmail.com, Minchan Kim <minchan@kernel.org>

MADV_FREE is a hint that it's okay to discard pages if there is memory
pressure and we use reclaimers(ie, kswapd and direct reclaim) to free them
so there is no value keeping them in the active anonymous LRU so this
patch moves them to inactive LRU list's head.

This means that MADV_FREE-ed pages which were living on the inactive list
are reclaimed first because they are more likely to be cold rather than
recently active pages.

An arguable issue for the approach would be whether we should put the page
to the head or tail of the inactive list.  I chose head because the kernel
cannot make sure it's really cold or warm for every MADV_FREE usecase but
at least we know it's not *hot*, so landing of inactive head would be a
comprimise for various usecases.

This fixes suboptimal behavior of MADV_FREE when pages living on the
active list will sit there for a long time even under memory pressure
while the inactive list is reclaimed heavily.  This basically breaks the
whole purpose of using MADV_FREE to help the system to free memory which
is might not be used.

Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Rik van Riel <riel@redhat.com>
Cc: Shaohua Li <shli@kernel.org>
Acked-by: Hugh Dickins <hughd@google.com>
Acked-by: Michal Hocko <mhocko@suse.cz>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 include/linux/swap.h |  2 +-
 mm/madvise.c         |  3 +++
 mm/swap.c            | 62 +++++++++++++++++++++++++++++-----------------------
 mm/truncate.c        |  2 +-
 4 files changed, 40 insertions(+), 29 deletions(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index 7ba7dccaf0e7..8e944c0cedea 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -307,7 +307,7 @@ extern void lru_add_drain(void);
 extern void lru_add_drain_cpu(int cpu);
 extern void lru_add_drain_all(void);
 extern void rotate_reclaimable_page(struct page *page);
-extern void deactivate_file_page(struct page *page);
+extern void deactivate_page(struct page *page);
 extern void swap_setup(void);
 
 extern void add_page_to_unevictable_list(struct page *page);
diff --git a/mm/madvise.c b/mm/madvise.c
index 6240a5de4a3a..3462a3ca9690 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -317,6 +317,9 @@ static int madvise_free_pte_range(pmd_t *pmd, unsigned long addr,
 			unlock_page(page);
 		}
 
+		if (PageActive(page))
+			deactivate_page(page);
+
 		if (pte_young(ptent) || pte_dirty(ptent)) {
 			/*
 			 * Some of architecture(ex, PPC) don't update TLB
diff --git a/mm/swap.c b/mm/swap.c
index 983f692a47fd..a2f2cd458de0 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -44,7 +44,7 @@ int page_cluster;
 
 static DEFINE_PER_CPU(struct pagevec, lru_add_pvec);
 static DEFINE_PER_CPU(struct pagevec, lru_rotate_pvecs);
-static DEFINE_PER_CPU(struct pagevec, lru_deactivate_file_pvecs);
+static DEFINE_PER_CPU(struct pagevec, lru_deactivate_pvecs);
 
 /*
  * This path almost never happens for VM activity - pages are normally
@@ -733,13 +733,13 @@ void lru_cache_add_active_or_unevictable(struct page *page,
 }
 
 /*
- * If the page can not be invalidated, it is moved to the
+ * If the file page can not be invalidated, it is moved to the
  * inactive list to speed up its reclaim.  It is moved to the
  * head of the list, rather than the tail, to give the flusher
  * threads some time to write it out, as this is much more
  * effective than the single-page writeout from reclaim.
  *
- * If the page isn't page_mapped and dirty/writeback, the page
+ * If the file page isn't page_mapped and dirty/writeback, the page
  * could reclaim asap using PG_reclaim.
  *
  * 1. active, mapped page -> none
@@ -752,32 +752,36 @@ void lru_cache_add_active_or_unevictable(struct page *page,
  * In 4, why it moves inactive's head, the VM expects the page would
  * be write it out by flusher threads as this is much more effective
  * than the single-page writeout from reclaim.
+ *
+ * If @page is anonymous page, it is moved to the inactive list.
  */
-static void lru_deactivate_file_fn(struct page *page, struct lruvec *lruvec,
+static void lru_deactivate_fn(struct page *page, struct lruvec *lruvec,
 			      void *arg)
 {
-	int lru, file;
-	bool active;
+	int lru;
+	bool file, active;
 
-	if (!PageLRU(page))
+	if (!PageLRU(page) || PageUnevictable(page))
 		return;
 
-	if (PageUnevictable(page))
-		return;
+	file = page_is_file_cache(page);
+	active = PageActive(page);
+	lru = page_lru_base_type(page);
 
-	/* Some processes are using the page */
-	if (page_mapped(page))
+	if (!file && !active)
 		return;
 
-	active = PageActive(page);
-	file = page_is_file_cache(page);
-	lru = page_lru_base_type(page);
+	if (file && page_mapped(page))
+		return;
 
 	del_page_from_lru_list(page, lruvec, lru + active);
 	ClearPageActive(page);
-	ClearPageReferenced(page);
 	add_page_to_lru_list(page, lruvec, lru);
 
+	if (!file)
+		goto out;
+
+	ClearPageReferenced(page);
 	if (PageWriteback(page) || PageDirty(page)) {
 		/*
 		 * PG_reclaim could be raced with end_page_writeback
@@ -793,9 +797,10 @@ static void lru_deactivate_file_fn(struct page *page, struct lruvec *lruvec,
 		list_move_tail(&page->lru, &lruvec->lists[lru]);
 		__count_vm_event(PGROTATED);
 	}
-
+out:
 	if (active)
 		__count_vm_event(PGDEACTIVATE);
+
 	update_page_reclaim_stat(lruvec, file, 0);
 }
 
@@ -821,22 +826,25 @@ void lru_add_drain_cpu(int cpu)
 		local_irq_restore(flags);
 	}
 
-	pvec = &per_cpu(lru_deactivate_file_pvecs, cpu);
+	pvec = &per_cpu(lru_deactivate_pvecs, cpu);
 	if (pagevec_count(pvec))
-		pagevec_lru_move_fn(pvec, lru_deactivate_file_fn, NULL);
+		pagevec_lru_move_fn(pvec, lru_deactivate_fn, NULL);
 
 	activate_page_drain(cpu);
 }
 
 /**
- * deactivate_file_page - forcefully deactivate a file page
+ * deactivate_page - forcefully deactivate a page
  * @page: page to deactivate
  *
- * This function hints the VM that @page is a good reclaim candidate,
- * for example if its invalidation fails due to the page being dirty
- * or under writeback.
+ * This function hints the VM that @page is a good reclaim candidate to
+ * accelerate the reclaim of @page.
+ * For example,
+ * 1. Invalidation of file-page fails due to the page being dirty or under
+ * writeback.
+ * 2. MADV_FREE hinted anonymous page.
  */
-void deactivate_file_page(struct page *page)
+void deactivate_page(struct page *page)
 {
 	/*
 	 * In a workload with many unevictable page such as mprotect,
@@ -846,11 +854,11 @@ void deactivate_file_page(struct page *page)
 		return;
 
 	if (likely(get_page_unless_zero(page))) {
-		struct pagevec *pvec = &get_cpu_var(lru_deactivate_file_pvecs);
+		struct pagevec *pvec = &get_cpu_var(lru_deactivate_pvecs);
 
 		if (!pagevec_add(pvec, page))
-			pagevec_lru_move_fn(pvec, lru_deactivate_file_fn, NULL);
-		put_cpu_var(lru_deactivate_file_pvecs);
+			pagevec_lru_move_fn(pvec, lru_deactivate_fn, NULL);
+		put_cpu_var(lru_deactivate_pvecs);
 	}
 }
 
@@ -882,7 +890,7 @@ void lru_add_drain_all(void)
 
 		if (pagevec_count(&per_cpu(lru_add_pvec, cpu)) ||
 		    pagevec_count(&per_cpu(lru_rotate_pvecs, cpu)) ||
-		    pagevec_count(&per_cpu(lru_deactivate_file_pvecs, cpu)) ||
+		    pagevec_count(&per_cpu(lru_deactivate_pvecs, cpu)) ||
 		    need_activate_page_drain(cpu)) {
 			INIT_WORK(work, lru_add_drain_per_cpu);
 			schedule_work_on(cpu, work);
diff --git a/mm/truncate.c b/mm/truncate.c
index 76e35ad97102..cf8d44679364 100644
--- a/mm/truncate.c
+++ b/mm/truncate.c
@@ -488,7 +488,7 @@ unsigned long invalidate_mapping_pages(struct address_space *mapping,
 			 * of interest and try to speed up its reclaim.
 			 */
 			if (!ret)
-				deactivate_file_page(page);
+				deactivate_page(page);
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
