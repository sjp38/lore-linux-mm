Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id E9763680FD0
	for <linux-mm@kvack.org>; Tue, 14 Feb 2017 14:36:18 -0500 (EST)
Received: by mail-oi0-f71.google.com with SMTP id a194so205633345oib.5
        for <linux-mm@kvack.org>; Tue, 14 Feb 2017 11:36:18 -0800 (PST)
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id y67si1824181iof.62.2017.02.14.11.36.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Feb 2017 11:36:18 -0800 (PST)
Received: from pps.filterd (m0109332.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v1EJXekv002949
	for <linux-mm@kvack.org>; Tue, 14 Feb 2017 11:36:18 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 28m7bm85j4-3
	(version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 14 Feb 2017 11:36:18 -0800
Received: from facebook.com (2401:db00:21:603d:face:0:19:0)	by
 mx-out.facebook.com (10.223.100.97) with ESMTP	id
 d864f5bef2ec11e6938a24be0593f280-8d5fca00 for <linux-mm@kvack.org>;	Tue, 14
 Feb 2017 11:36:14 -0800
From: Shaohua Li <shli@fb.com>
Subject: [PATCH V3 2/7] mm: move MADV_FREE pages into LRU_INACTIVE_FILE list
Date: Tue, 14 Feb 2017 11:36:08 -0800
Message-ID: <5c38c5f4d91e92ce86ee4f253e49c78708094632.1487100204.git.shli@fb.com>
In-Reply-To: <cover.1487100204.git.shli@fb.com>
References: <cover.1487100204.git.shli@fb.com>
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
 include/linux/mm_inline.h     | 20 +++++++++++++++++
 include/linux/swap.h          |  2 +-
 include/linux/vm_event_item.h |  2 +-
 mm/huge_memory.c              |  3 ---
 mm/madvise.c                  |  2 --
 mm/swap.c                     | 51 ++++++++++++++++++++++++-------------------
 mm/vmstat.c                   |  1 +
 7 files changed, 52 insertions(+), 29 deletions(-)

diff --git a/include/linux/mm_inline.h b/include/linux/mm_inline.h
index e030a68..e6e3af1 100644
--- a/include/linux/mm_inline.h
+++ b/include/linux/mm_inline.h
@@ -126,4 +126,24 @@ static __always_inline enum lru_list page_lru(struct page *page)
 
 #define lru_to_page(head) (list_entry((head)->prev, struct page, lru))
 
+/*
+ * lazyfree pages are clean anonymous pages. They have SwapBacked flag cleared
+ * to destinguish normal anonymous pages.
+ */
+static inline void set_page_lazyfree(struct page *page)
+{
+	VM_BUG_ON_PAGE(!PageAnon(page) || !PageSwapBacked(page), page);
+	ClearPageSwapBacked(page);
+}
+
+static inline void clear_page_lazyfree(struct page *page)
+{
+	VM_BUG_ON_PAGE(!PageAnon(page) || PageSwapBacked(page), page);
+	SetPageSwapBacked(page);
+}
+
+static inline bool page_is_lazyfree(struct page *page)
+{
+	return PageAnon(page) && !PageSwapBacked(page);
+}
 #endif
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
index e602265..4ddda58 100644
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
index 11fc65f..639c476 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -410,8 +410,6 @@ static int madvise_free_pte_range(pmd_t *pmd, unsigned long addr,
 			ptent = pte_mkold(ptent);
 			ptent = pte_mkclean(ptent);
 			set_pte_at(mm, addr, pte, ptent);
-			if (PageActive(page))
-				deactivate_page(page);
 			tlb_remove_tlb_entry(tlb, pte, addr);
 		}
 	}
diff --git a/mm/swap.c b/mm/swap.c
index c4910f1..9305c23 100644
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
@@ -268,6 +268,12 @@ static void __activate_page(struct page *page, struct lruvec *lruvec,
 		int lru = page_lru_base_type(page);
 
 		del_page_from_lru_list(page, lruvec, lru);
+		if (page_is_lazyfree(page)) {
+			clear_page_lazyfree(page);
+			/* charge to anon scanned/rotated reclaim_stat */
+			file = 0;
+			lru = LRU_INACTIVE_ANON;
+		}
 		SetPageActive(page);
 		lru += LRU_ACTIVE;
 		add_page_to_lru_list(page, lruvec, lru);
@@ -561,20 +567,21 @@ static void lru_deactivate_file_fn(struct page *page, struct lruvec *lruvec,
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
+		set_page_lazyfree(page);
+		add_page_to_lru_list(page, lruvec, LRU_INACTIVE_FILE);
 
-		__count_vm_event(PGDEACTIVATE);
-		update_page_reclaim_stat(lruvec, file, 0);
+		__count_vm_events(PGLAZYFREE, hpage_nr_pages(page));
+		update_page_reclaim_stat(lruvec, 1, 0);
 	}
 }
 
@@ -604,9 +611,9 @@ void lru_add_drain_cpu(int cpu)
 	if (pagevec_count(pvec))
 		pagevec_lru_move_fn(pvec, lru_deactivate_file_fn, NULL);
 
-	pvec = &per_cpu(lru_deactivate_pvecs, cpu);
+	pvec = &per_cpu(lru_lazyfree_pvecs, cpu);
 	if (pagevec_count(pvec))
-		pagevec_lru_move_fn(pvec, lru_deactivate_fn, NULL);
+		pagevec_lru_move_fn(pvec, lru_lazyfree_fn, NULL);
 
 	activate_page_drain(cpu);
 }
@@ -638,22 +645,22 @@ void deactivate_file_page(struct page *page)
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
 
@@ -704,7 +711,7 @@ void lru_add_drain_all(void)
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
