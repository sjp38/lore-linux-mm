Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3AC2644059E
	for <linux-mm@kvack.org>; Fri, 24 Feb 2017 16:31:54 -0500 (EST)
Received: by mail-it0-f70.google.com with SMTP id w185so8065600ita.5
        for <linux-mm@kvack.org>; Fri, 24 Feb 2017 13:31:54 -0800 (PST)
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id 66si8937382ion.153.2017.02.24.13.31.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Feb 2017 13:31:53 -0800 (PST)
Received: from pps.filterd (m0089730.ppops.net [127.0.0.1])
	by m0089730.ppops.net (8.16.0.20/8.16.0.20) with SMTP id v1OLNqN4007758
	for <linux-mm@kvack.org>; Fri, 24 Feb 2017 13:31:53 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
	by m0089730.ppops.net with ESMTP id 28ts9jrswp-3
	(version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 24 Feb 2017 13:31:53 -0800
Received: from facebook.com (2401:db00:21:603d:face:0:19:0)	by
 mx-out.facebook.com (10.223.100.97) with ESMTP	id
 a735a1a2fad811e68f4c24be0593f280-92df9a00 for <linux-mm@kvack.org>;	Fri, 24
 Feb 2017 13:31:51 -0800
From: Shaohua Li <shli@fb.com>
Subject: [PATCH V5 3/6] mm: move MADV_FREE pages into LRU_INACTIVE_FILE list
Date: Fri, 24 Feb 2017 13:31:46 -0800
Message-ID: <2f87063c1e9354677b7618c647abde77b07561e5.1487965799.git.shli@fb.com>
In-Reply-To: <cover.1487965799.git.shli@fb.com>
References: <cover.1487965799.git.shli@fb.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Kernel-team@fb.com, mhocko@suse.com, minchan@kernel.org, hughd@google.com, hannes@cmpxchg.org, riel@redhat.com, mgorman@techsingularity.net, akpm@linux-foundation.org

madv MADV_FREE indicate pages are 'lazyfree'. They are still anonymous
pages, but they can be freed without pageout. To destinguish them
against normal anonymous pages, we clear their SwapBacked flag.

MADV_FREE pages could be freed without pageout, so they pretty much like
used once file pages. For such pages, we'd like to reclaim them once
there is memory pressure. Also it might be unfair reclaiming MADV_FREE
pages always before used once file pages and we definitively want to
reclaim the pages before other anonymous and file pages.

To speed up MADV_FREE pages reclaim, we put the pages into
LRU_INACTIVE_FILE list. The rationale is LRU_INACTIVE_FILE list is tiny
nowadays and should be full of used once file pages. Reclaiming
MADV_FREE pages will not have much interfere of anonymous and active
file pages. And the inactive file pages and MADV_FREE pages will be
reclaimed according to their age, so we don't reclaim too many MADV_FREE
pages too. Putting the MADV_FREE pages into LRU_INACTIVE_FILE_LIST also
means we can reclaim the pages without swap support. This idea is
suggested by Johannes.

This patch doesn't move MADV_FREE pages to LRU_INACTIVE_FILE list yet to
avoid bisect failure, next patch will do it.

The patch is based on Minchan's original patch.

Cc: Michal Hocko <mhocko@suse.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Hugh Dickins <hughd@google.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>
Suggested-by: Johannes Weiner <hannes@cmpxchg.org>
Signed-off-by: Shaohua Li <shli@fb.com>
---
 include/linux/swap.h          |  2 +-
 include/linux/vm_event_item.h |  2 +-
 mm/huge_memory.c              |  3 ---
 mm/madvise.c                  |  2 --
 mm/swap.c                     | 50 ++++++++++++++++++++++++-------------------
 mm/vmstat.c                   |  1 +
 6 files changed, 31 insertions(+), 29 deletions(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index 45e91dd..486494e 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -279,7 +279,7 @@ extern void lru_add_drain_cpu(int cpu);
 extern void lru_add_drain_all(void);
 extern void rotate_reclaimable_page(struct page *page);
 extern void deactivate_file_page(struct page *page);
-extern void deactivate_page(struct page *page);
+extern void mark_page_lazyfree(struct page *page);
 extern void swap_setup(void);
 
 extern void add_page_to_unevictable_list(struct page *page);
diff --git a/include/linux/vm_event_item.h b/include/linux/vm_event_item.h
index 6aa1b6c..94e58da 100644
--- a/include/linux/vm_event_item.h
+++ b/include/linux/vm_event_item.h
@@ -25,7 +25,7 @@ enum vm_event_item { PGPGIN, PGPGOUT, PSWPIN, PSWPOUT,
 		FOR_ALL_ZONES(PGALLOC),
 		FOR_ALL_ZONES(ALLOCSTALL),
 		FOR_ALL_ZONES(PGSCAN_SKIP),
-		PGFREE, PGACTIVATE, PGDEACTIVATE,
+		PGFREE, PGACTIVATE, PGDEACTIVATE, PGLAZYFREE,
 		PGFAULT, PGMAJFAULT,
 		PGLAZYFREED,
 		PGREFILL,
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index cf9fb46..3b7ee0c 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1562,9 +1562,6 @@ bool madvise_free_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
 		ClearPageDirty(page);
 	unlock_page(page);
 
-	if (PageActive(page))
-		deactivate_page(page);
-
 	if (pmd_young(orig_pmd) || pmd_dirty(orig_pmd)) {
 		orig_pmd = pmdp_huge_get_and_clear_full(tlb->mm, addr, pmd,
 			tlb->fullmm);
diff --git a/mm/madvise.c b/mm/madvise.c
index dc5927c..61e10b1 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -411,8 +411,6 @@ static int madvise_free_pte_range(pmd_t *pmd, unsigned long addr,
 			ptent = pte_mkold(ptent);
 			ptent = pte_mkclean(ptent);
 			set_pte_at(mm, addr, pte, ptent);
-			if (PageActive(page))
-				deactivate_page(page);
 			tlb_remove_tlb_entry(tlb, pte, addr);
 		}
 	}
diff --git a/mm/swap.c b/mm/swap.c
index c4910f1..c4fb4b9 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -46,7 +46,7 @@ int page_cluster;
 static DEFINE_PER_CPU(struct pagevec, lru_add_pvec);
 static DEFINE_PER_CPU(struct pagevec, lru_rotate_pvecs);
 static DEFINE_PER_CPU(struct pagevec, lru_deactivate_file_pvecs);
-static DEFINE_PER_CPU(struct pagevec, lru_deactivate_pvecs);
+static DEFINE_PER_CPU(struct pagevec, lru_lazyfree_pvecs);
 #ifdef CONFIG_SMP
 static DEFINE_PER_CPU(struct pagevec, activate_page_pvecs);
 #endif
@@ -561,20 +561,26 @@ static void lru_deactivate_file_fn(struct page *page, struct lruvec *lruvec,
 }
 
 
-static void lru_deactivate_fn(struct page *page, struct lruvec *lruvec,
+static void lru_lazyfree_fn(struct page *page, struct lruvec *lruvec,
 			    void *arg)
 {
-	if (PageLRU(page) && PageActive(page) && !PageUnevictable(page)) {
-		int file = page_is_file_cache(page);
-		int lru = page_lru_base_type(page);
+	if (PageLRU(page) && PageAnon(page) && PageSwapBacked(page) &&
+	    !PageUnevictable(page)) {
+		bool active = PageActive(page);
 
-		del_page_from_lru_list(page, lruvec, lru + LRU_ACTIVE);
+		del_page_from_lru_list(page, lruvec, LRU_INACTIVE_ANON + active);
 		ClearPageActive(page);
 		ClearPageReferenced(page);
-		add_page_to_lru_list(page, lruvec, lru);
+		/*
+		 * lazyfree pages are clean anonymous pages. They have
+		 * SwapBacked flag cleared to distinguish normal anonymous
+		 * pages
+		 */
+		ClearPageSwapBacked(page);
+		add_page_to_lru_list(page, lruvec, LRU_INACTIVE_FILE);
 
-		__count_vm_event(PGDEACTIVATE);
-		update_page_reclaim_stat(lruvec, file, 0);
+		__count_vm_events(PGLAZYFREE, hpage_nr_pages(page));
+		update_page_reclaim_stat(lruvec, 1, 0);
 	}
 }
 
@@ -604,9 +610,9 @@ void lru_add_drain_cpu(int cpu)
 	if (pagevec_count(pvec))
 		pagevec_lru_move_fn(pvec, lru_deactivate_file_fn, NULL);
 
-	pvec = &per_cpu(lru_deactivate_pvecs, cpu);
+	pvec = &per_cpu(lru_lazyfree_pvecs, cpu);
 	if (pagevec_count(pvec))
-		pagevec_lru_move_fn(pvec, lru_deactivate_fn, NULL);
+		pagevec_lru_move_fn(pvec, lru_lazyfree_fn, NULL);
 
 	activate_page_drain(cpu);
 }
@@ -638,22 +644,22 @@ void deactivate_file_page(struct page *page)
 }
 
 /**
- * deactivate_page - deactivate a page
+ * mark_page_lazyfree - make an anon page lazyfree
  * @page: page to deactivate
  *
- * deactivate_page() moves @page to the inactive list if @page was on the active
- * list and was not an unevictable page.  This is done to accelerate the reclaim
- * of @page.
+ * mark_page_lazyfree() moves @page to the inactive file list.
+ * This is done to accelerate the reclaim of @page.
  */
-void deactivate_page(struct page *page)
-{
-	if (PageLRU(page) && PageActive(page) && !PageUnevictable(page)) {
-		struct pagevec *pvec = &get_cpu_var(lru_deactivate_pvecs);
+void mark_page_lazyfree(struct page *page)
+ {
+	if (PageLRU(page) && PageAnon(page) && PageSwapBacked(page) &&
+	    !PageUnevictable(page)) {
+		struct pagevec *pvec = &get_cpu_var(lru_lazyfree_pvecs);
 
 		get_page(page);
 		if (!pagevec_add(pvec, page) || PageCompound(page))
-			pagevec_lru_move_fn(pvec, lru_deactivate_fn, NULL);
-		put_cpu_var(lru_deactivate_pvecs);
+			pagevec_lru_move_fn(pvec, lru_lazyfree_fn, NULL);
+		put_cpu_var(lru_lazyfree_pvecs);
 	}
 }
 
@@ -704,7 +710,7 @@ void lru_add_drain_all(void)
 		if (pagevec_count(&per_cpu(lru_add_pvec, cpu)) ||
 		    pagevec_count(&per_cpu(lru_rotate_pvecs, cpu)) ||
 		    pagevec_count(&per_cpu(lru_deactivate_file_pvecs, cpu)) ||
-		    pagevec_count(&per_cpu(lru_deactivate_pvecs, cpu)) ||
+		    pagevec_count(&per_cpu(lru_lazyfree_pvecs, cpu)) ||
 		    need_activate_page_drain(cpu)) {
 			INIT_WORK(work, lru_add_drain_per_cpu);
 			queue_work_on(cpu, lru_add_drain_wq, work);
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 69f9aff..7774196 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -992,6 +992,7 @@ const char * const vmstat_text[] = {
 	"pgfree",
 	"pgactivate",
 	"pgdeactivate",
+	"pglazyfree",
 
 	"pgfault",
 	"pgmajfault",
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
